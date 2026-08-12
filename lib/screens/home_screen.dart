import 'package:flutter/material.dart';

import 'expense_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool menuOpen = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void openCore(String name) {
    if (name == 'EXPENSE') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ExpenseScreen(),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF07151C),
        content: Text(
          '$name is connected to Yansi.',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01060A),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _LifeBackgroundPainter(),
              ),
            ),

            // TOP CONTROL BAR
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                children: [
                  _smallButton(
                    Icons.menu_rounded,
                    () {
                      setState(
                        () => menuOpen = !menuOpen,
                      );
                    },
                  ),

                  const Spacer(),

                  const Text(
                    'L I F E O S',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      letterSpacing: 5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  _smallButton(
                    Icons.notifications_none_rounded,
                    () {},
                  ),
                ],
              ),
            ),

            // MAIN INTELLIGENCE
            Positioned.fill(
              top: 55,
              child: Column(
                children: [
                  const SizedBox(height: 18),

                  const Text(
                    'LIFE INTELLIGENCE',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 8,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (_, __) {
                            return Transform.rotate(
                              angle:
                                  _controller.value *
                                      6.28318,
                              child: CustomPaint(
                                size: const Size(
                                  290,
                                  290,
                                ),
                                painter:
                                    _NeuralRingPainter(),
                              ),
                            );
                          },
                        ),

                        // YANSI
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                backgroundColor:
                                    Color(0xFF07151C),
                                content: Text(
                                  'Yansi is listening. Speak naturally.',
                                ),
                              ),
                            );
                          },
                          child: const _YansiCore(),
                        ),

                        // FIVE INTELLIGENCE NODES
                        _node(
                          alignment:
                              const Alignment(
                            0,
                            -0.82,
                          ),
                          icon: Icons
                              .account_balance_wallet_outlined,
                          onTap: () =>
                              openCore('EXPENSE'),
                        ),

                        _node(
                          alignment:
                              const Alignment(
                            .82,
                            -.25,
                          ),
                          icon: Icons.flag_outlined,
                          onTap: () =>
                              openCore('GOALS'),
                        ),

                        _node(
                          alignment:
                              const Alignment(
                            .55,
                            .70,
                          ),
                          icon: Icons.bolt_outlined,
                          onTap: () =>
                              openCore('PRODUCTIVITY'),
                        ),

                        _node(
                          alignment:
                              const Alignment(
                            -.55,
                            .70,
                          ),
                          icon: Icons
                              .shopping_bag_outlined,
                          onTap: () =>
                              openCore('HOUSEHOLD'),
                        ),

                        _node(
                          alignment:
                              const Alignment(
                            -.82,
                            -.25,
                          ),
                          icon: Icons
                              .calendar_today_outlined,
                          onTap: () =>
                              openCore('CALENDAR'),
                        ),
                      ],
                    ),
                  ),

                  // YANSI STATUS
                  Container(
                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xCC061219),
                      borderRadius:
                          BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(
                          0x3300E5FF,
                        ),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 15,
                          color:
                              Color(0xFF55FF88),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Yansi is quietly watching your LifeOS patterns.',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.circle,
                          size: 6,
                          color:
                              Color(0xFF55FF88),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                ],
              ),
            ),

            // HIDDEN CONTROL CENTER
            if (menuOpen)
              Positioned(
                top: 47,
                left: 8,
                child: _controlCenter(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _smallButton(
    IconData icon,
    VoidCallback action,
  ) {
    return GestureDetector(
      onTap: action,
      child: Container(
        width: 31,
        height: 28,
        decoration: BoxDecoration(
          color:
              const Color(0xDD061219),
          borderRadius:
              BorderRadius.circular(7),
          border: Border.all(
            color:
                const Color(0x3300E5FF),
          ),
        ),
        child: Icon(
          icon,
          size: 15,
          color:
              const Color(0xFF55FF88),
        ),
      ),
    );
  }

  Widget _node({
    required Alignment alignment,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                const Color(0xDD07151C),
            border: Border.all(
              color:
                  const Color(0x7700E5FF),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3300E5FF),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 22,
            color:
                const Color(0xFF55FF88),
          ),
        ),
      ),
    );
  }

  Widget _controlCenter() {
    return Container(
      width: 225,
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:
            const Color(0xFF061219),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color:
              const Color(0x6600E5FF),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x5500E5FF),
            blurRadius: 25,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'CONTROL CENTER',
            style: TextStyle(
              color:
                  Color(0xFF00E5FF),
              fontSize: 9,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 12),

          _menuItem(
            Icons.auto_awesome,
            'YANSI',
          ),

          _menuItem(
            Icons.insights_outlined,
            'LIFE REPORT',
          ),

          _menuItem(
            Icons.person_outline,
            'PROFILE',
          ),

          _menuItem(
            Icons.security_outlined,
            'PRIVACY',
          ),

          _menuItem(
            Icons.settings_outlined,
            'SETTINGS',
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color:
                const Color(0xFF55FF88),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// YANSI CENTRAL CORE
// ============================================================

class _YansiCore extends StatelessWidget {
  const _YansiCore();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 125,
      height: 125,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient:
            const RadialGradient(
          colors: [
            Color(0xFF55FF88),
            Color(0xFF00BBD4),
            Color(0xFF06151C),
            Color(0xFF01060A),
          ],
          stops: [
            0.0,
            0.25,
            0.60,
            1.0,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x7700E5FF),
            blurRadius: 45,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: Color(0x4455FF88),
            blurRadius: 75,
            spreadRadius: 12,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.auto_awesome,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ============================================================
// NEURAL RINGS
// ============================================================

class _NeuralRingPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final paint = Paint()
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int i = 0; i < 8; i++) {
      paint.color = i.isEven
          ? const Color(0x5500E5FF)
          : const Color(0x4455FF88);

      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width:
              150 + i * 18,
          height:
              90 + i * 13,
        ),
        paint,
      );
    }

    final nodePaint = Paint()
      ..color =
          const Color(0xFF55FF88);

    for (int i = 0; i < 18; i++) {
      final angle =
          i * 6.28318 / 18;

      final radius =
          115 + (i % 3) * 12;

      final point = Offset(
        center.dx +
            radius *
                math.cos(angle),
        center.dy +
            radius *
                math.sin(angle) *
                .6,
      );

      canvas.drawCircle(
        point,
        1.5,
        nodePaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) =>
      true;
}

// ============================================================
// BACKGROUND
// ============================================================

class _LifeBackgroundPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color =
            const Color(0xFF01060A),
    );

    final grid = Paint()
      ..color =
          const Color(0x1200E5FF)
      ..strokeWidth = .5;

    for (
      double x = 0;
      x < size.width;
      x += 32
    ) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        grid,
      );
    }

    for (
      double y = 0;
      y < size.height;
      y += 32
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        grid,
      );
    }

    final center = Offset(
      size.width / 2,
      size.height * .48,
    );

    final neural = Paint()
      ..color =
          const Color(0x1600E5FF)
      ..strokeWidth = .6;

    for (int i = 0; i < 22; i++) {
      final angle =
          i * 6.28318 / 22;

      final end = Offset(
        center.dx +
            size.width *
                .45 *
                math.cos(angle),
        center.dy +
            size.height *
                .35 *
                math.sin(angle),
      );

      canvas.drawLine(
        center,
        end,
        neural,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _LifeBackgroundPainter
        oldDelegate,
  ) =>
      false;
}
