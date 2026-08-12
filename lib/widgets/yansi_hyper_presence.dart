import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/yansi_intelligence_core.dart';

/// Full-system ambient presence for Yansi. It is visual state, not a chat UI.
class YansiHyperPresence extends StatelessWidget {
  final YansiPresenceState state;
  final Animation<double> animation;
  final Color primary;
  final Color secondary;
  final double size;

  const YansiHyperPresence({
    super.key,
    required this.state,
    required this.animation,
    required this.primary,
    required this.secondary,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value * math.pi * 2;
        final active = state != YansiPresenceState.idle;
        final energy = .55 + (.45 * ((math.sin(t) + 1) / 2));
        final radius = size * (.30 + (.035 * energy));

        return SizedBox(
          width: size * 1.45,
          height: size * 1.45,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (int i = 4; i >= 1; i--)
                Transform.rotate(
                  angle: t * (i.isEven ? -.08 : .06),
                  child: Container(
                    width: radius + i * 18,
                    height: radius + i * 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.lerp(primary, secondary, i / 5)!
                            .withOpacity((active ? .12 : .055) / i),
                        width: active ? 1.4 : .8,
                      ),
                    ),
                  ),
                ),
              Container(
                width: radius,
                height: radius,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primary.withOpacity(.42 * energy),
                      secondary.withOpacity(.12 * energy),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(.24 * energy),
                      blurRadius: active ? 48 : 32,
                      spreadRadius: active ? 8 : 2,
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _NeuralCorePainter(
                    progress: animation.value,
                    primary: primary,
                    secondary: secondary,
                    active: active,
                  ),
                ),
              ),
              if (state != YansiPresenceState.idle)
                Text(
                  _stateLabel(state),
                  style: TextStyle(
                    color: primary.withOpacity(.82),
                    fontSize: 8,
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _stateLabel(YansiPresenceState value) {
    switch (value) {
      case YansiPresenceState.listening:
        return 'LISTENING';
      case YansiPresenceState.thinking:
        return 'THINKING';
      case YansiPresenceState.acting:
        return 'ACTING';
      case YansiPresenceState.speaking:
        return 'SPEAKING';
      case YansiPresenceState.idle:
        return '';
    }
  }
}

class _NeuralCorePainter extends CustomPainter {
  final double progress;
  final Color primary;
  final Color secondary;
  final bool active;

  const _NeuralCorePainter({
    required this.progress,
    required this.primary,
    required this.secondary,
    required this.active,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide * .42;
    final paint = Paint()..style = PaintingStyle.stroke;

    for (int i = 0; i < 14; i++) {
      final a = (i / 14) * math.pi * 2 + progress * math.pi * 2;
      final p1 = center + Offset(math.cos(a) * r * .25, math.sin(a) * r * .25);
      final p2 = center + Offset(math.cos(a) * r, math.sin(a) * r);
      paint
        ..strokeWidth = active ? 1.2 : .7
        ..color = Color.lerp(primary, secondary, i / 14)!
            .withOpacity(active ? .34 : .16);
      canvas.drawLine(p1, p2, paint);
      canvas.drawCircle(p2, active ? 1.7 : 1.1, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
    }

    paint
      ..style = PaintingStyle.fill
      ..color = primary.withOpacity(active ? .78 : .48);
    canvas.drawCircle(center, active ? 5 : 3.5, paint);
  }

  @override
  bool shouldRepaint(covariant _NeuralCorePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.active != active ||
      oldDelegate.primary != primary ||
      oldDelegate.secondary != secondary;
}
