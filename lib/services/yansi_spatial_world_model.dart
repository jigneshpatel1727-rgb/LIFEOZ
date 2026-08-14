/// Extensible world-model foundation for future maps, city intelligence,
/// travel planning and holographic/spatial experiences.
/// This layer stores semantic world information only; it does not navigate,
/// contact services, or perform external actions.
class YansiSpatialWorldModel {
  const YansiSpatialWorldModel();

  Map<String, dynamic> build({
    required String place,
    String? region,
    List<Map<String, dynamic>> landmarks = const [],
    List<Map<String, dynamic>> routes = const [],
    List<Map<String, dynamic>> events = const [],
    List<Map<String, dynamic>> constraints = const [],
  }) {
    return {
      'world': 'spatial',
      'place': place,
      'region': region,
      'landmarks': landmarks,
      'routes': routes,
      'events': events,
      'constraints': constraints,
      'layers': <String>[
        'geography',
        'transport',
        'places',
        'time',
        'events',
        'personal_context',
      ],
      'extensible': true,
      'readOnly': true,
    };
  }

  Map<String, dynamic> travelContext({
    required Map<String, dynamic> world,
    String? origin,
    String? destination,
    List<Map<String, dynamic>> personalStops = const [],
  }) {
    return {
      'origin': origin,
      'destination': destination,
      'world': world,
      'personalStops': personalStops,
      'planningMode': 'adaptive',
      'canReplan': true,
      'requiresExternalPermissionForLiveData': true,
      'readOnly': true,
    };
  }
}
