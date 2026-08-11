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
// LIFEOS COLORS
// ============================================================

const Color cyan = Color(0xFF00E5FF);
const Color green = Color(0xFF39FF88);
const Color deepBlue = Color(0xFF071C2B);
const Color background = Color(0xFF01070D);

// ============================================================
// APP
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
        scaffoldBackgroundColor: background,
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: cyan,
          secondary: green,
        ),
      ),
      home: const LifeOSHome(),
    );
  }
}

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
  final stt.SpeechToText speech = stt.SpeechToText();
  final FlutterTts tts = FlutterTts();

  late AnimationController pulseController;
  late AnimationController orbitController;
  late AnimationController particleController;

  bool listening = false;
  bool thinking = false;
  bool menuOpen = false;
  bool yansiReady = false;

  String userName = '';
  String heardText = '';
  String yansiStatus = 'READY';

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    initializeYansi();
  }

  // ==========================================================
  // INITIALIZE YANSI
  // ==========================================================

  Future<void> initializeYansi() async {
    try {
      await tts.setLanguage('en-IN');
      await tts.setSpeechRate(0.46);
      await tts.setPitch(0.95);
      await tts.setVolume(1.0);

      final prefs = await SharedPreferences.getInstance();

      String name =
          prefs.getString('profile_name') ??
          prefs.getString('user_name') ??
          prefs.getString('name') ??
          '';

      if (name.trim().isEmpty) {
        name = 'there';
      }

      if (!mounted) return;

      setState(() {
        userName = name.trim();
        yansiReady = true;
      });

      await Future.delayed(
        const Duration(milliseconds: 1200),
      );

      if (!mounted) return;

      await speak(
        'Welcome, $userName. I’m Yansi, your personal LifeOS AI agent. I’m here whenever you need me.',
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          yansiReady = true;
        });
      }
    }
  }

  // ==========================================================
  // YANSI SPEECH
  // ==========================================================

  Future<void> speak(String text) async {
    try {
      await tts.stop();
      await tts.speak(text);
    } catch (_) {}
  }

  // ==========================================================
  // LISTEN
  // ==========================================================

  Future<void> activateYansi() async {
    if (listening) {
      await stopListening();
      return;
    }

    try {
      await tts.stop();

      final available = await speech.initialize(
        onStatus: (status) {
          if (!mounted) return;

          if (status == 'done' ||
              status == 'notListening') {
            setState(() {
              listening = false;
              yansiStatus = 'READY';
            });
          }
        },
        onError: (_) {
          if (!mounted) return;

          setState(() {
            listening = false;
            yansiStatus = 'READY';
          });
        },
      );

      if (!available) {
        await speak(
          'Voice recognition is not available on this device.',
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        listening = true;
        thinking = false;
        heardText = '';
        yansiStatus = 'LISTENING';
      });

      await speech.listen(
        localeId: 'en_IN',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
        partialResults: true,
        onResult: (result) {
          if (!mounted) return;

          setState(() {
            heardText = result.recognizedWords;
          });

          if (result.finalResult) {
            setState(() {
              listening = false;
              thinking = true;
              yansiStatus = 'THINKING';
            });

            processCommand(
              result.recognizedWords,
            );
          }
        },
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        listening = false;
        thinking = false;
        yansiStatus = 'READY';
      });
    }
  }

  Future<void> stopListening() async {
    try {
      await speech.stop();
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      listening = false;
      yansiStatus = 'READY';
    });
  }

  // ==========================================================
  // YANSI COMMAND ENGINE
  // ==========================================================

  Future<void> processCommand(String text) async {
    final command = text.trim();
    final lower = command.toLowerCase();

    if (command.isEmpty) {
      finishThinking();
      return;
    }

    // --------------------------------------------------------
    // EXPENSE
    // --------------------------------------------------------

    final amount = extractAmount(command);

    final expenseCommand =
        amount != null &&
        (
          lower.contains('spent') ||
          lower.contains('spend') ||
          lower.contains('paid') ||
          lower.contains('bought') ||
          lower.contains('buy') ||
          lower.contains('expense') ||
          lower.contains('rupee') ||
          lower.contains('rupees') ||
          lower.contains('rs') ||
          lower.contains('₹')
        );

    if (expenseCommand) {
      final category = detectCategory(lower);

      await saveExpense(
        amount,
        category,
        command,
      );

      finishThinking();

      await speak(
        'Got it. I added ₹${amount.toStringAsFixed(0)} to $category for today.',
      );

      return;
    }

    // --------------------------------------------------------
    // SHOPPING
    // --------------------------------------------------------

    if (lower.contains('shopping list') ||
        lower.contains('add to shopping') ||
        lower.contains('buy milk') ||
        lower.contains('buy bread') ||
        lower.contains('add milk') ||
        lower.contains('add bread')) {
      final item = extractShoppingItem(command);

      await saveShopping(item);

      finishThinking();

      await speak(
        'Got it. I added $item to your shopping list.',
      );

      return;
    }

    // --------------------------------------------------------
    // DIARY
    // --------------------------------------------------------

    if (lower.contains('diary') ||
        lower.contains('journal') ||
        lower.contains('write this down')) {
      await saveDiary(command);

      finishThinking();

      await speak(
        'Got it. I saved that in your diary.',
      );

      return;
    }

    // --------------------------------------------------------
    // TASK / REMINDER
    // --------------------------------------------------------

    if (lower.contains('remind me') ||
        lower.contains('reminder') ||
        lower.contains('remember to') ||
        lower.contains('add a task') ||
        lower.contains('task')) {
      await saveTask(command);

      finishThinking();

      await speak(
        'Got it. I saved that as a task.',
      );

      return;
    }

    // --------------------------------------------------------
    // GREETINGS
    // --------------------------------------------------------

    if (lower.contains('hello') ||
        lower.contains('hi yansi') ||
        lower.contains('hey yansi')) {
      finishThinking();

      await speak(
        'Hello, $userName. I’m here.',
      );

      return;
    }

    // --------------------------------------------------------
    // HELP
    // --------------------------------------------------------

    if (lower.contains('what can you do') ||
        lower.contains('help me')) {
      finishThinking();

      await speak(
        'I can help you manage your LifeOS. '
        'You can tell me about expenses, tasks, shopping, '
        'diary entries, bills and more.',
      );

      return;
    }

    // --------------------------------------------------------
    // DEFAULT
    // --------------------------------------------------------

    finishThinking();

    await speak(
      'I heard you, $userName. '
      'I’m still learning how to handle that action.',
    );
  }

  void finishThinking() {
    if (!mounted) return;

    setState(() {
      thinking = false;
      yansiStatus = 'READY';
    });
  }

  // ==========================================================
  // AMOUNT EXTRACTION
  // ==========================================================

  double? extractAmount(String text) {
    final cleaned = text.replaceAll(',', '');

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
        text.contains('diesel') ||
        text.contains('fuel') ||
        text.contains('cng')) {
      return 'Fuel';
    }

    if (text.contains('electricity') ||
        text.contains('electric')) {
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

  // ==========================================================
  // EXPENSE STORAGE
  // ==========================================================

  Future<void> saveExpense(
    double amount,
    String category,
    String note,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final expenses =
        prefs.getStringList(
              'lifeos_expenses',
            ) ??
            [];

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

  // ==========================================================
  // SHOPPING STORAGE
  // ==========================================================

  Future<void> saveShopping(String item) async {
    final prefs =
        await SharedPreferences.getInstance();

    final list =
        prefs.getStringList(
              'lifeos_shopping',
            ) ??
            [];

    list.add(
      '${DateTime.now().toIso8601String()}|$item',
    );

    await prefs.setStringList(
      'lifeos_shopping',
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
  // DIARY STORAGE
  // ==========================================================

  Future<void> saveDiary(String text) async {
    final prefs =
        await SharedPreferences.getInstance();

    final list =
        prefs.getStringList(
              'lifeos_diary',
            ) ??
            [];

    list.add(
      '${DateTime.now().toIso8601String()}|$text',
    );

    await prefs.setStringList(
      'lifeos_diary',
      list,
    );
  }

  // ==========================================================
  // TASK STORAGE
  // ==========================================================

  Future<void> saveTask(String text) async {
    final prefs =
        await SharedPreferences.getInstance();

    final list =
        prefs.getStringList(
              'lifeos_tasks',
            ) ??
            [];

    list.add(
      '${DateTime.now().toIso8601String()}|$text',
    );

    await prefs.setStringList(
      'lifeos_tasks',
      list,
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            pulseController,
            orbitController,
            particleController,
          ]),
          builder: (context, child) {
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: SpacePainter(
                      particleController.value,
                    ),
                  ),
                ),

                buildTopControls(),

                buildLifeOSCenter(),

                if (menuOpen)
                  buildControlPanel(),

                if (listening || thinking)
                  buildVoiceState(),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // TOP CONTROLS
  // ==========================================================

  Widget buildTopControls() {
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          TinyHudButton(
            icon: menuOpen
                ? Icons.close_rounded
                : Icons.menu_rounded,
            onTap: () {
              setState(() {
                menuOpen = !menuOpen;
              });
            },
          ),

          Row(
            children: [
              TinyHudButton(
                icon:
                    Icons.notifications_none_rounded,
                showDot: true,
                onTap: () {
                  speak(
                    'There are no urgent LifeOS alerts.',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MAIN LIFEOS CENTER
  // ==========================================================

  Widget buildLifeOSCenter() {
    final size = MediaQuery.sizeOf(context);

    final width = size.width;
    final height = size.height;

    final centerX = width / 2;
    final centerY = height * 0.50;

    return Positioned.fill(
      child: Stack(
        children: [
          // ----------------------------------------------------
          // LIFEOS TITLE
          // ----------------------------------------------------

          Positioned(
            top: 78,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'L I F E O S',
                style: TextStyle(
                  fontSize: 25,
                  letterSpacing: 9,
                  fontWeight: FontWeight.w300,
                  color:
                      Colors.white.withOpacity(0.90),
                ),
              ),
            ),
          ),

          // ----------------------------------------------------
          // SUBTLE USER GREETING
          // ----------------------------------------------------

          Positioned(
            top: 121,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                userName.isEmpty
                    ? 'YOUR LIFE • ONE INTELLIGENCE'
                    : 'WELCOME BACK, ${userName.toUpperCase()}',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 3,
                  color:
                      cyan.withOpacity(0.65),
                ),
              ),
            ),
          ),

          // ----------------------------------------------------
          // ORBIT
          // ----------------------------------------------------

          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: OrbitPainter(
                  animation:
                      orbitController.value,
                ),
              ),
            ),
          ),

          // ----------------------------------------------------
          // YANSI
          // ----------------------------------------------------

          Positioned(
            left: centerX - 105,
            top: centerY - 115,
            child: GestureDetector(
              onTap: activateYansi,
              child: YansiOrb(
                pulse: pulseController.value,
                rotation:
                    orbitController.value,
                listening: listening,
                thinking: thinking,
              ),
            ),
          ),

          // ----------------------------------------------------
          // FIVE CORES
          // NO NAMES ON MAIN SCREEN
          // ----------------------------------------------------

          Positioned(
            left: centerX - 31,
            top: centerY - 215,
            child: CoreButton(
              icon: Icons.account_balance_wallet_rounded,
              onTap: () {
                openCore(
                  'Finance',
                  Icons.account_balance_wallet_rounded,
                );
              },
            ),
          ),

          Positioned(
            left: centerX + 125,
            top: centerY - 35,
            child: CoreButton(
              icon: Icons.calendar_month_rounded,
              onTap: () {
                openCore(
                  'Life',
                  Icons.calendar_month_rounded,
                );
              },
            ),
          ),

          Positioned(
            left: centerX + 55,
            top: centerY + 135,
            child: CoreButton(
              icon: Icons.favorite_rounded,
              onTap: () {
                openCore(
                  'Wellbeing',
                  Icons.favorite_rounded,
                );
              },
            ),
          ),

          Positioned(
            left: centerX - 130,
            top: centerY + 135,
            child: CoreButton(
              icon: Icons.auto_stories_rounded,
              onTap: () {
                openCore(
                  'Personal',
                  Icons.auto_stories_rounded,
                );
              },
            ),
          ),

          Positioned(
            left: centerX - 175,
            top: centerY - 35,
            child: CoreButton(
              icon: Icons.track_changes_rounded,
              onTap: () {
                openCore(
                  'Goals',
                  Icons.track_changes_rounded,
                );
              },
            ),
          ),

          // ----------------------------------------------------
          // YANSI STATUS
          // ----------------------------------------------------

          Positioned(
            top: centerY + 117,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                yansiStatus,
                style: TextStyle(
                  fontSize: 8,
                  letterSpacing: 4,
                  color: listening
                      ? cyan
                      : thinking
                          ? green
                          : Colors.white
                              .withOpacity(0.35),
                ),
              ),
            ),
          ),

          // ----------------------------------------------------
          // TAP HINT
          // ----------------------------------------------------

          if (!listening && !thinking)
            Positioned(
              top: centerY + 145,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'TAP YANSI TO SPEAK',
                  style: TextStyle(
                    fontSize: 8,
                    letterSpacing: 2.5,
                    color:
                        Colors.white.withOpacity(0.25),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // VOICE STATE
  // ==========================================================

  Widget buildVoiceState() {
    return Positioned(
      left: 22,
      right: 22,
      bottom: 25,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF06131E)
              .withOpacity(0.94),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: listening
                ? cyan.withOpacity(0.5)
                : green.withOpacity(0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: listening
                  ? cyan.withOpacity(0.12)
                  : green.withOpacity(0.10),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              listening
                  ? Icons.graphic_eq_rounded
                  : Icons.psychology_rounded,
              color:
                  listening ? cyan : green,
              size: 22,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                listening
                    ? (heardText.isEmpty
                        ? 'Yansi is listening…'
                        : heardText)
                    : 'Yansi is thinking…',
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // CONTROL CENTER
  // ==========================================================

  Widget buildControlPanel() {
    return Positioned(
      top: 48,
      left: 10,
      child: Container(
        width: 245,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF06131E)
              .withOpacity(0.97),
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: cyan.withOpacity(0.28),
          ),
          boxShadow: [
            BoxShadow(
              color: cyan.withOpacity(0.10),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'LIFEOS CONTROL',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 3,
                color: cyan,
              ),
            ),

            const SizedBox(height: 16),

            controlItem(
              Icons.person_outline_rounded,
              'Profile',
            ),

            controlItem(
              Icons.mic_none_rounded,
              'Yansi & Voice',
            ),

            controlItem(
              Icons.notifications_none_rounded,
              'Notifications',
            ),

            controlItem(
              Icons.security_rounded,
              'Privacy & Permissions',
            ),

            controlItem(
              Icons.settings_outlined,
              'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget controlItem(
    IconData icon,
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color:
                Colors.white.withOpacity(0.72),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CORE
  // ==========================================================

  void openCore(
    String title,
    IconData icon,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoreScreen(
          title: title,
          icon: icon,
        ),
      ),
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    speech.stop();
    tts.stop();

    pulseController.dispose();
    orbitController.dispose();
    particleController.dispose();

    super.dispose();
  }
}

// ============================================================
// YANSI ORB
// ============================================================

class YansiOrb extends StatelessWidget {
  final double pulse;
  final double rotation;
  final bool listening;
  final bool thinking;

  const YansiOrb({
    super.key,
    required this.pulse,
    required this.rotation,
    required this.listening,
    required this.thinking,
  });

  @override
  Widget build(BuildContext context) {
    final scale =
        0.94 + (pulse * 0.08);

    final activeColor = listening
        ? cyan
        : thinking
            ? green
            : const Color(0xFF26D9FF);

    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: 210,
        height: 210,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Container(
              width: 205,
              height: 205,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: activeColor
                        .withOpacity(0.13),
                    blurRadius: 70,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),

            // Neural ring
            CustomPaint(
              size: const Size(195, 195),
              painter: NeuralRingPainter(
                rotation,
                activeColor,
              ),
            ),

            // Inner sphere
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    activeColor.withOpacity(0.45),
                    const Color(0xFF08253A),
                    background,
                  ],
                ),
                border: Border.all(
                  color: activeColor
                      .withOpacity(0.72),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: activeColor
                        .withOpacity(0.28),
                    blurRadius: 35,
                  ),
                ],
              ),
            ),

            // Core
            Container(
              width: 26 + pulse * 5,
              height: 26 + pulse * 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activeColor
                    .withOpacity(0.85),
                boxShadow: [
                  BoxShadow(
                    color: activeColor
                        .withOpacity(0.75),
                    blurRadius: 25,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),

            // YANSI label
            Positioned(
              bottom: 30,
              child: Text(
                'YANSI',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 5,
                  fontWeight:
                      FontWeight.w400,
                  color: Colors.white
                      .withOpacity(0.75),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CORE BUTTON
// ============================================================

class CoreButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const CoreButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF06131E)
              .withOpacity(0.92),
          border: Border.all(
            color: cyan.withOpacity(0.32),
          ),
          boxShadow: [
            BoxShadow(
              color: cyan.withOpacity(0.08),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 27,
          color: Colors.white
              .withOpacity(0.85),
        ),
      ),
    );
  }
}

// ============================================================
// TINY HUD BUTTON
// ============================================================

class TinyHudButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  const TinyHudButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF07141F)
                  .withOpacity(0.88),
              border: Border.all(
                color: Colors.white
                    .withOpacity(0.12),
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Colors.white
                  .withOpacity(0.72),
            ),
          ),

          if (showDot)
            Positioned(
              right: 3,
              top: 3,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: green,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// CORE SCREEN
// ============================================================

class CoreScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const CoreScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Icon(
              icon,
              color: cyan,
            ),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: SpacePainter(0.2),
            ),
          ),

          Center(
            child: Container(
              margin:
                  const EdgeInsets.all(24),
              padding:
                  const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF06131E)
                    .withOpacity(0.88),
                borderRadius:
                    BorderRadius.circular(24),
                border: Border.all(
                  color:
                      cyan.withOpacity(0.2),
                ),
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 55,
                    color: cyan,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 25,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Yansi will analyze this part of your life and provide insights here.',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: Colors.white
                          .withOpacity(0.55),
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
// SPACE BACKGROUND
// ============================================================

class SpacePainter extends CustomPainter {
  final double animation;

  SpacePainter(this.animation);

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint();

    paint.shader = const RadialGradient(
      center: Alignment(0, 0),
      radius: 1.0,
      colors: [
        Color(0xFF092237),
        background,
      ],
    ).createShader(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
    );

    canvas.drawRect(
      Offset.zero & size,
      paint,
    );

    final random =
        math.Random(41);

    final starPaint = Paint();

    for (int i = 0; i < 95; i++) {
      final x =
          random.nextDouble() *
              size.width;

      final y =
          random.nextDouble() *
              size.height;

      final brightness =
          0.15 +
          (math.sin(
                animation * math.pi * 2 +
                    i,
              ) +
              1) *
              0.12;

      starPaint.color =
          Colors.white.withOpacity(
        brightness,
      );

      canvas.drawCircle(
        Offset(x, y),
        random.nextDouble() * 1.2,
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant SpacePainter oldDelegate,
  ) {
    return oldDelegate.animation !=
        animation;
  }
}

// ============================================================
// ORBIT PAINTER
// ============================================================

class OrbitPainter extends CustomPainter {
  final double animation;

  OrbitPainter({
    required this.animation,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2,
      size.height * 0.50,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (int i = 0; i < 4; i++) {
      final radius =
          105.0 + i * 47;

      paint.color =
          cyan.withOpacity(
        0.07 - i * 0.01,
      );

      canvas.drawCircle(
        center,
        radius,
        paint,
      );
    }

    final nodePaint = Paint();

    for (int i = 0; i < 8; i++) {
      final angle =
          animation *
              math.pi *
              2 +
          i *
              math.pi /
              4;

      final radius =
          155.0 +
          (i % 2) * 35;

      final position = Offset(
        center.dx +
            math.cos(angle) *
                radius,
        center.dy +
            math.sin(angle) *
                radius *
                0.58,
      );

      nodePaint.color =
          (i % 2 == 0
                  ? cyan
                  : green)
              .withOpacity(0.32);

      canvas.drawCircle(
        position,
        2.2,
        nodePaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant OrbitPainter oldDelegate,
  ) {
    return oldDelegate.animation !=
        animation;
  }
}

// ============================================================
// NEURAL RING
// ============================================================

class NeuralRingPainter extends CustomPainter {
  final double rotation;
  final Color color;

  NeuralRingPainter(
    this.rotation,
    this.color,
  );

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final random =
        math.Random(17);

    final nodePaint = Paint()
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65;

    final points =
        <Offset>[];

    for (int i = 0; i < 32; i++) {
      final angle =
          rotation *
              math.pi *
              2 +
          i *
              math.pi *
              2 /
              32;

      final radius =
          76.0 +
          random.nextDouble() *
              15;

      points.add(
        Offset(
          center.dx +
              math.cos(angle) *
                  radius,
          center.dy +
              math.sin(angle) *
                  radius,
        ),
      );
    }

    for (int i = 0;
        i < points.length;
        i++) {
      for (int j = i + 1;
          j < points.length;
          j++) {
        final distance =
            (points[i] -
                    points[j])
                .distance;

        if (distance < 28) {
          linePaint.color =
              color.withOpacity(
            0.12,
          );

          canvas.drawLine(
            points[i],
            points[j],
            linePaint,
          );
        }
      }
    }

    for (final point in points) {
      nodePaint.color =
          color.withOpacity(0.52);

      canvas.drawCircle(
        point,
        1.4,
        nodePaint,
      );
    }

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color =
          color.withOpacity(0.22);

    canvas.drawCircle(
      center,
      82,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant NeuralRingPainter oldDelegate,
  ) {
    return oldDelegate.rotation !=
            rotation ||
        oldDelegate.color != color;
  }
}
