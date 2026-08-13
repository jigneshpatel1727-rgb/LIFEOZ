import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// User-approved learning engine for Yansi.
///
/// It learns only from LifeOS data and conversation history already stored by
/// the app. It records explainable observations rather than attempting a
/// medical or psychological diagnosis.
class YansiLearningEngine {
  static const patternsKey = 'yansi_learned_patterns';
  static const profileKey = 'yansi_learning_profile';

  final SharedPreferences prefs;
  const YansiLearningEngine({required this.prefs});

  bool get enabled => prefs.getBool('permission_personal_learning') == true;

  Future<void> learn() async {
    if (!enabled) return;

    final history = _readList('yansi_conversation_history');
    final expenses = _readList('yansi_expenses');
    final tasks = _readList('yansi_tasks');
    final reminders = _readList('yansi_reminders');
    final household = _readList('yansi_household');
    final goals = _readList('yansi_goals');

    final observations = <Map<String, dynamic>>[];

    if (expenses.length >= 3) {
      final categoryTotals = <String, double>{};
      for (final r in expenses) {
        final category = '${r['category'] ?? 'Other'}';
        categoryTotals[category] = (categoryTotals[category] ?? 0) +
            ((r['amount'] as num?)?.toDouble() ?? 0);
      }
      final ranked = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (ranked.isNotEmpty) {
        final top = ranked.first;
        observations.add(_pattern(
          topic: 'spending: ${top.key}',
          observation: '${top.key} is currently your largest recorded spending area.',
          confidence: _confidence(expenses.length, 0.65),
          source: 'expense_history',
        ));
      }
    }

    final openTasks = tasks.where((r) => r['completed'] != true).length;
    if (openTasks >= 3) {
      observations.add(_pattern(
        topic: 'task load',
        observation: 'There are currently $openTasks open tasks; prioritising the most important ones may reduce overload.',
        confidence: _confidence(tasks.length, 0.70),
        source: 'task_history',
      ));
    }

    if (reminders.isNotEmpty) {
      observations.add(_pattern(
        topic: 'upcoming commitments',
        observation: 'You are using reminders to manage commitments; Yansi can connect them with daily priorities.',
        confidence: _confidence(reminders.length, 0.58),
        source: 'reminder_history',
      ));
    }

    if (household.length >= 3) {
      final counts = <String, int>{};
      for (final r in household) {
        final item = '${r['item'] ?? ''}'.trim().toLowerCase();
        if (item.isNotEmpty) counts[item] = (counts[item] ?? 0) + 1;
      }
      final repeated = counts.entries.where((e) => e.value >= 2).toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (repeated.isNotEmpty) {
        final item = repeated.first;
        observations.add(_pattern(
          topic: 'recurring household item: ${item.key}',
          observation: '${item.key} appears repeatedly in your household history.',
          confidence: _confidence(household.length, 0.74),
          source: 'household_history',
        ));
      }
    }

    if (goals.isNotEmpty) {
      observations.add(_pattern(
        topic: 'goal focus',
        observation: 'You have ${goals.length} recorded goal${goals.length == 1 ? '' : 's'}; Yansi can relate daily actions to them.',
        confidence: _confidence(goals.length, 0.60),
        source: 'goal_history',
      ));
    }

    if (history.length >= 5) {
      final recentUserMessages = history
          .where((r) => '${r['role']}' == 'user')
          .map((r) => '${r['text'] ?? ''}'.trim())
          .where((v) => v.isNotEmpty)
          .toList();
      if (recentUserMessages.length >= 5) {
        observations.add(_pattern(
          topic: 'conversation continuity',
          observation: 'You regularly use Yansi conversationally; maintaining context can make future answers more useful.',
          confidence: _confidence(recentUserMessages.length, 0.62),
          source: 'conversation_history',
        ));
      }
    }

    observations.sort((a, b) =>
        ((b['confidence'] as num?)?.toDouble() ?? 0)
            .compareTo((a['confidence'] as num?)?.toDouble() ?? 0));

    final limited = observations.take(20).map(jsonEncode).toList();
    await prefs.setStringList(patternsKey, limited);
    await prefs.setString(profileKey, jsonEncode({
      'updatedAt': DateTime.now().toIso8601String(),
      'historyCount': history.length,
      'expenseCount': expenses.length,
      'taskCount': tasks.length,
      'reminderCount': reminders.length,
      'householdCount': household.length,
      'goalCount': goals.length,
      'observationCount': observations.length,
    }));
  }

  Map<String, dynamic> _pattern({
    required String topic,
    required String observation,
    required double confidence,
    required String source,
  }) => {
        'topic': topic,
        'observation': observation,
        'confidence': confidence,
        'source': source,
        'updatedAt': DateTime.now().toIso8601String(),
      };

  double _confidence(int sample, double base) {
    final boost = (sample / 20).clamp(0.0, 0.20);
    return (base + boost).clamp(0.0, 0.95).toDouble();
  }

  List<Map<String, dynamic>> _readList(String key) {
    final raw = prefs.getStringList(key) ?? const <String>[];
    return raw.map((value) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
      return <String, dynamic>{};
    }).where((e) => e.isNotEmpty).toList();
  }
}
