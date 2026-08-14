import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'services/yansi_brain.dart';

class LifeOZFutureShell extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZFutureShell({super.key, required this.prefs});
  @override State<LifeOZFutureShell> createState() => _LifeOZFutureShellState();
}

class _LifeOZFutureShellState extends State<LifeOZFutureShell> with SingleTickerProviderStateMixin {
  late final AnimationController motion;
  late final YansiBrain brain;
  final tts = FlutterTts();
  final speech = stt.SpeechToText();
  final input = TextEditingController();
  String name = '', country = 'India', currency = 'INR', language = 'English', realityId = 'neural_void';
  String message = 'Yansi is present.', transcript = '';
  bool onboarding = true, listening = false, speaking = false, controls = false;
  int activeCore = -1;

  static const realities = <Reality>[
    Reality('neural_void','NEURAL VOID','Living neural space',Color(0xFF00F0FF),Color(0xFF00FF9D)),
    Reality('quantum_glass','QUANTUM GLASS','Transparent quantum layers',Color(0xFFB48CFF),Color(0xFF44E7FF)),
    Reality('holo_prism','HOLO PRISM','Volumetric light geometry',Color(0xFFFF4FD8),Color(0xFF52F7FF)),
    Reality('aurora_intelligence','AURORA INTELLIGENCE','Organic adaptive field',Color(0xFFB4FF58),Color(0xFF00E5FF)),
    Reality('singularity','SINGULARITY','Deep-space minimalism',Color(0xFFEAF8FF),Color(0xFF4DE7FF)),
    Reality('terra_flux','TERRA FLUX','Bio-energy life topology',Color(0xFFFFB15C),Color(0xFF58FFD2)),
  ];
  static const meanings = ['Money, income, bills and investments.','Work, tasks and execution.','Calendar, renewals and commitments.','Home, shopping and household.','Goals, diary and personal growth.'];
  Reality get reality => realities.firstWhere((r) => r.id == realityId, orElse: () => realities.first);

  @override void initState() {
    super.initState();
    motion = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
    brain = YansiBrain(prefs: widget.prefs);
    name = widget.prefs.getString('user_name') ?? '';
    country = widget.prefs.getString('user_country') ?? 'India';
    currency = widget.prefs.getString('user_currency') ?? 'INR';
    language = widget.prefs.getString('user_language') ?? 'English';
    realityId = widget.prefs.getString('lifeoz_reality') ?? 'neural_void';
    onboarding = widget.prefs.getBool('lifeoz_master_ready') != true;
    tts.setSpeechRate(.44);
    tts.setStartHandler(() { if (mounted) setState(() => speaking = true); });
    tts.setCompletionHandler(() { if (mounted) setState(() => speaking = false); });
  }

  Future<void> speak(String text) async { await speech.stop(); await tts.stop(); await tts.speak(text); }
  Future<void> process(String text) async { await speech.stop(); if (mounted) setState(() => listening = false); final r = await brain.process(text); if (!mounted) return; setState(() { message = r.response; transcript = ''; }); await speak(r.response); }

  Future<void> listen() async {
    if (listening) { await speech.stop(); if (mounted) setState(() => listening = false); return; }
    final ok = await speech.initialize(onStatus: (s) { if ((s == 'done' || s == 'notListening') && mounted) setState(() => listening = false); }, onError: (_) { if (mounted) setState(() => listening = false); });
    if (!ok) { toast('Microphone permission is required for Yansi.'); return; }
    setState(() { listening = true; transcript = ''; });
    await speech.listen(listenFor: const Duration(seconds: 30), pauseFor: const Duration(seconds: 4), onResult: (r) { if (!mounted) return; setState(() => transcript = r.recognizedWords); if (r.finalResult && r.recognizedWords.trim().isNotEmpty) process(r.recognizedWords); });
  }

  Future<void> enter() async {
    if (name.trim().isEmpty) { toast('Enter your name so Yansi knows who she is assisting.'); return; }
    await widget.prefs.setString('user_name', name.trim());
    await widget.prefs.setString('user_country', country);
    await widget.prefs.setString('user_currency', currency);
    await widget.prefs.setString('user_language', language);
    await widget.prefs.setString('lifeoz_reality', realityId);
    await widget.prefs.setBool('lifeoz_master_ready', true);
    if (!mounted) return;
    setState(() => onboarding = false);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await speak('Welcome, $name. I am Yansi. Your life is now connected. Tell me what you need.');
  }

  void toast(String s) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s))); }
  void choose(String id) { setState(() => realityId = id); widget.prefs.setString('lifeoz_reality', id); }

  @override void dispose() { motion.dispose(); tts.stop(); speech.stop(); input.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFF010207), body: AnimatedBuilder(animation: motion, builder: (_, __) => onboarding ? buildOnboarding() : buildHome()));

  Widget buildOnboarding() => Stack(children: [environment(), SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(22), child: Column(children: [brand(76), const SizedBox(height: 12), const Text('LIFEOZ', style: TextStyle(fontSize: 32, letterSpacing: 9, fontWeight: FontWeight.w200)), const SizedBox(height: 5), Text('A LIFE OPERATING SYSTEM', style: TextStyle(fontSize: 9, letterSpacing: 3, color: reality.a.withValues(alpha: .7))), const SizedBox(height: 25), panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('IDENTITY FIELD'), TextField(onChanged: (v) => name = v, style: const TextStyle(fontSize: 18), decoration: const InputDecoration(hintText: 'What should Yansi call you?', hintStyle: TextStyle(color: Colors.white30), border: InputBorder.none)), const SizedBox(height: 14), Row(children: [Expanded(child: select('LOCATION', country, ['India','United States','United Kingdom','Canada','Australia','Other'], (v) => country = v)), const SizedBox(width: 10), Expanded(child: select('CURRENCY', currency, ['INR','USD','GBP','CAD','AUD','EUR'], (v) => currency = v))]), const SizedBox(height: 10), select('LANGUAGE', language, ['English','Hindi','Gujarati'], (v) => language = v)])), const SizedBox(height: 14), panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('CHOOSE YOUR REALITY'), SizedBox(height: 155, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: realities.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => realityCard(realities[i])))])), const SizedBox(height: 18), primary('ENTER THE LIFEOZ FIELD', enter)]))]);

  Widget buildHome() => Stack(children: [environment(), SafeArea(child: Column(children: [Padding(padding: const EdgeInsets.all(16), child: Row(children: [control(), const Spacer(), Column(children: [const Text('LIFEOZ', style: TextStyle(fontSize: 13, letterSpacing: 5, fontWeight: FontWeight.w700)), Text(name.toUpperCase(), style: TextStyle(fontSize: 7, letterSpacing: 2, color: reality.a.withValues(alpha: .6)))]), const Spacer(), voice()])), Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), child: Column(children: [SizedBox(height: 290, child: Center(child: GestureDetector(onTap: listen, child: yansi()))), Text(transcript.isNotEmpty ? transcript : message, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: .78))), const SizedBox(height: 15), constellation(), const SizedBox(height: 15), command()]))])), if (controls) controlOverlay()]);

  Widget environment() => Positioned.fill(child: CustomPaint(painter: EnvironmentPainter(reality, motion.value)));
  Widget brand(double size) => SizedBox(width: size, height: size, child: CustomPaint(painter: BrandPainter(reality.a, reality.b)));
  Widget control() => GestureDetector(onTap: () => setState(() => controls = true), child: Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: reality.a.withValues(alpha: .45))), child: CustomPaint(painter: ControlPainter(reality.a))));
  Widget voice() => GestureDetector(onTap: listen, child: Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: reality.b.withValues(alpha: .5))), child: Icon(listening ? Icons.graphic_eq_rounded : Icons.mic_none_rounded, color: reality.b)));
  Widget yansi() => SizedBox(width: 245, height: 245, child: CustomPaint(painter: YansiPainter(reality, motion.value, listening, speaking)));

  Widget constellation() => SizedBox(width: 350, height: 200, child: Stack(alignment: Alignment.center, children: [CustomPaint(size: const Size(340, 200), painter: ConstellationPainter(reality)), ...List.generate(5, (i) { final a = -math.pi / 2 + i * 2 * math.pi / 5; return Transform.translate(offset: Offset(math.cos(a) * 116, math.sin(a) * 76), child: GestureDetector(onTap: () { setState(() => activeCore = i); speak(meanings[i]); }, child: glyph(i))); }), brand(66)]));
  Widget glyph(int i) => Container(width: 58, height: 58, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xCC050912), border: Border.all(color: (activeCore == i ? reality.b : reality.a).withValues(alpha: .8), width: activeCore == i ? 2 : 1)), child: CustomPaint(painter: GlyphPainter(i, activeCore == i ? reality.b : reality.a)));
  Widget command() => panel(Row(children: [Icon(Icons.auto_awesome, color: reality.a), const SizedBox(width: 8), Expanded(child: TextField(controller: input, onSubmitted: process, decoration: const InputDecoration(hintText: 'Speak to Yansi…', hintStyle: TextStyle(color: Colors.white30), border: InputBorder.none))), IconButton(onPressed: listen, icon: Icon(Icons.mic_none, color: reality.b))]));

  Widget controlOverlay() => Positioned.fill(child: GestureDetector(onTap: () => setState(() => controls = false), child: Container(color: Colors.black.withValues(alpha: .72), child: Center(child: GestureDetector(onTap: () {}, child: panel(Column(mainAxisSize: MainAxisSize.min, children: [brand(58), const SizedBox(height: 10), Text('CONTROL FIELD', style: TextStyle(letterSpacing: 3, color: reality.a)), const SizedBox(height: 15), action('REALITY', Icons.blur_on, showRealities), action('IDENTITY', Icons.person_outline, () => showInfo('IDENTITY', ['Name: $name','Location: $country','Currency: $currency','Language: $language'])), action('PERMISSIONS', Icons.shield_outlined, () => showInfo('PERMISSIONS', ['Voice: controlled','Background AI: controlled','Web access: permission controlled'])), action('YANSI', Icons.auto_awesome, () => speak('I am Yansi. I connect the information you allow me to access and turn it into useful intelligence.'))]))))));
  Widget action(String title, IconData icon, VoidCallback fn) => ListTile(onTap: fn, leading: Icon(icon, color: reality.a), title: Text(title, style: const TextStyle(letterSpacing: 1.5, fontSize: 11)), trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white30));

  void showRealities() => showModalBottomSheet(context: context, backgroundColor: const Color(0xFF05080E), builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: SizedBox(height: 190, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: realities.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => realityCard(realities[i]))))));
  void showInfo(String title, List<String> lines) => showModalBottomSheet(context: context, backgroundColor: const Color(0xFF060A12), builder: (_) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: reality.a, letterSpacing: 2)), const SizedBox(height: 15), ...lines.map((x) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(x, style: const TextStyle(color: Colors.white70))))]));

  Widget realityCard(Reality r) => GestureDetector(onTap: () { choose(r.id); Navigator.of(context).maybePop(); }, child: Container(width: 155, padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: realityId == r.id ? r.a : Colors.white12), gradient: LinearGradient(colors: [r.a.withValues(alpha: .13), const Color(0xFF05070D)])), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Center(child: CustomPaint(size: const Size(70,70), painter: PreviewPainter(r)))), Text(r.name, style: TextStyle(fontSize: 9, color: r.a, letterSpacing: 1.1)), const SizedBox(height: 3), Text(r.subtitle, style: const TextStyle(fontSize: 8, color: Colors.white38))]));
  Widget panel(Widget child) => Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0x66101824), borderRadius: BorderRadius.circular(22), border: Border.all(color: reality.a.withValues(alpha: .16))), child: child);
  Widget _label(String s) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Text(s, style: const TextStyle(fontSize: 9, letterSpacing: 2, color: Colors.white54)));
  Widget select(String label, String value, List<String> items, ValueChanged<String> fn) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label(label), DropdownButton<String>(value: items.contains(value) ? value : items.first, isExpanded: true, underline: const SizedBox(), dropdownColor: const Color(0xFF101620), items: items.map((x) => DropdownMenuItem(value: x, child: Text(x, style: const TextStyle(fontSize: 12)))).toList(), onChanged: (v) { if (v != null) { fn(v); setState(() {}); } })]);
  Widget primary(String text, VoidCallback fn) => SizedBox(width: double.infinity, height: 54, child: ElevatedButton(onPressed: fn, style: ElevatedButton.styleFrom(backgroundColor: reality.a.withValues(alpha: .12), foregroundColor: reality.a, side: BorderSide(color: reality.a.withValues(alpha: .45)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: Text(text, style: const TextStyle(letterSpacing: 2, fontSize: 11))));
}

class Reality { final String id, name, subtitle; final Color a, b; const Reality(this.id, this.name, this.subtitle, this.a, this.b); }

class EnvironmentPainter extends CustomPainter { final Reality r; final double t; EnvironmentPainter(this.r, this.t); @override void paint(Canvas c, Size s) { final p = Paint()..shader = RadialGradient(colors: [r.a.withValues(alpha:.08), Colors.transparent]).createShader(Rect.fromCircle(center:s.center(Offset.zero), radius:s.longestSide*.7)); c.drawRect(Offset.zero & s, p); final l=Paint()..color=r.a.withValues(alpha:.06)..strokeWidth=1; for(int i=0;i<8;i++){final y=s.height*(i/8);c.drawLine(Offset(0,y),Offset(s.width,y+math.sin(t*math.pi*2+i)*15),l);} for(int i=0;i<30;i++){final x=(math.sin(i*7.3+t*6.28)*.5+.5)*s.width;final y=(math.cos(i*4.7+t*6.28)*.5+.5)*s.height;c.drawCircle(Offset(x,y),1,Paint()..color=(i.isEven?r.a:r.b).withValues(alpha:.18));}} @override bool shouldRepaint(covariant EnvironmentPainter old)=>true; }
class BrandPainter extends CustomPainter { final Color a,b; BrandPainter(this.a,this.b); @override void paint(Canvas c,Size s){final m=s.center(Offset.zero);final r=s.shortestSide*.3;final p=Paint()..style=PaintingStyle.stroke..strokeWidth=3..strokeCap=StrokeCap.round..shader=LinearGradient(colors:[a,b]).createShader(Offset.zero&s);final path=Path()..moveTo(m.dx-r,m.dy)..cubicTo(m.dx-r*.3,m.dy-r*1.2,m.dx+r*.3,m.dy+r*1.2,m.dx+r,m.dy)..cubicTo(m.dx+r*.3,m.dy-r*1.2,m.dx-r*.3,m.dy+r*1.2,m.dx-r,m.dy);c.drawPath(path,p);c.drawCircle(m,r*.2,Paint()..color=b); } @override bool shouldRepaint(covariant BrandPainter old)=>false; }
class ControlPainter extends CustomPainter { final Color color; ControlPainter(this.color); @override void paint(Canvas c,Size s){final p=Paint()..style=PaintingStyle.stroke..strokeWidth=2..color=color;final m=s.center(Offset.zero);c.drawCircle(m,9,p);c.drawCircle(m,4,p);for(int i=0;i<4;i++){final a=i*math.pi/2;c.drawLine(m+Offset(math.cos(a)*11,math.sin(a)*11),m+Offset(math.cos(a)*16,math.sin(a)*16),p);}} @override bool shouldRepaint(covariant ControlPainter old)=>false; }
class YansiPainter extends CustomPainter { final Reality r; final double t; final bool listen,speak; YansiPainter(this.r,this.t,this.listen,this.speak); @override void paint(Canvas c,Size s){final m=s.center(Offset.zero);for(int i=0;i<6;i++){final p=Paint()..style=PaintingStyle.stroke..strokeWidth=i==0?2.5:1..color=(i.isEven?r.a:r.b).withValues(alpha:.2);c.drawCircle(m,45+i*15+math.sin(t*6.28)*2,p);}final core=Paint()..shader=RadialGradient(colors:[Colors.white,r.a,r.b.withValues(alpha:.2),Colors.transparent]).createShader(Rect.fromCircle(center:m,radius:55));c.drawCircle(m,52,core);for(int i=0;i<60;i++){final a=i*math.pi*2/60+t*6.28*(i.isEven?1:-1);final rr=55+(i%5)*11;c.drawCircle(m+Offset(math.cos(a)*rr,math.sin(a)*rr*.72),i%8==0?2:1,Paint()..color=(i.isEven?r.a:r.b).withValues(alpha:.4));}} @override bool shouldRepaint(covariant YansiPainter old)=>true; }
class ConstellationPainter extends CustomPainter { final Reality r; ConstellationPainter(this.r); @override void paint(Canvas c,Size s){final m=s.center(Offset.zero);final p=Paint()..color=r.a.withValues(alpha:.16)..style=PaintingStyle.stroke;final pts=<Offset>[];for(int i=0;i<5;i++){final a=-math.pi/2+i*2*math.pi/5;pts.add(m+Offset(math.cos(a)*116,math.sin(a)*76));}for(final q in pts)c.drawLine(m,q,p);for(int i=0;i<5;i++)c.drawLine(pts[i],pts[(i+1)%5],p);c.drawCircle(m,42,p);} @override bool shouldRepaint(covariant ConstellationPainter old)=>false; }
class GlyphPainter extends CustomPainter { final int i; final Color color; GlyphPainter(this.i,this.color); @override void paint(Canvas c,Size s){final m=s.center(Offset.zero);final p=Paint()..style=PaintingStyle.stroke..strokeWidth=2..color=color;final r=s.shortestSide*.25;if(i==0){c.drawCircle(m,r,p);c.drawArc(Rect.fromCircle(center:m,radius:r*1.6),-.8,1.6,false,p);}else if(i==1){c.drawLine(m+Offset(-r,0),m+Offset(r,0),p);c.drawLine(m+Offset(0,-r),m+Offset(0,r),p);c.drawCircle(m,r*.6,p);}else if(i==2){c.drawCircle(m,r*1.2,p);c.drawLine(m,m+Offset(0,-r),p);c.drawLine(m,m+Offset(r*.8,r*.6),p);}else if(i==3){final q=Path()..moveTo(m.dx-r,m.dy+r)..lineTo(m.dx,m.dy-r)..lineTo(m.dx+r,m.dy+r)..close();c.drawPath(q,p);}else{final q=Path()..moveTo(m.dx-r,m.dy+r)..lineTo(m.dx-r*.2,m.dy)..lineTo(m.dx+r*.2,m.dy+r*.5)..lineTo(m.dx+r,m.dy-r);c.drawPath(q,p);}} @override bool shouldRepaint(covariant GlyphPainter old)=>false; }
class PreviewPainter extends CustomPainter { final Reality r; PreviewPainter(this.r); @override void paint(Canvas c,Size s){final m=s.center(Offset.zero);final p=Paint()..style=PaintingStyle.stroke..strokeWidth=2..color=r.a;for(int i=0;i<4;i++)c.drawCircle(m,12+i*7,p);c.drawLine(m+const Offset(-28,0),m+const Offset(28,0),p);c.drawLine(m+const Offset(0,-28),m+const Offset(0,28),p);} @override bool shouldRepaint(covariant PreviewPainter old)=>false; }
