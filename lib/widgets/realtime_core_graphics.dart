import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Live vector intelligence icon. No static PNG is required for the five cores.
/// The icon continuously breathes, rotates its orbital field and emits particles.
class RealtimeCoreGraphic extends StatelessWidget {
  final int core;
  final Color color;
  final bool active;
  final double t;

  const RealtimeCoreGraphic({super.key, required this.core, required this.color, required this.active, required this.t});

  IconData get symbol => switch (core) {
    0 => Icons.account_balance_wallet_rounded,
    1 => Icons.track_changes_rounded,
    2 => Icons.bolt_rounded,
    3 => Icons.shopping_bag_rounded,
    _ => Icons.favorite_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final pulse = 1 + math.sin(t * math.pi * 2 + core) * .08;
    return CustomPaint(
      painter: _RealtimeCorePainter(color: color, t: t, core: core, active: active),
      child: Center(
        child: Transform.scale(
          scale: pulse,
          child: Icon(symbol, color: color, size: active ? 32 : 28),
        ),
      ),
    );
  }
}

class _RealtimeCorePainter extends CustomPainter {
  final Color color;
  final double t;
  final int core;
  final bool active;
  _RealtimeCorePainter({required this.color, required this.t, required this.core, required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2;
    final pulse = (math.sin(t * math.pi * 2 + core) + 1) / 2;

    final glow = Paint()
      ..color = color.withOpacity(active ? .25 : .10 + pulse * .07)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, active ? 18 : 11);
    canvas.drawCircle(c, r * (.62 + pulse * .08), glow);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 1.8 : 1.0
      ..color = color.withOpacity(active ? .95 : .55);
    canvas.drawCircle(c, r * .79, ring);

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(t * math.pi * 2 * (core.isEven ? 1 : -1));
    final orbit = Paint()..style = PaintingStyle.stroke..strokeWidth = .8..color = color.withOpacity(.72);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 1.62, height: r * .62), orbit);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 1.28, height: r * .38), orbit..color = color.withOpacity(.35));
    canvas.restore();

    final particlePaint = Paint()..color = color.withOpacity(.85);
    for (int i = 0; i < 5; i++) {
      final a = t * math.pi * 2 * (i.isEven ? 1 : -.7) + i * math.pi * 2 / 5;
      final pr = r * (.82 + .10 * math.sin(t * math.pi * 4 + i));
      canvas.drawCircle(Offset(c.dx + math.cos(a) * pr, c.dy + math.sin(a) * pr), active ? 2.0 : 1.2, particlePaint);
    }

    if (active) {
      final sweep = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.2..color = color.withOpacity(.95);
      canvas.drawArc(Rect.fromCircle(center: c, radius: r * .92), t * math.pi * 2, math.pi * .75, false, sweep);
    }
  }

  @override
  bool shouldRepaint(covariant _RealtimeCorePainter oldDelegate) => true;
}
