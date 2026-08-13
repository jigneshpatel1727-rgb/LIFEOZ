import 'yansi_notification_policy.dart';

/// Normalizes permitted LifeOS events before Yansi evaluates them.
enum YansiEventType { task, reminder, expense, household, goal, system }

class YansiEvent {
  final YansiEventType type;
  final String id,title;
  final DateTime at;
  final Map<String,dynamic> data;
  const YansiEvent({required this.type,required this.id,required this.title,required this.at,this.data=const {}});
}

class YansiEventIntake {
  final YansiNotificationPolicy policy;
  const YansiEventIntake({this.policy=const YansiNotificationPolicy()});

  YansiNotificationDecision evaluate(YansiEvent event,{required bool quietMode,required bool userIsActive,required bool notificationPermissionGranted}) {
    final raw='${event.data['priority']??event.data['urgency']??''}'.toUpperCase();
    final priority=raw.contains('URGENT')||raw.contains('HIGH')?'HIGH':raw.contains('MEDIUM')?'MEDIUM':'LOW';
    return policy.decide(priority:priority,quietMode:quietMode,userIsActive:userIsActive,permissionGranted:notificationPermissionGranted);
  }
}
