import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LifeOSAIService {
  Future<String> analyze({
    required String category,
    required double amount,
    required String description,
  }) async {
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

  /// Produces a trusted, read-only intelligence signal for Yansi.
  Map<String, dynamic> buildYansiExpenseSignal({
    required String category,
    required double amount,
    String description = '',
  }) {
    final normalized = category.trim().toLowerCase();
    final highValue = amount >= 10000;
    final recurringRisk = normalized.contains('emi') ||
        normalized.contains('loan') ||
        normalized.contains('bill') ||
        normalized.contains('utility');
    final discretionary = normalized.contains('food') ||
        normalized.contains('restaurant') ||
        normalized.contains('shopping') ||
        normalized.contains('entertainment');

    var priority = 55;
    if (highValue) priority = 95;
    if (recurringRisk && priority < 85) priority = 85;
    if (discretionary && amount >= 1000 && priority < 75) priority = 75;

    final confidence = category.trim().isEmpty ? 45 : 90;

    return {
      'core': 'expense',
      'priority': priority,
      'confidence': confidence,
      'amount': amount,
      'category': category.trim(),
      'hasDescription': description.trim().isNotEmpty,
      'requiresConfirmation': highValue,
      'readOnly': true,
    };
  }

  /// Converts the expense signal into a concise ambient insight payload.
  Map<String, dynamic> buildYansiExpenseInsight({
    required String category,
    required double amount,
    String description = '',
  }) {
    final signal = buildYansiExpenseSignal(
      category: category,
      amount: amount,
      description: description,
    );

    final priority = signal['priority'] as int;
    final confidence = signal['confidence'] as int;
    final normalized = category.trim().toLowerCase();

    String? insight;
    if (priority >= 90) {
      insight = 'High-value expense detected. It may be worth reviewing before it becomes a pattern.';
    } else if (normalized.contains('emi') || normalized.contains('loan')) {
      insight = 'This is a committed expense. Yansi can help you watch the remaining discretionary spending.';
    } else if (normalized.contains('food') ||
        normalized.contains('restaurant') ||
        normalized.contains('shopping')) {
      insight = 'This spending category is worth tracking for future saving opportunities.';
    }

    return {
      ...signal,
      'insight': insight,
      'surfaceEligible': priority >= 70 && confidence >= 70,
      'speakEligible': priority >= 90 && confidence >= 70 &&
          signal['requiresConfirmation'] != true,
    };
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
        if (decoded is List) expenses = decoded;
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
    await prefs.setString('lifeos_expenses', jsonEncode(expenses));
    await _mirrorExpenseToYansi(prefs, newExpense);
  }

  /// Keeps the canonical LifeOS expense store and Yansi memory synchronized.
  /// Existing records are not duplicated: the stable record id is checked first.
  Future<void> _mirrorExpenseToYansi(
    SharedPreferences prefs,
    Map<String, dynamic> expense,
  ) async {
    final raw = prefs.getStringList('yansi_expenses') ?? <String>[];
    final id = expense['id'].toString();
    for (final value in raw) {
      try {
        final existing = Map<String, dynamic>.from(jsonDecode(value) as Map);
        if (existing['id'].toString() == id) return;
      } catch (_) {}
    }

    raw.add(jsonEncode({
      ...expense,
      'type': 'expense',
      'source': 'lifeos_expenses',
    }));
    if (raw.length > 500) raw.removeRange(0, raw.length - 500);
    await prefs.setStringList('yansi_expenses', raw);
  }
}
