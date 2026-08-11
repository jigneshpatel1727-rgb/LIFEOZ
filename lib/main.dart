import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LifeOSApp());
}

const Color cyan = Color(0xFF00E5FF);
const Color green = Color(0xFF39FF72);
const Color background = Color(0xFF020912);

class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeOS',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: background,
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
  late final AnimationController pulseController;
  late final AnimationController particleController;

  final stt.SpeechToText speech = stt.SpeechToText();
  final FlutterTts tts = FlutterTts();

  bool listening = false;
  bool menuOpen = false;
  bool yansiReady = false;

  String heardText = '';

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    initializeYansi();
  }

  // ==========================================================
  // YANSI
  // ==========================================================

  Future<void> initializeYansi() async {
    try {
      await tts.setLanguage('en-IN');
      await tts.setSpeechRate(0.47);
      await tts.setPitch(1.0);
      await tts.setVolume(1.0);

      yansiReady = true;

      if (mounted) {
        setState(() {});
      }

      await Future.delayed(
        const Duration(milliseconds: 900),
      );

      if (!mounted) return;

      await speak(
        "Hello. I'm Yansi. Your LifeOS assistant is ready.",
      );
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    try {
      await tts.stop();
      await tts.speak(text);
    } catch (_) {}
  }

  // ==========================================================
  // VOICE
  // ==========================================================

  Future<void> startListening() async {
    if (!yansiReady) {
      await initializeYansi();
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

    if (!mounted) return;

    setState(() {
      listening = true;
      heardText = '';
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
          });

          processCommand(
            result.recognizedWords,
          );
        }
      },
    );
  }

  // ==========================================================
  // COMMAND PROCESSING
  // ==========================================================

  Future<void> processCommand(String text) async {
    final lower = text.toLowerCase();
    final amount = extractAmount(text);

    final isExpense =
        amount != null &&
        (
          lower.contains('spent') ||
          lower.contains('paid') ||
          lower.contains('buy') ||
          lower.contains('bought') ||
          lower.contains('expense') ||
          lower.contains('rupee') ||
          lower.contains('rupees') ||
          lower.contains('rs') ||
          lower.contains('₹')
        );

    // --------------------------------------------------------
    // EXPENSE
    // --------------------------------------------------------

    if (isExpense) {
      final category = detectCategory(lower);

      await saveExpense(
        amount,
        category,
        text,
      );

      await speak(
        'Done. I added ₹${amount.toStringAsFixed(0)} '
        'to today’s $category expenses.',
      );

      return;
    }

    // --------------------------------------------------------
    // SHOPPING
    // --------------------------------------------------------

    if (lower.contains('shopping') ||
        lower.contains('shopping list') ||
        lower.contains('add milk') ||
        lower.contains('add bread') ||
        lower.contains('buy milk') ||
        lower.contains('buy bread')) {
      final item = extractShoppingItem(text);

      await saveShoppingItem(item);

      await speak(
        'Done. I added $item to your shopping list.',
      );

      return;
    }

    // --------------------------------------------------------
    // DIARY
    // --------------------------------------------------------

    if (lower.contains('diary') ||
        lower.contains('journal') ||
        lower.contains('write in my diary')) {
      await saveDiary(text);

      await speak(
        "Done. I've saved that in your diary.",
      );

      return;
    }

    // --------------------------------------------------------
    // TASK
    // --------------------------------------------------------

    if (lower.contains('remind me') ||
        lower.contains('reminder') ||
        lower.contains('remember to') ||
        lower.contains('task')) {
      await saveTask(text);

      await speak(
        "Done. I've saved that as a task.",
      );

      return;
    }

    // --------------------------------------------------------
    // GREETING
    // --------------------------------------------------------

    if (lower.contains('hello') ||
        lower.contains('hi yansi') ||
        lower.contains('hello yansi')) {
      await speak(
        "Hello. I'm Yansi. I'm ready to help you.",
      );

      return;
    }

    // --------------------------------------------------------
    // DEFAULT
    // --------------------------------------------------------

    await speak(
      'I heard you say: $text. '
      'You can tell me an expense, shopping item, '
      'diary entry, or reminder.',
    );
  }

  // ==========================================================
  // AMOUNT
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

  Future<void> saveShoppingItem(
    String item,
  ) async {
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

  Future<void> saveDiary(
    String text,
  ) async {
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

  Future<void> saveTask(
    String text,
  ) async {
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

  String extractShoppingItem(
    String text,
  ) {
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
  // CORE NAVIGATION
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
          particleController,
        ]),
        builder: (context, child) {
          return SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: SpacePainter(
                      particleController.value,
                    ),
                  ),
                ),

                buildSmallMenu(),

                buildSmallBell(),

                Center(
                  child: buildLifeOSLayout(),
                ),

                if (menuOpen)
                  buildSideMenu(),

                if (listening)
                  buildListeningPanel(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // SMALL MENU
  // ==========================================================

  Widget buildSmallMenu() {
    return Positioned(
      top: 6,
      left: 9,
      child: TinyHudButton(
        icon: menuOpen
            ? Icons.close_rounded
            : Icons.menu_rounded,
        onTap: () {
          setState(() {
            menuOpen = !menuOpen;
          });
        },
      ),
    );
  }

  // ==========================================================
  // SMALL BELL
  // ==========================================================

  Widget buildSmallBell() {
    return Positioned(
      top: 6,
      right: 9,
      child: TinyHudButton(
        icon: Icons.notifications_none_rounded,
        showDot: true,
        onTap: () {
          speak(
            'You have no new LifeOS alerts.',
          );
        },
      ),
    );
  }

  // ==========================================================
  // MAIN FUTURISTIC LAYOUT
  // ==========================================================

  Widget buildLifeOSLayout() {
    final size = MediaQuery.sizeOf(context);

    final width = size.width;
    final height = size.height;

    final centerY = height * 0.50;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: OrbitPainter(),
              ),
            ),
          ),

          // ----------------------------------------------------
          // TITLE
          // ----------------------------------------------------

          Positioned(
            top: 94,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'L I F E O S',
                style: TextStyle(
                  fontSize: 27,
                  letterSpacing: 12,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withOpacity(0.92),
                ),
              ),
            ),
          ),

          // ----------------------------------------------------
          // MONEY
          // ----------------------------------------------------

          Positioned(
            top: centerY - 150,
            left: width / 2 - 40,
            child: buildCore(
              Icons.account_balance_wallet_rounded,
              () {
                openCore(
                  'Money',
                  Icons.account_balance_wallet_rounded,
                );
              },
              80,
            ),
          ),

          // ----------------------------------------------------
          // PLANNING
          // ----------------------------------------------------

          Positioned(
            top: centerY + 28,
            left: 10,
            child: buildCore(
              Icons.calendar_month_rounded,
              () {
                openCore(
                  'Planning',
                  Icons.calendar_month_rounded,
                );
              },
              72,
            ),
          ),

          // ----------------------------------------------------
          // HEALTH
          // ----------------------------------------------------

          Positioned(
            top: centerY + 28,
            right: 10,
            child: buildCore(
              Icons.favorite_rounded,
              () {
                openCore(
                  'Health',
                  Icons.favorite_rounded,
                );
              },
              72,
            ),
          ),

          // ----------------------------------------------------
          // SHOPPING
          // ----------------------------------------------------

          Positioned(
            top: centerY + 270,
            left: 62,
            child: buildCore(
              Icons.shopping_cart_rounded,
              () {
                openCore(
                  'Shopping',
                  Icons.shopping_cart_rounded,
                );
              },
              72,
            ),
          ),

          // ----------------------------------------------------
          // GROWTH
          // ----------------------------------------------------

          Positioned(
            top: centerY + 270,
            right: 62,
            child: buildCore(
              Icons.auto_graph_rounded,
              () {
                openCore(
                  'Growth',
                  Icons.auto_graph_rounded,
                );
              },
              72,
            ),
          ),

          // ----------------------------------------------------
          // YANSI
          // ----------------------------------------------------

          Positioned(
            top: centerY - 4,
            left: width / 2 - 78,
            child: buildYansi(156),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CORE BUTTON
  // ==========================================================

  Widget buildCore(
    IconData icon,
    VoidCallback onTap,
    double size,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(
            0xFF061723,
          ).withOpacity(0.92),
          border: Border.all(
            color: cyan.withOpacity(0.95),
            width: 1.7,
          ),
          boxShadow: [
            BoxShadow(
              color: cyan.withOpacity(0.22),
              blurRadius: 24,
            ),
            BoxShadow(
              color: green.withOpacity(0.12),
              blurRadius: 44,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: size * 0.42,
            color: green,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // YANSI
  // ==========================================================

  Widget buildYansi(double size) {
    return GestureDetector(
      onTap: listening
          ? () {
              speech.stop();

              setState(() {
                listening = false;
              });
            }
          : startListening,
      child: AnimatedBuilder(
        animation: pulseController,
        builder: (_, __) {
          final glow =
              18 + pulseController.value * 20;

          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF04131F),
              border: Border.all(
                color: cyan,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: cyan.withOpacity(0.25),
                  blurRadius: glow,
                ),
                BoxShadow(
                  color: green.withOpacity(0.16),
                  blurRadius: glow * 2,
                ),
              ],
            ),
            child: CustomPaint(
              painter: YansiPainter(
                pulseController.value,
              ),
              child: Center(
                child: Icon(
                  listening
                      ? Icons.mic_rounded
                      : Icons.psychology_rounded,
                  size: 60,
                  color: green,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // SIDE MENU
  // ==========================================================

  Widget buildSideMenu() {
    return Positioned(
      top: 48,
      left: 9,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 205,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(
              0xFF06131D,
            ).withOpacity(0.97),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: cyan.withOpacity(0.55),
            ),
            boxShadow: [
              BoxShadow(
                color: cyan.withOpacity(0.18),
                blurRadius: 28,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'LIFEOS',
                style: TextStyle(
                  letterSpacing: 4,
                  color: cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              menuRow(
                Icons.account_balance_wallet_rounded,
                'Money',
                () {
                  openCore(
                    'Money',
                    Icons.account_balance_wallet_rounded,
                  );
                },
              ),

              menuRow(
                Icons.calendar_month_rounded,
                'Planning',
                () {
                  openCore(
                    'Planning',
                    Icons.calendar_month_rounded,
                  );
                },
              ),

              menuRow(
                Icons.favorite_rounded,
                'Health',
                () {
                  openCore(
                    'Health',
                    Icons.favorite_rounded,
                  );
                },
              ),

              menuRow(
                Icons.shopping_cart_rounded,
                'Shopping',
                () {
                  openCore(
                    'Shopping',
                    Icons.shopping_cart_rounded,
                  );
                },
              ),

              menuRow(
                Icons.auto_graph_rounded,
                'Growth',
                () {
                  openCore(
                    'Growth',
                    Icons.auto_graph_rounded,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget menuRow(
    IconData icon,
    String text,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          menuOpen = false;
        });

        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: green,
              size: 21,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // LISTENING PANEL
  // ==========================================================

  Widget buildListeningPanel() {
    return Positioned(
      left: 22,
      right: 22,
      bottom: 22,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(
            0xFF06131D,
          ).withOpacity(0.94),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cyan.withOpacity(0.6),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.graphic_eq_rounded,
              color: green,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                heardText.isEmpty
                    ? 'Yansi is listening...'
                    : heardText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            IconButton(
              onPressed: () {
                speech.stop();

                setState(() {
                  listening = false;
                });
              },
              icon: const Icon(
                Icons.close_rounded,
                size: 19,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SMALL HUD BUTTON
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
      child: Container(
        width: 40,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(
            0xFF04131F,
          ).withOpacity(0.82),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: cyan.withOpacity(0.65),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: cyan.withOpacity(0.10),
              blurRadius: 12,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              color: green,
              size: 19,
            ),

            if (showDot)
              Positioned(
                top: 6,
                right: 7,
                child: Container(
                  width: 4.5,
                  height: 4.5,
                  decoration:
                      const BoxDecoration(
                    shape: BoxShape.circle,
                    color: green,
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
// BACKGROUND
// ============================================================

class SpacePainter extends CustomPainter {
  final double progress;

  SpacePainter(this.progress);

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = background,
    );

    final gridPaint = Paint()
      ..color = cyan.withOpacity(0.035)
      ..style = PaintingStyle.stroke;

    for (
      double y = 0;
      y < size.height;
      y += 42
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    for (
      double x = 0;
      x < size.width;
      x += 42
    ) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    final particlePaint = Paint()
      ..color = cyan.withOpacity(0.35);

    for (int i = 0; i < 34; i++) {
      final x =
          (i * 83.7) % size.width;

      final y =
          ((i * 47.3) +
                  progress * 80) %
              size.height;

      canvas.drawCircle(
        Offset(x, y),
        i % 4 == 0 ? 1.5 : 0.7,
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant SpacePainter oldDelegate,
  ) {
    return oldDelegate.progress != progress;
  }
}

// ============================================================
// ORBIT / NEURAL CONNECTIONS
// ============================================================

class OrbitPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2,
      size.height * 0.50 + 55,
    );

    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = cyan.withOpacity(0.13);

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.92,
        height: size.height * 0.62,
      ),
      orbitPaint,
    );

    final secondOrbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = green.withOpacity(0.10);

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.72,
        height: size.height * 0.46,
      ),
      secondOrbit,
    );

    final neuralPath = Path();

    neuralPath.moveTo(
      center.dx,
      center.dy - 115,
    );

    neuralPath.quadraticBezierTo(
      35,
      center.dy - 20,
      center.dx,
      center.dy + 45,
    );

    neuralPath.quadraticBezierTo(
      size.width - 35,
      center.dy - 20,
      center.dx,
      center.dy - 115,
    );

    canvas.drawPath(
      neuralPath,
      orbitPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant OrbitPainter oldDelegate,
  ) {
    return false;
  }
}

// ============================================================
// YANSI NEURAL PAINTER
// ============================================================

class YansiPainter extends CustomPainter {
  final double progress;

  YansiPainter(this.progress);

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = size.center;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = cyan.withOpacity(0.35);

    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        center,
        34 + i * 13 + progress * 3,
        ringPaint,
      );
    }

    final nodePaint = Paint()
      ..color = cyan.withOpacity(0.65);

    for (int i = 0; i < 10; i++) {
      final angle =
          i * math.pi * 2 / 10;

      const radius = 45.0;

      final point = center +
          Offset(
            math.cos(angle) * radius,
            math.sin(angle) * radius,
          );

      canvas.drawCircle(
        point,
        2.2,
        nodePaint,
      );

      canvas.drawLine(
        center,
        point,
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant YansiPainter oldDelegate,
  ) {
    return oldDelegate.progress != progress;
  }
}

// ============================================================
// CORE DETAIL SCREEN
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
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: cyan,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: cyan.withOpacity(0.20),
                blurRadius: 35,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: green,
            size: 90,
          ),
        ),
      ),
    );
  }
}
