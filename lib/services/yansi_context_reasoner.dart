import 'yansi_phase1_context.dart';
import 'yansi_proactive_suggestions.dart';

/// Coordinates Phase 1 context into a single ranked Yansi response set.
/// This layer is deliberately read-only: it recommends, never executes.
class YansiContextReasoner {
  final YansiProactiveSuggestions _suggestions;

  const YansiContextReasoner({
    YansiProactiveSuggestions suggestions = const YansiProactiveSuggestions(),
  }) : _suggestions = suggestions;

  List<YansiProactiveSuggestion> reason(YansiPhase1Context context) {
    final results = _suggestions.build(
      monthlySpend: context.monthlySpend,
      monthlyBudget: context.monthlyBudget,
      upcomingBills: context.upcomingBills,
      openTasks: context.openTasks,
      recurringHouseholdItems: context.householdNeeds,
      recentNotificationSignals: context.permittedSignals,
      userIsActive: context.activeFocus != null,
    );

    if (context.activeFocus == null || results.isEmpty) return results;

    final focused = results
        .map((item) => item.core == context.activeFocus
            ? YansiProactiveSuggestion(
                title: item.title,
                message: item.message,
                core: item.core,
                priority: (item.priority + 8).clamp(0, 100).toInt(),
                speakable: item.speakable,
              )
            : item)
        .toList();

    focused.sort((a, b) => b.priority.compareTo(a.priority));
    return focused;
  }
}
