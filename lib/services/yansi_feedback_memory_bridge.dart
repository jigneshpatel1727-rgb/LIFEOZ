import 'yansi_action_feedback.dart';

/// Converts execution outcomes into bounded, explainable learning signals.
/// This does not autonomously rewrite Yansi or alter its core behavior.
class YansiFeedbackMemoryBridge {
  const YansiFeedbackMemoryBridge();

  Map<String, dynamic> toLearningContext(YansiActionResult result) {
    return <String, dynamic>{
      'capabilityId': result.capabilityId,
      'actionId': result.actionId,
      'outcome': result.outcome.name,
      'summary': result.summary,
      'completedAt': result.completedAt.toIso8601String(),
      'reinforce': result.succeeded,
      'needsReview': result.outcome == YansiActionOutcome.failed ||
          result.outcome == YansiActionOutcome.partial,
    };
  }
}
