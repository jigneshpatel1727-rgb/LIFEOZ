/// Scores fused LifeOS signals for Yansi's next-best ambient insight.
///
/// Read-only:
/// - never changes LifeOS data
/// - never executes actions
/// - only ranks trusted intelligence signals
class YansiCrossCorePriority {
  const YansiCrossCorePriority();

  Map<String, dynamic> rank(Map<String, dynamic> fused) {
    final signals = fused['signals'];

    if (signals is! Map) {
      return const {'core': null, 'score': 0, 'confidence': 0, 'reason': null};
    }

    String? best;
    var score = 0;
    var confidence = 0;
    final trustedCores = <String>[];
    final themes = <String, Set<String>>{};

    for (final entry in signals.entries) {
      if (entry.value is! Map || (entry.value as Map).isEmpty) continue;
      final value = entry.value as Map;
      if (value['readOnly'] == false) continue;

      final core = entry.key.toString();
      final candidate = _score(core, value);
      final candidateConfidence = _confidence(value);
      trustedCores.add(core.toLowerCase());
      for (final theme in _themes(core, value)) {
        themes.putIfAbsent(theme, () => <String>{}).add(core.toLowerCase());
      }

      if (candidate > score || (candidate == score && candidateConfidence > confidence)) {
        score = candidate;
        confidence = candidateConfidence;
        best = core;
      }
    }

    final uniqueCores = trustedCores.toSet();
    final reinforcedThemes = themes.entries
        .where((entry) => entry.value.length >= 2)
        .toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    final reinforcement = best == null
        ? 0
        : reinforcedThemes.fold<int>(0, (sum, entry) {
            final supportsBest = entry.value.contains(best!.toLowerCase());
            return supportsBest ? sum + (entry.value.length >= 3 ? 10 : 6) : sum;
          });

    final multiCore = uniqueCores.length >= 2;
    if (multiCore && best != null) {
      score = (score + 8 + reinforcement).clamp(0, 100);
      confidence = (confidence + 5 + (reinforcement > 0 ? 4 : 0)).clamp(0, 100);
    }

    final supporting = <String>{...uniqueCores};
    final reason = best == null
        ? null
        : reinforcement > 0
            ? 'Multiple independent LifeOS signals point to the same situation'
            : multiCore
                ? 'Multiple trusted LifeOS signals reinforce this insight'
                : 'Highest-value trusted LifeOS signal';

    return {
      'core': best,
      'score': score,
      'confidence': confidence,
      'multiCore': multiCore,
      'supportingCores': supporting.toList(),
      'reinforcedThemes': reinforcedThemes.map((e) => e.key).toList(),
      'reason': reason,
    };
  }

  Set<String> _themes(String core, Map value) {
    final themes = <String>{};
    final raw = <String>[
      core,
      '${value['title'] ?? ''}',
      '${value['reason'] ?? ''}',
      '${value['category'] ?? ''}',
      if (value['themes'] is Iterable) ...value['themes'].map((e) => '$e'),
    ].join(' ').toLowerCase();

    const groups = <String, List<String>>{
      'deadline': ['deadline', 'due', 'renewal', 'urgent', 'tomorrow', 'overdue'],
      'workload': ['task', 'todo', 'productivity', 'workload', 'pending'],
      'money': ['expense', 'spend', 'money', 'budget', 'payment', 'bill'],
      'goal': ['goal', 'target', 'milestone'],
      'household': ['household', 'grocery', 'shopping', 'kitchen', 'home'],
      'health': ['health', 'medical', 'checkup', 'fitness'],
      'personal': ['diary', 'journal', 'memory', 'personal'],
    };

    for (final entry in groups.entries) {
      if (entry.value.any(raw.contains)) themes.add(entry.key);
    }
    return themes;
  }

  int _score(String core, Map value) {
    final explicit = value['priority'];
    if (explicit is num) return explicit.clamp(0, 100).toInt();
    return switch (core.toLowerCase()) {
      'calendar' => 80,
      'tasks' => 75,
      'expense' => 70,
      'goals' => 65,
      'household' => 60,
      _ => 50,
    };
  }

  int _confidence(Map value) {
    final explicit = value['confidence'];
    if (explicit is num) return explicit.clamp(0, 100).toInt();
    return 60;
  }
}
