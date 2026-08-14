/// Central policy for deciding which context may enter Yansi reasoning.
///
/// The policy is intentionally conservative: sensitive or unapproved sources
/// are excluded rather than silently downgraded into trusted intelligence.
enum YansiContextSensitivity { publicData, personal, sensitive }

class YansiContextItem {
  final String source;
  final YansiContextSensitivity sensitivity;
  final bool userApproved;
  final bool permissionGranted;
  final Map<String, dynamic> data;

  const YansiContextItem({
    required this.source,
    this.sensitivity = YansiContextSensitivity.personal,
    this.userApproved = false,
    this.permissionGranted = false,
    this.data = const <String, dynamic>{},
  });
}

class YansiContextPrivacyDecision {
  final bool allowed;
  final String reason;

  const YansiContextPrivacyDecision(this.allowed, this.reason);
}

class YansiContextPrivacyPolicy {
  const YansiContextPrivacyPolicy();

  YansiContextPrivacyDecision evaluate(YansiContextItem item) {
    if (!item.userApproved) {
      return const YansiContextPrivacyDecision(
        false,
        'User approval is required for this context source.',
      );
    }

    if (item.sensitivity != YansiContextSensitivity.publicData &&
        !item.permissionGranted) {
      return const YansiContextPrivacyDecision(
        false,
        'Required permission is not granted.',
      );
    }

    return const YansiContextPrivacyDecision(true, 'Context may enter reasoning.');
  }
}
