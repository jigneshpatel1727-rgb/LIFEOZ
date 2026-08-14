import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LIFEOZ MASTER LAYOUT
/// Visual source of truth: user supplied master reference board.
/// Home: central Yansi intelligence + five symbolic cores, no core names.
/// Secondary layers: holographic control, adaptive environment, six visual realities.
class LifeOZMasterShell extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZMasterShell({super.key, required this.prefs});

  @override
  State<LifeOZMasterShell> createState() => _LifeOZMasterShellState();
}

class _LifeOZMasterShellState extends State<LifeOZMasterShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  final FlutterTts _tts = FlutterTts();
  Timer? _splashTimer;
  String _name = '';
  bool _splash = true;
  String _layer = 'home';
  int _activeCore = -1;
  int _environment = 0;
  int _reality = 0;

  static const coreColors = <Color>[
    Color(0xFF4FF5A9), // life / household
    Color(0xFFFFB84A), // goals / growth
    Color(0xFFB66BFF), // productivity
    Color(0xFF42D9FF), // time
    Color(0xFFC16BFF), // future / intelligence
  ];

  static const coreMessages = <String>[
    'I am opening your life and household intelligence.',
    'I am opening your goals and growth intelligence.',
    'I am opening your productivity intelligence.',
    'I am opening your time and calendar intelligence.',
    'I am opening your future and possibility intelligence.',
  ];

  static const environments = <String>['Morning', 'Work', 'Evening', 'Focus', 'Rest'];
  static const realities = <String>[
    'OREON PRIME',
    'TERRA FLUX',
    'VORTEX NEXUS',
    'CRYSTA LUMEN',
    'NEBULA SOUL',
    'SHADOW CORE',
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.prefs.getString('user_name') ?? '';
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
    _tts.setSpeechRate(0.44);
    _splashTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _splash = false);
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _pulse.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  void _core(int index) {
    setState(() => _activeCore = index);
    _speak(coreMessages[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01040A),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) => Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _MasterBackground(_pulse.value, _reality)),
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
        children: [
          CustomPaint(size: const Size(190, 190), painter: _YansiPainter(_pulse.value, const Color(0xFF20D9FF), large: true)),
          const SizedBox(height: 16),
          const Text('LifeOZ', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 5)),
          const SizedBox(height: 7),
          Text('Initiating Your Universe...', style: TextStyle(color: const Color(0xFF63E8FF).withOpacity(.75), fontSize: 10, letterSpacing: 1.8)),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return LayoutBuilder(
      builder: (_, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        final center = Offset(w / 2, h * .46);
        final nodes = <Offset>[
          Offset(w * .50, h * .16),
          Offset(w * .19, h * .30),
          Offset(w * .81, h * .30),
          Offset(w * .20, h * .70),
          Offset(w * .80, h * .70),
        ];
        return Stack(
          children: [
            Positioned(top: 12, left: 18, right: 18, child: _topBar()),
            Positioned.fill(child: CustomPaint(painter: _MasterNetwork(_pulse.value, nodes, center, _activeCore))),
            for (var i = 0; i < nodes.length; i++)
              Positioned(
                left: nodes[i].dx - 55,
                top: nodes[i].dy - 55,
                child: GestureDetector(
                  onTap: () => _core(i),
                  child: CustomPaint(size: const Size(110, 110), painter: _CoreMasterPainter(i, coreColors[i], _activeCore == i, _pulse.value)),
                ),
              ),
            Positioned(
              left: center.dx - 145,
              top: center.dy - 145,
              child: GestureDetector(
                onTap: () => _speak(_name.isEmpty ? 'I am Yansi, your personal LifeOS intelligence.' : 'Welcome, $_name. I am Yansi, your personal LifeOS intelligence.'),
                child: CustomPaint(size: const Size(290, 290), painter: _YansiPainter(_pulse.value, _activeCore < 0 ? const Color(0xFF20D9FF) : coreColors[_activeCore], large: true)),
              ),
            ),
            Positioned(left: 18, right: 18, bottom: 16, child: _adaptiveStrip()),
          ],
        );
      },
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        CustomPaint(size: const Size(46, 46), painter: _LogoPainter()),
        const SizedBox(width: 10),
        const Text('LifeOZ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 3)),
        const Spacer(),
        _controlButton(Icons.tune_rounded, () => setState(() => _layer = 'hologram')),
      ],
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(.28),
          border: Border.all(color: const Color(0xFF20D9FF).withOpacity(.65)),
          boxShadow: const [BoxShadow(color: Color(0x3320D9FF), blurRadius: 18)],
        ),
        child: const Icon(Icons.tune_rounded, color: Color(0xFF20D9FF), size: 25),
      ),
    );
  }

  Widget _adaptiveStrip() {
    return GestureDetector(
      onTap: () => setState(() => _layer = 'environment'),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.25),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF20D9FF), size: 18),
            const SizedBox(width: 8),
            Text(environments[_environment], style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildLayer() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(.88),
        child: _layer == 'hologram'
            ? _hologramLayer()
            : _layer == 'environment'
                ? _environmentLayer()
                : _realityLayer(),
      ),
    );
  }

  Widget _hologramLayer() {
    final items = <MapEntry<String, IconData>>[
      const MapEntry('PROFILE', Icons.person_outline),
      const MapEntry('DESIGN', Icons.auto_awesome),
      const MapEntry('PERMISSIONS', Icons.shield_outlined),
      const MapEntry('YANSI', Icons.psychology_outlined),
      const MapEntry('SETTINGS', Icons.tune),
    ];
    return _layerScaffold(
      'HOLOGRAPHIC CONTROL',
      'Tap a node • Open your universe',
      Center(
        child: SizedBox(
          width: 320,
          height: 340,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(size: const Size(320, 340), painter: _HoloNetwork(_pulse.value)),
              GestureDetector(
                onTap: () => _speak('Yansi is listening.'),
                child: CustomPaint(size: const Size(92, 92), painter: _YansiPainter(_pulse.value, const Color(0xFF20D9FF), large: false)),
              ),
              for (var i = 0; i < items.length; i++)
                Positioned(
                  left: const [8.0, 124.0, 232.0, 8.0, 232.0][i],
                  top: const [118.0, 28.0, 118.0, 224.0, 224.0][i],
                  child: _holoNode(items[i].key, items[i].value),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _holoNode(String label, IconData icon) {
    return GestureDetector(
      onTap: () => _speak('$label control is ready.'),
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(width: 58, height: 58, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF20D9FF).withOpacity(.65)), boxShadow: const [BoxShadow(color: Color(0x4420D9FF), blurRadius: 18)]), child: Icon(icon, color: Colors.white70, size: 26)),
            const SizedBox(height: 5),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 8, letterSpacing: .7)),
          ],
        ),
      ),
    );
  }

  Widget _environmentLayer() {
    return _layerScaffold(
      'ADAPTIVE ENVIRONMENT',
      'Changes with time, mood & context',
      Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 18,
          children: List.generate(environments.length, (i) {
            final selected = _environment == i;
            return GestureDetector(
              onTap: () {
                setState(() => _environment = i);
                _speak('${environments[i]} environment selected.');
              },
              child: Column(
                children: [
                  Container(width: 72, height: 72, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [coreColors[i], Colors.black87]), border: Border.all(color: coreColors[i].withOpacity(selected ? .9 : .45), width: selected ? 2 : 1), boxShadow: [BoxShadow(color: coreColors[i].withOpacity(.25), blurRadius: 22)]), child: Icon([Icons.wb_sunny, Icons.work_outline, Icons.nights_stay, Icons.center_focus_strong, Icons.spa][i], color: Colors.white, size: 28)),
                  const SizedBox(height: 7),
                  Text(environments[i], style: TextStyle(color: selected ? Colors.white : Colors.white54, fontSize: 9)),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _realityLayer() {
    return _layerScaffold(
      '6 UNIQUE VISUAL REALITIES',
      'Each a different world, not just a theme',
      GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .82),
        itemCount: realities.length,
        itemBuilder: (_, i) {
          final selected = _reality == i;
          return GestureDetector(
            onTap: () {
              setState(() => _reality = i);
              _speak('${realities[i]} visual reality selected.');
            },
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: coreColors[i % coreColors.length].withOpacity(selected ? .9 : .35), width: selected ? 2 : 1), gradient: RadialGradient(colors: [coreColors[i % coreColors.length].withOpacity(.18), Colors.black.withOpacity(.5)])),
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CustomPaint(size: const Size(92, 92), painter: _RealityPainter(i, _pulse.value, coreColors[i % coreColors.length])), const SizedBox(height: 10), Text('${i + 1}. ${realities[i]}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: .8))])),
            ),
          );
        },
      ),
    );
  }

  Widget _layerScaffold(String title, String subtitle, Widget child) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 2)),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: Color(0xFF6BEAFF), fontSize: 9, letterSpacing: 1)),
        const SizedBox(height: 22),
        Expanded(child: child),
        Padding(padding: const EdgeInsets.only(bottom: 18), child: GestureDetector(onTap: () => setState(() => _layer = 'home'), child: const Text('RETURN TO YOUR UNIVERSE', style: TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1.4)))),
      ],
    );
  }
}

class _MasterBackground extends CustomPainter {
  final double phase;
  final int reality;
  _MasterBackground(this.phase, this.reality);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = [const Color(0xFF061B2D), const Color(0xFF0A241A), const Color(0xFF1C0B28), const Color(0xFF100A27), const Color(0xFF061A25), const Color(0xFF020206)][reality];
    canvas.drawRect(rect, Paint()..shader = RadialGradient(colors: [base, const Color(0xFF010207)], radius: 1.08).createShader(rect));
    final random = math.Random(73 + reality);
    for (var i = 0; i < 110; i++) {
      final a = (.04 + .035 * math.sin(phase * math.pi * 2 + i)).clamp(.01, .10);
      canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), .5 + random.nextDouble() * 1.3, Paint()..color = (i % 3 == 0 ? const Color(0xFFFFC45A) : const Color(0xFF20D9FF)).withOpacity(a));
    }
    final c = Offset(size.width / 2, size.height * .46);
    for (var i = 0; i < 7; i++) {
      canvas.drawOval(Rect.fromCenter(center: c, width: 240 + i * 90.0, height: 120 + i * 58.0), Paint()..style = PaintingStyle.stroke..strokeWidth = .65..color = const Color(0xFF20D9FF).withOpacity(.04));
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
    for (var i = 0; i < nodes.length; i++) {
      final color = _LifeColors.core(i);
      final path = Path()..moveTo(nodes[i].dx, nodes[i].dy)..cubicTo(nodes[i].dx, nodes[i].dy + (center.dy - nodes[i].dy) * .28, center.dx, center.dy - (center.dy - nodes[i].dy) * .20, center.dx, center.dy);
      canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = active == i ? 3.2 : 1.0..color = color.withOpacity(active == i ? .72 : .25));
      final metrics = path.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final t = (phase + i * .19) % 1.0;
        final tan = metrics.first.getTangentForOffset(metrics.first.length * t);
        if (tan != null) canvas.drawCircle(tan.position, active == i ? 4 : 2.5, Paint()..color = color.withOpacity(.9));
      }
    }
  }
  @override
  bool shouldRepaint(covariant _MasterNetwork oldDelegate) => true;
}

class _YansiPainter extends CustomPainter {
  final double phase;
  final Color color;
  final bool large;
  _YansiPainter(this.phase, this.color, {required this.large});
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final scale = large ? 1.0 : .55;
    for (var i = 0; i < 8; i++) {
      final r = size.shortestSide * (.19 + i * .045) * scale;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(phase * math.pi * 2 * (i.isEven ? 1 : -1) + i * .38);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 2.0, height: r * .82), Paint()..style = PaintingStyle.stroke..strokeWidth = i == 2 ? 2.4 : .8..color = (i.isEven ? const Color(0xFF20D9FF) : const Color(0xFFFFC45A)).withOpacity(.28));
      canvas.restore();
    }
    final r = size.shortestSide * .15 * scale;
    canvas.drawCircle(c, r * 1.8, Paint()..color = color.withOpacity(.10)..maskFilter = MaskFilter.blur(BlurStyle.normal, large ? 30 : 16));
    canvas.drawCircle(c, r, Paint()..shader = RadialGradient(colors: [Colors.white, color, color.withOpacity(0)]).createShader(Rect.fromCircle(center: c, radius: r)));
    canvas.drawCircle(c, r * .28, Paint()..color = Colors.white..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
  }
  @override
  bool shouldRepaint(covariant _YansiPainter oldDelegate) => true;
}

class _CorePainter extends CustomPainter {
  final int index; final Color color; final bool active; final double phase;
  _CorePainter(this.index, this.color, this.active, this.phase);
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero); final r = size.shortestSide * .30;
    canvas.drawCircle(c, r, Paint()..color = color.withOpacity(active ? .26 : .10)..maskFilter = MaskFilter.blur(BlurStyle.normal, active ? 20 : 11));
    canvas.drawCircle(c, r, Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 2.6 : 1.1..color = color.withOpacity(active ? .95 : .58));
    canvas.save(); canvas.translate(c.dx, c.dy); canvas.rotate(phase * math.pi * 2 + index * .65);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 2.1, height: r * .62), Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = color.withOpacity(.55)); canvas.restore();
    final p = Path();
    if (index == 0) { p.moveTo(c.dx, c.dy + r*.75); p.cubicTo(c.dx-r*.8,c.dy,c.dx-r*.5,c.dy-r*.7,c.dx,c.dy-r*.9); p.cubicTo(c.dx+r*.5,c.dy-r*.7,c.dx+r*.8,c.dy,c.dx,c.dy+r*.75); }
    if (index == 1) { p.moveTo(c.dx,c.dy+r*.75); p.cubicTo(c.dx-r,c.dy,c.dx-r*.7,c.dy-r*.8,c.dx,c.dy-r*.25); p.cubicTo(c.dx+r*.7,c.dy-r*.8,c.dx+r,c.dy,c.dx,c.dy+r*.75); }
    if (index == 2) { for(var n=0;n<55;n++){final t=n/54;final a=t*math.pi*5+phase*math.pi*2;final rr=r*(1-t);final q=Offset(c.dx+math.cos(a)*rr,c.dy+math.sin(a)*rr);if(n==0)p.moveTo(q.dx,q.dy);else p.lineTo(q.dx,q.dy);}} 
    if (index == 3) { canvas.drawCircle(c,r*.65,Paint()..style=PaintingStyle.stroke..strokeWidth=2.5..color=color); canvas.drawLine(c,c+Offset(0,-r*.45),Paint()..color=color..strokeWidth=2.2); canvas.drawLine(c,c+Offset(r*.35,r*.22),Paint()..color=color..strokeWidth=2.2); }
    if (index == 4) { p.moveTo(c.dx,c.dy-r*.9);p.lineTo(c.dx+r*.58,c.dy-r*.22);p.lineTo(c.dx+r*.42,c.dy+r*.72);p.lineTo(c.dx,c.dy+r*.9);p.lineTo(c.dx-r*.42,c.dy+r*.72);p.lineTo(c.dx-r*.58,c.dy-r*.22);p.close(); }
    canvas.drawPath(p,Paint()..style=PaintingStyle.stroke..strokeWidth=2.8..strokeCap=StrokeCap.round..color=color);
    canvas.drawCircle(c,r*.11,Paint()..color=Colors.white..maskFilter=const MaskFilter.blur(BlurStyle.normal,4));
  }
  @override
  bool shouldRepaint(covariant _CorePainter oldDelegate)=>true;
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c=size.center(Offset.zero); final r=size.shortestSide*.42;
    canvas.drawCircle(c,r,Paint()..style=PaintingStyle.stroke..strokeWidth=2..color=const Color(0xFF20D9FF));
    final p=Path()..moveTo(c.dx,c.dy-r*.72)..cubicTo(c.dx-r*.75,c.dy-r*.2,c.dx-r*.55,c.dy+r*.35,c.dx,c.dy)..cubicTo(c.dx+r*.55,c.dy-r*.35,c.dx+r*.75,c.dy+r*.2,c.dx,c.dy+r*.72);
    canvas.drawPath(p,Paint()..style=PaintingStyle.stroke..strokeWidth=2.3..strokeCap=StrokeCap.round..color=const Color(0xFF20D9FF));
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}

class _HoloNetwork extends CustomPainter {
  final double phase; _HoloNetwork(this.phase);
  @override void paint(Canvas canvas,Size size){final c=size.center(Offset.zero);for(var i=0;i<5;i++){final a=-math.pi/2+i*2*math.pi/5;final p=Offset(c.dx+math.cos(a)*112,c.dy+math.sin(a)*112);canvas.drawLine(c,p,Paint()..color=const Color(0xFF20D9FF).withOpacity(.35)..strokeWidth=1.4);canvas.drawCircle(p,18+math.sin(phase*math.pi*2+i)*2,Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0xFF20D9FF).withOpacity(.45));}} 
  @override bool shouldRepaint(covariant _HoloNetwork oldDelegate)=>true;
}

class _RealityPainter extends CustomPainter {
  final int index; final double phase; final Color color; _RealityPainter(this.index,this.phase,this.color);
  @override void paint(Canvas canvas,Size size){final c=size.center(Offset.zero);for(var i=0;i<4;i++){final r=12+i*10.0;canvas.drawOval(Rect.fromCenter(center:c,width:r*2.5,height:r*1.0),Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=color.withOpacity(.35));}canvas.save();canvas.translate(c.dx,c.dy);canvas.rotate(phase*math.pi*2*(index.isEven?1:-1));canvas.drawCircle(Offset.zero,16,Paint()..shader=RadialGradient(colors:[Colors.white,color,Colors.transparent]).createShader(const Rect.fromCircle(center:Offset.zero,radius:16)));canvas.restore();}
  @override bool shouldRepaint(covariant _RealityPainter oldDelegate)=>true;
}

class _LifeColors {
  static Color core(int i) => const [Color(0xFF55F2B0),Color(0xFFFFC45A),Color(0xFFB77BFF),Color(0xFF20D9FF),Color(0xFFC16BFF)][i];
}
