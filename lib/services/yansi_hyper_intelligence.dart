import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// High-level intelligence layer for Yansi.
///
/// This layer does not mutate LifeOS records. It fuses permitted signals,
/// detects reinforcing patterns, produces explainable priorities, and exposes
/// a safe action proposal for the UI. Actual execution remains behind the
/// existing YansiBrain/permission boundaries.
class YansiHyperIntelligence {
  final SharedPreferences prefs;

  YansiHyperIntelligence({required this.prefs});

  static const _expenseKey = 'yansi_expenses';
  static const _incomeKey = 'yansi_income';
  static const _taskKey = 'yansi_tasks';
  static const _reminderKey = 'yansi_reminders';
  static const _householdKey = 'yansi_household';
  static const _goalKey = 'yansi_goals';
  static const _diaryKey = 'yansi_diary';

  /// Produces one explainable life-state snapshot from all permitted cores.
  Future<YansiLifeState> analyze() async {
    final expenses = _records(_expenseKey);
    final income = _records(_incomeKey);
    final tasks = _records(_taskKey);
    final reminders = _records(_reminderKey);
    final household = _records(_householdKey);
    final goals = _records(_goalKey);
    final diary = _records(_diaryKey);

    final openTasks = tasks.where((r) => r['completed'] != true).length;
    final moneySpent = expenses.fold<double>(0, (sum, r) => sum + _number(r['amount']));
    final moneyIn = income.fold<double>(0, (sum, r) => sum + _number(r['amount']));

    final signals = <YansiSignal>[];

    if (openTasks >= 5) {
      signals.add(YansiSignal(
        core: 'productivity',
        score: 82,
        title: 'Workload pressure',
        explanation: '$openTasks open tasks are competing for attention.',
      ));
    }

    if (reminders.isNotEmpty && openTasks > 0) {
      signals.add(YansiSignal(
        core: 'time',
        score: 76,
        title: 'Time collision risk',
        explanation: 'Open work and scheduled commitments may need sequencing.',
      ));
    }

    if (moneyIn > 0 && moneySpent > moneyIn * .8) {
      signals.add(YansiSignal(
        core: 'money',
        score: 91,
        title: 'Cash-flow pressure',
        explanation: 'Recorded spending has reached ${(moneySpent / moneyIn * 100).round()}% of recorded income.',
      ));
    }

    if (household.length >= 3) {
      signals.add(YansiSignal(
        core: 'household',
        score: 63,
        title: 'Recurring household pattern',
        explanation: 'Repeated household entries can be turned into a predictive list.',
      ));
    }

    if (goals.isNotEmpty && openTasks > 0) {
      signals.add(YansiSignal(
        core: 'goals',
        score: 79,
        title: 'Goal execution gap',
        explanation: 'Goals exist while unfinished actions are accumulating.',
      ));
    }

    if (diary.isNotEmpty) {
      signals.add(YansiSignal(
        core: 'mind',
        score: 58,
        title: 'Context available',
        explanation: 'Personal reflections can improve future recommendations when permission remains enabled.',
      ));
    }

    signals.sort((a, b) => b.score.compareTo(a.score));
    final top = signals.isEmpty ? null : signals.first;

    return YansiLifeState(
      moneySpent: moneySpent,
      moneyIn: moneyIn,
      openTasks: openTasks,
      reminderCount: reminders.length,
      householdCount: household.length,
      goalCount: goals.length,
      diaryCount: diary.length,
      signals: signals,
      headline: top?.title ?? 'LifeOS is quiet',
      advice: top == null
          ? 'Yansi is observing quietly. More context will make the intelligence more useful.'
          : '${top.title}: ${top.explanation}',
    );
  }

  /// Converts the current state into a safe, human-readable proposal.
  /// Nothing is executed here.
  Future<YansiActionProposal?> proposeNextAction() async {
    final state = await analyze();
    final top = state.signals.isEmpty ? null : state.signals.first;
    if (top == null) return null;

    switch (top.core) {
      case 'money':
        return const YansiActionProposal(
          type: 'show_money_analysis',
          reason: 'Money signals reinforce a cash-flow concern.',
          requiresConfirmation: false,
        );
      case 'productivity':
        return const YansiActionProposal(
          type: 'show_priority_sequence',
          reason: 'Several unfinished tasks compete for attention.',
          requiresConfirmation: false,
        );
      case 'time':
        return const YansiActionProposal(
          type: 'show_schedule_conflict',
          reason: 'Tasks and commitments should be sequenced.',
          requiresConfirmation: false,
        );
      case 'household':
        return const YansiActionProposal(
          type: 'show_predicted_household_list',
          reason: 'Repeated household records support a prediction.',
          requiresConfirmation: false,
        );
      case 'goals':
        return const YansiActionProposal(
          type: 'show_goal_path',
          reason: 'Goals and unfinished actions are connected.',
          requiresConfirmation: false,
        );
      default:
        return const YansiActionProposal(
          type: 'show_context',
          reason: 'Relevant LifeOS context is available.',
          requiresConfirmation: false,
        );
    }
  }

  List<Map<String, dynamic>> _records(String key) {
    final raw = prefs.getStringList(key) ?? const <String>[];
    return raw.map((value) {
      try {
        return Map<String, dynamic>.from(jsonDecode(value) as Map);
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((value) => value.isNotEmpty).toList();
  }

  double _number(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
}

class YansiLifeState {
  final double moneySpent;
  final double moneyIn;
  final int openTasks;
  final int reminderCount;
  final int householdCount;
  final int goalCount;
  final int diaryCount;
  final List<YansiSignal> signals;
  final String headline;
  final String advice;

  const YansiLifeState({
    required this.moneySpent,
    required this.moneyIn,
    required this.openTasks,
    required this.reminderCount,
    required this.householdCount,
    required this.goalCount,
    required this.diaryCount,
    required this.signals,
    required this.headline,
    required this.advice,
  });
}

class YansiSignal {
  final String core;
  final int score;
  final String title;
  final String explanation;

  const YansiSignal({
    required this.core,
    required this.score,
    required this.title,
    required this.explanation,
  });
}

class YansiActionProposal {
  final String type;
  final String reason;
  final bool requiresConfirmation;

  const YansiActionProposal({
    required this.type,
    required this.reason,
    required this.requiresConfirmation,
  });
}
