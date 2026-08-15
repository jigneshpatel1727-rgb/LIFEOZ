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
                          Container(
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
            final positions = <Offset>[
              Offset(w * .50, h * .27),
              Offset(w * .24, h * .43),
              Offset(w * .76, h * .43),
              Offset(w * .29, h * .66),
              Offset(w * .71, h * .66),
            ];

            return Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _CosmicPainter(reality: _reality))),

                // Brand is rendered independently; no reference-board poster is placed on the home screen.
                Positioned(
                  left: 24,
                  top: 12,
                  width: w * .65,
                  height: 74,
                  child: Image.asset('02_LifeOZ_Full_Logo.png', fit: BoxFit.contain, alignment: Alignment.centerLeft),
                ),
                Positioned(
                  right: 16,
                  top: 12,
                  width: 64,
                  height: 64,
                  child: GestureDetector(
                    onTap: _controls,
                    child: Image.asset('04_Holographic_Control.png', fit: BoxFit.contain),
                  ),
                ),

                // Five clean intelligence symbols surround the central Yansi presence.
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _EnergyNetworkPainter(positions: positions),
                    ),
                  ),
                ),

                Positioned(
                  left: w * .22,
                  top: h * .31,
                  width: w * .56,
                  height: h * .31,
                  child: GestureDetector(
                    onTap: () => _speak('I am Yansi, your silent LifeOS intelligence. Tap a core when you want me to help.'),
                    child: const CustomPaint(painter: _YansiOrbPainter()),
                  ),
                ),

                ...List.generate(
                  5,
                  (i) => Positioned(
                    left: positions[i].dx - 44,
                    top: positions[i].dy - 44,
                    width: 88,
                    height: 88,
                    child: GestureDetector(
                      onTap: () => _core(i),
                      child: CustomPaint(painter: _CorePainter(index: i)),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 18,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      _name.isEmpty ? 'LIVING INTELLIGENCE' : 'LIVING INTELLIGENCE  •  ${_name.toUpperCase()}',
                      style: const TextStyle(color: Colors.white70, letterSpacing: 3, fontSize: 11, fontWeight: FontWeight.w600),
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

class _YansiOrbPainter extends CustomPainter {
  const _YansiOrbPainter();

  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height * .52);
    final radius = math.min(s.width, s.height) * .23;

    final glow = Paint()
      ..shader = RadialGradient(colors: [const Color(0xFF4BE7FF).withOpacity(.65), const Color(0xFF5265FF).withOpacity(.25), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: radius * 2.3));
    c.drawCircle(center, radius * 2.3, glow);

    final sphere = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFF39E6FF), Color(0xFF3C8DFF), Color(0xFF8055E8)]).createShader(Rect.fromCircle(center: center, radius: radius));
    c.drawCircle(center, radius, sphere);

    final wire = Paint()..color = Colors.white.withOpacity(.72)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    for (var i = -2; i <= 2; i++) {
      final y = center.dy + i * radius * .25;
      c.drawOval(Rect.fromCenter(center: Offset(center.dx, y), width: radius * 1.85, height: radius * .28), wire);
    }
    c.drawOval(Rect.fromCenter(center: center, width: radius * 1.9, height: radius * .62), wire);

    final coreGlow = Paint()..color = Colors.white.withOpacity(.24)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    c.drawCircle(center, radius * .28, coreGlow);
    c.drawCircle(center, radius * .12, Paint()..color = Colors.white);

    final gold = Paint()..color = const Color(0xFFFFC15A).withOpacity(.95)..style = PaintingStyle.stroke..strokeWidth = 2.2;
    final path = Path();
    path.moveTo(center.dx, center.dy - radius * 1.25);
    path.cubicTo(center.dx - radius * .72, center.dy - radius * .55, center.dx - radius * .72, center.dy + radius * .6, center.dx, center.dy + radius * 1.3);
    path.cubicTo(center.dx + radius * .72, center.dy + radius * .6, center.dx + radius * .72, center.dy - radius * .55, center.dx, center.dy - radius * 1.25);
    c.drawPath(path, gold);
  }

  @override
  bool shouldRepaint(covariant _YansiOrbPainter oldDelegate) => false;
}

class _CorePainter extends CustomPainter {
  final int index;
  const _CorePainter({required this.index});

  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height / 2);
    const colors = [Color(0xFF4FEF83), Color(0xFFFF5A61), Color(0xFFFFB83D), Color(0xFF42D9FF), Color(0xFFC86BFF)];
    final color = colors[index];
    final glow = Paint()..color = color.withOpacity(.20)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    c.drawCircle(center, 23, glow);
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.2;

    switch (index) {
      case 0: // organic leaf
        final path = Path()..moveTo(center.dx, center.dy + 24)..cubicTo(center.dx - 26, center.dy + 5, center.dx - 23, center.dy - 20, center.dx, center.dy - 28)..cubicTo(center.dx + 24, center.dy - 18, center.dx + 20, center.dy + 8, center.dx, center.dy + 24)..close();
        c.drawPath(path, p);
        c.drawLine(center.dx, center.dy + 17, center.dx, center.dy - 18, p);
        break;
      case 1: // heart / care
        final path = Path()..moveTo(center.dx, center.dy + 25)..cubicTo(center.dx - 42, center.dy - 2, center.dx - 25, center.dy - 30, center.dx, center.dy - 12)..cubicTo(center.dx + 25, center.dy - 30, center.dx + 42, center.dy - 2, center.dx, center.dy + 25)..close();
        c.drawPath(path, p);
        break;
      case 2: // prosperity spiral
        final path = Path();
        for (var i = 0; i <= 40; i++) {
          final t = i / 40 * math.pi * 2.5;
          final r = 2 + i * .55;
          final point = Offset(center.dx + math.cos(t) * r, center.dy + math.sin(t) * r);
          if (i == 0) path.moveTo(point.dx, point.dy); else path.lineTo(point.dx, point.dy);
        }
        c.drawPath(path, p);
        break;
      case 3: // time / orbital clock
        c.drawCircle(center, 22, p);
        c.drawCircle(center, 5, p);
        c.drawLine(center, Offset(center.dx, center.dy - 15), p);
        c.drawLine(center, Offset(center.dx + 13, center.dy + 9), p);
        break;
      case 4: // crystal / mind
        final path = Path()..moveTo(center.dx, center.dy - 28)..lineTo(center.dx + 23, center.dy - 7)..lineTo(center.dx + 14, center.dy + 24)..lineTo(center.dx, center.dy + 30)..lineTo(center.dx - 14, center.dy + 24)..lineTo(center.dx - 23, center.dy - 7)..close();
        c.drawPath(path, p);
        c.drawLine(center.dx, center.dy - 28, center.dx, center.dy + 30, p);
        break;
    }
    c.drawCircle(center, 3.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _CorePainter oldDelegate) => oldDelegate.index != index;
}

class _EnergyNetworkPainter extends CustomPainter {
  final List<Offset> positions;
  const _EnergyNetworkPainter({required this.positions});

  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height * .47);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0xFF46B7E8).withOpacity(.18);
    for (final p in positions) {
      c.drawLine(center, p, paint);
    }
    final ring = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0xFF3AA9C5).withOpacity(.14);
    c.drawOval(Rect.fromCenter(center: center, width: s.width * .95, height: s.width * .30), ring);
    c.drawOval(Rect.fromCenter(center: center, width: s.width * .72, height: s.width * .22), ring);
  }

  @override
  bool shouldRepaint(covariant _EnergyNetworkPainter oldDelegate) => false;
}

class _CosmicPainter extends CustomPainter {
  final int reality;
  const _CosmicPainter({required this.reality});

  @override
  void paint(Canvas c, Size s) {
    final base = Paint()..shader = const RadialGradient(center: Alignment(0, .05), radius: 1.1, colors: [Color(0xFF071A29), Color(0xFF030811), Color(0xFF01030A)]).createShader(Offset.zero & s);
    c.drawRect(Offset.zero & s, base);

    final star = Paint()..color = Colors.white.withOpacity(.22 + (reality * .008));
    for (var i = 0; i < 95; i++) {
      final x = (i * 83.0 + 17) % s.width;
      final y = (i * 137.0 + 31) % s.height;
      c.drawCircle(Offset(x, y), i % 9 == 0 ? 1.5 : .8, star);
    }

    final ring = Paint()..color = const Color(0xFF1C8CA0).withOpacity(.15)..style = PaintingStyle.stroke..strokeWidth = 1;
    final center = Offset(s.width / 2, s.height * .47);
    for (final r in [s.width * .33, s.width * .45, s.width * .57]) {
      c.drawOval(Rect.fromCenter(center: center, width: r * 2, height: r * .56), ring);
    }
  }

  @override
  bool shouldRepaint(covariant _CosmicPainter oldDelegate) => oldDelegate.reality != reality;
}
