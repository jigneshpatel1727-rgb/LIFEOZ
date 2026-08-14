import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'services/yansi_brain.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(LifeOSApp(prefs: prefs));
}

class LifeOSApp extends StatelessWidget {
  final SharedPreferences prefs;
  const LifeOSApp({super.key, required this.prefs});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'LIFEOZ',
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF02040A), useMaterial3: true),
    home: LifeOSHome(prefs: prefs),
  );
}

class DesignProfile {
  final String id, name, subtitle;
  final Color a, b, c;
  const DesignProfile(this.id, this.name, this.subtitle, this.a, this.b, this.c);
}

const designs = <DesignProfile>[
  DesignProfile('neural_flow', 'NEURAL FLOW', 'Living neural intelligence', Color(0xFF00F0FF), Color(0xFF00FF9D), Color(0xFF063A56)),
  DesignProfile('quantum_pulse', 'QUANTUM PULSE', 'Quantum energy interface', Color(0xFF8C7CFF), Color(0xFF00D9FF), Color(0xFF24165A)),
  DesignProfile('holo_prism', 'HOLO PRISM', 'Layered holographic space', Color(0xFFFF4FD8), Color(0xFF55F7FF), Color(0xFF35134A)),
  DesignProfile('aurora_core', 'AURORA CORE', 'Organic adaptive intelligence', Color(0xFF7CFF5B), Color(0xFF00E5FF), Color(0xFF123B24)),
  DesignProfile('singularity', 'SINGULARITY', 'Minimal deep-space intelligence', Color(0xFFE8F7FF), Color(0xFF4DE7FF), Color(0xFF18212A)),
];

class LifeOSHome extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOSHome({super.key, required this.prefs});
  @override State<LifeOSHome> createState() => _LifeOSHomeState();
}

class _LifeOSHomeState extends State<LifeOSHome> with SingleTickerProviderStateMixin {
  late final YansiBrain brain;
  final tts = FlutterTts();
  final speech = stt.SpeechToText();
  late AnimationController anim;
  String name = '', country = 'India', currency = 'INR', designId = 'neural_flow', message = 'Yansi is ready.', transcript = '';
  bool onboarding = true, listening = false, speaking = false, drawer = false;
  int selectedCore = -1;
  DesignProfile get design => designs.firstWhere((d) => d.id == designId, orElse: () => designs.first);
  final cores = const [Icons.account_balance_wallet_rounded, Icons.bolt_rounded, Icons.calendar_month_rounded, Icons.shopping_basket_rounded, Icons.track_changes_rounded];

  @override void initState() {
    super.initState();
    brain = YansiBrain(prefs: widget.prefs);
    anim = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    name = widget.prefs.getString('user_name') ?? '';
    country = widget.prefs.getString('user_country') ?? 'India';
    currency = widget.prefs.getString('user_currency') ?? 'INR';
    designId = widget.prefs.getString('lifeos_design') ?? 'neural_flow';
    onboarding = widget.prefs.getBool('lifeos_ready') != true;
    _voiceSetup();
    if (!onboarding) WidgetsBinding.instance.addPostFrameCallback((_) => _say('Welcome back, $name. I am Yansi.'));
  }

  Future<void> _voiceSetup() async {
    await tts.setSpeechRate(.44);
    tts.setStartHandler(() { if (mounted) setState(() => speaking = true); });
    tts.setCompletionHandler(() { if (mounted) setState(() => speaking = false); });
  }

  Future<void> _say(String text) async {
    if (text.trim().isEmpty) return;
    await speech.stop(); await tts.stop(); await tts.speak(text);
  }

  Future<void> _listen() async {
    if (listening) { await speech.stop(); if (mounted) setState(() => listening = false); return; }
    final ok = await speech.initialize(onStatus: (s) { if ((s == 'done' || s == 'notListening') && mounted) setState(() => listening = false); }, onError: (_) { if (mounted) setState(() => listening = false); });
    if (!ok) { _toast('Microphone permission is required for Yansi voice.'); return; }
    setState(() { listening = true; transcript = ''; });
    await speech.listen(listenFor: const Duration(seconds: 30), pauseFor: const Duration(seconds: 4), onResult: (r) {
      if (!mounted) return;
      setState(() => transcript = r.recognizedWords);
      if (r.finalResult && r.recognizedWords.trim().isNotEmpty) _process(r.recognizedWords);
    });
  }

  Future<void> _process(String text) async {
    await speech.stop();
    if (mounted) setState(() => listening = false);
    final r = await brain.process(text);
    if (!mounted) return;
    setState(() { message = r.response; transcript = ''; });
    await _say(r.response);
  }

  Future<void> _finishProfile() async {
    if (name.trim().isEmpty) { _toast('Tell Yansi your name first.'); return; }
    await widget.prefs.setString('user_name', name.trim());
    await widget.prefs.setString('user_country', country);
    await widget.prefs.setString('user_currency', currency);
    await widget.prefs.setString('lifeos_design', designId);
    await widget.prefs.setBool('lifeos_ready', true);
    if (!mounted) return;
    setState(() => onboarding = false);
    await Future.delayed(const Duration(milliseconds: 250));
    await _say('Welcome, $name. I am Yansi, your personal LifeOS AI agent. Tell me what you need.');
  }

  void _toast(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  @override void dispose() { anim.dispose(); tts.stop(); speech.stop(); super.dispose(); }

  @override Widget build(BuildContext context) => onboarding ? _onboarding() : _home();

  Widget _onboarding() => Scaffold(
    body: _space(child: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(24, 38, 24, 30), children: [
      const SizedBox(height: 20),
      _orb(size: 130),
      const SizedBox(height: 28),
      const Text('LIFEOZ', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, letterSpacing: 9, fontWeight: FontWeight.w300)),
      const SizedBox(height: 8),
      Text('YOUR LIFE. ONE INTELLIGENT SYSTEM.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, letterSpacing: 2.4, color: design.a.withOpacity(.7))),
      const SizedBox(height: 34),
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('IDENTITY', style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.white54)),
        const SizedBox(height: 8),
        TextField(onChanged: (v) => name = v, style: const TextStyle(fontSize: 18), decoration: _dec('What should Yansi call you?')),
        const SizedBox(height: 18),
        Row(children: [Expanded(child: _select('LOCATION', country, ['India','United States','United Kingdom','Canada','Australia','Other'], (v) => setState(() => country = v))), const SizedBox(width: 12), Expanded(child: _select('CURRENCY', currency, ['INR','USD','GBP','CAD','AUD','EUR'], (v) => setState(() => currency = v)))]),
      ])),
      const SizedBox(height: 18),
      _glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('CHOOSE YOUR REALITY', style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.white54)),
        const SizedBox(height: 12),
        SizedBox(height: 132, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: designs.length, separatorBuilder: (_,__) => const SizedBox(width: 10), itemBuilder: (_, i) => _designCard(designs[i], compact: true))),
      ])),
      const SizedBox(height: 24),
      _primaryButton('ENTER LIFEOZ', _finishProfile),
    ])),
  );

  InputDecoration _dec(String hint) => InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white30), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: design.a.withOpacity(.2))), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: design.a)), border: InputBorder.none);

  Widget _select(String label, String value, List<String> items, ValueChanged<String> onChanged) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38, letterSpacing: 1.4)), DropdownButton<String>(value: items.contains(value) ? value : items.first, isExpanded: true, underline: const SizedBox(), dropdownColor: const Color(0xFF101620), items: items.map((x) => DropdownMenuItem(value: x, child: Text(x, style: const TextStyle(fontSize: 12)))).toList(), onChanged: (v) { if (v != null) onChanged(v); })]);

  Widget _designCard(DesignProfile d, {bool compact = false}) => GestureDetector(onTap: () => setState(() => designId = d.id), child: AnimatedContainer(duration: const Duration(milliseconds: 250), width: compact ? 154 : double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: designId == d.id ? d.a : Colors.white.withOpacity(.08), width: designId == d.id ? 1.6 : 1), gradient: LinearGradient(colors: [d.c, const Color(0xFF05070D)], begin: Alignment.topLeft, end: Alignment.bottomRight)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Center(child: _miniDesign(d))), Text(d.name, style: TextStyle(fontSize: 9, letterSpacing: 1.3, color: d.a, fontWeight: FontWeight.bold)), const SizedBox(height: 3), Text(d.subtitle, style: const TextStyle(fontSize: 8, color: Colors.white38))])));

  Widget _home() => Scaffold(body: _space(child: SafeArea(child: Stack(children: [
    Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(18, 10, 18, 0), child: Row(children: [IconButton(onPressed: () => setState(() => drawer = true), icon: const Icon(Icons.menu_rounded)), const Spacer(), Column(children: [const Text('LIFEOZ', style: TextStyle(fontSize: 13, letterSpacing: 5, fontWeight: FontWeight.w700)), Text(name.toUpperCase(), style: TextStyle(fontSize: 7, letterSpacing: 2, color: design.a.withOpacity(.65)))]), const Spacer(), IconButton(onPressed: _listen, icon: Icon(listening ? Icons.graphic_eq : Icons.circle_outlined, color: design.a))])),
      Expanded(child: LayoutBuilder(builder: (_, c) => SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), child: Column(children: [
        SizedBox(height: math.min(290, c.maxHeight * .42), child: Center(child: GestureDetector(onTap: _listen, child: _orb(size: 190)))),
        AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: Text(transcript.isNotEmpty ? transcript : message, key: ValueKey(transcript.isNotEmpty ? transcript : message), textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.white70))),
        const SizedBox(height: 22),
        _coreConstellation(),
        const SizedBox(height: 18),
        _voiceCommand(),
      ]))),
    ]),
    if (drawer) _drawerPanel(),
  ]))));

  Widget _coreConstellation() => SizedBox(height: 185, child: Stack(alignment: Alignment.center, children: [CustomPaint(size: const Size(330, 180), painter: NetworkPainter(a: design.a, b: design.b)), ...List.generate(5, (i) { final angle = -math.pi/2 + i*2*math.pi/5; return Transform.translate(offset: Offset(math.cos(angle)*112, math.sin(angle)*68), child: GestureDetector(onTap: () { setState(() => selectedCore = i); _say(['Money intelligence','Productivity intelligence','Time intelligence','Household intelligence','Goals intelligence'][i]); }, child: _coreNode(cores[i], i))); })]));

  Widget _coreNode(IconData icon, int i) => AnimatedContainer(duration: const Duration(milliseconds: 250), width: 54, height: 54, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF080D15), border: Border.all(color: (selectedCore == i ? design.b : design.a).withOpacity(.8)), boxShadow: [BoxShadow(color: design.a.withOpacity(.16), blurRadius: 20)]), child: Icon(icon, size: 21, color: selectedCore == i ? design.b : design.a));

  Widget _voiceCommand() => _glass(child: Row(children: [Icon(Icons.auto_awesome, color: design.a), const SizedBox(width: 10), Expanded(child: TextField(onSubmitted: _process, style: const TextStyle(fontSize: 13), decoration: const InputDecoration(hintText: 'Ask Yansi anything about your life…', hintStyle: TextStyle(color: Colors.white30), border: InputBorder.none))), IconButton(onPressed: _listen, icon: Icon(Icons.mic_none_rounded, color: design.a))]));

  Widget _drawerPanel() => Positioned.fill(child: GestureDetector(onTap: () => setState(() => drawer = false), child: Container(color: Colors.black.withOpacity(.58), child: Align(alignment: Alignment.centerLeft, child: GestureDetector(onTap: () {}, child: Container(width: 315, height: double.infinity, padding: const EdgeInsets.fromLTRB(22, 58, 22, 24), decoration: BoxDecoration(color: const Color(0xFF070B12), border: Border(right: BorderSide(color: design.a.withOpacity(.2)))), child: ListView(children: [Text('LIFEOZ', style: TextStyle(fontSize: 20, letterSpacing: 5, color: design.a)), const SizedBox(height: 5), Text('CONTROL SPACE', style: TextStyle(fontSize: 8, letterSpacing: 2, color: Colors.white30)), const SizedBox(height: 34), _menu('DESIGN REALITY', Icons.blur_on_rounded, () => _showDesigns()), _menu('PROFILE & IDENTITY', Icons.person_outline_rounded, () => _showProfile()), _menu('PERMISSIONS', Icons.shield_outlined, () => _showPermissions()), _menu('YANSI', Icons.auto_awesome_rounded, () => _say('I am Yansi. I connect the information you allow me to access and turn it into useful intelligence.')), const SizedBox(height: 24), Text('DATA CONTROL', style: TextStyle(fontSize: 8, letterSpacing: 2, color: Colors.white24)), const SizedBox(height: 10), Text('Your LifeOS memory is governed by your permission settings. There is no destructive learning-reset control on the main interface.', style: const TextStyle(fontSize: 11, height: 1.5, color: Colors.white38))]))))));

  Widget _menu(String text, IconData icon, VoidCallback fn) => ListTile(contentPadding: EdgeInsets.zero, leading: Icon(icon, color: design.a, size: 20), title: Text(text, style: const TextStyle(fontSize: 11, letterSpacing: 1)), onTap: fn);

  void _showDesigns() => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: const Color(0xFF05080E), builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('CHOOSE YOUR REALITY', style: TextStyle(fontSize: 18, letterSpacing: 2, color: design.a)), const SizedBox(height: 16), SizedBox(height: 180, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: designs.length, separatorBuilder: (_,__) => const SizedBox(width: 12), itemBuilder: (_, i) => _designCard(designs[i])))]))));

  void _showProfile() => _infoSheet('PROFILE & IDENTITY', ['Name: $name', 'Location: $country', 'Currency: $currency']);
  void _showPermissions() => _infoSheet('PERMISSIONS', ['Voice: available when microphone permission is granted', 'Personal learning: controlled by LifeOS', 'Background AI: permission controlled', 'Sensitive actions: confirmation required']);
  void _infoSheet(String title, List<String> rows) => showModalBottomSheet(context: context, backgroundColor: const Color(0xFF070B12), builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: design.a, fontSize: 17, letterSpacing: 2)), const SizedBox(height: 18), ...rows.map((x) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(x, style: const TextStyle(color: Colors.white70))))]))));

  Widget _space({required Widget child}) => AnimatedBuilder(animation: anim, builder: (_, __) => Container(decoration: BoxDecoration(gradient: RadialGradient(center: Alignment(0, -.15), radius: 1.2, colors: [design.c, const Color(0xFF02040A), const Color(0xFF010207)])), child: CustomPaint(painter: StarPainter(t: anim.value, a: design.a, b: design.b), child: child)));
  Widget _glass({required Widget child}) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(.035), borderRadius: BorderRadius.circular(20), border: Border.all(color: design.a.withOpacity(.14)), boxShadow: [BoxShadow(color: design.a.withOpacity(.035), blurRadius: 30)]), child: child);
  Widget _primaryButton(String text, VoidCallback fn) => SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: fn, style: FilledButton.styleFrom(backgroundColor: design.a, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: Text(text, style: const TextStyle(fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold))));
  Widget _orb({required double size}) => AnimatedBuilder(animation: anim, builder: (_, __) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Colors.white.withOpacity(.9), design.a.withOpacity(.65), design.b.withOpacity(.12), Colors.transparent]), boxShadow: [BoxShadow(color: design.a.withOpacity(.35), blurRadius: 50 + 15*math.sin(anim.value*math.pi*2).abs())]), child: CustomPaint(painter: OrbPainter(t: anim.value, a: design.a, b: design.b))));
  Widget _miniDesign(DesignProfile d) => Container(width: 58, height: 58, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [d.a, d.b.withOpacity(.25), Colors.transparent]), boxShadow: [BoxShadow(color: d.a.withOpacity(.35), blurRadius: 18)]));
  void _showDesignsNoop() {}
}

class StarPainter extends CustomPainter { final double t; final Color a,b; StarPainter({required this.t,required this.a,required this.b}); @override void paint(Canvas c, Size s) { final p=Paint(); for(int i=0;i<42;i++){ final x=(i*83.7)%s.width; final y=((i*47.3)+(t*18*(i%3)))%s.height; p.color=(i%2==0?a:b).withOpacity(.08+(i%5)*.01); c.drawCircle(Offset(x,y), .7+(i%3)*.45,p); } } @override bool shouldRepaint(covariant StarPainter o)=>o.t!=t; }
class OrbPainter extends CustomPainter { final double t; final Color a,b; OrbPainter({required this.t,required this.a,required this.b}); @override void paint(Canvas c,Size s){ final p=Paint()..style=PaintingStyle.stroke..strokeWidth=1; final r=s.width/2; for(int k=0;k<5;k++){ p.color=(k%2==0?a:b).withOpacity(.18); final rr=r*.35+k*r*.065; c.drawOval(Rect.fromCenter(center:Offset(s.width/2,s.height/2),width:rr*2,height:rr*1.25),p); } for(int i=0;i<18;i++){ final ang=t*math.pi*2+i*math.pi/9; final q=Offset(s.width/2+math.cos(ang)*r*.62,s.height/2+math.sin(ang)*r*.62); p.color=(i%2==0?a:b).withOpacity(.55); c.drawCircle(q,1.2,p); } } @override bool shouldRepaint(covariant OrbPainter o)=>o.t!=t; }
class NetworkPainter extends CustomPainter { final Color a,b; NetworkPainter({required this.a,required this.b}); @override void paint(Canvas c,Size s){ final p=Paint()..style=PaintingStyle.stroke..strokeWidth=1; final center=Offset(s.width/2,s.height/2); for(int i=0;i<5;i++){final an=-math.pi/2+i*2*math.pi/5;final q=Offset(center.dx+math.cos(an)*112,center.dy+math.sin(an)*68);p.color=(i.isEven?a:b).withOpacity(.25);c.drawLine(center,q,p);} } @override bool shouldRepaint(covariant NetworkPainter o)=>false; }
