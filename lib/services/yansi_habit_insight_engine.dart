/// Identifies stable behavior patterns without automatically changing the user's routine.
class YansiHabitInsightEngine {
  const YansiHabitInsightEngine();

  List<Map<String, dynamic>> analyze(List<Map<String, dynamic>> routines) {
    return routines
        .where((routine) => (routine['observations'] as num?)?.toInt() != null)
        .where((routine) => ((routine['observations'] as num?)?.toInt() ?? 0) >= 3)
        .map((routine) => {
              'pattern': routine['pattern'],
              'observations': routine['observations'],
              'insight': 'This pattern appears repeatedly and may be useful for proactive assistance.',
              'requiresUserApprovalToAct': true,
            })
        .toList(growable: false);
  }
}
