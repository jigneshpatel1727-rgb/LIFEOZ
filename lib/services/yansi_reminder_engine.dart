import 'lifeos_data_store.dart';

class YansiReminder {
  final String id;
  final String title;
  final String category;
  final DateTime dueAt;
  final Duration remaining;

  const YansiReminder({
    required this.id,
    required this.title,
    required this.category,
    required this.dueAt,
    required this.remaining,
  });

  bool get isOverdue => remaining.isNegative;
}

/// Read-only reminder discovery for bills, renewals, birthdays, services,
/// checkups and other LifeOS calendar records.
class YansiReminderEngine {
  final LifeOSDataStore store;
  const YansiReminderEngine(this.store);

  List<YansiReminder> upcoming({DateTime? now, Duration horizon = const Duration(days: 30)}) {
    final current = now ?? DateTime.now();
    final limit = current.add(horizon);
    final reminders = <YansiReminder>[];

    for (final row in store.read('calendar')) {
      final raw = row['dueDate']?.toString() ?? row['timestamp']?.toString();
      final dueAt = raw == null ? null : DateTime.tryParse(raw)?.toLocal();
      if (dueAt == null || dueAt.isAfter(limit)) continue;
      reminders.add(YansiReminder(
        id: row['id']?.toString() ?? '',
        title: row['title']?.toString() ?? 'LifeOS reminder',
        category: row['category']?.toString() ?? 'general',
        dueAt: dueAt,
        remaining: dueAt.difference(current),
      ));
    }

    reminders.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return reminders;
  }
}
