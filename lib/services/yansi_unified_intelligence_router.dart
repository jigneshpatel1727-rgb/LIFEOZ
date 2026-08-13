import 'yansi_goal_prediction_engine.dart';
import 'yansi_routine_intelligence.dart';

/// Routes personal signals to the appropriate intelligence layer.
class YansiUnifiedIntelligenceRouter {
  final YansiGoalPredictionEngine goals;
  final YansiRoutineIntelligence routines;

  const YansiUnifiedIntelligenceRouter({
    this.goals = const YansiGoalPredictionEngine(),
    this.routines = const YansiRoutineIntelligence(),
  });

  Map<String, dynamic> analyze(List<Map<String, dynamic>> memories) {
    return {
      'goalSignals': goals.suggestNextSteps(memories),
      'routineSignals': routines.recurringSignals(memories),
      'memoryCount': memories.length,
    };
  }
}
