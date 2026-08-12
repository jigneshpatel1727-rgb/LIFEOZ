import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BudgetEngine {
  final SharedPreferences prefs;

  BudgetEngine({
    required this.prefs,
  });

  // ==========================================================
  // SAVE RECEIPT INTO FINANCIAL MEMORY
  // ==========================================================

  Future<void> saveReceiptAsExpense({
    required double total,
    required List<Map<String, dynamic>> items,
    String source = 'receipt',
  }) async {
    final now = DateTime.now();

    final record = {
      'id': now.microsecondsSinceEpoch.toString(),
      'type': 'expense',
      'source': source,
      'date': now.toIso8601String(),
      'amount': total,
      'category': _mainCategory(items),
      'items': items,
      'text': 'Receipt purchase',
    };

    final memory =
        prefs.getStringList('yansi_memory') ??
            <String>[];

    memory.add(
      jsonEncode(record),
    );

    await prefs.setStringList(
      'yansi_memory',
      memory,
    );

    await _updateCategorySpending(
      items,
    );
  }

  // ==========================================================
  // CATEGORY SPENDING
  // ==========================================================

  Future<void> _updateCategorySpending(
    List<Map<String, dynamic>> items,
  ) async {
    final spending =
        await categorySpending();

    for (final item in items) {
      final category =
          item['category']
                  ?.toString() ??
              'Other';

      final price =
          (item['price'] as num?)
                  ?.toDouble() ??
              0;

      spending[category] =
          (spending[category] ?? 0) +
              price;
    }

    await prefs.setString(
      'yansi_category_spending',
      jsonEncode(spending),
    );
  }

  // ==========================================================
  // CATEGORY SPENDING READ
  // ==========================================================

  Future<Map<String, double>>
      categorySpending() async {
    final raw =
        prefs.getString(
      'yansi_category_spending',
    );

    if (raw == null) {
      return {};
    }

    try {
      final decoded =
          jsonDecode(raw);

      if (decoded is! Map) {
        return {};
      }

      return decoded.map(
        (key, value) {
          return MapEntry(
            key.toString(),
            (value as num).toDouble(),
          );
        },
      );
    } catch (_) {
      return {};
    }
  }

  // ==========================================================
  // CURRENT MONTH SPENDING
  // ==========================================================

  Future<double> currentMonthSpending() async {
    final memory =
        prefs.getStringList(
              'yansi_memory',
            ) ??
            <String>[];

    final now =
        DateTime.now();

    double total = 0;

    for (final raw in memory) {
      try {
        final record =
            jsonDecode(raw);

        if (record is! Map) {
          continue;
        }

        if (record['type'] !=
            'expense') {
          continue;
        }

        final date =
            DateTime.tryParse(
          record['date']
                  ?.toString() ??
              '',
        );

        if (date == null) {
          continue;
        }

        if (date.year ==
                now.year &&
            date.month ==
                now.month) {
          total +=
              (record['amount']
                          as num?)
                      ?.toDouble() ??
                  0;
        }
      } catch (_) {}
    }

    return total;
  }

  // ==========================================================
  // MONTHLY CATEGORY SPENDING
  // ==========================================================

  Future<Map<String, double>>
      currentMonthCategories() async {
    final memory =
        prefs.getStringList(
              'yansi_memory',
            ) ??
            <String>[];

    final now =
        DateTime.now();

    final result =
        <String, double>{};

    for (final raw in memory) {
      try {
        final record =
            jsonDecode(raw);

        if (record is! Map) {
          continue;
        }

        if (record['type'] !=
            'expense') {
          continue;
        }

        final date =
            DateTime.tryParse(
          record['date']
                  ?.toString() ??
              '',
        );

        if (date == null ||
            date.year !=
                now.year ||
            date.month !=
                now.month) {
          continue;
        }

        final category =
            record['category']
                    ?.toString() ??
                'Other';

        final amount =
            (record['amount']
                        as num?)
                    ?.toDouble() ??
                0;

        result[category] =
            (result[category] ??
                    0) +
                amount;

        // Also analyse individual receipt items.
        final items =
            record['items'];

        if (items is List) {
          for (final item
              in items) {
            if (item
                is! Map) {
              continue;
            }

            final itemCategory =
                item['category']
                        ?.toString() ??
                    category;

            final price =
                (item['price']
                            as num?)
                        ?.toDouble() ??
                    0;

            result[
                    itemCategory] =
                (result[
                            itemCategory] ??
                        0) +
                    price;
          }
        }
      } catch (_) {}
    }

    return result;
  }

  // ==========================================================
  // SIMPLE MONTHLY BUDGET
  // ==========================================================

  Future<Map<String, dynamic>>
      calculateBudget({
    double? monthlyIncome,
  }) async {
    final spending =
        await currentMonthSpending();

    final income =
        monthlyIncome ??
            prefs.getDouble(
              'yansi_monthly_income',
            ) ??
            0;

    if (income <= 0) {
      return {
        'income': 0,
        'spending': spending,
        'remaining': 0,
        'savingTarget': 0,
        'message':
            'Set your monthly income so Yansi can create a smarter budget.',
      };
    }

    final remaining =
        income - spending;

    final savingTarget =
        income * 0.20;

    String message;

    if (spending >
        income * 0.80) {
      message =
          'Your spending is getting high. Yansi recommends reducing non-essential expenses.';
    } else if (spending >
        income * 0.60) {
      message =
          'You are spending moderately. Yansi will watch your categories for saving opportunities.';
    } else {
      message =
          'Your spending is under control. Yansi can help you increase your savings.';
    }

    return {
      'income': income,
      'spending': spending,
      'remaining': remaining,
      'savingTarget': savingTarget,
      'message': message,
    };
  }

  // ==========================================================
  // SAVING SUGGESTIONS
  // ==========================================================

  Future<List<String>>
      savingSuggestions() async {
    final categories =
        await currentMonthCategories();

    if (categories.isEmpty) {
      return [
        'Yansi needs more spending history before making personalised saving suggestions.',
      ];
    }

    final sorted =
        categories.entries.toList()
          ..sort(
            (a, b) =>
                b.value.compareTo(
              a.value,
            ),
          );

    final suggestions =
        <String>[];

    for (final entry
        in sorted.take(3)) {
      if (entry.value > 0) {
        suggestions.add(
          '${entry.key} is one of your higher spending areas at ₹${entry.value.toStringAsFixed(0)} this month.',
        );
      }
    }

    suggestions.add(
      'Yansi will continue learning your spending pattern and look for future saving opportunities.',
    );

    return suggestions;
  }

  // ==========================================================
  // MAIN CATEGORY
  // ==========================================================

  String _mainCategory(
    List<Map<String, dynamic>> items,
  ) {
    if (items.isEmpty) {
      return 'Other';
    }

    final counts =
        <String, int>{};

    for (final item in items) {
      final category =
          item['category']
                  ?.toString() ??
              'Other';

      counts[category] =
          (counts[category] ??
                  0) +
              1;
    }

    counts.entries.toList()
      ..sort(
        (a, b) =>
            b.value.compareTo(
          a.value,
        ),
      );

    return counts.keys.first;
  }
}
