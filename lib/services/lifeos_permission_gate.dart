import 'package:shared_preferences/shared_preferences.dart';

/// Central permission policy for LifeOS intelligence sources.
/// Platform-specific permission prompts remain outside this policy layer.
class LifeOSPermissionGate {
  final SharedPreferences prefs;
  const LifeOSPermissionGate(this.prefs);

  bool get voiceEnabled => prefs.getBool('permission_voice') ?? false;
  bool get notificationEnabled => prefs.getBool('permission_notifications') ?? false;
  bool get webEnabled => prefs.getBool('permission_web') ?? false;
  bool get healthEnabled => prefs.getBool('permission_health') ?? false;
  bool get backgroundEnabled => prefs.getBool('permission_background_ai') ?? false;

  bool allows(String capability) {
    switch (capability) {
      case 'voice': return voiceEnabled;
      case 'notifications': return notificationEnabled;
      case 'web': return webEnabled;
      case 'health': return healthEnabled;
      case 'background': return backgroundEnabled;
      default: return false;
    }
  }

  Future<void> set(String capability, bool enabled) async {
    final key = switch (capability) {
      'voice' => 'permission_voice',
      'notifications' => 'permission_notifications',
      'web' => 'permission_web',
      'health' => 'permission_health',
      'background' => 'permission_background_ai',
      _ => null,
    };
    if (key != null) await prefs.setBool(key, enabled);
  }
}
