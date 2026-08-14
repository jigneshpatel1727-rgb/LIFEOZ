/// Combines prediction horizon with current context to decide when preparation
/// should begin. It never schedules, executes, or changes user data.
class YansiTemporalAnticipation {
  const YansiTemporalAnticipation();

  Map<String, dynamic> anticipate({
    required String horizon,
    required double timingConfidence,
    required int priority,
    required int situationalPressure,
    required bool relatedCalendarSignal,
    required bool relatedTaskSignal,
  }) {
    final confidence = timingConfidence.clamp(0.0, 1.0).toDouble();
    final safePriority = priority.clamp(0, 100);
    final pressure = situationalPressure.clamp(0, 100);

    if (horizon == 'unknown' || confidence < 0.45) {
      return _result('observe', 0, 'Timing evidence is not strong enough for anticipation.');
    }

    var readiness = (safePriority * 0.45 + confidence * 35 + pressure * 0.20).round().clamp(0, 100);
    if (relatedCalendarSignal) readiness = (readiness + 8).clamp(0, 100);
    if (relatedTaskSignal) readiness = (readiness + 7).clamp(0, 100);

    if (horizon == 'now' || horizon == 'within_24_hours') {
      return _result(readiness >= 70 ? 'prepare_now' : 'prepare', readiness,
          'The predicted pattern is close enough that a non-destructive preparation step may be useful.');
    }
    if (horizon == 'within_3_days') {
      return _result(readiness >= 65 ? 'prepare_soon' : 'watch', readiness,
          'The predicted pattern is approaching; Yansi can keep the situation ready without interrupting unnecessarily.');
    }
    return _result('watch', readiness, 'The predicted pattern is still distant; continue observing for stronger evidence.');
  }

  Map<String, dynamic> _result(String state, int readiness, String reason) => {
        'state': state,
        'readiness': readiness,
        'reason': reason,
        'canAutoExecute': false,
        'requiresConfirmationForAction': true,
      };
}
