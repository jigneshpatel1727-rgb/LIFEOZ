import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'expense_screen.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final TextEditingController _controller =
      TextEditingController();

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          'Hello! I am LifeOS AI. Ask me about your expenses, savings or spending.',
      isUser: false,
    ),
  ];

  bool _isThinking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // SEND MESSAGE
  // ------------------------------------------------------------

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty || _isThinking) {
      return;
    }

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: true,
        ),
      );

      _controller.clear();
      _isThinking = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    final response =
        await _processMessage(text);

    if (!mounted) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: response,
          isUser: false,
        ),
      );

      _isThinking = false;
    });
  }

  // ------------------------------------------------------------
  // PROCESS USER MESSAGE
  // ------------------------------------------------------------

  Future<String> _processMessage(
    String text,
  ) async {
    final message = text.toLowerCase();

    // Add expense
    final expenseResult =
        await _tryAddExpense(text);

    if (expenseResult != null) {
      return expenseResult;
    }

    // Monthly expense
    if (message.contains('this month') ||
        message.contains('monthly') ||
        message.contains('month')) {
      final data =
          await _readExpenses();

      final total =
          _monthlyTotal(data);

      return
          'Your LifeOS expenses this month are '
          '₹${total.toStringAsFixed(0)}.';
    }

    // Total expense
    if (message.contains('total expense') ||
        message.contains('total spending') ||
        message.contains('all expenses')) {
      final data =
          await _readExpenses();

      final total =
          _totalExpenses(data);

      return
          'Your total recorded expenses are '
          '₹${total.toStringAsFixed(0)}.';
    }

    // Biggest spending
    if (message.contains('biggest') ||
        message.contains('highest') ||
        message.contains('too much') ||
        message.contains('spending too much')) {
      return await _spendingAnalysis();
    }

    // Report
    if (message.contains('report') ||
        message.contains('summary')) {
      return await _generateReport();
    }

    // Savings
    if (message.contains('saving') ||
        message.contains('savings')) {
      final prefs =
          await SharedPreferences.getInstance();

      final income =
          prefs.getDouble(
                'lifeos_monthly_income',
              ) ??
              0;

      final expenses =
          _monthlyTotal(
        await _readExpenses(),
      );

      final savings =
          income - expenses;

      return
          'Monthly income: ₹${income.toStringAsFixed(0)}\n'
          'Monthly expenses: ₹${expenses.toStringAsFixed(0)}\n'
          'Estimated savings: ₹${savings.toStringAsFixed(0)}.';
    }

    // Greeting
    if (message == 'hi' ||
        message == 'hello' ||
        message.contains('good morning') ||
        message.contains('good evening')) {
      return
          'Hello! 👋 I am your LifeOS AI. '
          'Tell me about an expense or ask me for your spending report.';
    }

    return
        'I understand your request. '
        'Try asking:\n\n'
        '• How much did I spend this month?\n'
        '• Show my total expenses\n'
        '• I spent ₹500 on fuel\n'
        '• Where am I spending too much?\n'
        '• Give me a report';
  }

  // ------------------------------------------------------------
  // READ EXPENSES
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>>
      _readExpenses() async {
    final prefs =
        await SharedPreferences.getInstance();

    final raw =
        prefs.getString('lifeos_expenses');

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded =
          jsonDecode(raw);

      return decoded
          .map(
            (item) =>
                Map<String, dynamic>.from(item),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ------------------------------------------------------------
  // TOTAL EXPENSES
  // ------------------------------------------------------------

  double _totalExpenses(
    List<Map<String, dynamic>> expenses,
  ) {
    double total = 0;

    for (final expense in expenses) {
      total +=
          (expense['amount'] as num).toDouble();
    }

    return total;
  }

  // ------------------------------------------------------------
  // MONTHLY EXPENSES
  // ------------------------------------------------------------

  double _monthlyTotal(
    List<Map<String, dynamic>> expenses,
  ) {
    final now = DateTime.now();

    double total = 0;

    for (final expense in expenses) {
      try {
        final date = DateTime.parse(
          expense['date'].toString(),
        );

        if (date.year == now.year &&
            date.month == now.month) {
          total +=
              (expense['amount'] as num)
                  .toDouble();
        }
      } catch (_) {}
    }

    return total;
  }

  // ------------------------------------------------------------
  // ADD EXPENSE FROM NATURAL LANGUAGE
  // ------------------------------------------------------------

  Future<String?> _tryAddExpense(
    String text,
  ) async {
    final regex = RegExp(
      r'(?:₹|rs\.?|inr)?\s*([0-9]+(?:\.[0-9]+)?)',
      caseSensitive: false,
    );

    final match =
        regex.firstMatch(text);

    final lower =
        text.toLowerCase();

    final expenseWords = [
      'spent',
      'spend',
      'expense',
      'paid',
      'pay',
      'bought',
      'purchase',
    ];

    final isExpense =
        expenseWords.any(
      (word) => lower.contains(word),
    );

    if (match == null || !isExpense) {
      return null;
    }

    final amount =
        double.tryParse(match.group(1)!);

    if (amount == null || amount <= 0) {
      return null;
    }

    final category =
        _detectCategory(lower);

    await _saveExpense(
      amount: amount,
      category: category,
    );

    return
        'Done ✅\n'
        'I recorded ₹${amount.toStringAsFixed(0)} '
        'under $category.';
  }

  // ------------------------------------------------------------
  // CATEGORY DETECTION
  // ------------------------------------------------------------

  String _detectCategory(
    String text,
  ) {
    if (text.contains('fuel') ||
        text.contains('petrol') ||
        text.contains('diesel')) {
      return 'Fuel';
    }

    if (text.contains('food') ||
        text.contains('restaurant') ||
        text.contains('lunch') ||
        text.contains('dinner') ||
        text.contains('breakfast')) {
      return 'Food';
    }

    if (text.contains('milk')) {
      return 'Milk';
    }

    if (text.contains('electricity') ||
        text.contains('light bill')) {
      return 'Electricity';
    }

    if (text.contains('rent')) {
      return 'Rent';
    }

    if (text.contains('medicine') ||
        text.contains('medical') ||
        text.contains('hospital')) {
      return 'Medical';
    }

    if (text.contains('shopping') ||
        text.contains('clothes')) {
      return 'Shopping';
    }

    if (text.contains('travel') ||
        text.contains('ticket')) {
      return 'Travel';
    }

    return 'Other';
  }

  // ------------------------------------------------------------
  // SAVE EXPENSE
  // ------------------------------------------------------------

  Future<void> _saveExpense({
    required double amount,
    required String category,
  }) async {
    final prefs =
        await SharedPreferences.getInstance();

    final raw =
        prefs.getString('lifeos_expenses');

    List<dynamic> expenses = [];

    if (raw != null) {
      try {
        expenses = jsonDecode(raw);
      } catch (_) {
        expenses = [];
      }
    }

    expenses.add({
      'amount': amount,
      'category': category,
      'date': DateTime.now()
          .toIso8601String(),
    });

    await prefs.setString(
      'lifeos_expenses',
      jsonEncode(expenses),
    );
  }

  // ------------------------------------------------------------
  // SPENDING ANALYSIS
  // ------------------------------------------------------------

  Future<String> _spendingAnalysis() async {
    final expenses =
        await _readExpenses();

    if (expenses.isEmpty) {
      return
          'I do not have enough expense data yet. '
          'Add some expenses and I will analyze your spending.';
    }

    final Map<String, double> categories =
        {};

    for (final expense in expenses) {
      final category =
          expense['category']
              ?.toString() ??
              'Other';

      final amount =
          (expense['amount'] as num)
              .toDouble();

      categories[category] =
          (categories[category] ?? 0) +
              amount;
    }

    String highestCategory = 'Other';
    double highestAmount = 0;

    categories.forEach(
      (category, amount) {
        if (amount > highestAmount) {
          highestAmount = amount;
          highestCategory = category;
        }
      },
    );

    return
        'Your highest spending category is '
        '$highestCategory at '
        '₹${highestAmount.toStringAsFixed(0)}.\n\n'
        'LifeOS suggestion: review this category '
        'first to look for possible savings.';
  }

  // ------------------------------------------------------------
  // REPORT
  // ------------------------------------------------------------

  Future<String> _generateReport() async {
    final expenses =
        await _readExpenses();

    final prefs =
        await SharedPreferences.getInstance();

    final income =
        prefs.getDouble(
              'lifeos_monthly_income',
            ) ??
            0;

    final monthly =
        _monthlyTotal(expenses);

    final savings =
        income - monthly;

    return
        '📊 LifeOS Report\n\n'
        'Monthly income: ₹${income.toStringAsFixed(0)}\n'
        'Monthly expenses: ₹${monthly.toStringAsFixed(0)}\n'
        'Estimated savings: ₹${savings.toStringAsFixed(0)}\n'
        'Recorded transactions: ${expenses.length}';
  }

  // ------------------------------------------------------------
  // OPEN EXPENSES
  // ------------------------------------------------------------

  void _openExpenses() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            const ExpenseScreen(),
      ),
    );
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome),
            SizedBox(width: 8),
            Text(
              'LifeOS AI',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Expenses',
            onPressed: _openExpenses,
            icon: const Icon(
              Icons.account_balance_wallet_outlined,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.all(16),
              itemCount:
                  _messages.length,
              itemBuilder:
                  (context, index) {
                return _MessageBubble(
                  message:
                      _messages[index],
                );
              },
            ),
          ),

          if (_isThinking)
            const Padding(
              padding:
                  EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              child: Align(
                alignment:
                    Alignment.centerLeft,
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'LifeOS AI is thinking...',
                    ),
                  ],
                ),
              ),
            ),

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          _controller,
                      textInputAction:
                          TextInputAction.send,
                      onSubmitted:
                          (_) =>
                              _sendMessage(),
                      decoration:
                          InputDecoration(
                        hintText:
                            'Ask LifeOS anything...',
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            24,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  CircleAvatar(
                    radius: 25,
                    child: IconButton(
                      onPressed:
                          _isThinking
                              ? null
                              : _sendMessage,
                      icon: const Icon(
                        Icons.send,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// CHAT MESSAGE
// =============================================================

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({
    required this.text,
    required this.isUser,
  });
}

// =============================================================
// MESSAGE BUBBLE
// =============================================================

class _MessageBubble
    extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 330,
        ),
        margin:
            const EdgeInsets.only(
          bottom: 12,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration:
            BoxDecoration(
          gradient: message.isUser
              ? const LinearGradient(
                  colors: [
                    Color(0xFF00D4FF),
                    Color(0xFF00E676),
                  ],
                )
              : null,
          color: message.isUser
              ? null
              : Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
          borderRadius:
              BorderRadius.circular(
            18,
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser
                ? Colors.black87
                : null,
          ),
        ),
      ),
    );
  }
}
