import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  static const String _storageKey = 'lifeos_expenses';

  List<ExpenseRecord> _expenses = [];
  String _period = 'Month';

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return;
    }

    try {
      final List<dynamic> data = jsonDecode(raw);

      setState(() {
        _expenses = data
            .map(
              (item) => ExpenseRecord.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();

        _expenses.sort(
          (a, b) => b.date.compareTo(a.date),
        );
      });
    } catch (_) {
      // Keep the app usable if old/corrupt data exists.
    }
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();

    final data = _expenses
        .map((expense) => expense.toJson())
        .toList();

    await prefs.setString(
      _storageKey,
      jsonEncode(data),
    );
  }

  DateTime _startOfToday() {
    final now = DateTime.now();

    return DateTime(
      now.year,
      now.month,
      now.day,
    );
  }

  DateTime _startOfWeek() {
    final today = _startOfToday();

    final difference = today.weekday - 1;

    return today.subtract(
      Duration(days: difference),
    );
  }

  DateTime _startOfMonth() {
    final now = DateTime.now();

    return DateTime(
      now.year,
      now.month,
      1,
    );
  }

  List<ExpenseRecord> get _filteredExpenses {
    final now = DateTime.now();

    DateTime start;

    switch (_period) {
      case 'Today':
        start = _startOfToday();
        break;

      case 'Week':
        start = _startOfWeek();
        break;

      case 'Month':
        start = _startOfMonth();
        break;

      case 'Quarter':
        final quarterMonth =
            ((now.month - 1) ~/ 3) * 3 + 1;

        start = DateTime(
          now.year,
          quarterMonth,
          1,
        );
        break;

      case 'Half Year':
        final halfMonth =
            now.month <= 6 ? 1 : 7;

        start = DateTime(
          now.year,
          halfMonth,
          1,
        );
        break;

      case 'Year':
        start = DateTime(
          now.year,
          1,
          1,
        );
        break;

      default:
        start = _startOfMonth();
    }

    return _expenses
        .where(
          (expense) =>
              !expense.date.isBefore(start) &&
              !expense.date.isAfter(now),
        )
        .toList();
  }

  double get _total {
    double value = 0;

    for (final expense in _filteredExpenses) {
      value += expense.amount;
    }

    return value;
  }

  Map<String, double> get _categoryTotals {
    final result = <String, double>{};

    for (final expense in _filteredExpenses) {
      result[expense.category] =
          (result[expense.category] ?? 0) +
              expense.amount;
    }

    return result;
  }

  Future<void> _addExpense() async {
    final result = await showDialog<ExpenseRecord>(
      context: context,
      builder: (_) => const _AddExpenseDialog(),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _expenses.add(result);

      _expenses.sort(
        (a, b) => b.date.compareTo(a.date),
      );
    });

    await _saveExpenses();
  }

  Future<void> _deleteExpense(
    ExpenseRecord expense,
  ) async {
    setState(() {
      _expenses.remove(expense);
    });

    await _saveExpenses();
  }

  String _money(double value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categoryTotals.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );

    return Scaffold(
      backgroundColor: const Color(0xFF02070B),
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'EXPENSE',
          style: TextStyle(
            letterSpacing: 3,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            4,
            18,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              _buildTotalCard(),

              const SizedBox(height: 18),

              _buildPeriodSelector(),

              const SizedBox(height: 18),

              _buildCategorySection(categories),

              const SizedBox(height: 18),

              _buildInsight(),

              const SizedBox(height: 18),

              _buildRecentSection(),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      icon: Icons.mic_none_rounded,
                      title: 'VOICE',
                      onTap: () {
                        _showMessage(
                          'Voice entry will be connected to Yansi next.',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionButton(
                      icon: Icons.camera_alt_outlined,
                      title: 'BILL',
                      onTap: () {
                        _showMessage(
                          'Receipt scanning will be connected next.',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionButton(
                      icon: Icons.add_rounded,
                      title: 'ADD',
                      onTap: _addExpense,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF09252D),
            Color(0xFF061319),
          ],
        ),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _money(_total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _period.toUpperCase(),
            style: TextStyle(
              color: Colors.cyanAccent.withOpacity(0.85),
              fontSize: 12,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = [
      'Today',
      'Week',
      'Month',
      'More',
    ];

    return Row(
      children: periods.map((period) {
        final selected =
            period == _period ||
                (period == 'More' &&
                    [
                      'Quarter',
                      'Half Year',
                      'Year',
                    ].contains(_period));

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 3,
            ),
            child: GestureDetector(
              onTap: () {
                if (period == 'More') {
                  _showMorePeriods();
                } else {
                  setState(() {
                    _period = period;
                  });
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(16),
                  color: selected
                      ? Colors.cyan.withOpacity(0.18)
                      : Colors.white.withOpacity(0.035),
                  border: Border.all(
                    color: selected
                        ? Colors.cyanAccent
                            .withOpacity(0.6)
                        : Colors.white
                            .withOpacity(0.08),
                  ),
                ),
                child: Center(
                  child: Text(
                    period,
                    style: TextStyle(
                      color: selected
                          ? Colors.cyanAccent
                          : Colors.white70,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showMorePeriods() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF07151A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        final periods = [
          'Quarter',
          'Half Year',
          'Year',
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: periods.map((period) {
                return ListTile(
                  leading: const Icon(
                    Icons.analytics_outlined,
                    color: Colors.cyanAccent,
                  ),
                  title: Text(
                    period,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    setState(() {
                      _period = period;
                    });
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySection(
    List<MapEntry<String, double>> categories,
  ) {
    if (categories.isEmpty) {
      return _emptyCard(
        icon: Icons.bar_chart_rounded,
        text: 'No expenses yet',
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'CATEGORIES',
            style: TextStyle(
              color: Colors.white70,
              letterSpacing: 2,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),
          ...categories.take(5).map(
            (entry) {
              final percentage =
                  _total == 0
                      ? 0.0
                      : entry.value / _total;

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 13,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 82,
                      child: Text(
                        entry.key,
                        style:
                            const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                        child:
                            LinearProgressIndicator(
                          value: percentage,
                          minHeight: 7,
                          backgroundColor:
                              Colors.white
                                  .withOpacity(
                            0.06,
                          ),
                          valueColor:
                              AlwaysStoppedAnimation<
                                  Color>(
                            Colors.cyanAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _money(entry.value),
                      style:
                          const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInsight() {
    if (_filteredExpenses.isEmpty) {
      return const SizedBox.shrink();
    }

    final categories = _categoryTotals.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );

    final topCategory = categories.first;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.greenAccent
            .withOpacity(0.055),
        border: Border.all(
          color: Colors.greenAccent
              .withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: Colors.greenAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${topCategory.key} is your highest spending category.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSection() {
    final records = _filteredExpenses.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'RECENT',
            style: TextStyle(
              color: Colors.white70,
              letterSpacing: 2,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          if (records.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 18,
              ),
              child: Center(
                child: Text(
                  'Nothing recorded',
                  style: TextStyle(
                    color: Colors.white38,
                  ),
                ),
              ),
            )
          else
            ...records.map(
              (expense) {
                return Dismissible(
                  key: ValueKey(
                    expense.id,
                  ),
                  direction:
                      DismissDirection.endToStart,
                  background: Container(
                    alignment:
                        Alignment.centerRight,
                    padding:
                        const EdgeInsets.only(
                      right: 20,
                    ),
                    color: Colors.red
                        .withOpacity(0.25),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                  ),
                  onDismissed: (_) {
                    _deleteExpense(expense);
                  },
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.cyan
                            .withOpacity(0.08),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        color: Colors.cyanAccent,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      expense.title,
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      '${expense.category} • ${_formatDate(expense.date)}',
                      style:
                          const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    trailing: Text(
                      _money(expense.amount),
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _emptyCard({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: _panelDecoration(),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.cyanAccent
                .withOpacity(0.6),
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withOpacity(0.035),
          border: Border.all(
            color: Colors.cyanAccent
                .withOpacity(0.22),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.cyanAccent,
              size: 22,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 9,
                letterSpacing: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF061217),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                10,
                24,
                25,
              ),
              child: Text(
                'LIFEOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 5,
                ),
              ),
            ),
            _drawerItem(
              Icons.psychology_outlined,
              'Chat with Yansi',
              () {
                _showMessage(
                  'Yansi chat will be added here.',
                );
              },
            ),
            _drawerItem(
              Icons.analytics_outlined,
              'Reports',
              () {
                _showMessage(
                  'Reports will use the same stored data.',
                );
              },
            ),
            _drawerItem(
              Icons.history_rounded,
              'History',
              () {
                _showMessage(
                  'Complete expense history is stored date-wise.',
                );
              },
            ),
            _drawerItem(
              Icons.notifications_none_rounded,
              'Reminders',
              () {
                _showMessage(
                  'Expense reminders will be connected later.',
                );
              },
            ),
            _drawerItem(
              Icons.settings_outlined,
              'Settings',
              () {
                _showMessage(
                  'LifeOS settings will be added later.',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.cyanAccent,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      color: const Color(0xFF071419),
      border: Border.all(
        color: Colors.white.withOpacity(0.07),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(
            seconds: 2,
          ),
        ),
      );
  }
}

class ExpenseRecord {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;

  const ExpenseRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory ExpenseRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExpenseRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(
        json['date'] as String,
      ),
    );
  }
}

class _AddExpenseDialog extends StatefulWidget {
  const _AddExpenseDialog();

  @override
  State<_AddExpenseDialog> createState() =>
      _AddExpenseDialogState();
}

class _AddExpenseDialogState
    extends State<_AddExpenseDialog> {
  final _titleController =
      TextEditingController();

  final _amountController =
      TextEditingController();

  String _category = 'Other';

  final _categories = [
    'Food',
    'Fuel',
    'Bills',
    'Shopping',
    'Grocery',
    'EMI',
    'Medical',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final title =
        _titleController.text.trim();

    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (title.isEmpty ||
        amount == null ||
        amount <= 0) {
      return;
    }

    Navigator.pop(
      context,
      ExpenseRecord(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),
        title: title,
        category: _category,
        amount: amount,
        date: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF09171D),
      title: const Text(
        'Add Expense',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration:
                  const InputDecoration(
                labelText: 'What?',
              ),
            ),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration:
                  const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _category,
              dropdownColor:
                  const Color(0xFF10242B),
              decoration:
                  const InputDecoration(
                labelText: 'Category',
              ),
              items: _categories.map(
                (category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      style:
                          const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}
