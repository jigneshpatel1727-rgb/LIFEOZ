import 'dart:math' as math;
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool menuOpen = false;

  final cores = const [
    _CoreData(
      'EXPENSE',
      Icons.account_balance_wallet_outlined,
    ),
    _CoreData(
      'GOAL',
      Icons.flag_outlined,
    ),
    _CoreData(
      'PRODUCTIVITY',
      Icons.bolt_outlined,
    ),
    _CoreData(
      'HOUSEHOLD',
      Icons.shopping_bag_outlined,
    ),
    _CoreData(
      'CALENDAR',
      Icons.calendar_today_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void openCore(_CoreData core) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF07151C),
        content: Text(
          '${core.name} is connected to Yansi.',
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

            // SMALL SMART TOP BAR
            Positioned(
              top: 7,
              left: 7,
              right: 7,
              child: Row(
                children: [
                  _topButton(
                    Icons.menu_rounded,
                    () {
                      setState(() {
                        menuOpen = !menuOpen;
                      });
                    },
                  ),

                  const Spacer(),

                  const Text(
                    'L I F E O S',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      letterSpacing: 5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  _topButton(
                    Icons.notifications_none_rounded,
                    () {},
                  ),
                ],
              ),
            ),

            Positioned.fill(
              top: 42,
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  const Text(
                    'LIFE INTELLIGENCE',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 7,
                      letterSpacing: 3,
                    ),
                  ),

                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, box) {
                        final diameter =
                            math.min(
                              box.maxWidth,
                              box.maxHeight,
                            ) *
                            .78;

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation:
                                  _controller,
                              builder:
                                  (_, child) {
                                return Transform.rotate(
                                  angle:
                                      _controller.value *
                                          math.pi *
                                          2,
                                  child: CustomPaint(
                                    size: Size(
                                      diameter,
                                      diameter,
                                    ),
                                    painter:
                                        _NeuralPainter(),
                                  ),
                                );
                              },
                            ),

                            // YANSI — HEART OF LIFEOS
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger
                                    .of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    backgroundColor:
                                        Color(
                                      0xFF07151C,
                                    ),
                                    content: Text(
                                      'Yansi is ready. Speak naturally.',
                                    ),
                                  ),
                                );
                              },
                              child:
                                  const _YansiCore(),
                            ),

                            // FIVE CORES
                            for (int i = 0;
                                i < cores.length;
                                i++)
                              _positionedCore(
                                i,
                                cores[i],
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  // AMBIENT YANSI STATUS
                  Container(
                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(0xCC061219),
                      borderRadius:
                          BorderRadius.circular(9),
                      border: Border.all(
                        color:
                            const Color(0x2200E5FF),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 13,
                          color:
                              Color(0xFF55FF88),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Yansi is quietly connecting your life systems.',
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  Colors.white54,
                              fontSize: 8,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.circle,
                          size: 5,
                          color:
                              Color(0xFF55FF88),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),

            if (menuOpen)
              Positioned(
                top: 42,
                left: 7,
                child: _controlCenter(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _topButton(
    IconData icon,
    VoidCallback action,
  ) {
    return GestureDetector(
      onTap: action,
      child: Container(
        width: 27,
        height: 25,
        decoration: BoxDecoration(
          color: const Color(0xDD061219),
          borderRadius:
              BorderRadius.circular(6),
          border: Border.all(
            color:
                const Color(0x3000E5FF),
          ),
        ),
        child: Icon(
          icon,
          size: 13,
          color:
              const Color(0xFF55FF88),
        ),
      ),
    );
  }

  Widget _positionedCore(
    int index,
    _CoreData core,
  ) {
    final positions = [
      const Alignment(0, -.80),
      const Alignment(.78, -.25),
      const Alignment(.52, .66),
      const Alignment(-.52, .66),
      const Alignment(-.78, -.25),
    ];

    return Align(
      alignment: positions[index],
      child: GestureDetector(
        onTap: () => openCore(core),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                const Color(0xEE07151C),
            border: Border.all(
              color:
                  const Color(0x6600E5FF),
            ),
            boxShadow: const [
              BoxShadow(
                color:
                    Color(0x2200E5FF),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            core.icon,
            size: 19,
            color:
                const Color(0xFF55FF88),
          ),
        ),
      ),
    );
  }

  Widget _controlCenter() {
    return Container(
      width: 215,
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            const Color(0xFF061219),
        borderRadius:
            BorderRadius.circular(11),
        border: Border.all(
          color:
              const Color(0x5500E5FF),
        ),
        boxShadow: const [
          BoxShadow(
            color:
                Color(0x4400E5FF),
            blurRadius: 22,
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
              fontSize: 8,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          _menuRow(
            Icons.auto_awesome,
            'YANSI',
          ),
          _menuRow(
            Icons.insights_outlined,
            'LIFE REPORT',
          ),
          _menuRow(
            Icons.person_outline,
            'PROFILE',
          ),
          _menuRow(
            Icons.security_outlined,
            'PRIVACY',
          ),
          _menuRow(
            Icons.settings_outlined,
            'SETTINGS',
          ),
        ],
      ),
    );
  }

  Widget _menuRow(
    IconData icon,
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15,
            color:
                const Color(0xFF55FF88),
          ),
          const SizedBox(width: 11),
          Text(
            title,
            style: const TextStyle(
              color:
                  Colors.white70,
              fontSize: 8,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoreData {
  final String name;
  final IconData icon;

  const _CoreData(
    this.name,
    this.icon,
  );
}

// ============================================================
// YANSI
// ============================================================

class _YansiCore extends StatelessWidget {
  const _YansiCore();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      height: 118,
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
            0,
            .25,
            .60,
            1,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color:
                Color(0x6600E5FF),
            blurRadius: 38,
            spreadRadius: 6,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.auto_awesome,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

// ============================================================
// NEURAL NETWORK
// ============================================================

class _NeuralPainter
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

    final ring = Paint()
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = .7;

    for (int i = 0; i < 8; i++) {
      ring.color = i.isEven
          ? const Color(0x4400E5FF)
          : const Color(0x3355FF88);

      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width:
              size.width *
              (.48 + i * .055),
          height:
              size.height *
              (.28 + i * .04),
        ),
        ring,
      );
    }

    final node =
        Paint()
          ..color =
              const Color(0xFF55FF88);

    for (int i = 0; i < 24; i++) {
      final a =
          i * math.pi * 2 / 24;

      final p = Offset(
        center.dx +
            size.width *
                .42 *
                math.cos(a),
        center.dy +
            size.height *
                .25 *
                math.sin(a),
      );

      canvas.drawCircle(
        p,
        1.2,
        node,
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
          const Color(0x1000E5FF)
      ..strokeWidth = .4;

    for (
      double x = 0;
      x < size.width;
      x += 30
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
      y += 30
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        grid,
      );
    }

    final glow =
        Paint()
          ..shader =
              const RadialGradient(
            colors: [
              Color(0x1800E5FF),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(
                size.width / 2,
                size.height * .48,
              ),
              radius:
                  size.width * .65,
            ),
          );

    canvas.drawCircle(
      Offset(
        size.width / 2,
        size.height * .48,
      ),
      size.width * .65,
      glow,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) =>
      false;
}
