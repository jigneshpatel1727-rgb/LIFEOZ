import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LifeOSApp());
}

// ============================================================
// LIFEOS
// ============================================================

class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeOS',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF01070D),
        useMaterial3: true,
      ),
      home: const LifeOSHome(),
    );
  }
}

// ============================================================
// COLORS
// ============================================================

const Color cyan = Color(0xFF00E5FF);
const Color green = Color(0xFF39FF88);

// ============================================================
// HOME
// ============================================================

class LifeOSHome extends StatefulWidget {
  const LifeOSHome({super.key});

  @override
  State<LifeOSHome> createState() => _LifeOSHomeState();
}

class _LifeOSHomeState extends State<LifeOSHome>
    with TickerProviderStateMixin {
  late AnimationController pulseController;
  late AnimationController rotationController;
  late AnimationController particleController;

  final stt.SpeechToText speech = stt.SpeechToText();
  final FlutterTts tts = FlutterTts();

  bool listening = false;
  bool menuOpen = false;
  bool notifications = true;
  bool yansiReady = false;

  String heardText = '';

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _initializeYansi();
  }

  // ==========================================================
  // YANSI INITIALIZATION
  // ==========================================================

  Future<void> _initializeYansi() async {
    await tts.setLanguage('en-IN');
    await tts.setSpeechRate(0.48);
    await tts.setPitch(1.0);
    await tts.setVolume(1.0);

    yansiReady = true;

    // Small delay so the home screen appears first.
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    await speak(
      "Hello. I'm Yansi. Your LifeOS assistant is ready. "
      "Tell me what you want to add or manage.",
    );
  }

  Future<void> speak(String text) async {
    try {
      await tts.stop();
      await tts.speak(text);
    } catch (_) {}
  }

  // ==========================================================
  // VOICE LISTENING
  // ==========================================================

  Future<void> startListening() async {
    if (!yansiReady) {
      await _initializeYansi();
    }

    final available = await speech.initialize(
      onStatus: (status) {
        if (!mounted) return;

        if (status == 'done' || status == 'notListening') {
          setState(() {
            listening = false;
          });
        }
      },
      onError: (_) {
        if (!mounted) return;

        setState(() {
          listening = false;
        });
      },
    );

    if (!available) {
      await speak(
        "Sorry. Voice recognition is not available on this device.",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Voice recognition is not available.',
          ),
        ),
      );

      return;
    }

    await tts.stop();

    setState(() {
      listening = true;
      heardText = '';
    });

    await speech.listen(
      localeId: 'en_IN',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      onResult: (result) {
        if (!mounted) return;

        setState(() {
          heardText = result.recognizedWords;
        });

        if (result.finalResult) {
          setState(() {
            listening = false;
          });

          processYansiCommand(
            result.recognizedWords,
          );
        }
      },
    );
  }

  Future<void> stopListening() async {
    await speech.stop();

    if (mounted) {
      setState(() {
        listening = false;
      });
    }
  }

  // ==========================================================
  // YANSI COMMAND ENGINE
  // ==========================================================

  Future<void> processYansiCommand(String text) async {
    if (text.trim().isEmpty) {
      await speak("I didn't hear anything. Please try again.");
      return;
    }

    final lower = text.toLowerCase();

    // -----------------------------
    // EXPENSE
    // -----------------------------

    final amount = extractAmount(text);

    final looksLikeExpense =
        amount != null &&
        (
          lower.contains('spent') ||
          lower.contains('spend') ||
          lower.contains('paid') ||
          lower.contains('pay') ||
          lower.contains('bought') ||
          lower.contains('buy') ||
          lower.contains('expense') ||
          lower.contains('rupees') ||
          lower.contains('rs') ||
          lower.contains('₹')
        );

    if (looksLikeExpense) {
      final category = detectCategory(lower);

      await saveExpense(
        amount,
        category,
        text,
      );

      final response =
          "Done. I added ${money(amount)} to today's "
          "$category expenses.";

      await speak(response);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => YansiDialog(
          title: 'Yansi',
          message: response,
        ),
      );

      return;
    }

    // -----------------------------
    // SHOPPING
    // -----------------------------

    if (lower.contains('shopping') ||
        lower.contains('shopping list') ||
        lower.contains('add milk') ||
        lower.contains('add bread') ||
        lower.contains('buy milk') ||
        lower.contains('buy bread')) {
      final item = extractShoppingItem(text);

      await saveShoppingItem(item);

      final response =
          "Done. I added $item to your shopping list.";

      await speak(response);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => YansiDialog(
          title: 'Shopping',
          message: response,
        ),
      );

      return;
    }

    // -----------------------------
    // DIARY
    // -----------------------------

    if (lower.contains('diary') ||
        lower.contains('write in my diary') ||
        lower.contains('journal')) {
      await saveDiary(text);

      const response =
          "Done. I've saved that in your diary.";

      await speak(response);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => const YansiDialog(
          title: 'Diary',
          message: response,
        ),
      );

      return;
    }

    // -----------------------------
    // TASK / REMINDER
    // -----------------------------

    if (lower.contains('remind me') ||
        lower.contains('reminder') ||
        lower.contains('remember to') ||
        lower.contains('task')) {
      await saveTask(text);

      const response =
          "Done. I've saved that as a task.";

      await speak(response);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => const YansiDialog(
          title: 'Task',
          message: response,
        ),
      );

      return;
    }

    // -----------------------------
    // GREETING
    // -----------------------------

    if (lower.contains('hello') ||
        lower.contains('hi yansi') ||
        lower.contains('hello yansi')) {
      const response =
          "Hello. I'm Yansi. I'm ready to help you.";

      await speak(response);
      return;
    }

    // -----------------------------
    // DEFAULT
    // -----------------------------

    final response =
        "I heard you say: $text. "
        "You can tell me an expense, shopping item, diary entry, "
        "or reminder.";

    await speak(response);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => YansiDialog(
        title: 'Yansi',
        message: response,
      ),
    );
  }

  // ==========================================================
  // AMOUNT EXTRACTION
  // ==========================================================

  double? extractAmount(String text) {
    String cleaned = text.toLowerCase();

    cleaned = cleaned
        .replaceAll(',', '')
        .replaceAll('₹', '')
        .replaceAll('rs.', 'rs')
        .replaceAll('rupees', '')
        .replaceAll('rs ', ' ');

    final match = RegExp(
      r'(\d+(?:\.\d+)?)',
    ).firstMatch(cleaned);

    if (match == null) {
      return null;
    }

    return double.tryParse(
      match.group(1)!,
    );
  }

  // ==========================================================
  // CATEGORY
  // ==========================================================

  String detectCategory(String text) {
    if (text.contains('petrol') ||
        text.contains('fuel') ||
        text.contains('diesel') ||
        text.contains('gas')) {
      return 'Fuel';
    }

    if (text.contains('electric') ||
        text.contains('electricity')) {
      return 'Electricity';
    }

    if (text.contains('milk')) {
      return 'Milk';
    }

    if (text.contains('food') ||
        text.contains('restaurant') ||
        text.contains('lunch') ||
        text.contains('dinner') ||
        text.contains('breakfast')) {
      return 'Food';
    }

    if (text.contains('medicine') ||
        text.contains('medical') ||
        text.contains('doctor') ||
        text.contains('hospital')) {
      return 'Medical';
    }

    if (text.contains('shopping') ||
        text.contains('clothes') ||
        text.contains('shirt') ||
        text.contains('dress')) {
      return 'Shopping';
    }

    if (text.contains('emi') ||
        text.contains('loan')) {
      return 'EMI';
    }

    if (text.contains('mobile') ||
        text.contains('phone') ||
        text.contains('recharge')) {
      return 'Mobile';
    }

    if (text.contains('bill') ||
        text.contains('payment')) {
      return 'Bills';
    }

    return 'Other';
  }

  String money(double amount) {
    if (amount == amount.roundToDouble()) {
      return '₹${amount.toInt()}';
    }

    return '₹${amount.toStringAsFixed(2)}';
  }

  // ==========================================================
  // STORAGE
  // ==========================================================

  Future<void> saveExpense(
    double amount,
    String category,
    String note,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final expenses =
        prefs.getStringList('lifeos_expenses') ?? [];

    final record = [
      DateTime.now().toIso8601String(),
      category,
      amount.toString(),
      note,
    ].join('|');

    expenses.add(record);

    await prefs.setStringList(
      'lifeos_expenses',
      expenses,
    );
  }

  Future<void> saveShoppingItem(
    String item,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final list =
        prefs.getStringList('lifeos_shopping') ?? [];

    list.add(
      '${DateTime.now().toIso8601String()}|$item',
    );

    await prefs.setStringList(
      'lifeos_shopping',
      list,
    );
  }

  Future<void> saveDiary(
    String text,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final list =
        prefs.getStringList('lifeos_diary') ?? [];

    list.add(
      '${DateTime.now().toIso8601String()}|$text',
    );

    await prefs.setStringList(
      'lifeos_diary',
      list,
    );
  }

  Future<void> saveTask(
    String text,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final list =
        prefs.getStringList('lifeos_tasks') ?? [];

    list.add(
      '${DateTime.now().toIso8601String()}|$text',
    );

    await prefs.setStringList(
      'lifeos_tasks',
      list,
    );
  }

  String extractShoppingItem(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('milk')) {
      return 'Milk';
    }

    if (lower.contains('bread')) {
      return 'Bread';
    }

    if (lower.contains('vegetable')) {
      return 'Vegetables';
    }

    if (lower.contains('grocery')) {
      return 'Groceries';
    }

    return text;
  }

  // ==========================================================
  // CORE
  // ==========================================================

  void openCore(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoreDetailScreen(
          title: title,
          icon: icon,
        ),
      ),
    );
  }

  @override
  void dispose() {
    speech.stop();
    tts.stop();

    pulseController.dispose();
    rotationController.dispose();
    particleController.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          pulseController,
          rotationController,
          particleController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              const FuturisticBackground(),

              Positioned.fill(
                child: CustomPaint(
                  painter: ParticlePainter(
                    progress: particleController.value,
                  ),
                ),
              ),

              SafeArea(
                child: LayoutBuilder(
                  builder: (
                    context,
                    constraints,
                  ) {
                    final width =
                        constraints.maxWidth;

                    final height =
                        constraints.maxHeight;

                    return Stack(
                      children: [
                        // MENU
                        Positioned(
                          top: 10,
                          left: 10,
                          child: HudButton(
                            icon: menuOpen
                                ? Icons.close_rounded
                                : Icons.menu_rounded,
                            onTap: () {
                              setState(() {
                                menuOpen =
                                    !menuOpen;
                              });
                            },
                          ),
                        ),

                        // BELL
                        Positioned(
                          top: 10,
                          right: 10,
                          child: BellButton(
                            active:
                                notifications,
                            onTap: () {
                              setState(() {
                                notifications =
                                    !notifications;
                              });
                            },
                          ),
                        ),

                        // LIFEOS TITLE
                        Positioned(
                          top: 62,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              'L I F E O S',
                              style: TextStyle(
                                color: Colors.white
                                    .withOpacity(.92),
                                fontSize: 24,
                                fontWeight:
                                    FontWeight.w300,
                                letterSpacing: 7,
                                shadows: const [
                                  Shadow(
                                    color: cyan,
                                    blurRadius: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // NETWORK
                        Positioned.fill(
                          top: 115,
                          child: CustomPaint(
                            painter:
                                NeuralNetworkPainter(
                              pulse:
                                  pulseController
                                      .value,
                              rotation:
                                  rotationController
                                      .value,
                            ),
                          ),
                        ),

                        // FINANCE
                        Positioned(
                          top: height * .14,
                          left:
                              width / 2 - 60,
                          child: CoreOrb(
                            size: 120,
                            icon: Icons
                                .account_balance_wallet_rounded,
                            color: cyan,
                            pulse:
                                pulseController
                                    .value,
                            onTap: () =>
                                openCore(
                              context,
                              'Finance',
                              Icons
                                  .account_balance_wallet_rounded,
                            ),
                          ),
                        ),

                        // CALENDAR
                        Positioned(
                          top: height * .33,
                          left: -6,
                          child: CoreOrb(
                            size: 114,
                            icon: Icons
                                .calendar_month_rounded,
                            color: cyan,
                            pulse:
                                pulseController
                                    .value,
                            onTap: () =>
                                openCore(
                              context,
                              'Calendar',
                              Icons
                                  .calendar_month_rounded,
                            ),
                          ),
                        ),

                        // HEALTH
                        Positioned(
                          top: height * .33,
                          right: -6,
                          child: CoreOrb(
                            size: 114,
                            icon: Icons
                                .favorite_rounded,
                            color: green,
                            pulse:
                                pulseController
                                    .value,
                            onTap: () =>
                                openCore(
                              context,
                              'Health',
                              Icons
                                  .favorite_rounded,
                            ),
                          ),
                        ),

                        // YANSI
                        Positioned(
                          top: height * .39,
                          left:
                              width / 2 - 95,
                          child: YansiOrb(
                            size: 190,
                            pulse:
                                pulseController
                                    .value,
                            rotation:
                                rotationController
                                    .value,
                            listening: listening,
                            onTap: () {
                              if (listening) {
                                stopListening();
                              } else {
                                startListening();
                              }
                            },
                          ),
                        ),

                        // SHOPPING
                        Positioned(
                          top: height * .60,
                          left: 12,
                          child: CoreOrb(
                            size: 110,
                            icon: Icons
                                .shopping_cart_rounded,
                            color: green,
                            pulse:
                                pulseController
                                    .value,
                            onTap: () =>
                                openCore(
                              context,
                              'Shopping',
                              Icons
                                  .shopping_cart_rounded,
                            ),
                          ),
                        ),

                        // GOALS
                        Positioned(
                          top: height * .60,
                          right: 12,
                          child: CoreOrb(
                            size: 110,
                            icon: Icons
                                .track_changes_rounded,
                            color: green,
                            pulse:
                                pulseController
                                    .value,
                            onTap: () =>
                                openCore(
                              context,
                              'Goals',
                              Icons
                                  .track_changes_rounded,
                            ),
                          ),
                        ),

                        // LISTENING
                        if (listening)
                          Positioned(
                            left: 25,
                            right: 25,
                            bottom: 50,
                            child: Container(
                              padding:
                                  const EdgeInsets
                                      .all(14),
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xEE031522,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  18,
                                ),
                                border:
                                    Border.all(
                                  color: green
                                      .withOpacity(
                                    .55,
                                  ),
                                ),
                              ),
                              child: Text(
                                heardText.isEmpty
                                    ? 'YANSI IS LISTENING...'
                                    : heardText,
                                textAlign:
                                    TextAlign.center,
                                maxLines: 3,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                        // MENU PANEL
                        if (menuOpen)
                          Positioned(
                            top: 58,
                            left: 10,
                            child:
                                MenuPanel(
                              close: () {
                                setState(() {
                                  menuOpen =
                                      false;
                                });
                              },
                              openCore:
                                  (title,
                                      icon) {
                                openCore(
                                  context,
                                  title,
                                  icon,
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// HUD BUTTON
// ============================================================

class HudButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const HudButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 43,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xCC031522),
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color: cyan.withOpacity(.65),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4400E5FF),
              blurRadius: 12,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: green,
          size: 20,
        ),
      ),
    );
  }
}

// ============================================================
// BELL
// ============================================================

class BellButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const BellButton({
    super.key,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 43,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xCC031522),
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color: cyan.withOpacity(.65),
          ),
        ),
        child: Icon(
          active
              ? Icons.notifications_none_rounded
              : Icons.notifications_off_outlined,
          color: green,
          size: 20,
        ),
      ),
    );
  }
}

// ============================================================
// CORE ORB
// ============================================================

class CoreOrb extends StatelessWidget {
  final double size;
  final IconData icon;
  final Color color;
  final double pulse;
  final VoidCallback onTap;

  const CoreOrb({
    super.key,
    required this.size,
    required this.icon,
    required this.color,
    required this.pulse,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: CorePainter(
            color: color,
            pulse: pulse,
          ),
          child: Center(
            child: Container(
              width: size * .48,
              height: size * .48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xDD031522),
                border: Border.all(
                  color: color,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        color.withOpacity(.5),
                    blurRadius:
                        15 + pulse * 10,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: size * .22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// YANSI ORB
// ============================================================

class YansiOrb extends StatelessWidget {
  final double size;
  final double pulse;
  final double rotation;
  final bool listening;
  final VoidCallback onTap;

  const YansiOrb({
    super.key,
    required this.size,
    required this.pulse,
    required this.rotation,
    required this.listening,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: YansiPainter(
            pulse: pulse,
            rotation: rotation,
            listening: listening,
          ),
          child: Center(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Icon(
                  listening
                      ? Icons.graphic_eq_rounded
                      : Icons.psychology_rounded,
                  color: green,
                  size: 52,
                ),
                const SizedBox(height: 6),
                Text(
                  listening
                      ? 'LISTENING'
                      : 'YANSI',
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MENU
// ============================================================

class MenuPanel extends StatelessWidget {
  final VoidCallback close;
  final void Function(
    String,
    IconData,
  ) openCore;

  const MenuPanel({
    super.key,
    required this.close,
    required this.openCore,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Finance',
        Icons.account_balance_wallet_rounded
      ),
      (
        'Calendar',
        Icons.calendar_month_rounded
      ),
      (
        'Health',
        Icons.favorite_rounded
      ),
      (
        'Shopping',
        Icons.shopping_cart_rounded
      ),
      (
        'Goals',
        Icons.track_changes_rounded
      ),
    ];

    return Container(
      width: 210,
      padding:
          const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xF5031522),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: cyan.withOpacity(.55),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x5500E5FF),
            blurRadius: 25,
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding:
                EdgeInsets.all(8),
            child: Text(
              'LIFEOS CORES',
              style: TextStyle(
                color: cyan,
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
          ),
          ...items.map(
            (item) => ListTile(
              dense: true,
              leading: Icon(
                item.$2,
                color: green,
                size: 20,
              ),
              title: Text(
                item.$1,
                style:
                    const TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                close();
                openCore(
                  item.$1,
                  item.$2,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CORE DETAIL
// ============================================================

class CoreDetailScreen
    extends StatelessWidget {
  final String title;
  final IconData icon;

  const CoreDetailScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF01070D),
      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        title: Text(
          title,
          style:
              const TextStyle(
            letterSpacing: 2,
          ),
        ),
        iconTheme:
            const IconThemeData(
          color: cyan,
        ),
      ),
      body: Stack(
        children: [
          const FuturisticBackground(),
          Center(
            child: Padding(
              padding:
                  const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,
                      border: Border.all(
                        color: cyan,
                        width: 1.5,
                      ),
                      boxShadow:
                          const [
                        BoxShadow(
                          color:
                              Color(0x5500E5FF),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 58,
                      color: cyan,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    title.toUpperCase(),
                    style:
                        const TextStyle(
                      fontSize: 25,
                      letterSpacing: 5,
                      color:
                          Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Yansi will use this LifeOS core '
                    'to organize and analyze your $title.',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: Colors.white
                          .withOpacity(.65),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BACKGROUND
// ============================================================

class FuturisticBackground
    extends StatelessWidget {
  const FuturisticBackground({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          const BoxDecoration(
        gradient:
            RadialGradient(
          center:
              Alignment(0, .25),
          radius: 1.15,
          colors: [
            Color(0xFF06283B),
            Color(0xFF020D17),
            Color(0xFF01050A),
          ],
        ),
      ),
      child: CustomPaint(
        painter:
            CircuitPainter(),
        child:
            const SizedBox.expand(),
      ),
    );
  }
}

// ============================================================
// CORE PAINTER
// ============================================================

class CorePainter
    extends CustomPainter {
  final Color color;
  final double pulse;

  CorePainter({
    required this.color,
    required this.pulse,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius =
        size.width / 2;

    final glowPaint = Paint()
      ..color = color.withOpacity(
        .16 + pulse * .1,
      )
      ..maskFilter =
          const MaskFilter.blur(
        BlurStyle.normal,
        16,
      );

    canvas.drawCircle(
      center,
      radius * .72,
      glowPaint,
    );

    final ringPaint = Paint()
      ..color = color.withOpacity(.65)
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 1.3;

    canvas.drawCircle(
      center,
      radius * .84,
      ringPaint,
    );

    canvas.drawCircle(
      center,
      radius * .68,
      ringPaint,
    );

    for (int i = 0; i < 8; i++) {
      final angle =
          i * math.pi / 4;

      final start = Offset(
        center.dx +
            math.cos(angle) *
                radius *
                .84,
        center.dy +
            math.sin(angle) *
                radius *
                .84,
      );

      final end = Offset(
        center.dx +
            math.cos(angle) *
                radius *
                .94,
        center.dy +
            math.sin(angle) *
                radius *
                .94,
      );

      canvas.drawLine(
        start,
        end,
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CorePainter oldDelegate,
  ) =>
      true;
}

// ============================================================
// YANSI PAINTER
// ============================================================

class YansiPainter
    extends CustomPainter {
  final double pulse;
  final double rotation;
  final bool listening;

  YansiPainter({
    required this.pulse,
    required this.rotation,
    required this.listening,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius =
        size.width / 2;

    final glow = Paint()
      ..color = green.withOpacity(
        listening
            ? .3
            : .15 + pulse * .1,
      )
      ..maskFilter =
          const MaskFilter.blur(
        BlurStyle.normal,
        22,
      );

    canvas.drawCircle(
      center,
      radius * .65,
      glow,
    );

    final ring = Paint()
      ..color =
          cyan.withOpacity(.7)
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(
      center,
      radius * .86,
      ring,
    );

    canvas.drawCircle(
      center,
      radius * .72,
      Paint()
        ..color =
            green.withOpacity(.55)
        ..style =
            PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    canvas.save();

    canvas.translate(
      center.dx,
      center.dy,
    );

    canvas.rotate(
      rotation * math.pi * 2,
    );

    for (int i = 0; i < 16; i++) {
      final angle =
          i * math.pi * 2 / 16;

      final inner =
          radius * .77;

      final outer = radius *
          (.86 + pulse * .05);

      final p1 = Offset(
        math.cos(angle) * inner,
        math.sin(angle) * inner,
      );

      final p2 = Offset(
        math.cos(angle) * outer,
        math.sin(angle) * outer,
      );

      canvas.drawLine(
        p1,
        p2,
        ring,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(
    covariant YansiPainter oldDelegate,
  ) =>
      true;
}

// ============================================================
// PARTICLES
// ============================================================

class ParticlePainter
    extends CustomPainter {
  final double progress;

  ParticlePainter({
    required this.progress,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint();

    for (int i = 0; i < 35; i++) {
      final x =
          (i * 73.0) %
              size.width;

      final baseY =
          (i * 127.0) %
              size.height;

      final y =
          (baseY +
                  progress *
                      size.height *
                      .4) %
              size.height;

      paint.color =
          (i % 2 == 0
                  ? cyan
                  : green)
              .withOpacity(
        .15 + (i % 5) * .07,
      );

      canvas.drawCircle(
        Offset(x, y),
        1.1 + (i % 3) * .4,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant ParticlePainter oldDelegate,
  ) =>
      true;
}

// ============================================================
// NEURAL NETWORK
// ============================================================

class NeuralNetworkPainter
    extends CustomPainter {
  final double pulse;
  final double rotation;

  NeuralNetworkPainter({
    required this.pulse,
    required this.rotation,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2,
      size.height * .48,
    );

    final linePaint = Paint()
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = .7
      ..color =
          cyan.withOpacity(.22);

    final nodePaint = Paint()
      ..color = green.withOpacity(
        .55 + pulse * .2,
      );

    final points = <Offset>[];

    for (int i = 0; i < 18; i++) {
      final angle =
          rotation * math.pi * 2 +
              i * math.pi * 2 / 18;

      final radius =
          size.width *
              (.18 +
                  (i % 4) * .035);

      points.add(
        Offset(
          center.dx +
              math.cos(angle) *
                  radius,
          center.dy +
              math.sin(angle) *
                  radius *
                  .7,
        ),
      );
    }

    for (int i = 0;
        i < points.length;
        i++) {
      for (int j = i + 1;
          j < points.length;
          j++) {
        if ((points[i] -
                    points[j])
                .distance <
            size.width * .13) {
          canvas.drawLine(
            points[i],
            points[j],
            linePaint,
          );
        }
      }
    }

    for (final point in points) {
      canvas.drawCircle(
        point,
        2.2,
        nodePaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant NeuralNetworkPainter oldDelegate,
  ) =>
      true;
}

// ============================================================
// CIRCUIT
// ============================================================

class CircuitPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color =
          cyan.withOpacity(.035)
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 1;

    const gap = 42.0;

    for (double x = 0;
        x < size.width;
        x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0;
        y < size.height;
        y += gap) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CircuitPainter oldDelegate) =>
      false;
}

// ============================================================
// YANSI DIALOG
// ============================================================

class YansiDialog
    extends StatelessWidget {
  final String title;
  final String message;

  const YansiDialog({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
          const Color(0xFF031522),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(24),
        side: BorderSide(
          color:
              cyan.withOpacity(.5),
        ),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.psychology_rounded,
            color: green,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            title,
            style:
                const TextStyle(
              color: cyan,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style:
            const TextStyle(
          color: Colors.white,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: const Text(
            'OK',
            style:
                TextStyle(
              color: green,
            ),
          ),
        ),
      ],
    );
  }
}
