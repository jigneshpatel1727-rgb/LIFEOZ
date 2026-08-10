import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LifeOSAIService {
  Future<String> analyze({
    required String category,
    required double amount,
    required String description,
  }) async {
    // Save the expense automatically.
    await _saveExpense(
      amount: amount,
      category: category,
      description: description,
    );

    final normalizedCategory = category.trim().toLowerCase();
    final note = description.trim();

    if (amount >= 10000) {
      return 'Added ₹${amount.toStringAsFixed(0)} to today\'s $category expense. This is a high-value expense, so review whether it can be reduced.';
    }

    if (normalizedCategory.contains('food') ||
        normalizedCategory.contains('restaurant') ||
        normalizedCategory.contains('shopping')) {
      return 'Added ₹${amount.toStringAsFixed(0)} to today\'s $category expense. Keep tracking this category to find ways to save.';
    }

    if (normalizedCategory.contains('fuel') ||
        normalizedCategory.contains('petrol') ||
        normalizedCategory.contains('diesel')) {
      return 'Added ₹${amount.toStringAsFixed(0)} to today\'s Fuel expense. Keep monitoring your fuel spending.';
    }

    if (normalizedCategory.contains('electricity') ||
        normalizedCategory.contains('bill') ||
        normalizedCategory.contains('utility')) {
      return 'Added ₹${amount.toStringAsFixed(0)} to today\'s $category expense. Compare it with previous months.';
    }

    if (normalizedCategory.contains('emi') ||
        normalizedCategory.contains('loan')) {
      return 'Added ₹${amount.toStringAsFixed(0)} to today\'s $category expense. EMI is a committed expense, so focus on controlling other spending.';
    }

    if (amount <= 500) {
      return 'Added ₹${amount.toStringAsFixed(0)} to today\'s $category expense. Small expenses can add up, so keep tracking them.';
    }

    if (note.isNotEmpty) {
      return 'Added ₹${amount.toStringAsFixed(0)} to today\'s $category expense. Your description was also saved.';
    }

    return 'Added ₹${amount.toStringAsFixed(0)} to today\'s $category expense.';
  }

  Future<void> _saveExpense({
    required double amount,
    required String category,
    required String description,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final existing = prefs.getString('lifeos_expenses');

    List<dynamic> expenses = [];

    if (existing != null && existing.isNotEmpty) {
      try {
        final decoded = jsonDecode(existing);

        if (decoded is List) {
          expenses = decoded;
        }
      } catch (_) {
        expenses = [];
      }
    }

    final now = DateTime.now();

    final newExpense = {
      'id': now.microsecondsSinceEpoch.toString(),
      'amount': amount,
      'category': category,
      'note': description.trim(),
      'date': now.toIso8601String(),
    };

    expenses.insert(0, newExpense);

    await prefs.setString(
      'lifeos_expenses',
      jsonEncode(expenses),
    );
  }
}
