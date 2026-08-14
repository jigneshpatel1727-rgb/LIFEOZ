import 'yansi_context_fusion.dart';
import 'yansi_proactive_suggestions.dart';

/// Phase-1 bridge between real LifeOS context and Yansi's suggestion engine.
/// The bridge only reads existing context and produces suggestions; it does
/// not mutate user records or execute external actions.
class YansiPhase1Intelligence {
  final YansiContextFusion contextFusion;
  final YansiProactiveSuggestions suggestions;

  const YansiPhase1Intelligence({
    required this.contextFusion,
    this.suggestions = const YansiProactiveSuggestions(),
  });

  Future<List<YansiProactiveSuggestion>> refresh({
    bool userIsActive = true,
  }) async {
    final context = await contextFusion.build();

    return suggestions.build(
      monthlySpend: context.recentSpend,
      upcomingBills: context.upcomingReminders,
      openTasks: context.openTasks,
      recentNotificationSignals: const [],
      userIsActive: userIsActive,
    );
  }
}
