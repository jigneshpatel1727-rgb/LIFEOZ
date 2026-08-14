import 'yansi_budget_household_insights.dart';
import 'yansi_phase1_context.dart';
import 'yansi_phase1_planning_signals.dart';
import 'yansi_proactive_suggestions.dart';

/// Merges budget and household planning signals into the Phase 1 suggestion
/// stream without coupling the planning service to the UI.
class YansiPhase1PlanningBridge {
  final YansiBudgetHouseholdInsights planner;

  const YansiPhase1PlanningBridge({
    this.planner = const YansiBudgetHouseholdInsights(),
  });

  List<YansiProactiveSuggestion> evaluate(
    YansiPhase1Context context, {
    YansiPhase1PlanningSignals signals = const YansiPhase1PlanningSignals(),
  }) {
    return planner.evaluate(
      monthlySpend: context.monthlySpend,
      monthlyBudget: context.monthlyBudget,
      householdNeeds: context.householdNeeds,
      projectedMonthlySpend: signals.projectedMonthlySpend,
      lowStockItems: signals.lowStockItems,
    );
  }
}
