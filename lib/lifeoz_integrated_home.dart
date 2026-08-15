import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lifeoz_core_hub.dart';

class LifeOZIntegratedHome extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZIntegratedHome({super.key, required this.prefs});
  @override
  State<LifeOZIntegratedHome> createState() => _LifeOZIntegratedHomeState();
}

class _LifeOZIntegratedHomeState extends State<LifeOZIntegratedHome> {
  final FlutterTts _tts = FlutterTts();
  String _name = '';
  int _reality = 0;
  static const realities = ['01_Oreon_Prime.png','02_Terra_Flux.png','03_Vortex_Nexus.png','04_Crysta_Lumen.png','09_Nebula_Soul-1.png','10_Shadow_Core-1.png'];

  @override
  void initState() { super.initState(); _name = widget.prefs.getString('user_name') ?? ''; _reality = (widget.prefs.getInt('lifeoz_reality') ?? 0).clamp(0, realities.length - 1); _tts.setSpeechRate(.44); }
  @override
  void dispose() { _tts.stop(); super.dispose(); }
  Future<void> _speak(String text) async { await _tts.stop(); await _tts.speak(text); }

  void _openCore(int index) {
    const messages = ['Growth intelligence: goals, productivity and progress.','Care intelligence: household, health and daily care.','Prosperity intelligence: expenses, investments and financial flow.','Time intelligence: tasks, calendar and commitments.','Personal intelligence: diary, reflection and personal goals.'];
    _speak(messages[index]);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => LifeOZCoreHub(prefs: widget.prefs, coreIndex: index)));
  }

  Future<void> _profile() async {
    final c = TextEditingController(text: _name);
    final value = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF050A12), title: const Text('PROFILE'), content: TextField(controller: c, autofocus: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Name')), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')), FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('SAVE'))]));
    c.dispose();
    if (value != null && value.isNotEmpty) { await widget.prefs.setString('user_name', value); if (mounted) setState(() => _name = value); }
  }

  void _controls() {
    showModalBottomSheet<void>(context: context, backgroundColor: const Color(0xFF050A12), builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: const Icon(Icons.person_outline), title: const Text('Profile'), onTap: () { Navigator.pop(ctx); _profile(); }),
      ListTile(leading: const Icon(Icons.palette_outlined), title: const Text('Design'), onTap: () { Navigator.pop(ctx); _showDesigns(); }),
      const ListTile(leading: Icon(Icons.security_outlined), title: Text('Permissions')),
      const ListTile(leading: Icon(Icons.settings_outlined), title: Text('Settings')),
    ])));
  }

  void _showDesigns() {
    showModalBottomSheet<void>(context: context, isScrollControlled: true, backgroundColor: const Color(0xFF03060D), builder: (ctx) => SafeArea(child: SizedBox(height: MediaQuery.of(ctx).size.height * .82, child: Column(children: [
      const Padding(padding: EdgeInsets.all(16), child: Text('LIFEOZ VISUAL REALITIES', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w700))),
      Expanded(child: GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: .72), itemCount: realities.length, itemBuilder: (_, i) => GestureDetector(onTap: () async { await widget.prefs.setInt('lifeoz_reality', i); if (mounted) setState(() => _reality = i); if (ctx.mounted) Navigator.pop(ctx); }, child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Stack(fit: StackFit.expand, children: [Image.asset(realities[i], fit: BoxFit.cover), Container(decoration: BoxDecoration(border: Border.all(color: _reality == i ? Colors.cyanAccent : Colors.white12, width: _reality == i ? 3 : 1), borderRadius: BorderRadius.circular(16)))]))))),
    ]))));
  }

  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFF01030A), body: SafeArea(child: LayoutBuilder(builder: (context, c) {
    final w = c.maxWidth, h = c.maxHeight;
    final positions = [Offset(w*.50,h*.28), Offset(w*.22,h*.43), Offset(w*.78,h*.43), Offset(w*.28,h*.68), Offset(w*.72,h*.68)];
    return Stack(children: [
      Positioned.fill(child: CustomPaint(painter: _CosmicPainter(reality: _reality))),
      Positioned(left: 22, top: 10, child: Row(children: [CustomPaint(size: const Size(62,62), painter: _BrandPainter()), const SizedBox(width: 14), const Text('LIFEOZ', style: TextStyle(color: Color(0xFFF2EEF7), fontSize: 34, fontWeight: FontWeight.w600, letterSpacing: 7))])),
      Positioned(right: 18, top: 12, width: 58, height: 58, child: GestureDetector(onTap: _controls, child: const _ControlGlyph())),
      Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _EnergyPainter(positions: positions)))),
      Positioned(left: w*.23, top: h*.30, width: w*.54, height: h*.34, child: GestureDetector(onTap: () => _speak('I am Yansi, your silent LifeOS intelligence.'), child: const CustomPaint(painter: _YansiPainter()))),
      ...List.generate(5, (i) => Positioned(left: positions[i].dx-43, top: positions[i].dy-43, width: 86, height: 86, child: GestureDetector(onTap: () => _openCore(i), child: CustomPaint(painter: _CorePainter(index: i))))),
      Positioned(bottom: 18, left: 0, right: 0, child: Center(child: Text('LIVING INTELLIGENCE${_name.isEmpty ? '' : '  •  ${_name.toUpperCase()}'}', style: const TextStyle(color: Colors.white70, letterSpacing: 3, fontSize: 11, fontWeight: FontWeight.w600)))),
    ]);
  })));
}

class _BrandPainter extends CustomPainter { @override void paint(Canvas c, Size s) { final o=Offset(s.width/2,s.height/2); final p=Paint()..style=PaintingStyle.stroke..strokeWidth=2.5..color=const Color(0xFFFFBD68); c.drawOval(Rect.fromCenter(center:o,width:50,height:50),p); c.drawOval(Rect.fromCenter(center:Offset(o.dx,o.dy+1),width:39,height:15),p); c.drawCircle(Offset(o.dx+8,o.dy+1),4,Paint()..color=const Color(0xFF39E37B)); } @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false; }
class _ControlGlyph extends StatelessWidget { const _ControlGlyph(); @override Widget build(BuildContext context)=>CustomPaint(painter:_ControlPainter()); }
class _ControlPainter extends CustomPainter { @override void paint(Canvas c, Size s) { final p=Paint()..color=const Color(0xFFFFB75E)..strokeWidth=2.5..strokeCap=StrokeCap.round; for(var i=0;i<3;i++){final y=18.0+i*12;c.drawLine(12,y,46,y,p);} for(final o in const [Offset(23,18),Offset(39,30),Offset(28,42)]) c.drawCircle(o,4,Paint()..color=const Color(0xFF01030A)); c.drawCircle(const Offset(29,30),27,Paint()..style=PaintingStyle.stroke..strokeWidth=1.2..color=const Color(0xFFFFB75E).withOpacity(.7)); } @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false; }
class _YansiPainter extends CustomPainter { const _YansiPainter(); @override void paint(Canvas c, Size s) { final o=Offset(s.width/2,s.height*.53),r=math.min(s.width,s.height)*.23; c.drawCircle(o,r*2.2,Paint()..shader=RadialGradient(colors:[const Color(0xFF39E6FF).withOpacity(.32),Colors.transparent]).createShader(Rect.fromCircle(center:o,radius:r*2.2))); c.drawCircle(o,r,Paint()..shader=const LinearGradient(colors:[Color(0xFF38E6FF),Color(0xFF3D8FFF),Color(0xFF7E55E8)]).createShader(Rect.fromCircle(center:o,radius:r))); final wire=Paint()..color=Colors.white.withOpacity(.72)..style=PaintingStyle.stroke..strokeWidth=1.4; for(var i=-2;i<=2;i++){final y=o.dy+i*r*.25;c.drawOval(Rect.fromCenter(center:Offset(o.dx,y),width:r*1.85,height:r*.25),wire);} c.drawOval(Rect.fromCenter(center:o,width:r*1.9,height:r*.62),wire); final gold=Paint()..color=const Color(0xFFFFC15A)..style=PaintingStyle.stroke..strokeWidth=2.1; final path=Path()..moveTo(o.dx,o.dy-r*1.2)..cubicTo(o.dx-r*.7,o.dy-r*.5,o.dx-r*.7,o.dy+r*.6,o.dx,o.dy+r*1.25)..cubicTo(o.dx+r*.7,o.dy+r*.6,o.dx+r*.7,o.dy-r*.5,o.dx,o.dy-r*1.2); c.drawPath(path,gold); c.drawCircle(o,r*.12,Paint()..color=Colors.white); } @override bool shouldRepaint(covariant _YansiPainter oldDelegate)=>false; }
class _CorePainter extends CustomPainter { final int index; const _CorePainter({required this.index}); @override void paint(Canvas c,Size s){final o=Offset(s.width/2,s.height/2); const cs=[Color(0xFF4FEF83),Color(0xFFFF5A61),Color(0xFFFFB83D),Color(0xFF42D9FF),Color(0xFFC86BFF)]; final color=cs[index]; c.drawCircle(o,25,Paint()..color=color.withOpacity(.16)..maskFilter=const MaskFilter.blur(BlurStyle.normal,15)); final p=Paint()..color=color..style=PaintingStyle.stroke..strokeWidth=2.2; if(index==0){final q=Path()..moveTo(o.dx,o.dy+24)..cubicTo(o.dx-25,o.dy+5,o.dx-22,o.dy-20,o.dx,o.dy-28)..cubicTo(o.dx+22,o.dy-20,o.dx+25,o.dy+5,o.dx,o.dy+24)..close();c.drawPath(q,p);c.drawLine(Offset(o.dx,o.dy+17),Offset(o.dx,o.dy-18),p);}else if(index==1){final q=Path()..moveTo(o.dx,o.dy+25)..cubicTo(o.dx-42,o.dy-2,o.dx-25,o.dy-30,o.dx,o.dy-12)..cubicTo(o.dx+25,o.dy-30,o.dx+42,o.dy-2,o.dx,o.dy+25)..close();c.drawPath(q,p);}else if(index==2){final q=Path();for(var i=0;i<=40;i++){final t=i/40*math.pi*2.5,r=2+i*.55,z=Offset(o.dx+math.cos(t)*r,o.dy+math.sin(t)*r);if(i==0)q.moveTo(z.dx,z.dy);else q.lineTo(z.dx,z.dy);}c.drawPath(q,p);}else if(index==3){c.drawCircle(o,22,p);c.drawCircle(o,5,p);c.drawLine(o,Offset(o.dx,o.dy-15),p);c.drawLine(o,Offset(o.dx,o.dy),Offset(o.dx+13,o.dy+9),p);}else{final q=Path()..moveTo(o.dx,o.dy-28)..lineTo(o.dx+23,o.dy-7)..lineTo(o.dx+14,o.dy+24)..lineTo(o.dx,o.dy+30)..lineTo(o.dx-14,o.dy+24)..lineTo(o.dx-23,o.dy-7)..close();c.drawPath(q,p);c.drawLine(Offset(o.dx,o.dy-28),Offset(o.dx,o.dy+30),p);}c.drawCircle(o,3.5,Paint()..color=Colors.white);} @override bool shouldRepaint(covariant _CorePainter oldDelegate)=>oldDelegate.index!=index; }
class _EnergyPainter extends CustomPainter { final List<Offset> positions; const _EnergyPainter({required this.positions}); @override void paint(Canvas c,Size s){final o=Offset(s.width/2,s.height*.48),p=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0xFF46B7E8).withOpacity(.16);for(final x in positions)c.drawLine(o,x,p);final ring=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0xFF3AA9C5).withOpacity(.12);c.drawOval(Rect.fromCenter(center:o,width:s.width*.95,height:s.width*.30),ring);c.drawOval(Rect.fromCenter(center:o,width:s.width*.72,height:s.width*.22),ring);} @override bool shouldRepaint(covariant _EnergyPainter oldDelegate)=>false; }
class _CosmicPainter extends CustomPainter { final int reality; const _CosmicPainter({required this.reality}); @override void paint(Canvas c,Size s){c.drawRect(Offset.zero&s,Paint()..shader=const RadialGradient(center:Alignment(0,.05),radius:1.1,colors:[Color(0xFF071A29),Color(0xFF030811),Color(0xFF01030A)]).createShader(Offset.zero&s));final random=math.Random(100+reality);final stars=Paint()..color=Colors.white.withOpacity(.42);for(var i=0;i<90;i++){final x=random.nextDouble()*s.width,y=random.nextDouble()*s.height,r=.4+random.nextDouble()*1.4;c.drawCircle(Offset(x,y),r,stars);}final h=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=const Color(0xFF2F9DBA).withOpacity(.10);c.drawOval(Rect.fromCenter(center:Offset(s.width/2,s.height*.52),width:s.width*1.15,height:s.width*.32),h);} @override bool shouldRepaint(covariant _CosmicPainter oldDelegate)=>oldDelegate.reality!=reality; }
