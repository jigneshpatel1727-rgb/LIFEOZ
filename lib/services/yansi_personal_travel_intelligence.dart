/// Connects a future spatial world model with personal LifeOS context.
/// Produces adaptive travel intelligence only; it does not navigate or execute actions.
class YansiPersonalTravelIntelligence {
  const YansiPersonalTravelIntelligence();

  Map<String, dynamic> plan({
    required String origin,
    required String destination,
    DateTime? departure,
    DateTime? arrival,
    List<Map<String, dynamic>> calendar = const [],
    List<Map<String, dynamic>> tasks = const [],
    List<Map<String, dynamic>> priorities = const [],
    List<Map<String, dynamic>> stops = const [],
  }) {
    final signals = <Map<String, dynamic>>[];
    for (final item in calendar.take(10)) {
      signals.add({'type': 'calendar', 'data': item});
    }
    for (final item in tasks.take(10)) {
      signals.add({'type': 'task', 'data': item});
    }
    for (final item in priorities.take(10)) {
      signals.add({'type': 'priority', 'data': item});
    }

    return {
      'mode': 'adaptive_travel',
      'origin': origin,
      'destination': destination,
      'departure': departure?.toUtc().toIso8601String(),
      'arrival': arrival?.toUtc().toIso8601String(),
      'personalStops': stops,
      'lifeSignals': signals,
      'dimensions': <String>[
        'time',
        'commitments',
        'tasks',
        'priorities',
        'stops',
        'future_live_context',
      ],
      'replanning': 'dynamic',
      'externalLiveDataRequired': true,
      'readOnly': true,
    };
  }

  List<String> preparationFocus(Map<String, dynamic> plan) {
    final focus = <String>[];
    final signals = plan['lifeSignals'];
    if (signals is List && signals.isNotEmpty) focus.add('Align the journey with active LifeOS commitments.');
    if ((plan['personalStops'] as List?)?.isNotEmpty == true) focus.add('Preserve important personal stops.');
    if (plan['departure'] != null || plan['arrival'] != null) focus.add('Protect the required time window.');
    if (focus.isEmpty) focus.add('Build context before making a strong travel recommendation.');
    return focus;
  }
}
