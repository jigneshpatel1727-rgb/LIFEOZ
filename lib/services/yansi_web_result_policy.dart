import 'yansi_web_access_policy.dart';

/// Controls how Yansi presents information returned by an approved web source.
/// It does not perform network requests.
class YansiWebResultPolicy {
  const YansiWebResultPolicy();

  bool mayPresent({
    required YansiWebAccessPolicy access,
    required bool userRequested,
    required String source,
  }) {
    return access.isEnabled &&
        userRequested &&
        access.provider.isNotEmpty &&
        source.trim().isNotEmpty;
  }

  String attribution(String source) {
    final value = source.trim();
    return value.isEmpty ? 'Source unavailable' : 'Source: $value';
  }

  String staleNotice() =>
      'Web information can change. Yansi will identify the source and should not treat external results as permanent LifeOS facts.';
}
