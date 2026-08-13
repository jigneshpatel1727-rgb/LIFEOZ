/// Finds relationships between retained memories using shared structured fields.
class YansiMemoryRelationshipEngine {
  const YansiMemoryRelationshipEngine();

  List<Map<String, dynamic>> connect(List<Map<String, dynamic>> memories) {
    final relationships = <Map<String, dynamic>>[];
    for (var i = 0; i < memories.length; i++) {
      for (var j = i + 1; j < memories.length; j++) {
        final a = memories[i];
        final b = memories[j];
        final shared = <String>[];
        for (final key in a.keys) {
          if (key == 'timestamp' || !b.containsKey(key)) continue;
          final left = a[key]?.toString().trim();
          final right = b[key]?.toString().trim();
          if (left != null && right != null && left.isNotEmpty && left == right) {
            shared.add(key);
          }
        }
        if (shared.isNotEmpty) {
          relationships.add({
            'firstMemoryIndex': i,
            'secondMemoryIndex': j,
            'sharedFields': List.unmodifiable(shared),
            'relationship': 'shared_context',
          });
        }
      }
    }
    return List.unmodifiable(relationships);
  }
}
