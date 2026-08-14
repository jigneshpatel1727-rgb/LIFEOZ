import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LIFEOZ MASTER EXPERIENCE
/// The user's supplied master board is the visual source of truth.
/// This is an interactive implementation: symbols are live controls,
/// Yansi is animated, and six visual realities are animated realms.
class LifeOZMasterShell extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZMasterShell({super.key, required this.prefs});

  @override
  State<LifeOZMasterShell> createState() => _LifeOZMasterShellState();
}

class _LifeOZMasterShellState extends State<LifeOZMasterShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  final FlutterTts _tts = FlutterTts();
  Timer? _splashTimer;

  String _name = '';
  bool _splash = true;
  String _layer = 'home';
  int _activeCore = -1;
  int _environment = 0;
  int _reality = 0;

  static const List<Color> coreColors = <Color>[
    Color(0xFF38E88A),
    Color(0xFFFFA63D),
    Color(0xFFB46CFF),
    Color(0xFF42DFFF),
    Color(0xFFD15CFF),
  ];

  static const List<String> coreMessages = <String>[
    'Life intelligence is ready.',
    'Growth and goals intelligence is ready.',
    'Productivity intelligence is ready.',
    'Time and calendar intelligence is ready.',
    'Future and possibility intelligence is ready.',
  ];

  static const List<String> environments = <String>[
    'Morning',
    'Work',
    'Evening',
    'Focus',
    'Rest',
  ];

  static const List<String> realities = <String>[
    'OREON PRIME',
    'TERRA FLUX',
    'VORTEX NEXUS',
    'CRYSTA LUMEN',
    'NEBULA SOUL',
    'SHADOW CORE',
  ];

  static const List<String> realitySubtitles = <String>[
    'Living Cosmic Organism',
    'Organic Nature Tech',
    'Dimensional Rings',
    'Light Geometry',
    'Emotion & Energy',
    'Minimal Dark Matter',
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.prefs.getString('user_name') ?? '';
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _tts.setSpeechRate(0.44);
    _splashTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _splash = false);
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _motion.dispose();
    _tts.stop();
    super.dispose();
  }

  Color fade(Color color, double alpha) => color.withValues(alpha: alpha);

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  void _openCore(int index) {
    setState(() {
      _activeCore = index;
      _layer = 'core';
    });
    _speak(coreMessages[index]);
  }

  void _openReality(int index) {
    setState(() {
      _reality = index;
      _layer = 'reality';
    });
    _speak('${realities[index]} selected. Entering the living realm.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01040A),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _motion,
          builder: (context, child) => Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CustomPaint(painter: _MasterBackground(_motion.value, _reality)),
              if (_splash) _buildSplash() else _buildHome(),
              if (!_splash && _layer != 'home') _buildLayer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplash() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CustomPaint(
            size: const Size(190, 190),
            painter: _YansiPainter(_motion.value, const Color(0xFF20D9FF)),
          ),
          const SizedBox(height: 18),
          const Text(
            'LifeOZ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Initiating Your Universe...',
            style: TextStyle(
              color: Color(0xFF63E8FF),
              fontSize: 10,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight;
        final Offset center = Offset(w / 2, h * .45);
        final List<Offset> nodes = <Offset>[
          Offset(w * .50, h * .16),
          Offset(w * .19, h * .30),
          Offset(w * .81, h * .30),
          Offset(w * .20, h * .69),
          Offset(w * .80, h * .69),
        ];

        return Stack(
          children: <Widget>[
            Positioned(top: 12, left: 18, right: 18, child: _topBar()),
            Positioned.fill(
              child: CustomPaint(
                painter: _MasterNetwork(_motion.value, nodes, center, _activeCore),
              ),
            ),
            for (int i = 0; i < nodes.length; i++)
              Positioned(
                left: nodes[i].dx - 58,
                top: nodes[i].dy - 58,
                child: GestureDetector(
                  onTap: () => _openCore(i),
                  child: CustomPaint(
                    size: const Size(116, 116),
                    painter: _CorePainter(i, coreColors[i], _activeCore == i, _motion.value),
                  ),
                ),
              ),
            Positioned(
              left: center.dx - 145,
              top: center.dy - 145,
              child: GestureDetector(
                onTap: () => _speak(
                  _name.isEmpty
                      ? 'I am Yansi, your personal LifeOS intelligence.'
                      : 'Welcome, $_name. I am Yansi, your personal LifeOS intelligence.',
                ),
                child: CustomPaint(
                  size: const Size(290, 290),
                  painter: _YansiPainter(
                    _motion.value,
                    _activeCore < 0 ? const Color(0xFF20D9FF) : coreColors[_activeCore],
                  ),
                ),
              ),
            ),
            Positioned(left: 18, right: 18, bottom: 14, child: _bottomControls()),
          ],
        );
      },
    );
  }

  Widget _topBar() {
    return Row(
      children: <Widget>[
        CustomPaint(size: const Size(48, 48), painter: _LogoPainter()),
        const SizedBox(width: 10),
        const Text(
          'LifeOZ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        const Spacer(),
        _roundButton(Icons.tune_rounded, () => setState(() => _layer = 'hologram')),
      ],
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fade(Colors.black, .30),
          border: Border.all(color: fade(const Color(0xFF20D9FF), .70)),
          boxShadow: <BoxShadow>[
            BoxShadow(color: fade(const Color(0xFF20D9FF), .20), blurRadius: 18),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF20D9FF), size: 25),
      ),
    );
  }

  Widget _bottomControls() {
    return Row(
      children: <Widget>[
        Expanded(
          child: _bottomButton(Icons.auto_awesome, 'REALITIES', () => setState(() => _layer = 'realities')),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _bottomButton(Icons.wb_sunny_outlined, environments[_environment].toUpperCase(), () => setState(() => _layer = 'environment')),
        ),
      ],
    );
  }

  Widget _bottomButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: fade(Colors.black, .34),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: fade(const Color(0xFF6BEAFF), .18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: const Color(0xFF6BEAFF), size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1.3, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildLayer() {
    return Positioned.fill(
      child: Container(
        color: fade(Colors.black, .90),
        child: _layer == 'hologram'
            ? _hologramLayer()
            : _layer == 'environment'
                ? _environmentLayer()
                : _layer == 'realities'
                    ? _realitiesLayer()
                    : _layer == 'reality'
                        ? _realityLayer()
                        : _coreLayer(),
      ),
    );
  }

  Widget _layerHeader(String title, String subtitle) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 2)),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: Color(0xFF6BEAFF), fontSize: 9, letterSpacing: 1)),
      ],
    );
  }

  Widget _layerFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: GestureDetector(
        onTap: () => setState(() => _layer = 'home'),
        child: const Text('RETURN TO YOUR UNIVERSE', style: TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1.4)),
      ),
    );
  }

  Widget _hologramLayer() {
    const List<MapEntry<String, IconData>> items = <MapEntry<String, IconData>>[
      MapEntry<String, IconData>('PROFILE', Icons.person_outline),
      MapEntry<String, IconData>('DESIGN', Icons.auto_awesome),
      MapEntry<String, IconData>('PERMISSIONS', Icons.shield_outlined),
      MapEntry<String, IconData>('YANSI', Icons.psychology_outlined),
      MapEntry<String, IconData>('SETTINGS', Icons.tune),
    ];

    return Column(
      children: <Widget>[
        _layerHeader('HOLOGRAPHIC CONTROL', 'Tap a node • Open your universe'),
        Expanded(
          child: Center(
            child: SizedBox(
              width: 320,
              height: 360,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  CustomPaint(size: const Size(320, 360), painter: _HoloNetwork(_motion.value)),
                  GestureDetector(
                    onTap: () => _speak('Yansi is listening.'),
                    child: CustomPaint(size: const Size(94, 94), painter: _YansiPainter(_motion.value, const Color(0xFF20D9FF))),
                  ),
                  _holoPositioned(0, items[0].key, items[0].value),
                  _holoPositioned(1, items[1].key, items[1].value),
                  _holoPositioned(2, items[2].key, items[2].value),
                  _holoPositioned(3, items[3].key, items[3].value),
                  _holoPositioned(4, items[4].key, items[4].value),
                ],
              ),
            ),
          ),
        ),
        _layerFooter(),
      ],
    );
  }

  Widget _holoPositioned(int index, String label, IconData icon) {
    const List<double> left = <double>[0, 120, 240, 0, 240];
    const List<double> top = <double>[128, 28, 128, 240, 240];
    return Positioned(
      left: left[index],
      top: top[index],
      child: GestureDetector(
        onTap: () => _speak('$label control is ready.'),
        child: SizedBox(
          width: 80,
          child: Column(
            children: <Widget>[
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: fade(const Color(0xFF20D9FF), .68)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: fade(const Color(0xFF20D9FF), .24), blurRadius: 18),
                  ],
                ),
                child: Icon(icon, color: Colors.white70, size: 26),
              ),
              const SizedBox(height: 5),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _environmentLayer() {
    return Column(
      children: <Widget>[
        _layerHeader('ADAPTIVE ENVIRONMENT', 'Changes with time, mood & context'),
        Expanded(
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 14,
              runSpacing: 18,
              children: List<Widget>.generate(environments.length, (int i) {
                final bool selected = _environment == i;
                return GestureDetector(
                  onTap: () {
                    setState(() => _environment = i);
                    _speak('${environments[i]} environment selected.');
                  },
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: <Color>[coreColors[i], fade(Colors.black, .82)]),
                          border: Border.all(color: fade(coreColors[i], selected ? .95 : .42), width: selected ? 2 : 1),
                          boxShadow: <BoxShadow>[BoxShadow(color: fade(coreColors[i], .25), blurRadius: 22)],
                        ),
                        child: Icon(
                          <IconData>[Icons.wb_sunny, Icons.work_outline, Icons.nights_stay, Icons.center_focus_strong, Icons.spa][i],
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(environments[i], style: TextStyle(color: selected ? Colors.white : Colors.white54, fontSize: 9)),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
        _layerFooter(),
      ],
    );
  }

  Widget _realitiesLayer() {
    return Column(
      children: <Widget>[
        _layerHeader('6 UNIQUE VISUAL REALITIES', 'Each a different world, not just a theme'),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: .82),
            itemCount: realities.length,
            itemBuilder: (BuildContext context, int i) {
              final Color color = _realityColor(i);
              final bool selected = _reality == i;
              return GestureDetector(
                onTap: () => _openReality(i),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: fade(color, selected ? .95 : .42), width: selected ? 2 : 1),
                    gradient: RadialGradient(colors: <Color>[fade(color, .18), fade(Colors.black, .64)]),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(child: Center(child: CustomPaint(size: const Size(145, 150), painter: _RealityPainter(i, _motion.value, color)))),
                      Text('${i + 1}. ${realities[i]}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .7)),
                      const SizedBox(height: 4),
                      Text(realitySubtitles[i], style: TextStyle(color: fade(color, .92), fontSize: 7)),
                      const SizedBox(height: 9),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        _layerFooter(),
      ],
    );
  }

  Widget _realityLayer() {
    final Color color = _realityColor(_reality);
    return Column(
      children: <Widget>[
        _layerHeader(realities[_reality], realitySubtitles[_reality]),
        Expanded(
          child: Center(
            child: CustomPaint(size: const Size(330, 330), painter: _RealityPainter(_reality, _motion.value, color)),
          ),
        ),
        Text('Living • Adaptive • Moving', style: TextStyle(color: fade(color, .95), fontSize: 10, letterSpacing: 1.4)),
        const SizedBox(height: 14),
        _layerFooter(),
      ],
    );
  }

  Widget _coreLayer() {
    final int i = _activeCore.clamp(0, coreColors.length - 1);
    final Color color = coreColors[i];
    return Column(
      children: <Widget>[
        _layerHeader('LIFE INTELLIGENCE', coreMessages[i]),
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: () => _speak(coreMessages[i]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CustomPaint(size: const Size(240, 240), painter: _CorePainter(i, color, true, _motion.value)),
                  const SizedBox(height: 12),
                  Text('Tap the intelligence core to ask Yansi', style: TextStyle(color: fade(color, .88), fontSize: 10)),
                ],
              ),
            ),
          ),
        ),
        _layerFooter(),
      ],
    );
  }

  Color _realityColor(int i) {
    const List<Color> colors = <Color>[
      Color(0xFF26BFFF),
      Color(0xFF50E88A),
      Color(0xFFFFA936),
      Color(0xFFB56CFF),
      Color(0xFFFF5E8C),
      Color(0xFFE8EEF5),
    ];
    return colors[i];
  }
}

class _MasterBackground extends CustomPainter {
  final double phase;
  final int reality;
  _MasterBackground(this.phase, this.reality);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    const List<Color> bases = <Color>[
      Color(0xFF061B2D), Color(0xFF0A241A), Color(0xFF1C0B28),
      Color(0xFF100A27), Color(0xFF18091E), Color(0xFF020206),
    ];
    canvas.drawRect(rect, Paint()..shader = RadialGradient(colors: <Color>[bases[reality], const Color(0xFF010207)], radius: 1.08).createShader(rect));
    final math.Random random = math.Random(73 + reality);
    for (int i = 0; i < 130; i++) {
      final double alpha = .03 + .05 * ((math.sin(phase * math.pi * 2 + i) + 1) / 2);
      canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), .5 + random.nextDouble() * 1.3, Paint()..color = Colors.white.withValues(alpha: alpha));
    }
  }

  @override
  bool shouldRepaint(covariant _MasterBackground oldDelegate) => true;
}

class _MasterNetwork extends CustomPainter {
  final double phase;
  final List<Offset> nodes;
  final Offset center;
  final int active;
  _MasterNetwork(this.phase, this.nodes, this.center, this.active);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < nodes.length; i++) {
      final Color c = <Color>[
        const Color(0xFF38E88A), const Color(0xFFFFA63D), const Color(0xFFB46CFF),
        const Color(0xFF42DFFF), const Color(0xFFD15CFF),
      ][i];
      canvas.drawLine(center, nodes[i], Paint()..color = c.withValues(alpha: active == i ? .55 : .20)..strokeWidth = active == i ? 3 : 1.2);
      final double t = (phase + i * .17) % 1.0;
      final Offset p = Offset.lerp(center, nodes[i], t)!;
      canvas.drawCircle(p, 3.5, Paint()..color = c.withValues(alpha: .88));
    }
  }

  @override
  bool shouldRepaint(covariant _MasterNetwork oldDelegate) => true;
}

class _YansiPainter extends CustomPainter {
  final double phase;
  final Color color;
  _YansiPainter(this.phase, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2);
    final double r = size.shortestSide * .27;
    canvas.drawCircle(c, r * 1.45, Paint()..color = color.withValues(alpha: .22)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28));
    for (int i = 0; i < 3; i++) {
      final double rr = r * (1.05 + i * .18);
      canvas.drawOval(Rect.fromCenter(center: c, width: rr * 2, height: rr * .82), Paint()..color = color.withValues(alpha: .30 - i * .06)..style = PaintingStyle.stroke..strokeWidth = 2);
    }
    final Path p = Path();
    for (int i = 0; i <= 80; i++) {
      final double t = i / 80 * math.pi * 2;
      final double wave = math.sin(t * 2 + phase * math.pi * 2) * r * .18;
      final double x = c.dx + math.cos(t) * (r + wave);
      final double y = c.dy + math.sin(t) * (r + wave) * 1.18;
      if (i == 0) p.moveTo(x, y); else p.lineTo(x, y);
    }
    p.close();
    canvas.drawPath(p, Paint()..color = color.withValues(alpha: .72)..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawCircle(c, r * .48, Paint()..color = color.withValues(alpha: .20));
    canvas.drawCircle(c, r * .28, Paint()..color = color.withValues(alpha: .92));
    canvas.drawCircle(c, r * .12, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _YansiPainter oldDelegate) => true;
}

class _CorePainter extends CustomPainter {
  final int index;
  final Color color;
  final bool selected;
  final double phase;
  _CorePainter(this.index, this.color, this.selected, this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2);
    final double r = size.shortestSide * .25;
    canvas.drawCircle(c, r * 1.42, Paint()..color = color.withValues(alpha: selected ? .24 : .12)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));
    canvas.drawCircle(c, r * 1.05, Paint()..color = color.withValues(alpha: selected ? .85 : .45)..style = PaintingStyle.stroke..strokeWidth = selected ? 2.4 : 1.2);
    if (index == 0) {
      _leaf(canvas, c, r, phase);
    } else if (index == 1) {
      _heart(canvas, c, r, phase);
    } else if (index == 2) {
      _spiral(canvas, c, r, phase);
    } else if (index == 3) {
      _orbital(canvas, c, r, phase);
    } else {
      _crystal(canvas, c, r, phase);
    }
  }

  void _leaf(Canvas canvas, Offset c, double r, double phase) {
    final Path p = Path()..moveTo(c.dx, c.dy-r)..quadraticBezierTo(c.dx+r*.9,c.dy-r*.25,c.dx,c.dy+r)..quadraticBezierTo(c.dx-r*.9,c.dy-r*.25,c.dx,c.dy-r)..close();
    canvas.drawPath(p, Paint()..color = color.withValues(alpha: .28));
    canvas.drawPath(p, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawLine(Offset(c.dx,c.dy-r*.8), Offset(c.dx+math.sin(phase*math.pi*2)*r*.2,c.dy+r*.8), Paint()..color = Colors.white.withValues(alpha: .75)..strokeWidth = 2);
  }

  void _heart(Canvas canvas, Offset c, double r, double phase) {
    final Path p = Path()..moveTo(c.dx,c.dy+r)..cubicTo(c.dx-r*1.35,c.dy+r*.15,c.dx-r*.75,c.dy-r,c.dx,c.dy-r*.25)..cubicTo(c.dx+r*.75,c.dy-r,c.dx+r*1.35,c.dy+r*.15,c.dx,c.dy+r)..close();
    canvas.drawPath(p, Paint()..color = color.withValues(alpha: .22));
    canvas.drawPath(p, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawCircle(Offset(c.dx+math.sin(phase*math.pi*2)*r*.28,c.dy), r*.12, Paint()..color = Colors.white);
  }

  void _spiral(Canvas canvas, Offset c, double r, double phase) {
    final Path p = Path();
    for (int i=0;i<=100;i++) { final double t=i/100*math.pi*5+phase*math.pi*2; final double rr=r*.08+r*.92*(i/100); final double x=c.dx+math.cos(t)*rr; final double y=c.dy+math.sin(t)*rr; if(i==0)p.moveTo(x,y);else p.lineTo(x,y); }
    canvas.drawPath(p, Paint()..color=color..style=PaintingStyle.stroke..strokeWidth=3);
    canvas.drawCircle(c,r*.16,Paint()..color=Colors.white);
  }

  void _orbital(Canvas canvas, Offset c, double r, double phase) {
    for(int i=0;i<3;i++){ canvas.save(); canvas.translate(c.dx,c.dy); canvas.rotate(phase*math.pi*2+i*math.pi/3); canvas.drawOval(Rect.fromCenter(center:Offset.zero,width:r*1.7,height:r*.55),Paint()..color=color.withValues(alpha:.78)..style=PaintingStyle.stroke..strokeWidth=2.5); canvas.restore(); }
    canvas.drawCircle(c,r*.22,Paint()..color=color); canvas.drawCircle(c,r*.09,Paint()..color=Colors.white);
  }

  void _crystal(Canvas canvas, Offset c, double r, double phase) {
    final Path p=Path()..moveTo(c.dx,c.dy-r)..lineTo(c.dx+r*.55,c.dy-r*.25)..lineTo(c.dx+r*.30,c.dy+r)..lineTo(c.dx-r*.30,c.dy+r)..lineTo(c.dx-r*.55,c.dy-r*.25)..close();
    canvas.drawPath(p,Paint()..color=color.withValues(alpha:.22)); canvas.drawPath(p,Paint()..color=color..style=PaintingStyle.stroke..strokeWidth=3);
    canvas.drawCircle(Offset(c.dx+math.cos(phase*math.pi*2)*r*.16,c.dy+math.sin(phase*math.pi*2)*r*.16),r*.12,Paint()..color=Colors.white);
  }

  @override
  bool shouldRepaint(covariant _CorePainter oldDelegate) => true;
}

class _RealityPainter extends CustomPainter {
  final int index;
  final double phase;
  final Color color;
  _RealityPainter(this.index, this.phase, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c=Offset(size.width/2,size.height*.52); final double r=size.shortestSide*.26;
    for(int i=0;i<4;i++){ final double rr=r*(1.05+i*.25); canvas.drawOval(Rect.fromCenter(center:c,width:rr*2,height:rr*.72),Paint()..color=color.withValues(alpha:.32-i*.045)..style=PaintingStyle.stroke..strokeWidth=2); }
    if(index==0){_energy(canvas,c,r);}else if(index==1){_leaves(canvas,c,r);}else if(index==2){_rings(canvas,c,r);}else if(index==3){_crystals(canvas,c,r);}else if(index==4){_flame(canvas,c,r);}else{_shadow(canvas,c,r);}
    final double a=phase*math.pi*2; canvas.drawCircle(Offset(c.dx+math.cos(a)*r*1.5,c.dy+math.sin(a)*r*.8),3,Paint()..color=Colors.white);
  }

  void _energy(Canvas canvas, Offset c, double r){ final Path p=Path(); for(int i=0;i<=80;i++){final double t=i/80*math.pi*2;final double x=c.dx+math.sin(t*2)*r*.55;final double y=c.dy+math.cos(t)*r;if(i==0)p.moveTo(x,y);else p.lineTo(x,y);} canvas.drawPath(p,Paint()..color=color..style=PaintingStyle.stroke..strokeWidth=4);canvas.drawCircle(c,r*.16,Paint()..color=Colors.white); }
  void _leaves(Canvas canvas, Offset c, double r){ for(int i=0;i<5;i++){final Offset p=Offset(c.dx+math.sin(i*1.3)*r*.45,c.dy-r*.25+i*r*.16);final Path q=Path()..moveTo(p.dx,p.dy-r*.24)..quadraticBezierTo(p.dx+r*.32,p.dy,p.dx,p.dy+r*.24)..quadraticBezierTo(p.dx-r*.32,p.dy,p.dx,p.dy-r*.24)..close();canvas.drawPath(q,Paint()..color=color.withValues(alpha:.2));canvas.drawPath(q,Paint()..color=color..style=PaintingStyle.stroke..strokeWidth=2);} }
  void _rings(Canvas canvas, Offset c, double r){ for(int i=0;i<5;i++){canvas.save();canvas.translate(c.dx,c.dy);canvas.rotate(phase*math.pi*2+i*.55);canvas.drawOval(Rect.fromCenter(center:Offset.zero,width:r*1.7,height:r*.65),Paint()..color=color.withValues(alpha:.75)..style=PaintingStyle.stroke..strokeWidth=2);canvas.restore();}canvas.drawCircle(c,r*.18,Paint()..color=Colors.white); }
  void _crystals(Canvas canvas, Offset c, double r){ for(int i=0;i<7;i++){final double a=i/7*math.pi*2;final double rr=r*(.45+.08*(i%3));final Offset p=Offset(c.dx+math.cos(a)*r*.75,c.dy+math.sin(a)*r*.75);final Path q=Path()..moveTo(p.dx,p.dy-rr)..lineTo(p.dx+rr*.45,p.dy)..lineTo(p.dx,p.dy+rr)..lineTo(p.dx-rr*.45,p.dy)..close();canvas.drawPath(q,Paint()..color=color.withValues(alpha:.22));canvas.drawPath(q,Paint()..color=color..style=PaintingStyle.stroke..strokeWidth=2);} }
  void _flame(Canvas canvas, Offset c, double r){ final Path p=Path()..moveTo(c.dx,c.dy-r)..cubicTo(c.dx+r*.9,c.dy-r*.25,c.dx+r*.55,c.dy+r*.7,c.dx,c.dy+r)..cubicTo(c.dx-r*.55,c.dy+r*.7,c.dx-r*.9,c.dy-r*.25,c.dx,c.dy-r)..close();canvas.drawPath(p,Paint()..color=color.withValues(alpha:.22));canvas.drawPath(p,Paint()..color=color..style=PaintingStyle.stroke..strokeWidth=3);canvas.drawCircle(c,r*.15,Paint()..color=Colors.white); }
  void _shadow(Canvas canvas, Offset c, double r){ for(int i=0;i<3;i++){final double y=c.dy-r*.75+i*r*.75;canvas.drawCircle(Offset(c.dx,y),r*.30,Paint()..color=color.withValues(alpha:.08));canvas.drawCircle(Offset(c.dx,y),r*.30,Paint()..color=color.withValues(alpha:.78)..style=PaintingStyle.stroke..strokeWidth=2);}canvas.drawLine(Offset(c.dx,c.dy-r),Offset(c.dx,c.dy+r),Paint()..color=color.withValues(alpha:.8)..strokeWidth=2); }

  @override
  bool shouldRepaint(covariant _RealityPainter oldDelegate) => true;
}

class _HoloNetwork extends CustomPainter {
  final double phase;
  _HoloNetwork(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c=Offset(size.width/2,size.height/2);
    final Paint p=Paint()..color=const Color(0xFF20D9FF).withValues(alpha:.34)..style=PaintingStyle.stroke..strokeWidth=1.4;
    for(int i=0;i<4;i++){canvas.drawCircle(c,60+i*35,p);}
    final double a=phase*math.pi*2;canvas.drawCircle(Offset(c.dx+math.cos(a)*105,c.dy+math.sin(a)*105),4,Paint()..color=const Color(0xFF20D9FF));
  }

  @override
  bool shouldRepaint(covariant _HoloNetwork oldDelegate)=>true;
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset c=Offset(size.width/2,size.height/2);
    final Paint p=Paint()..color=const Color(0xFF20D9FF)..style=PaintingStyle.stroke..strokeWidth=2.5;
    canvas.drawCircle(c,20,p);
    final Path loop=Path()..moveTo(c.dx-12,c.dy)..cubicTo(c.dx-3,c.dy-12,c.dx+3,c.dy+12,c.dx+12,c.dy)..cubicTo(c.dx+3,c.dy-12,c.dx-3,c.dy+12,c.dx-12,c.dy);
    canvas.drawPath(loop,p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}
