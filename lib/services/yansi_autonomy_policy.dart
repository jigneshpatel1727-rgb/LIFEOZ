/// Defines Yansi's autonomy boundary without imposing rigid behavior rules.
/// Intelligence remains adaptive; authority remains explicitly bounded.
class YansiAutonomyPolicy {
  const YansiAutonomyPolicy();

  Map<String, dynamic> evaluate({
    required String capability,
    required bool permissionGranted,
    required bool sensitive,
    required bool dataChanging,
    required bool externalSideEffect,
  }) {
    final allowed = permissionGranted && !sensitive && !dataChanging && !externalSideEffect;

    if (allowed) {
      return {
        'autonomy': 'adaptive',
        'authority': 'permitted',
        'capability': capability,
        'requiresConfirmation': false,
        'reason': 'Yansi may decide dynamically within the granted non-destructive capability.',
      };
    }

    return {
      'autonomy': 'adaptive',
      'authority': permissionGranted ? 'bounded' : 'not_granted',
      'capability': capability,
      'requiresConfirmation': sensitive || dataChanging || externalSideEffect,
      'reason': permissionGranted
          ? 'Yansi may reason and prepare freely, but this capability crosses an authority boundary.'
          : 'Yansi may reason about the capability but cannot use it without permission.',
    };
  }
}
