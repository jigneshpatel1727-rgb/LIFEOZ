import 'lifeos_permission_gate.dart';

/// Policy boundary for Yansi's optional internet/current-information ability.
class YansiWebIntelligencePolicy {
  final LifeOSPermissionGate permissions;
  const YansiWebIntelligencePolicy(this.permissions);

  bool get canUseWeb => permissions.canUseWeb;

  bool shouldSearch(String request) {
    if (!canUseWeb) return false;
    final text = request.toLowerCase();
    return text.contains('latest') ||
        text.contains('today') ||
        text.contains('current') ||
        text.contains('search') ||
        text.contains('research') ||
        text.contains('compare') ||
        text.contains('news') ||
        text.contains('weather') ||
        text.contains('price');
  }

  Map<String, dynamic> requestPolicy({
    required String query,
    bool currentInformationNeeded = true,
  }) {
    final clean = query.trim();
    final allowed = canUseWeb && clean.isNotEmpty;
    return {
      'allowed': allowed,
      'query': clean,
      'reason': !canUseWeb
          ? 'internet_permission_required'
          : clean.isEmpty
              ? 'query_required'
              : 'approved_web_request',
      'currentInformationNeeded': currentInformationNeeded,
      'mustCiteSources': allowed,
      'mustShowExternalSourceUse': allowed,
      'mayStoreQueryInHistory': true,
    };
  }

  String explainAccess() => canUseWeb
      ? 'Yansi may use approved web/search services for current information when needed.'
      : 'Web access is disabled. Yansi will use available LifeOS knowledge instead.';
}
