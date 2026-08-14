import 'yansi_context_reasoner.dart';
import 'yansi_insight_memory.dart';
import 'yansi_insight_memory_ranker.dart';
import 'yansi_insight_presenter.dart';
import 'yansi_intelligence_bridge.dart';
import 'yansi_phase1_context.dart';
import 'yansi_proactive_suggestions.dart';

/// Stable orchestration contract for Yansi intelligence.
///
/// Providers publish facts into a single snapshot and suggestions into a
/// common stream. The fabric then fuses them, reasons over them, applies
/// memory reinforcement, and produces an ambient presentation state.
///
/// Future capabilities should integrate here rather than creating another
/// independent decision pipeline.
class YansiIntelligenceFabric {
  final YansiIntelligenceBridge bridge;
  final YansiContextReasoner reasoner;
  final YansiInsightMemoryRanker memoryRanker;
  final YansiInsightPresenter presenter;

  const YansiIntelligenceFabric({
    this.bridge = const YansiIntelligenceBridge(),
    this.reasoner = const YansiContextReasoner(),
    this.memoryRanker = const YansiInsightMemoryRanker(),
    this.presenter = const YansiInsightPresenter(),
  });

  Future<YansiInsightPresentation> think(
    YansiPhase1Context context, {
    YansiInsightMemory? memory,
    List<YansiProactiveSuggestion> additionalSuggestions = const [],
    required bool userIsActive,
    required bool voiceAllowed,
  }) async {
    final baseSuggestions = bridge.evaluate(
      monthlySpend: context.monthlySpend,
      monthlyBudget: context.monthlyBudget,
      upcomingBills: context.upcomingBills,
      openTasks: context.openTasks,
      recurringHouseholdItems: context.householdNeeds,
      recentNotificationSignals: context.permittedSignals,
      userIsActive: userIsActive,
    );

    final reasoned = reasoner.reason(context);
    final merged = <YansiProactiveSuggestion>[...baseSuggestions, ...reasoned, ...additionalSuggestions];

    final unique = <String, YansiProactiveSuggestion>{};
    for (final item in merged) {
      final key = '${item.core}|${item.title}|${item.message}';
      final previous = unique[key];
      if (previous == null || item.priority > previous.priority) {
        unique[key] = item;
      }
    }

    var ranked = unique.values.toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    if (memory != null && ranked.isNotEmpty) {
      ranked = memoryRanker.rank(
        current: ranked,
        memories: memory.load(),
      );
    }

    return presenter.present(
      insights: ranked,
      userIsActive: userIsActive,
      voiceAllowed: voiceAllowed,
    );
  }
}
