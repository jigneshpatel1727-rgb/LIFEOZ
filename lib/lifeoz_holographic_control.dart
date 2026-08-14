import 'dart:math' as math;
import 'package:flutter/material.dart';

class LifeOZHolographicControl extends StatefulWidget {
  const LifeOZHolographicControl({super.key});
  @override State<LifeOZHolographicControl> createState() => _LifeOZHolographicControlState();
}

class _LifeOZHolographicControlState extends State<LifeOZHolographicControl> with SingleTickerProviderStateMixin {
  late final AnimationController motion = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
  int selected = 0;
  static const labels = ['PROFILE','DESIGN','PERMISSIONS','YANSI','SETTINGS'];
  static const icons = [Icons.person_outline, Icons.palette_outlined, Icons.lock_outline, Icons.auto_awesome, Icons.settings_outlined];

  @override void dispose() { motion.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01040A),
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('HOLOGRAPHIC CONTROL', style: TextStyle(letterSpacing: 2, fontSize: 13))),
      body: AnimatedBuilder(
        animation: motion,
        builder: (context, _) => LayoutBuilder(builder: (context, box) {
          final center = Offset(box.maxWidth / 2, box.maxHeight * .42);
          return Stack(children: [
            Positioned.fill(child: CustomPaint(painter: _HoloPainter(motion.value, selected))),
            for (int i = 0; i < labels.length; i++)
              Positioned(
                left: center.dx + math.cos(i * math.pi * 2 / labels.length - math.pi / 2) * math.min(box.maxWidth * .34, 145) - 48,
                top: center.dy + math.sin(i * math.pi * 2 / labels.length - math.pi / 2) * math.min(box.maxHeight * .28, 150) - 48,
                child: GestureDetector(onTap: () => setState(() => selected = i), child: _Node(icon: icons[i], label: labels[i], selected: selected == i)),
              ),
            Positioned(left: center.dx - 62, top: center.dy - 62, child: GestureDetector(onTap: () => setState(() => selected = 3), child: const _CenterNode())),
            Positioned(bottom: 28, left: 24, right: 24, child: Text(_description(selected), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: .8))),
          ];
        }),
      ),
    );
  }

  String _description(int i) => ['Your LifeOZ profile and identity.', 'Choose the living visual environment.', 'Control permissions for LifeOZ intelligence.', 'Configure Yansi voice and ambient behavior.', 'Application preferences and controls.'][i];
}

class _Node extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  const _Node({required this.icon, required this.label, required this.selected});
  @override Widget build(BuildContext context) => Column(children: [
    Container(width: 58, height: 58, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF06111B), border: Border.all(color: const Color(0xFF42DFFF).withValues(alpha: selected ? .95 : .38), width: selected ? 2 : 1), boxShadow: selected ? [BoxShadow(color: const Color(0xFF42DFFF).withValues(alpha: .28), blurRadius: 18)] : null), child: Icon(icon, color: const Color(0xFF42DFFF), size: 25)),
    const SizedBox(height: 6), Text(label, style: TextStyle(color: Colors.white.withValues(alpha: selected ? .95 : .55), fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1))
  ]);
}

class _CenterNode extends StatelessWidget {
  const _CenterNode();
  @override Widget build(BuildContext context) => Container(width: 124, height: 124, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const RadialGradient(colors: [Colors.white, Color(0xFF20D9FF), Color(0xFF06111B)]), boxShadow: [BoxShadow(color: const Color(0xFF20D9FF).withValues(alpha: .55), blurRadius: 38)]), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 38));
}

class _HoloPainter extends CustomPainter {
  final double phase;
  final int selected;
  const _HoloPainter(this.phase, this.selected);
  @override void paint(Canvas c, Size s) {
    final m = Offset(s.width / 2, s.height * .42);
    for (int i = 0; i < 5; i++) {
      final r = 90.0 + i * 34;
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = i == selected ? 2 : .7
        ..color = const Color(0xFF42DFFF).withValues(alpha: .10 + i * .025);
      c.save();
      c.translate(m.dx, m.dy);
      c.rotate(phase * math.pi * 2 * (i.isEven ? .08 : -.06) + selected * .12);
      c.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 2.5, height: r * .72), p);
      c.restore();
    }
  }
  @override bool shouldRepaint(covariant _HoloPainter oldDelegate) => true;
}
