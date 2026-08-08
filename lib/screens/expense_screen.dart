import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Expense {
  final String id;
  final double amount;
  final String category;
  final String note;
  final DateTime date;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] ?? 'Other',
      note: json['note'] ?? '',
      date: DateTime.parse(json['date']),
    );
  }
}

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<Expense> expenses = [];

  final List<String> categories = [
    'Food',
    'Fuel',
    'Rent',
    'EMI',
    'Electricity',
    'Milk',
    'Shopping',
    'Medical',
    'Travel',
    'Bills',
    'Education',
    'Entertainment',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('lifeos_expenses');

    if (data != null) {
      final List decoded = jsonDecode(data);

      setState(() {
        expenses = decoded
            .map((item) => Expense.fromJson(item))
            .toList();
      });
    }
  }

  Future<void> saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();

    final data = jsonEncode(
      expenses.map((expense) => expense.toJson()).toList(),
    );

    await prefs.setString('lifeos_expenses', data);
  }

  double get totalExpense {
    return expenses.fold(
      0,
      (total, expense) => total + expense.amount,
    );
  }

  Future<void> showExpenseDialog({Expense? existing}) async {
    final amountController = TextEditingController(
      text: existing == null ? '' : existing.amount.toString(),
    );

    final noteController = TextEditingController(
      text: existing?.note ?? '',
    );

    String selectedCategory =
        existing?.category ?? categories.first;

    DateTime selectedDate = existing?.date ?? DateTime.now();

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                existing == null
                    ? 'Add Expense'
                    : 'Edit Expense',
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: amountController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          prefixText: '₹ ',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final amount =
                              double.tryParse(value ?? '');

                          if (amount == null || amount <= 0) {
                            return 'Enter a valid amount';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Note',
                          hintText: 'Example: Monthly milk',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_month),
                        title: const Text('Date'),
                        subtitle: Text(
                          '${selectedDate.day}/'
                          '${selectedDate.month}/'
                          '${selectedDate.year}',
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setDialogState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),

                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    final amount =
                        double.parse(amountController.text);

                    if (existing == null) {
                      expenses.insert(
                        0,
                        Expense(
                          id: DateTime.now()
                              .microsecondsSinceEpoch
                              .toString(),
                          amount: amount,
                          category: selectedCategory,
                          note: noteController.text.trim(),
                          date: selectedDate,
                        ),
                      );
                    } else {
                      final index = expenses.indexWhere(
                        (expense) => expense.id == existing.id,
                      );

                      if (index != -1) {
                        expenses[index] = Expense(
                          id: existing.id,
                          amount: amount,
                          category: selectedCategory,
                          note: noteController.text.trim(),
                          date: selectedDate,
                        );
                      }
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  child: Text(
                    existing == null ? 'Add' : 'Update',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    amountController.dispose();
    noteController.dispose();

    if (result == true) {
      await saveExpenses();
      setState(() {});
    }
  }

  Future<void> deleteExpense(Expense expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Expense?'),
          content: Text(
            'Delete ₹${expense.amount.toStringAsFixed(0)} '
            'from ${expense.category}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        expenses.removeWhere(
          (item) => item.id == expense.id,
        );
      });

      await saveExpenses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense deleted'),
          ),
        );
      }
    }
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData categoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;

      case 'Fuel':
        return Icons.local_gas_station;

      case 'Rent':
        return Icons.home;

      case 'EMI':
        return Icons.account_balance;

      case 'Electricity':
        return Icons.bolt;

      case 'Milk':
        return Icons.local_drink;

      case 'Shopping':
        return Icons.shopping_bag;

      case 'Medical':
        return Icons.medical_services;

      case 'Travel':
        return Icons.directions_car;

      case 'Bills':
        return Icons.receipt_long;

      case 'Education':
        return Icons.school;

      case 'Entertainment':
        return Icons.movie;

      default:
        return Icons.payments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),

      body: expenses.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 70,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'No expenses yet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Start tracking your daily expenses.',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    FilledButton.icon(
                      onPressed: () {
                        showExpenseDialog();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Expense'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet,
                          size: 40,
                        ),

                        const SizedBox(width: 16),

                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Expenses',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              '₹${totalExpense.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.only(bottom: 90),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(
                              categoryIcon(
                                expense.category,
                              ),
                            ),
                          ),

                          title: Text(
                            expense.category,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            expense.note.isEmpty
                                ? formatDate(expense.date)
                                : '${expense.note}\n'
                                  '${formatDate(expense.date)}',
                          ),

                          isThreeLine:
                              expense.note.isNotEmpty,

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₹${expense.amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    showExpenseDialog(
                                      existing: expense,
                                    );
                                  }

                                  if (value == 'delete') {
                                    deleteExpense(expense);
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 10),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete),
                                        SizedBox(width: 10),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          onTap: () {
                            showExpenseDialog(
                              existing: expense,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showExpenseDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}
