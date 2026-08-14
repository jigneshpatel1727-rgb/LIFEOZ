/// Connects multiple spatial situations into one adaptive reasoning context.
/// A situation can represent a current place, destination, event, route, or future world state.
/// This layer ranks relationships; it does not execute external actions.
class YansiMultiWorldReasoning {
  const YansiMultiWorldReasoning();

  Map<String, dynamic> reason({
    required List<Map<String, dynamic>> worlds,
    List<Map<String, dynamic>> objectives = const [],
    List<Map<String, dynamic>> personalSignals = const [],
  }) {
    final situations = worlds.take(12).map((world) {
      final place = '${world['place'] ?? world['destination'] ?? ''}'.trim();
      final importance = ((world['importance'] as num?)?.toInt() ?? 50).clamp(0, 100);
      return {
        'place': place,
        'importance': importance,
        'world': world,
      };
    }).toList();

    final relationships = <Map<String, dynamic>>[];
    for (var i = 0; i < situations.length; i++) {
      for (var j = i + 1; j < situations.length; j++) {
        final a = situations[i];
        final b = situations[j];
        final score = (((a['importance'] as int) + (b['importance'] as int)) / 2).round();
        relationships.add({
          'from': a['place'],
          'to': b['place'],
          'relevance': score,
          'relationship': 'potentially_connected_situations',
        });
      }
    }

    relationships.sort((a, b) => (b['relevance'] as int).compareTo(a['relevance'] as int));
    return {
      'situations': situations,
      'relationships': relationships.take(20).toList(),
      'objectives': objectives.take(20).toList(),
      'personalSignals': personalSignals.take(20).toList(),
      'reasoningMode': 'multi_world_context',
      'adaptive': true,
      'readOnly': true,
      'requiresAuthorityForExternalAction': true,
    };
  }
}
