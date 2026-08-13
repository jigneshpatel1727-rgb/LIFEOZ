import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_briefing_history.dart';
import 'yansi_proactive_planner.dart';
import 'yansi_cross_core_priority.dart';
import 'yansi_proactive_pipeline.dart';

/// Runtime bridge for Yansi's ambient/proactive intelligence.
/// It prepares intelligence only; presentation is recorded separately.
class YansiProactiveRuntime {
  final SharedPreferences prefs;

  const YansiProactiveRuntime({required this.prefs});

  Future<YansiProactivePlan?> prepare({
    bool userIsActive = true,
    bool quietMode = false,
  }) async {
    if (quietMode) return null;

    final plan = await YansiProactivePlanner(prefs: prefs).build();
    if (plan.items.isEmpty) return null;

    final history = YansiBriefingHistory(prefs: prefs);
    if (!await history.shouldSurface(plan.headline)) return null;

    final signals = <Map<String, dynamic>>[
      for (final item in plan.items)
        {
          'core': item.core.toLowerCase(),
          'priority': _priorityForRank(item.rank),
          'confidence': 85,
          'readOnly': true,
        },
    ];

    final fused = <String, dynamic>{
      'signals': {
        for (final signal in signals) signal['core'].toString(): signal,
      },
    };

    final decision = const YansiProactivePipeline(
      priorityEngine: YansiCrossCorePriority(),
    ).evaluate(
      fusedSignals: fused,
      insight: plan.items.first.reason,
      repeated: false,
      quietHours: quietMode,
    );

    if (decision['surface'] != true) return null;

    // Cache the prepared decision for the ambient controller. Do not mark it
    // as surfaced here: preparing intelligence is not the same as showing it.
    await prefs.setBool('yansi_plan_ready', true);
    await prefs.setString('yansi_plan_headline', plan.headline);
    await prefs.setBool('yansi_decision_speak', decision['speak'] == true);
    await prefs.setInt('yansi_decision_priority', decision['priority'] as int? ?? 0);
    await prefs.setInt('yansi_decision_confidence', decision['confidence'] as int? ?? 0);

    return plan;
  }

  /// Call only after the ambient surface/voice has actually been presented.
  Future<void> markPresented() async {
    final headline = prefs.getString('yansi_plan_headline');
    if (headline == null || headline.trim().isEmpty) return;
    await YansiBriefingHistory(prefs: prefs).markSurfaced(headline);
  }

  int _priorityForRank(int rank) {
    switch (rank) {
      case 1: return 90;
      case 2: return 85;
      case 3: return 80;
      case 4: return 75;
      case 5: return 70;
      default: return 60;
    }
  }

  bool get isReady => prefs.getBool('yansi_plan_ready') == true;
  String? get headline => prefs.getString('yansi_plan_headline');
  bool get shouldSpeak => prefs.getBool('yansi_decision_speak') == true;
  int get priority => prefs.getInt('yansi_decision_priority') ?? 0;
  int get confidence => prefs.getInt('yansi_decision_confidence') ?? 0;

  Future<void> clearReady() async {
    await prefs.remove('yansi_plan_ready');
    await prefs.remove('yansi_plan_headline');
    await prefs.remove('yansi_decision_speak');
    await prefs.remove('yansi_decision_priority');
    await prefs.remove('yansi_decision_confidence');
  }
}
