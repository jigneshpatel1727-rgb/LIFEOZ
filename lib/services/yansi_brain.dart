import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================
/// YANSI BRAIN
/// ============================================================
///
/// Local intelligence layer for LifeOS.
///
/// Voice/text
///     ↓
/// Intent detection
///     ↓
/// Structured LifeOS record
///     ↓
/// Persistent memory
///
/// This is the first local intelligence layer.
/// Later this same interface can be connected to a more powerful
/// AI model without changing the LifeOS UI.
/// ============================================================

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
  final SharedPreferences prefs;

  YansiBrain({
    required this.prefs,
  });

  // ==========================================================
  // MAIN PROCESSOR
  // ==========================================================

  Future<YansiResult> process(
    String input,
  ) async {
    final text =
        input.trim();

    if (text.isEmpty) {
      return const YansiResult(
        intent:
            YansiIntent.unknown,
        originalText: '',
        category: 'Unknown',
        amount: null,
        item: null,
        response:
            'I did not hear anything.',
        data: {},
      );
    }

    final lower =
        text.toLowerCase();

    // --------------------------------------------------------
    // EXPENSE
    // --------------------------------------------------------

    if (_isExpense(lower)) {
      return _processExpense(
        text,
        lower,
      );
    }

    // --------------------------------------------------------
    // INCOME
    // --------------------------------------------------------

    if (_isIncome(lower)) {
      return _processIncome(
        text,
        lower,
      );
    }

    // --------------------------------------------------------
    // TASK
    // --------------------------------------------------------

    if (_isTask(lower)) {
      return _processTask(
        text,
      );
    }

    // --------------------------------------------------------
    // REMINDER
    // --------------------------------------------------------

    if (_isReminder(lower)) {
      return _processReminder(
        text,
      );
    }

    // --------------------------------------------------------
    // HOUSEHOLD
    // --------------------------------------------------------

    if (_isHousehold(lower)) {
      return _processHousehold(
        text,
      );
    }

    // --------------------------------------------------------
    // GOAL
    // --------------------------------------------------------

    if (_isGoal(lower)) {
      return _processGoal(
        text,
      );
    }

    // --------------------------------------------------------
    // DIARY
    // --------------------------------------------------------

    if (_isDiary(lower)) {
      return _processDiary(
        text,
      );
    }

    // --------------------------------------------------------
    // QUESTION
    // --------------------------------------------------------

    return YansiResult(
      intent:
          YansiIntent.question,
      originalText: text,
      category: 'Conversation',
      amount: null,
      item: null,
      response:
          'I heard you. I can help you think through that, and I will keep the conversation connected to your LifeOS context.',
      data: {
        'text': text,
      },
    );
  }

  // ==========================================================
  // EXPENSE
  // ==========================================================

  Future<YansiResult> _processExpense(
    String text,
    String lower,
  ) async {
    final amount =
        _extractAmount(text);

    final category =
        _detectExpenseCategory(
      lower,
    );

    final record = {
      'id':
          DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
      'type': 'expense',
      'amount':
          amount ?? 0,
      'category':
          category,
      'text':
          text,
      'date':
          DateTime.now()
              .toIso8601String(),
      'source':
          'voice',
    };

    await _saveRecord(
      'yansi_expenses',
      record,
    );

    final amountText =
        amount == null
            ? 'that expense'
            : _money(amount);

    return YansiResult(
      intent:
          YansiIntent.expense,
      originalText: text,
      category: category,
      amount: amount,
      item: category,
      response:
          'Got it. I added $amountText to $category for today.',
      data: record,
    );
  }

  // ==========================================================
  // INCOME
  // ==========================================================

  Future<YansiResult> _processIncome(
    String text,
    String lower,
  ) async {
    final amount =
        _extractAmount(text);

    final record = {
      'id':
          DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
      'type': 'income',
      'amount':
          amount ?? 0,
      'category':
          _detectIncomeCategory(
        lower,
      ),
      'text':
          text,
      'date':
          DateTime.now()
              .toIso8601String(),
      'source':
          'voice',
    };

    await _saveRecord(
      'yansi_income',
      record,
    );

    final amountText =
        amount == null
            ? 'the income'
            : _money(amount);

    return YansiResult(
      intent:
          YansiIntent.income,
      originalText: text,
      category:
          record['category']
              .toString(),
      amount: amount,
      item: null,
      response:
          'Got it. I recorded $amountText as income.',
      data: record,
    );
  }

  // ==========================================================
  // TASK
  // ==========================================================

  Future<YansiResult> _processTask(
    String text,
  ) async {
    final record = {
      'id':
          DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
      'type': 'task',
      'task':
          _cleanTaskText(text),
      'completed':
          false,
      'date':
          DateTime.now()
              .toIso8601String(),
      'source':
          'voice',
    };

    await _saveRecord(
      'yansi_tasks',
      record,
    );

    return YansiResult(
      intent:
          YansiIntent.task,
      originalText: text,
      category:
          'Productivity',
      amount: null,
      item:
          record['task']
              .toString(),
      response:
          'Got it. I added that to your tasks.',
      data: record,
    );
  }

  // ==========================================================
  // REMINDER
  // ==========================================================

  Future<YansiResult> _processReminder(
    String text,
  ) async {
    final record = {
      'id':
          DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
      'type':
          'reminder',
      'text':
          text,
      'date':
          DateTime.now()
              .toIso8601String(),
      'source':
          'voice',
    };

    await _saveRecord(
      'yansi_reminders',
      record,
    );

    return YansiResult(
      intent:
          YansiIntent.reminder,
      originalText: text,
      category:
          'Calendar',
      amount: null,
      item: text,
      response:
          'Understood. I saved that as a reminder.',
      data: record,
    );
  }

  // ==========================================================
  // HOUSEHOLD
  // ==========================================================

  Future<YansiResult> _processHousehold(
    String text,
  ) async {
    final item =
        _extractHouseholdItem(
      text,
    );

    final record = {
      'id':
          DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
      'type':
          'household',
      'item':
          item,
      'text':
          text,
      'date':
          DateTime.now()
              .toIso8601String(),
      'source':
          'voice',
    };

    await _saveRecord(
      'yansi_household',
      record,
    );

    return YansiResult(
      intent:
          YansiIntent.household,
      originalText: text,
      category:
          'Household',
      amount: null,
      item: item,
      response:
          'Got it. I added $item to your household list.',
      data: record,
    );
  }

  // ==========================================================
  // GOAL
  // ==========================================================

  Future<YansiResult> _processGoal(
    String text,
  ) async {
    final record = {
      'id':
          DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
      'type':
          'goal',
      'goal':
          text,
      'date':
          DateTime.now()
              .toIso8601String(),
      'source':
          'voice',
    };

    await _saveRecord(
      'yansi_goals',
      record,
    );

    return YansiResult(
      intent:
          YansiIntent.goal,
      originalText: text,
      category:
          'Goals',
      amount: null,
      item: text,
      response:
          'Got it. I saved that as one of your goals.',
      data: record,
    );
  }

  // ==========================================================
  // DIARY
  // ==========================================================

  Future<YansiResult> _processDiary(
    String text,
  ) async {
    final record = {
      'id':
          DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
      'type':
          'diary',
      'text':
          text,
      'date':
          DateTime.now()
              .toIso8601String(),
      'source':
          'voice',
    };

    await _saveRecord(
      'yansi_diary',
      record,
    );

    return YansiResult(
      intent:
          YansiIntent.diary,
      originalText: text,
      category:
          'Diary',
      amount: null,
      item: text,
      response:
          'I saved that in your personal diary.',
      data: record,
    );
  }

  // ==========================================================
  // INTENT DETECTION
  // ==========================================================

  bool _isExpense(
    String text,
  ) {
    return _containsAny(
      text,
      [
        'spent',
        'spend',
        'paid',
        'payment',
        'bought',
        'purchase',
        'expense',
        'cost me',
        'bill paid',
      ],
    );
  }

  bool _isIncome(
    String text,
  ) {
    return _containsAny(
      text,
      [
        'received',
        'salary',
        'income',
        'earned',
        'got paid',
        'commission',
        'bonus',
      ],
    );
  }

  bool _isTask(
    String text,
  ) {
    return _containsAny(
      text,
      [
        'task',
        'need to',
        'have to',
        'must do',
        'do today',
        'finish',
        'complete',
        'work on',
      ],
    );
  }

  bool _isReminder(
    String text,
  ) {
    return _containsAny(
      text,
      [
        'remind me',
        'reminder',
        'remember',
        'due tomorrow',
        'due on',
        'appointment',
      ],
    );
  }

  bool _isHousehold(
    String text,
  ) {
    return _containsAny(
      text,
      [
        'grocery',
        'groceries',
        'shopping',
        'milk',
        'vegetables',
        'vegetable',
        'rice',
        'flour',
        'oil',
        'household',
        'kitchen',
      ],
    );
  }

  bool _isGoal(
    String text,
  ) {
    return _containsAny(
      text,
      [
        'my goal',
        'goal is',
        'target',
        'save for',
        'want to achieve',
        'plan to',
        'dream',
      ],
    );
  }

  bool _isDiary(
    String text) {
    return _containsAny(
      text,
      [
        'today I',
        'today was',
        'I feel',
        'I am feeling',
        'my day',
        'diary',
        'journal',
        'something happened',
      ],
    );
  }

  bool _containsAny(
    String text,
    List<String> words,
  ) {
    for (final word in words) {
      if (text.contains(word)) {
        return true;
      }
    }

    return false;
  }

  // ==========================================================
  // AMOUNT EXTRACTION
  // ==========================================================

  double? _extractAmount(
    String text,
  ) {
    final cleaned =
        text
            .replaceAll(
              ',',
              '',
            )
            .replaceAll(
              '₹',
              '',
            )
            .replaceAll(
              '\$',
              '',
            );

    final patterns = [
      RegExp(
        r'(?:rs\.?|inr|rupees?)\s*(\d+(?:\.\d+)?)',
        caseSensitive:
            false,
      ),
      RegExp(
        r'(\d+(?:\.\d+)?)\s*(?:rs|inr|rupees)',
        caseSensitive:
            false,
      ),
      RegExp(
        r'(\d+(?:\.\d+)?)',
      ),
    ];

    for (final pattern
        in patterns) {
      final match =
          pattern.firstMatch(
        cleaned,
      );

      if (match != null) {
        final value =
            double.tryParse(
          match.group(1)!,
        );

        if (value != null) {
          return value;
        }
      }
    }

    return null;
  }

  // ==========================================================
  // EXPENSE CATEGORY
  // ==========================================================

  String _detectExpenseCategory(
    String text,
  ) {
    if (_containsAny(
      text,
      [
        'petrol',
        'fuel',
        'diesel',
        'cng',
        'gas',
      ],
    )) {
      return 'Fuel';
    }

    if (_containsAny(
      text,
      [
        'grocery',
        'groceries',
        'vegetable',
        'milk',
        'rice',
        'food',
        'kitchen',
      ],
    )) {
      return 'Household';
    }

    if (_containsAny(
      text,
      [
        'restaurant',
        'hotel',
        'lunch',
        'dinner',
        'breakfast',
        'coffee',
      ],
    )) {
      return 'Food';
    }

    if (_containsAny(
      text,
      [
        'electricity',
        'water bill',
        'gas bill',
        'internet',
        'mobile bill',
      ],
    )) {
      return 'Bills';
    }

    if (_containsAny(
      text,
      [
        'medicine',
        'doctor',
        'hospital',
        'medical',
      ],
    )) {
      return 'Medical';
    }

    if (_containsAny(
      text,
      [
        'school',
        'college',
        'education',
        'fees',
      ],
    )) {
      return 'Education';
    }

    if (_containsAny(
      text,
      [
        'shopping',
        'shirt',
        'clothes',
        'dress',
        'shoe',
      ],
    )) {
      return 'Shopping';
    }

    if (_containsAny(
      text,
      [
        'rent',
        'house rent',
      ],
    )) {
      return 'Rent';
    }

    if (_containsAny(
      text,
      [
        'insurance',
        'policy',
        'premium',
      ],
    )) {
      return 'Insurance';
    }

    return 'Other';
  }

  // ==========================================================
  // INCOME CATEGORY
  // ==========================================================

  String _detectIncomeCategory(
    String text,
  ) {
    if (_containsAny(
      text,
      [
        'salary',
      ],
    )) {
      return 'Salary';
    }

    if (_containsAny(
      text,
      [
        'commission',
      ],
    )) {
      return 'Commission';
    }

    if (_containsAny(
      text,
      [
        'bonus',
      ],
    )) {
      return 'Bonus';
    }

    return 'Other Income';
  }

  // ==========================================================
  // CLEAN TASK
  // ==========================================================

  String _cleanTaskText(
    String text,
  ) {
    return text
        .replaceFirst(
          RegExp(
            r'^(yansi[,\s]*)?',
            caseSensitive:
                false,
          ),
          '',
        )
        .trim();
  }

  // ==========================================================
  // HOUSEHOLD ITEM
  // ==========================================================

  String _extractHouseholdItem(
    String text,
  ) {
    final lower =
        text.toLowerCase();

    const knownItems = [
      'milk',
      'rice',
      'oil',
      'flour',
      'sugar',
      'vegetables',
      'vegetable',
      'bread',
      'eggs',
      'eggs',
      'soap',
      'detergent',
      'toothpaste',
      'shampoo',
      'groceries',
    ];

    for (final item
        in knownItems) {
      if (lower.contains(item)) {
        return item;
      }
    }

    return text;
  }

  // ==========================================================
  // SAVE RECORD
  // ==========================================================

  Future<void> _saveRecord(
    String key,
    Map<String, dynamic> record,
  ) async {
    final existing =
        prefs.getStringList(
              key,
            ) ??
            <String>[];

    existing.add(
      jsonEncode(
        record,
      ),
    );

    await prefs.setStringList(
      key,
      existing,
    );

    // --------------------------------------------------------
    // MASTER YANSI MEMORY
    // --------------------------------------------------------

    final memory =
        prefs.getStringList(
              'yansi_memory',
            ) ??
            <String>[];

    memory.add(
      jsonEncode(
        record,
      ),
    );

    await prefs.setStringList(
      'yansi_memory',
      memory,
    );
  }

  // ==========================================================
  // MONEY DISPLAY
  // ==========================================================

  String _money(
    double amount,
  ) {
    final currency =
        prefs.getString(
              'currency',
            ) ??
            '₹';

    if (amount ==
        amount.roundToDouble()) {
      return '$currency${amount.toInt()}';
    }

    return '$currency${amount.toStringAsFixed(2)}';
  }

  // ==========================================================
  // MEMORY ACCESS
  // ==========================================================

  Future<List<Map<String, dynamic>>>
      getMemory() async {
    final records =
        prefs.getStringList(
              'yansi_memory',
            ) ??
            <String>[];

    final result =
        <Map<String, dynamic>>[];

    for (final item
        in records) {
      try {
        final decoded =
            jsonDecode(item);

        if (decoded
            is Map<String, dynamic>) {
          result.add(
            decoded,
          );
        }
      } catch (_) {}
    }

    return result;
  }

  // ==========================================================
  // MEMORY SUMMARY
  // ==========================================================

  Future<Map<String, dynamic>>
      getSummary() async {
    final memory =
        await getMemory();

    double expenses = 0;

    double income = 0;

    int tasks = 0;

    int diary = 0;

    int household = 0;

    for (final record
        in memory) {
      final type =
          record['type']
              ?.toString();

      final amount =
          (record['amount']
                  as num?)
              ?.toDouble() ??
          0;

      if (type ==
          'expense') {
        expenses += amount;
      }

      if (type ==
          'income') {
        income += amount;
      }

      if (type ==
          'task') {
        tasks++;
      }

      if (type ==
          'diary') {
        diary++;
      }

      if (type ==
          'household') {
        household++;
      }
    }

    return {
      'records':
          memory.length,
      'expenses':
          expenses,
      'income':
          income,
      'balance':
          income - expenses,
      'tasks':
          tasks,
      'diary':
          diary,
      'household':
          household,
    };
  }
}
