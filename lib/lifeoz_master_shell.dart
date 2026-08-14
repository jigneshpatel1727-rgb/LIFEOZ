import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LifeOZMasterShell extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZMasterShell({super.key, required this.prefs});
  @override State<LifeOZMasterShell> createState() => _LifeOZMasterShellState();
}

class _LifeOZMasterShellState extends State<LifeOZMasterShell> with SingleTickerProviderStateMixin {
  late final AnimationController motion = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
  final FlutterTts tts = FlutterTts();
  String name = '';
  int active = -1;
  bool showProfile = false;

  static const coreColors = <Color>[Color(0xFF55E89A), Color(0xFFFFB24A), Color(0xFFB96BFF), Color(0xFF47DFFF), Color(0xFFE16CFF)];
  static const coreSpeech = <String>[
    'Your life intelligence is ready.',
    'Your care and commitment intelligence is ready.',
    'Your prosperity intelligence is ready.',
    'Your time intelligence is ready.',
    'Your personal growth intelligence is ready.',
  ];

  @override
  void initState() {
    super.initState();
    name = widget.prefs.getString('user_name') ?? '';
    tts.setSpeechRate(.44);
  }

  @override
  void dispose() {
    motion.dispose();
    tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await tts.stop();
    await tts.speak(text);
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: name);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF08131D),
        title: const Text('PROFILE', style: TextStyle(letterSpacing: 2)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.white70)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('SAVE')),
        ],
      ),
    );
    if (value != null && value.isNotEmpty) {
      await widget.prefs.setString('user_name', value);
      if (mounted) setState(() => name = value);
      await _speak('Got it. I will call you $value.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01040A),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: motion,
          builder: (context, _) => Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _UniversePainter(motion.value)),
              _home(),
              if (showProfile) _profileOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _home() {
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      final h = box.maxHeight;
      final center = Offset(w / 2, h * .48);
      final radiusX = math.min(w * .36, 150.0);
      final radiusY = math.min(h * .28, 205.0);
      final nodes = List<Offset>.generate(5, (i) {
        final angle = -math.pi / 2 + i * math.pi * 2 / 5;
        return Offset(center.dx + math.cos(angle) * radiusX, center.dy + math.sin(angle) * radiusY);
      });
      return Stack(children: [
        Positioned(top: 10, left: 18, right: 18, child: Row(children: [
          SizedBox(width: 48, height: 48, child: CustomPaint(painter: _LifeOZLogoPainter(motion.value))),
          const SizedBox(width: 10),
          const Text('LIFEOZ', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: 4)),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => showProfile = true),
            child: Container(width: 50, height: 50, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFFB45B).withValues(alpha: .75)), color: Colors.black.withValues(alpha: .22)), child: const Icon(Icons.tune_rounded, color: Color(0xFFFFB45B), size: 26)),
          ),
        ])),
        Positioned.fill(child: CustomPaint(painter: _NeuralFieldPainter(motion.value, center, nodes, active))),
        for (int i = 0; i < 5; i++)
          Positioned(left: nodes[i].dx - 43, top: nodes[i].dy - 43, child: GestureDetector(
            onTap: () { setState(() => active = i); _speak(coreSpeech[i]); },
            child: SizedBox(width: 86, height: 86, child: CustomPaint(painter: _Core3DPainter(i, coreColors[i], motion.value, active == i))),
          )),
        Positioned(left: center.dx - math.min(w * .34, 150.0), top: center.dy - math.min(w * .34, 150.0), child: IgnorePointer(child: SizedBox(width: math.min(w * .68, 300.0), height: math.min(w * .68, 300.0), child: CustomPaint(painter: _Yansi3DPainter(motion.value))))),
        if (active >= 0) _insightChip(active),
        Positioned(bottom: 20, left: 24, right: 24, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(name.isEmpty ? 'LIVING INTELLIGENCE' : 'WELCOME, ${name.toUpperCase()}', style: const TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 2.1, fontWeight: FontWeight.w700)),
        ])),
      ]);
    });
  }

  Widget _insightChip(int i) => Positioned(left: 28, right: 28, bottom: 54, child: GestureDetector(
    onTap: () => setState(() => active = -1),
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), decoration: BoxDecoration(color: const Color(0xFF06111A).withValues(alpha: .92), borderRadius: BorderRadius.circular(22), border: Border.all(color: coreColors[i].withValues(alpha: .55)), boxShadow: [BoxShadow(color: coreColors[i].withValues(alpha: .16), blurRadius: 24)]), child: Row(children: [
      Icon(Icons.auto_awesome, color: coreColors[i], size: 17), const SizedBox(width: 10), Expanded(child: Text(coreSpeech[i], style: const TextStyle(color: Colors.white, fontSize: 11, letterSpacing: .4))), const Icon(Icons.close, color: Colors.white38, size: 15),
    ])),
  ));

  Widget _profileOverlay() => Positioned.fill(child: Container(color: const Color(0xE801040A), child: Center(child: Container(width: 320, padding: const EdgeInsets.all(22), decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), color: const Color(0xFF07121C), border: Border.all(color: const Color(0xFFFFB45B).withValues(alpha: .55)), boxShadow: const [BoxShadow(color: Color(0x4400D9FF), blurRadius: 40)]), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Text('LIFEOZ PROFILE', style: TextStyle(color: Colors.white, letterSpacing: 2.2, fontSize: 13, fontWeight: FontWeight.w800)),
    const SizedBox(height: 18),
    CircleAvatar(radius: 38, backgroundColor: const Color(0xFF102533), child: Icon(Icons.person_outline, color: const Color(0xFFFFB45B), size: 38)),
    const SizedBox(height: 12),
    Text(name.isEmpty ? 'Your name' : name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
    const SizedBox(height: 18),
    SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _editName, icon: const Icon(Icons.edit_outlined), label: const Text('CORRECT / EDIT NAME'))),
    const SizedBox(height: 8),
    SizedBox(width: double.infinity, child: TextButton(onPressed: () => setState(() => showProfile = false), child: const Text('CLOSE'))),
  ]))));
}

class _UniversePainter extends CustomPainter {
  final double phase;
  _UniversePainter(this.phase);
  @override void paint(Canvas c, Size s) {
    final rect = Offset.zero & s;
    c.drawRect(rect, Paint()..shader = const RadialGradient(radius: 1.1, colors: [Color(0xFF071B2B), Color(0xFF01040A), Color(0xFF000106)]).createShader(rect));
    final rng = math.Random(42);
    for (var i = 0; i < 145; i++) {
      final x = rng.nextDouble() * s.width;
      final y = rng.nextDouble() * s.height;
      final twinkle = .18 + .28 * ((math.sin(phase * math.pi * 2 + i) + 1) / 2);
      c.drawCircle(Offset(x, y), .45 + rng.nextDouble() * 1.2, Paint()..color = Colors.white.withValues(alpha: twinkle));
    }
    final center = Offset(s.width / 2, s.height * .48);
    for (var i = 0; i < 7; i++) {
      final rx = 95.0 + i * 42;
      final ry = rx * .28;
      c.save(); c.translate(center.dx, center.dy); c.rotate(phase * math.pi * 2 * (i.isEven ? .035 : -.025));
      c.drawOval(Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2), Paint()..style = PaintingStyle.stroke..strokeWidth = .65..color = const Color(0xFF48DFFF).withValues(alpha: .07 + i * .008));
      c.restore();
    }
  }
  @override bool shouldRepaint(covariant _UniversePainter old) => true;
}

class _NeuralFieldPainter extends CustomPainter {
  final double phase; final Offset center; final List<Offset> nodes; final int active;
  _NeuralFieldPainter(this.phase, this.center, this.nodes, this.active);
  @override void paint(Canvas c, Size s) {
    for (var i = 0; i < nodes.length; i++) {
      final color = <Color>[const Color(0xFF55E89A), const Color(0xFFFFB24A), const Color(0xFFB96BFF), const Color(0xFF47DFFF), const Color(0xFFE16CFF)][i];
      final p = Paint()..style = PaintingStyle.stroke..strokeWidth = active == i ? 2.0 : .75..color = color.withValues(alpha: active == i ? .42 : .17);
      c.drawLine(center, nodes[i], p);
      for (var k = 0; k < 3; k++) {
        final t = (phase + k / 3 + i * .09) % 1;
        final pos = Offset.lerp(center, nodes[i], t)!;
        c.drawCircle(pos, active == i ? 2.6 : 1.4, Paint()..color = color.withValues(alpha: .75));
      }
    }
  }
  @override bool shouldRepaint(covariant _NeuralFieldPainter old) => true;
}

class _LifeOZLogoPainter extends CustomPainter {
  final double phase; _LifeOZLogoPainter(this.phase);
  @override void paint(Canvas c, Size s) {
    final m = Offset(s.width / 2, s.height / 2); final r = s.shortestSide * .34;
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.0..color = const Color(0xFFFFB45B);
    c.drawCircle(m, r, p); c.drawOval(Rect.fromCenter(center: m, width: r * 1.55, height: r * .65), p);
    c.drawCircle(Offset(m.dx + math.cos(phase * math.pi * 2) * r * .72, m.dy), 2.4, Paint()..color = const Color(0xFF55E89A));
  }
  @override bool shouldRepaint(covariant _LifeOZLogoPainter old) => true;
}

class _Core3DPainter extends CustomPainter {
  final int index; final Color color; final double phase; final bool selected;
  _Core3DPainter(this.index, this.color, this.phase, this.selected);
  @override void paint(Canvas c, Size s) {
    final m = Offset(s.width / 2, s.height / 2); final pulse = 1 + .08 * math.sin(phase * math.pi * 2 + index);
    final r = 25 * pulse;
    c.drawCircle(m, r * 1.5, Paint()..color = color.withValues(alpha: selected ? .25 : .12)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
    c.drawCircle(m, r, Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: .9), color.withValues(alpha: .92), const Color(0xFF02060B)]).createShader(Rect.fromCircle(center: m, radius: r)));
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = selected ? 2.0 : 1.1..color = color.withValues(alpha: selected ? .95 : .62);
    for (var k = 0; k < 3; k++) { c.save(); c.translate(m.dx, m.dy); c.rotate(phase * math.pi * 2 * (k.isEven ? .8 : -.55) + index); c.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 2.7, height: r * .66), p); c.restore(); }
    final star = Path();
    for (var k = 0; k < 8; k++) { final a = -math.pi / 2 + k * math.pi / 4; final rr = k.isEven ? r * .48 : r * .20; final pt = m + Offset(math.cos(a) * rr, math.sin(a) * rr); if (k == 0) star.moveTo(pt.dx, pt.dy); else star.lineTo(pt.dx, pt.dy); }
    star.close(); c.drawPath(star, Paint()..color = Colors.white.withValues(alpha: .82));
  }
  @override bool shouldRepaint(covariant _Core3DPainter old) => true;
}

class _Yansi3DPainter extends CustomPainter {
  final double phase; _Yansi3DPainter(this.phase);
  @override void paint(Canvas c, Size s) {
    final m = Offset(s.width / 2, s.height / 2); final scale = s.shortestSide * .27; final breathe = 1 + .045 * math.sin(phase * math.pi * 2);
    c.drawCircle(m, scale * 1.65, Paint()..color = const Color(0xFF43DFFF).withValues(alpha: .13)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30));
    c.drawCircle(m, scale * breathe, Paint()..shader = const RadialGradient(center: Alignment(-.25, -.28), radius: 1, colors: [Colors.white, Color(0xFF49E6FF), Color(0xFF5A46C7), Color(0xFF02050A)]).createShader(Rect.fromCircle(center: m, radius: scale)));
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.15..color = const Color(0xFF8DEBFF).withValues(alpha: .72);
    for (var i = 0; i < 9; i++) {
      final lat = -1 + i * .25; final y = lat * scale; final width = math.sqrt(math.max(0, 1 - lat * lat)) * scale;
      c.save(); c.translate(m.dx, m.dy + y); c.rotate(phase * math.pi * 2 * (i.isEven ? .12 : -.08));
      c.drawOval(Rect.fromCenter(center: Offset.zero, width: width * 2, height: scale * .22), p); c.restore();
    }
    for (var i = 0; i < 4; i++) {
      final a = phase * math.pi * 2 * (1 + i * .11) + i * 1.57; final pos = m + Offset(math.cos(a) * scale * 1.18, math.sin(a * 1.7) * scale * .62);
      c.drawCircle(pos, 2.1, Paint()..color = const Color(0xFFFFC978));
    }
    c.drawCircle(m.translate(-scale * .25, -scale * .3), scale * .10, Paint()..color = Colors.white.withValues(alpha: .65));
  }
  @override bool shouldRepaint(covariant _Yansi3DPainter old) => true;
}
