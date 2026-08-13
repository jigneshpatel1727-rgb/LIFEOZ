/// Normalizes approved web results into retained, attributable memory records.
class YansiWebResultMemoryBridge {
  const YansiWebResultMemoryBridge();

  Map<String, dynamic> capture({
    required String query,
    required List<Map<String, dynamic>> results,
  }) {
    return {
      'type': 'web_research_result',
      'query': query,
      'results': results
          .map((result) => Map<String, dynamic>.from(result))
          .toList(growable: false),
      'source': 'approved_web_search',
      'retention': 'permanent',
      'requiresSourceAttribution': true,
      'capturedAt': DateTime.now().toIso8601String(),
    };
  }

  bool canUseForReasoning(Map<String, dynamic> memory) {
    return memory['source'] == 'approved_web_search' &&
        memory['requiresSourceAttribution'] == true;
  }
}
