/// Ranks retained personal memories by relevance to a current request.
class YansiMemoryRelevanceEngine {
  const YansiMemoryRelevanceEngine();

  List<Map<String, dynamic>> rank({
    required String query,
    required List<Map<String, dynamic>> memories,
  }) {
    final terms = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((term) => term.length > 2)
        .toSet();

    final ranked = memories.map((memory) {
      final text = memory.values.map((value) => value.toString().toLowerCase()).join(' ');
      final matches = terms.where(text.contains).length;
      return {
        'memory': Map<String, dynamic>.from(memory),
        'relevance': terms.isEmpty ? 0.0 : matches / terms.length,
      };
    }).where((item) => (item['relevance'] as double) > 0).toList();

    ranked.sort((a, b) =>
        (b['relevance'] as double).compareTo(a['relevance'] as double));
    return List.unmodifiable(ranked);
  }
}
