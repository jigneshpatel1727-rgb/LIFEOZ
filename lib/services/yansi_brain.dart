import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

part 'yansi_brain_compat.dart';

/// Yansi's local-first intelligence gateway.
///
/// The UI talks to this class instead of knowing how LifeOS data is stored.
/// It supports natural commands, structured records, lightweight context,
/// behavioural observations and explainable predictions. A future remote AI
/// provider can sit behind the same interface without changing the UI.
enum YansiIntent {
  expense,
  income,
  task,
  reminder,
  household,
  diary,
  goal,
  question,
  unknown,
}

class YansiResult {
  final YansiIntent intent;
  final String originalText;
  final String category;
  final double? amount;
  final String? item;
  final String response;
  final Map<String, dynamic> data;

  const YansiResult({
    required this.intent,
    required this.originalText,
    required this.category,
    required this.amount,
    required this.item,
    required this.response,
    required this.data,
  });
}

class YansiBrain {
  static const _historyKey = 'yansi_conversation_history';
  static const _voiceKey = 'yansi_voice_history';
  static const _expenseKey = 'yansi_expenses';
  static const _incomeKey = 'yansi_income';
  static const _taskKey = 'yansi_tasks';
  static const _reminderKey = 'yansi_reminders';
  static const _householdKey = 'yansi_household';
  static const _goalKey = 'yansi_goals';
  static const _diaryKey = 'yansi_diary';

  final SharedPreferences prefs;
  YansiBrain({required this.prefs});

  Future<YansiResult> process(String input, {String? voicePath}) async {
    final text = input.trim();
    if (text.isEmpty) {
      return const YansiResult(
        intent: YansiIntent.unknown,
        originalText: '',
        category: 'Unknown',
        amount: null,
        item: null,
        response: 'I did not hear anything.',
        data: {},
      );
    }

    final lower = text.toLowerCase();
    await _saveConversation('user', text);
    if (voicePath != null && voicePath.trim().isNotEmpty) {
      await _saveVoice(text, voicePath.trim());
    }

    late YansiResult result;
    if (_containsAny(lower, ['spent ', 'spend ', 'paid ', 'bought ', 'purchase ', 'expense', 'cost me', 'bill paid'])) {
      result = await _expense(text, lower);
    } else if (_containsAny(lower, ['received ', 'salary', 'income', 'earned ', 'got paid', 'commission', 'bonus'])) {
      result = await _income(text, lower);
    } else if (_containsAny(lower, ['remind me', 'reminder', 'remember this', 'due tomorrow', 'due on', 'appointment'])) {
      result = await _reminder(text);
    } else if (_containsAny(lower, ['task', 'need to', 'have to', 'must do', 'do today', 'finish ', 'complete ', 'work on'])) {
      result = await _task(text);
    } else if (_containsAny(lower, ['grocery', 'groceries', 'shopping', 'milk', 'vegetable', 'rice', 'flour', 'oil', 'household', 'kitchen'])) {
      result = await _household(text);
    } else if (_containsAny(lower, ['my goal', 'goal is', 'target', 'save for', 'want to achieve', 'plan to', 'dream'])) {
      result = await _goal(text);
    } else if (_containsAny(lower, ['today i', 'today was', 'i feel', 'i am feeling', 'my day', 'diary', 'journal'])) {
      result = await _diary(text);
    } else {
      result = await _answerQuestion(text, lower);
    }

    await _saveConversation('yansi', result.response);
    return result;
  }

  Future<YansiResult> _answerQuestion(String text, String lower) async {
    if (_containsAny(lower, ['budget', 'monthly budget', 'how much should i spend'])) {
      final report = _budgetSnapshot();
      return _question(text, 'Money', report['total'] as double == 0
          ? 'I can prepare your monthly budget as soon as I have some income and spending history. Tell me your monthly income and I will build a starting plan.'
          : 'Based on your stored history, your recent monthly spending is about ${_money(report['average'] as double)}. I can use that pattern with your income, goals and upcoming bills to build a monthly plan.', report);
    }

    if (_containsAny(lower, ['household', 'what should i buy', 'shopping list', 'grocery list', 'next month'])) {
      final items = _readRecords(_householdKey);
      final counts = <String, int>{};
      for (final r in items) {
        final item = (r['item'] ?? '').toString().trim().toLowerCase();
        if (item.isNotEmpty) counts[item] = (counts[item] ?? 0) + 1;
      }
      final top = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final names = top.take(6).map((e) => e.key).toList();
      return _question(text, 'Household', names.isEmpty
          ? 'I do not have enough household history yet. Keep telling me what you buy and I will learn your recurring requirements.'
          : 'I see these recurring household items in your history: ${names.join(', ')}. I can use their purchase pattern to prepare a predicted monthly list.', {'predictedItems': names});
    }

    if (_containsAny(lower, ['why am i spending', 'spending too much', 'behaviour', 'behavior', 'good or bad', 'what am i doing wrong', 'what should i improve'])) {
      return _behaviourAnswer(text);
    }

    if (_containsAny(lower, ['what is my status', 'how am i doing', 'how are we doing', 'life report', 'overall report'])) {
      final b = _budgetSnapshot();
      final tasks = _readRecords(_taskKey);
      final openTasks = tasks.where((r) => r['completed'] != true).length;
      final line = b['total'] as double == 0
          ? 'I need more financial history before I can judge your money trend.'
          : 'Your stored spending average is around ${_money(b['average'] as double)} per month.';
      return _question(text, 'Life Overview', '$line You currently have $openTasks open task${openTasks == 1 ? '' : 's'}. I can connect these patterns as more LifeOS data builds up.', {'openTasks': openTasks, 'monthlyAverage': b['average']});
    }

    final friendly = _friendlyTone(lower);
    return _question(text, 'Conversation', friendly
        ? 'Absolutely. I am with you. Tell me what you are thinking, and I will help you work through it using your LifeOS context.'
        : 'I understand. I can reason about your LifeOS information and help you work through the question. If it needs current external information, that can be connected through an approved web service.', {'text': text});
  }

  YansiResult _behaviourAnswer(String text) {
    final expenses = _readRecords(_expenseKey);
    if (expenses.length < 2) {
      return _question(text, 'Behaviour', 'I need a little more history before I make a behaviour judgement. I will look for patterns rather than judging individual choices.', {'sampleSize': expenses.length});
    }
    final totals = <String, double>{};
    for (final r in expenses) {
      final category = (r['category'] ?? 'Other').toString();
      totals[category] = (totals[category] ?? 0) + ((r['amount'] as num?)?.toDouble() ?? 0);
    }
    final ranked = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = ranked.first;
    final tone = top.value > 0 ? 'Your largest stored spending area is ${top.key} at about ${_money(top.value)} in the available history.' : 'Your stored spending is still too small to identify a reliable pattern.';
    return _question(text, 'Behaviour', '$tone I will treat this as a pattern, not a judgement, and refine the recommendation as more data arrives.', {'topCategory': top.key, 'topAmount': top.value, 'categories': totals});
  }

  Future<YansiResult> _expense(String text, String lower) async {
    final amount = _extractAmount(text);
    final category = _expenseCategory(lower);
    final record = _record('expense', {
      'amount': amount ?? 0,
      'category': category,
      'text': text,
      'source': 'voice_or_text',
    });
    await _append(_expenseKey, record);
    return _result(YansiIntent.expense, text, category, amount, category, amount == null ? 'Got it. I recorded that expense under $category.' : 'Got it. I added ${_money(amount)} to $category for today.', record);
  }

  Future<YansiResult> _income(String text, String lower) async {
    final amount = _extractAmount(text);
    final category = _containsAny(lower, ['salary']) ? 'Salary' : _containsAny(lower, ['commission']) ? 'Commission' : 'Income';
    final record = _record('income', {'amount': amount ?? 0, 'category': category, 'text': text, 'source': 'voice_or_text'});
    await _append(_incomeKey, record);
    return _result(YansiIntent.income, text, category, amount, null, amount == null ? 'Got it. I recorded that income.' : 'Done. I recorded ${_money(amount)} as $category.', record);
  }

  Future<YansiResult> _task(String text) async {
    final record = _record('task', {'task': _cleanTask(text), 'completed': false, 'source': 'voice_or_text'});
    await _append(_taskKey, record);
    return _result(YansiIntent.task, text, 'Productivity', null, record['task'] as String, 'Got it. I added that to your tasks.', record);
  }

  Future<YansiResult> _reminder(String text) async {
    final record = _record('reminder', {'text': text, 'source': 'voice_or_text'});
    await _append(_reminderKey, record);
    return _result(YansiIntent.reminder, text, 'Calendar', null, text, 'Understood. I saved that as a reminder.', record);
  }

  Future<YansiResult> _household(String text) async {
    final item = _householdItem(text);
    final record = _record('household', {'item': item, 'text': text, 'source': 'voice_or_text'});
    await _append(_householdKey, record);
    return _result(YansiIntent.household, text, 'Household', null, item, 'Got it. I added $item to your household list.', record);
  }

  Future<YansiResult> _goal(String text) async {
    final record = _record('goal', {'goal': text, 'source': 'voice_or_text'});
    await _append(_goalKey, record);
    return _result(YansiIntent.goal, text, 'Goals', null, text, 'Got it. I saved that as one of your goals.', record);
  }

  Future<YansiResult> _diary(String text) async {
    final record = _record('diary', {'text': text, 'source': 'voice_or_text'});
    await _append(_diaryKey, record);
    return _result(YansiIntent.diary, text, 'Diary', null, text, 'I saved that in your personal diary.', record);
  }

  YansiResult _question(String text, String category, String response, [Map<String, dynamic>? data]) => _result(YansiIntent.question, text, category, null, null, response, data ?? {'text': text});

  YansiResult _result(YansiIntent intent, String text, String category, double? amount, String? item, String response, Map<String, dynamic> data) => YansiResult(intent: intent, originalText: text, category: category, amount: amount, item: item, response: response, data: data);

  Map<String, dynamic> _budgetSnapshot() {
    final records = _readRecords(_expenseKey);
    if (records.isEmpty) return {'total': 0.0, 'average': 0.0};
    final monthTotals = <String, double>{};
    for (final r in records) {
      final date = DateTime.tryParse((r['date'] ?? '').toString()) ?? DateTime.now();
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      monthTotals[key] = (monthTotals[key] ?? 0) + ((r['amount'] as num?)?.toDouble() ?? 0);
    }
    final values = monthTotals.values.toList();
    final average = values.fold<double>(0, (a, b) => a + b) / values.length;
    return {'total': records.fold<double>(0, (a, r) => a + ((r['amount'] as num?)?.toDouble() ?? 0)), 'average': average, 'months': monthTotals};
  }

  Map<String, dynamic> _record(String type, Map<String, dynamic> values) => {'id': DateTime.now().microsecondsSinceEpoch.toString(), 'type': type, ...values, 'date': DateTime.now().toIso8601String()};

  List<Map<String, dynamic>> _readRecords(String key) {
    final raw = prefs.getStringList(key) ?? <String>[];
    return raw.map((v) { try { return Map<String, dynamic>.from(jsonDecode(v) as Map); } catch (_) { return <String, dynamic>{}; } }).where((m) => m.isNotEmpty).toList();
  }

  Future<void> _append(String key, Map<String, dynamic> record) async {
    final raw = prefs.getStringList(key) ?? <String>[];
    raw.add(jsonEncode(record));
    await prefs.setStringList(key, raw);
  }

  Future<void> _saveConversation(String role, String text) async {
    final raw = prefs.getStringList(_historyKey) ?? <String>[];
    raw.add(jsonEncode({'role': role, 'text': text, 'date': DateTime.now().toIso8601String()}));
    if (raw.length > 200) raw.removeRange(0, raw.length - 200);
    await prefs.setStringList(_historyKey, raw);
  }

  Future<void> _saveVoice(String transcript, String path) async {
    if (!(prefs.getBool('save_voice_history') ?? false)) return;
    final raw = prefs.getStringList(_voiceKey) ?? <String>[];
    raw.add(jsonEncode({'transcript': transcript, 'path': path, 'date': DateTime.now().toIso8601String()}));
    await prefs.setStringList(_voiceKey, raw);
  }

  double? _extractAmount(String text) {
    final cleaned = text.replaceAll(',', '').replaceAll('₹', '').replaceAll('\$', '');
    for (final p in [RegExp(r'(?:rs\.?|inr|rupees?)\s*(\d+(?:\.\d+)?)', caseSensitive: false), RegExp(r'(\d+(?:\.\d+)?)\s*(?:rs|inr|rupees)', caseSensitive: false), RegExp(r'(\d+(?:\.\d+)?)')]) {
      final m = p.firstMatch(cleaned);
      if (m != null) return double.tryParse(m.group(1)!);
    }
    return null;
  }

  String _expenseCategory(String text) {
    if (_containsAny(text, ['petrol', 'fuel', 'diesel', 'cng'])) return 'Fuel';
    if (_containsAny(text, ['grocery', 'groceries', 'vegetable', 'rice', 'flour', 'milk', 'kitchen'])) return 'Household';
    if (_containsAny(text, ['food', 'restaurant', 'lunch', 'dinner', 'breakfast', 'coffee'])) return 'Food';
    if (_containsAny(text, ['electricity', 'water bill', 'gas bill', 'internet', 'recharge'])) return 'Bills';
    if (_containsAny(text, ['medicine', 'doctor', 'hospital'])) return 'Health';
    if (_containsAny(text, ['school', 'education', 'course'])) return 'Education';
    if (_containsAny(text, ['share', 'stock', 'mutual fund', 'investment'])) return 'Investment';
    return 'Other';
  }

  String _householdItem(String text) {
    final lower = text.toLowerCase();
    for (final item in ['milk', 'rice', 'wheat', 'flour', 'oil', 'vegetables', 'vegetable', 'detergent', 'soap', 'coffee', 'tea', 'sugar']) {
      if (lower.contains(item)) return item;
    }
    final cleaned = text.replaceAll(RegExp(r'^(add|buy|get|purchase|remind me to)\s+', caseSensitive: false), '').trim();
    return cleaned.isEmpty ? 'household item' : cleaned;
  }

  String _cleanTask(String text) => text.replaceFirst(RegExp(r'^(add|create|make)\s+(a\s+)?task\s+(to\s+)?', caseSensitive: false), '').trim();

  bool _friendlyTone(String text) => _containsAny(text, ['yaar', 'buddy', 'friend', 'bro', 'haha', 'please', 'thanks', 'thank you', '😊', '😂']);

  bool _containsAny(String text, List<String> words) => words.any(text.contains);

  String _money(double value) {
    final symbol = prefs.getString('currency_symbol') ?? prefs.getString('currency') ?? '₹';
    return '$symbol${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
  }
}
