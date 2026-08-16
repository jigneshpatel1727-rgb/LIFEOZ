import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lifeoz_3d_theme_home.dart';
import 'screens/core_report_screen.dart';

class LifeOZThemedCoreShell extends StatefulWidget {
  final SharedPreferences prefs;
  final int coreIndex;

  const LifeOZThemedCoreShell({
    super.key,
    required this.prefs,
    required this.coreIndex,
  });

  @override
  State<LifeOZThemedCoreShell> createState() => _LifeOZThemedCoreShellState();
}

class _LifeOZThemedCoreShellState extends State<LifeOZThemedCoreShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final int themeIndex;
  late final LifeOZTheme theme;

  static const coreNames = <String>[
    'Financial Life',
    'Goals & Growth',
    'Productivity',
    'Household',
    'Life',
  ];

  static const coreGlyphs = <String>['◈', '✦', '⬢', '◇', '◉'];

  @override
  void initState() {
    super.initState();

    final savedTheme = widget.prefs.getInt('lifeoz_theme') ?? 0;
    themeIndex = savedTheme < 0
        ? 0
        : savedTheme >= lifeOZThemes.length
            ? lifeOZThemes.length - 1
            : savedTheme;
    theme = lifeOZThemes[themeIndex];

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Color(theme.primary);
    final glow = Color(theme.secondary);
    final core = widget.coreIndex.clamp(0, coreNames.length - 1);

    return Scaffold(
      backgroundColor: Color(theme.background),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) {
              return CustomPaint(
                size: Size.infinite,
                painter: _ThemeCorePainter(
                  accent,
                  glow,
                  _pulse.value,
                  core,
                ),
              );
            },
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: glow,
                          size: 18,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coreNames[core],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Text(
                              '${theme.name} • REALTIME INTELLIGENCE',
                              style: TextStyle(
                                color: glow.withOpacity(.72),
                                fontSize: 8,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        coreGlyphs[core],
                        style: TextStyle(
                          color: glow,
                          fontSize: 26,
                          shadows: [
                            Shadow(color: glow, blurRadius: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: accent,
                              secondary: glow,
                            ),
                      ),
                      child: CoreReportScreen(
                        core: core,
                        currency: _currency(widget.prefs),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _currency(SharedPreferences prefs) {
    final value = prefs.getString('currency')?.trim();
    return value == null || value.isEmpty ? '₹' : value;
  }
}

class _ThemeCorePainter extends CustomPainter {
  final Color a;
  final Color b;
  final double t;
  final int core;

  _ThemeCorePainter(this.a, this.b, this.t, this.core);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .22);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 5; i++) {
      final radius = 55.0 + i * 28 + math.sin(t * math.pi * 2 + i) * 5;
      final alpha = (.12 - i * .014).clamp(0.02, 0.12);
      ringPaint.color = (i == core ? b : a).withOpacity(alpha);
      canvas.drawCircle(center, radius, ringPaint);
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          b.withOpacity(.22),
          a.withOpacity(.06),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: 125),
      );
    canvas.drawCircle(center, 125, glowPaint);

    for (var i = 0; i < 7; i++) {
      final angle = t * math.pi * 2 * (i.isEven ? 1 : -.7) + i * .9;
      final radius = 85 + i * 18.0;
      final dot = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius * .45,
      );
      final dotPaint = Paint()
        ..color = (i == core ? b : a).withOpacity(.55);
      canvas.drawCircle(dot, 2.2 + (i == core ? 2 : 0), dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ThemeCorePainter old) {
    return old.t != t || old.a != a || old.b != b || old.core != core;
  }
}
