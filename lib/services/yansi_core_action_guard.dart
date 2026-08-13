/// Final guard before a routed Yansi intent reaches a LifeOS core.
class YansiCoreActionGuard {
  const YansiCoreActionGuard();

  Map<String, dynamic> evaluate({
    required String core,
    required bool permissionGranted,
    required bool userConfirmed,
    required bool sensitive,
  }) {
    if (!permissionGranted) {
      return {'allowed': false, 'state': 'permission_required', 'core': core};
    }
    if (sensitive && !userConfirmed) {
      return {'allowed': false, 'state': 'confirmation_required', 'core': core};
    }
    return {'allowed': true, 'state': 'ready', 'core': core};
  }
}
