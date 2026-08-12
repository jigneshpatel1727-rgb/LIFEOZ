import 'lifeos_data_store.dart';
import 'yansi_core_context.dart';
import 'yansi_predictive_intelligence.dart';

/// Combines bounded five-core context with memory-derived observations and
/// predictions. It produces structured intelligence; it does not execute
/// external or sensitive actions.
class YansiPersonalIntelligenceLoop {
  final LifeOSDataStore store;
  final YansiCoreContextBuilder contextBuilder;
  final YansiPredictiveIntelligence predictions;

  YansiPersonalIntelligenceLoop(this.store)
      : contextBuilder = YansiCoreContextBuilder(store),
        predictions = YansiPredictiveIntelligence(store);

  Map<String, dynamic> snapshot() {
    return {
      'cores': contextBuilder.build(),
      'budget': predictions.monthlyBudget(),
      'household_predictions': predictions.predictedHouseholdList(),
      'behaviour': predictions.behaviour(),
      'generated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  List<String> suggestions() {
    final result = <String>[];
    final behaviour = predictions.behaviour();
    final completion = (behaviour['taskCompletionRate'] as num?)?.toDouble() ?? 0;
    final budget = predictions.monthlyBudget();
    final balance = (budget['projectedBalance'] as num?)?.toDouble() ?? 0;

    if (completion < .5) {
      result.add('Consider focusing on the most important tasks first.');
    }
    if (balance < 0) {
      result.add('Your recorded spending pattern may exceed the current income basis.');
    }
    if (predictions.predictedHouseholdList().isNotEmpty) {
      result.add('Some household items appear regularly in your records.');
    }
    if (result.isEmpty) {
      result.add('Your current LifeOS pattern has no high-priority suggestion.');
    }
    return result;
  }
}
