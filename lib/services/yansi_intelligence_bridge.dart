import 'yansi_proactive_suggestions.dart';

/// Small integration boundary between LifeOS context providers and Yansi's
/// proactive reasoning. Providers can feed live values without coupling the
/// UI to the suggestion engine.
class YansiIntelligenceBridge {
  final YansiProactiveSuggestions suggestions;

  const YansiIntelligenceBridge({
    this.suggestions = const YansiProactiveSuggestions(),
  });

  List<YansiProactiveSuggestion> evaluate({
    required double monthlySpend,
    required double monthlyBudget,
    required int upcomingBills,
    required int openTasks,
    required List<String> recurringHouseholdItems,
    required List<String> recentNotificationSignals,
    required bool userIsActive,
  }) {
    return suggestions.build(
      monthlySpend: monthlySpend,
      monthlyBudget: monthlyBudget,
      upcomingBills: upcomingBills,
      openTasks: openTasks,
      recurringHouseholdItems: recurringHouseholdItems,
      recentNotificationSignals: recentNotificationSignals,
      userIsActive: userIsActive,
    );
  }
}
