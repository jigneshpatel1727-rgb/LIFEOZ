import 'lifeos_permission_gate.dart';

class YansiWebIntelligencePolicyV2 {
  final LifeOSPermissionGate permissions;
  const YansiWebIntelligencePolicyV2(this.permissions);
  bool get canUseWeb => permissions.webEnabled;
  bool shouldSearch(String request) {
    if (!canUseWeb) return false;
    final text = request.toLowerCase();
    return text.contains('latest') || text.contains('today') || text.contains('current') ||
        text.contains('search') || text.contains('research') || text.contains('compare') ||
        text.contains('news') || text.contains('weather') || text.contains('price');
  }
}
