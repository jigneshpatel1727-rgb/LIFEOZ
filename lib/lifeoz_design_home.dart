import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lifeoz_core_hub.dart';

class LifeOZDesignHome extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZDesignHome({super.key, required this.prefs});

  @override
  State<LifeOZDesignHome> createState() => _LifeOZDesignHomeState();
}

class _LifeOZDesignHomeState extends State<LifeOZDesignHome>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late final AnimationController _motion;
  late Future<Uint8List> _masterArtwork;

  int _design = 0;
  int? _activeCore;
  bool _yansiActive = false;

  static const realities = [
    ('01_Oreon_Prime.png', 'OREON PRIME'),
    ('02_Terra_Flux.png', 'TERRA FLUX'),
    ('03_Vortex_Nexus.png', 'VORTEX NEXUS'),
    ('04_Crysta_Lumen.png', 'CRYSTA LUMEN'),
    ('09_Nebula_Soul-1.png', 'NEBULA SOUL'),
    ('10_Shadow_Core-1.png', 'SHADOW CORE'),
  ];

  static const coreNames = [
    'Financial Intelligence',
    'Goals & Growth',
    'Productivity',
    'Household Management',
    'Personal Life & Wellness',
  ];

  static const coreIntro = [
    'This is Financial Intelligence. I organise your expenses, spending patterns, budgets and money insights.',
    'This is Goals and Growth. I help you define goals, track progress and keep you moving toward completion.',
    'This is Productivity. I organise your work and daily tasks, carry pending work forward and help you finish them.',
    'This is Household Management. I organise shopping, home requirements and recurring household needs.',
    'This is Personal Life and Wellness. I organise personal records, diary information and life routines.',
  ];

  @override
  void initState() {
    super.initState();
    _design = (widget.prefs.getInt('lifeos_visual_design') ?? 0).clamp(0, 5);
    _tts.setSpeechRate(0.44);
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _masterArtwork = _loadMasterArtwork();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) => _welcomeYansi());
  }

  Future<Uint8List> _loadMasterArtwork() async {
    final raw = await rootBundle.loadString('assets/home_master_b64.txt');
    return base64Decode(raw.replaceAll(RegExp(r'\s+'), ''));
  }

  @override
  void dispose() {
    _motion.dispose();
    _tts.stop();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _welcomeYansi() async {
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    await _speak('Welcome to LifeOS. I am Yansi, your personal AI. I am here whenever you need me.');
  }

  Future<void> _yansi() async {
    setState(() {
      _yansiActive = true;
      _activeCore = null;
    });
    await _speak('I am Yansi, your LifeOS intelligence. Tap any living core and I will introduce it, then open its real report and controls.');
    if (mounted) setState(() => _yansiActive = false);
  }

  Future<void> _core(int index) async {
    setState(() {
      _activeCore = index;
      _yansiActive = false;
    });
    await _speak(coreIntro[index]);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LifeOZCoreHub(
          prefs: widget.prefs,
          coreIndex: index,
        ),
      ),
    );
    if (mounted) setState(() => _activeCore = null);
  }

  Future<void> _designs() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF020711),
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.92,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 18, 18, 10),
                child: Text(
                  'SIX REALITIES — TAP TO TRANSFORM LIFEOS',
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.8,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Text(
                'These are live visual engines, not wallpaper screens.',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(14),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.67,
                  ),
                  itemCount: realities.length,
                  itemBuilder: (_, i) {
                    final selected = _design == i;
                    return GestureDetector(
                      onTap: () async {
                        await widget.prefs.setInt('lifeos_visual_design', i);
                        if (!mounted) return;
                        setState(() => _design = i);
                        Navigator.of(sheetContext).pop();
                        await _speak('${realities[i].$2} reality activated.');
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected ? const Color(0xFFFFC15A) : Colors.white24,
                            width: selected ? 2.5 : 1,
                          ),
                          boxShadow: selected
                              ? const [
                                  BoxShadow(
                                    color: Color(0x66FFB52E),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(realities[i].$1, fit: BoxFit.cover),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.78),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 12,
                              right: 12,
                              bottom: 12,
                              child: Text(
                                realities[i].$2,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ),
                            if (selected)
                              const Positioned(
                                top: 10,
                                right: 10,
                                child: Icon(Icons.check_circle, color: Color(0xFFFFC15A)),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
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
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: const Color(0xFF01040B),
      body: AnimatedBuilder(
        animation: _motion,
        builder: (_, __) {
          final pulse = 1 + math.sin(_motion.value * math.pi * 2) * 0.018;
          return Stack(
            fit: StackFit.expand,
            children: [
              _realityArtwork(pulse),
              _livingConstellation(pulse),
              SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      top: 12,
                      left: 16,
                      child: Row(
                        children: [
                          Image.asset('01_LifeOZ_App_Icon.png', width: 46, height: 46),
                          const SizedBox(width: 10),
                          const Text(
                            'LIFEOZ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              letterSpacing: 7,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 16,
                      child: _actionButton(Icons.auto_awesome, _designs),
                    ),
                    Positioned(
                      top: 70,
                      left: 18,
                      child: AnimatedOpacity(
                        opacity: _design == 0 ? 0.9 : 0.72,
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          realities[_design].$2,
                          style: const TextStyle(
                            color: Colors.white70,
                            letterSpacing: 2.4,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    _yansiNode(size),
                    _coreHotspot(0, const Offset(0.22, 0.34), const Color(0xFFFFB84D)),
                    _coreHotspot(1, const Offset(0.78, 0.34), const Color(0xFF66FF9A)),
                    _coreHotspot(2, const Offset(0.19, 0.66), const Color(0xFF38D9FF)),
                    _coreHotspot(3, const Offset(0.81, 0.66), const Color(0xFFB86CFF)),
                    _coreHotspot(4, const Offset(0.50, 0.82), const Color(0xFFFF6D94)),
                    Positioned(
                      bottom: 22,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            _activeCore == null
                                ? 'ONE TAP  •  ONE SCREEN  •  ONE REPORT'
                                : coreNames[_activeCore!],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.8,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 7),
                          const Text(
                            'LIVING INTELLIGENCE',
                            style: TextStyle(
                              color: Colors.white54,
                              letterSpacing: 4.5,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _realityArtwork(double pulse) {
    return FutureBuilder<Uint8List>(
      future: _masterArtwork,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const ColoredBox(color: Color(0xFF01040B));
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 900),
              child: Transform.scale(
                key: ValueKey(_design),
                scale: pulse,
                child: Image.asset(
                  realities[_design].$1,
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.56),
                ),
              ),
            ),
            Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              opacity: AlwaysStoppedAnimation(_design == 0 ? 0.82 : 0.24),
            ),
            Container(color: const Color(0x6601030A)),
          ],
        );
      },
    );
  }

  Widget _livingConstellation(double pulse) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _LivingEnergyPainter(
          t: _motion.value,
          design: _design,
          pulse: pulse,
        ),
      ),
    );
  }

  Widget _yansiNode(Size size) {
    return Positioned(
      left: size.width / 2 - 104,
      top: size.height * 0.39,
      width: 208,
      height: 208,
      child: GestureDetector(
        onTap: _yansi,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 450),
          scale: _yansiActive ? 1.08 : 1,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00BFFF).withOpacity(_yansiActive ? 0.65 : 0.34),
                  blurRadius: _yansiActive ? 70 : 46,
                  spreadRadius: _yansiActive ? 10 : 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                '03_Yansi_Silent_Intelligence.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _coreHotspot(int index, Offset normalized, Color color) {
    final active = _activeCore == index;
    return Positioned(
      left: MediaQuery.sizeOf(context).width * normalized.dx - 46,
      top: MediaQuery.sizeOf(context).height * normalized.dy - 46,
      width: 92,
      height: 92,
      child: GestureDetector(
        onTap: () => _core(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.26),
            border: Border.all(
              color: color.withOpacity(active ? 0.95 : 0.72),
              width: active ? 2.8 : 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(active ? 0.65 : 0.28),
                blurRadius: active ? 38 : 24,
                spreadRadius: active ? 7 : 1,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: _motion.value * math.pi * 2,
                child: Icon(
                  _coreIcon(index),
                  color: color,
                  size: active ? 34 : 30,
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _CoreEnergyPainter(color, _motion.value),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _coreIcon(int i) => switch (i) {
        0 => Icons.account_balance_wallet_rounded,
        1 => Icons.track_changes_rounded,
        2 => Icons.bolt_rounded,
        3 => Icons.home_work_rounded,
        _ => Icons.favorite_rounded,
      };

  Widget _actionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black.withOpacity(0.5),
          border: Border.all(color: const Color(0xFFFFB74D), width: 1.5),
          boxShadow: const [
            BoxShadow(color: Color(0x55FFB74D), blurRadius: 18),
          ],
        ),
        child: Icon(icon, color: const Color(0xFFFFC15A), size: 25),
      ),
    );
  }
}

class _LivingEnergyPainter extends CustomPainter {
  final double t;
  final int design;
  final double pulse;
  _LivingEnergyPainter({required this.t, required this.design, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.49);
    final colors = <Color>[
      const Color(0xFFFFB84D),
      const Color(0xFF66FF9A),
      const Color(0xFF38D9FF),
      const Color(0xFFB86CFF),
      const Color(0xFFFF6D94),
    ];
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * math.pi * 2 / 5;
      final p = Offset(
        center.dx + math.cos(a) * size.width * 0.28,
        center.dy + math.sin(a) * size.height * 0.25,
      );
      final path = Path()..moveTo(center.dx, center.dy);
      path.cubicTo(
        center.dx + math.cos(a + 0.5) * size.width * 0.12,
        center.dy + math.sin(a + 0.5) * size.height * 0.09,
        p.dx - math.cos(a) * 30,
        p.dy - math.sin(a) * 30,
        p.dx,
        p.dy,
      );
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = colors[i].withOpacity(0.22);
      canvas.drawPath(path, paint);
      final dot = Paint()..color = colors[i].withOpacity(0.8);
      final moving = Offset.lerp(Offset(center.dx, center.dy), p, (t * 1.2 + i * .2) % 1)!;
      canvas.drawCircle(moving, 2.2 * pulse, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _LivingEnergyPainter oldDelegate) => true;
}

class _CoreEnergyPainter extends CustomPainter {
  final Color color;
  final double t;
  _CoreEnergyPainter(this.color, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = color.withOpacity(0.35);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(t * math.pi * 2);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 68, height: 25), p);
    canvas.rotate(math.pi / 2);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 68, height: 25), p);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CoreEnergyPainter oldDelegate) => true;
}
