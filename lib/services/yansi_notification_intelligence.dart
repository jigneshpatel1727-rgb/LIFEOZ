/// Permission-aware notification intelligence boundary for Yansi.
///
/// This service does not read notifications by itself. The Android/platform
/// integration must explicitly provide notification events after the user
/// grants permission. Yansi can then classify and summarize permitted events.
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
  final bool requiresConfirmation;

  const YansiNotificationInsight({
    required this.category,
    required this.summary,
    this.suggestedAction,
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

      if (_containsAny(text, const ['bill due', 'payment due', 'due date'])) {
        result.add(YansiNotificationInsight(
          category: 'bill',
          summary: 'A payment-related notification may need your attention.',
          suggestedAction: 'Review the bill and add a due date if needed.',
          requiresConfirmation: true,
        ));
      } else if (_containsAny(text, const ['renewal', 'policy expires', 'insurance'])) {
        result.add(YansiNotificationInsight(
          category: 'insurance',
          summary: 'An insurance-related notification may need your attention.',
          suggestedAction: 'Review the policy date and renewal details.',
          requiresConfirmation: true,
        ));
      } else if (_containsAny(text, const ['order delivered', 'delivery', 'delivered'])) {
        result.add(const YansiNotificationInsight(
          category: 'delivery',
          summary: 'A delivery update was detected.',
        ));
      } else if (_containsAny(text, const ['appointment', 'meeting', 'scheduled'])) {
        result.add(const YansiNotificationInsight(
          category: 'calendar',
          summary: 'A possible appointment or scheduled event was detected.',
          requiresConfirmation: true,
        ));
      }
    }
    return result;
  }

  bool _containsAny(String text, List<String> values) =>
      values.any(text.contains);
}
