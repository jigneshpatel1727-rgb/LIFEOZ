import 'package:shared_preferences/shared_preferences.dart';

import '../models/life_memory.dart';

/// ============================================================
/// YANSI MEMORY
/// ============================================================
///
/// Permanent memory storage for LifeOS.
///
/// IMPORTANT:
/// - Records are append-only.
/// - There is intentionally NO delete method.
/// - Existing memories are preserved.
/// - All five LifeOS cores can use this memory.
/// - Future AI, bill scanner, budget engine and diary engine
///   can use the same memory layer.
///
class YansiMemory {
  static const String _memoryKey =
      'yansi_permanent_memory';

  final SharedPreferences prefs;

  YansiMemory(this.prefs);

  // ==========================================================
  // READ ALL MEMORY
  // ==========================================================

  List<LifeMemory> getAll() {
    final stored =
        prefs.getStringList(_memoryKey) ?? <String>[];

    final memories = <LifeMemory>[];

    for (final item in stored) {
      try {
        final memory =
            LifeMemory.fromJson(item);

        memories.add(memory);
      } catch (_) {
        // Ignore one damaged record instead of
        // crashing the entire application.
      }
    }

    // Newest records first.
    memories.sort(
      (a, b) => b.createdAt.compareTo(
        a.createdAt,
      ),
    );

    return List.unmodifiable(memories);
  }

  // ==========================================================
  // ADD PERMANENT MEMORY
  // ==========================================================

  Future<bool> remember(
    LifeMemory memory,
  ) async {
    try {
      final stored =
          prefs.getStringList(_memoryKey) ??
              <String>[];

      // Append only.
      //
      // Existing records are never modified.
      stored.add(memory.toJson());

      final saved =
          await prefs.setStringList(
        _memoryKey,
        stored,
      );

      return saved;
    } catch (_) {
      return false;
    }
  }

  // ==========================================================
  // ADD MULTIPLE MEMORIES
  // ==========================================================

  Future<bool> rememberMany(
    List<LifeMemory> memories,
  ) async {
    if (memories.isEmpty) {
      return true;
    }

    try {
      final stored =
          prefs.getStringList(_memoryKey) ??
              <String>[];

      for (final memory in memories) {
        stored.add(memory.toJson());
      }

      final saved =
          await prefs.setStringList(
        _memoryKey,
        stored,
      );

      return saved;
    } catch (_) {
      return false;
    }
  }

  // ==========================================================
  // MEMORY COUNT
  // ==========================================================

  int get count {
    return getAll().length;
  }

  // ==========================================================
  // CORE MEMORY
  // ==========================================================

  List<LifeMemory> forCore(
    MemoryCore core,
  ) {
    final memories = getAll()
        .where(
          (memory) => memory.core == core,
        )
        .toList();

    return List.unmodifiable(memories);
  }

  // ==========================================================
  // SOURCE MEMORY
  // ==========================================================

  List<LifeMemory> forSource(
    MemorySource source,
  ) {
    final memories = getAll()
        .where(
          (memory) => memory.source == source,
        )
        .toList();

    return List.unmodifiable(memories);
  }

  // ==========================================================
  // CATEGORY MEMORY
  // ==========================================================

  List<LifeMemory> forCategory(
    String category,
  ) {
    final search =
        category.trim().toLowerCase();

    if (search.isEmpty) {
      return const [];
    }

    final memories = getAll()
        .where(
          (memory) =>
              memory.category
                  .toLowerCase() ==
              search,
        )
        .toList();

    return List.unmodifiable(memories);
  }

  // ==========================================================
  // SEARCH YANSI MEMORY
  // ==========================================================

  List<LifeMemory> search(
    String query,
  ) {
    final searchText =
        query.trim().toLowerCase();

    if (searchText.isEmpty) {
      return getAll();
    }

    final memories = getAll()
        .where(
          (memory) {
            final original =
                memory.originalText
                    .toLowerCase();

            final transcript =
                memory.transcript
                    .toLowerCase();

            final summary =
                memory.aiSummary
                    .toLowerCase();

            final category =
                memory.category
                    .toLowerCase();

            final entity =
                (memory.entity ?? '')
                    .toLowerCase();

            return original.contains(
                  searchText,
                ) ||
                transcript.contains(
                  searchText,
                ) ||
                summary.contains(
                  searchText,
                ) ||
                category.contains(
                  searchText,
                ) ||
                entity.contains(
                  searchText,
                );
          },
        )
        .toList();

    return List.unmodifiable(memories);
  }

  // ==========================================================
  // TOTAL AMOUNT FOR A CORE
  // ==========================================================

  double totalForCore(
    MemoryCore core,
  ) {
    return forCore(core).fold(
      0.0,
      (
        total,
        memory,
      ) {
        return total +
            (memory.amount ?? 0.0);
      },
    );
  }

  // ==========================================================
  // TOTAL AMOUNT FOR CATEGORY
  // ==========================================================

  double totalForCategory(
    String category,
  ) {
    return forCategory(category).fold(
      0.0,
      (
        total,
        memory,
      ) {
        return total +
            (memory.amount ?? 0.0);
      },
    );
  }

  // ==========================================================
  // COUNT FOR CORE
  // ==========================================================

  int countForCore(
    MemoryCore core,
  ) {
    return forCore(core).length;
  }

  // ==========================================================
  // COUNT FOR CATEGORY
  // ==========================================================

  int countForCategory(
    String category,
  ) {
    return forCategory(category).length;
  }

  // ==========================================================
  // TODAY'S MEMORY
  // ==========================================================

  List<LifeMemory> today() {
    final now = DateTime.now();

    final memories = getAll()
        .where(
          (memory) {
            final date =
                memory.createdAt;

            return date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
          },
        )
        .toList();

    return List.unmodifiable(memories);
  }

  // ==========================================================
  // TODAY'S CORE MEMORY
  // ==========================================================

  List<LifeMemory> todayForCore(
    MemoryCore core,
  ) {
    final memories = today()
        .where(
          (memory) => memory.core == core,
        )
        .toList();

    return List.unmodifiable(memories);
  }

  // ==========================================================
  // TODAY'S TOTAL
  // ==========================================================

  double todayTotalForCore(
    MemoryCore core,
  ) {
    return todayForCore(core).fold(
      0.0,
      (
        total,
        memory,
      ) {
        return total +
            (memory.amount ?? 0.0);
      },
    );
  }

  // ==========================================================
  // RECENT MEMORY
  // ==========================================================

  List<LifeMemory> recent({
    int limit = 20,
  }) {
    if (limit <= 0) {
      return const [];
    }

    final memories = getAll();

    if (memories.length <= limit) {
      return memories;
    }

    return List.unmodifiable(
      memories.take(limit).toList(),
    );
  }

  // ==========================================================
  // MEMORY EXISTS
  // ==========================================================

  bool containsMemoryId(
    String id,
  ) {
    if (id.trim().isEmpty) {
      return false;
    }

    return getAll().any(
      (memory) => memory.id == id,
    );
  }

  // ==========================================================
  // MEMORY BY ID
  // ==========================================================

  LifeMemory? findById(
    String id,
  ) {
    if (id.trim().isEmpty) {
      return null;
    }

    for (final memory in getAll()) {
      if (memory.id == id) {
        return memory;
      }
    }

    return null;
  }

  // ==========================================================
  // MONTHLY TOTAL
  // ==========================================================

  double monthlyTotalForCore(
    MemoryCore core, {
    DateTime? month,
  }) {
    final target =
        month ?? DateTime.now();

    return getAll()
        .where(
          (memory) {
            final date =
                memory.createdAt;

            return memory.core == core &&
                date.year == target.year &&
                date.month == target.month;
          },
        )
        .fold(
          0.0,
          (
            total,
            memory,
          ) {
            return total +
                (memory.amount ?? 0.0);
          },
        );
  }

  // ==========================================================
  // MONTHLY MEMORY
  // ==========================================================

  List<LifeMemory> monthlyMemory({
    DateTime? month,
  }) {
    final target =
        month ?? DateTime.now();

    final memories = getAll()
        .where(
          (memory) {
            final date =
                memory.createdAt;

            return date.year == target.year &&
                date.month == target.month;
          },
        )
        .toList();

    return List.unmodifiable(memories);
  }

  // ==========================================================
  // FINANCIAL ANALYSIS DATA
  // ==========================================================

  Map<String, double> spendingByCategory({
    DateTime? month,
  }) {
    final target =
        month ?? DateTime.now();

    final result =
        <String, double>{};

    for (final memory in getAll()) {
      if (memory.core !=
          MemoryCore.finance) {
        continue;
      }

      final date =
          memory.createdAt;

      if (date.year != target.year ||
          date.month != target.month) {
        continue;
      }

      final category =
          memory.category.isEmpty
              ? 'Other'
              : memory.category;

      result[category] =
          (result[category] ?? 0.0) +
              (memory.amount ?? 0.0);
    }

    return Map.unmodifiable(result);
  }

  // ==========================================================
  // IMPORTANT
  // ==========================================================
  //
  // THERE IS INTENTIONALLY:
  //
  // NO deleteMemory()
  // NO deleteAll()
  // NO remove()
  // NO clear()
  //
  // LifeOS is designed as a permanent personal history.
  //
  // ==========================================================
}
