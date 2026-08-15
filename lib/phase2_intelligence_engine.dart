import 'dart:math' as math;

/// Phase 2: read-only intelligence layer for LIFEOZ.
/// It never mutates user data. It converts approved LifeOS signals into
/// explainable priorities that the UI/Yansi layer can present.
class LifeOZSignal {
  final String core;
  final String title;
  final String detail;
  final double urgency;
  final double confidence;
  final DateTime? dueAt;
  final List<String> evidence;

  const LifeOZSignal({
    required this.core,
    required this.title,
    required this.detail,
    required this.urgency,
    required this.confidence,
    this.dueAt,
    this.evidence = const <String>[],
  });
}

class LifeOZInsight {
  final String title;
  final String message;
  final String primaryCore;
  final double score;
  final List<String> supportingCores;
  final List<String> evidence;

  const LifeOZInsight({
    required this.title,
    required this.message,
    required this.primaryCore,
    required this.score,
    required this.supportingCores,
    required this.evidence,
  });
}

class Phase2IntelligenceEngine {
  const Phase2IntelligenceEngine();

  List<LifeOZInsight> rank(List<LifeOZSignal> signals, {String? activeFocus}) {
    final now = DateTime.now();
    final grouped = <String, List<LifeOZSignal>>{};
    for (final signal in signals) {
      grouped.putIfAbsent(_fingerprint(signal), () => <LifeOZSignal>[]).add(signal);
    }

    final insights = <LifeOZInsight>[];
    for (final entry in grouped.entries) {
      final items = entry.value;
      final primary = items.reduce((a, b) => _baseScore(a, now) >= _baseScore(b, now) ? a : b);
      final cores = items.map((e) => e.core).toSet().toList();
      final reinforcement = math.min(18.0, math.max(0, (cores.length - 1) * 7.0));
      final focusBoost = activeFocus != null && cores.contains(activeFocus) ? 8.0 : 0.0;
      final score = math.min(100.0, _baseScore(primary, now) + reinforcement + focusBoost);
      final evidence = <String>{};
      for (final item in items) {
        evidence.addAll(item.evidence);
      }
      insights.add(LifeOZInsight(
        title: primary.title,
        message: primary.detail,
        primaryCore: primary.core,
        score: score,
        supportingCores: cores,
        evidence: evidence.toList(),
      ));
    }

    insights.sort((a, b) => b.score.compareTo(a.score));
    return insights;
  }

  double _baseScore(LifeOZSignal signal, DateTime now) {
    var score = signal.urgency.clamp(0, 100) * .7 + signal.confidence.clamp(0, 100) * .3;
    if (signal.dueAt != null) {
      final hours = signal.dueAt!.difference(now).inHours;
      if (hours <= 0) {
        score += 18;
      } else if (hours <= 24) {
        score += 14;
      } else if (hours <= 72) {
        score += 8;
      }
    }
    return math.min(100, score);
  }

  String _fingerprint(LifeOZSignal signal) {
    return signal.title.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
  }
}
