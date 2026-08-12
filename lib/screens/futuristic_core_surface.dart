import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/lifeos_core.dart';

class FuturisticCoreSurface extends StatefulWidget {
  final int core;
  final String currency;
  const FuturisticCoreSurface({super.key, required this.core, required this.currency});
  @override State<FuturisticCoreSurface> createState() => _FuturisticCoreSurfaceState();
}

class _FuturisticCoreSurfaceState extends State<FuturisticCoreSurface> with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  @override void dispose() { _motion.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final definition = coreByIndex(widget.core);
    return Scaffold(
      backgroundColor: const Color(0xFF01060A),
      body: Stack(children: [
        Positioned.fill(child: AnimatedBuilder(animation: _motion, builder: (_, __) => CustomPaint(painter: _CoreFieldPainter(_motion.value)))),
        SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 0), child: Row(children: [
            _circleButton(Icons.arrow_back_rounded, () => Navigator.pop(context)),
            const Spacer(),
            Text('LIFEOS', style: TextStyle(color: Colors.white.withOpacity(.68), fontSize: 9, letterSpacing: 3)),
            const Spacer(),
            _circleButton(Icons.auto_awesome, () {}),
          ])),
          const Spacer(flex: 2),
          AnimatedBuilder(animation: _motion, builder: (_, __) => _CoreOrb(icon: definition.icon, phase: _motion.value)),
          const SizedBox(height: 28),
          Text(definition.title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 4, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: Text(definition.description, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(.48), fontSize: 11, height: 1.45))),
          const SizedBox(height: 30),
          Container(margin: const EdgeInsets.symmetric(horizontal: 26), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF00E5FF).withOpacity(.15)), color: Colors.white.withOpacity(.025)), child: Row(children: [
            Icon(Icons.insights_rounded, size: 16, color: const Color(0xFF00E5FF).withOpacity(.8)),
            const SizedBox(width: 10),
            Expanded(child: Text('YANSI INTELLIGENCE READY', style: TextStyle(color: Colors.white.withOpacity(.62), fontSize: 8, letterSpacing: 1.8))),
            Text(widget.currency, style: TextStyle(color: const Color(0xFF35FF72).withOpacity(.8), fontSize: 9, letterSpacing: 1)),
          ])),
          const Spacer(flex: 3),
        ])),
      ]),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback action) => GestureDetector(onTap: action, child: Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.035), border: Border.all(color: const Color(0xFF00E5FF).withOpacity(.22))), child: Icon(icon, size: 17, color: Colors.white.withOpacity(.7))));
}

class _CoreOrb extends StatelessWidget {
  final IconData icon; final double phase;
  const _CoreOrb({required this.icon, required this.phase});
  @override Widget build(BuildContext context) {
    final pulse = 1 + math.sin(phase * math.pi * 2) * .045;
    return Transform.scale(scale: pulse, child: Stack(alignment: Alignment.center, children: [
      for (int i = 0; i < 4; i++) Container(width: 108 + i * 30, height: 108 + i * 30, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00E5FF).withOpacity(.10 + i * .025)))),
      Container(width: 88, height: 88, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0xAA00E5FF), Color(0x2200E5FF), Colors.transparent]), boxShadow: [BoxShadow(color: Color(0x5500E5FF), blurRadius: 45, spreadRadius: 4)]), child: Icon(icon, size: 29, color: Colors.white)),
    ]));
  }
}

class _CoreFieldPainter extends CustomPainter {
  final double phase; _CoreFieldPainter(this.phase);
  @override void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .42); final paint = Paint()..strokeWidth = 1;
    for (var i = 0; i < 26; i++) { final angle = phase * math.pi * 2 + i * .47; final radius = size.width * (.18 + (i % 7) * .035); final end = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius); paint.color = const Color(0xFF00E5FF).withOpacity(.025 + (i % 4) * .008); canvas.drawLine(center, end, paint); canvas.drawCircle(end, 1.3, paint); }
  }
  @override bool shouldRepaint(covariant _CoreFieldPainter oldDelegate) => oldDelegate.phase != phase;
}
