/// Classifies permitted incoming notifications/messages for LifeOS routing.
class YansiNotificationIntelligenceEngine {
  const YansiNotificationIntelligenceEngine();

  Map<String, dynamic> classify({
    required String title,
    required String body,
  }) {
    final text = '$title $body'.toLowerCase();
    String category = 'general';
    if (_has(text, ['payment', 'paid', 'transaction', 'bank'])) category = 'financial';
    else if (_has(text, ['bill', 'renewal', 'due date', 'appointment'])) category = 'calendar';
    else if (_has(text, ['task', 'todo', 'assignment'])) category = 'productivity';
    else if (_has(text, ['shopping', 'grocery', 'buy'])) category = 'household';

    return {
      'title': title,
      'body': body,
      'category': category,
      'needsAttention': category != 'general',
      'source': 'permitted_notification',
    };
  }

  bool _has(String text, List<String> values) => values.any(text.contains);
}
