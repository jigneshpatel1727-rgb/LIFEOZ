import 'yansi_context_reasoner.dart';
import 'yansi_insight_presenter.dart';
import 'yansi_intelligence_bridge.dart';
import 'yansi_phase1_context.dart';

/// Runtime coordinator for the Phase 1 intelligence path.
/// Keeps data collection, reasoning and presentation separate.
class YansiPhase1Runtime {
  final YansiIntelligenceBridge bridge;
  final YansiContextReasoner reasoner;
  final YansiInsightPresenter presenter;

  const YansiPhase1Runtime({
    this.bridge = const YansiIntelligenceBridge(),
    this.reasoner = const YansiContextReasoner(),
    this.presenter = const YansiInsightPresenter(),
  });

  YansiInsightPresentation evaluate(
    YansiPhase1Context context, {
    required bool userIsActive,
    required bool voiceAllowed,
  }) {
    final suggestions = bridge.evaluate(
      monthlySpend: context.monthlySpend,
      monthlyBudget: context.monthlyBudget,
      upcomingBills: context.upcomingBills,
      openTasks: context.openTasks,
      recurringHouseholdItems: context.householdNeeds,
      recentNotificationSignals: context.permittedSignals,
      userIsActive: userIsActive,
    );

    final reasoned = reasoner.reason(context);
    final combined = reasoned.isNotEmpty ? reasoned : suggestions;

    return presenter.present(
      insights: combined,
      userIsActive: userIsActive,
      voiceAllowed: voiceAllowed,
    );
  }
}
