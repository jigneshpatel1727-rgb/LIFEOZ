/// Finds relationships between the user's world context and personal context.
/// It produces reasoning candidates only; it never executes actions.
class YansiWorldAwareReasoning {
  const YansiWorldAwareReasoning();

  List<Map<String, dynamic>> infer({
    required Map<String, dynamic> fusedContext,
    String? currentPlace,
    String? destination,
    DateTime? now,
  }) {
    final results = <Map<String, dynamic>>[];
    final evidence = fusedContext['evidence'];
    if (evidence is! List) return results;

    for (final item in evidence.whereType<Map>()) {
      final data = item['data'];
      if (data is! Map) continue;
      final place = '${data['place'] ?? data['location'] ?? ''}'.trim();
      final time = '${data['time'] ?? data['date'] ?? ''}'.trim();
      final relevance = ((data['relevance'] as num?)?.toInt() ?? 0).clamp(0, 100);

      if (currentPlace != null && currentPlace.isNotEmpty && place.isNotEmpty &&
          place.toLowerCase() == currentPlace.toLowerCase()) {
        results.add(_candidate('local_context', 'A personal signal is connected to the current place.', relevance + 10, item));
      }
      if (destination != null && destination.isNotEmpty && place.isNotEmpty &&
          place.toLowerCase() == destination.toLowerCase()) {
        results.add(_candidate('destination_context', 'A personal signal is connected to the destination.', relevance + 15, item));
      }
      if (time.isNotEmpty && now != null) {
        results.add(_candidate('time_context', 'A time-bound personal signal may affect planning.', relevance, item));
      }
    }

    results.sort((a, b) => (b['relevance'] as int).compareTo(a['relevance'] as int));
    return results.take(12).toList();
  }

  Map<String, dynamic> _candidate(String type, String explanation, int relevance, Map item) => {
        'type': type,
        'explanation': explanation,
        'relevance': relevance.clamp(0, 100),
        'evidence': Map<String, dynamic>.from(item),
        'action': 'reason_only',
        'requiresConfirmationForAction': true,
      };
}
