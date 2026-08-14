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
  late final AnimationController _motion;
  late final YansiBrain _brain;
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _input = TextEditingController();

  String _name = '';
  String _country = 'India';
  String _currency = 'INR';
  String _language = 'English';
  String _design = 'neural_void';
  String _message = 'Yansi is present.';
  String _transcript = '';
  bool _onboarding = true;
  bool _listening = false;
  bool _speaking = false;
  bool _controls = false;
  int _activeCore = -1;

  static const realities = <RealityProfile>[
    RealityProfile('neural_void', 'NEURAL VOID', 'Living neural space', Color(0xFF00F0FF), Color(0xFF00FF9D), 0),
    RealityProfile('quantum_glass', 'QUANTUM GLASS', 'Transparent quantum layers', Color(0xFFB48CFF), Color(0xFF44E7FF), 1),
    RealityProfile('holo_prism', 'HOLO PRISM', 'Volumetric light geometry', Color(0xFFFF4FD8), Color(0xFF52F7FF), 2),
    RealityProfile('aurora_intelligence', 'AURORA INTELLIGENCE', 'Organic adaptive field', Color(0xFFB4FF58), Color(0xFF00E5FF), 3),
    RealityProfile('singularity', 'SINGULARITY', 'Deep-space minimalism', Color(0xFFEAF8FF), Color(0xFF4DE7FF), 4),
    RealityProfile('terra_flux', 'TERRA FLUX', 'Bio-energy life topology', Color(0xFFFFB15C), Color(0xFF58FFD2), 5),
  ];

  static const coreMeanings = <String>[
    'Money, income, bills and investments.',
    'Work, tasks and execution.',
    'Calendar, renewals and commitments.',
    'Home, shopping and household.',
    'Goals, diary and personal growth.',
  ];

  RealityProfile get reality => realities.firstWhere((r) => r.id == _design, orElse: () => realities.first);

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
    _brain = YansiBrain(prefs: widget.prefs);
    _name = widget.prefs.getString('user_name') ?? '';
    _country = widget.prefs.getString('user_country') ?? 'India';
    _currency = widget.prefs.getString('user_currency') ?? 'INR';
    _language = widget.prefs.getString('user_language') ?? 'English';
    _design = widget.prefs.getString('lifeoz_reality') ?? widget.prefs.getString('lifeos_design') ?? 'neural_void';
    _onboarding = widget.prefs.getBool('lifeoz_master_ready') != true;
    _configureVoice();
  }

  Future<void> _configureVoice() async {
    await _tts.setSpeechRate(.44);
    _tts.setStartHandler(() { if (mounted) setState(() => _speaking = true); });
    _tts.setCompletionHandler(() { if (mounted) setState(() => _speaking = false); });
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    await _speech.stop();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _listen() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    final available = await _speech.initialize(
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && mounted) {
          setState(() => _listening = false);
        }
      },
      onError: (_) { if (mounted) setState(() => _listening = false); },
    );
    if (!available) {
      _toast('Microphone permission is required for Yansi.');
      return;
    }
    setState(() { _listening = true; _transcript = ''; });
    await _speech.listen(
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      onResult: (result) {
        if (!mounted) return;
        setState(() => _transcript = result.recognizedWords);
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          _process(result.recognizedWords);
        }
      },
    );
  }

  Future<void> _process(String text) async {
    await _speech.stop();
    if (mounted) setState(() => _listening = false);
    final result = await _brain.process(text);
    if (!mounted) return;
    setState(() { _message = result.response; _transcript = ''; });
    await _speak(result.response);
  }

  Future<void> _enter() async {
    if (_name.trim().isEmpty) {
      _toast('Enter your name so Yansi knows who she is assisting.');
      return;
    }
    await widget.prefs.setString('user_name', _name.trim());
    await widget.prefs.setString('user_country', _country);
    await widget.prefs.setString('user_currency', _currency);
    await widget.prefs.setString('user_language', _language);
    await widget.prefs.setString('lifeoz_reality', _design);
    await widget.prefs.setBool('lifeoz_master_ready', true);
    await widget.prefs.setBool('permission_voice', true);
    if (!mounted) return;
    setState(() => _onboarding = false);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    await _speak('Welcome, $_name. I am Yansi. Your life is now connected. Tell me what you need.');
  }

  void _selectReality(String id) {
    setState(() => _design = id);
    widget.prefs.setString('lifeoz_reality', id);
  }

  void _toast(String text) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _motion.dispose();
    _tts.stop();
    _speech.stop();
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010207),
      body: AnimatedBuilder(
        animation: _motion,
        builder: (_, __) => _onboarding ? _buildOnboarding() : _buildHome(),
      ),
    );
  }

  Widget _buildOnboarding() {
    return Stack(children: [
      _environment(),
      SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 30, 22, 28),
          child: Column(children: [
            _brandMark(76),
            const SizedBox(height: 16),
            const Text('LIFEOZ', style: TextStyle(fontSize: 32, letterSpacing: 9, fontWeight: FontWeight.w200)),
            const SizedBox(height: 6),
            Text('A LIFE OPERATING SYSTEM', style: TextStyle(fontSize: 9, letterSpacing: 3.2, color: reality.a.withValues(alpha: .72))),
            const SizedBox(height: 28),
            _glass(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _section('IDENTITY FIELD'),
              TextField(onChanged: (v) => _name = v, style: const TextStyle(fontSize: 18), decoration: _inputDecoration('What should Yansi call you?')),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(child: _selector('LOCATION', _country, ['India','United States','United Kingdom','Canada','Australia','Other'], (v) => setState(() => _country = v))),
                const SizedBox(width: 12),
                Expanded(child: _selector('CURRENCY', _currency, ['INR','USD','GBP','CAD','AUD','EUR'], (v) => setState(() => _currency = v))),
              ]),
              const SizedBox(height: 14),
              _selector('LANGUAGE', _language, ['English','Hindi','Gujarati'], (v) => setState(() => _language = v)),
            ])),
            const SizedBox(height: 14),
            _glass(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _section('CHOOSE YOUR REALITY'),
              const SizedBox(height: 10),
              SizedBox(height: 170, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: realities.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => _realityCard(realities[i]))),
            ])),
            const SizedBox(height: 18),
            _glass(Row(children: [Icon(Icons.graphic_eq_rounded, color: reality.a), const SizedBox(width: 12), Expanded(child: Text('Yansi becomes the ambient intelligence layer of your LifeOS.', style: TextStyle(fontSize: 11, height: 1.45, color: Colors.white.withValues(alpha: .64))))])),
            const SizedBox(height: 22),
            _primary('ENTER THE LIFEOZ FIELD', _enter),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildHome() {
    return Stack(children: [
      _environment(),
      SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
          child: Row(children: [
            _controlNode(),
            const Spacer(),
            Column(children: [
              const Text('LIFEOZ', style: TextStyle(fontSize: 13, letterSpacing: 5, fontWeight: FontWeight.w700)),
              Text(_name.toUpperCase(), style: TextStyle(fontSize: 7, letterSpacing: 2, color: reality.a.withValues(alpha: .6))),
            ]),
            const Spacer(),
            _voiceNode(),
          ]),
        ),
        Expanded(child: LayoutBuilder(builder: (_, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(children: [
            SizedBox(height: math.min(310, constraints.maxHeight * .46), child: Center(child: GestureDetector(onTap: _listen, child: _yansi()))),
            AnimatedSwitcher(duration: const Duration(milliseconds: 260), child: Text(_transcript.isNotEmpty ? _transcript : _message, key: ValueKey(_transcript.isNotEmpty ? _transcript : _message), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.5, color: Colors.white.withValues(alpha: .78)))),
            const SizedBox(height: 12),
            _constellation(),
            const SizedBox(height: 14),
            _commandField(),
          ]),
        ))),
      ])),
      if (_controls) _controlField(),
    ]);
  }

  Widget _environment() => Positioned.fill(child: CustomPaint(painter: EnvironmentPainter(reality, _motion.value)));

  Widget _brandMark(double size) => SizedBox(width: size, height: size, child: CustomPaint(painter: BrandPainter(reality.a, reality.b)));

  Widget _controlNode() => GestureDetector(onTap: () => setState(() => _controls = true), child: Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: reality.a.withValues(alpha: .45)), boxShadow: [BoxShadow(color: reality.a.withValues(alpha: .15), blurRadius: 18)]), child: CustomPaint(painter: ControlPainter(reality.a))));

  Widget _voiceNode() => GestureDetector(onTap: _listen, child: Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: reality.b.withValues(alpha: .5)), boxShadow: [BoxShadow(color: reality.b.withValues(alpha: _listening ? .28 : .12), blurRadius: 18)]), child: Icon(_listening ? Icons.graphic_eq_rounded : Icons.mic_none_rounded, color: reality.b, size: 19)));

  Widget _yansi() => SizedBox(width: 250, height: 250, child: CustomPaint(painter: YansiPainter(reality, _motion.value, _listening, _speaking)));

  Widget _constellation() => SizedBox(width: 350, height: 205, child: Stack(alignment: Alignment.center, children: [
    CustomPaint(size: const Size(340, 205), painter: ConstellationPainter(reality, _motion.value)),
    ...List.generate(5, (i) {
      final angle = -math.pi / 2 + i * 2 * math.pi / 5;
      final offset = Offset(math.cos(angle) * 116, math.sin(angle) * 78);
      return Transform.translate(offset: offset, child: GestureDetector(onTap: () { setState(() => _activeCore = i); _speak(coreMeanings[i]); }, child: _glyph(i, _activeCore == i)));
    }),
    _brandMark(70),
  ]));

  Widget _glyph(int index, bool active) => Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xCC050912), border: Border.all(color: (active ? reality.b : reality.a).withValues(alpha: .72), width: active ? 2 : 1), boxShadow: [BoxShadow(color: reality.a.withValues(alpha: active ? .25 : .09), blurRadius: 24)]), child: CustomPaint(painter: CoreGlyphPainter(index, active ? reality.b : reality.a)));

  Widget _commandField() => _glass(Row(children: [Icon(Icons.auto_awesome_rounded, color: reality.a, size: 19), const SizedBox(width: 10), Expanded(child: TextField(controller: _input, onSubmitted: _process, style: const TextStyle(fontSize: 12), decoration: const InputDecoration(hintText: 'Speak to Yansi…', hintStyle: TextStyle(color: Colors.white30), border: InputBorder.none))), IconButton(onPressed: _listen, icon: Icon(Icons.mic_none_rounded, color: reality.b))]));

  Widget _controlField() => Positioned.fill(child: GestureDetector(onTap: () => setState(() => _controls = false), child: Container(color: Colors.black.withValues(alpha: .72), child: Center(child: GestureDetector(onTap: () {}, child: Container(width: 330, padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: const Color(0xF0070B14), borderRadius: BorderRadius.circular(28), border: Border.all(color: reality.a.withValues(alpha: .25)), boxShadow: [BoxShadow(color: reality.a.withValues(alpha: .12), blurRadius: 50)]), child: Column(mainAxisSize: MainAxisSize.min, children: [
    _brandMark(58), const SizedBox(height: 12), Text('CONTROL FIELD', style: TextStyle(letterSpacing: 3, color: reality.a, fontSize: 13)), const SizedBox(height: 20),
    _controlAction('REALITY', Icons.blur_on_rounded, _showRealities),
    _controlAction('IDENTITY', Icons.person_outline_rounded, () => _showInfo('IDENTITY', ['Name: $_name', 'Location: $_country', 'Currency: $_currency', 'Language: $_language'])),
    _controlAction('PERMISSIONS', Icons.shield_outlined, () => _showInfo('PERMISSIONS', ['Voice: controlled by permission', 'Background AI: controlled', 'Web access: permission controlled'])),
    _controlAction('YANSI', Icons.auto_awesome_rounded, () => _speak('I am Yansi. I connect the information you allow me to access and turn it into useful intelligence.')),
  ])))))));

  Widget _controlAction(String title, IconData icon, VoidCallback fn) => ListTile(onTap: fn, contentPadding: EdgeInsets.zero, leading: Icon(icon, color: reality.a), title: Text(title, style: const TextStyle(fontSize: 11, letterSpacing: 1.8)), trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white30));

  void _showRealities() => showModalBottomSheet(context: context, backgroundColor: const Color(0xFF05080E), isScrollControlled: true, builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('CHOOSE YOUR REALITY', style: TextStyle(color: reality.a, fontSize: 17, letterSpacing: 2)), const SizedBox(height: 14), SizedBox(height: 190, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: realities.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => _realityCard(realities[i])))]))));

  void _showInfo(String title, List<String> lines) => showModalBottomSheet(context: context, backgroundColor: const Color(0xFF060A12), builder: (_) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: reality.a, letterSpacing: 2)), const SizedBox(height: 15), ...lines.map((line) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(line, style: const TextStyle(color: Colors.white70))))]));

  Widget _realityCard(RealityProfile r) => GestureDetector(onTap: () { _selectReality(r.id); Navigator.of(context).maybePop(); }, child: AnimatedContainer(duration: const Duration(milliseconds: 220), width: 155, padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: _design == r.id ? r.a : Colors.white.withValues(alpha: .08), width: _design == r.id ? 1.6 : 1), gradient: LinearGradient(colors: [r.a.withValues(alpha: .14), const Color(0xFF05070D)], begin: Alignment.topLeft, end: Alignment.bottomRight)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Center(child: CustomPaint(size: const Size(78, 78), painter: RealityPreviewPainter(r)))), Text(r.name, style: TextStyle(fontSize: 9, letterSpacing: 1.2, color: r.a, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(r.subtitle, style: const TextStyle(fontSize: 8, color: Colors.white38))])));

  Widget _glass(Widget child) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0x66101824), borderRadius: BorderRadius.circular(22), border: Border.all(color: reality.a.withValues(alpha: .16)), boxShadow: [BoxShadow(color: reality.a.withValues(alpha: .05), blurRadius: 30)]), child: child);

  Widget _section(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 9, letterSpacing: 2, color: Colors.white54)));

  InputDecoration _inputDecoration(String hint) => InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white30), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: reality.a)), border: InputBorder.none);

  Widget _selector(String label, String value, List<String> items, ValueChanged<String> onChanged) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38, letterSpacing: 1.4)), DropdownButton<String>(value: items.contains(value) ? value : items.first, isExpanded: true, underline: const SizedBox(), dropdownColor: const Color(0xFF101620), items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 12)))).toList(), onChanged: (v) { if (v != null) onChanged(v); })]);

  Widget _primary(String text, VoidCallback action) => SizedBox(width: double.infinity, height: 54, child: ElevatedButton(onPressed: action, style: ElevatedButton.styleFrom(backgroundColor: reality.a.withValues(alpha: .12), foregroundColor: reality.a, side: BorderSide(color: reality.a.withValues(alpha: .45)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: Text(text, style: const TextStyle(letterSpacing: 2, fontSize: 11))));
}

class RealityProfile {
  final String id, name, subtitle;
  final Color a, b;
  final int style;
  const RealityProfile(this.id, this.name, this.subtitle, this.a, this.b, this.style);
}

class EnvironmentPainter extends CustomPainter {
  final RealityProfile reality; final double t;
  EnvironmentPainter(this.reality, this.t);
  @override void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final p = Paint()..style = PaintingStyle.fill;
    p.shader = RadialGradient(colors: [reality.a.withValues(alpha: .08), Colors.transparent], stops: const [0, 1]).createShader(Rect.fromCircle(center: center, radius: size.longestSide * .7));
    canvas.drawRect(Offset.zero & size, p);
    final line = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = reality.a.withValues(alpha: .07);
    for (int i = 0; i < 7; i++) { final y = size.height * (.12 + i * .13); canvas.drawLine(Offset(0, y), Offset(size.width, y + math.sin(t * math.pi * 2 + i) * 18), line); }
    for (int i = 0; i < 26; i++) { final x = (math.sin(i * 8.7 + t * math.pi * 2) * .5 + .5) * size.width; final y = (math.cos(i * 4.1 + t * math.pi * 2) * .5 + .5) * size.height; canvas.drawCircle(Offset(x, y), i.isEven ? 1.3 : .8, Paint()..color = (i.isEven ? reality.a : reality.b).withValues(alpha: .18)); }
  }
  @override bool shouldRepaint(covariant EnvironmentPainter old) => true;
}

class BrandPainter extends CustomPainter {
  final Color a, b; BrandPainter(this.a, this.b);
  @override void paint(Canvas c, Size s) { final center = s.center(Offset.zero); final r = s.shortestSide * .33; final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round..shader = LinearGradient(colors: [a,b]).createShader(Offset.zero & s); final path = Path()..moveTo(center.dx-r, center.dy)..cubicTo(center.dx-r*.35, center.dy-r*1.25, center.dx+r*.35, center.dy+r*1.25, center.dx+r, center.dy)..cubicTo(center.dx+r*.35, center.dy-r*1.25, center.dx-r*.35, center.dy+r*1.25, center.dx-r, center.dy); c.drawPath(path,p); c.drawCircle(center,r*.22,Paint()..color=b.withValues(alpha:.9)); }
  @override bool shouldRepaint(covariant BrandPainter old) => false;
}

class ControlPainter extends CustomPainter {
  final Color color; ControlPainter(this.color);
  @override void paint(Canvas c, Size s) { final p=Paint()..style=PaintingStyle.stroke..strokeWidth=2..color=color; final r=s.shortestSide*.28; c.drawCircle(s.center(Offset.zero),r,p); c.drawCircle(s.center(Offset.zero),r*.42,p); for(int i=0;i<4;i++){final a=i*math.pi/2;c.drawLine(s.center(Offset.zero)+Offset(math.cos(a)*r*.95,math.sin(a)*r*.95),s.center(Offset.zero)+Offset(math.cos(a)*r*1.3,math.sin(a)*r*1.3),p);} }
  @override bool shouldRepaint(covariant ControlPainter old) => false;
}

class YansiPainter extends CustomPainter {
  final RealityProfile reality; final double t; final bool listening, speaking;
  YansiPainter(this.reality,this.t,this.listening,this.speaking);
  @override void paint(Canvas c, Size s) { final center=s.center(Offset.zero); final pulse=1+math.sin(t*math.pi*2)*.035; for(int k=0;k<5;k++){final r=(48+k*18)*pulse; final p=Paint()..style=PaintingStyle.stroke..strokeWidth=k==0?2.4:1..color=(k.isEven?reality.a:reality.b).withValues(alpha:(.22-k*.025).clamp(.05,.22)); c.drawCircle(center,r,p);} for(int i=0;i<70;i++){final a=i*math.pi*2/70+t*math.pi*2*(i.isEven?1:-1);final r=52+((i*17)%62);final pos=center+Offset(math.cos(a)*r,math.sin(a)*r*.74); c.drawCircle(pos,i%7==0?2.4:1,Paint()..color=(i.isEven?reality.a:reality.b).withValues(alpha:.42));} final core=Paint()..shader=RadialGradient(colors:[Colors.white.withValues(alpha:.95),reality.a,reality.b.withValues(alpha:.2),Colors.transparent]).createShader(Rect.fromCircle(center:center,radius:54)); c.drawCircle(center,54,core); final ring=Paint()..style=PaintingStyle.stroke..strokeWidth=3..color=(listening?speaking?reality.b:reality.a:reality.a).withValues(alpha:.8); c.drawArc(Rect.fromCircle(center:center,radius:66),t*math.pi*2,math.pi*.95,false,ring); }
  @override bool shouldRepaint(covariant YansiPainter old) => true;
}

class ConstellationPainter extends CustomPainter {
  final RealityProfile reality; final double t;
  ConstellationPainter(this.reality,this.t);
  @override void paint(Canvas c,Size s){final center=s.center(Offset.zero);final p=Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=reality.a.withValues(alpha:.16);for(int i=0;i<5;i++){final a=-math.pi/2+i*2*math.pi/5;final q=center+Offset(math.cos(a)*116,math.sin(a)*78);c.drawLine(center,q,p);}for(int i=0;i<5;i++){final a=-math.pi/2+i*2*math.pi/5;final b=-math.pi/2+((i+1)%5)*2*math.pi/5;c.drawLine(center+Offset(math.cos(a)*116,math.sin(a)*78),center+Offset(math.cos(b)*116,math.sin(b)*78),p);}c.drawCircle(center,46+math.sin(t*math.pi*2)*3,p);}
  @override bool shouldRepaint(covariant ConstellationPainter old)=>true;
}

class CoreGlyphPainter extends CustomPainter {
  final int index; final Color color; CoreGlyphPainter(this.index,this.color);
  @override void paint(Canvas c,Size s){final center=s.center(Offset.zero);final p=Paint()..style=PaintingStyle.stroke..strokeWidth=2..color=color;final r=s.shortestSide*.27;switch(index){case 0:c.drawCircle(center,r,p);c.drawArc(Rect.fromCircle(center:center,radius:r*1.55),-.8,1.6,false,p);break;case 1:c.drawLine(center+Offset(-r,0),center+Offset(r,0),p);c.drawLine(center+Offset(0,-r),center+Offset(0,r),p);c.drawCircle(center,r*.65,p);break;case 2:c.drawCircle(center,r*1.3,p);c.drawLine(center,center+Offset(0,-r*1.3),p);c.drawLine(center,center+Offset(r*.9,r*.7),p);break;case 3:final path=Path()..moveTo(center.dx-r,center.dy+r*.8)..lineTo(center.dx,center.dy-r)..lineTo(center.dx+r,center.dy+r*.8)..close();c.drawPath(path,p);break;default:final path=Path()..moveTo(center.dx-r,center.dy+r)..lineTo(center.dx-r*.2,center.dy)..lineTo(center.dx+r*.2,center.dy+r*.45)..lineTo(center.dx+r,center.dy-r)..;c.drawPath(path,p);}}
  @override bool shouldRepaint(covariant CoreGlyphPainter old)=>false;
}

class RealityPreviewPainter extends CustomPainter {
  final RealityProfile reality; RealityPreviewPainter(this.reality);
  @override void paint(Canvas c,Size s){final center=s.center(Offset.zero);final p=Paint()..style=PaintingStyle.stroke..strokeWidth=2..color=reality.a;for(int i=0;i<4;i++){c.drawCircle(center,12+i*8,p);}c.drawLine(center+const Offset(-30,0),center+const Offset(30,0),p);c.drawLine(center+const Offset(0,-30),center+const Offset(0,30),p);}
  @override bool shouldRepaint(covariant RealityPreviewPainter old)=>false;
}
