import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================
/// YANSI BRAIN
///
/// Yansi is not a chatbot.
/// Yansi is the intelligence layer connecting LifeOS.
///
/// Flow:
/// User speech
///     ↓
/// Understand
///     ↓
/// Identify intent
///     ↓
/// Read LifeOS memory
///     ↓
/// Decide action
///     ↓
/// Execute / ask confirmation
///     ↓
/// Respond
/// ============================================================

enum YansiIntent {
  expense,
  income,
  task,
  reminder,
  diary,
  calendar,
  queryFinance,
  queryTasks,
  queryDiary,
  queryLife,
  analysis,
  greeting,
  help,
  unknown,
}

enum YansiRisk {
  safe,
  confirmationRequired,
  sensitive,
}

class YansiDecision {
  final YansiIntent intent;
  final YansiRisk risk;

  final String originalText;
  final String response;

  final String category;
  final String item;

  final double? amount;

  final Map<String, dynamic> data;

  const YansiDecision({
    required this.intent,
    required this.risk,
    required this.originalText,
    required this.response,
    this.category = 'Other',
    this.item = '',
    this.amount,
    this.data = const {},
  });

  bool get requiresConfirmation =>
      risk != YansiRisk.safe;
}

/// ============================================================
/// YANSI BRAIN SERVICE
/// ============================================================

class YansiBrainService {
  static final YansiBrainService instance =
      YansiBrainService._internal();

  YansiBrainService._internal();

  factory YansiBrainService() {
    return instance;
  }

  /// ==========================================================
  /// MAIN ENTRY POINT
  /// ==========================================================

  Future<YansiDecision> think(String input) async {
    final text = input.trim();

    if (text.isEmpty) {
      return const YansiDecision(
        intent: YansiIntent.unknown,
        risk: YansiRisk.safe,
        originalText: '',
        response: 'I’m listening.',
      );
    }

    final command = text.toLowerCase();

    // ----------------------------------------------------------
    // GREETING
    // ----------------------------------------------------------

    if (_isGreeting(command)) {
      final name = await _getUserName();

      return YansiDecision(
        intent: YansiIntent.greeting,
        risk: YansiRisk.safe,
        originalText: text,
        response: name.isEmpty
            ? 'Hello. I’m here.'
            : 'Hello, $name. I’m here.',
      );
    }

    // ----------------------------------------------------------
    // EXPENSE
    // ----------------------------------------------------------

    final amount = _extractAmount(command);

    if (amount != null && _looksLikeExpense(command)) {
      final category = _detectCategory(command);
      final item = _detectItem(command);

      await _rememberLastIntent(
        'expense',
      );

      return YansiDecision(
        intent: YansiIntent.expense,
        risk: YansiRisk.safe,
        originalText: text,
        category: category,
        item: item,
        amount: amount,
        response:
            'I understand. This is a $category expense of ₹${amount.toStringAsFixed(0)}.',
        data: {
          'amount': amount,
          'category': category,
          'item': item,
        },
      );
    }

    // ----------------------------------------------------------
    // FINANCE QUESTIONS
    // ----------------------------------------------------------

    if (_isFinanceQuestion(command)) {
      final answer =
          await _analyzeFinance(command);

      return YansiDecision(
        intent: YansiIntent.queryFinance,
        risk: YansiRisk.safe,
        originalText: text,
        response: answer,
      );
    }

    // ----------------------------------------------------------
    // TASK
    // ----------------------------------------------------------

    if (_looksLikeTask(command)) {
      return YansiDecision(
        intent: YansiIntent.task,
        risk: YansiRisk.safe,
        originalText: text,
        item: text,
        response:
            'I understand. I can add that to your tasks.',
        data: {
          'task': text,
        },
      );
    }

    // ----------------------------------------------------------
    // REMINDER
    // ----------------------------------------------------------

    if (_looksLikeReminder(command)) {
      return YansiDecision(
        intent: YansiIntent.reminder,
        risk: YansiRisk.safe,
        originalText: text,
        item: text,
        response:
            'I understand. I can create that reminder.',
        data: {
          'reminder': text,
        },
      );
    }

    // ----------------------------------------------------------
    // DIARY
    // ----------------------------------------------------------

    if (_looksLikeDiary(command)) {
      return YansiDecision(
        intent: YansiIntent.diary,
        risk: YansiRisk.safe,
        originalText: text,
        item: text,
        response:
            'I understand. I can save that in your diary.',
        data: {
          'entry': text,
        },
      );
    }

    // ----------------------------------------------------------
    // TASK QUESTIONS
    // ----------------------------------------------------------

    if (_isTaskQuestion(command)) {
      final answer =
          await _analyzeTasks();

      return YansiDecision(
        intent: YansiIntent.queryTasks,
        risk: YansiRisk.safe,
        originalText: text,
        response: answer,
      );
    }

    // ----------------------------------------------------------
    // LIFE ANALYSIS
    // ----------------------------------------------------------

    if (_isAnalysisQuestion(command)) {
      final answer =
          await _analyzeLife();

      return YansiDecision(
        intent: YansiIntent.analysis,
        risk: YansiRisk.safe,
        originalText: text,
        response: answer,
      );
    }

    // ----------------------------------------------------------
    // HELP
    // ----------------------------------------------------------

    if (_isHelp(command)) {
      return const YansiDecision(
        intent: YansiIntent.help,
        risk: YansiRisk.safe,
        originalText: '',
        response:
            'I can help you manage your money, tasks, reminders, diary and other parts of your LifeOS. You can speak naturally and I’ll decide where your information belongs.',
      );
    }

    // ----------------------------------------------------------
    // UNKNOWN
    // ----------------------------------------------------------

    return YansiDecision(
      intent: YansiIntent.unknown,
      risk: YansiRisk.safe,
      originalText: text,
      response:
          'I understand what you said, but I need more intelligence connected to LifeOS to decide the best action.',
    );
  }

  // ============================================================
  // EXPENSE DETECTION
  // ============================================================

  bool _looksLikeExpense(String text) {
    return text.contains('spent') ||
        text.contains('spend') ||
        text.contains('paid') ||
        text.contains('purchase') ||
        text.contains('purchased') ||
        text.contains('bought') ||
        text.contains('buy') ||
        text.contains('expense') ||
        text.contains('cost me') ||
        text.contains('costs');
  }

  // ============================================================
  // AMOUNT
  // ============================================================

  double? _extractAmount(String text) {
    final cleaned = text.replaceAll(',', '');

    final rupee = RegExp(
      r'₹\s*(\d+(?:\.\d+)?)',
    ).firstMatch(cleaned);

    if (rupee != null) {
      return double.tryParse(
        rupee.group(1)!,
      );
    }

    final currency = RegExp(
      r'(\d+(?:\.\d+)?)\s*(?:rupees|rs|inr)',
    ).firstMatch(cleaned);

    if (currency != null) {
      return double.tryParse(
        currency.group(1)!,
      );
    }

    final number = RegExp(
      r'\b(\d+(?:\.\d+)?)\b',
    ).firstMatch(cleaned);

    if (number != null) {
      return double.tryParse(
        number.group(1)!,
      );
    }

    return null;
  }

  // ============================================================
  // CATEGORY INTELLIGENCE
  // ============================================================

  String _detectCategory(String text) {
    if (_containsAny(text, [
      'petrol',
      'fuel',
      'diesel',
      'cng',
      'gas station',
    ])) {
      return 'Fuel';
    }

    if (_containsAny(text, [
      'electricity',
      'electric bill',
      'power bill',
    ])) {
      return 'Electricity';
    }

    if (_containsAny(text, [
      'milk',
      'grocery',
      'groceries',
      'vegetables',
      'vegetable',
      'rice',
      'flour',
      'oil',
      'supermarket',
      'household',
    ])) {
      return 'Household';
    }

    if (_containsAny(text, [
      'restaurant',
      'food',
      'lunch',
      'dinner',
      'breakfast',
      'snack',
      'tea',
      'coffee',
      'pizza',
    ])) {
      return 'Food';
    }

    if (_containsAny(text, [
      'medicine',
      'medical',
      'doctor',
      'hospital',
      'pharmacy',
    ])) {
      return 'Health';
    }

    if (_containsAny(text, [
      'shopping',
      'clothes',
      'shirt',
      'dress',
      'shoes',
    ])) {
      return 'Shopping';
    }

    if (_containsAny(text, [
      'emi',
      'loan',
      'installment',
    ])) {
      return 'EMI';
    }

    if (_containsAny(text, [
      'mobile',
      'phone bill',
      'recharge',
      'internet',
      'wifi',
    ])) {
      return 'Communication';
    }

    if (_containsAny(text, [
      'school',
      'college',
      'course',
      'book',
      'education',
    ])) {
      return 'Education';
    }

    if (_containsAny(text, [
      'movie',
      'game',
      'entertainment',
    ])) {
      return 'Entertainment';
    }

    return 'Other';
  }

  String _detectItem(String text) {
    if (_containsAny(text, [
      'petrol',
      'fuel',
      'diesel',
      'cng',
    ])) {
      return 'Fuel';
    }

    if (text.contains('milk')) {
      return 'Milk';
    }

    if (_containsAny(text, [
      'electricity',
      'electric bill',
    ])) {
      return 'Electricity Bill';
    }

    if (_containsAny(text, [
      'restaurant',
      'lunch',
      'dinner',
      'breakfast',
    ])) {
      return 'Food';
    }

    return 'Expense';
  }

  // ============================================================
  // FINANCE INTELLIGENCE
  // ============================================================

  Future<String> _analyzeFinance(
    String question,
  ) async {
    final expenses =
        await _loadExpenses();

    if (expenses.isEmpty) {
      return 'I don’t have enough expense data yet. Start telling me about your spending and I’ll build your LifeOS financial picture.';
    }

    final now = DateTime.now();

    double todayTotal = 0;
    double monthTotal = 0;

    final Map<String, double> categories = {};

    for (final expense in expenses) {
      final amount =
          _toDouble(expense['amount']);

      final date =
          DateTime.tryParse(
        expense['date']?.toString() ?? '',
      );

      final category =
          expense['category']?.toString() ??
              'Other';

      if (amount == null || date == null) {
        continue;
      }

      if (_sameDay(date, now)) {
        todayTotal += amount;
      }

      if (date.year == now.year &&
          date.month == now.month) {
        monthTotal += amount;

        categories[category] =
            (categories[category] ?? 0) +
                amount;
      }
    }

    if (question.contains('today')) {
      return 'You have spent ₹${todayTotal.toStringAsFixed(0)} today.';
    }

    if (question.contains('fuel') ||
        question.contains('petrol')) {
      final fuel =
          categories['Fuel'] ?? 0;

      return 'Your Fuel spending this month is ₹${fuel.toStringAsFixed(0)}.';
    }

    if (question.contains('food')) {
      final food =
          categories['Food'] ?? 0;

      return 'Your Food spending this month is ₹${food.toStringAsFixed(0)}.';
    }

    if (question.contains('where') ||
        question.contains('too much') ||
        question.contains('highest') ||
        question.contains('spending')) {
      if (categories.isEmpty) {
        return 'I don’t have enough monthly data yet to identify your largest spending area.';
      }

      final sorted =
          categories.entries.toList()
            ..sort(
              (a, b) =>
                  b.value.compareTo(a.value),
            );

      final top = sorted.first;

      return 'Your highest spending category this month is ${top.key} at ₹${top.value.toStringAsFixed(0)}. Your total monthly spending is ₹${monthTotal.toStringAsFixed(0)}.';
    }

    return 'Your total spending this month is ₹${monthTotal.toStringAsFixed(0)}. Today you have spent ₹${todayTotal.toStringAsFixed(0)}.';
  }

  // ============================================================
  // LIFE ANALYSIS
  // ============================================================

  Future<String> _analyzeLife() async {
    final expenses =
        await _loadExpenses();

    final tasks =
        await _loadStringList(
      'lifeos_tasks',
    );

    final diary =
        await _loadStringList(
      'lifeos_diary',
    );

    final now = DateTime.now();

    double monthlyExpense = 0;

    for (final expense in expenses) {
      final amount =
          _toDouble(expense['amount']);

      final date =
          DateTime.tryParse(
        expense['date']?.toString() ?? '',
      );

      if (amount == null || date == null) {
        continue;
      }

      if (date.year == now.year &&
          date.month == now.month) {
        monthlyExpense += amount;
      }
    }

    return 'Here is your current LifeOS picture. '
        'This month I have recorded ₹${monthlyExpense.toStringAsFixed(0)} '
        'of spending, ${tasks.length} task entries and '
        '${diary.length} diary entries. '
        'As you use LifeOS more, I’ll be able to identify patterns and give you more useful recommendations.';
  }

  // ============================================================
  // TASK ANALYSIS
  // ============================================================

  Future<String> _analyzeTasks() async {
    final tasks =
        await _loadStringList(
      'lifeos_tasks',
    );

    if (tasks.isEmpty) {
      return 'You currently have no tasks stored in LifeOS.';
    }

    return 'You currently have ${tasks.length} task entries in LifeOS.';
  }

  // ============================================================
  // STORAGE
  // ============================================================

  Future<List<Map<String, dynamic>>>
      _loadExpenses() async {
    final prefs =
        await SharedPreferences.getInstance();

    final raw =
        prefs.getString(
      'lifeos_expenses',
    );

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded =
          jsonDecode(raw);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                Map<String, dynamic>.from(
              item,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<String>> _loadStringList(
    String key,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getStringList(key) ?? [];
  }

  // ============================================================
  // MEMORY
  // ============================================================

  Future<void> _rememberLastIntent(
    String intent,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      'yansi_last_intent',
      intent,
    );

    await prefs.setString(
      'yansi_last_interaction',
      DateTime.now().toIso8601String(),
    );
  }

  Future<String> _getUserName() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString('profile_name') ??
        prefs.getString('user_name') ??
        prefs.getString('name') ??
        '';
  }

  // ============================================================
  // INTENT DETECTION
  // ============================================================

  bool _isGreeting(String text) {
    return text == 'hi' ||
        text == 'hello' ||
        text.contains('hi yansi') ||
        text.contains('hello yansi') ||
        text.contains('good morning') ||
        text.contains('good evening');
  }

  bool _isHelp(String text) {
    return text.contains('what can you do') ||
        text.contains('help me') ||
        text == 'help';
  }

  bool _isFinanceQuestion(String text) {
    return text.contains('how much') ||
        text.contains('spent') ||
        text.contains('spending') ||
        text.contains('expense') ||
        text.contains('expenses') ||
        text.contains('fuel') ||
        text.contains('petrol') ||
        text.contains('food') ||
        text.contains('money') ||
        text.contains('save money') ||
        text.contains('where am i spending');
  }

  bool _isTaskQuestion(String text) {
    return text.contains('my tasks') ||
        text.contains('what do i have to do') ||
        text.contains('what should i do today') ||
        text.contains('pending tasks');
  }

  bool _isAnalysisQuestion(String text) {
    return text.contains('analyze') ||
        text.contains('analyse') ||
        text.contains('pattern') ||
        text.contains('too much') ||
        text.contains('improve my life') ||
        text.contains('where can i save') ||
        text.contains('recommend');
  }

  bool _looksLikeTask(String text) {
    return text.contains('add a task') ||
        text.contains('todo') ||
        text.contains('to do') ||
        text.contains('need to') ||
        text.contains('have to do');
  }

  bool _looksLikeReminder(String text) {
    return text.contains('remind me') ||
        text.contains('reminder') ||
        text.contains('remember to');
  }

  bool _looksLikeDiary(String text) {
    return text.contains('diary') ||
        text.contains('journal') ||
        text.contains('i feel') ||
        text.contains('today was') ||
        text.contains('today i');
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool _containsAny(
    String text,
    List<String> values,
  ) {
    for (final value in values) {
      if (text.contains(value)) {
        return true;
      }
    }

    return false;
  }

  bool _sameDay(
    DateTime a,
    DateTime b,
  ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    );
  }
}
