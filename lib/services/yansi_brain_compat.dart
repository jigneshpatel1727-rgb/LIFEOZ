part of 'yansi_brain.dart';

/// Compatibility/report API used by the existing LifeOS report screen.
/// Kept separate so the conversational Yansi engine can evolve without
/// breaking established report screens.
extension YansiReportApi on YansiBrain {
  Future<List<Map<String, dynamic>>> getMemory() async {
    const keys = [
      YansiBrain._expenseKey,
      YansiBrain._incomeKey,
      YansiBrain._taskKey,
      YansiBrain._reminderKey,
      YansiBrain._householdKey,
      YansiBrain._goalKey,
      YansiBrain._diaryKey,
    ];

    final records = <Map<String, dynamic>>[];
    for (final key in keys) {
      records.addAll(_readRecords(key));
    }

    records.sort((a, b) {
      final ad = DateTime.tryParse((a['date'] ?? '').toString());
      final bd = DateTime.tryParse((b['date'] ?? '').toString());
      return (bd ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(ad ?? DateTime.fromMillisecondsSinceEpoch(0));
    });

    return records;
  }

  Future<Map<String, dynamic>> getSummary() async {
    final memory = await getMemory();
    double income = 0;
    double expenses = 0;

    for (final record in memory) {
      final amount = (record['amount'] as num?)?.toDouble() ?? 0;
      if (record['type'] == 'income') {
        income += amount;
      } else if (record['type'] == 'expense') {
        expenses += amount;
      }
    }

    return {
      'income': income,
      'expenses': expenses,
      'balance': income - expenses,
      'recordCount': memory.length,
    };
  }
}
