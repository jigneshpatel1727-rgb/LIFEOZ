import '../models/life_memory.dart';
import 'yansi_memory.dart';

/// ============================================================
/// HOUSEHOLD INTELLIGENCE
/// ============================================================
///
/// Yansi learns household purchasing patterns from permanent
/// LifeOS memory.
///
/// It does NOT delete or modify historical records.
///
/// It analyzes:
/// - Previous household purchases
/// - Grocery purchases
/// - Repeated items
/// - Purchase frequency
/// - Last purchase date
/// - Average spending
///
/// Then it can prepare:
/// - Daily requirements
/// - Weekly requirements
/// - Monthly requirements
/// - Estimated household budget
///
/// Future upgrades:
/// - Receipt scanning
/// - Quantity extraction
/// - Price history
/// - Stock estimation
/// - Smart reminders
/// ============================================================

class HouseholdItemPattern {
  final String item;

  final int purchaseCount;

  final DateTime? lastPurchase;

  final double totalSpent;

  final double averagePrice;

  final double averageDaysBetweenPurchases;

  const HouseholdItemPattern({
    required this.item,
    required this.purchaseCount,
    required this.lastPurchase,
    required this.totalSpent,
    required this.averagePrice,
    required this.averageDaysBetweenPurchases,
  });

  int get daysSinceLastPurchase {
    if (lastPurchase == null) {
      return 9999;
    }

    return DateTime.now()
        .difference(lastPurchase!)
        .inDays;
  }

  bool get likelyNeededSoon {
    if (lastPurchase == null) {
      return false;
    }

    if (averageDaysBetweenPurchases <= 0) {
      return false;
    }

    return daysSinceLastPurchase >=
        averageDaysBetweenPurchases * 0.80;
  }

  bool get likelyNeededNow {
    if (lastPurchase == null) {
      return false;
    }

    if (averageDaysBetweenPurchases <= 0) {
      return false;
    }

    return daysSinceLastPurchase >=
        averageDaysBetweenPurchases;
  }
}

class HouseholdRequirement {
  final String item;

  final String reason;

  final double estimatedPrice;

  final bool urgent;

  final bool predicted;

  const HouseholdRequirement({
    required this.item,
    required this.reason,
    required this.estimatedPrice,
    required this.urgent,
    required this.predicted,
  });
}

class HouseholdReport {
  final List<HouseholdItemPattern> patterns;

  final List<HouseholdRequirement> requirements;

  final double estimatedMonthlyCost;

  final int learnedItemCount;

  const HouseholdReport({
    required this.patterns,
    required this.requirements,
    required this.estimatedMonthlyCost,
    required this.learnedItemCount,
  });
}

class HouseholdIntelligence {
  final YansiMemory memory;

  HouseholdIntelligence(
    this.memory,
  );

  // ==========================================================
  // GENERATE COMPLETE HOUSEHOLD REPORT
  // ==========================================================

  HouseholdReport generateReport() {
    final patterns =
        learnPatterns();

    final requirements =
        generateRequirements(
      patterns,
    );

    final monthlyCost =
        estimateMonthlyCost(
      patterns,
    );

    return HouseholdReport(
      patterns: patterns,
      requirements: requirements,
      estimatedMonthlyCost: monthlyCost,
      learnedItemCount: patterns.length,
    );
  }

  // ==========================================================
  // LEARN PURCHASING PATTERNS
  // ==========================================================

  List<HouseholdItemPattern> learnPatterns() {
    final memories =
        memory.getAll();

    final householdMemories =
        memories.where(
      (item) =>
          item.core == MemoryCore.household ||
          _isGroceryMemory(item),
    );

    final grouped =
        <String, List<LifeMemory>>{};

    for (final item in householdMemories) {
      final name =
          _normaliseItem(
        item.entity ??
            item.category,
      );

      if (name.isEmpty) {
        continue;
      }

      grouped
          .putIfAbsent(
            name,
            () => <LifeMemory>[],
          )
          .add(item);
    }

    final patterns =
        <HouseholdItemPattern>[];

    for (final entry in grouped.entries) {
      final itemMemories =
          entry.value.toList();

      itemMemories.sort(
        (a, b) =>
            a.createdAt.compareTo(
          b.createdAt,
        ),
      );

      final purchaseCount =
          itemMemories.length;

      final totalSpent =
          itemMemories.fold<double>(
        0.0,
        (
          total,
          memory,
        ) =>
            total +
            (memory.amount ?? 0.0),
      );

      final averagePrice =
          purchaseCount == 0
              ? 0.0
              : totalSpent /
                  purchaseCount;

      final intervals =
          <int>[];

      for (
        int i = 1;
        i < itemMemories.length;
        i++
      ) {
        final previous =
            itemMemories[i - 1]
                .createdAt;

        final current =
            itemMemories[i]
                .createdAt;

        final days =
            current
                .difference(previous)
                .inDays;

        if (days > 0) {
          intervals.add(days);
        }
      }

      final averageInterval =
          intervals.isEmpty
              ? 30.0
              : intervals.reduce(
                    (a, b) => a + b,
                  ) /
                  intervals.length;

      patterns.add(
        HouseholdItemPattern(
          item: entry.key,
          purchaseCount:
              purchaseCount,
          lastPurchase:
              itemMemories
                  .last
                  .createdAt,
          totalSpent:
              totalSpent,
          averagePrice:
              averagePrice,
          averageDaysBetweenPurchases:
              averageInterval,
        ),
      );
    }

    patterns.sort(
      (a, b) =>
          b.purchaseCount
              .compareTo(
        a.purchaseCount,
      ),
    );

    return patterns;
  }

  // ==========================================================
  // GENERATE REQUIREMENTS
  // ==========================================================

  List<HouseholdRequirement> generateRequirements(
    List<HouseholdItemPattern> patterns,
  ) {
    final requirements =
        <HouseholdRequirement>[];

    for (final pattern in patterns) {
      if (pattern.likelyNeededNow) {
        requirements.add(
          HouseholdRequirement(
            item: pattern.item,
            reason:
                'Yansi predicts this item is due based on your normal purchase cycle.',
            estimatedPrice:
                pattern.averagePrice,
            urgent: true,
            predicted: true,
          ),
        );
      } else if (pattern.likelyNeededSoon) {
        requirements.add(
          HouseholdRequirement(
            item: pattern.item,
            reason:
                'Yansi predicts you may need this item soon.',
            estimatedPrice:
                pattern.averagePrice,
            urgent: false,
            predicted: true,
          ),
        );
      }
    }

    return requirements;
  }

  // ==========================================================
  // DAILY LIST
  // ==========================================================

  List<HouseholdRequirement> dailyList() {
    final patterns =
        learnPatterns();

    return generateRequirements(
      patterns,
    ).where(
      (item) =>
          item.urgent,
    ).toList();
  }

  // ==========================================================
  // MONTHLY LIST
  // ==========================================================

  List<HouseholdRequirement> monthlyList() {
    final patterns =
        learnPatterns();

    final requirements =
        <HouseholdRequirement>[];

    for (final pattern in patterns) {
      if (pattern.purchaseCount >= 1) {
        requirements.add(
          HouseholdRequirement(
            item: pattern.item,
            reason:
                'Included from your household purchase history.',
            estimatedPrice:
                pattern.averagePrice,
            urgent:
                pattern.likelyNeededNow,
            predicted: true,
          ),
        );
      }
    }

    return requirements;
  }

  // ==========================================================
  // ESTIMATE MONTHLY HOUSEHOLD COST
  // ==========================================================

  double estimateMonthlyCost(
    List<HouseholdItemPattern> patterns,
  ) {
    double total = 0.0;

    for (final pattern in patterns) {
      if (pattern.averageDaysBetweenPurchases <= 0) {
        continue;
      }

      final purchasesPerMonth =
          30 /
              pattern.averageDaysBetweenPurchases;

      total +=
          pattern.averagePrice *
              purchasesPerMonth;
    }

    return total;
  }

  // ==========================================================
  // ITEM PRICE HISTORY
  // ==========================================================

  List<double> priceHistory(
    String item,
  ) {
    final search =
        _normaliseItem(item);

    final results =
        <double>[];

    for (final memoryItem
        in memory.getAll()) {
      final entity =
          _normaliseItem(
        memoryItem.entity ?? '',
      );

      if (entity == search &&
          memoryItem.amount != null) {
        results.add(
          memoryItem.amount!,
        );
      }
    }

    return List.unmodifiable(
      results,
    );
  }

  // ==========================================================
  // AVERAGE ITEM PRICE
  // ==========================================================

  double averagePrice(
    String item,
  ) {
    final prices =
        priceHistory(item);

    if (prices.isEmpty) {
      return 0.0;
    }

    final total =
        prices.fold<double>(
      0.0,
      (sum, price) =>
          sum + price,
    );

    return total / prices.length;
  }

  // ==========================================================
  // PRICE TREND
  // ==========================================================

  String priceTrend(
    String item,
  ) {
    final prices =
        priceHistory(item);

    if (prices.length < 2) {
      return 'Not enough history';
    }

    final recent =
        prices.last;

    final previous =
        prices[prices.length - 2];

    if (recent > previous * 1.05) {
      return 'Increasing';
    }

    if (recent < previous * 0.95) {
      return 'Decreasing';
    }

    return 'Stable';
  }

  // ==========================================================
  // SMART SAVING INSIGHT
  // ==========================================================

  String? savingSuggestion() {
    final patterns =
        learnPatterns();

    if (patterns.isEmpty) {
      return null;
    }

    final expensive =
        patterns.where(
      (item) =>
          item.averagePrice > 1000,
    );

    if (expensive.isNotEmpty) {
      final item =
          expensive.first;

      return 'Your ${item.item} purchases '
          'average around '
          '${item.averagePrice.toStringAsFixed(0)} '
          'per purchase. Yansi can watch this '
          'category for future savings opportunities.';
    }

    return 'Yansi is learning your household '
        'purchase patterns and will identify '
        'future savings opportunities.';
  }

  // ==========================================================
  // CHECK IF MEMORY IS GROCERY RELATED
  // ==========================================================

  bool _isGroceryMemory(
    LifeMemory memoryItem,
  ) {
    final text =
        '${memoryItem.originalText} '
        '${memoryItem.category} '
        '${memoryItem.entity ?? ''}'
            .toLowerCase();

    const groceryWords = [
      'grocery',
      'groceries',
      'rice',
      'oil',
      'milk',
      'vegetable',
      'bread',
      'detergent',
      'soap',
      'shampoo',
      'household',
      'shopping',
    ];

    for (final word
        in groceryWords) {
      if (text.contains(word)) {
        return true;
      }
    }

    return false;
  }

  // ==========================================================
  // NORMALISE ITEM
  // ==========================================================

  String _normaliseItem(
    String value,
  ) {
    var result =
        value.trim().toLowerCase();

    if (result.isEmpty) {
      return '';
    }

    result = result
        .replaceAll(
          'groceries',
          'grocery',
        )
        .replaceAll(
          'vegetables',
          'vegetable',
        )
        .replaceAll(
          'shirts',
          'shirt',
        );

    return result;
  }
}
