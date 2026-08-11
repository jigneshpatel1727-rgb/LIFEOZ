import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const LifeOS());
}

class LifeOS extends StatelessWidget {
  const LifeOS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeOS',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020812),
        fontFamily: 'sans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF),
          brightness: Brightness.dark,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// ============================================================
// DATA MODELS
// ============================================================

class Expense {
  final String category;
  final String item;
  final double amount;
  final DateTime date;

  Expense({
    required this.category,
    required this.item,
    required this.amount,
    required this.date,
  });
}

class Task {
  String title;
  bool completed;
  int priority;

  Task({
    required this.title,
    this.completed = false,
    this.priority = 2,
  });
}

class HouseholdItem {
  String name;
  double price;
  double monthlyUse;

  HouseholdItem({
    required this.name,
    required this.price,
    required this.monthlyUse,
  });
}

class Goal {
  String name;
  double target;
  double current;

  Goal({
    required this.name,
    required this.target,
    required this.current,
  });

  double get progress {
    if (target <= 0) return 0;
    return (current / target).clamp(0, 1);
  }
}

// ============================================================
// GLOBAL APP DATA
// ============================================================

final List<Expense> expenses = [
  Expense(
    category: 'Fuel',
    item: 'Petrol',
    amount: 850,
    date: DateTime.now(),
  ),
  Expense(
    category: 'Food',
    item: 'Groceries',
    amount: 1250,
    date: DateTime.now(),
  ),
  Expense(
    category: 'Bills',
    item: 'Electricity',
    amount: 1800,
    date: DateTime.now(),
  ),
];

final List<Task> tasks = [
  Task(title: 'Pay electricity bill', priority: 1),
  Task(title: 'Buy household items', priority: 2),
  Task(title: 'Review monthly expenses', priority: 2),
  Task(title: 'Complete daily exercise', priority: 3),
];

final List<HouseholdItem> householdItems = [
  HouseholdItem(name: 'Milk', price: 60, monthlyUse: 30),
  HouseholdItem(name: 'Rice', price: 650, monthlyUse: 1),
  HouseholdItem(name: 'Vegetables', price: 700, monthlyUse: 4),
  HouseholdItem(name: 'Cooking Oil', price: 180, monthlyUse: 3),
];

final List<Goal> goals = [
  Goal(name: 'House Fund', target: 1000000, current: 350000),
  Goal(name: 'Emergency Fund', target: 300000, current: 120000),
];

// ============================================================
// MAIN SCREEN
// ============================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final stt.SpeechToText speech = stt.SpeechToText();

  bool listening = false;
  String selectedPeriod = 'Month';

  @override
  void initState() {
    super.initState();
    speech.initialize();
  }

  Future<void> listenToYansi() async {
    if (listening) {
      await speech.stop();
      setState(() => listening = false);
      return;
    }

    setState(() => listening = true);

    await speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          setState(() => listening = false);
          _processVoice(result.recognizedWords);
        }
      },
    );
  }

  void _processVoice(String text) {
    final lower = text.toLowerCase();

    // Expense example:
    // "I spent 500 on petrol"
    final match = RegExp(
      r'(\d+(?:\.\d+)?)',
    ).firstMatch(lower);

    if (match != null &&
        (lower.contains('spent') ||
            lower.contains('paid') ||
            lower.contains('buy'))) {
      final amount = double.tryParse(match.group(1)!);

      if (amount != null) {
        String category = 'Other';

        if (lower.contains('petrol') ||
            lower.contains('fuel') ||
            lower.contains('diesel')) {
          category = 'Fuel';
        } else if (lower.contains('milk') ||
            lower.contains('grocery') ||
            lower.contains('vegetable')) {
          category = 'Household';
        } else if (lower.contains('electricity') ||
            lower.contains('bill')) {
          category = 'Bills';
        } else if (lower.contains('food') ||
            lower.contains('restaurant')) {
          category = 'Food';
        }

        expenses.add(
          Expense(
            category: category,
            item: text,
            amount: amount,
            date: DateTime.now(),
          ),
        );

        setState(() {});
      }
    }
  }

  void openCore(String core) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoreScreen(
          title: core,
          onChanged: () => setState(() {}),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.1,
            colors: [
              Color(0xFF08243A),
              Color(0xFF020812),
              Color(0xFF01040A),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ------------------------------------------------
              // TOP BAR
              // ------------------------------------------------

              Positioned(
                top: 12,
                left: 15,
                child: _topButton(
                  Icons.hub_rounded,
                  () {
                    _showCoreMenu();
                  },
                ),
              ),

              Positioned(
                top: 12,
                right: 15,
                child: _topButton(
                  Icons.notifications_none_rounded,
                  () {
                    _showReminders();
                  },
                ),
              ),

              // ------------------------------------------------
              // CENTER DESIGN
              // ------------------------------------------------

              Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      _lifeosLogo(),

                      const SizedBox(height: 25),

                      const Text(
                        'L I F E O S',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 9,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 35),

                      SizedBox(
                        width: 380,
                        height: 610,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            _orbit(),

                            // CENTER INTELLIGENCE
                            _centerBrain(),

                            // TOP - MONEY
                            Positioned(
                              top: 0,
                              child: _coreIcon(
                                Icons.account_balance_wallet_rounded,
                                () => openCore('Money'),
                              ),
                            ),

                            // LEFT TOP - PRODUCTIVITY
                            Positioned(
                              left: 0,
                              top: 165,
                              child: _coreIcon(
                                Icons.calendar_month_rounded,
                                () => openCore('Productivity'),
                              ),
                            ),

                            // RIGHT TOP - HEALTH
                            Positioned(
                              right: 0,
                              top: 165,
                              child: _coreIcon(
                                Icons.favorite_rounded,
                                () => openCore('Health'),
                              ),
                            ),

                            // LEFT BOTTOM - HOUSEHOLD
                            Positioned(
                              left: 35,
                              bottom: 65,
                              child: _coreIcon(
                                Icons.shopping_cart_rounded,
                                () => openCore('Household'),
                              ),
                            ),

                            // RIGHT BOTTOM - GOALS
                            Positioned(
                              right: 35,
                              bottom: 65,
                              child: _coreIcon(
                                Icons.track_changes_rounded,
                                () => openCore('Goals'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 5),

                      // INVISIBLE/BACKGROUND AI CONTROL
                      GestureDetector(
                        onTap: listenToYansi,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: listening
                                  ? const Color(0xFF7CFF4D)
                                  : const Color(0xFF00DFFF),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: listening
                                    ? const Color(0xFF7CFF4D)
                                    : const Color(0xFF00DFFF),
                                blurRadius: listening ? 30 : 12,
                              ),
                            ],
                          ),
                          child: Icon(
                            listening
                                ? Icons.mic_rounded
                                : Icons.mic_none_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lifeosLogo() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF00E5FF),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF00E5FF),
            blurRadius: 18,
          ),
        ],
      ),
      child: const Icon(
        Icons.hub_rounded,
        size: 44,
        color: Color(0xFF00E5FF),
      ),
    );
  }

  Widget _centerBrain() {
    return Container(
      width: 155,
      height: 155,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFF183C50),
            Color(0xFF04121C),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00E5FF),
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF00E5FF),
            blurRadius: 25,
            spreadRadius: 3,
          ),
        ],
      ),
      child: const Icon(
        Icons.psychology_rounded,
        size: 80,
        color: Color(0xFF5CFF6A),
      ),
    );
  }

  Widget _orbit() {
    return Container(
      width: 370,
      height: 370,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF00DFFF).withOpacity(.18),
        ),
      ),
    );
  }

  Widget _coreIcon(IconData icon, VoidCallback action) {
    return GestureDetector(
      onTap: action,
      child: Container(
        width: 125,
        height: 125,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF021321),
              Color(0xFF071A24),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF00E5FF),
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF00DFFF),
              blurRadius: 18,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 55,
          color: const Color(0xFF64FF62),
        ),
      ),
    );
  }

  Widget _topButton(IconData icon, VoidCallback action) {
    return GestureDetector(
      onTap: action,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00E5FF),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF00E5FF),
              blurRadius: 12,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF65FF52),
        ),
      ),
    );
  }

  void _showCoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF06131C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'LifeOS',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _menuItem('Money', Icons.account_balance_wallet_rounded),
              _menuItem('Health', Icons.favorite_rounded),
              _menuItem('Productivity', Icons.calendar_month_rounded),
              _menuItem('Household', Icons.shopping_cart_rounded),
              _menuItem('Goals', Icons.track_changes_rounded),
              _menuItem('Settings', Icons.settings_rounded),
            ],
          ),
        );
      },
    );
  }

  Widget _menuItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF5CFF6A),
      ),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);

        if (title != 'Settings') {
          openCore(title);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SettingsScreen(),
            ),
          );
        }
      },
    );
  }

  void _showReminders() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF06131C),
      builder: (_) {
        return const Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFF5CFF6A),
                size: 40,
              ),
              SizedBox(height: 15),
              Text(
                'Smart Reminders',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Bills, insurance, tasks and important dates will appear here.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// CORE SCREEN
// ============================================================

class CoreScreen extends StatefulWidget {
  final String title;
  final VoidCallback onChanged;

  const CoreScreen({
    super.key,
    required this.title,
    required this.onChanged,
  });

  @override
  State<CoreScreen> createState() => _CoreScreenState();
}

class _CoreScreenState extends State<CoreScreen> {
  String period = 'Month';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020812),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 5, 16, 30),
        child: Column(
          children: [
            _periodSelector(),

            const SizedBox(height: 18),

            _mainInsight(),

            const SizedBox(height: 15),

            if (widget.title == 'Money') _money(),

            if (widget.title == 'Health') _health(),

            if (widget.title == 'Productivity') _productivity(),

            if (widget.title == 'Household') _household(),

            if (widget.title == 'Goals') _goals(),
          ],
        ),
      ),
    );
  }

  Widget _periodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          'Day',
          'Month',
          'Quarter',
          'Half-year',
          'Year',
        ].map(
          (p) {
            final selected = p == period;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => period = p);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: selected
                        ? const Color(0xFF00DFFF)
                        : const Color(0xFF0A1A24),
                  ),
                  child: Text(
                    p,
                    style: TextStyle(
                      color: selected
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _mainInsight() {
    String message = '';

    switch (widget.title) {
      case 'Money':
        message = 'Spending is being monitored automatically.';
        break;
      case 'Health':
        message = 'Your daily health pattern is being tracked.';
        break;
      case 'Productivity':
        message = 'Today has ${tasks.where((e) => !e.completed).length} pending tasks.';
        break;
      case 'Household':
        message = 'Household prices and usage are being compared.';
        break;
      case 'Goals':
        message = 'Your goals are moving toward their targets.';
        break;
    }

    return _card(
      child: Row(
        children: [
          const Icon(
            Icons.auto_graph_rounded,
            color: Color(0xFF5CFF6A),
            size: 32,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MONEY
  // ==========================================================

  Widget _money() {
    final total = expenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );

    return Column(
      children: [
        _metricGrid([
          _metric('Spent', '₹${total.toStringAsFixed(0)}'),
          _metric('Budget', '₹30,000'),
          _metric('Saved', '₹12,500'),
          _metric('Bills', '₹8,450'),
        ]),

        const SizedBox(height: 15),

        _graphCard(
          title: 'Cash Flow',
          values: const [55, 62, 45, 72, 58, 78, 68],
        ),

        const SizedBox(height: 15),

        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Money Insight',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'LifeOS will compare spending with previous periods and identify avoidable expenses.',
              ),
              const SizedBox(height: 15),
              _insightLine(
                Icons.trending_down,
                'Potential saving opportunity',
                '₹3,200',
              ),
              _insightLine(
                Icons.warning_amber_rounded,
                'Upcoming commitments',
                '₹8,450',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // HEALTH
  // ==========================================================

  Widget _health() {
    return Column(
      children: [
        _metricGrid([
          _metric('Activity', '72%'),
          _metric('Sleep', '7.2 h'),
          _metric('Habits', '5/7'),
          _metric('Visits', '1'),
        ]),

        const SizedBox(height: 15),

        _graphCard(
          title: 'Health Trend',
          values: const [45, 60, 55, 70, 68, 80, 74],
        ),

        const SizedBox(height: 15),

        _card(
          child: Column(
            children: [
              _healthRow(
                Icons.directions_walk,
                'Daily activity',
                'Good',
              ),
              _healthRow(
                Icons.bedtime,
                'Sleep',
                'Needs attention',
              ),
              _healthRow(
                Icons.medication,
                'Medicine',
                'No missed dose',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // PRODUCTIVITY
  // ==========================================================

  Widget _productivity() {
    return Column(
      children: [
        _metricGrid([
          _metric(
            'Done',
            '${tasks.where((e) => e.completed).length}',
          ),
          _metric(
            'Pending',
            '${tasks.where((e) => !e.completed).length}',
          ),
          _metric('Focus', '78%'),
          _metric('Streak', '6 d'),
        ]),

        const SizedBox(height: 15),

        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              ...tasks.map(
                (task) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: task.completed,
                  activeColor: const Color(0xFF5CFF6A),
                  title: Text(task.title),
                  onChanged: (value) {
                    setState(() {
                      task.completed = value ?? false;
                    });
                    widget.onChanged();
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Smart Calendar',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _calendarEvent(
                'Today',
                'Electricity bill',
                'Due',
              ),
              _calendarEvent(
                '15 Sep',
                'Insurance payment',
                'Upcoming',
              ),
              _calendarEvent(
                '20 Sep',
                'Important date',
                'Reminder',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // HOUSEHOLD
  // ==========================================================

  Widget _household() {
    final monthly = householdItems.fold<double>(
      0,
      (sum, item) => sum + item.price * item.monthlyUse,
    );

    return Column(
      children: [
        _metricGrid([
          _metric('Monthly', '₹${monthly.toStringAsFixed(0)}'),
          _metric('Items', '${householdItems.length}'),
          _metric('Bills', '₹4,200'),
          _metric('Saving', '₹1,150'),
        ]),

        const SizedBox(height: 15),

        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Household Usage',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              ...householdItems.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.shopping_basket_outlined,
                    color: Color(0xFF5CFF6A),
                  ),
                  title: Text(item.name),
                  subtitle: Text(
                    '${item.monthlyUse} × ₹${item.price.toStringAsFixed(0)}',
                  ),
                  trailing: Text(
                    '₹${(item.price * item.monthlyUse).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        _graphCard(
          title: 'Household Cost Trend',
          values: const [42, 50, 47, 63, 57, 70, 64],
        ),

        const SizedBox(height: 15),

        _card(
          child: Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF5CFF6A),
                size: 32,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'AI can compare item prices and usage to identify where household spending can be reduced.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // GOALS
  // ==========================================================

  Widget _goals() {
    return Column(
      children: [
        _metricGrid([
          _metric('Goals', '${goals.length}'),
          _metric('Average', '48%'),
          _metric('On track', '2'),
          _metric('Risk', '0'),
        ]),

        const SizedBox(height: 15),

        ...goals.map(
          (goal) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: goal.progress,
                    minHeight: 9,
                    backgroundColor: Colors.white12,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(
                      Color(0xFF5CFF6A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${goal.current.toStringAsFixed(0)}',
                      ),
                      Text(
                        '₹${goal.target.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        _graphCard(
          title: 'Progress Projection',
          values: const [25, 31, 38, 45, 52, 61, 70],
        ),
      ],
    );
  }

  // ==========================================================
  // COMMON WIDGETS
  // ==========================================================

  Widget _metricGrid(List<Widget> metrics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.1,
      children: metrics,
    );
  }

  Widget _metric(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: const Color(0xFF071722),
        border: Border.all(
          color: const Color(0xFF00DFFF).withOpacity(.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5CFF6A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _graphCard({
    required String title,
    required List<double> values,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 150,
            child: CustomPaint(
              painter: GraphPainter(values),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFF06131D),
        border: Border.all(
          color: const Color(0xFF00DFFF).withOpacity(.22),
        ),
      ),
      child: child,
    );
  }

  Widget _insightLine(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF5CFF6A),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthRow(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: const Color(0xFF5CFF6A),
      ),
      title: Text(title),
      trailing: Text(value),
    );
  }

  Widget _calendarEvent(
    String date,
    String title,
    String status,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(
        Icons.event_available_rounded,
        color: Color(0xFF00DFFF),
      ),
      title: Text(title),
      subtitle: Text(date),
      trailing: Text(status),
    );
  }
}

// ============================================================
// GRAPH PAINTER
// ============================================================

class GraphPainter extends CustomPainter {
  final List<double> values;

  GraphPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF00DFFF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF5CFF6A)
      ..style = PaintingStyle.fill;

    final path = Path();

    final maxValue = values.reduce(
      (a, b) => a > b ? a : b,
    );

    final minValue = values.reduce(
      (a, b) => a < b ? a : b,
    );

    final range =
        maxValue - minValue == 0 ? 1 : maxValue - minValue;

    for (int i = 0; i < values.length; i++) {
      final x = i * size.width / (values.length - 1);

      final normalized =
          (values[i] - minValue) / range;

      final y = size.height -
          normalized * (size.height - 20) -
          10;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(
        Offset(x, y),
        4,
        dotPaint,
      );
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

// ============================================================
// SETTINGS
// ============================================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String currency = '₹ INR';
  String design = 'Neon';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020812),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _settingCard(
            Icons.currency_exchange,
            'Currency',
            currency,
            () {
              setState(() {
                currency =
                    currency == '₹ INR' ? '\$ USD' : '₹ INR';
              });
            },
          ),
          _settingCard(
            Icons.palette_outlined,
            'Design',
            design,
            () {
              setState(() {
                design =
                    design == 'Neon' ? 'Classic' : 'Neon';
              });
            },
          ),
          _settingCard(
            Icons.mic_none_rounded,
            'Microphone',
            'Permission',
            () {},
          ),
          _settingCard(
            Icons.camera_alt_outlined,
            'Camera',
            'Bill scanning',
            () {},
          ),
          _settingCard(
            Icons.notifications_none_rounded,
            'Notifications',
            'Reminders',
            () {},
          ),
        ],
      ),
    );
  }

  Widget _settingCard(
    IconData icon,
    String title,
    String value,
    VoidCallback action,
  ) {
    return Card(
      color: const Color(0xFF071722),
      child: ListTile(
        onTap: action,
        leading: Icon(
          icon,
          color: const Color(0xFF5CFF6A),
        ),
        title: Text(title),
        subtitle: Text(value),
        trailing: const Icon(
          Icons.chevron_right_rounded,
        ),
      ),
    );
  }
}
