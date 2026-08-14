/// Cross-core suggestion engine for Phase 1.
///
/// It reasons over supplied LifeOS signals and returns useful suggestions;
/// it never performs an external action by itself.
class YansiProactiveSuggestion {
  final String title;
  final String message;
  final String core;
  final int priority;
  final bool speakable;

  const YansiProactiveSuggestion({
    required this.title,
    required this.message,
    required this.core,
    required this.priority,
    this.speakable = true,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'message': message,
        'core': core,
        'priority': priority,
        'speakable': speakable,
      };
}

class YansiProactiveSuggestions {
  const YansiProactiveSuggestions();

  List<YansiProactiveSuggestion> build({
    double monthlySpend = 0,
    double monthlyBudget = 0,
    int upcomingBills = 0,
    int openTasks = 0,
    List<String> recurringHouseholdItems = const [],
    List<String> recentNotificationSignals = const [],
    bool userIsActive = false,
  }) {
    final suggestions = <YansiProactiveSuggestion>[];

    if (monthlyBudget > 0 && monthlySpend > monthlyBudget * 0.85) {
      suggestions.add(YansiProactiveSuggestion(
        title: 'Budget attention',
        message: 'Your spending is approaching this month’s budget. I can help rebalance the remaining plan.',
        core: 'money',
        priority: 88,
      ));
    }

    if (upcomingBills > 0) {
      suggestions.add(YansiProactiveSuggestion(
        title: 'Upcoming commitment',
        message: 'You have $upcomingBills upcoming payment${upcomingBills == 1 ? '' : 's'}. I can help you prepare for them.',
        core: 'calendar',
        priority: 82,
      ));
    }

    if (openTasks >= 5) {
      suggestions.add(YansiProactiveSuggestion(
        title: 'Task load',
        message: 'You have $openTasks open tasks. I can help identify what matters most today.',
        core: 'productivity',
        priority: 76,
      ));
    }

    if (recurringHouseholdItems.isNotEmpty) {
      final preview = recurringHouseholdItems.take(4).join(', ');
      suggestions.add(YansiProactiveSuggestion(
        title: 'Household pattern',
        message: 'Your recurring household pattern suggests checking $preview soon.',
        core: 'household',
        priority: 72,
      ));
    }

    if (recentNotificationSignals.isNotEmpty) {
      suggestions.add(YansiProactiveSuggestion(
        title: 'New information',
        message: 'I found ${recentNotificationSignals.length} new permitted signal${recentNotificationSignals.length == 1 ? '' : 's'} that may be useful.',
        core: 'yansi',
        priority: 70,
      ));
    }

    suggestions.sort((a, b) => b.priority.compareTo(a.priority));
    if (userIsActive) return suggestions;
    return suggestions.where((s) => s.priority >= 75).toList();
  }
}
