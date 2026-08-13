/// Produces concise, explainable insight text from trusted LifeOS signals.
/// This layer is read-only and never executes actions.
class YansiContextualInsight {
  const YansiContextualInsight();

  Map<String, dynamic> build({
    required String? core,
    required int score,
    Map<String, dynamic> context = const {},
  }) {
    final safeScore = score.clamp(0, 100).toInt();
    if (core == null || core.isEmpty || safeScore < 60) {
      return const {
        'available': false,
        'text': null,
        'priority': 0,
      };
    }

    final text = switch (core) {
      'calendar' => 'You have a time-sensitive calendar signal to review.',
      'tasks' => 'Your task activity suggests something may need attention.',
      'expense' => 'Your recent expense activity may be worth reviewing.',
      'goals' => 'A goal-related signal may benefit from your attention.',
      'household' => 'A household signal may need attention.',
      _ => 'I found something relevant in your LifeOS activity.',
    };

    return {
      'available': true,
      'text': text,
      'priority': safeScore,
      'core': core,
      'contextAvailable': context.isNotEmpty,
    };
  }
}
