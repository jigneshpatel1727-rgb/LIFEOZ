/// Detects whether current observed behavior may put a goal under pressure.
class YansiGoalPressureEngine {
  const YansiGoalPressureEngine();

  Map<String, dynamic> assess({
    required double goalAmount,
    required double currentProgress,
    required double monthlyContribution,
    required double monthlyRequired,
  }) {
    final gap = (monthlyRequired - monthlyContribution).clamp(0.0, double.infinity).toDouble();
    final pressure = monthlyRequired > 0 && monthlyContribution < monthlyRequired;
    return {
      'goalUnderPressure': pressure,
      'monthlyGap': gap,
      'remainingGoal': (goalAmount - currentProgress).clamp(0.0, double.infinity),
      'recommendation': pressure
          ? 'Review the goal plan and consider adjusting contribution, timeline, or spending.'
          : 'Current observed contribution is meeting the planned monthly requirement.',
    };
  }
}
