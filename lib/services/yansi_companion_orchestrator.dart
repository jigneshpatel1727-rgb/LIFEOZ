import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_context_fusion.dart';
import 'yansi_pattern_advice.dart';
import 'yansi_proactive_planner.dart';

/// Integrated intelligence coordinator for Yansi.
///
/// This is the companion layer: it combines LifeOS context, proactive planning,
/// approved learning and conversation memory into one explainable snapshot.
/// It does not grant permissions, perform sensitive actions, or rewrite code.
class YansiCompanionSnapshot {
  final DateTime createdAt;
  final String headline;
  final String advice;
  final String reason;
  final double confidence;
  final Map<String, dynamic> context;
  final List<Map<String, dynamic>> priorities;

  const YansiCompanionSnapshot({
    required this.createdAt,
    required this.headline,
    required this.advice,
    required this.reason,
    required this.confidence,
    required this.context,
    required this.priorities,
  });

  Map<String, dynamic> toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'headline': headline,
        'advice': advice,
        'reason': reason,
        'confidence': confidence,
        'context': context,
        'priorities': priorities,
      };
}

class YansiCompanionOrchestrator {
  static const snapshotKey = 'yansi_companion_snapshot';
  static const lastInteractionKey = 'yansi_last_companion_update';

  final SharedPreferences prefs;
  const YansiCompanionOrchestrator({required this.prefs});

  bool get learningEnabled => prefs.getBool('permission_personal_learning') == true;
  bool get webEnabled => prefs.getBool('permission_web_knowledge') == true;
  bool get backgroundEnabled => prefs.getBool('permission_background_ai') == true;

  Future<YansiCompanionSnapshot> refresh({bool userIsActive = true}) async {
    final context = await YansiContextFusion(prefs: prefs).build();
    final plan = await YansiProactivePlanner(prefs: prefs).build();
    final pattern = learningEnabled
        ? await YansiPatternAdviceService(prefs: prefs).build()
        : null;

    String advice = plan.headline;
    String reason = 'Based on your current LifeOS context.';
    double confidence = 0.65;

    if (pattern != null) {
      advice = pattern.suggestion;
      reason = pattern.reason;
      confidence = pattern.confidence;
    } else if (plan.items.isNotEmpty) {
      advice = plan.items.first.title;
      reason = plan.items.first.reason;
      confidence = 0.72;
    }

    final priorities = plan.items
        .map((e) => e.toJson())
        .toList(growable: false);

    final snapshot = YansiCompanionSnapshot(
      createdAt: DateTime.now(),
      headline: plan.headline,
      advice: advice,
      reason: reason,
      confidence: confidence,
      context: {
        'openTasks': context.openTasks,
        'upcomingReminders': context.upcomingReminders,
        'recentSpend': context.recentSpend,
        'goals': context.goals,
        'householdRecords': context.householdRecords,
        'learningEnabled': learningEnabled,
        'webEnabled': webEnabled,
        'backgroundEnabled': backgroundEnabled,
        'userIsActive': userIsActive,
      },
      priorities: priorities,
    );

    await prefs.setString(snapshotKey, jsonEncode(snapshot.toJson()));
    await prefs.setString(lastInteractionKey, DateTime.now().toIso8601String());
    return snapshot;
  }

  YansiCompanionSnapshot? read() {
    final raw = prefs.getString(snapshotKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      return YansiCompanionSnapshot(
        createdAt: DateTime.tryParse('${map['createdAt']}') ?? DateTime.now(),
        headline: '${map['headline'] ?? ''}',
        advice: '${map['advice'] ?? ''}',
        reason: '${map['reason'] ?? ''}',
        confidence: ((map['confidence'] as num?)?.toDouble() ?? 0.5).clamp(0, 1).toDouble(),
        context: Map<String, dynamic>.from((map['context'] as Map?) ?? const {}),
        priorities: ((map['priorities'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(growable: false),
      );
    } catch (_) {
      return null;
    }
  }
}
