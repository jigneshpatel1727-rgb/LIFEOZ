/// Connects observed financial patterns with a target goal without promising outcomes.
class YansiGoalFinancialForecastEngine {
  const YansiGoalFinancialForecastEngine();

  Map<String, dynamic> forecast({
    required double goalAmount,
    required double currentProgress,
    required double observedMonthlySpend,
    required double observedMonthlyContribution,
  }) {
    final remaining = (goalAmount - currentProgress).clamp(0.0, double.infinity).toDouble();
    final months = observedMonthlyContribution > 0
        ? remaining / observedMonthlyContribution
        : null;

    return {
      'goalAmount': goalAmount,
      'currentProgress': currentProgress,
      'remaining': remaining,
      'observedMonthlySpend': observedMonthlySpend,
      'observedMonthlyContribution': observedMonthlyContribution,
      'estimatedMonthsAtObservedContribution': months,
      'confidence': observedMonthlyContribution > 0 ? 'planning_estimate' : 'insufficient_data',
    };
  }
}
