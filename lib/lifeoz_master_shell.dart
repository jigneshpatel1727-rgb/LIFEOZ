import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LifeOZMasterShell extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZMasterShell({super.key, required this.prefs});
  @override
  State<LifeOZMasterShell> createState() => _LifeOZMasterShellState();
}

class _LifeOZMasterShellState extends State<LifeOZMasterShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();
  final FlutterTts tts = FlutterTts();
  String name = '';
  int active = -1;
  bool showProfile = false;

  static const coreColors = <Color>[
    Color(0xFF55E89A),
    Color(0xFFFFB24A),
    Color(0xFFB96BFF),
    Color(0xFF47DFFF),
    Color(0xFFE16CFF),
  ];
  static const coreSpeech = <String>[
    'Your life and growth intelligence is ready.',
    'Your care and guardian intelligence is ready.',
    'Your prosperity intelligence is ready.',
    'Your time and commitment intelligence is ready.',
    'Your personal intelligence is ready.',
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
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF08131D),
        title: const Text('PROFILE', style: TextStyle(letterSpacing: 2)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Name',
            labelStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('SAVE'),
          ),
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
            children: <Widget>[
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
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        final center = Offset(w / 2, h * .47);
        final radiusX = math.min(w * .36, 150.0);
        final radiusY = math.min(h * .27, 195.0);
        final nodes = List<Offset>.generate(5, (i) {
          final angle = -math.pi / 2 + i * math.pi * 2 / 5;
          return Offset(
            center.dx + math.cos(angle) * radiusX,
            center.dy + math.sin(angle) * radiusY,
          );
        });
        return Stack(
          children: <Widget>[
            Positioned(
              top: 10,
              left: 18,
              right: 18,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CustomPaint(painter: _LifeOZLogoPainter(motion.value)),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'LIFEOZ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => showProfile = true),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: .22),
                        border: Border.all(
                          color: const Color(0xFFFFB45B).withValues(alpha: .75),
                        ),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Color(0xFFFFB45B),
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _NeuralFieldPainter(motion.value, center, nodes, active),
              ),
            ),
            for (int i = 0; i < 5; i++)
              Positioned(
                left: nodes[i].dx - 43,
                top: nodes[i].dy - 43,
                child: GestureDetector(
                  onTap: () {
                    setState(() => active = i);
                    _speak(coreSpeech[i]);
                  },
                  child: SizedBox(
                    width: 86,
                    height: 86,
                    child: CustomPaint(
                      painter: _Core3DPainter(i, coreColors[i], motion.value, active == i),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: center.dx - math.min(w * .34, 150.0),
              top: center.dy - math.min(w * .34, 150.0),
              child: IgnorePointer(
                child: SizedBox(
                  width: math.min(w * .68, 300.0),
                  height: math.min(w * .68, 300.0),
                  child: CustomPaint(painter: _Yansi3DPainter(motion.value)),
                ),
              ),
            ),
            if (active >= 0) _insightChip(active),
            Positioned(
              bottom: 18,
              left: 24,
              right: 24,
              child: Text(
                name.isEmpty ? 'LIVING INTELLIGENCE' : 'WELCOME, ${name.toUpperCase()}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  letterSpacing: 2.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _insightChip(int index) {
    return Positioned(
      left: 28,
      right: 28,
      bottom: 52,
      child: GestureDetector(
        onTap: () => setState(() => active = -1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF06111A).withValues(alpha: .92),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: coreColors[index].withValues(alpha: .55)),
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.auto_awesome, color: coreColors[index], size: 17),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  coreSpeech[index],
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
              const Icon(Icons.close, color: Colors.white38, size: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileOverlay() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xE801040A),
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: const Color(0xFF07121C),
              border: Border.all(color: const Color(0xFFFFB45B).withValues(alpha: .55)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'LIFEOZ PROFILE',
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 2.2,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                const CircleAvatar(
                  radius: 38,
                  backgroundColor: Color(0xFF102533),
                  child: Icon(Icons.person_outline, color: Color(0xFFFFB45B), size: 38),
                ),
                const SizedBox(height: 12),
                Text(
                  name.isEmpty ? 'Your name' : name,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _editName,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('CORRECT / EDIT NAME'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() => showProfile = false),
                  child: const Text('CLOSE'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UniversePainter extends CustomPainter {
  final double phase;
  _UniversePainter(this.phase);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          radius: 1.1,
          colors: <Color>[Color(0xFF071B2B), Color(0xFF01040A), Color(0xFF000106)],
        ).createShader(rect),
    );
    final rng = math.Random(42);
    for (int i = 0; i < 120; i++) {
      final alpha = .14 + .25 * ((math.sin(phase * math.pi * 2 + i) + 1) / 2);
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        .45 + rng.nextDouble() * 1.2,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }
    final center = Offset(size.width / 2, size.height * .47);
    for (int i = 0; i < 7; i++) {
      final radius = 95.0 + i * 42;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(phase * math.pi * 2 * (i.isEven ? .035 : -.025));
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: radius * 2, height: radius * .56),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .65
          ..color = const Color(0xFF48DFFF).withValues(alpha: .07),
      );
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(covariant _UniversePainter oldDelegate) => true;
}

class _NeuralFieldPainter extends CustomPainter {
  final double phase;
  final Offset center;
  final List<Offset> nodes;
  final int active;
  _NeuralFieldPainter(this.phase, this.center, this.nodes, this.active);
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < nodes.length; i++) {
      final color = _LifeOZMasterShellState.coreColors[i];
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = active == i ? 2 : .75
        ..color = color.withValues(alpha: active == i ? .42 : .17);
      canvas.drawLine(center, nodes[i], paint);
      for (int k = 0; k < 3; k++) {
        final t = (phase + k / 3 + i * .09) % 1;
        final position = Offset.lerp(center, nodes[i], t)!;
        canvas.drawCircle(position, active == i ? 2.6 : 1.4, Paint()..color = color.withValues(alpha: .75));
      }
    }
  }
  @override
  bool shouldRepaint(covariant _NeuralFieldPainter oldDelegate) => true;
}

class _LifeOZLogoPainter extends CustomPainter {
  final double phase;
  _LifeOZLogoPainter(this.phase);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * .34;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = const Color(0xFFFFB45B);
    canvas.drawCircle(center, radius, paint);
    canvas.drawOval(Rect.fromCenter(center: center, width: radius * 1.55, height: radius * .65), paint);
    canvas.drawCircle(
      Offset(center.dx + math.cos(phase * math.pi * 2) * radius * .72, center.dy),
      2.4,
      Paint()..color = const Color(0xFF55E89A),
    );
  }
  @override
  bool shouldRepaint(covariant _LifeOZLogoPainter oldDelegate) => true;
}

class _Core3DPainter extends CustomPainter {
  final int index;
  final Color color;
  final double phase;
  final bool selected;
  _Core3DPainter(this.index, this.color, this.phase, this.selected);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 25 * (1 + .08 * math.sin(phase * math.pi * 2 + index));
    canvas.drawCircle(
      center,
      radius * 1.5,
      Paint()
        ..color = color.withValues(alpha: selected ? .25 : .12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[Colors.white.withValues(alpha: .9), color.withValues(alpha: .92), const Color(0xFF02060B)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    final orbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = selected ? 2 : 1.1
      ..color = color.withValues(alpha: selected ? .95 : .62);
    for (int k = 0; k < 3; k++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(phase * math.pi * 2 * (k.isEven ? .8 : -.55) + index);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: radius * 2.7, height: radius * .66), orbit);
      canvas.restore();
    }
    canvas.drawCircle(center, radius * .18, Paint()..color = Colors.white.withValues(alpha: .85));
  }
  @override
  bool shouldRepaint(covariant _Core3DPainter oldDelegate) => true;
}

class _Yansi3DPainter extends CustomPainter {
  final double phase;
  _Yansi3DPainter(this.phase);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.shortestSide * .27;
    final breathe = 1 + .045 * math.sin(phase * math.pi * 2);
    canvas.drawCircle(
      center,
      scale * 1.65,
      Paint()
        ..color = const Color(0xFF43DFFF).withValues(alpha: .13)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );
    canvas.drawCircle(
      center,
      scale * breathe,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.25, -.28),
          radius: 1,
          colors: <Color>[Colors.white, Color(0xFF49E6FF), Color(0xFF5A46C7), Color(0xFF02050A)],
        ).createShader(Rect.fromCircle(center: center, radius: scale)),
    );
    final orbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..color = const Color(0xFF8DEBFF).withValues(alpha: .72);
    for (int i = 0; i < 8; i++) {
      final latitude = -1 + i * .285;
      final y = latitude * scale;
      final width = math.sqrt(math.max(0, 1 - latitude * latitude)) * scale;
      canvas.save();
      canvas.translate(center.dx, center.dy + y);
      canvas.rotate(phase * math.pi * 2 * (i.isEven ? .12 : -.08));
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: width * 2, height: scale * .22), orbit);
      canvas.restore();
    }
    final particlePaint = Paint()..color = Colors.white.withValues(alpha: .7);
    for (int i = 0; i < 32; i++) {
      final angle = phase * math.pi * 2 * (.35 + i * .01) + i;
      final radius = scale * (.72 + (i % 7) * .045);
      canvas.drawCircle(
        center + Offset(math.cos(angle) * radius, math.sin(angle * 1.3) * radius),
        .9,
        particlePaint,
      );
    }
  }
  @override
  bool shouldRepaint(covariant _Yansi3DPainter oldDelegate) => true;
}
