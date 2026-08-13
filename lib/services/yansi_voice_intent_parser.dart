class YansiVoiceIntent {
  final String intent;
  final String text;
  final double? amount;
  final String? category;
  const YansiVoiceIntent({required this.intent, required this.text, this.amount, this.category});
}

/// Lightweight, deterministic first-pass intent extraction for offline use.
/// A future approved AI provider can enrich this without changing callers.
class YansiVoiceIntentParser {
  const YansiVoiceIntentParser();

  YansiVoiceIntent parse(String input) {
    final text = input.trim();
    final lower = text.toLowerCase();
    final amountMatch = RegExp(r'(?:₹|rs\.?|inr\s*)([0-9]+(?:\.[0-9]+)?)').firstMatch(lower);
    final amount = amountMatch == null ? null : double.tryParse(amountMatch.group(1)!);

    if (amount != null && (lower.contains('spent') || lower.contains('paid') || lower.contains('bought'))) {
      return YansiVoiceIntent(intent: 'expense', text: text, amount: amount, category: _category(lower));
    }
    if (lower.startsWith('remind me') || lower.startsWith('i need to') || lower.contains('todo')) {
      return YansiVoiceIntent(intent: 'task', text: text);
    }
    if (lower.contains('tomorrow') || lower.contains('next week') || lower.contains('appointment') || lower.contains('due date')) {
      return YansiVoiceIntent(intent: 'calendar', text: text);
    }
    if (lower.contains('shopping') || lower.contains('grocery') || lower.contains('buy milk')) {
      return YansiVoiceIntent(intent: 'household', text: text);
    }
    if (lower.contains('diary') || lower.contains('journal')) {
      return YansiVoiceIntent(intent: 'diary', text: text);
    }
    return YansiVoiceIntent(intent: 'conversation', text: text);
  }

  String _category(String text) {
    if (text.contains('fuel') || text.contains('petrol') || text.contains('diesel')) return 'Fuel';
    if (text.contains('grocery') || text.contains('vegetable') || text.contains('milk')) return 'Household';
    if (text.contains('medicine') || text.contains('doctor') || text.contains('hospital')) return 'Health';
    if (text.contains('bill') || text.contains('electricity') || text.contains('recharge')) return 'Bills';
    return 'Other';
  }
}
