import 'lifeos_intelligence_bus.dart';
import 'lifeos_intelligence_coordinator.dart';
import 'lifeos_signal_store.dart';
import 'yansi_brain.dart';

/// Bridges natural Yansi conversations into the shared LifeOS intelligence
/// stream. YansiBrain remains responsible for understanding and persistence;
/// this layer makes the resulting intelligence visible to the whole system.
class YansiAmbientCommandService {
  final YansiBrain brain;
  final LifeOSSignalStore signals;
  final LifeOSIntelligenceCoordinator coordinator;

  YansiAmbientCommandService({
    required this.brain,
    required this.signals,
    required this.coordinator,
  });

  Future<YansiResult> process(String utterance) async {
    final result = await brain.process(utterance);
    signals.record(
      _signalType(result.intent),
      result.originalText,
      data: {
        'intent': result.intent.name,
        'category': result.category,
        'amount': result.amount,
        'item': result.item,
        'yansiResponse': result.response,
        ...result.data,
      },
    );
    // Evaluate immediately so proactive context is refreshed after every
    // meaningful utterance rather than waiting for a screen rebuild.
    coordinator.evaluate();
    return result;
  }

  LifeOSSignalType _signalType(YansiIntent intent) {
    switch (intent) {
      case YansiIntent.expense:
        return LifeOSSignalType.expense;
      case YansiIntent.task:
        return LifeOSSignalType.task;
      case YansiIntent.reminder:
        return LifeOSSignalType.calendar;
      case YansiIntent.household:
        return LifeOSSignalType.household;
      case YansiIntent.goal:
        return LifeOSSignalType.goal;
      case YansiIntent.diary:
        return LifeOSSignalType.diary;
      case YansiIntent.income:
        return LifeOSSignalType.investment;
      case YansiIntent.question:
      case YansiIntent.unknown:
        return LifeOSSignalType.voice;
    }
  }
}
