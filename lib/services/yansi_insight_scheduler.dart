import 'yansi_intelligence_bridge.dart';
import 'yansi_speech_decision.dart';

/// Runtime policy that decides which useful insight should be surfaced next.
/// It deliberately separates intelligence from presentation and side effects.
class YansiInsightScheduler {
  final YansiIntelligenceBridge bridge;
  final YansiSpeechDecision speechDecision;

  const YansiInsightScheduler({
    this.bridge = const YansiIntelligenceBridge(),
    this.speechDecision = const YansiSpeechDecision(),
  });

  YansiScheduledInsight? next({
    required double monthlySpend,
    required double monthlyBudget,
    required int upcomingBills,
    required int openTasks,
    required List<String> recurringHouseholdItems,
    required List<String> recentNotificationSignals,
    required bool userIsActive,
    required bool quietMode,
    required bool voiceAllowed,
  }) {
    final insights = bridge.evaluate(
      monthlySpend: monthlySpend,
      monthlyBudget: monthlyBudget,
      upcomingBills: upcomingBills,
      openTasks: openTasks,
      recurringHouseholdItems: recurringHouseholdItems,
      recentNotificationSignals: recentNotificationSignals,
      userIsActive: userIsActive,
    );
    if (insights.isEmpty) return null;

    final insight = insights.first;
    final speak = speechDecision.shouldSpeak(
      priority: insight.priority,
      userIsActive: userIsActive,
      quietMode: quietMode,
      voiceAllowed: voiceAllowed,
      urgent: insight.priority >= 90,
    );

    return YansiScheduledInsight(
      suggestion: insight,
      shouldSpeak: speak,
    );
  }
}

class YansiScheduledInsight {
  final YansiProactiveSuggestion suggestion;
  final bool shouldSpeak;

  const YansiScheduledInsight({
    required this.suggestion,
    required this.shouldSpeak,
  });
}
