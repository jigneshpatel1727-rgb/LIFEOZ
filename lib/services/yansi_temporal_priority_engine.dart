/// Estimates when a signal should surface based on urgency and time context.
class YansiTemporalPriorityEngine {
  const YansiTemporalPriorityEngine();

  Map<String, dynamic> schedule({
    required double priority,
    required int hour,
    bool quietHours = false,
    bool critical = false,
  }) {
    if (critical) return {'timing': 'now', 'reason': 'critical'};
    if (quietHours) return {'timing': 'later', 'reason': 'quiet_hours'};
    if (priority >= 0.8) return {'timing': 'soon', 'reason': 'high_priority'};
    if (hour >= 22 || hour < 7) return {'timing': 'next_active_period', 'reason': 'late_or_early'};
    return {'timing': 'when_relevant', 'reason': 'normal_priority'};
  }
}
