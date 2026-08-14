import 'yansi_phase1_context.dart';
import 'yansi_proactive_suggestions.dart';

/// Normalizes planning signals so future budget/household providers can plug
/// into Yansi without changing the runtime contract.
class YansiPhase1PlanningSignals {
  final double projectedMonthlySpend;
  final int lowStockItems;

  const YansiPhase1PlanningSignals({
    this.projectedMonthlySpend = 0,
    this.lowStockItems = 0,
  });

  List<YansiProactiveSuggestion> mergeInto(
    YansiPhase1Context context,
  ) {
    final result = <YansiProactiveSuggestion>[];
    final projected = projectedMonthlySpend > 0
        ? projectedMonthlySpend
        : context.monthlySpend;

    if (context.monthlyBudget > 0 && projected > context.monthlyBudget) {
      result.add(YansiProactiveSuggestion(
        title: 'Budget forecast',
        message: 'Your current pattern is projected to exceed the monthly budget.',
        core: 'money',
        priority: 90,
      ));
    }

    if (lowStockItems > 0) {
      result.add(YansiProactiveSuggestion(
        title: 'Household replenishment',
        message: 'Some household items may need attention soon.',
        core: 'household',
        priority: 80,
      ));
    }

    return result;
  }
}
