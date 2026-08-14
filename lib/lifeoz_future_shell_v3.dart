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
  late final AnimationController _controller;
  final FlutterTts _tts = FlutterTts();
  int active = -1;
  bool menu = false;
  String name = '';

  static const colors = <Color>[
    Color(0xFF20D9FF),
    Color(0xFFFFC45A),
    Color(0xFFB77BFF),
    Color(0xFF55F2B0),
    Color(0xFF6E9CFF),
  ];

  static const messages = <String>[
    'Opening financial intelligence.',
    'Opening goals and growth intelligence.',
    'Opening productivity intelligence.',
    'Opening time and calendar intelligence.',
    'Opening household intelligence.',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    name = widget.prefs.getString('user_name') ?? '';
    _tts.setSpeechRate(0.44);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01040A),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _BackgroundPainter(_controller.value)),
              _buildTopBar(),
              _buildUniverse(),
              if (menu) _buildMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 14,
      left: 18,
      right: 18,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors[0], width: 1.5),
              boxShadow: const [BoxShadow(color: Color(0x5520D9FF), blurRadius: 18)],
            ),
            child: const Icon(Icons.all_inclusive, color: Color(0xFF20D9FF)),
          ),
          const SizedBox(width: 9),
          const Text(
            'LifeOZ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.8,
            ),
          ),
          const Spacer(),
          _roundButton(Icons.hub_rounded, () => setState(() => menu = true)),
        ],
      ),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: .035),
          border: Border.all(color: colors[0].withValues(alpha: .55)),
          boxShadow: [BoxShadow(color: colors[0].withValues(alpha: .18), blurRadius: 18)],
        ),
        child: Icon(icon, color: colors[0]),
      ),
    );
  }

  Widget _buildUniverse() {
    return Positioned.fill(
      top: 60,
      child: LayoutBuilder(
        builder: (_, c) {
          final center = Offset(c.maxWidth / 2, c.maxHeight * .43);
          final points = <Offset>[
            Offset(c.maxWidth * .18, c.maxHeight * .22),
            Offset(c.maxWidth * .82, c.maxHeight * .22),
            Offset(c.maxWidth * .12, c.maxHeight * .65),
            Offset(c.maxWidth * .88, c.maxHeight * .65),
            Offset(c.maxWidth * .50, c.maxHeight * .06),
          ];
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _NetworkPainter(_controller.value, active, points, center),
                ),
              ),
              for (var i = 0; i < 5; i++)
                Positioned(
                  left: points[i].dx - 48,
                  top: points[i].dy - 48,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => active = i);
                      speak(messages[i]);
                    },
                    child: CustomPaint(
                      size: const Size(96, 96),
                      painter: _CorePainter(i, colors[i], active == i, _controller.value),
                    ),
                  ),
                ),
              Positioned(
                left: center.dx - 130,
                top: center.dy - 130,
                child: GestureDetector(
                  onTap: () => speak(name.isEmpty
                      ? 'I am Yansi, your LifeOS intelligence.'
                      : 'Welcome back, $name. I am Yansi, your LifeOS intelligence.'),
                  child: CustomPaint(
                    size: const Size(260, 260),
                    painter: _OrbPainter(_controller.value, active < 0 ? colors[0] : colors[active]),
                  ),
                ),
              ),
              Positioned(
                left: 22,
                right: 22,
                bottom: 26,
                child: Text(
                  active < 0 ? 'ONE SCREEN  •  ONE TAP  •  ONE REPORT' : messages[active],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: active < 0 ? colors[0] : colors[active], fontSize: 11, letterSpacing: 1.1),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenu() {
    final items = <MapEntry<String, IconData>>[
      const MapEntry('PROFILE', Icons.person_outline),
      const MapEntry('DESIGN', Icons.auto_awesome),
      const MapEntry('PERMISSIONS', Icons.shield_outlined),
      const MapEntry('YANSI', Icons.psychology_outlined),
      const MapEntry('SETTINGS', Icons.tune),
    ];
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => menu = false),
        child: Container(
          color: Colors.black.withValues(alpha: .90),
          alignment: Alignment.center,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 18,
            runSpacing: 18,
            children: [
              for (final item in items)
                GestureDetector(
                  onTap: () => speak('${item.key} control is ready.'),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _roundButton(item.value, () => speak('${item.key} control is ready.')),
                      const SizedBox(height: 5),
                      Text(item.key, style: const TextStyle(color: Colors.white70, fontSize: 9)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double phase;
  _BackgroundPainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()..shader = const RadialGradient(
        colors: [Color(0xFF09233B), Color(0xFF01040A)],
        radius: 1.05,
      ).createShader(rect),
    );
    final random = math.Random(19);
    for (var i = 0; i < 90; i++) {
      final a = (.06 + .04 * math.sin(phase * math.pi * 2 + i)).clamp(.01, .12);
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        .5 + random.nextDouble() * 1.2,
        Paint()..color = (i.isEven ? const Color(0xFF20D9FF) : const Color(0xFFFFC45A)).withValues(alpha: a),
      );
    }
    final center = Offset(size.width / 2, size.height * .43);
    for (var i = 0; i < 6; i++) {
      canvas.drawOval(
        Rect.fromCenter(center: center, width: 230 + i * 85.0, height: 110 + i * 52.0),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .7
          ..color = const Color(0xFF20D9FF).withValues(alpha: .045),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => true;
}

class _NetworkPainter extends CustomPainter {
  final double phase;
  final int active;
  final List<Offset> points;
  final Offset center;
  _NetworkPainter(this.phase, this.active, this.points, this.center);

  static const colors = <Color>[
    Color(0xFF20D9FF), Color(0xFFFFC45A), Color(0xFFB77BFF),
    Color(0xFF55F2B0), Color(0xFF6E9CFF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < points.length; i++) {
      final path = Path()
        ..moveTo(points[i].dx, points[i].dy)
        ..cubicTo(points[i].dx, points[i].dy + (center.dy - points[i].dy) * .25,
            center.dx, center.dy - (center.dy - points[i].dy) * .25, center.dx, center.dy);
      canvas.drawPath(path, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = active == i ? 3 : 1
        ..color = colors[i].withValues(alpha: active == i ? .68 : .22));
      final metrics = path.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final metric = metrics.first;
        final tangent = metric.getTangentForOffset(metric.length * ((phase + i * .18) % 1));
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 3, Paint()..color = colors[i].withValues(alpha: .9));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NetworkPainter oldDelegate) => true;
}

class _OrbPainter extends CustomPainter {
  final double phase;
  final Color color;
  _OrbPainter(this.phase, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (var i = 0; i < 7; i++) {
      final r = size.shortestSide * (.22 + i * .055);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(phase * math.pi * 2 + i * .45);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 1.35), Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = i == 2 ? 2 : .8
        ..color = (i.isEven ? const Color(0xFF20D9FF) : const Color(0xFFFFC45A)).withValues(alpha: .22));
      canvas.restore();
    }
    final r = size.shortestSide * .17;
    canvas.drawCircle(center, r, Paint()..shader = RadialGradient(colors: [Colors.white, color, color.withValues(alpha: 0)]).createShader(Rect.fromCircle(center: center, radius: r)));
    canvas.drawCircle(center, r * .3, Paint()..color = Colors.white..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) => true;
}

class _CorePainter extends CustomPainter {
  final int index;
  final Color color;
  final bool active;
  final double phase;
  _CorePainter(this.index, this.color, this.active, this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide * .31;
    canvas.drawCircle(center, r, Paint()
      ..color = color.withValues(alpha: active ? .28 : .10)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, active ? 20 : 10));
    canvas.drawCircle(center, r, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 2.5 : 1
      ..color = color.withValues(alpha: active ? .95 : .55));
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(phase * math.pi * 2 + index * .7);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 1.45, height: r * .58), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color.withValues(alpha: .72));
    canvas.restore();

    final p = Path();
    switch (index) {
      case 0:
        p.moveTo(center.dx - 13, center.dy + 8); p.lineTo(center.dx - 13, center.dy - 2); p.lineTo(center.dx - 3, center.dy + 3); p.lineTo(center.dx + 7, center.dy - 10); p.lineTo(center.dx + 14, center.dy - 5); break;
      case 1:
        p.moveTo(center.dx, center.dy + 14); p.lineTo(center.dx, center.dy - 13); p.moveTo(center.dx - 10, center.dy - 3); p.lineTo(center.dx, center.dy - 13); p.lineTo(center.dx + 10, center.dy - 3); break;
      case 2:
        p.addRect(Rect.fromCenter(center: center, width: 26, height: 22)); p.moveTo(center.dx - 7, center.dy); p.lineTo(center.dx + 7, center.dy); break;
      case 3:
        p.addOval(Rect.fromCircle(center: center, radius: 12)); p.moveTo(center.dx, center.dy - 12); p.lineTo(center.dx, center.dy); p.lineTo(center.dx + 8, center.dy + 5); break;
      default:
        p.moveTo(center.dx - 13, center.dy - 3); p.lineTo(center.dx - 4, center.dy + 6); p.lineTo(center.dx + 14, center.dy - 12); p.moveTo(center.dx - 12, center.dy + 12); p.lineTo(center.dx + 12, center.dy + 12);
    }
    canvas.drawPath(p, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.4..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant _CorePainter oldDelegate) => true;
}
