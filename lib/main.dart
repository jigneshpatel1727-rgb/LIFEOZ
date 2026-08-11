import 'dart:math' as math;
import 'package:flutter/material.dart';

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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF010812),
        fontFamily: 'Roboto',
      ),
      home: const LifeOSHome(),
    );
  }
}

class LifeOSHome extends StatefulWidget {
  const LifeOSHome({super.key});

  @override
  State<LifeOSHome> createState() => _LifeOSHomeState();
}

class _LifeOSHomeState extends State<LifeOSHome>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late AnimationController _rotationController;

  bool menuOpen = false;
  bool notificationOn = true;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _particleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _showCore(String title, IconData icon) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoreScreen(
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
          _pulseController,
          _particleController,
          _rotationController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              const FuturisticBackground(),

              Positioned.fill(
                child: CustomPaint(
                  painter: ParticlePainter(
                    progress: _particleController.value,
                  ),
                ),
              ),

              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;

                    return Stack(
                      children: [
                        // --------------------------------------------
                        // SMALL MENU BUTTON
                        // --------------------------------------------
                        Positioned(
                          top: 18,
                          left: 18,
                          child: SmallHudButton(
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

                        // --------------------------------------------
                        // SMALL SMART BELL
                        // --------------------------------------------
                        Positioned(
                          top: 18,
                          right: 18,
                          child: SmallBellButton(
                            active: notificationOn,
                            onTap: () {
                              setState(() {
                                notificationOn = !notificationOn;
                              });
                            },
                          ),
                        ),

                        // --------------------------------------------
                        // LIFEOS TITLE
                        // --------------------------------------------
                        Positioned(
                          top: 82,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              'L I F E O S',
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 9,
                                color: Colors.white.withOpacity(0.88),
                                shadows: const [
                                  Shadow(
                                    color: Color(0xFF00E5FF),
                                    blurRadius: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // --------------------------------------------
                        // ENERGY NETWORK
                        // --------------------------------------------
                        Positioned.fill(
                          top: 145,
                          bottom: 10,
                          child: CustomPaint(
                            painter: NeuralNetworkPainter(
                              pulse: _pulseController.value,
                              rotation: _rotationController.value,
                            ),
                          ),
                        ),

                        // --------------------------------------------
                        // TOP FINANCE CORE
                        // --------------------------------------------
                        Positioned(
                          top: h * 0.17,
                          left: w / 2 - 67,
                          child: FuturisticCore(
                            size: 134,
                            icon: Icons.account_balance_wallet_rounded,
                            color: const Color(0xFF00E5FF),
                            pulse: _pulseController.value,
                            onTap: () => _showCore(
                              'Finance',
                              Icons.account_balance_wallet_rounded,
                            ),
                          ),
                        ),

                        // --------------------------------------------
                        // LEFT CALENDAR CORE
                        // --------------------------------------------
                        Positioned(
                          top: h * 0.36,
                          left: -4,
                          child: FuturisticCore(
                            size: 126,
                            icon: Icons.calendar_month_rounded,
                            color: const Color(0xFF00D9FF),
                            pulse: _pulseController.value,
                            onTap: () => _showCore(
                              'Calendar',
                              Icons.calendar_month_rounded,
                            ),
                          ),
                        ),

                        // --------------------------------------------
                        // RIGHT HEALTH CORE
                        // --------------------------------------------
                        Positioned(
                          top: h * 0.36,
                          right: -4,
                          child: FuturisticCore(
                            size: 126,
                            icon: Icons.favorite_rounded,
                            color: const Color(0xFF39FF88),
                            pulse: _pulseController.value,
                            onTap: () => _showCore(
                              'Health',
                              Icons.favorite_rounded,
                            ),
                          ),
                        ),

                        // --------------------------------------------
                        // CENTER YANSI AI
                        // --------------------------------------------
                        Positioned(
                          top: h * 0.39,
                          left: w / 2 - 108,
                          child: YansiCore(
                            size: 216,
                            pulse: _pulseController.value,
                            rotation: _rotationController.value,
                            onTap: () {
                              _showYansiDialog(context);
                            },
                          ),
                        ),

                        // --------------------------------------------
                        // LEFT BOTTOM SHOPPING CORE
                        // --------------------------------------------
                        Positioned(
                          top: h * 0.62,
                          left: 22,
                          child: FuturisticCore(
                            size: 124,
                            icon: Icons.shopping_cart_rounded,
                            color: const Color(0xFF45FF82),
                            pulse: _pulseController.value,
                            onTap: () => _showCore(
                              'Shopping',
                              Icons.shopping_cart_rounded,
                            ),
                          ),
                        ),

                        // --------------------------------------------
                        // RIGHT BOTTOM GOALS CORE
                        // --------------------------------------------
                        Positioned(
                          top: h * 0.62,
                          right: 22,
                          child: FuturisticCore(
                            size: 124,
                            icon: Icons.track_changes_rounded,
                            color: const Color(0xFF39FF88),
                            pulse: _pulseController.value,
                            onTap: () => _showCore(
                              'Goals',
                              Icons.track_changes_rounded,
                            ),
                          ),
                        ),

                        // --------------------------------------------
                        // BOTTOM HOLOGRAPHIC PLATFORM
                        // --------------------------------------------
                        Positioned(
                          bottom: 5,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: SizedBox(
                              height: 100,
                              child: CustomPaint(
                                painter: HolographicPlatformPainter(
                                  rotation: _rotationController.value,
                                  pulse: _pulseController.value,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // --------------------------------------------
                        // MENU PANEL
                        // --------------------------------------------
                        if (menuOpen)
                          Positioned(
                            top: 70,
                            left: 18,
                            child: FuturisticMenu(
                              onClose: () {
                                setState(() {
                                  menuOpen = false;
                                });
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

  void _showYansiDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
          decoration: BoxDecoration(
            color: const Color(0xFF03121D).withOpacity(0.97),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF00E5FF).withOpacity(0.55),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x6600E5FF),
                blurRadius: 35,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.psychology_rounded,
                size: 55,
                color: Color(0xFF45FF82),
              ),
              const SizedBox(height: 12),
              const Text(
                'YANSI AI',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Color(0xFF00E5FF),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hello. I am Yansi.\n'
                'I am ready to understand your day, '
                'organize your information and help you manage LifeOS.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF39FF88).withOpacity(0.5),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'YANSI IS READY',
                    style: TextStyle(
                      color: Color(0xFF45FF82),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// FUTURISTIC BACKGROUND
// ============================================================

class FuturisticBackground extends StatelessWidget {
  const FuturisticBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, 0.25),
          radius: 1.05,
          colors: [
            Color(0xFF062034),
            Color(0xFF020C17),
            Color(0xFF01050B),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: CircuitBackgroundPainter(),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.72,
                    colors: [
                      const Color(0x0000E5FF),
                      const Color(0x0000E5FF),
                      const Color(0xAA000000),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SMALL HUD BUTTON
// ============================================================

class SmallHudButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const SmallHudButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF041522).withOpacity(0.72),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFF00E5FF).withOpacity(0.75),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x5500E5FF),
              blurRadius: 13,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 22,
          color: const Color(0xFF45FF82),
        ),
      ),
    );
  }
}

// ============================================================
// SMALL SMART BELL
// ============================================================

class SmallBellButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const SmallBellButton({
    super.key,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 48,
        height: 42,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 48,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF041522).withOpacity(0.72),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withOpacity(0.75),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x5500E5FF),
                    blurRadius: 13,
                  ),
                ],
              ),
              child: Icon(
                active
                    ? Icons.notifications_none_rounded
                    : Icons.notifications_off_outlined,
                size: 22,
                color: const Color(0xFF45FF82),
              ),
            ),
            if (active)
              Positioned(
                right: 8,
                top: 7,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF45FF82),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF45FF82),
                        blurRadius: 6,
                      ),
                    ],
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
// FUTURISTIC CORE
// ============================================================

class FuturisticCore extends StatelessWidget {
  final double size;
  final IconData icon;
  final Color color;
  final double pulse;
  final VoidCallback onTap;

  const FuturisticCore({
    super.key,
    required this.size,
    required this.icon,
    required this.color,
    required this.pulse,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final glow = 20 + (pulse * 18);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 0.78,
              height: size * 0.78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.22),
                    blurRadius: glow,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),

            CustomPaint(
              size: Size(size, size),
              painter: CoreRingPainter(
                color: color,
                pulse: pulse,
              ),
            ),

            Container(
              width: size * 0.63,
              height: size * 0.63,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.12),
                    const Color(0xFF03131E).withOpacity(0.96),
                  ],
                ),
                border: Border.all(
                  color: color.withOpacity(0.65),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: size * 0.30,
                color: color,
                shadows: [
                  Shadow(
                    color: color,
                    blurRadius: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// YANSI AI CORE
// ============================================================

class YansiCore extends StatelessWidget {
  final double size;
  final double pulse;
  final double rotation;
  final VoidCallback onTap;

  const YansiCore({
    super.key,
    required this.size,
    required this.pulse,
    required this.rotation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 0.70,
              height: size * 0.70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.35),
                    blurRadius: 40 + pulse * 20,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: const Color(0xFF39FF88).withOpacity(0.18),
                    blurRadius: 55,
                  ),
                ],
              ),
            ),

            CustomPaint(
              size: Size(size, size),
              painter: YansiRingPainter(
                pulse: pulse,
                rotation: rotation,
              ),
            ),

            Container(
              width: size * 0.60,
              height: size * 0.60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF0A2B3D),
                    Color(0xFF03101A),
                    Color(0xFF01070D),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withOpacity(0.65),
                  width: 2,
                ),
              ),
              child: CustomPaint(
                painter: BrainNetworkPainter(
                  pulse: pulse,
                ),
                child: Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF02111B),
                      border: Border.all(
                        color: const Color(0xFF39FF88).withOpacity(0.65),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x5500E5FF),
                          blurRadius: 22,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'YANSI\nAI',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
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
// CORE RING PAINTER
// ============================================================

class CoreRingPainter extends CustomPainter {
  final Color color;
  final double pulse;

  CoreRingPainter({
    required this.color,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 3; i++) {
      final radius = size.width * (0.38 + i * 0.07);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = i == 0 ? 2.0 : 0.8
        ..color = color.withOpacity(
          i == 0 ? 0.9 : 0.28,
        );

      canvas.drawCircle(center, radius, paint);
    }

    final tickPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 2;

    for (int i = 0; i < 16; i++) {
