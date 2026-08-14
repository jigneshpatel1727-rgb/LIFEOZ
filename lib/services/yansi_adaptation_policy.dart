import 'yansi_action_feedback.dart';

/// Controls how execution feedback may influence future Yansi reasoning.
///
/// This is intentionally bounded: feedback can improve contextual ranking and
/// reliability signals, but it cannot rewrite application code, permissions,
/// safety rules, or Yansi's core behavior autonomously.
class YansiAdaptationSignal {
  final String capabilityId;
  final double reliability;
  final int observations;
  final DateTime updatedAt;

  const YansiAdaptationSignal({
    required this.capabilityId,
    required this.reliability,
    required this.observations,
    required this.updatedAt,
  });
}

class YansiAdaptationPolicy {
  const YansiAdaptationPolicy();

  YansiAdaptationSignal update({
    required YansiAdaptationSignal? previous,
    required YansiFeedbackSignal feedback,
  }) {
    final oldReliability = previous?.reliability ?? 0.5;
    final oldCount = previous?.observations ?? 0;

    final delta = switch (feedback.outcome) {
      YansiActionOutcome.success => 0.05,
      YansiActionOutcome.partial => 0.01,
      YansiActionOutcome.failed => -0.05,
      YansiActionOutcome.cancelled => 0.0,
      YansiActionOutcome.unavailable => -0.02,
    };

    final reliability = (oldReliability + delta).clamp(0.0, 1.0).toDouble();
    return YansiAdaptationSignal(
      capabilityId: feedback.capabilityId,
      reliability: reliability,
      observations: oldCount + 1,
      updatedAt: feedback.timestamp,
    );
  }
}
