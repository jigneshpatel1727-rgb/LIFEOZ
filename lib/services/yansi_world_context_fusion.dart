/// Fuses personal LifeOS context with a spatial world model.
/// This is a reasoning input layer only: it does not navigate, contact services,
/// or perform external actions.
class YansiWorldContextFusion {
  const YansiWorldContextFusion();

  Map<String, dynamic> fuse({
    required Map<String, dynamic> world,
    List<Map<String, dynamic>> personalSignals = const [],
    List<Map<String, dynamic>> commitments = const [],
    List<Map<String, dynamic>> goals = const [],
    List<Map<String, dynamic>> travelSignals = const [],
  }) {
    final evidence = <Map<String, dynamic>>[];
    evidence.addAll(personalSignals.take(20).map((e) => {'domain': 'personal', 'data': e}));
    evidence.addAll(commitments.take(20).map((e) => {'domain': 'commitment', 'data': e}));
    evidence.addAll(goals.take(20).map((e) => {'domain': 'goal', 'data': e}));
    evidence.addAll(travelSignals.take(20).map((e) => {'domain': 'travel', 'data': e}));

    return {
      'world': world,
      'evidence': evidence,
      'fusionMode': 'contextual_spatial_reasoning',
      'domains': <String>['world', 'personal', 'commitments', 'goals', 'travel'],
      'supports': <String>[
        'situational_understanding',
        'travel_preparation',
        'place_aware_planning',
        'future_spatial_visualization',
      ],
      'readOnly': true,
      'requiresPermissionForExternalData': true,
    };
  }

  List<Map<String, dynamic>> strongestSignals(Map<String, dynamic> fused, {int limit = 8}) {
    final raw = fused['evidence'];
    if (raw is! List) return const [];
    final signals = raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    signals.sort((a, b) {
      final ar = (a['data'] is Map ? ((a['data'] as Map)['relevance'] as num?)?.toDouble() : null) ?? 0;
      final br = (b['data'] is Map ? ((b['data'] as Map)['relevance'] as num?)?.toDouble() : null) ?? 0;
      return br.compareTo(ar);
    });
    return signals.take(limit.clamp(1, 20)).toList();
  }
}
