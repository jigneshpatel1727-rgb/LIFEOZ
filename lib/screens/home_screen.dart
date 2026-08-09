import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _DashboardScreen(),
    ExpenseScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? const _DashboardScreen()
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

class _DashboardScreen extends StatefulWidget {
  const _DashboardScreen();

  @override
  State<_DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<_DashboardScreen> {
  double totalExpense = 0;
  double monthlyExpense = 0;
  int expenseCount = 0;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString('lifeos_expenses');

    if (data == null) {
      return;
    }

    try {
      final List decoded = jsonDecode(data);

      double total = 0;
      double monthTotal = 0;
      int count = 0;

      final now = DateTime.now();

      for (final item in decoded) {
        final amount = (item['amount'] as num).toDouble();

        final date = DateTime.parse(
          item['date'].toString(),
        );

        total += amount;
        count++;

        if (date.year == now.year &&
            date.month == now.month) {
          monthTotal += amount;
        }
      }

      if (mounted) {
        setState(() {
          totalExpense = total;
          monthlyExpense = monthTotal;
          expenseCount = count;
        });
      }
    } catch (_) {
      // Ignore invalid saved data.
    }
  }

  String money(double value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            28,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(16),
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
                      color: Colors.black87,
                      size: 28,
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

              // MAIN CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(24),
                  gradient:
                      const LinearGradient(
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
                    const Text(
                      'THIS MONTH',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      money(monthlyExpense),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '$expenseCount expense'
                      '${expenseCount == 1 ? '' : 's'} recorded',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // FINANCIAL CARDS
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Total Expenses',
                      value: money(totalExpense),
                      icon: Icons.north_east,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: _MetricCard(
                      label: 'Income',
                      value: '₹0',
                      icon: Icons.south_west,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: const [
                  Expanded(
                    child: _MetricCard(
                      label: 'Savings',
                      value: '₹0',
                      icon: Icons.savings_outlined,
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: _MetricCard(
                      label: 'Health',
                      value: 'Ready',
                      icon: Icons.favorite_border,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

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
                      onTap: () {
                        setState(() {
                          _selectedIndexHack();
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _ActionCard(
                      icon: Icons.auto_awesome,
                      title: 'Ask AI',
                      onTap: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'LifeOS AI is coming next.',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              const Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.lightbulb_outline,
                    ),
                  ),
                  title: Text(
                    'Smart Suggestion',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'LifeOS will identify expenses '
                    'that may be reduced.',
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.security_outlined,
                    ),
                  ),
                  title: Text(
                    'Data & Permissions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Automatic access when permitted; '
                    'manual entry when permission is denied.',
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.smart_toy_outlined,
                    ),
                  ),
                  title: Text(
                    'LifeOS AI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Your personal AI assistant.',
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectedIndexHack() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ExpenseScreen(),
      ),
    );
  }
}

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
            Icon(
              icon,
              size: 22,
            ),

            const SizedBox(height: 12),

            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        borderRadius:
            BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Icon(
                icon,
                size: 30,
              ),

              const SizedBox(height: 10),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
