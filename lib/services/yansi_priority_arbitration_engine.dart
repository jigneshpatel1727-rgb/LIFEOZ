/// Chooses the most important unified Yansi signal for the current moment.
class YansiPriorityArbitrationEngine {
  const YansiPriorityArbitrationEngine();

  Map<String, dynamic> select({
    required List<Map<String, dynamic>> signals,
    required bool quietHours,
  }) {
    if (signals.isEmpty) {
      return {'decision': 'silent', 'reason': 'no_signal'};
    }

    final ranked = signals.map((signal) {
      final domain = (signal['domain'] ?? '').toString();
      final observations = (signal['observations'] as num?)?.toDouble() ?? 0;
      var score = observations;
      if (domain == 'prediction') score += 3;
      if (domain == 'memory') score += 2;
      if (domain == 'health') score += 1;
      if (domain == 'web') score += 1;
      return {'signal': signal, 'score': score};
    }).toList();

    ranked.sort((a, b) =>
        (b['score'] as double).compareTo(a['score'] as double));

    final winner = ranked.first['signal'] as Map<String, dynamic>;
    return {
      'decision': quietHours ? 'defer' : 'surface',
      'selectedSignal': Map<String, dynamic>.from(winner),
      'score': ranked.first['score'],
      'reason': quietHours ? 'quiet_hours' : 'highest_priority_signal',
    };
  }
}
