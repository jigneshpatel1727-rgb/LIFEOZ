import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LifeOZReferenceHome extends StatefulWidget {
  final SharedPreferences prefs;

  const LifeOZReferenceHome({super.key, required this.prefs});

  @override
  State<LifeOZReferenceHome> createState() => _LifeOZReferenceHomeState();
}

class _LifeOZReferenceHomeState extends State<LifeOZReferenceHome> {
  final FlutterTts _tts = FlutterTts();
  String _name = '';

  static const colors = <Color>[
    Color(0xFF55D98A),
    Color(0xFFFFB447),
    Color(0xFFD76BFF),
    Color(0xFF39D7FF),
    Color(0xFFB66CFF),
  ];

  static const titles = <String>[
    'Life & Growth',
    'Guardian & Care',
    'Prosperity',
    'Time & Commitments',
    'Personal Intelligence',
  ];

  SharedPreferences get prefs => widget.prefs;

  @override
  void initState() {
    super.initState();
    _name = prefs.getString('user_name') ?? '';
    _tts.setSpeechRate(0.44);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> profile() async {
    final controller = TextEditingController(text: _name);
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF07101B),
        title: const Text('PROFILE'),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
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
      await prefs.setString('user_name', value);
      if (mounted) {
        setState(() => _name = value);
      }
    }
  }

  void core(int index) {
    const messages = <String>[
      'Life, growth, goals and daily progress.',
      'Household, care and protection commitments.',
      'Expenses, savings, investments and money intelligence.',
      'Calendar, bills, renewals and time-sensitive commitments.',
      'Diary, personal goals, reflection and connected LifeOS context.',
    ];

    final message = messages[index];
    speak('${titles[index]}. $message');

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF050C16),
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titles[index], style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 18),
            const Text(
              'ONE SCREEN • ONE TAP • ONE REPORT',
              style: TextStyle(
                letterSpacing: 2,
                fontSize: 11,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int nearest(double angle) {
    const points = <double>[-math.pi / 2, 0, math.pi / 2, math.pi, 2.5];
    var best = 0;
    var bestDistance = double.infinity;

    for (var i = 0; i < points.length; i++) {
      var distance = (angle - points[i]).abs();
      if (distance > math.pi) {
        distance = 2 * math.pi - distance;
      }
      if (distance < bestDistance) {
        bestDistance = distance;
        best = i;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF010207),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: SpacePainter()),
            ),
            Positioned(
              top: 18,
              left: 24,
              right: 24,
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFC067),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.all_inclusive_rounded,
                      color: Color(0xFFFFC067),
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'LIFEOZ',
                    style: TextStyle(
                      fontSize: 28,
                      letterSpacing: 5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: profile,
                    icon: const Icon(Icons.tune_rounded),
                    color: const Color(0xFFFFC067),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 100,
              bottom: 55,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTapUp: (details) {
                  final center = Offset(size.width / 2, size.height * 0.43);
                  final dx = details.localPosition.dx - center.dx;
                  final dy = details.localPosition.dy - center.dy;
                  final distance = math.sqrt(dx * dx + dy * dy);

                  if (distance < 125) {
                    speak(
                      _name.isEmpty ? 'I am here.' : 'I am here, $_name.',
                    );
                  } else if (distance < 300) {
                    core(nearest(math.atan2(dy, dx)));
                  }
                },
                child: const CustomPaint(
                  painter: ConstellationPainter(),
                  child: SizedBox.expand(),
                ),
              ),
            ),
            Positioned(
              bottom: 22,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  _name.isEmpty
                      ? 'LIVING INTELLIGENCE'
                      : 'LIVING INTELLIGENCE • $_name',
                  style: const TextStyle(
                    letterSpacing: 4,
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpacePainter extends CustomPainter {
  const SpacePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.3);
    final random = math.Random(17);

    for (var i = 0; i < 100; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SpacePainter oldDelegate) => false;
}

class ConstellationPainter extends CustomPainter {
  const ConstellationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.43);
    final radius = math.min(size.width * 0.29, 170.0);
    final points = <Offset>[
      Offset(center.dx, center.dy - radius * 1.45),
      Offset(center.dx + radius * 1.28, center.dy - radius * 0.3),
      Offset(center.dx + radius * 0.92, center.dy + radius * 1.25),
      Offset(center.dx - radius * 0.92, center.dy + radius * 1.25),
      Offset(center.dx - radius * 1.28, center.dy - radius * 0.3),
    ];

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF4F7185).withValues(alpha: 0.45);

    for (final point in points) {
      canvas.drawLine(center, point, line);
    }

    final orbit = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF6F91A4).withValues(alpha: 0.2);

    canvas.drawOval(
      Rect.fromLTRB(
        center.dx - radius * 1.6,
        center.dy - radius * 0.65,
        center.dx + radius * 1.6,
        center.dy + radius * 0.65,
      ),
      orbit,
    );
    canvas.drawOval(
      Rect.fromLTRB(
        center.dx - radius * 1.35,
        center.dy - radius * 0.45,
        center.dx + radius * 1.35,
        center.dy + radius * 0.45,
      ),
      orbit,
    );

    drawYansi(canvas, center, 92);
    for (var i = 0; i < 5; i++) {
      drawCore(canvas, points[i], i, 42);
    }
  }

  void drawYansi(Canvas canvas, Offset center, double radius) {
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF56E5FF).withValues(alpha: 0.85),
          const Color(0xFF4D72FF).withValues(alpha: 0.4),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius * 1.45),
      );

    canvas.drawCircle(center, radius * 1.45, glow);

    final fill = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF69F2FF),
          Color(0xFF4B9EFF),
          Color(0xFF7C55D9),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, fill);

    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFBDEBFF);

    for (var i = 0; i < 3; i++) {
      final height = radius * (0.35 + i * 0.2);
      canvas.drawOval(
        Rect.fromLTRB(
          center.dx - radius * 0.85,
          center.dy - height / 2,
          center.dx + radius * 0.85,
          center.dy + height / 2,
        ),
        edge,
      );
    }
  }

  void drawCore(Canvas canvas, Offset center, int index, double radius) {
    final color = _LifeOZReferenceHomeState.colors[index];

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.75),
          color.withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius * 1.5),
      );

    canvas.drawCircle(center, radius * 1.5, glow);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color;

    canvas.drawOval(
      Rect.fromLTRB(
        center.dx - radius,
        center.dy - radius * 0.32,
        center.dx + radius,
        center.dy + radius * 0.32,
      ),
      ring,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(index * 0.42);
    canvas.drawOval(
      Rect.fromLTRB(-radius, -radius * 0.32, radius, radius * 0.32),
      ring,
    );
    canvas.restore();

    final icon = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = color;
    final path = Path();

    if (index == 0 || index == 1) {
      path
        ..moveTo(center.dx, center.dy + radius * 0.55)
        ..cubicTo(
          center.dx - radius * 0.7,
          center.dy,
          center.dx - radius * 0.4,
          center.dy - radius * 0.8,
          center.dx,
          center.dy - radius * 0.25,
        )
        ..cubicTo(
          center.dx + radius * 0.4,
          center.dy - radius * 0.8,
          center.dx + radius * 0.7,
          center.dy,
          center.dx,
          center.dy + radius * 0.55,
        );
      canvas.drawPath(path, icon);
    } else if (index == 2) {
      for (var k = 0; k < 24; k++) {
        final angle = k / 23 * math.pi * 3;
        final currentRadius = radius * 0.6 * (1 - k / 30);
        final point = Offset(
          center.dx + math.cos(angle) * currentRadius,
          center.dy + math.sin(angle) * currentRadius,
        );
        if (k == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, icon);
    } else if (index == 3) {
      canvas.drawCircle(center, radius * 0.48, icon);
      canvas.drawLine(
        center,
        Offset(center.dx, center.dy - radius * 0.3),
        icon,
      );
      canvas.drawLine(
        center,
        Offset(center.dx + radius * 0.24, center.dy + radius * 0.18),
        icon,
      );
    } else {
      path
        ..moveTo(center.dx, center.dy - radius * 0.65)
        ..lineTo(center.dx + radius * 0.48, center.dy)
        ..lineTo(center.dx, center.dy + radius * 0.65)
        ..lineTo(center.dx - radius * 0.48, center.dy)
        ..close();
      canvas.drawPath(path, icon);
    }

    canvas.drawCircle(center, 3.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant ConstellationPainter oldDelegate) => false;
}
