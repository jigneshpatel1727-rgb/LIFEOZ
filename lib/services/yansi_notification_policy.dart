/// Controls when Yansi should surface proactive intelligence.
/// Local policy only: no notification is emitted by this class.
enum YansiDeliveryMode { silent, ambient, alert }

class YansiNotificationDecision {
  final bool deliver;
  final YansiDeliveryMode mode;
  final String reason;
  final double confidence;
  const YansiNotificationDecision({required this.deliver,required this.mode,required this.reason,this.confidence=0});

  Map<String,dynamic> toJson()=>{'deliver':deliver,'mode':mode.name,'reason':reason,'confidence':confidence};
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
    final c = confidence.isNaN ? 0.0 : confidence.clamp(0.0, 1.0).toDouble();
    if (!permissionGranted) {
      return YansiNotificationDecision(deliver:false,mode:YansiDeliveryMode.silent,reason:'Notification permission is not granted.',confidence:c);
    }
    if (quietMode && p != 'HIGH') {
      return YansiNotificationDecision(deliver:false,mode:YansiDeliveryMode.silent,reason:'Quiet mode suppresses non-critical signals.',confidence:c);
    }
    if (p == 'HIGH') {
      final mode = userIsActive ? YansiDeliveryMode.ambient : YansiDeliveryMode.alert;
      return YansiNotificationDecision(deliver:true,mode:mode,reason:c >= .8 ? 'High-priority signal with strong confidence.' : 'High-priority signal; confidence is limited, so delivery stays controlled.',confidence:c);
    }
    if (userIsActive && c >= .6) {
      return YansiNotificationDecision(deliver:true,mode:YansiDeliveryMode.ambient,reason:'User is active and the signal has sufficient confidence.',confidence:c);
    }
    return YansiNotificationDecision(deliver:false,mode:YansiDeliveryMode.silent,reason:userIsActive ? 'Signal confidence is too low for ambient delivery.' : 'Non-critical signal deferred until useful.',confidence:c);
  }
}
