/// Permission-aware notification intelligence boundary for Yansi.
///
/// This service does not read notifications by itself. A platform integration
/// must explicitly provide notification events after the user grants access.
/// Yansi can then classify permitted events and decide whether an insight is
/// worth surfacing. It never sends, deletes, replies to, or edits messages.
class YansiNotificationEvent {
  final String source;
  final String title;
  final String body;
  final DateTime receivedAt;
  final bool sensitive;

  const YansiNotificationEvent({
    required this.source,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.sensitive = false,
  });
}

class YansiNotificationInsight {
  final String category;
  final String summary;
  final String? suggestedAction;
  final double? amount;
  final String intent;
  final bool requiresConfirmation;

  const YansiNotificationInsight({
    required this.category,
    required this.summary,
    this.suggestedAction,
    this.amount,
    this.intent = 'observe',
    this.requiresConfirmation = false,
  });
}

class YansiNotificationIntelligence {
  const YansiNotificationIntelligence();

  List<YansiNotificationInsight> classify(
    Iterable<YansiNotificationEvent> events,
  ) {
    final result = <YansiNotificationInsight>[];
    for (final event in events) {
      if (event.sensitive) continue;
      final text = '${event.title} ${event.body}'.toLowerCase();
      final amount = _extractAmount(event.body);

      if (_containsAny(text, const ['debited', 'spent', 'purchase', 'transaction', 'paid'])) {
        result.add(YansiNotificationInsight(
          category: _expenseCategory(text),
          summary: 'A possible expense signal was detected from ${event.source}.',
          suggestedAction: 'Review the amount and let Yansi categorize it if needed.',
          amount: amount,
          intent: 'expense_signal',
        ));
      } else if (_containsAny(text, const ['credited', 'salary', 'received', 'deposit'])) {
        result.add(YansiNotificationInsight(
          category: 'Income',
          summary: 'A possible income signal was detected.',
          amount: amount,
          intent: 'income_signal',
        ));
      } else if (_containsAny(text, const ['bill due', 'payment due', 'due date'])) {
        result.add(const YansiNotificationInsight(
          category: 'bill',
          summary: 'A payment-related notification may need your attention.',
          suggestedAction: 'Review the bill and add a due date if useful.',
          intent: 'calendar_signal',
          requiresConfirmation: true,
        ));
      } else if (_containsAny(text, const ['renewal', 'policy expires', 'insurance'])) {
        result.add(const YansiNotificationInsight(
          category: 'insurance',
          summary: 'An insurance-related notification may need your attention.',
          suggestedAction: 'Review the policy date and renewal details.',
          intent: 'calendar_signal',
          requiresConfirmation: true,
        ));
      } else if (_containsAny(text, const ['order delivered', 'delivery', 'delivered'])) {
        result.add(const YansiNotificationInsight(
          category: 'delivery',
          summary: 'A delivery update was detected.',
          intent: 'household_signal',
        ));
      } else if (_containsAny(text, const ['appointment', 'meeting', 'scheduled', 'deadline'])) {
        result.add(const YansiNotificationInsight(
          category: 'calendar',
          summary: 'A possible appointment, meeting or deadline was detected.',
          intent: 'calendar_signal',
          requiresConfirmation: true,
        ));
      }
    }
    return result;
  }

  bool shouldSurface({
    required YansiNotificationInsight insight,
    required bool notificationsEnabled,
    required bool backgroundEnabled,
    required bool materiallyNew,
    required DateTime localTime,
    int priority = 60,
    bool userIsActive = false,
  }) {
    if (!notificationsEnabled || !backgroundEnabled || !materiallyNew) return false;
    if (userIsActive) return true;
    if (localTime.hour >= 23 || localTime.hour < 7) return priority >= 90;
    return priority >= 60;
  }

  double? _extractAmount(String value) {
    final cleaned = value.replaceAll(',', '').replaceAll('₹', '');
    for (final pattern in [
      RegExp(r'(?:rs\.?|inr|rupees?)\s*(\d+(?:\.\d+)?)', caseSensitive: false),
      RegExp(r'(\d+(?:\.\d+)?)\s*(?:rs|inr|rupees)', caseSensitive: false),
    ]) {
      final match = pattern.firstMatch(cleaned);
      final number = match?.group(1);
      if (number != null) return double.tryParse(number);
    }
    return null;
  }

  String _expenseCategory(String text) {
    if (_containsAny(text, const ['grocery', 'groceries', 'rice', 'milk', 'vegetable'])) return 'Household';
    if (_containsAny(text, const ['fuel', 'petrol', 'diesel', 'cng'])) return 'Fuel';
    if (_containsAny(text, const ['restaurant', 'food', 'cafe'])) return 'Food';
    if (_containsAny(text, const ['electricity', 'water bill', 'gas bill', 'recharge'])) return 'Bills';
    return 'Other';
  }

  bool _containsAny(String text, List<String> values) => values.any(text.contains);
}
