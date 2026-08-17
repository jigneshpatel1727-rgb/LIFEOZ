import 'dart:math' as math;

/// A small deterministic intent layer for Phase 2.
///
/// This is intentionally local and explainable. It does not call a third-party
/// AI service and it never performs an action by itself. The caller decides
/// whether an intent is safe to execute or needs confirmation.
class YansiIntent {
  final String type;
  final String rawText;
  final Map<String, dynamic> fields;
  final double confidence;
  final bool requiresConfirmation;

  const YansiIntent({
    required this.type,
    required this.rawText,
    required this.fields,
    required this.confidence,
    required this.requiresConfirmation,
  });

  bool get isActionable => type != 'unknown';

  Map<String, dynamic> toMap() => {
        'type': type,
        'rawText': rawText,
        'fields': fields,
        'confidence': confidence,
        'requiresConfirmation': requiresConfirmation,
      };
}

class YansiPhase2IntentParser {
  static const _expenseWords = [
    'spent', 'spend', 'paid', 'pay', 'expense', 'bought', 'purchase',
    'खर्च', 'दिया', 'खरीदा',
  ];
  static const _incomeWords = [
    'received', 'income', 'salary', 'earned', 'credit',
    'आया', 'मिला', 'कमाई',
  ];
  static const _taskWords = [
    'task', 'todo', 'to do', 'do ', 'finish', 'complete', 'work',
    'करना', 'कर',
  ];
  static const _reminderWords = [
    'remind', 'reminder', 'remember', 'due', 'tomorrow', 'later',
    'याद', 'रिमाइंड',
  ];
  static const _householdWords = [
    'grocery', 'groceries', 'shopping', 'milk', 'vegetable', 'vegetables',
    'kitchen', 'household', 'दूध', 'सब्जी', 'किराना',
  ];
  static const _goalWords = [
    'goal', 'target', 'save for', 'plan to achieve', 'लक्ष्य', 'बचत लक्ष्य',
  ];
  static const _diaryWords = [
    'diary', 'journal', 'today i', 'today was', 'note this', 'मेरी डायरी',
  ];

  YansiIntent parse(String input) {
    final raw = input.trim();
    if (raw.isEmpty) {
      return _unknown(raw);
    }

    final text = raw.toLowerCase();
    final amount = _extractAmount(text);

    if (_containsAny(text, _expenseWords) && amount != null) {
      return YansiIntent(
        type: 'expense',
        rawText: raw,
        fields: {
          'amount': amount,
          'category': _guessCategory(text),
        },
        confidence: .92,
        requiresConfirmation: false,
      );
    }

    if (_containsAny(text, _incomeWords) && amount != null) {
      return YansiIntent(
        type: 'income',
        rawText: raw,
        fields: {'amount': amount},
        confidence: .90,
        requiresConfirmation: false,
      );
    }

    if (_containsAny(text, _reminderWords)) {
      return YansiIntent(
        type: 'reminder',
        rawText: raw,
        fields: {
          'text': _cleanActionText(raw),
          'dateHint': _dateHint(text),
        },
        confidence: .84,
        requiresConfirmation: true,
      );
    }

    if (_containsAny(text, _householdWords)) {
      return YansiIntent(
        type: 'household',
        rawText: raw,
        fields: {'item': _cleanActionText(raw)},
        confidence: .82,
        requiresConfirmation: false,
      );
    }

    if (_containsAny(text, _goalWords)) {
      return YansiIntent(
        type: 'goal',
        rawText: raw,
        fields: {'goal': _cleanActionText(raw)},
        confidence: .80,
        requiresConfirmation: false,
      );
    }

    if (_containsAny(text, _diaryWords)) {
      return YansiIntent(
        type: 'diary',
        rawText: raw,
        fields: {'text': raw},
        confidence: .78,
        requiresConfirmation: false,
      );
    }

    if (_containsAny(text, _taskWords)) {
      return YansiIntent(
        type: 'task',
        rawText: raw,
        fields: {'task': _cleanActionText(raw)},
        confidence: .80,
        requiresConfirmation: false,
      );
    }

    return _unknown(raw);
  }

  YansiIntent _unknown(String raw) => YansiIntent(
        type: 'unknown',
        rawText: raw,
        fields: const {},
        confidence: 0,
        requiresConfirmation: false,
      );

  bool _containsAny(String text, List<String> words) =>
      words.any(text.contains);

  double? _extractAmount(String text) {
    final match = RegExp(
      r'(?:₹|rs\.?|inr\s*)?\s*([0-9]+(?:[.,][0-9]{1,2})?)\s*(?:rupees|rs)?',
      caseSensitive: false,
    ).firstMatch(text);
    if (match == null) return null;
    return double.tryParse(match.group(1)!.replaceAll(',', ''));
  }

  String _guessCategory(String text) {
    const categories = <String, List<String>>{
      'fuel': ['fuel', 'petrol', 'diesel', 'गाड़ी'],
      'food': ['food', 'lunch', 'dinner', 'breakfast', 'restaurant', 'chai', 'tea'],
      'grocery': ['grocery', 'groceries', 'vegetable', 'milk', 'किराना', 'सब्जी'],
      'transport': ['taxi', 'uber', 'auto', 'bus', 'train', 'transport'],
      'bills': ['bill', 'electricity', 'mobile', 'internet', 'recharge'],
    };
    for (final entry in categories.entries) {
      if (entry.value.any(text.contains)) return entry.key;
    }
    return 'general';
  }

  String _dateHint(String text) {
    if (text.contains('tomorrow')) return 'tomorrow';
    if (text.contains('today')) return 'today';
    if (text.contains('week')) return 'this_week';
    return 'unspecified';
  }

  String _cleanActionText(String raw) {
    final value = raw.trim();
    return value.length <= 180 ? value : value.substring(0, 180).trim();
  }

  // Kept here so future scoring can add small confidence adjustments without
  // changing the public intent model.
  double confidenceNoiseSeed(String text) => math.min(1, text.length / 1000);
}
