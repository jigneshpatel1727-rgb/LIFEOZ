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
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? const DashboardScreen()
          : const ExpenseScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
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
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Expenses',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double totalExpense = 0;
  double monthlyExpense = 0;
  double monthlyIncome = 0;
  double savings = 0;
  int expenseCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();

    final expenseData = prefs.getString('lifeos_expenses');

    final savedIncome =
        prefs.getDouble('lifeos_monthly_income') ?? 0;

    double total = 0;
    double monthTotal = 0;
    int count = 0;

    if (expenseData != null && expenseData.isNotEmpty) {
      try {
        final decoded = jsonDecode(expenseData);

        if (decoded is List) {
          final now = DateTime.now();

          for (final item in decoded) {
            if (item is! Map) continue;

            final amountValue = item['amount'];

            if (amountValue is! num) continue;

            final amount = amountValue.toDouble();

            total += amount;
            count++;

            final dateValue = item['date'];

            if (dateValue != null) {
              try {
                final date =
                    DateTime.parse(dateValue.toString());

                if (date.year == now.year &&
                    date.month == now.month) {
                  monthTotal += amount;
                }
              } catch (_) {
                // Ignore invalid dates.
              }
            }
          }
        }
      } catch (_) {
        // Ignore invalid saved expense data.
      }
    }

    if (!mounted) return;

    setState(() {
      totalExpense = total;
      monthlyExpense = monthTotal;
      monthlyIncome = savedIncome;
      savings = monthlyIncome - monthlyExpense;
      expenseCount = count;
    });
  }

  String _money(double value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  Future<void> _setIncome() async {
    final controller = TextEditingController(
      text: monthlyIncome == 0
          ? ''
          : monthlyIncome.toStringAsFixed(0),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Monthly Income'),
          content: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              prefixText: '₹ ',
              hintText: 'Enter monthly income',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(
                  controller.text.trim(),
                );

                Navigator.pop(
                  context,
                  value,
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble(
      'lifeos_monthly_income',
      result,
    );

    await _loadDashboardData();
  }

  // FIXED:
  // Your AI screen class is AIScreen, not AiScreen.
  void _openAI() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AIScreen(),
      ),
    );
  }

  void _openExpenses() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ExpenseScreen(),
      ),
    );
  }

  void _openPermissions() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PermissionsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // HEADER
              // =====================================================

              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(17),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00D4FF),
                          Color(0xFF00E676),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.hub,
                      color: Colors.black87,
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
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'One screen. One tap. One report.',
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

              const SizedBox(height: 24),

              // =====================================================
              // AI HERO
              // =====================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                              letterSpacing: 1.5,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white24,
                            ),
                          ),
                          child: const Text(
                            'AI READY',
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Your life at a glance',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Ask LifeOS about your expenses, '
                      'savings and daily life.',
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openAI,
                        icon: const Icon(
                          Icons.auto_awesome,
                        ),
                        label: const Text(
                          'Ask LifeOS AI',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // THIS MONTH
              // =====================================================

              const Text(
                'This Month',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Income',
                      value: _money(monthlyIncome),
                      icon: Icons.south_west,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Expenses',
                      value: _money(monthlyExpense),
                      icon: Icons.north_east,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Savings',
                      value: _money(savings),
                      icon: Icons.savings_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Transactions',
                      value: '$expenseCount',
                      icon:
                          Icons.receipt_long_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // =====================================================
              // INCOME
              // =====================================================

              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.payments_outlined,
                    ),
                  ),
                  title: const Text(
                    'Set Monthly Income',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    monthlyIncome == 0
                        ? 'Tap to add your income'
                        : 'Current: '
                            '${_money(monthlyIncome)}',
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: _setIncome,
                ),
              ),

              const SizedBox(height: 16),

              // =====================================================
              // QUICK ACTIONS
              // =====================================================

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.add_card,
                      title: 'Add Expense',
                      onTap: _openExpenses,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.auto_awesome,
                      title: 'Ask AI',
                      onTap: _openAI,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // =====================================================
              // SMART SUGGESTION
              // =====================================================

              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.lightbulb_outline,
                    ),
                  ),
                  title: const Text(
                    'Smart Suggestion',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    monthlyExpense == 0
                        ? 'Add expenses to receive '
                          'AI-powered suggestions.'
                        : 'LifeOS will analyze your '
                          'spending and identify areas '
                          'to reduce.',
                  ),
                  trailing:
                      const Icon(Icons.chevron_right),
                  onTap: _openAI,
                ),
              ),

              const SizedBox(height: 12),

              // =====================================================
              // PERMISSIONS
              // =====================================================

              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.security_outlined,
                    ),
                  ),
                  title: const Text(
                    'Data & Permissions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Automatic access when permitted. '
                    'Manual entry remains available '
                    'when permission is denied.',
                  ),
                  trailing:
                      const Icon(Icons.chevron_right),
                  onTap: _openPermissions,
                ),
              ),

              const SizedBox(height: 12),

              // =====================================================
              // AI AGENT
              // =====================================================

              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.smart_toy_outlined,
                    ),
                  ),
                  title: const Text(
                    'LifeOS AI Agent',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Your personal assistant for money, '
                    'reports and daily life.',
                  ),
                  trailing:
                      const Icon(Icons.chevron_right),
                  onTap: _openAI,
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // TOTAL
              // =====================================================

              Text(
                'All-time expenses: '
                '${_money(totalExpense)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// METRIC CARD
// ===============================================================

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// ACTION CARD
// ===============================================================

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
