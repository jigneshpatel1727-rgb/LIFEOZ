import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Deterministic, offline-first action engine for iamyansi.
///
/// It converts simple natural-language commands into canonical records and
/// stores them in the same stream consumed by the existing five-core UI.
/// No network call is made here and no sensitive action is executed implicitly.
class IamyansiActionEngine {
  static const canonicalKey = 'iamyansi_core_records';
  static const _idPrefix = 'yansi';

  final SharedPreferences prefs;
  const IamyansiActionEngine({required this.prefs});

  Future<IamyansiActionResult> process(String transcript, {DateTime? now}) async {
    final text = transcript.trim();
    if (text.isEmpty) return const IamyansiActionResult.unhandled();
    final lower = text.toLowerCase();
    final time = now ?? DateTime.now();

    final expense = _parseExpense(text, lower);
    if (expense != null) return _save(expense, time);

    final income = _parseIncome(text, lower);
    if (income != null) return _save(income, time);

    final task = _parseTask(text, lower);
    if (task != null) return _save(task, time);

    final shopping = _parseShopping(text, lower);
    if (shopping != null) return _save(shopping, time);

    final diary = _parseDiary(text, lower);
    if (diary != null) return _save(diary, time);

    return const IamyansiActionResult.unhandled();
  }

  Map<String, dynamic>? _parseExpense(String text, String lower) {
    if (!(lower.contains('spent') || lower.contains('paid') || lower.contains('expense') || lower.contains('bought'))) return null;
    final amount = _amount(text);
    if (amount == null) return null;
    final category = _category(lower);
    return {'type': 'expense', 'amount': amount, 'category': category, 'text': text};
  }

  Map<String, dynamic>? _parseIncome(String text, String lower) {
    if (!(lower.contains('received') || lower.contains('income') || lower.contains('earned') || lower.contains('salary'))) return null;
    final amount = _amount(text);
    if (amount == null) return null;
    return {'type': 'income', 'amount': amount, 'category': 'income', 'text': text};
  }

  Map<String, dynamic>? _parseTask(String text, String lower) {
    final markers = ['remind me to ', 'add task ', 'add a task ', 'task: ', 'i need to '];
    for (final marker in markers) {
      final index = lower.indexOf(marker);
      if (index >= 0) {
        final value = text.substring(index + marker.length).trim();
        if (value.isNotEmpty) return {'type': 'task', 'task': value, 'completed': false, 'text': text};
      }
    }
    return null;
  }

  Map<String, dynamic>? _parseShopping(String text, String lower) {
    final markers = ['add to shopping list ', 'add to grocery list ', 'shopping list '];
    for (final marker in markers) {
      final index = lower.indexOf(marker);
      if (index >= 0) {
        final value = text.substring(index + marker.length).trim();
        if (value.isNotEmpty) return {'type': 'household', 'item': value, 'text': text};
      }
    }
    return null;
  }

  Map<String, dynamic>? _parseDiary(String text, String lower) {
    const markers = ['diary: ', 'note this: ', 'journal: '];
    for (final marker in markers) {
      final index = lower.indexOf(marker);
      if (index >= 0) {
        final value = text.substring(index + marker.length).trim();
        if (value.isNotEmpty) return {'type': 'diary', 'text': value};
      }
    }
    return null;
  }

  Future<IamyansiActionResult> _save(Map<String, dynamic> data, DateTime now) async {
    final id = '${_idPrefix}_${now.microsecondsSinceEpoch}';
    final record = <String, dynamic>{
      ...data,
      'id': id,
      'source': 'iamyansi_voice',
      'createdAt': now.toIso8601String(),
      'dateKey': _dateKey(now),
    };
    final raw = prefs.getStringList(canonicalKey) ?? <String>[];
    raw.add(jsonEncode(record));
    await prefs.setStringList(canonicalKey, raw);
    return IamyansiActionResult.handled(record);
  }

  double? _amount(String text) {
    final match = RegExp(r'(?:₹|rs\.?|inr\s*)\s*([0-9]+(?:[.,][0-9]+)?)', caseSensitive: false).firstMatch(text);
    if (match != null) return double.tryParse(match.group(1)!.replaceAll(',', ''));
    final generic = RegExp(r'\b([0-9]{2,}(?:[.,][0-9]+)?)\b').firstMatch(text);
    return generic == null ? null : double.tryParse(generic.group(1)!.replaceAll(',', ''));
  }

  String _category(String lower) {
    const categories = {
      'fuel': 'Fuel', 'petrol': 'Fuel', 'diesel': 'Fuel', 'grocery': 'Groceries',
      'groceries': 'Groceries', 'food': 'Food', 'restaurant': 'Food', 'medicine': 'Medical',
      'medical': 'Medical', 'rent': 'Rent', 'electricity': 'Bills', 'bill': 'Bills',
      'shopping': 'Shopping', 'travel': 'Travel', 'school': 'Education',
    };
    for (final entry in categories.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return 'Other';
  }

  String _dateKey(DateTime value) => '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

class IamyansiActionResult {
  final bool handled;
  final Map<String, dynamic>? record;
  const IamyansiActionResult._(this.handled, this.record);
  const IamyansiActionResult.unhandled() : this._(false, null);
  const IamyansiActionResult.handled(Map<String, dynamic> record) : this._(true, record);
}
