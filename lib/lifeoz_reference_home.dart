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

class _LifeOZReferenceHomeState extends State<LifeOZReferenceHome> with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
  final FlutterTts _tts = FlutterTts();
  String _name = '';
  static const coreColors = [Color(0xFF55D98A), Color(0xFFFFB447), Color(0xFFD76BFF), Color(0xFF39D7FF), Color(0xFFB66CFF)];
  static const coreTitles = ['Life & Growth', 'Guardian & Care', 'Prosperity', 'Time & Commitments', 'Personal Intelligence'];
  @override void initState() { super.initState(); _name = widget.prefs.getString('user_name') ?? ''; _tts.setSpeechRate(.44); }
  @override void dispose() { _motion.dispose(); _tts.stop(); super.dispose(); }
  Future<void> _speak(String text) async { await _tts.stop(); await _tts.speak(text); }
  Future<void> _profile() async {
    final c = TextEditingController(text: _name);
    final value = await showDialog<String>(context: context, builder: (d) => AlertDialog(
      backgroundColor: const Color(0xFF07101B), title: const Text('PROFILE', style: TextStyle(letterSpacing: 3)),
      content: TextField(controller: c, autofocus: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.white70))),
      actions: [TextButton(onPressed: () => Navigator.pop(d), child: const Text('CANCEL')), FilledButton(onPressed: () => Navigator.pop(d, c.text.trim()), child: const Text('SAVE'))],
    ));
    if (value != null && value.isNotEmpty) { await widget.prefs.setString('user_name', value); if (mounted) setState(() => _name = value); }
  }
  void _openCore(int index) {
    final message = switch (index) { 0 => 'Life, growth, goals and daily progress.', 1 => 'Household, care and protection commitments.', 2 => 'Expenses, savings, investments and money intelligence.', 3 => 'Calendar, bills, renewals and time-sensitive commitments.', _ => 'Diary, personal goals, reflection and connected LifeOS context.' };
    _speak('${coreTitles[index]}. $message');
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF050C16), showDragHandle: true, builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(coreTitles[index], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)), const SizedBox(height: 12), Text(message, style: const TextStyle(color: Colors.white70, height: 1.5)), const SizedBox(height: 18), const Text('ONE SCREEN • ONE TAP • ONE REPORT', style: TextStyle(letterSpacing: 2, fontSize: 11, color: Colors.white54))])));
  }
  @override Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(backgroundColor: const Color(0xFF020711), body: SafeArea(child: Stack(children: [
      Positioned.fill(child: AnimatedBuilder(animation: _motion, builder: (_, __) => CustomPaint(painter: _ReferenceSpacePainter(_motion.value)))),
      Positioned(top: 18, left: 24, right: 24, child: Row(children: [
        Container(width: 58, height: 58, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFFC067), width: 1.5)), child: const Center(child: Icon(Icons.all_inclusive_rounded, color: Color(0xFFFFC067), size: 34))),
        const SizedBox(width: 14), const Text('LIFEOZ', style: TextStyle(fontSize: 28, letterSpacing: 5, fontWeight: FontWeight.w600)), const Spacer(), IconButton(onPressed: _profile, icon: const Icon(Icons.tune_rounded), color: const Color(0xFFFFC067), iconSize: 29),
      ])),
      Positioned(top: size.height * .13, left: 0, right: 0, bottom: size.height * .08, child: GestureDetector(behavior: HitTestBehavior.translucent, onTapUp: (details) {
        final local = details.localPosition; final center = Offset(size.width / 2, size.height * .43); final dx = local.dx - center.dx, dy = local.dy - center.dy; final angle = math.atan2(dy, dx); final dist = math.sqrt(dx * dx + dy * dy);
        if (dist < 150) { _speak(_name.isEmpty ? 'I am here.' : 'I am here, $_name.'); return; } if (dist > 170 && dist < 340) _openCore(_nearestCore(angle));
      }, child: CustomPaint(painter: _ReferenceConstellationPainter(_motion.value), child: const SizedBox.expand()))),
      Positioned(bottom: 22, left: 0, right: 0, child: Center(child: Text(_name.isEmpty ? 'LIVING INTELLIGENCE' : 'LIVING INTELLIGENCE • $_name', style: const TextStyle(letterSpacing: 4, fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)))),
    ])));
  }
  int _nearestCore(double angle) { final points = [-math.pi / 2, 0.0, math.pi / 2, math.pi, 2.5]; var best = 0; var bestDiff = double.infinity; for (var i = 0; i < points.length; i++) { var d = (angle - points[i]).abs(); if (d > math.pi) d = 2 * math.pi - d; if (d < bestDiff) { bestDiff = d; best = i; } } return best; }
}

class _ReferenceSpacePainter extends CustomPainter { final double t; _ReferenceSpacePainter(this.t); @override void paint(Canvas canvas, Size size) { final p = Paint()..color = Colors.white.withOpacity(.34); final r = math.Random(17); for (var i = 0; i < 100; i++) canvas.drawCircle(Offset(r.nextDouble()*size.width, r.nextDouble()*size.height), .7+r.nextDouble()*1.2, p); } @override bool shouldRepaint(covariant _ReferenceSpacePainter old) => old.t != t; }

class _ReferenceConstellationPainter extends CustomPainter { final double t; _ReferenceConstellationPainter(this.t);
  @override void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .43); final radius = math.min(size.width * .29, 170.0); final points = [Offset(center.dx, center.dy-radius*1.45), Offset(center.dx+radius*1.28, center.dy-radius*.30), Offset(center.dx+radius*.92, center.dy+radius*1.25), Offset(center.dx-radius*.92, center.dy+radius*1.25), Offset(center.dx-radius*1.28, center.dy-radius*.30)];
    final line = Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0xFF4F7185).withOpacity(.45); for (final p in points) canvas.drawLine(center,p,line); final pulse=.5+.5*math.sin(t*2*math.pi); _drawYansi(canvas,center,92+pulse*4); for(var i=0;i<points.length;i++) _drawCore(canvas,points[i],i,42+pulse*2);
    final orbit=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0xFF6F91A4).withOpacity(.20); canvas.drawOval(Rect.fromCenter(center:center,width:radius*3.2,height:radius*1.3),orbit); canvas.drawOval(Rect.fromCenter(center:center,width:radius*2.7,height:radius*.9),orbit);
  }
  void _drawYansi(Canvas canvas, Offset c, double r) { final glow=Paint()..shader=RadialGradient(colors:[const Color(0xFF56E5FF).withOpacity(.85),const Color(0xFF4D72FF).withOpacity(.40),Colors.transparent]).createShader(Rect.fromCircle(center:c,radius:r*1.45)); canvas.drawCircle(c,r*1.45,glow); final fill=Paint()..shader=const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF69F2FF),Color(0xFF4B9EFF),Color(0xFF7C55D9)]).createShader(Rect.fromCircle(center:c,radius:r)); canvas.drawCircle(c,r,fill); final edge=Paint()..style=PaintingStyle.stroke..strokeWidth=2..color=const Color(0xFFBDEBFF).withOpacity(.85); for(var i=0;i<3;i++) canvas.drawOval(Rect.fromCenter(center:c,width:r*1.7,height:r*(.35+i*.2)),edge); canvas.drawCircle(c,r*.13,Paint()..color=Colors.white.withOpacity(.95)); }
  void _drawCore(Canvas canvas, Offset c, int i, double r) { final color=_LifeOZReferenceHomeState.coreColors[i]; final glow=Paint()..shader=RadialGradient(colors:[color.withOpacity(.78),color.withOpacity(.14),Colors.transparent]).createShader(Rect.fromCircle(center:c,radius:r*1.55)); canvas.drawCircle(c,r*1.5,glow); final p=Paint()..style=PaintingStyle.stroke..strokeWidth=2..color=color; canvas.drawOval(Rect.fromCenter(center:c,width:r*1.9,height:r*.62),p); canvas.save(); canvas.translate(c.dx,c.dy); canvas.rotate(i*.42); canvas.drawOval(Rect.fromCenter(center:Offset.zero,width:r*1.9,height:r*.62),p); canvas.restore(); final icon=Paint()..style=PaintingStyle.stroke..strokeWidth=3..strokeCap=StrokeCap.round..color=color; final path=Path();
    if(i==0){path.moveTo(c.dx,c.dy+r*.55);path.cubicTo(c.dx-r*.7,c.dy,c.dx-r*.4,c.dy-r*.8,c.dx,c.dy-r*.25);path.cubicTo(c.dx+r*.4,c.dy-r*.8,c.dx+r*.7,c.dy,c.dx,c.dy+r*.55);canvas.drawPath(path,icon);canvas.drawLine(c.dx,c.dy+r*.45,c.dx,c.dy-r*.1,icon);} else if(i==1){path.moveTo(c.dx,c.dy+r*.55);path.cubicTo(c.dx-r*.75,c.dy+r*.05,c.dx-r*.45,c.dy-r*.65,c.dx,c.dy-r*.25);path.cubicTo(c.dx+r*.45,c.dy-r*.65,c.dx+r*.75,c.dy+r*.05,c.dx,c.dy+r*.55);canvas.drawPath(path,icon);canvas.drawLine(c.dx,c.dy-r*.1,c.dx,c.dy+r*.35,icon);} else if(i==2){final q=Path();for(var k=0;k<32;k++){final a=k/31*math.pi*3.2;final rr=r*.65*(1-k/40);final pt=Offset(c.dx+math.cos(a)*rr,c.dy+math.sin(a)*rr);if(k==0)q.moveTo(pt.dx,pt.dy);else q.lineTo(pt.dx,pt.dy);}canvas.drawPath(q,icon);} else if(i==3){canvas.drawCircle(c,r*.48,icon);canvas.drawLine(c.dx,c.dy,c.dx,c.dy-r*.3,icon);canvas.drawLine(c.dx,c.dy,c.dx+r*.24,c.dy+r*.18,icon);} else {final q=Path()..moveTo(c.dx,c.dy-r*.65)..lineTo(c.dx+r*.48,c.dy)..lineTo(c.dx,c.dy+r*.65)..lineTo(c.dx-r*.48,c.dy)..close();canvas.drawPath(q,icon);canvas.drawCircle(c,r*.13,icon);} canvas.drawCircle(c,3.5,Paint()..color=Colors.white); }
  @override bool shouldRepaint(covariant _ReferenceConstellationPainter old) => old.t != t;
}
