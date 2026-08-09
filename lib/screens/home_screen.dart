import 'package:flutter/material.dart';
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
      body: _screens[_selectedIndex],
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

class _DashboardScreen extends StatelessWidget {
  const _DashboardScreen();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LifeOS Header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
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
                    size: 28,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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

            // Main LifeOS Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF082B3A),
                    Color(0xFF07351F),
                  ],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Your life at a glance',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'LifeOS will turn your daily data into simple actions and reports.',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Financial Summary
            Row(
              children: const [
                Expanded(
                  child: _MetricCard(
                    label: 'Income',
                    value: '₹0',
                    icon: Icons.south_west,
                  ),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: _MetricCard(
                    label: 'Expenses',
                    value: '₹0',
                    icon: Icons.north_east,
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
                    onTap: () {},
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _ActionCard(
                    icon: Icons.auto_awesome,
                    title: 'Ask AI',
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Smart Suggestions
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
                  'Your personalized expense-control insights will appear here.',
                ),
                trailing: Icon(
                  Icons.chevron_right,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Permissions
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
                  'Automatic access when permitted; manual entry when permission is denied.',
                ),
                trailing: Icon(
                  Icons.chevron_right,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // AI Assistant
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(
                    Icons.smart_toy_outlined,
                  ),
                ),
                title: const Text(
                  'LifeOS AI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Your personal AI assistant is ready for future automation.',
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Metric Card
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
          crossAxisAlignment: CrossAxisAlignment.start,
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

// Quick Action Card
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
                size: 30,
              ),

              const SizedBox(height: 10),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
