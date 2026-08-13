/// Provides a small continuity hint for Yansi's proactive intelligence.
/// Advisory only: it never modifies LifeOS data or executes actions.
class YansiProactiveMemoryHint {
  const YansiProactiveMemoryHint();

  Map<String, dynamic> build({
    required String? core,
    required int priority,
    String? previousCore,
  }) {
    final score = priority.clamp(0, 100).toInt();
    if (core == null || core.isEmpty || score < 70) {
      return const {'available': false, 'hint': null, 'priority': 0};
    }

    final sameContext = previousCore == core;
    return {
      'available': true,
      'hint': sameContext
          ? 'This is related to your recent $core activity.'
          : 'This is a new signal from your $core activity.',
      'core': core,
      'priority': score,
      'continuity': sameContext,
    };
  }
}
