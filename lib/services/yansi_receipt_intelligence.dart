import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'yansi_receipt_scanner.dart';

/// Persists a reviewed receipt into the existing LifeOS money and household
/// stores. It deliberately keeps the operation local and reversible.
class YansiReceiptIntelligence {
  const YansiReceiptIntelligence();

  Future<Map<String, dynamic>> commitReceipt({
    required SharedPreferences prefs,
    required YansiReceiptResult receipt,
    String source = 'receipt_scan',
    bool saveItemsToHousehold = true,
  }) async {
    final now = DateTime.now();
    final date = receipt.date ?? now;
    final expenseRecords = <String>[...(prefs.getStringList('yansi_expenses') ?? const [])];
    final householdRecords = <String>[...(prefs.getStringList('yansi_household') ?? const [])];

    final total = receipt.total ?? receipt.items.fold<double>(0, (sum, item) => sum + (item.price ?? 0));
    final expense = <String, dynamic>{
      'amount': total,
      'category': _categoryForItems(receipt.items),
      'merchant': receipt.merchant,
      'date': date.toIso8601String(),
      'source': source,
      'receipt': true,
      'items': receipt.items.map((e) => e.toMap()).toList(),
    };
    expenseRecords.add(jsonEncode(expense));
    await prefs.setStringList('yansi_expenses', expenseRecords);

    if (saveItemsToHousehold) {
      for (final item in receipt.items) {
        if (item.name.trim().isEmpty) continue;
        householdRecords.add(jsonEncode({
          'item': item.name.trim(),
          'amount': item.price,
          'quantity': item.quantity,
          'date': date.toIso8601String(),
          'source': source,
          'merchant': receipt.merchant,
          'fromReceipt': true,
          'category': _categoryForName(item.name),
        }));
      }
      await prefs.setStringList('yansi_household', householdRecords);
    }

    return {
      'expenseSaved': true,
      'householdItemsSaved': saveItemsToHousehold ? receipt.items.length : 0,
      'amount': total,
      'merchant': receipt.merchant,
      'category': expense['category'],
      'source': source,
    };
  }

  String _categoryForItems(List<YansiReceiptItem> items) {
    if (items.isEmpty) return 'shopping';
    final counts = <String, int>{};
    for (final item in items) {
      final category = _categoryForName(item.name);
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String _categoryForName(String name) {
    final value = name.toLowerCase();
    if (RegExp(r'\b(rice|wheat|flour|dal|pulse|milk|bread|vegetable|fruit|grocery|oil|sugar|salt|spice|snack|food)\b').hasMatch(value)) {
      return 'food';
    }
    if (RegExp(r'\b(detergent|soap|cleaner|toilet|tissue|broom|mop|dishwash|household)\b').hasMatch(value)) {
      return 'household';
    }
    if (RegExp(r'\b(shampoo|cream|toothpaste|cosmetic|personal)\b').hasMatch(value)) {
      return 'personal_care';
    }
    if (RegExp(r'\b(petrol|diesel|fuel|parking|transport)\b').hasMatch(value)) {
      return 'transport';
    }
    return 'shopping';
  }
}
