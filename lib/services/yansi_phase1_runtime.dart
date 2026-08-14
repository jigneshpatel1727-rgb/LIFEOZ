import 'yansi_context_reasoner.dart';
import 'yansi_insight_memory.dart';
import 'yansi_insight_memory_ranker.dart';
import 'yansi_insight_presenter.dart';
import 'yansi_intelligence_bridge.dart';
import 'yansi_phase1_context.dart';

/// Runtime coordinator for the Phase 1 intelligence path.
/// Keeps data collection, reasoning and presentation separate.
class YansiPhase1Runtime {
  final YansiIntelligenceBridge bridge;
  final YansiContextReasoner reasoner;
  final YansiInsightMemoryRanker memoryRanker;
  final YansiInsightPresenter presenter;

  const YansiPhase1Runtime({
    this.bridge = const YansiIntelligenceBridge(),
    this.reasoner = const YansiContextReasoner(),
    this.memoryRanker = const YansiInsightMemoryRanker(),
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

  Future<YansiInsightPresentation> evaluateWithMemory(
    YansiPhase1Context context,
    YansiInsightMemory memory, {
    required bool userIsActive,
    required bool voiceAllowed,
  }) async {
    final base = evaluate(
      context,
      userIsActive: userIsActive,
      voiceAllowed: voiceAllowed,
    );
    if (base.insight == null) return base;

    final ranked = memoryRanker.rank(
      current: [base.insight!],
      memories: memory.load(),
    );

    return presenter.present(
      insights: ranked,
      userIsActive: userIsActive,
      voiceAllowed: voiceAllowed,
    );
  }
}
