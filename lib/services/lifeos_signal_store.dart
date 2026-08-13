import 'lifeos_intelligence_bus.dart';

/// Small persistence adapter for the intelligence stream.
/// Core services can use it without knowing how storage is implemented.
class LifeOSSignalStore {
  final LifeOSIntelligenceBus bus;
  const LifeOSSignalStore(this.bus);

  void record(LifeOSSignalType type, String text, {Map<String, dynamic> data = const {}}) {
    bus.publish(LifeOSSignal(type: type, text: text, timestamp: DateTime.now(), data: data));
  }

  void expense(double amount, String description, {String category = 'Other'}) => record(
        LifeOSSignalType.expense,
        description,
        data: {'amount': amount, 'category': category},
      );

  void task(String description, {bool completed = false}) => record(
        LifeOSSignalType.task,
        description,
        data: {'completed': completed},
      );

  void calendar(String description, {String? dueDate}) => record(
        LifeOSSignalType.calendar,
        description,
        data: {'dueDate': dueDate},
      );

  void household(String description) => record(LifeOSSignalType.household, description);

  void diary(String text) => record(LifeOSSignalType.diary, text);
}
