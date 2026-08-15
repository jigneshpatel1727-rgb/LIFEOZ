import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LifeOZExactMasterHome extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZExactMasterHome({super.key, required this.prefs});

  @override
  State<LifeOZExactMasterHome> createState() => _LifeOZExactMasterHomeState();
}

class _LifeOZExactMasterHomeState extends State<LifeOZExactMasterHome> {
  final FlutterTts _tts = FlutterTts();
  String _name = '';
  int _reality = 0;

  static const realities = <String>[
    '01_Oreon_Prime.png',
    '02_Terra_Flux.png',
    '03_Vortex_Nexus.png',
    '04_Crysta_Lumen.png',
    '09_Nebula_Soul-1.png',
    '10_Shadow_Core-1.png',
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.prefs.getString('user_name') ?? '';
    _reality = (widget.prefs.getInt('lifeoz_reality') ?? 0).clamp(0, realities.length - 1);
    _tts.setSpeechRate(0.44);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _profile() async {
    final controller = TextEditingController(text: _name);
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF050A12),
        title: const Text('PROFILE'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('SAVE')),
        ],
      ),
    );
    if (value != null && value.isNotEmpty) {
      await widget.prefs.setString('user_name', value);
      if (mounted) setState(() => _name = value);
    }
  }

  void _core(int index) {
    const messages = [
      'Life and growth intelligence.',
      'Guardian and care intelligence.',
      'Prosperity and money intelligence.',
      'Time and commitments intelligence.',
      'Personal intelligence, diary and goals.',
    ];
    _speak(messages[index]);
  }

  void _controls() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF050A12),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.person_outline), title: const Text('Profile'), onTap: () { Navigator.pop(ctx); _profile(); }),
            ListTile(leading: const Icon(Icons.palette_outlined), title: const Text('Design'), onTap: () { Navigator.pop(ctx); _showDesigns(); }),
            const ListTile(leading: Icon(Icons.security_outlined), title: Text('Permissions')),
            const ListTile(leading: Icon(Icons.settings_outlined), title: Text('Settings')),
          ],
        ),
      ),
    );
  }

  void _showDesigns() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF03060D),
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * .82,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('LIFEOZ VISUAL REALITIES', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w700)),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: .72),
                  itemCount: realities.length,
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () async {
                      await widget.prefs.setInt('lifeoz_reality', i);
                      if (mounted) setState(() => _reality = i);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(realities[i], fit: BoxFit.cover),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(color: _reality == i ? Colors.cyanAccent : Colors.white12, width: _reality == i ? 3 : 1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01030A),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final h = c.maxHeight;
            final center = Offset(w * .50, h * .48);
            final positions = <Offset>[
              Offset(w * .50, h * .27),
              Offset(w * .23, h * .44),
              Offset(w * .77, h * .44),
              Offset(w * .30, h * .67),
              Offset(w * .70, h * .67),
            ];

            return Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _CosmicPainter(reality: _reality))),

                // The master-board images are references/selection assets only.
                // They must never be painted as posters on the home screen.
                Positioned(
                  left: 26,
                  top: 16,
                  child: GestureDetector(
                    onTap: () => _speak('LifeOZ. Living intelligence for your life.'),
                    child: const SizedBox(width: 62, height: 62, child: CustomPaint(painter: _LifeOZMarkPainter())),
                  ),
                ),
                Positioned(
                  left: 98,
                  top: 22,
                  child: Text(
                    'L I F E O Z',
                    style: TextStyle(color: Colors.white.withOpacity(.96), fontSize: 30, fontWeight: FontWeight.w500, letterSpacing: 6),
                  ),
                ),
                Positioned(
                  right: 22,
                  top: 19,
                  child: GestureDetector(
                    onTap: _controls,
                    child: const SizedBox(width: 56, height: 56, child: CustomPaint(painter: _ControlGlyphPainter())),
                  ),
                ),

                Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _EnergyNetworkPainter(positions: positions, center: center)))),

                Positioned(
                  left: w * .22,
                  top: h * .29,
                  width: w * .56,
                  height: h * .37,
                  child: GestureDetector(
                    onTap: () => _speak(_name.isEmpty ? 'I am Yansi, your silent LifeOS intelligence.' : 'I am Yansi, your silent LifeOS intelligence, ${_name}.'),
                    child: const CustomPaint(painter: _YansiLivingPainter()),
                  ),
                ),

                ...List.generate(
                  5,
                  (i) => Positioned(
                    left: positions[i].dx - 46,
                    top: positions[i].dy - 46,
                    width: 92,
                    height: 92,
                    child: GestureDetector(
                      onTap: () => _core(i),
                      child: CustomPaint(painter: _CoreSymbolPainter(index: i)),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 18,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'LIVING INTELLIGENCE',
                      style: TextStyle(color: Colors.white.withOpacity(.68), letterSpacing: 3.2, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LifeOZMarkPainter extends CustomPainter {
  const _LifeOZMarkPainter();
  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height / 2);
    final gold = Paint()..color = const Color(0xFFFFC15A)..style = PaintingStyle.stroke..strokeWidth = 2.4;
    c.drawCircle(center, s.width * .46, gold);
    final p = Path()
      ..moveTo(center.dx - 20, center.dy)
      ..cubicTo(center.dx - 10, center.dy - 13, center.dx + 5, center.dy - 13, center.dx + 17, center.dy)
      ..cubicTo(center.dx + 5, center.dy + 13, center.dx - 10, center.dy + 13, center.dx - 20, center.dy)
      ..moveTo(center.dx - 5, center.dy)
      ..cubicTo(center.dx + 3, center.dy - 8, center.dx + 14, center.dy - 7, center.dx + 20, center.dy)
      ..cubicTo(center.dx + 12, center.dy + 8, center.dx + 2, center.dy + 7, center.dx - 5, center.dy);
    c.drawPath(p, gold);
    c.drawCircle(Offset(center.dx + 5, center.dy), 3.2, Paint()..color = const Color(0xFF54E69A));
  }
  @override
  bool shouldRepaint(covariant _LifeOZMarkPainter oldDelegate) => false;
}

class _ControlGlyphPainter extends CustomPainter {
  const _ControlGlyphPainter();
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = const Color(0xFFFFC15A)..style = PaintingStyle.stroke..strokeWidth = 2.2..strokeCap = StrokeCap.round;
    final x = s.width / 2;
    for (var i = 0; i < 3; i++) {
      final y = 16.0 + i * 12;
      c.drawLine(13, y, 43, y, p);
    }
    c.drawCircle(25, 16, 3.5, Paint()..color = const Color(0xFFFFC15A));
    c.drawCircle(36, 28, 3.5, Paint()..color = const Color(0xFFFFC15A));
    c.drawCircle(22, 40, 3.5, Paint()..color = const Color(0xFFFFC15A));
    c.drawCircle(0, 0, 0, Paint()..color = Colors.transparent);
  }
  @override
  bool shouldRepaint(covariant _ControlGlyphPainter oldDelegate) => false;
}

class _YansiLivingPainter extends CustomPainter {
  const _YansiLivingPainter();
  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height * .54);
    final r = math.min(s.width, s.height) * .22;

    final glow = Paint()
      ..shader = RadialGradient(colors: [const Color(0xFF4DEBFF).withOpacity(.55), const Color(0xFF5B61FF).withOpacity(.22), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: r * 2.2));
    c.drawCircle(center, r * 2.2, glow);

    final sphere = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFF42E9FF), Color(0xFF4389FF), Color(0xFF8053E8)]).createShader(Rect.fromCircle(center: center, radius: r));
    c.drawCircle(center, r, sphere);

    final wire = Paint()..color = Colors.white.withOpacity(.76)..style = PaintingStyle.stroke..strokeWidth = 1.4;
    for (var i = -2; i <= 2; i++) {
      final y = center.dy + i * r * .25;
      c.drawOval(Rect.fromCenter(center: Offset(center.dx, y), width: r * 1.85, height: r * .27), wire);
    }
    c.drawOval(Rect.fromCenter(center: center, width: r * 1.9, height: r * .62), wire);

    final gold = Paint()..color = const Color(0xFFFFC15A).withOpacity(.95)..style = PaintingStyle.stroke..strokeWidth = 2.1;
    final yansi = Path()
      ..moveTo(center.dx, center.dy - r * 1.32)
      ..cubicTo(center.dx - r * .76, center.dy - r * .66, center.dx - r * .72, center.dy + r * .62, center.dx, center.dy + r * 1.32)
      ..cubicTo(center.dx + r * .72, center.dy + r * .62, center.dx + r * .76, center.dy - r * .66, center.dx, center.dy - r * 1.32);
    c.drawPath(yansi, gold);

    final core = Paint()..color = Colors.white..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    c.drawCircle(center, r * .12, core);
    c.drawCircle(center, r * .07, Paint()..color = Colors.white);
  }
  @override
  bool shouldRepaint(covariant _YansiLivingPainter oldDelegate) => false;
}

class _CoreSymbolPainter extends CustomPainter {
  final int index;
  const _CoreSymbolPainter({required this.index});
  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height / 2);
    const colors = [Color(0xFF58EF88), Color(0xFFFF6470), Color(0xFFFFC04D), Color(0xFF4BE1FF), Color(0xFFC66BFF)];
    final color = colors[index];
    c.drawCircle(center, 28, Paint()..color = color.withOpacity(.16)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.3..strokeCap = StrokeCap.round;

    switch (index) {
      case 0:
        final leaf = Path()..moveTo(center.dx, center.dy + 26)..cubicTo(center.dx - 29, center.dy + 4, center.dx - 23, center.dy - 23, center.dx, center.dy - 29)..cubicTo(center.dx + 25, center.dy - 20, center.dx + 25, center.dy + 8, center.dx, center.dy + 26)..close();
        c.drawPath(leaf, p);
        c.drawLine(Offset(center.dx, center.dy + 20), Offset(center.dx, center.dy - 20), p);
        break;
      case 1:
        final heart = Path()..moveTo(center.dx, center.dy + 27)..cubicTo(center.dx - 39, center.dy, center.dx - 27, center.dy - 29, center.dx, center.dy - 10)..cubicTo(center.dx + 27, center.dy - 29, center.dx + 39, center.dy, center.dx, center.dy + 27)..close();
        c.drawPath(heart, p);
        break;
      case 2:
        final spiral = Path();
        for (var i = 0; i <= 52; i++) {
          final t = i / 52 * math.pi * 2.7;
          final radius = 2.0 + i * .48;
          final point = Offset(center.dx + math.cos(t) * radius, center.dy + math.sin(t) * radius);
          if (i == 0) spiral.moveTo(point.dx, point.dy); else spiral.lineTo(point.dx, point.dy);
        }
        c.drawPath(spiral, p);
        break;
      case 3:
        c.drawCircle(center, 23, p);
        c.drawCircle(center, 4, p);
        c.drawLine(center, Offset(center.dx, center.dy - 17), p);
        c.drawLine(center, Offset(center.dx + 14, center.dy + 10), p);
        break;
      case 4:
        final crystal = Path()..moveTo(center.dx, center.dy - 30)..lineTo(center.dx + 25, center.dy - 8)..lineTo(center.dx + 15, center.dy + 25)..lineTo(center.dx, center.dy + 31)..lineTo(center.dx - 15, center.dy + 25)..lineTo(center.dx - 25, center.dy - 8)..close();
        c.drawPath(crystal, p);
        c.drawLine(Offset(center.dx, center.dy - 30), Offset(center.dx, center.dy + 31), p);
        break;
    }
    c.drawCircle(center, 3.5, Paint()..color = Colors.white);
  }
  @override
  bool shouldRepaint(covariant _CoreSymbolPainter oldDelegate) => oldDelegate.index != index;
}

class _EnergyNetworkPainter extends CustomPainter {
  final List<Offset> positions;
  final Offset center;
  const _EnergyNetworkPainter({required this.positions, required this.center});
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0xFF4DB9D6).withOpacity(.15);
    for (final point in positions) {
      c.drawLine(center, point, p);
    }
    final ring = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0xFF4DB9D6).withOpacity(.13);
    c.drawOval(Rect.fromCenter(center: center, width: s.width * .98, height: s.width * .30), ring);
    c.drawOval(Rect.fromCenter(center: center, width: s.width * .74, height: s.width * .22), ring);
  }
  @override
  bool shouldRepaint(covariant _EnergyNetworkPainter oldDelegate) => false;
}

class _CosmicPainter extends CustomPainter {
  final int reality;
  const _CosmicPainter({required this.reality});
  @override
  void paint(Canvas c, Size s) {
    final base = Paint()..shader = const RadialGradient(center: Alignment(0, .05), radius: 1.15, colors: [Color(0xFF071A29), Color(0xFF030811), Color(0xFF01030A)]).createShader(Offset.zero & s);
    c.drawRect(Offset.zero & s, base);

    final star = Paint()..color = Colors.white.withOpacity(.22 + reality * .008);
    for (var i = 0; i < 105; i++) {
      final x = (i * 83.0 + 17) % s.width;
      final y = (i * 137.0 + 31) % s.height;
      c.drawCircle(Offset(x, y), i % 9 == 0 ? 1.5 : .8, star);
    }

    final ring = Paint()..color = const Color(0xFF1C8CA0).withOpacity(.14)..style = PaintingStyle.stroke..strokeWidth = 1;
    final center = Offset(s.width / 2, s.height * .48);
    for (final r in [s.width * .33, s.width * .45, s.width * .57]) {
      c.drawOval(Rect.fromCenter(center: center, width: r * 2, height: r * .56), ring);
    }
  }
  @override
  bool shouldRepaint(covariant _CosmicPainter oldDelegate) => oldDelegate.reality != reality;
}
