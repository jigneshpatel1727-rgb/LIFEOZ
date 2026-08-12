import 'package:shared_preferences/shared_preferences.dart';

import '../models/life_memory.dart';

class YansiMemory {
  static const String _memoryKey = 'yansi_permanent_memory';

  final SharedPreferences prefs;

  YansiMemory(this.prefs);

  List<LifeMemory> getAll() {
    final stored =
        prefs.getStringList(_memoryKey) ?? [];

    return stored
        .map((item) {
          try {
            return LifeMemory.fromJson(item);
          } catch (_) {
            return null;
          }
        })
        .whereType<LifeMemory>()
        .toList();
  }

  Future<void> remember(
    LifeMemory memory,
  ) async {
    final existing = getAll();

    existing.add(memory);

    await prefs.setStringList(
      _memoryKey,
      existing
          .map((item) => item.toJson())
          .toList(),
    );
  }

  List<LifeMemory> forCore(
    MemoryCore core,
  ) {
    return getAll()
        .where((item) => item.core == core)
        .toList();
  }

  List<LifeMemory> search(
    String query,
  ) {
    final q = query.toLowerCase();

    return getAll().where((item) {
      return item.originalText
              .toLowerCase()
              .contains(q) ||
          item.transcript
              .toLowerCase()
              .contains(q) ||
          item.aiSummary
              .toLowerCase()
              .contains(q) ||
          item.category
              .toLowerCase()
              .contains(q) ||
          (item.entity ?? '')
              .toLowerCase()
              .contains(q);
    }).toList();
  }

  double totalForCore(
    MemoryCore core,
  ) {
    return forCore(core)
        .fold(
          0,
          (sum, item) =>
              sum + (item.amount ?? 0),
        );
  }

  int countForCore(
    MemoryCore core,
  ) {
    return forCore(core).length;
  }

  // IMPORTANT:
  // There is deliberately NO delete method.
  //
  // LifeOS keeps the user's history.
}
