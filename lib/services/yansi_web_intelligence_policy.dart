import 'lifeos_permission_gate.dart';

/// Policy boundary for Yansi's optional internet/current-information ability.
class YansiWebIntelligencePolicy {
  final LifeOSPermissionGate permissions;
  const YansiWebIntelligencePolicy(this.permissions);

  bool get canUseWeb => permissions.canUseWeb;

  bool shouldSearch(String request) {
    if (!canUseWeb) return false;
    final text = request.toLowerCase();
    return text.contains('latest') || text.contains('today') || text.contains('current') || text.contains('search') || text.contains('research') || text.contains('compare') || text.contains('news') || text.contains('weather') || text.contains('price');
  }

  String explainAccess() => canUseWeb
      ? 'Yansi may use approved web/search services for current information when needed.'
      : 'Web access is disabled. Yansi will use available LifeOS knowledge instead.';
}
