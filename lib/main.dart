import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/expense_screen.dart';
import 'screens/ai_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LifeOSApp());
}

class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeOS',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const LifeOSShell(),
    );
  }
}

class LifeOSShell extends StatefulWidget {
  const LifeOSShell({super.key});

  @override
  State<LifeOSShell> createState() => _LifeOSShellState();
}

class _LifeOSShellState extends State<LifeOSShell> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    DashboardScreen(),
    ExpenseScreen(),
    AIScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),

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
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Money',
          ),

          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'Yansi',
          ),
        ],
      ),
    );
  }
}
