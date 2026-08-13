import 'package:shared_preferences/shared_preferences.dart';

/// Permission boundary for Yansi's future internet/search capability.
///
/// This class does not perform network requests. It makes the permission,
/// transparency and source rules explicit so a search provider can be added
/// without giving Yansi unrestricted background access.
class YansiWebAccessPolicy {
  static const _enabledKey = 'permission_web_access';
  static const _providerKey = 'yansi_web_provider';
  static const _lastSourceKey = 'yansi_last_web_source';

  final SharedPreferences prefs;

  const YansiWebAccessPolicy({required this.prefs});

  bool get isEnabled => prefs.getBool(_enabledKey) == true;

  String get provider => prefs.getString(_providerKey)?.trim() ?? '';

  String get lastSource => prefs.getString(_lastSourceKey)?.trim() ?? '';

  Future<void> setEnabled(bool enabled) async {
    await prefs.setBool(_enabledKey, enabled);
    if (!enabled) {
      await prefs.remove(_lastSourceKey);
    }
  }

  Future<void> setProvider(String value) async {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      await prefs.remove(_providerKey);
      return;
    }
    await prefs.setString(_providerKey, normalized);
  }

  /// Records the source used for a user-approved web lookup.
  /// Sensitive query text is deliberately not persisted here.
  Future<void> recordApprovedSource(String source) async {
    if (!isEnabled) return;
    final normalized = source.trim();
    if (normalized.isEmpty) return;
    await prefs.setString(_lastSourceKey, normalized);
  }

  /// Returns whether Yansi may initiate a user-requested web lookup.
  /// Background web access is never implied by this policy.
  bool maySearch({required bool userRequested}) {
    return isEnabled && userRequested && provider.isNotEmpty;
  }

  Map<String, dynamic> status() => {
        'enabled': isEnabled,
        'provider': provider,
        'lastSource': lastSource,
        'backgroundSearchAllowed': false,
      };
}
