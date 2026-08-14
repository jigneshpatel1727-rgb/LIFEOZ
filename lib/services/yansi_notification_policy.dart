/// Controls when Yansi should surface proactive intelligence.
/// Local policy only: no notification is emitted by this class.
enum YansiDeliveryMode { silent, ambient, alert }

class YansiNotificationDecision {
  final bool deliver;
  final YansiDeliveryMode mode;
  final String reason;
  const YansiNotificationDecision({required this.deliver,required this.mode,required this.reason});
}

class YansiNotificationPolicy {
  const YansiNotificationPolicy();

  YansiNotificationDecision decide({
    required String priority,
    required bool quietMode,
    required bool userIsActive,
    bool permissionGranted = false,
    double confidence = 0,
  }) {
    final p = priority.toUpperCase();
    final c = confidence.isNaN ? 0.0 : confidence.clamp(0.0, 1.0);
    if (!permissionGranted) {
      return const YansiNotificationDecision(deliver:false, mode:YansiDeliveryMode.silent, reason:'Notification permission is not granted.');
    }
    if (quietMode && p != 'HIGH') {
      return const YansiNotificationDecision(deliver:false, mode:YansiDeliveryMode.silent, reason:'Quiet mode suppresses non-critical signals.');
    }
    if (p == 'HIGH') {
      final mode = userIsActive ? YansiDeliveryMode.ambient : YansiDeliveryMode.alert;
      return YansiNotificationDecision(deliver:true, mode:mode, reason:c >= .8 ? 'High-priority signal with strong confidence.' : 'High-priority signal; confidence is limited, so delivery stays controlled.');
    }
    if (userIsActive && c >= .6) {
      return const YansiNotificationDecision(deliver:true, mode:YansiDeliveryMode.ambient, reason:'User is active and the signal has sufficient confidence.');
    }
    return YansiNotificationDecision(deliver:false, mode:YansiDeliveryMode.silent, reason:userIsActive ? 'Signal confidence is too low for ambient delivery.' : 'Non-critical signal deferred until useful.');
  }
}
