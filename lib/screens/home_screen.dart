import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final FlutterTts _tts = FlutterTts();

  bool _speaking = false;

  final List<_CoreItem> _cores = [
    _CoreItem(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Expense',
      description:
          'This is your Expense core. I can manage your daily expenses, income, EMI, spending and savings.',
    ),
    _CoreItem(
      icon: Icons.track_changes_rounded,
      title: 'Goals',
      description:
          'This is your Goals core. I can help you create goals, track progress and remember important targets.',
    ),
    _CoreItem(
      icon: Icons.bolt_rounded,
      title: 'Productivity',
      description:
          'This is your Productivity core. I can manage your tasks, work, reminders and daily activities.',
    ),
    _CoreItem(
      icon: Icons.shopping_cart_rounded,
      title: 'Household',
      description:
          'This is your Household core. I can maintain your grocery, milk, medicine and daily household requirement list.',
    ),
    _CoreItem(
      icon: Icons.calendar_month_rounded,
      title: 'Life Calendar',
      description:
          'This is your Life Calendar. I can maintain bills, EMI dates, insurance renewals, investment dates and important reminders.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _setupYansi();
  }

  Future<void> _setupYansi() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.46);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      if (!mounted) return;

      setState(() {
        _speaking = true;
      });
    });

    _tts.setCompletionHandler(() {
      if (!mounted) return;

      setState(() {
        _speaking = false;
      });
    });
  }

  Future<void> _speakCore(
    _CoreItem core,
  ) async {
    await _tts.stop();

    if (!mounted) return;

    setState(() {
      _speaking = true;
    });

    await _tts.speak(core.description);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02070B),
      body: SafeArea(
        child: Stack(
          children: [
            // Futuristic background
            Positioned.fill(
              child: CustomPaint(
                painter: _NeuralBackgroundPainter(
                  animation:
                      _animationController,
                ),
              ),
            ),

            // Main interface
            Column(
              children: [
                const SizedBox(height: 18),

                // LifeOS logo / title
                _buildLogo(),

                const SizedBox(height: 10),

                Expanded(
                  child: LayoutBuilder(
                    builder:
                        (context, constraints) {
                      return _buildCoreInterface(
                        constraints,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan
                        .withOpacity(
                      0.18 +
                          (_animationController
                                  .value *
                              0.15),
                    ),
                    blurRadius: 35,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: Colors.greenAccent
                        .withOpacity(0.12),
                    blurRadius: 60,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _LifeOSLogoPainter(
                  progress:
                      _animationController.value,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 5),

        const Text(
          'LIFEOS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildCoreInterface(
    BoxConstraints constraints,
  ) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    final centerX = width / 2;
    final centerY = height / 2;

    final radius =
        math.min(width * 0.34, height * 0.34);

    return Stack(
      children: [
        // Central AI hub
        Positioned(
          left: centerX - 58,
          top: centerY - 58,
          child: _buildCentralHub(),
        ),

        // Five core icons
        ...List.generate(
          _cores.length,
          (index) {
            final core = _cores[index];

            // Five-point circular arrangement
            final angle =
                (-math.pi / 2) +
                    (index *
                        (2 * math.pi / 5));

            final x =
                centerX +
                    radius * math.cos(angle) -
                    38;

            final y =
                centerY +
                    radius * math.sin(angle) -
                    38;

            return Positioned(
              left: x,
              top: y,
              child: _buildCoreButton(core),
            );
          },
        ),

        // Connection lines
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter:
                  _ConnectionPainter(
                animation:
                    _animationController,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCentralHub() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final pulse =
            1.0 +
                math.sin(
                      _animationController
                              .value *
                          math.pi *
                          2,
                    ) *
                    0.05;

        return Transform.scale(
          scale: pulse,
          child: Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient:
                  const RadialGradient(
                colors: [
                  Color(0xFF0D333A),
                  Color(0xFF06171D),
                  Color(0xFF02070B),
                ],
              ),
              border: Border.all(
                color:
                    Colors.cyanAccent
                        .withOpacity(0.75),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan
                      .withOpacity(0.35),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.greenAccent
                      .withOpacity(0.18),
                  blurRadius: 55,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.psychology_rounded,
                size: 54,
                color:
                    Colors.cyanAccent,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoreButton(
    _CoreItem core,
  ) {
    return GestureDetector(
      onTap: () {
        _speakCore(core);
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient:
                  const RadialGradient(
                colors: [
                  Color(0xFF153C43),
                  Color(0xFF07171D),
                ],
              ),
              border: Border.all(
                color: Colors.cyanAccent
                    .withOpacity(0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan
                      .withOpacity(0.25),
                  blurRadius: 22,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: Colors.greenAccent
                      .withOpacity(0.12),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                core.icon,
                size: 34,
                color:
                    Colors.cyanAccent,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CoreItem {
  final IconData icon;
  final String title;
  final String description;

  const _CoreItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _NeuralBackgroundPainter
    extends CustomPainter {
  final Animation<double> animation;

  _NeuralBackgroundPainter({
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final center =
        Offset(
      size.width / 2,
      size.height / 2,
    );

    for (int i = 0; i < 16; i++) {
      final angle =
          animation.value *
                  math.pi *
                  2 +
              i * 0.4;

      final radius =
          100.0 + (i * 20);

      final point = Offset(
        center.dx +
            math.cos(angle) *
                radius,
        center.dy +
            math.sin(angle) *
                radius,
      );

      paint.color =
          Colors.cyan.withOpacity(
        0.035,
      );

      canvas.drawLine(
        center,
        point,
        paint,
      );
    }

    for (int i = 0; i < 35; i++) {
      final x =
          (i * 97.0) %
              size.width;

      final y =
          (i * 173.0) %
              size.height;

      paint
        ..style =
            PaintingStyle.fill
        ..color =
            Colors.cyan.withOpacity(
          0.04,
        );

      canvas.drawCircle(
        Offset(x, y),
        1.2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _NeuralBackgroundPainter
        oldDelegate,
  ) {
    return true;
  }
}

class _ConnectionPainter
    extends CustomPainter {
  final Animation<double> animation;

  _ConnectionPainter({
    required this.animation,
  }) : super(repaint: animation);

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
        math.min(
              size.width * 0.34,
              size.height * 0.34,
            );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 5; i++) {
      final angle =
          (-math.pi / 2) +
              (i *
                  (2 * math.pi / 5));

      final end = Offset(
        center.dx +
            radius *
                math.cos(angle),
        center.dy +
            radius *
                math.sin(angle),
      );

      final opacity =
          0.12 +
              0.08 *
                  math.sin(
                    animation.value *
                            math.pi *
                            2 +
                        i,
                  );

      paint.color =
          Colors.cyan.withOpacity(
        opacity,
      );

      canvas.drawLine(
        center,
        end,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _ConnectionPainter
        oldDelegate,
  ) {
    return true;
  }
}

class _LifeOSLogoPainter
    extends CustomPainter {
  final double progress;

  _LifeOSLogoPainter({
    required this.progress,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center =
        Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius =
        size.width * 0.32;

    final paint = Paint()
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 2
      ..color =
          Colors.cyanAccent;

    canvas.drawCircle(
      center,
      radius,
      paint,
    );

    for (int i = 0; i < 8; i++) {
      final angle =
          progress *
                  math.pi *
                  2 +
              i *
                  (math.pi / 4);

      final start =
          Offset(
        center.dx +
            radius *
                math.cos(angle),
        center.dy +
            radius *
                math.sin(angle),
      );

      final end =
          Offset(
        center.dx +
            radius *
                1.45 *
                math.cos(angle),
        center.dy +
            radius *
                1.45 *
                math.sin(angle),
      );

      canvas.drawLine(
        start,
        end,
        paint,
      );
    }

    final nodePaint = Paint()
      ..style =
          PaintingStyle.fill
      ..color =
          Colors.greenAccent;

    canvas.drawCircle(
      center,
      7,
      nodePaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _LifeOSLogoPainter
        oldDelegate,
  ) {
    return true;
  }
}
