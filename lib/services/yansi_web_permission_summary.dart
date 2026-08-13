import 'yansi_web_access_policy.dart';

/// Small presentation model for the Permissions UI.
/// Keeps web-access state understandable without exposing query history.
class YansiWebPermissionSummary {
  final bool enabled;
  final String provider;
  final bool backgroundSearchAllowed;

  const YansiWebPermissionSummary({
    required this.enabled,
    required this.provider,
    required this.backgroundSearchAllowed,
  });

  factory YansiWebPermissionSummary.fromPolicy(YansiWebAccessPolicy policy) {
    return YansiWebPermissionSummary(
      enabled: policy.isEnabled,
      provider: policy.provider,
      backgroundSearchAllowed: false,
    );
  }

  String get statusText {
    if (!enabled) return 'Web knowledge is off.';
    if (provider.isEmpty) return 'Web knowledge is on, but no provider is approved.';
    return 'Web knowledge is available only when you ask Yansi to search.';
  }

  String get privacyText =>
      'Yansi does not search the web in the background. Search permission is separate from personal learning.';
}
