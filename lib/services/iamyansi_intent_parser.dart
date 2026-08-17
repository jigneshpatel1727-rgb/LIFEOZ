/// Deterministic natural-language intent parser for iamyansi.
///
/// No network or third-party AI dependency. It converts common spoken phrases
/// into structured intents that the shared five-core storage boundary can use.
class IamyansiIntentParser {
  IamyansiIntent parse(String input) {
    final raw = input.trim();
    final text = raw.toLowerCase();
    if (raw.isEmpty) return IamyansiIntent.unknown(raw);

    final amount = _amount(text);
    final category = _category(text);

    if (_matches(text, ['spent', 'expense', 'paid', 'bought', 'purchase', 'cost me'])) {
      return IamyansiIntent(type: IamyansiIntentType.expense, text: raw, amount: amount, category: category);
    }
    if (_matches(text, ['received', 'earned', 'income', 'salary', 'got paid'])) {
      return IamyansiIntent(type: IamyansiIntentType.income, text: raw, amount: amount, category: category);
    }
    if (_matches(text, ['remind me', 'reminder', 'remember to', 'due on', 'due date'])) {
      return IamyansiIntent(type: IamyansiIntentType.reminder, text: raw, category: category);
    }
    if (_matches(text, ['task', 'todo', 'to-do', 'do today', 'need to', 'finish'])) {
      return IamyansiIntent(type: IamyansiIntentType.task, text: raw, category: category);
    }
    if (_matches(text, ['grocery', 'groceries', 'vegetables', 'milk', 'shopping', 'household'])) {
      return IamyansiIntent(type: IamyansiIntentType.household, text: raw, amount: amount, category: category ?? 'household');
    }
    if (_matches(text, ['goal', 'target', 'save for', 'want to achieve'])) {
      return IamyansiIntent(type: IamyansiIntentType.goal, text: raw, amount: amount, category: category);
    }
    if (_matches(text, ['diary', 'journal', 'today i', 'today was', 'i feel', 'my day'])) {
      return IamyansiIntent(type: IamyansiIntentType.diary, text: raw, category: category);
    }
    if (_matches(text, ['delete', 'remove', 'cancel', 'send', 'pay', 'transfer'])) {
      return IamyansiIntent(type: IamyansiIntentType.sensitiveAction, text: raw, amount: amount, category: category, needsConfirmation: true);
    }
    return IamyansiIntent.unknown(raw);
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

enum IamyansiIntentType { expense, income, task, reminder, household, goal, diary, sensitiveAction, unknown }

class IamyansiIntent {
  final IamyansiIntentType type;
  final String text;
  final double? amount;
  final String? category;
  final bool needsConfirmation;

  const IamyansiIntent({required this.type, required this.text, this.amount, this.category, this.needsConfirmation = false});

  const IamyansiIntent.unknown(this.text)
      : type = IamyansiIntentType.unknown,
        amount = null,
        category = null,
        needsConfirmation = false;
}
