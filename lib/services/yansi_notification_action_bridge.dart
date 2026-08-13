import 'yansi_notification_intelligence_engine.dart';

/// Converts a classified permitted notification into a reviewable LifeOS intent.
class YansiNotificationActionBridge {
  final YansiNotificationIntelligenceEngine classifier;

  const YansiNotificationActionBridge({
    this.classifier = const YansiNotificationIntelligenceEngine(),
  });

  Map<String, dynamic> process({
    required String title,
    required String body,
  }) {
    final classified = classifier.classify(title: title, body: body);
    return {
      'classification': classified,
      'nextState': classified['needsAttention'] == true ? 'review_and_route' : 'observe',
      'requiresUserPermissionForAction': true,
      'requiresVerificationAfterAction': true,
    };
  }
}
