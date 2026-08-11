import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = LifeOSStore();
  await store.load();

  runApp(
    LifeOSApp(store: store),
  );
}

// ============================================================
// APP
// ============================================================

class LifeOSApp extends StatelessWidget {
  final LifeOSStore store;

  const LifeOSApp({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeOS',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020812),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: MainScreen(store: store),
    );
  }
}

// ============================================================
// MODELS
// ============================================================

class Expense {
  String category;
  String item;
  double amount;
  DateTime date;

  Expense({
    required this.category,
    required this.item,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'item': item,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      category: json['category'] ?? 'Other',
      item: json['item'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: DateTime.parse(
        json['date'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
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

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'completed': completed,
      'priority': priority,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] ?? '',
      completed: json['completed'] ?? false,
      priority: json['priority'] ?? 2,
    );
  }
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'monthlyUse': monthlyUse,
    };
  }

  factory HouseholdItem.fromJson(Map<String, dynamic> json) {
    return HouseholdItem(
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      monthlyUse: (json['monthlyUse'] ?? 0).toDouble(),
    );
  }
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
    return (current / target).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'target': target,
      'current': current,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      name: json['name'] ?? '',
      target: (json['target'] ?? 0).toDouble(),
      current: (json['current'] ?? 0).toDouble(),
    );
  }
}

class Reminder {
  String title;
  DateTime date;

  Reminder({
    required this.title,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String(),
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      title: json['title'] ?? '',
      date: DateTime.parse(
        json['date'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class DiaryEntry {
  String text;
  DateTime date;

  DiaryEntry({
    required this.text,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'date': date.toIso8601String(),
    };
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      text: json['text'] ?? '',
      date: DateTime.parse(
        json['date'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

// ============================================================
// STORAGE
// ============================================================

class LifeOSStore extends ChangeNotifier {
  SharedPreferences? _prefs;

  List<Expense> expenses = [];
  List<Task> tasks = [];
  List<HouseholdItem> householdItems = [];
  List<Goal> goals = [];
  List<Reminder> reminders = [];
  List<DiaryEntry> diary = [];

  String currency = '₹';
  String design = 'Neon';

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();

    expenses = _readList(
      'expenses',
      (json) => Expense.fromJson(json),
    );

    tasks = _readList(
      'tasks',
      (json) => Task.fromJson(json),
    );

    householdItems = _readList(
      'household',
      (json) => HouseholdItem.fromJson(json),
    );

    goals = _readList(
      'goals',
      (json) => Goal.fromJson(json),
    );

    reminders = _readList(
      'reminders',
      (json) => Reminder.fromJson(json),
    );

    diary = _readList(
      'diary',
      (json) => DiaryEntry.fromJson(json),
    );

    currency = _prefs?.getString('currency') ?? '₹';
    design = _prefs?.getString('design') ?? 'Neon';

    if (expenses.isEmpty) {
      expenses.add(
        Expense(
          category: 'Fuel',
          item: 'Petrol',
          amount: 850,
          date: DateTime.now(),
        ),
      );
    }

    if (tasks.isEmpty) {
      tasks.addAll([
        Task(title: 'Pay electricity bill', priority: 1),
        Task(title: 'Buy household items', priority: 2),
        Task(title: 'Review monthly expenses', priority: 2),
        Task(title: 'Complete daily activity', priority: 3),
      ]);
    }

    if (householdItems.isEmpty) {
      householdItems.addAll([
        HouseholdItem(
          name: 'Milk',
          price: 60,
          monthlyUse: 30,
        ),
        HouseholdItem(
          name: 'Rice',
          price: 650,
          monthlyUse: 1,
        ),
        HouseholdItem(
          name: 'Vegetables',
          price: 700,
          monthlyUse: 4,
        ),
        HouseholdItem(
          name: 'Cooking Oil',
          price: 180,
          monthlyUse: 3,
        ),
      ]);
    }

    if (goals.isEmpty) {
      goals.addAll([
        Goal(
          name: 'House Fund',
          target: 1000000,
          current: 350000,
        ),
        Goal(
          name: 'Emergency Fund',
          target: 300000,
          current: 120000,
        ),
      ]);
    }

    await save();
  }

  List<T> _readList<T>(
    String key,
    T Function(Map<String, dynamic>) parser,
  ) {
    final raw = _prefs?.getString(key);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List;

      return decoded
          .map(
            (item) => parser(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save() async {
    await _prefs?.setString(
      'expenses',
      jsonEncode(
        expenses.map((e) => e.toJson()).toList(),
      ),
    );

    await _prefs?.setString(
      'tasks',
      jsonEncode(
        tasks.map((e) => e.toJson()).toList(),
      ),
    );

    await _prefs?.setString(
      'household',
      jsonEncode(
        householdItems.map((e) => e.toJson()).toList(),
      ),
    );

    await _prefs?.setString(
      'goals',
      jsonEncode(
        goals.map((e) => e.toJson()).toList(),
      ),
    );

    await _prefs?.setString(
      'reminders',
      jsonEncode(
        reminders.map((e) => e.toJson()).toList(),
      ),
    );

    await _prefs?.setString(
      'diary',
      jsonEncode(
        diary.map((e) => e.toJson()).toList(),
      ),
    );

    await _prefs?.setString('currency', currency);
    await _prefs?.setString('design', design);
  }

  Future<void> addExpense({
    required String category,
    required String item,
    required double amount,
  }) async {
    expenses.add(
      Expense(
        category: category,
        item: item,
        amount: amount,
        date: DateTime.now(),
      ),
    );

    await save();
    notifyListeners();
  }

  Future<void> addTask(String title) async {
    tasks.add(
      Task(title: title),
    );

    await save();
    notifyListeners();
  }

  Future<void> addReminder(
    String title,
    DateTime date,
  ) async {
    reminders.add(
      Reminder(
        title: title,
        date: date,
      ),
    );

    await save();
    notifyListeners();
  }

  Future<void> addDiary(String text) async {
    diary.add(
      DiaryEntry(
        text: text,
        date: DateTime.now(),
      ),
    );

    await save();
    notifyListeners();
  }

  Future<void> setCurrency(String value) async {
    currency = value;
    await save();
    notifyListeners();
  }

  Future<void> setDesign(String value) async {
    design = value;
    await save();
    notifyListeners();
  }
}

// ============================================================
// MAIN SCREEN
// ============================================================

class MainScreen extends StatefulWidget {
  final LifeOSStore store;

  const MainScreen({
    super.key,
    required this.store,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late stt.SpeechToText speech;

  bool listening = false;

  @override
  void initState() {
    super.initState();

    speech = stt.SpeechToText();

    speech.initialize();
  }

  Future<void> listen() async {
    if (listening) {
      await speech.stop();

      setState(() {
        listening = false;
      });

      return;
    }

    final available = await speech.initialize();

    if (!available) {
      return;
    }

    setState(() {
      listening = true;
    });

    await speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          final text = result.recognizedWords;

          setState(() {
            listening = false;
          });

          processYansiCommand(text);
        }
      },
    );
  }

  Future<void> processYansiCommand(String text) async {
    final command = text.toLowerCase();

    final amountMatch = RegExp(
      r'(\d+(?:\.\d+)?)',
    ).firstMatch(command);

    if (amountMatch != null &&
        (command.contains('spent') ||
            command.contains('paid') ||
            command.contains('buy') ||
            command.contains('bought'))) {
      final amount =
          double.tryParse(amountMatch.group(1)!);

      if (amount != null) {
        String category = 'Other';

        if (command.contains('petrol') ||
            command.contains('fuel') ||
            command.contains('diesel')) {
          category = 'Fuel';
        } else if (command.contains('milk') ||
            command.contains('grocery') ||
            command.contains('vegetable')) {
          category = 'Household';
        } else if (command.contains('electricity') ||
            command.contains('bill')) {
          category = 'Bills';
        } else if (command.contains('food') ||
            command.contains('restaurant')) {
          category = 'Food';
        }

        await widget.store.addExpense(
          category: category,
          item: text,
          amount: amount,
        );

        _showMessage(
          '${widget.store.currency}${amount.toStringAsFixed(0)} recorded',
        );

        return;
      }
    }

    if (command.contains('remind') ||
        command.contains('reminder')) {
      await widget.store.addReminder(
        text,
        DateTime.now().add(
          const Duration(days: 1),
        ),
      );

      _showMessage('Reminder created');

      return;
    }

    if (command.contains('task') ||
        command.contains('todo') ||
        command.contains('need to')) {
      await widget.store.addTask(text);

      _showMessage('Task added');

      return;
    }

    await widget.store.addDiary(text);

    _showMessage('Added to your diary');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void openCore(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoreScreen(
          title: title,
          store: widget.store,
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
              Positioned(
                top: 12,
                left: 15,
                child: _button(
                  Icons.menu_rounded,
                  showMenu,
                ),
              ),
              Positioned(
                top: 12,
                right: 15,
                child: _button(
                  Icons.notifications_none_rounded,
                  showReminders,
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      _logo(),

                      const SizedBox(height: 20),

                      const Text(
                        'L I F E O S',
                        style: TextStyle(
                          fontSize: 30,
                          letterSpacing: 9,
                          fontWeight: FontWeight.w300,
                        ),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: 380,
                        height: 570,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 370,
                              height: 370,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(
                                    0xFF00E5FF,
                                  ).withOpacity(.18),
                                ),
                              ),
                            ),

                            _brain(),

                            Positioned(
                              top: 0,
                              child: _core(
                                Icons.account_balance_wallet_rounded,
                                'Money',
                              ),
                            ),

                            Positioned(
                              left: 0,
                              top: 160,
                              child: _core(
                                Icons.calendar_month_rounded,
                                'Productivity',
                              ),
                            ),

                            Positioned(
                              right: 0,
                              top: 160,
                              child: _core(
                                Icons.favorite_rounded,
                                'Health',
                              ),
                            ),

                            Positioned(
                              left: 35,
                              bottom: 40,
                              child: _core(
                                Icons.shopping_cart_rounded,
                                'Household',
                              ),
                            ),

                            Positioned(
                              right: 35,
                              bottom: 40,
                              child: _core(
                                Icons.track_changes_rounded,
                                'Goals',
                              ),
                            ),
                          ],
                        ),
                      ),

                      GestureDetector(
                        onTap: listen,
                        child: AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 300),
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: listening
                                  ? const Color(0xFF5CFF6A)
                                  : const Color(0xFF00E5FF),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: listening
                                    ? const Color(0xFF5CFF6A)
                                    : const Color(0xFF00E5FF),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Icon(
                            listening
                                ? Icons.mic
                                : Icons.mic_none,
                            color: Colors.white,
                            size: 30,
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

  Widget _logo() {
    return Container(
      width: 70,
      height: 70,
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
        color: Color(0xFF00E5FF),
        size: 42,
      ),
    );
  }

  Widget _brain() {
    return Container(
      width: 155,
      height: 155,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFF173B4E),
            Color(0xFF03111B),
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
          ),
        ],
      ),
      child: const Icon(
        Icons.psychology_rounded,
        color: Color(0xFF5CFF6A),
        size: 75,
      ),
    );
  }

  Widget _core(
    IconData icon,
    String title,
  ) {
    return GestureDetector(
      onTap: () => openCore(title),
      child: Container(
        width: 115,
        height: 115,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF061824),
          border: Border.all(
            color: const Color(0xFF00E5FF),
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF00DFFF),
              blurRadius: 16,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 52,
          color: const Color(0xFF5CFF6A),
        ),
      ),
    );
  }

  Widget _button(
    IconData icon,
    VoidCallback action,
  ) {
    return GestureDetector(
      onTap: action,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFF00E5FF),
          ),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF5CFF6A),
        ),
      ),
    );
  }

  void showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF06131C),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),
              const Text(
                'LifeOS',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _menuItem(
                'Money',
                Icons.account_balance_wallet,
              ),
              _menuItem(
                'Health',
                Icons.favorite,
              ),
              _menuItem(
                'Productivity',
                Icons.calendar_month,
              ),
              _menuItem(
                'Household',
                Icons.shopping_cart,
              ),
              _menuItem(
                'Goals',
                Icons.track_changes,
              ),
              _menuItem(
                'Settings',
                Icons.settings,
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  Widget _menuItem(
    String title,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF5CFF6A),
      ),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);

        if (title == 'Settings') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SettingsScreen(
                store: widget.store,
              ),
            ),
          );
        } else {
          openCore(title);
        }
      },
    );
  }

  void showReminders() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF06131C),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: Color(0xFF5CFF6A),
                  size: 42,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Smart Reminders',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                if (widget.store.reminders.isEmpty)
                  const Text(
                    'No reminders yet.',
                  ),
                ...widget.store.reminders.map(
                  (r) => ListTile(
                    title: Text(r.title),
                    subtitle: Text(
                      '${r.date.day}/${r.date.month}/${r.date.year}',
                    ),
                  ),
                ),
              ],
            ),
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
  final LifeOSStore store;

  const CoreScreen({
    super.key,
    required this.title,
    required this.store,
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
        title: Text(widget.title),
      ),
      body: AnimatedBuilder(
        animation: widget.store,
        builder: (_, __) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _periods(),
                const SizedBox(height: 15),
                _insight(),
                const SizedBox(height: 15),
                if (widget.title == 'Money') money(),
                if (widget.title == 'Health') health(),
                if (widget.title == 'Productivity')
                  productivity(),
                if (widget.title == 'Household')
                  household(),
                if (widget.title == 'Goals') goals(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _periods() {
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
                  setState(() {
                    period = p;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: selected
                        ? const Color(0xFF00E5FF)
                        : const Color(0xFF091923),
                  ),
                  child: Text(
                    p,
                    style: TextStyle(
                      color: selected
                          ? Colors.black
                          : Colors.white,
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

  Widget _insight() {
    String text;

    switch (widget.title) {
      case 'Money':
        text =
            'LifeOS is monitoring your spending and identifying saving opportunities.';
        break;
      case 'Health':
        text =
            'Your health activities and habits can be tracked here.';
        break;
      case 'Productivity':
        text =
            '${widget.store.tasks.where((t) => !t.completed).length} tasks remain today.';
        break;
      case 'Household':
        text =
            'Household usage and item prices are being monitored.';
        break;
      default:
        text =
            'Your goals are being measured against their targets.';
    }

    return _card(
      Row(
        children: [
          const Icon(
            Icons.auto_graph,
            color: Color(0xFF5CFF6A),
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MONEY
  // ==========================================================

  Widget money() {
    final total = widget.store.expenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );

    return Column(
      children: [
        _metrics([
          _metric('Spent', '${widget.store.currency}${total.toStringAsFixed(0)}'),
          _metric('Budget', '${widget.store.currency}30,000'),
          _metric('Bills', '${widget.store.currency}8,450'),
          _metric('Saving', '${widget.store.currency}12,500'),
        ]),
        const SizedBox(height: 15),
        _graph(
          'Cash Flow',
          const [40, 52, 47, 63, 58, 72, 68],
        ),
        const SizedBox(height: 15),
        _card(
          Column(
            children: [
              const Text(
                'Smart Analysis',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _line(
                'Potential saving',
                '${widget.store.currency}3,200',
              ),
              _line(
                'Upcoming commitments',
                '${widget.store.currency}8,450',
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

  Widget health() {
    return Column(
      children: [
        _metrics([
          _metric('Activity', '72%'),
          _metric('Sleep', '7.2 h'),
          _metric('Habits', '5/7'),
          _metric('Visits', '1'),
        ]),
        const SizedBox(height: 15),
        _graph(
          'Health Trend',
          const [45, 60, 55, 70, 68, 80, 74],
        ),
        const SizedBox(height: 15),
        _card(
          Column(
            children: [
              _line('Activity', 'Good'),
              _line('Sleep', 'Needs attention'),
              _line('Medicine', 'On schedule'),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // PRODUCTIVITY
  // ==========================================================

  Widget productivity() {
    return Column(
      children: [
        _metrics([
          _metric(
            'Done',
            '${widget.store.tasks.where((t) => t.completed).length}',
          ),
          _metric(
            'Pending',
            '${widget.store.tasks.where((t) => !t.completed).length}',
          ),
          _metric('Focus', '78%'),
          _metric('Streak', '6 d'),
        ]),
        const SizedBox(height: 15),
        _card(
          Column(
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
              ...widget.store.tasks.map(
                (task) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: task.completed,
                  activeColor: const Color(0xFF5CFF6A),
                  title: Text(task.title),
                  onChanged: (value) async {
                    setState(() {
                      task.completed = value ?? false;
                    });

                    await widget.store.save();
                    widget.store.notifyListeners();
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Calendar',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...widget.store.reminders.map(
                (r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.event,
                    color: Color(0xFF5CFF6A),
                  ),
                  title: Text(r.title),
                  subtitle: Text(
                    '${r.date.day}/${r.date.month}/${r.date.year}',
                  ),
                ),
              ),
              if (widget.store.reminders.isEmpty)
                const Text('No reminders yet.'),
            ],
          ),
        ),
        const SizedBox(height: 15),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Diary',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...widget.store.diary.reversed.take(5).map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    entry.text,
                  ),
                ),
              ),
              if (widget.store.diary.isEmpty)
                const Text(
                  'Speak to Yansi and your diary can be written automatically.',
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

  Widget household() {
    final monthly = widget.store.householdItems.fold<double>(
      0,
      (sum, item) =>
          sum + item.price * item.monthlyUse,
    );

    return Column(
      children: [
        _metrics([
          _metric(
            'Monthly',
            '${widget.store.currency}${monthly.toStringAsFixed(0)}',
          ),
          _metric(
            'Items',
            '${widget.store.householdItems.length}',
          ),
          _metric('Bills', '${widget.store.currency}4,200'),
          _metric('Saving', '${widget.store.currency}1,150'),
        ]),
        const SizedBox(height: 15),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Household Usage',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...widget.store.householdItems.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.shopping_basket_outlined,
                    color: Color(0xFF5CFF6A),
                  ),
                  title: Text(item.name),
                  subtitle: Text(
                    '${item.monthlyUse} × ${widget.store.currency}${item.price.toStringAsFixed(0)}',
                  ),
                  trailing: Text(
                    '${widget.store.currency}${(item.price * item.monthlyUse).toStringAsFixed(0)}',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        _graph(
          'Household Cost Trend',
          const [42, 50, 47, 63, 57, 70, 64],
        ),
        const SizedBox(height: 15),
        _card(
          Row(
            children: const [
              Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF5CFF6A),
                size: 32,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Price and usage analysis will identify opportunities to reduce household costs.',
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

  Widget goals() {
    return Column(
      children: [
        _metrics([
          _metric('Goals', '${widget.store.goals.length}'),
          _metric('Average', '48%'),
          _metric('On track', '2'),
          _metric('Risk', '0'),
        ]),
        const SizedBox(height: 15),
        ...widget.store.goals.map(
          (goal) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _card(
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
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
                        const AlwaysStoppedAnimation(
                      Color(0xFF5CFF6A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.store.currency}${goal.current.toStringAsFixed(0)}',
                      ),
                      Text(
                        '${widget.store.currency}${goal.target.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        _graph(
          'Goal Progress',
          const [25, 31, 38, 45, 52, 61, 70],
        ),
      ],
    );
  }

  // ==========================================================
  // UI HELPERS
  // ==========================================================

  Widget _metrics(List<Widget> children) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.1,
      children: children,
    );
  }

  Widget _metric(
    String title,
    String value,
  ) {
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
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

  Widget _graph(
    String title,
    List<double> values,
  ) {
    return _card(
      Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
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

  Widget _card(Widget child) {
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

  Widget _line(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF5CFF6A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// GRAPH
// ============================================================

class GraphPainter extends CustomPainter {
  final List<double> values;

  GraphPainter(this.values);

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    if (values.length < 2) return;

    final line = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dot = Paint()
      ..color = const Color(0xFF5CFF6A);

    final path = Path();

    final max = values.reduce(
      (a, b) => a > b ? a : b,
    );

    final min = values.reduce(
      (a, b) => a < b ? a : b,
    );

    final range = max == min ? 1 : max - min;

    for (int i = 0; i < values.length; i++) {
      final x =
          i * size.width / (values.length - 1);

      final normalized =
          (values[i] - min) / range;

      final y =
          size.height -
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
        dot,
      );
    }

    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(
    covariant GraphPainter oldDelegate,
  ) {
    return oldDelegate.values != values;
  }
}

// ============================================================
// SETTINGS
// ============================================================

class SettingsScreen extends StatelessWidget {
  final LifeOSStore store;

  const SettingsScreen({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020812),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: AnimatedBuilder(
        animation: store,
        builder: (_, __) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _setting(
                context,
                Icons.currency_exchange,
                'Currency',
                store.currency,
                () async {
                  await store.setCurrency(
                    store.currency == '₹'
                        ? '\$'
                        : '₹',
                  );
                },
              ),
              _setting(
                context,
                Icons.palette_outlined,
                'Design',
                store.design,
                () async {
                  await store.setDesign(
                    store.design == 'Neon'
                        ? 'Classic'
                        : 'Neon',
                  );
                },
              ),
              _setting(
                context,
                Icons.mic_none_rounded,
                'Microphone',
                'Permission',
                () {},
              ),
              _setting(
                context,
                Icons.camera_alt_outlined,
                'Camera',
                'Bill scanning',
                () {},
              ),
              _setting(
                context,
                Icons.notifications_none_rounded,
                'Notifications',
                'Reminders',
                () {},
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _setting(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
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
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right_rounded,
        ),
      ),
    );
  }
}
