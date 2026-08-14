import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LifeOZFutureShell extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZFutureShell({super.key, required this.prefs});

  @override
  State<LifeOZFutureShell> createState() => _LifeOZFutureShellState();
}

class _LifeOZFutureShellState extends State<LifeOZFutureShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  final FlutterTts _tts = FlutterTts();
  int _active = -1;
  bool _hologram = false;
  String _name = '';

  final List<Color> coreColors = const [
    Color(0xFF20D9FF),
    Color(0xFFFFC45A),
    Color(0xFFB77BFF),
    Color(0xFF55F2B0),
    Color(0xFF6E9CFF),
  ];

  final List<String> coreMessages = const [
    'I am opening your financial intelligence.',
    'I am opening your goals and growth intelligence.',
    'I am opening your productivity intelligence.',
    'I am opening your time and calendar intelligence.',
    'I am opening your home and household intelligence.',
  ];

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _name = widget.prefs.getString('user_name') ?? '';
    _tts.setSpeechRate(0.44);
  }

  @override
  void dispose() {
    _animation.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  void _selectCore(int index) {
    setState(() => _active = index);
    _speak(coreMessages[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01040A),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: _CosmicPainter(_animation.value)),
                _topBar(),
                _mainUniverse(),
                if (_hologram) _holographicControl(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _topBar() {
    return Positioned(
      top: 14,
      left: 18,
      right: 18,
      child: Row(
        children: [
          const _LifeOZLogo(),
          const Spacer(),
          _roundButton(Icons.hub_rounded, () {
            setState(() => _hologram = true);
          }),
        ],
      ),
    );
  }

  Widget _mainUniverse() {
    return Positioned.fill(
      top: 60,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final center = Offset(width / 2, height * 0.45);
          final points = <Offset>[
            Offset(width * 0.20, height * 0.23),
            Offset(width * 0.80, height * 0.23),
            Offset(width * 0.13, height * 0.66),
            Offset(width * 0.87, height * 0.66),
            Offset(width * 0.50, height * 0.06),
          ];

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _NetworkPainter(
                    animation: _animation.value,
                    active: _active,
                    points: points,
                    center: center,
                    colors: coreColors,
                  ),
                ),
              ),
              ...List.generate(5, (index) {
                return Positioned(
                  left: points[index].dx - 48,
                  top: points[index].dy - 48,
                  child: GestureDetector(
                    onTap: () => _selectCore(index),
                    child: CustomPaint(
                      size: const Size(96, 96),
                      painter: _CoreSymbolPainter(
                        index: index,
                        color: coreColors[index],
                        active: _active == index,
                        phase: _animation.value,
                      ),
                    ),
                  ),
                );
              }),
              Positioned(
                left: center.dx - 130,
                top: center.dy - 130,
                child: GestureDetector(
                  onTap: () => _speak(
                    _name.isEmpty
                        ? 'I am Yansi, your LifeOS intelligence.'
                        : 'Welcome back, $_name. I am Yansi, your LifeOS intelligence.',
                  ),
                  child: CustomPaint(
                    size: const Size(260, 260),
                    painter: _YansiPainter(
                      phase: _animation.value,
                      color: _active >= 0
                          ? coreColors[_active]
                          : coreColors[0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 32,
                child: Column(
                  children: [
                    const Text(
                      'YANSI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _active >= 0 ? coreMessages[_active] : 'YOUR SILENT INTELLIGENCE',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _active >= 0 ? coreColors[_active] : coreColors[0],
                        fontSize: 11,
                        letterSpacing: 1.1,
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

  Widget _roundButton(IconData icon, VoidCallback action) {
    return GestureDetector(
      onTap: action,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.035),
          border: Border.all(color: coreColors[0].withOpacity(0.55)),
          boxShadow: [
            BoxShadow(color: coreColors[0].withOpacity(0.18), blurRadius: 18),
          ],
        ),
        child: Icon(icon, color: coreColors[0]),
      ),
    );
  }

  Widget _holographicControl() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _hologram = false),
        child: Container(
          color: Colors.black.withOpacity(0.90),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'HOLOGRAPHIC CONTROL',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(height: 28),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 18,
                  runSpacing: 18,
                  children: [
                    _holoItem('PROFILE', Icons.person_outline),
                    _holoItem('DESIGN', Icons.auto_awesome),
                    _holoItem('PERMISSIONS', Icons.shield_outlined),
                    _holoItem('YANSI', Icons.psychology_outlined),
                    _holoItem('SETTINGS', Icons.tune),
                  ],
                ),
                const SizedBox(height: 26),
                const Text(
                  'Tap anywhere to return',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _holoItem(String label, IconData icon) {
    return GestureDetector(
      onTap: () => _speak('$label control is ready.'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _roundButton(icon, () => _speak('$label control is ready.')),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9)),
        ],
      ),
    );
  }
}

class _LifeOZLogo extends StatelessWidget {
  const _LifeOZLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF20D9FF), width: 1.5),
            boxShadow: const [BoxShadow(color: Color(0x5520D9FF), blurRadius: 18)],
          ),
          child: const Icon(Icons.all_inclusive, color: Color(0xFF20D9FF)),
        ),
        const SizedBox(width: 9),
        const Text(
          'LifeOZ',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.8,
            fontSize: 17,
          ),
        ),
      ],
    );
  }
}

class _CosmicPainter extends CustomPainter {
  final double phase;
  _CosmicPainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF09233B), Color(0xFF01040A)],
          radius: 1.05,
        ).createShader(rect),
    );

    final random = math.Random(19);
    for (var i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final twinkle = 0.06 + 0.04 * math.sin(phase * math.pi * 2 + i);
      canvas.drawCircle(
        Offset(x, y),
        0.5 + random.nextDouble() * 1.3,
        Paint()..color = (i.isEven ? const Color(0xFF20D9FF) : const Color(0xFFFFC45A)).withOpacity(twinkle),
      );
    }

    final center = Offset(size.width / 2, size.height * 0.45);
    for (var i = 0; i < 7; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: 210 + i * 88.0,
          height: 100 + i * 55.0,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7
          ..color = const Color(0xFF20D9FF).withOpacity(0.045),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CosmicPainter oldDelegate) => true;
}

class _NetworkPainter extends CustomPainter {
  final double animation;
  final int active;
  final List<Offset> points;
  final Offset center;
  final List<Color> colors;

  _NetworkPainter({
    required this.animation,
    required this.active,
    required this.points,
    required this.center,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < points.length; i++) {
      final color = colors[i];
      final path = Path()
        ..moveTo(points[i].dx, points[i].dy)
        ..cubicTo(
          points[i].dx,
          points[i].dy + (center.dy - points[i].dy) * 0.25,
          center.dx,
          center.dy - (center.dy - points[i].dy) * 0.25,
          center.dx,
          center.dy,
        );

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = active == i ? 3.0 : 1.0
          ..color = color.withOpacity(active == i ? 0.68 : 0.22),
      );

      final t = (animation + i * 0.18) % 1.0;
      final particle = PathMetrics(path.computeMetrics()).isEmpty
          ? center
          : _pointOnPath(path, t);
      canvas.drawCircle(particle, 3.0, Paint()..color = color.withOpacity(0.9));
    }
  }

  Offset _pointOnPath(Path path, double t) {
    final metric = path.computeMetrics().first;
    final tangent = metric.getTangentForOffset(metric.length * t);
    return tangent?.position ?? center;
  }

  @override
  bool shouldRepaint(covariant _NetworkPainter oldDelegate) => true;
}

class _YansiPainter extends CustomPainter {
  final double phase;
  final Color color;
  _YansiPainter({required this.phase, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.17;

    for (var i = 0; i < 7; i++) {
      final r = size.shortestSide * (0.22 + i * 0.055);
      final rotation = phase * math.pi * 2 + i * 0.45;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 1.35),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == 2 ? 2.0 : 0.8
          ..color = (i.isEven ? const Color(0xFF20D9FF) : const Color(0xFFFFC45A)).withOpacity(0.22),
      );
      canvas.restore();
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white, color, color.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(
      center,
      radius * 0.30,
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  @override
  bool shouldRepaint(covariant _YansiPainter oldDelegate) => true;
}

class _CoreSymbolPainter extends CustomPainter {
  final int index;
  final Color color;
  final bool active;
  final double phase;

  _CoreSymbolPainter({
    required this.index,
    required this.color,
    required this.active,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide * 0.31;

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = color.withOpacity(active ? 0.28 : 0.10)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, active ? 20 : 10),
    );

    canvas.drawOval(
      Rect.fromCenter(center: center, width: r * 2.7, height: r * 2.05),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = active ? 2.2 : 1.0
        ..color = color.withOpacity(active ? 0.78 : 0.30),
    );

    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = color;
    final path = Path();

    if (index == 0) {
      path.moveTo(center.dx, center.dy + r * 0.85);
      path.cubicTo(center.dx - r * 0.8, center.dy, center.dx - r * 0.55, center.dy - r * 0.7, center.dx, center.dy - r * 0.8);
      path.cubicTo(center.dx + r * 0.55, center.dy - r * 0.7, center.dx + r * 0.8, center.dy, center.dx, center.dy + r * 0.85);
    } else if (index == 1) {
      path.moveTo(center.dx, center.dy + r * 0.85);
      path.cubicTo(center.dx - r, center.dy, center.dx - r * 0.7, center.dy - r * 0.8, center.dx, center.dy - r * 0.25);
      path.cubicTo(center.dx + r * 0.7, center.dy - r * 0.8, center.dx + r, center.dy, center.dx, center.dy + r * 0.85);
    } else if (index == 2) {
      for (var n = 0; n < 70; n++) {
        final t = n / 69;
        final angle = t * math.pi * 5.0 + phase * math.pi * 2;
        final rr = r * (1.0 - t);
        final point = Offset(center.dx + math.cos(angle) * rr, center.dy + math.sin(angle) * rr);
        if (n == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
    } else if (index == 3) {
      canvas.drawCircle(center, r * 0.62, pen);
      canvas.drawOval(Rect.fromCenter(center: center, width: r * 2.0, height: r * 0.65), pen);
      return;
    } else {
      path.moveTo(center.dx, center.dy - r);
      path.lineTo(center.dx + r * 0.60, center.dy - r * 0.25);
      path.lineTo(center.dx + r * 0.42, center.dy + r * 0.82);
      path.lineTo(center.dx, center.dy + r);
      path.lineTo(center.dx - r * 0.42, center.dy + r * 0.82);
      path.lineTo(center.dx - r * 0.60, center.dy - r * 0.25);
      path.close();
    }

    canvas.drawPath(path, pen);
    canvas.drawCircle(
      center,
      r * 0.11,
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(covariant _CoreSymbolPainter oldDelegate) => true;
}
