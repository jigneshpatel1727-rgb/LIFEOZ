import 'lifeos_data_store.dart';

/// Normalizes calendar and goal records before they are written by Yansi.
/// This keeps the five-core action layer deterministic and makes these records
/// ready for future cloud synchronization.
class YansiCalendarGoalService {
  final LifeOSDataStore store;

  const YansiCalendarGoalService(this.store);

  Future<void> addCalendarEvent({
    required String title,
    required DateTime dueAt,
    String category = 'general',
    bool recurring = false,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final id = '${dueAt.microsecondsSinceEpoch}_calendar';
    await store.append('calendar', {
      'id': id,
      'type': 'calendar_event',
      'title': title.trim(),
      'category': category,
      'dueAt': dueAt.toUtc().toIso8601String(),
      'recurring': recurring,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<void> addGoal({
    required String title,
    DateTime? targetDate,
    double targetValue = 0,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final id = '${DateTime.now().microsecondsSinceEpoch}_goal';
    await store.append('goals', {
      'id': id,
      'type': 'goal',
      'title': title.trim(),
      'targetDate': targetDate?.toUtc().toIso8601String(),
      'targetValue': targetValue,
      'progress': 0.0,
      'completed': false,
      'createdAt': now,
      'updatedAt': now,
    });
  }
}
