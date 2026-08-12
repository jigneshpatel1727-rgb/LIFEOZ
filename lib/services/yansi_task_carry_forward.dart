import 'lifeos_data_store.dart';

/// Moves unfinished tasks into the next day without duplicating records.
class YansiTaskCarryForward {
  final LifeOSDataStore store;
  const YansiTaskCarryForward(this.store);

  Future<int> carryForward({DateTime? now}) async {
    final current = now ?? DateTime.now();
    final start = DateTime(current.year, current.month, current.day);
    final end = start.add(const Duration(days: 1));
    final nextDay = end;
    final rows = store.read('tasks');
    var added = 0;

    for (final task in rows) {
      if (task['completed'] == true || task['carriedForward'] == true) continue;
      final raw = task['dueDate']?.toString() ?? task['timestamp']?.toString();
      final date = raw == null ? null : DateTime.tryParse(raw);
      if (date == null || date.isBefore(start) || !date.isBefore(end)) continue;

      final copy = Map<String, dynamic>.from(task);
      copy['id'] = '${task['id']}_next_${nextDay.toIso8601String()}';
      copy['dueDate'] = nextDay.toIso8601String();
      copy['carriedForward'] = true;
      copy['carriedFrom'] = raw;
      copy['completed'] = false;
      await store.append('tasks', copy);
      added++;
    }
    return added;
  }
}
