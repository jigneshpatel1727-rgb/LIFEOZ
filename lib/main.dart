import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LifeOSApp());
}

// ============================================================
// LIFEOS APP
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
        fontFamily: 'Roboto',
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
const Color deepBlue = Color(0xFF031522);

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

  bool menuOpen = false;
  bool notifications = true;

  final stt.SpeechToText speech = stt.SpeechToText();

  bool listening = false;
  String heardText = '';

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    pulseController.dispose();
    rotationController.dispose();
    particleController.dispose();
    super.dispose();
  }

  Future<void> startYansiListening() async {
    final available = await speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() {
              listening = false;
            });
          }
        }
      },
      onError: (_) {
        if (mounted) {
          setState(() {
            listening = false;
          });
        }
      },
    );

    if (!available) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice recognition is not available on this device.'),
        ),
      );
      return;
    }

    setState(() {
      listening = true;
      heardText = '';
    });

    await speech.listen(
      onResult: (result) {
        if (!mounted) return;

        setState(() {
          heardText = result.recognizedWords;
        });

        if (result.finalResult) {
          setState(() {
            listening = false;
          });

          _processYansiCommand(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
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

  Future<void> _processYansiCommand(String text) async {
    final lower = text.toLowerCase();

    final amount = extractAmount(text);

    if (amount != null &&
        (lower.contains('expense') ||
            lower.contains('spent') ||
            lower.contains('paid') ||
            lower.contains('buy') ||
            lower.contains('bought') ||
            lower.contains('rupees') ||
            lower.contains('rs'))) {
      final category = detectCategory(lower);

      await saveExpense(amount, category, text);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => YansiMessage(
          title: 'Expense Recorded',
          message:
              'I understood:\n\n₹${amount.toStringAsFixed(0)}\n'
              '$category\n\nI added it to today\'s expenses.',
        ),
      );

      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => YansiMessage(
        title: 'Yansi',
        message:
            'I heard:\n\n"$text"\n\n'
            'You can say things like:\n'
            '• I spent 500 on fuel\n'
            '• I paid 1200 electricity bill\n'
            '• I spent 300 on milk',
      ),
    );
  }

  double? extractAmount(String text) {
    final cleaned = text
        .toLowerCase()
        .replaceAll(',', '')
        .replaceAll('₹', '')
        .replaceAll('rs.', 'rs')
        .replaceAll('rupees', '');

    final match = RegExp(
      r'(?:rs\s*)?(\d+(?:\.\d+)?)',
    ).firstMatch(cleaned);

    if (match == null) return null;

    return double.tryParse(match.group(1)!);
  }

  String detectCategory(String text) {
    if (text.contains('fuel') ||
        text.contains('petrol') ||
        text.contains('diesel')) {
      return 'Fuel';
    }

    if (text.contains('electric')) {
      return 'Electricity';
    }

    if (text.contains('milk')) {
      return 'Milk';
    }

    if (text.contains('food') ||
        text.contains('restaurant') ||
        text.contains('lunch') ||
        text.contains('dinner')) {
      return 'Food';
    }

    if (text.contains('shopping') ||
        text.contains('shirt') ||
        text.contains('clothes')) {
      return 'Shopping';
    }

    if (text.contains('medicine') ||
        text.contains('medical') ||
        text.contains('doctor')) {
      return 'Medical';
    }

    if (text.contains('emi') || text.contains('loan')) {
      return 'EMI';
    }

    if (text.contains('bill')) {
      return 'Bills';
    }

    return 'Other';
  }

  Future<void> saveExpense(
    double amount,
    String category,
    String note,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final existing = prefs.getStringList('expenses') ?? [];

    final item =
        '${DateTime.now().toIso8601String()}|$category|$amount|$note';

    existing.add(item);

    await prefs.setStringList('expenses', existing);
  }

  void openCore(String title, IconData icon) {
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
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height = constraints.maxHeight;

                    return Stack(
                      children: [
                        // MENU
                        Positioned(
                          top: 12,
                          left: 12,
                          child: HudButton(
                            icon: menuOpen
                                ? Icons.close_rounded
                                : Icons.menu_rounded,
                            onTap: () {
                              setState(() {
                                menuOpen = !menuOpen;
                              });
                            },
                          ),
                        ),

                        // BELL
                        Positioned(
                          top: 12,
                          right: 12,
                          child: BellButton(
                            active: notifications,
                            onTap: () {
                              setState(() {
                                notifications = !notifications;
                              });
                            },
                          ),
                        ),

                        // TITLE
                        Positioned(
                          top: 70,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              'L I F E O S',
                              style: TextStyle(
                                color: Colors.white.withOpacity(.9),
                                fontSize: 25,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 8,
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
                          top: 120,
                          bottom: 0,
                          child: CustomPaint(
                            painter: NeuralNetworkPainter(
                              pulse: pulseController.value,
                              rotation: rotationController.value,
                            ),
                          ),
                        ),

                        // FINANCE
                        Positioned(
                          top: height * .15,
                          left: width / 2 - 61,
                          child: CoreOrb(
                            size: 122,
                            icon: Icons.account_balance_wallet_rounded,
                            color: cyan,
                            pulse: pulseController.value,
                            onTap: () => openCore(
                              'Finance',
                              Icons.account_balance_wallet_rounded,
                            ),
                          ),
                        ),

                        // CALENDAR
                        Positioned(
                          top: height * .34,
                          left: -8,
                          child: CoreOrb(
                            size: 116,
                            icon: Icons.calendar_month_rounded,
                            color: cyan,
                            pulse: pulseController.value,
                            onTap: () => openCore(
                              'Calendar',
                              Icons.calendar_month_rounded,
                            ),
                          ),
                        ),

                        // HEALTH
                        Positioned(
                          top: height * .34,
                          right: -8,
                          child: CoreOrb(
                            size: 116,
                            icon: Icons.favorite_rounded,
                            color: green,
                            pulse: pulseController.value,
                            onTap: () => openCore(
                              'Health',
                              Icons.favorite_rounded,
                            ),
                          ),
                        ),

                        // YANSI
                        Positioned(
                          top: height * .39,
                          left: width / 2 - 95,
                          child: YansiOrb(
                            size: 190,
                            pulse: pulseController.value,
                            rotation: rotationController.value,
                            listening: listening,
                            onTap: () {
                              if (listening) {
                                stopListening();
                              } else {
                                startYansiListening();
                              }
                            },
                          ),
                        ),

                        // SHOPPING
                        Positioned(
                          top: height * .61,
                          left: 15,
                          child: CoreOrb(
                            size: 112,
                            icon: Icons.shopping_cart_rounded,
                            color: green,
                            pulse: pulseController.value,
                            onTap: () => openCore(
                              'Shopping',
                              Icons.shopping_cart_rounded,
                            ),
                          ),
                        ),

                        // GOALS
                        Positioned(
                          top: height * .61,
                          right: 15,
                          child: CoreOrb(
                            size: 112,
                            icon: Icons.track_changes_rounded,
                            color: green,
                            pulse: pulseController.value,
                            onTap: () => openCore(
                              'Goals',
                              Icons.track_changes_rounded,
                            ),
                          ),
                        ),

                        // LISTENING TEXT
                        if (listening)
                          Positioned(
                            left: 30,
                            right: 30,
                            bottom: 65,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xDD031522),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: green.withOpacity(.5),
                                ),
                              ),
                              child: Text(
                                heardText.isEmpty
                                    ? 'Yansi is listening...'
                                    : heardText,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                        // MENU
                        if (menuOpen)
                          Positioned(
                            top: 62,
                            left: 12,
                            child: MenuPanel(
                              close: () {
                                setState(() {
                                  menuOpen = false;
                                });
                              },
                              openCore: openCore,
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
          borderRadius: BorderRadius.circular(12),
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
        child: const Icon(
          Icons.menu_rounded,
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
          borderRadius: BorderRadius.circular(12),
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
        child: Stack(
          children: [
            Center(
              child: Icon(
                active
                    ? Icons.notifications_none_rounded
                    : Icons.notifications_off_outlined,
                color: green,
                size: 20,
              ),
            ),
            if (active)
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
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
    final glow = 12 + pulse * 15;

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
                color: const Color(0xCC031522),
                border: Border.all(
                  color: color.withOpacity(.9),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(.5),
                    blurRadius: glow,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: size * .22,
                color: color,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  listening
                      ? Icons.graphic_eq_rounded
                      : Icons.psychology_rounded,
                  size: 52,
                  color: green,
                ),
                const SizedBox(height: 7),
                Text(
                  listening ? 'LISTENING' : 'YANSI',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
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
// CORE DETAIL SCREEN
// ============================================================

class CoreDetailScreen extends StatelessWidget {
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
      backgroundColor: const Color(0xFF01070D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          title,
          style: const TextStyle(
            letterSpacing: 2,
          ),
        ),
        iconTheme: const IconThemeData(
          color: cyan,
        ),
      ),
      body: Stack(
        children: [
          const FuturisticBackground(),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cyan,
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x5500E5FF),
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
                  const SizedBox(height: 30),
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 25,
                      letterSpacing: 5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Your $title intelligence center will show '
                    'reports, trends, analysis and recommendations here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.65),
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
// YANSI MESSAGE
// ============================================================

class YansiMessage extends StatelessWidget {
  final String title;
  final String message;

  const YansiMessage({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF031522),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: cyan.withOpacity(.5),
        ),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.psychology_rounded,
            color: green,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: cyan,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'OK',
            style: TextStyle(
              color: green,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// MENU PANEL
// ============================================================

class MenuPanel extends StatelessWidget {
  final VoidCallback close;
  final void Function(String, IconData) openCore;

  const MenuPanel({
    super.key,
    required this.close,
    required this.openCore,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Finance', Icons.account_balance_wallet_rounded),
      ('Calendar', Icons.calendar_month_rounded),
      ('Health', Icons.favorite_rounded),
      ('Shopping', Icons.shopping_cart_rounded),
      ('Goals', Icons.track_changes_rounded),
    ];

    return Container(
      width: 205,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xF5031522),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cyan.withOpacity(.55),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x6600E5FF),
            blurRadius: 25,
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
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
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                close();
                openCore(item.$1, item.$2);
              },
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

class FuturisticBackground extends StatelessWidget {
  const FuturisticBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, .25),
          radius: 1.15,
          colors: [
            Color(0xFF06283B),
            Color(0xFF020D17),
            Color(0xFF01050A),
          ],
        ),
      ),
      child: CustomPaint(
        painter: CircuitPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ============================================================
// CORE PAINTER
// ============================================================

class CorePainter extends CustomPainter {
  final Color color;
  final double pulse;

  CorePainter({
    required this.color,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2;

    final glowPaint = Paint()
      ..color = color.withOpacity(.18 + pulse * .1)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        16,
      );

    canvas.drawCircle(
      center,
      radius * .73,
      glowPaint,
    );

    final ringPaint = Paint()
      ..color = color.withOpacity(.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    canvas.drawCircle(
      center,
      radius * .83,
      ringPaint,
    );

    canvas.drawCircle(
      center,
      radius * .68,
      ringPaint,
    );

    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;

      final start = Offset(
        center.dx + math.cos(angle) * radius * .84,
        center.dy + math.sin(angle) * radius * .84,
      );

      final end = Offset(
        center.dx + math.cos(angle) * radius * .94,
        center.dy + math.sin(angle) * radius * .94,
      );

      canvas.drawLine(start, end, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CorePainter oldDelegate) => true;
}

// ============================================================
// YANSI PAINTER
// ============================================================

class YansiPainter extends CustomPainter {
  final double pulse;
  final double rotation;
  final bool listening;

  YansiPainter({
    required this.pulse,
    required this.rotation,
    required this.listening,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2;

    final glow = Paint()
      ..color = green.withOpacity(
        listening ? .28 : .16 + pulse * .1,
      )
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        22,
      );

    canvas.drawCircle(
      center,
      radius * .65,
      glow,
    );

    final ring = Paint()
      ..color = cyan.withOpacity(.7)
      ..style = PaintingStyle.stroke
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
        ..color = green.withOpacity(.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    canvas.save();

    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * math.pi * 2);

    for (int i = 0; i < 16; i++) {
      final angle = i * math.pi * 2 / 16;

      final inner = radius * .77;
      final outer = radius * (.86 + pulse * .05);

      final p1 = Offset(
        math.cos(angle) * inner,
        math.sin(angle) * inner,
      );

      final p2 = Offset(
        math.cos(angle) * outer,
        math.sin(angle) * outer,
      );

      canvas.drawLine(p1, p2, ring);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant YansiPainter oldDelegate) => true;
}

// ============================================================
// PARTICLES
// ============================================================

class ParticlePainter extends CustomPainter {
  final double progress;

  ParticlePainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < 35; i++) {
      final x = ((i * 73.0) % size.width);

      final baseY = ((i * 127.0) % size.height);

      final y =
          (baseY + progress * size.height * .4) % size.height;

      final opacity = .15 + ((i % 5) * .07);

      paint.color = (i % 2 == 0 ? cyan : green)
          .withOpacity(opacity);

      canvas.drawCircle(
        Offset(x, y),
        1.1 + (i % 3) * .4,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}

// ============================================================
// NEURAL NETWORK
// ============================================================

class NeuralNetworkPainter extends CustomPainter {
  final double pulse;
  final double rotation;

  NeuralNetworkPainter({
    required this.pulse,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height * .48,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7
      ..color = cyan.withOpacity(.22);

    final nodePaint = Paint()
      ..color = green.withOpacity(.55 + pulse * .2);

    final points = <Offset>[];

    for (int i = 0; i < 18; i++) {
      final angle = rotation * math.pi * 2 +
          i * math.pi * 2 / 18;

      final radius =
          size.width * (.18 + (i % 4) * .035);

      points.add(
        Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius * .7,
        ),
      );
    }

    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        if ((points[i] - points[j]).distance <
            size.width * .13) {
          canvas.drawLine(
            points[i],
            points[j],
            paint,
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
  bool shouldRepaint(covariant NeuralNetworkPainter oldDelegate) =>
      true;
}

// ============================================================
// CIRCUIT BACKGROUND
// ============================================================

class CircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cyan.withOpacity(.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const gap = 42.0;

    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CircuitPainter oldDelegate) => false;
}
