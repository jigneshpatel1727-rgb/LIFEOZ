import 'package:flutter/material.dart';

void main() {
  runApp(const AllinmydayTrialApp());
}

class AllinmydayTrialApp extends StatelessWidget {
  const AllinmydayTrialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Allinmyday',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF07101A),
      ),
      home: const _TrialHome(),
    );
  }
}

class _TrialHome extends StatelessWidget {
  const _TrialHome();

  @override
  Widget build(BuildContext context) {
    const cores = <(String, IconData)>[
      ('Expenses', Icons.account_balance_wallet_outlined),
      ('Goals', Icons.track_changes_outlined),
      ('Tasks', Icons.check_circle_outline),
      ('Household', Icons.shopping_cart_outlined),
      ('Calendar', Icons.calendar_month_outlined),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Row(
                children: [
                  Text(
                    'ALLINMYDAY',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 2),
                  ),
                  Spacer(),
                  Icon(Icons.circle, size: 9, color: Color(0xFF5FE6A8)),
                ],
              ),
              const Spacer(),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFFFFFF), Color(0xFF7AD8FF), Color(0xFF174C69)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6DD8FF).withValues(alpha: .28),
                      blurRadius: 45,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'iamyansi',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text('iamyansi is ready.', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 28),
              Expanded(
                flex: 2,
                child: GridView.builder(
                  itemCount: cores.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.7,
                  ),
                  itemBuilder: (context, index) {
                    final core = cores[index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white12),
                        color: Colors.white.withValues(alpha: .035),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(core.$2, color: Colors.white70),
                          const SizedBox(height: 7),
                          Text(core.$1, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'TRIAL BUILD • ALLINMYDAY • IAMYANSI',
                style: TextStyle(fontSize: 9, color: Colors.white38, letterSpacing: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
