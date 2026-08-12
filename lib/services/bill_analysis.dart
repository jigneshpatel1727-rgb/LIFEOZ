import '../models/purchase_record.dart';
import 'purchase_memory.dart';

/// ============================================================
/// BILL ANALYSIS ENGINE
/// ============================================================
///
/// Yansi uses this engine to understand purchase history.
///
/// It can calculate:
/// - Monthly spending
/// - Category spending
/// - Item price history
/// - Average item price
/// - Latest item price
/// - Price movement
/// - Frequently purchased items
/// - Unusual/high purchases
/// - Estimated monthly household spending
/// - Savings opportunities
///
/// Historical records are never deleted or modified.
/// ============================================================

class BillAnalysisResult {
  final double monthlyTotal;

  final double previousMonthTotal;

  final double monthlyChangePercent;

  final Map<String, double> categoryTotals;

  final List<String> frequentlyPurchasedItems;

  final List<String> priceIncreasingItems;

  final List<String> priceDecreasingItems;

  final List<String> unusualPurchases;

  final List<String> suggestions;

  const BillAnalysisResult({
    required this.monthlyTotal,
    required this.previousMonthTotal,
    required this.monthlyChangePercent,
    required this.categoryTotals,
    required this.frequentlyPurchasedItems,
    required this.priceIncreasingItems,
    required this.priceDecreasingItems,
    required this.unusualPurchases,
    required this.suggestions,
  });
}

class BillAnalysis {
  final PurchaseMemory purchaseMemory;

  BillAnalysis(
    this.purchaseMemory,
  );

  // ==========================================================
  // COMPLETE ANALYSIS
  // ==========================================================

  BillAnalysisResult analyze({
    DateTime? month,
  }) {
    final target =
        month ?? DateTime.now();

    final current =
        purchaseMemory.monthly(
      month: target,
    );

    final previousDate =
        DateTime(
      target.year,
      target.month - 1,
      1,
    );

    final previous =
        purchaseMemory.monthly(
      month: previousDate,
    );

    final currentTotal =
        current.fold<double>(
      0.0,
      (
        total,
        purchase,
      ) =>
          total +
          purchase.total,
    );

    final previousTotal =
        previous.fold<double>(
      0.0,
      (
        total,
        purchase,
      ) =>
          total +
          purchase.total,
    );

    final change =
        _percentageChange(
      previousTotal,
      currentTotal,
    );

    final categories =
        purchaseMemory.spendingByCategory(
      month: target,
    );

    final frequent =
        _frequentItems();

    final increasing =
        _itemsWithTrend(
      'Increasing',
    );

    final decreasing =
        _itemsWithTrend(
      'Decreasing',
    );

    final unusual =
        _findUnusualPurchases(
      current,
    );

    final suggestions =
        _generateSuggestions(
      currentTotal: currentTotal,
      previousTotal: previousTotal,
      categoryTotals: categories,
      increasingItems: increasing,
      unusualPurchases: unusual,
    );

    return BillAnalysisResult(
      monthlyTotal:
          currentTotal,
      previousMonthTotal:
          previousTotal,
      monthlyChangePercent:
          change,
      categoryTotals:
          Map.unmodifiable(
        categories,
      ),
      frequentlyPurchasedItems:
          List.unmodifiable(
        frequent,
      ),
      priceIncreasingItems:
          List.unmodifiable(
        increasing,
      ),
      priceDecreasingItems:
          List.unmodifiable(
        decreasing,
      ),
      unusualPurchases:
          List.unmodifiable(
        unusual,
      ),
      suggestions:
          List.unmodifiable(
        suggestions,
      ),
    );
  }

  // ==========================================================
  // MONTHLY TOTAL
  // ==========================================================

  double monthlyTotal({
    DateTime? month,
  }) {
    return purchaseMemory.monthlyTotal(
      month: month,
    );
  }

  // ==========================================================
  // CATEGORY TOTAL
  // ==========================================================

  double categoryTotal(
    String category, {
    DateTime? month,
  }) {
    final purchases =
        purchaseMemory.monthly(
      month: month,
    );

    double total = 0;

    for (final purchase
        in purchases) {
      for (final item
          in purchase.items) {
        if (item.category
            .toLowerCase() ==
            category.toLowerCase()) {
          total += item.totalPrice;
        }
      }
    }

    return total;
  }

  // ==========================================================
  // ITEM PRICE ANALYSIS
  // ==========================================================

  Map<String, dynamic>
      itemPriceAnalysis(
    String itemName,
  ) {
    final history =
        purchaseMemory.priceHistory(
      itemName,
    );

    final average =
        purchaseMemory.averageItemPrice(
      itemName,
    );

    final latest =
        purchaseMemory.latestItemPrice(
      itemName,
    );

    final trend =
        purchaseMemory.priceTrend(
      itemName,
    );

    double highest = 0;
    double lowest = 0;

    if (history.isNotEmpty) {
      highest =
          history.reduce(
        (a, b) => a > b ? a : b,
      );

      lowest =
          history.reduce(
        (a, b) => a < b ? a : b,
      );
    }

    return {
      'item': itemName,
      'history': history,
      'averagePrice': average,
      'latestPrice': latest,
      'highestPrice': highest,
      'lowestPrice': lowest,
      'trend': trend,
    };
  }

  // ==========================================================
  // FREQUENT ITEMS
  // ==========================================================

  List<String> _frequentItems() {
    final frequency =
        purchaseMemory.itemFrequency();

    final entries =
        frequency.entries.toList();

    entries.sort(
      (a, b) =>
          b.value.compareTo(
        a.value,
      ),
    );

    return entries
        .take(10)
        .map(
          (entry) => entry.key,
        )
        .toList();
  }

  // ==========================================================
  // PRICE TRENDS
  // ==========================================================

  List<String> _itemsWithTrend(
    String trend,
  ) {
    final frequency =
        purchaseMemory.itemFrequency();

    final results =
        <String>[];

    for (final item
        in frequency.keys) {
      final currentTrend =
          purchaseMemory.priceTrend(
        item,
      );

      if (currentTrend == trend) {
        results.add(item);
      }
    }

    return results;
  }

  // ==========================================================
  // UNUSUAL PURCHASES
  // ==========================================================
  //
  // A purchase is considered unusual when the item's price
  // is substantially above its historical average.
  //
  // This is a simple local rule now.
  // Later the AI layer can make this much smarter.
  // ==========================================================

  List<String> _findUnusualPurchases(
    List<PurchaseRecord> purchases,
  ) {
    final results =
        <String>[];

    for (final purchase
        in purchases) {
      for (final item
          in purchase.items) {
        final history =
            purchaseMemory.priceHistory(
          item.name,
        );

        if (history.length < 2) {
          continue;
        }

        final average =
            purchaseMemory.averageItemPrice(
          item.name,
        );

        if (average <= 0) {
          continue;
        }

        if (item.unitPrice >
            average * 1.30) {
          results.add(
            '${item.name} was purchased at '
            '${item.unitPrice.toStringAsFixed(0)}, '
            'above its historical average of '
            '${average.toStringAsFixed(0)}.',
          );
        }
      }
    }

    return results;
  }

  // ==========================================================
  // SUGGESTIONS
  // ==========================================================

  List<String> _generateSuggestions({
    required double currentTotal,
    required double previousTotal,
    required Map<String, double>
        categoryTotals,
    required List<String>
        increasingItems,
    required List<String>
        unusualPurchases,
  }) {
    final suggestions =
        <String>[];

    // --------------------------------------------------------
    // MONTHLY SPENDING
    // --------------------------------------------------------

    if (previousTotal > 0 &&
        currentTotal >
            previousTotal * 1.10) {
      suggestions.add(
        'Your purchase spending is more than 10% higher than last month. Yansi will watch the main categories causing the increase.',
      );
    }

    if (previousTotal > 0 &&
        currentTotal <
            previousTotal * 0.90) {
      suggestions.add(
        'Your purchase spending is lower than last month. You are currently moving in a positive direction.',
      );
    }

    // --------------------------------------------------------
    // CATEGORY
    // --------------------------------------------------------

    if (categoryTotals.isNotEmpty) {
      final sorted =
          categoryTotals.entries.toList();

      sorted.sort(
        (a, b) =>
            b.value.compareTo(
          a.value,
        ),
      );

      final highest =
          sorted.first;

      suggestions.add(
        '${highest.key} is currently your largest recorded purchase category at ${highest.value.toStringAsFixed(0)}.',
      );
    }

    // --------------------------------------------------------
    // PRICE INCREASES
    // --------------------------------------------------------

    if (increasingItems.isNotEmpty) {
      final names =
          increasingItems
              .take(3)
              .join(', ');

      suggestions.add(
        'Yansi detected increasing prices for: $names.',
      );
    }

    // --------------------------------------------------------
    // UNUSUAL PURCHASES
    // --------------------------------------------------------

    if (unusualPurchases.isNotEmpty) {
      suggestions.add(
        'Yansi found purchases that are higher than your historical normal. These can be reviewed for future savings.',
      );
    }

    // --------------------------------------------------------
    // DEFAULT
    // --------------------------------------------------------

    if (suggestions.isEmpty) {
      suggestions.add(
        'Yansi is learning your purchase patterns. More useful savings insights will appear as your history grows.',
      );
    }

    return suggestions;
  }

  // ==========================================================
  // PERCENTAGE CHANGE
  // ==========================================================

  double _percentageChange(
    double previous,
    double current,
  ) {
    if (previous == 0) {
      return current == 0
          ? 0
          : 100;
    }

    return ((current - previous) /
            previous) *
        100;
  }

  // ==========================================================
  // SAVINGS OPPORTUNITY
  // ==========================================================

  String? savingsOpportunity() {
    final result =
        analyze();

    if (result.unusualPurchases
        .isNotEmpty) {
      return 'Yansi found unusually high purchases that may provide a savings opportunity.';
    }

    if (result.priceIncreasingItems
        .isNotEmpty) {
      return 'Some regularly purchased items are becoming more expensive. Yansi can watch their prices for you.';
    }

    if (result.monthlyChangePercent >
        10) {
      return 'Your purchase spending is rising. Yansi can help identify where to reduce it.';
    }

    return 'Yansi is continuously learning your purchase patterns.';
  }

  // ==========================================================
  // BUDGET PREPARATION DATA
  // ==========================================================
  //
  // This does NOT set a final user budget yet.
  // It prepares historical data for the upcoming
  // Budget Intelligence Engine.
  // ==========================================================

  Map<String, double>
      budgetBaseline() {
    final result =
        <String, double>{};

    final now =
        DateTime.now();

    for (int i = 0; i < 6; i++) {
      final month =
          DateTime(
        now.year,
        now.month - i,
        1,
      );

      final categories =
          purchaseMemory
              .spendingByCategory(
        month: month,
      );

      for (final entry
          in categories.entries) {
        result[entry.key] =
            (result[entry.key] ??
                    0) +
                entry.value;
      }
    }

    // Convert six-month total into an
    // approximate monthly baseline.
    for (final key
        in result.keys.toList()) {
      result[key] =
          result[key]! / 6;
    }

    return Map.unmodifiable(
      result,
    );
  }
}
