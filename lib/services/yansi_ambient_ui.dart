import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shared visual tokens for the ambient Yansi/LifeOS interface.
class YansiAmbientUi {
  static const background = Color(0xFF02070B);
  static const cyan = Color(0xFF00E5FF);
  static const green = Color(0xFF00FFB3);

  static BoxDecoration glass({Color accent = cyan}) => BoxDecoration(
        color: background.withOpacity(.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(.18)),
        boxShadow: [BoxShadow(color: accent.withOpacity(.10), blurRadius: 26, spreadRadius: 1)],
      );

  static TextStyle micro({Color color = cyan}) => TextStyle(
        color: color, fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.w500,
      );

  static TextStyle body({Color color = Colors.white70}) => TextStyle(
        color: color, fontSize: 12, height: 1.35,
      );
}

class YansiAmbientPulse extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final double size;

  const YansiAmbientPulse({super.key, required this.animation, this.color = YansiAmbientUi.cyan, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final pulse = .82 + (.18 * math.sin(animation.value * 2 * math.pi));
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(.035),
            border: Border.all(color: color.withOpacity(.25 * pulse)),
            boxShadow: [BoxShadow(color: color.withOpacity(.12 * pulse), blurRadius: 28 * pulse, spreadRadius: 2)],
          ),
          child: Icon(Icons.auto_awesome, color: color.withOpacity(.82), size: size * .34),
        );
      },
    );
  }
}
