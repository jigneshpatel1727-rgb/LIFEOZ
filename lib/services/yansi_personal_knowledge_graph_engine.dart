/// Builds a lightweight personal knowledge graph from retained LifeOS records.
class YansiPersonalKnowledgeGraphEngine {
  const YansiPersonalKnowledgeGraphEngine();

  Map<String, dynamic> build(List<Map<String, dynamic>> records) {
    final nodes = <Map<String, dynamic>>[];
    final edges = <Map<String, dynamic>>[];

    for (var index = 0; index < records.length; index++) {
      final record = records[index];
      nodes.add({
        'id': 'record_$index',
        'type': (record['type'] ?? record['core'] ?? 'life_event').toString(),
        'label': (record['title'] ?? record['operation'] ?? record['pattern'] ?? 'Life event').toString(),
      });
    }

    for (var i = 0; i < records.length; i++) {
      for (var j = i + 1; j < records.length; j++) {
        final a = records[i];
        final b = records[j];
        final sharedKeys = a.keys
            .where((key) => key != 'timestamp' && b.containsKey(key))
            .where((key) => a[key]?.toString().isNotEmpty == true && a[key]?.toString() == b[key]?.toString())
            .toList(growable: false);
        if (sharedKeys.isNotEmpty) {
          edges.add({
            'from': 'record_$i',
            'to': 'record_$j',
            'type': 'shared_context',
            'fields': List.unmodifiable(sharedKeys),
          });
        }
      }
    }

    return {
      'nodes': List.unmodifiable(nodes),
      'edges': List.unmodifiable(edges),
      'retention': 'permanent',
      'source': 'LifeOS_history',
    };
  }
}
