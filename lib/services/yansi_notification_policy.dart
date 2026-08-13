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
  }) {
    final p = priority.toUpperCase();
    if (!permissionGranted) {
      return const YansiNotificationDecision(deliver:false, mode:YansiDeliveryMode.silent, reason:'Notification permission is not granted.');
    }
    if (quietMode && p != 'HIGH') {
      return const YansiNotificationDecision(deliver:false, mode:YansiDeliveryMode.silent, reason:'Quiet mode suppresses non-critical signals.');
    }
    if (p == 'HIGH') {
      return YansiNotificationDecision(deliver:true, mode:userIsActive ? YansiDeliveryMode.ambient : YansiDeliveryMode.alert, reason:'High-priority signal.');
    }
    if (userIsActive) {
      return const YansiNotificationDecision(deliver:true, mode:YansiDeliveryMode.ambient, reason:'User is active; use ambient delivery.');
    }
    return const YansiNotificationDecision(deliver:false, mode:YansiDeliveryMode.silent, reason:'Non-critical signal deferred until useful.');
  }
}
