import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lifeoz_core_hub.dart';

class LifeOZPhase2Home extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZPhase2Home({super.key, required this.prefs});
  @override
  State<LifeOZPhase2Home> createState() => _LifeOZPhase2HomeState();
}

class _LifeOZPhase2HomeState extends State<LifeOZPhase2Home> with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late final AnimationController _motion;
  bool _menuOpen = false;
  int? _activeCore;
  bool _yansiActive = false;

  static const _intro = [
    'Financial intelligence is ready. I can organise expenses, income and money insights.',
    'Goals and growth is ready. I can track goals, progress and completion.',
    'Productivity is ready. I can organise tasks and carry pending work forward.',
    'Household intelligence is ready. I can organise shopping and recurring home needs.',
    'Personal life intelligence is ready. I can organise diary and personal routines.',
  ];

  @override
  void initState() {
    super.initState();
    _tts.setSpeechRate(0.44);
    _motion = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _welcome());
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _welcome() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) await _speak('Welcome to LifeOS. I am Yansi, your personal AI. I am here whenever you need me.');
  }

  Future<void> _tapYansi() async {
    setState(() { _yansiActive = true; _activeCore = null; });
    await _speak('I am Yansi. Tap any intelligence core and I will explain it and open its report.');
    if (mounted) setState(() => _yansiActive = false);
  }

  Future<void> _tapCore(int index) async {
    setState(() { _activeCore = index; _yansiActive = false; });
    await _speak(_intro[index]);
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => LifeOZCoreHub(prefs: widget.prefs, coreIndex: index)));
    if (mounted) setState(() => _activeCore = null);
  }

  @override
  void dispose() {
    _motion.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01040B),
      body: AnimatedBuilder(
        animation: _motion,
        builder: (_, __) {
          final pulse = 1 + math.sin(_motion.value * math.pi * 2) * .018;
          return Stack(fit: StackFit.expand, children: [
            const _SpaceBackground(),
            _EnergyField(t: _motion.value),
            SafeArea(child: Stack(children: [
              Positioned(top: 10, left: 12, child: _glassButton(Icons.menu_rounded, () => setState(() => _menuOpen = !_menuOpen))),
              const Positioned(top: 16, left: 0, right: 0, child: IgnorePointer(child: Center(child: Text('L I F E O S', style: TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 5, fontWeight: FontWeight.w500))))),
              if (_menuOpen) Positioned(top: 48, left: 12, child: _controlPanel()),
              _yansiNode(pulse),
              _core(0, const Offset(.21, .34), const Color(0xFFFFB84D)),
              _core(1, const Offset(.79, .34), const Color(0xFF66FF9A)),
              _core(2, const Offset(.18, .66), const Color(0xFF38D9FF)),
              _core(3, const Offset(.82, .66), const Color(0xFFB86CFF)),
              _core(4, const Offset(.50, .82), const Color(0xFFFF6D94)),
              Positioned(left: 18, right: 18, bottom: 18, child: _ambientStatus()),
            ])),
          ]);
        },
      ),
    );
  }

  Widget _yansiNode(double pulse) => Positioned(
    left: MediaQuery.sizeOf(context).width / 2 - 104,
    top: MediaQuery.sizeOf(context).height * .37,
    width: 208, height: 208,
    child: GestureDetector(
      onTap: _tapYansi,
      child: Transform.scale(
        scale: (_yansiActive ? 1.06 : 1) * pulse,
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF00C8FF).withOpacity(_yansiActive ? .68 : .34), blurRadius: _yansiActive ? 72 : 48, spreadRadius: _yansiActive ? 10 : 2)]),
          child: ClipOval(child: Image.asset('03_Yansi_Silent_Intelligence.png', fit: BoxFit.cover)),
        ),
      ),
    ),
  );

  Widget _core(int index, Offset normalized, Color color) {
    final active = _activeCore == index;
    return Positioned(
      left: MediaQuery.sizeOf(context).width * normalized.dx - 43,
      top: MediaQuery.sizeOf(context).height * normalized.dy - 43,
      width: 86, height: 86,
      child: GestureDetector(
        onTap: () => _tapCore(index),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: active ? 1.13 : 1,
          child: Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(.30), border: Border.all(color: color.withOpacity(active ? .98 : .76), width: active ? 2.5 : 1.2), boxShadow: [BoxShadow(color: color.withOpacity(active ? .72 : .30), blurRadius: active ? 38 : 24, spreadRadius: active ? 7 : 1)]),
            child: Stack(alignment: Alignment.center, children: [
              Transform.rotate(angle: _motion.value * math.pi * 2 * (index.isEven ? 1 : -1), child: Icon(_coreIcon(index), color: color, size: active ? 34 : 30)),
              CustomPaint(painter: _CoreOrbitPainter(color, _motion.value)),
            ]),
          ),
        ),
      ),
    );
  }

  IconData _coreIcon(int i) => switch (i) {
    0 => Icons.account_balance_wallet_rounded,
    1 => Icons.track_changes_rounded,
    2 => Icons.bolt_rounded,
    3 => Icons.shopping_bag_rounded,
    _ => Icons.favorite_rounded,
  };

  Widget _glassButton(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.black.withOpacity(.42), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x4400E5FF))), child: Icon(icon, size: 20, color: const Color(0xFF70FFD0))),
  );

  Widget _controlPanel() => Container(
    width: 220, padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xF008121A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x6600E5FF)), boxShadow: const [BoxShadow(color: Color(0x4400E5FF), blurRadius: 26)]),
    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('LIFE CONTROL', style: TextStyle(color: Color(0xFF76FFFF), fontSize: 9, letterSpacing: 2)),
      SizedBox(height: 8),
      _PanelRow(Icons.auto_awesome, 'YANSI INTELLIGENCE'),
      _PanelRow(Icons.insights_rounded, 'LIFE REPORT'),
      _PanelRow(Icons.security_rounded, 'PRIVACY'),
      _PanelRow(Icons.settings_rounded, 'SETTINGS'),
    ]),
  );

  Widget _ambientStatus() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(color: const Color(0xC9061219), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x2200E5FF))),
    child: Row(children: [
      const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF55FF88)),
      const SizedBox(width: 8),
      Expanded(child: Text(_activeCore == null ? 'Yansi is quietly connecting your life systems.' : 'Yansi is opening your intelligence report.', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 9))),
      const SizedBox(width: 8),
      const Icon(Icons.circle, size: 6, color: Color(0xFF55FF88)),
    ]),
  );
}

class _PanelRow extends StatelessWidget {
  final IconData icon; final String text;
  const _PanelRow(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Icon(icon, size: 16, color: Color(0xFF55FF88)), const SizedBox(width: 10), Text(text, style: TextStyle(color: Colors.white70, fontSize: 8, letterSpacing: 1))]));
}

class _SpaceBackground extends StatelessWidget {
  const _SpaceBackground();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _SpacePainter());
}

class _SpacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF01040B));
    final grid = Paint()..color = const Color(0x1200E5FF)..strokeWidth = .35;
    for (double x = 0; x < size.width; x += 32) canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    for (double y = 0; y < size.height; y += 32) canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    final glow = Paint()..shader = const RadialGradient(colors: [Color(0x2400BFFF), Colors.transparent]).createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height * .48), radius: size.width * .72));
    canvas.drawCircle(Offset(size.width / 2, size.height * .48), size.width * .72, glow);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EnergyField extends StatelessWidget {
  final double t; const _EnergyField({required this.t});
  @override Widget build(BuildContext context) => IgnorePointer(child: CustomPaint(painter: _EnergyPainter(t)));
}

class _EnergyPainter extends CustomPainter {
  final double t; _EnergyPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * .51);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1;
    for (int i = 0; i < 5; i++) {
      paint.color = i.isEven ? const Color(0x4400E5FF) : const Color(0x3355FF88);
      final rx = size.width * (.22 + i * .085); final ry = size.height * (.10 + i * .026);
      canvas.save(); canvas.translate(c.dx, c.dy); canvas.rotate(t * math.pi * 2 * (i.isEven ? 1 : -.7));
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2), paint); canvas.restore();
    }
  }
  @override bool shouldRepaint(covariant _EnergyPainter oldDelegate) => true;
}

class _CoreOrbitPainter extends CustomPainter {
  final Color color; final double t; _CoreOrbitPainter(this.color, this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color.withOpacity(.55)..style = PaintingStyle.stroke..strokeWidth = .7;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.save(); canvas.translate(center.dx, center.dy); canvas.rotate(t * math.pi * 2);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: size.width * .72, height: size.height * .32), p); canvas.restore();
  }
  @override bool shouldRepaint(covariant _CoreOrbitPainter oldDelegate) => true;
}
