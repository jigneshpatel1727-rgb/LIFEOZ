/// Produces a compact, attributable reasoning context from approved web results.
class YansiWebResultReasoningEngine {
  const YansiWebResultReasoningEngine();

  Map<String, dynamic> reason({
    required String query,
    required List<Map<String, dynamic>> results,
    String? lifeosContext,
  }) {
    final usable = results.where((result) {
      final title = result['title']?.toString().trim() ?? '';
      final source = result['source']?.toString().trim() ?? '';
      return title.isNotEmpty && source.isNotEmpty;
    }).toList(growable: false);

    return {
      'query': query,
      'context': lifeosContext,
      'resultCount': usable.length,
      'usableResults': List.unmodifiable(usable),
      'reasoningMode': 'approved_web_context',
      'requiresAttribution': true,
      'uncertainty': usable.isEmpty ? 'high' : 'context_dependent',
    };
  }
}
