/// Lightweight, deterministic natural-language intent parser for Yansi.
///
/// This layer intentionally has no network/AI dependency. It converts common
/// user phrases into structured intents that the existing LifeOS storage layer
/// can consume. Ambiguous or sensitive actions remain confirmation-gated.
class YansiIntentParser {
  YansiIntent parse(String input) {
    final raw = input.trim();
    final text = raw.toLowerCase();
    if (raw.isEmpty) return YansiIntent.unknown(raw);

    final amount = _amount(text);
    final category = _category(text);

    if (_matches(text, ['spent', 'expense', 'paid', 'bought', 'purchase', 'cost me'])) {
      return YansiIntent(
        type: YansiIntentType.expense,
        text: raw,
        amount: amount,
        category: category,
        needsConfirmation: false,
      );
    }

    if (_matches(text, ['received', 'earned', 'income', 'salary', 'got paid'])) {
      return YansiIntent(
        type: YansiIntentType.income,
        text: raw,
        amount: amount,
        category: category,
        needsConfirmation: false,
      );
    }

    if (_matches(text, ['remind me', 'reminder', 'remember to', 'due on', 'due date'])) {
      return YansiIntent(
        type: YansiIntentType.reminder,
        text: raw,
        category: category,
        needsConfirmation: false,
      );
    }

    if (_matches(text, ['task', 'todo', 'to-do', 'do today', 'need to', 'finish'])) {
      return YansiIntent(
        type: YansiIntentType.task,
        text: raw,
        category: category,
        needsConfirmation: false,
      );
    }

    if (_matches(text, ['grocery', 'groceries', 'vegetables', 'milk', 'shopping', 'household'])) {
      return YansiIntent(
        type: YansiIntentType.household,
        text: raw,
        amount: amount,
        category: category ?? 'household',
        needsConfirmation: false,
      );
    }

    if (_matches(text, ['goal', 'target', 'save for', 'want to achieve'])) {
      return YansiIntent(
        type: YansiIntentType.goal,
        text: raw,
        amount: amount,
        category: category,
        needsConfirmation: false,
      );
    }

    if (_matches(text, ['diary', 'journal', 'today i', 'today was', 'i feel', 'my day'])) {
      return YansiIntent(
        type: YansiIntentType.diary,
        text: raw,
        category: category,
        needsConfirmation: false,
      );
    }

    if (_matches(text, ['delete', 'remove', 'cancel', 'send', 'pay', 'transfer'])) {
      return YansiIntent(
        type: YansiIntentType.sensitiveAction,
        text: raw,
        amount: amount,
        category: category,
        needsConfirmation: true,
      );
    }

    return YansiIntent.unknown(raw);
  }

  double? _amount(String text) {
    final matches = RegExp(r'(?:₹|rs\.?|inr\s*)\s*([0-9]+(?:\.[0-9]+)?)').allMatches(text);
    if (matches.isNotEmpty) return double.tryParse(matches.first.group(1)!);
    final loose = RegExp(r'\b([0-9]+(?:\.[0-9]+)?)\s*(?:rupees|rs)\b').firstMatch(text);
    return loose == null ? null : double.tryParse(loose.group(1)!);
  }

  String? _category(String text) {
    const categories = <String, List<String>>{
      'fuel': ['fuel', 'petrol', 'diesel', 'cng'],
      'food': ['food', 'restaurant', 'lunch', 'dinner', 'breakfast'],
      'grocery': ['grocery', 'groceries', 'vegetables', 'milk'],
      'transport': ['taxi', 'cab', 'bus', 'train', 'metro', 'transport'],
      'bills': ['bill', 'electricity', 'water bill', 'mobile bill', 'internet'],
      'shopping': ['shopping', 'clothes', 'shoes'],
      'health': ['medicine', 'doctor', 'hospital', 'health'],
    };
    for (final entry in categories.entries) {
      if (_matches(text, entry.value)) return entry.key;
    }
    return null;
  }

  bool _matches(String text, List<String> words) => words.any(text.contains);
}

enum YansiIntentType {
  expense,
  income,
  task,
  reminder,
  household,
  goal,
  diary,
  sensitiveAction,
  unknown,
}

class YansiIntent {
  final YansiIntentType type;
  final String text;
  final double? amount;
  final String? category;
  final bool needsConfirmation;

  const YansiIntent({
    required this.type,
    required this.text,
    this.amount,
    this.category,
    required this.needsConfirmation,
  });

  const YansiIntent.unknown(this.text)
      : type = YansiIntentType.unknown,
        amount = null,
        category = null,
        needsConfirmation = false;
}
