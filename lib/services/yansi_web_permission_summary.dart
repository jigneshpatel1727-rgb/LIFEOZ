import 'yansi_web_access_policy.dart';

/// Presentation model for Yansi's persistent personal-AI memory policy.
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
    return 'Web knowledge is available when you ask Yansi to search.';
  }

  String get privacyText =>
      'Approved Yansi searches are retained as part of your personal AI memory. Search history is not automatically deleted or capped.';

  String get retentionText =>
      'Yansi keeps the complete approved search history as long-term personal context.';
}
