import 'package:shared_preferences/shared_preferences.dart';

import '../models/purchase_record.dart';

/// ============================================================
/// PURCHASE MEMORY
/// ============================================================
///
/// Permanent storage for scanned and recorded purchases.
///
/// There is intentionally NO delete function.
///
/// Future sources:
/// Camera
/// Voice
/// Email
/// Notifications
/// Manual
/// ============================================================

class PurchaseMemory {
  static const String _key =
      'lifeos_purchase_records';

  final SharedPreferences prefs;

  PurchaseMemory(
    this.prefs,
  );

  // ==========================================================
  // ALL PURCHASES
  // ==========================================================

  List<PurchaseRecord> getAll() {
    final stored =
        prefs.getStringList(_key) ??
            <String>[];

    final purchases =
        <PurchaseRecord>[];

    for (final value in stored) {
      try {
        purchases.add(
          PurchaseRecord.fromJson(
            value,
          ),
        );
      } catch (_) {
        // Protect the app from one corrupted record.
      }
    }

    purchases.sort(
      (a, b) => b.createdAt.compareTo(
        a.createdAt,
      ),
    );

    return List.unmodifiable(
      purchases,
    );
  }

  // ==========================================================
  // SAVE PURCHASE
  // ==========================================================

  Future<bool> save(
    PurchaseRecord purchase,
  ) async {
    try {
      final stored =
          prefs.getStringList(_key) ??
              <String>[];

      stored.add(
        purchase.toJson(),
      );

      return await prefs.setStringList(
        _key,
        stored,
      );
    } catch (_) {
      return false;
    }
  }

  // ==========================================================
  // PURCHASE COUNT
  // ==========================================================

  int get count {
    return getAll().length;
  }

  // ==========================================================
  // MONTHLY PURCHASES
  // ==========================================================

  List<PurchaseRecord> monthly({
    DateTime? month,
  }) {
    final target =
        month ?? DateTime.now();

    return getAll()
        .where(
          (purchase) {
            final date =
                purchase.purchaseDate ??
                    purchase.createdAt;

            return date.year ==
                    target.year &&
                date.month ==
                    target.month;
          },
        )
        .toList();
  }

  // ==========================================================
  // MONTHLY TOTAL
  // ==========================================================

  double monthlyTotal({
    DateTime? month,
  }) {
    return monthly(
      month: month,
    ).fold(
      0.0,
      (
        total,
        purchase,
      ) =>
          total +
          purchase.total,
    );
  }

  // ==========================================================
  // ITEM HISTORY
  // ==========================================================

  List<PurchaseItem> itemHistory(
    String itemName,
  ) {
    final search =
        itemName.trim().toLowerCase();

    final result =
        <PurchaseItem>[];

    for (final purchase in getAll()) {
      for (final item
          in purchase.items) {
        if (item.name
            .toLowerCase()
            .contains(search)) {
          result.add(item);
        }
      }
    }

    return List.unmodifiable(
      result,
    );
  }

  // ==========================================================
  // ITEM PRICE HISTORY
  // ==========================================================

  List<double> priceHistory(
    String itemName,
  ) {
    return itemHistory(
      itemName,
    )
        .map(
          (item) => item.unitPrice,
        )
        .toList();
  }

  // ==========================================================
  // AVERAGE ITEM PRICE
  // ==========================================================

  double averageItemPrice(
    String itemName,
  ) {
    final prices =
        priceHistory(itemName);

    if (prices.isEmpty) {
      return 0;
    }

    final total =
        prices.fold<double>(
      0,
      (sum, price) =>
          sum + price,
    );

    return total / prices.length;
  }

  // ==========================================================
  // LATEST ITEM PRICE
  // ==========================================================

  double? latestItemPrice(
    String itemName,
  ) {
    final history =
        itemHistory(itemName);

    if (history.isEmpty) {
      return null;
    }

    return history.last.unitPrice;
  }

  // ==========================================================
  // PRICE TREND
  // ==========================================================

  String priceTrend(
    String itemName,
  ) {
    final prices =
        priceHistory(itemName);

    if (prices.length < 2) {
      return 'Not enough history';
    }

    final latest =
        prices.last;

    final previous =
        prices[prices.length - 2];

    if (latest >
        previous * 1.05) {
      return 'Increasing';
    }

    if (latest <
        previous * 0.95) {
      return 'Decreasing';
    }

    return 'Stable';
  }

  // ==========================================================
  // SPENDING BY CATEGORY
  // ==========================================================

  Map<String, double>
      spendingByCategory({
    DateTime? month,
  }) {
    final result =
        <String, double>{};

    for (final purchase
        in monthly(
          month: month,
        )) {
      for (final item
          in purchase.items) {
        final category =
            item.category.isEmpty
                ? 'Other'
                : item.category;

        result[category] =
            (result[category] ??
                    0.0) +
                item.totalPrice;
      }
    }

    return Map.unmodifiable(
      result,
    );
  }

  // ==========================================================
  // TOP PURCHASED ITEMS
  // ==========================================================

  Map<String, int>
      itemFrequency() {
    final result =
        <String, int>{};

    for (final purchase
        in getAll()) {
      for (final item
          in purchase.items) {
        final name =
            item.name.trim();

        if (name.isEmpty) {
          continue;
        }

        result[name] =
            (result[name] ?? 0) +
                1;
      }
    }

    return Map.unmodifiable(
      result,
    );
  }

  // ==========================================================
  // NO DELETE METHOD
  // ==========================================================
  //
  // Purchase history is permanent.
  //
  // ==========================================================
}
