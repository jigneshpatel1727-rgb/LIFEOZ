import 'package:shared_preferences/shared_preferences.dart';

/// Central permission and safety guard for Yansi capabilities.
/// Defaults are conservative: optional data access is disabled until enabled.
class YansiPrivacyGuard {
  final SharedPreferences prefs;
  const YansiPrivacyGuard(this.prefs);

  bool get voiceHistory => prefs.getBool('permission_voice_history') ?? false;
  bool get webAccess => prefs.getBool('permission_web_access') ?? false;
  bool get notifications => prefs.getBool('permission_notifications') ?? false;
  bool get healthData => prefs.getBool('permission_health_data') ?? false;
  bool get cloudSync => prefs.getBool('permission_cloud_sync') ?? false;

  Future<void> setVoiceHistory(bool value) => prefs.setBool('permission_voice_history', value);
  Future<void> setWebAccess(bool value) => prefs.setBool('permission_web_access', value);
  Future<void> setNotifications(bool value) => prefs.setBool('permission_notifications', value);
  Future<void> setHealthData(bool value) => prefs.setBool('permission_health_data', value);
  Future<void> setCloudSync(bool value) => prefs.setBool('permission_cloud_sync', value);

  bool canUseWeb() => webAccess;
  bool canStoreVoice() => voiceHistory;
  bool canReadNotifications() => notifications;
  bool canReadHealth() => healthData;
  bool canSyncCloud() => cloudSync;

  /// Financial, destructive, account, and external side-effect actions require
  /// an explicit confirmation regardless of other permissions.
  bool requiresConfirmation(String action) {
    final a = action.toLowerCase();
    return a.contains('delete') ||
        a.contains('remove') ||
        a.contains('pay') ||
        a.contains('transfer') ||
        a.contains('send') ||
        a.contains('purchase') ||
        a.contains('account') ||
        a.contains('sensitive');
  }
}
