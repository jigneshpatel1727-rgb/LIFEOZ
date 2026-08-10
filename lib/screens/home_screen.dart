import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'expense_screen.dart';
import 'ai_screen.dart';
import 'permissions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardScreen(),
      const ExpenseScreen(),
    ];

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon:
                Icon(Icons.account_balance_wallet),
            label: 'Money',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  double totalExpense = 0;
  double monthlyExpense = 0;
  double monthlyIncome = 0;
  int expenseCount = 0;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final prefs =
        await SharedPreferences.getInstance();

    final data =
        prefs.getString('lifeos_expenses');

    final income =
        prefs.getDouble('lifeos_monthly_income') ?? 0;

    double total = 0;
    double month = 0;
    int count = 0;

    if (data != null && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);

        if (decoded is List) {
          final now = DateTime.now();

          for (final item in decoded) {
            if (item is! Map) continue;

            final amount = item['amount'];

            if (amount is! num) continue;

            final value = amount.toDouble();

            total += value;
            count++;

            final dateValue = item['date'];

            if (dateValue != null) {
              try {
                final date =
                    DateTime.parse(
                  dateValue.toString(),
                );

                if (date.year == now.year &&
                    date.month == now.month) {
                  month += value;
                }
              } catch (_) {}
            }
          }
        }
      } catch (_) {}
    }

    if (!mounted) return;

    setState(() {
      totalExpense = total;
      monthlyExpense = month;
      monthlyIncome = income;
      expenseCount = count;
    });
  }

  double get savings =>
      monthlyIncome - monthlyExpense;

  String money(double value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  Future<void> setIncome() async {
    final controller = TextEditingController(
      text: monthlyIncome == 0
          ? ''
          : monthlyIncome.toStringAsFixed(0),
    );

    final result =
        await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Monthly Income'),
          content: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration:
                const InputDecoration(
              prefixText: '₹ ',
              labelText:
                  'Monthly income',
              border:
                  OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
                  const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value =
                    double.tryParse(
                  controller.text.trim(),
                );

                if (value == null ||
                    value < 0) {
                  return;
                }

                Navigator.pop(
                  context,
                  value,
                );
              },
              child:
                  const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null) return;

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setDouble(
      'lifeos_monthly_income',
      result,
    );

    await loadDashboard();
  }

  void openAI() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AIScreen(),
      ),
    );
  }

  void openExpenses() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const ExpenseScreen(),
      ),
    );
  }

  void openPermissions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const PermissionsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: loadDashboard,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            30,
          ),
          children: [
            // HEADER
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                      17,
                    ),
                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xFF00D4FF),
                        Color(0xFF00E676),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.hub,
                    color:
                        Colors.black87,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LifeOS',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      Text(
                        'One screen • One tap • One report',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // AI HERO
            Container(
              padding:
                  const EdgeInsets.all(20),
              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  25,
                ),
                gradient:
                    const LinearGradient(
                  begin:
                      Alignment.topLeft,
                  end:
                      Alignment.bottomRight,
                  colors: [
                    Color(0xFF082B3A),
                    Color(0xFF07351F),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'LIFEOS AI',
                          style: TextStyle(
                            fontSize: 13,
                            letterSpacing:
                                1.5,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration:
                            BoxDecoration(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                          border:
                              Border.all(
                            color:
                                Colors.white24,
                          ),
                        ),
                        child:
                            const Text(
                          'AI READY',
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your life at a glance',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Ask LifeOS about your '
                    'expenses, savings and '
                    'daily life.',
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        FilledButton.icon(
                      onPressed: openAI,
                      icon: const Icon(
                        Icons.auto_awesome,
                      ),
                      label: const Text(
                        'ASK LIFEOS AI',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // MONTHLY SUMMARY
            const Text(
              'This Month',
              style: TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: metricCard(
                    'Income',
                    money(monthlyIncome),
                    Icons
                        .south_west,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: metricCard(
                    'Expenses',
                    money(monthlyExpense),
                    Icons
                        .north_east,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: metricCard(
                    'Savings',
                    money(savings),
                    Icons
                        .savings_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: metricCard(
                    'Transactions',
                    '$expenseCount',
                    Icons
                        .receipt_long_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // INCOME
            Card(
              child: ListTile(
                leading:
                    const CircleAvatar(
                  child: Icon(
                    Icons.payments_outlined,
                  ),
                ),
                title: const Text(
                  'Monthly Income',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  monthlyIncome == 0
                      ? 'Tap to add income'
                      : money(
                          monthlyIncome,
                        ),
                ),
                trailing:
                    const Icon(
                  Icons.edit,
                ),
                onTap: setIncome,
              ),
            ),

            const SizedBox(height: 20),

            // QUICK ACTIONS
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: actionCard(
                    Icons.add_card,
                    'Add Expense',
                    openExpenses,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: actionCard(
                    Icons.auto_awesome,
                    'Ask AI',
                    openAI,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // SMART INSIGHT
            Card(
              child: ListTile(
                leading:
                    const CircleAvatar(
                  child: Icon(
                    Icons
                        .lightbulb_outline,
                  ),
                ),
                title: const Text(
                  'Smart Insight',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  monthlyExpense == 0
                      ? 'Add expenses and LifeOS '
                        'will analyse your spending.'
                      : savings < 0
                          ? '⚠️ Your expenses are '
                            'higher than recorded income.'
                          : '✅ Your recorded income '
                            'is higher than your '
                            'monthly expenses.',
                ),
                trailing:
                    const Icon(
                  Icons.chevron_right,
                ),
                onTap: openAI,
              ),
            ),

            const SizedBox(height: 12),

            // PERMISSIONS
            Card(
              child: ListTile(
                leading:
                    const CircleAvatar(
                  child: Icon(
                    Icons.security_outlined,
                  ),
                ),
                title: const Text(
                  'Data & Permissions',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                subtitle:
                    const Text(
                  'Allow automatic access where '
                  'available. Manual entry remains '
                  'available if permission is denied.',
                ),
                trailing:
                    const Icon(
                  Icons.chevron_right,
                ),
                onTap:
                    openPermissions,
              ),
            ),

            const SizedBox(height: 12),

            // AI AGENT
            Card(
              child: ListTile(
                leading:
                    const CircleAvatar(
                  child: Icon(
                    Icons
                        .smart_toy_outlined,
                  ),
                ),
                title: const Text(
                  'LifeOS AI Agent',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                subtitle:
                    const Text(
                  'Your personal assistant for '
                  'money, reports and daily life.',
                ),
                trailing:
                    const Icon(
                  Icons.chevron_right,
                ),
                onTap: openAI,
              ),
            ),

            const SizedBox(height: 22),

            // REPORT PREVIEW
            Container(
              padding:
                  const EdgeInsets.all(18),
              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons
                            .assessment_outlined,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'LifeOS Report',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Income: ${money(monthlyIncome)}',
                  ),
                  Text(
                    'Expenses: ${money(monthlyExpense)}',
                  ),
                  Text(
                    'Savings: ${money(savings)}',
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Detailed reports will become '
                    'available as LifeOS collects more data.',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'All-time expenses: '
              '${money(totalExpense)}',
              style: TextStyle(
                fontSize: 13,
                color:
                    Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget metricCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              value,
              style:
                  const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget actionCard(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        borderRadius:
            BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.all(18),
          child: Column(
            children: [
              Icon(
                icon,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
