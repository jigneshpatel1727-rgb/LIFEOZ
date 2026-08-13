/// Classifies whether a Yansi question needs current web knowledge.
///
/// This is deliberately conservative: it never performs a network request and
/// never grants permission. The request gate remains the final authority.
class YansiWebQueryClassifier {
  static const _currentSignals = <String>[
    'today', 'now', 'latest', 'current', 'recent', 'this week',
    'this month', 'live', 'price', 'weather', 'news', 'score',
    'stock price', 'exchange rate', 'updated', '2026',
  ];

  bool likelyNeedsCurrentWebKnowledge(String input) {
    final text = input.trim().toLowerCase();
    if (text.isEmpty) return false;
    return _currentSignals.any(text.contains);
  }

  String explain(String input) {
    if (likelyNeedsCurrentWebKnowledge(input)) {
      return 'This question may need current information from an approved web source.';
    }
    return 'This question can normally be answered from LifeOS context without web access.';
  }
}
