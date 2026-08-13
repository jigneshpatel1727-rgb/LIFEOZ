import 'package:shared_preferences/shared_preferences.dart';

/// Central contract for Yansi as a LifeOS companion.
///
/// Yansi is designed to be present by default for conversation and voice,
/// while capabilities that access external/private sources remain explicitly
/// permission-controlled. This class is policy only; it never bypasses the
/// Android operating system's runtime permissions.
class YansiCompanionContract {
  final SharedPreferences prefs;
  const YansiCompanionContract(this.prefs);

  /// Core companion voice is ON by default. Android microphone permission
  /// still has to be granted by the operating system.
  bool get voiceEnabled => prefs.getBool('permission_voice') ?? true;

  /// Ambient companion behavior is ON by default.
  bool get ambientEnabled => prefs.getBool('permission_background_ai') ?? true;

  /// Learning requires explicit approval.
  bool get learningEnabled => prefs.getBool('permission_personal_learning') ?? false;

  /// External web/search access requires explicit approval.
  bool get webAccessEnabled => prefs.getBool('permission_web') ?? false;

  /// Notifications/messages require explicit approval.
  bool get notificationAccessEnabled => prefs.getBool('permission_notifications') ?? false;

  /// Health/device integrations require explicit approval.
  bool get healthAccessEnabled => prefs.getBool('permission_health') ?? false;

  /// Yansi may suggest and prepare actions, but sensitive actions require
  /// confirmation. Yansi never grants itself new permissions.
  bool requiresConfirmation(String capability) {
    const sensitive = <String>{
      'send_message',
      'make_payment',
      'delete_data',
      'change_account',
      'publish',
      'install_update',
      'modify_core_behavior',
    };
    return sensitive.contains(capability);
  }

  bool canUse(String capability) {
    switch (capability) {
      case 'voice':
        return voiceEnabled;
      case 'ambient':
        return ambientEnabled;
      case 'learning':
        return learningEnabled;
      case 'web':
        return webAccessEnabled;
      case 'notifications':
        return notificationAccessEnabled;
      case 'health':
        return healthAccessEnabled;
      default:
        return false;
    }
  }
}
