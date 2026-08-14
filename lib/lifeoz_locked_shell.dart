import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'services/yansi_brain.dart';

class _Design {
  final String id, name, meaning;
  final Color a, b;
  const _Design(this.id, this.name, this.meaning, this.a, this.b);
}

class LifeOZLockedShell extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZLockedShell({super.key, required this.prefs});
  @override
  State<LifeOZLockedShell> createState() => _LifeOZLockedShellState();
}

class _LifeOZLockedShellState extends State<LifeOZLockedShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final YansiBrain _brain;
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _text = TextEditingController();

  static const designs = <_Design>[
    _Design('neural_void', 'NEURAL VOID', 'Living neural space', Color(0xFF00F0FF), Color(0xFF00FF9D)),
    _Design('quantum_glass', 'QUANTUM GLASS', 'Transparent intelligence', Color(0xFFB48CFF), Color(0xFF44E7FF)),
    _Design('holo_prism', 'HOLO PRISM', 'Volumetric cognition', Color(0xFFFF4FD8), Color(0xFF52F7FF)),
    _Design('aurora_intelligence', 'AURORA', 'Adaptive intelligence field', Color(0xFFB4FF58), Color(0xFF00E5FF)),
    _Design('singularity', 'SINGULARITY', 'Deep-space minimalism', Color(0xFFEAF8FF), Color(0xFF4DE7FF)),
  ];
  static const coreIcons = <IconData>[
    Icons.account_balance_wallet_outlined,
    Icons.bolt_outlined,
    Icons.schedule_outlined,
    Icons.home_work_outlined,
    Icons.track_changes_outlined,
  ];
  static const coreVoice = <String>[
    'Money, income, bills and investments.',
    'Work, tasks and execution.',
    'Calendar, renewals and commitments.',
    'Home, shopping and household.',
    'Goals, diary and personal growth.',
  ];

  String _country = 'India', _currency = 'INR', _language = 'English';
  String _design = 'neural_void', _message = 'Yansi is present.';
  String _transcript = '';
  bool _onboarding = true, _listening = false, _speaking = false, _settings = false;
  int _core = -1;

  _Design get d => designs.firstWhere((x) => x.id == _design, orElse: () => designs.first);

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat();
    _brain = YansiBrain(prefs: widget.prefs);
    _name.text = widget.prefs.getString('user_name') ?? '';
    _country = widget.prefs.getString('user_country') ?? 'India';
    _currency = widget.prefs.getString('user_currency') ?? 'INR';
    _language = widget.prefs.getString('user_language') ?? 'English';
    _design = widget.prefs.getString('lifeoz_reality') ?? designs.first.id;
    _onboarding = widget.prefs.getBool('lifeoz_master_ready') != true;
    _tts.setSpeechRate(0.44);
    _tts.setStartHandler(() { if (mounted) setState(() => _speaking = true); });
    _tts.setCompletionHandler(() { if (mounted) setState(() => _speaking = false); });
  }

  @override
  void dispose() {
    _pulse.dispose(); _tts.stop(); _speech.stop(); _name.dispose(); _text.dispose();
    super.dispose();
  }

  Future<void> _speak(String value) async {
    if (value.trim().isEmpty) return;
    await _speech.stop(); await _tts.stop(); await _tts.speak(value);
  }

  Future<void> _process(String value) async {
    final clean = value.trim();
    if (clean.isEmpty) return;
    await _speech.stop();
    setState(() { _listening = false; _message = 'Thinking…'; });
    try {
      final result = await _brain.process(clean);
      if (!mounted) return;
      setState(() { _message = result.response; _transcript = ''; });
      await _speak(result.response);
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = 'I heard you. I need a moment to complete that safely.');
      await _speak(_message);
    }
  }

  Future<void> _listen() async {
    if (_listening) { await _speech.stop(); setState(() => _listening = false); return; }
    final ok = await _speech.initialize(
      onStatus: (s) { if ((s == 'done' || s == 'notListening') && mounted) setState(() => _listening = false); },
      onError: (_) { if (mounted) setState(() => _listening = false); },
    );
    if (!ok) { _snack('Allow microphone access for Yansi.'); return; }
    setState(() { _listening = true; _transcript = ''; });
    await _speech.listen(onResult: (r) {
      if (!mounted) return;
      setState(() => _transcript = r.recognizedWords);
      if (r.finalResult && r.recognizedWords.trim().isNotEmpty) _process(r.recognizedWords);
    });
  }

  Future<void> _enter() async {
    if (_name.text.trim().isEmpty) { _snack('Enter your name first.'); return; }
    await widget.prefs.setString('user_name', _name.text.trim());
    await widget.prefs.setString('user_country', _country);
    await widget.prefs.setString('user_currency', _currency);
    await widget.prefs.setString('user_language', _language);
    await widget.prefs.setString('lifeoz_reality', _design);
    await widget.prefs.setBool('lifeoz_master_ready', true);
    setState(() => _onboarding = false);
    await _speak('Welcome, ${_name.text.trim()}. I am Yansi. I am here when you need me.');
  }

  void _snack(String value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _pulse,
    builder: (_, __) => Scaffold(backgroundColor: const Color(0xFF01050A), body: SafeArea(child: _onboarding ? _setup() : _home())),
  );

  Widget _setup() => Stack(children: [
    _fieldBackground(),
    SingleChildScrollView(padding: const EdgeInsets.fromLTRB(22, 28, 22, 36), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _logo(), const SizedBox(height: 30),
      const Text('LIFEOZ', style: TextStyle(fontSize: 12, color: Colors.white54, letterSpacing: 5, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('YOUR LIFE.\nONE INTELLIGENCE.', style: TextStyle(fontSize: 34, height: .98, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: -1.2)),
      const SizedBox(height: 10),
      Text('Create your personal environment for Yansi.', style: TextStyle(color: Colors.white.withValues(alpha: .62))),
      const SizedBox(height: 24),
      _input('YOUR NAME', _name, 'Name'),
      const SizedBox(height: 12),
      _drop('LOCATION', _country, ['India','United States','United Kingdom','UAE','Singapore','Other'], (v) => setState(() => _country = v!)),
      const SizedBox(height: 12),
      _drop('CURRENCY', _currency, ['INR','USD','GBP','AED','SGD','EUR'], (v) => setState(() => _currency = v!)),
      const SizedBox(height: 12),
      _drop('LANGUAGE', _language, ['English','Hindi','Gujarati'], (v) => setState(() => _language = v!)),
      const SizedBox(height: 24),
      Text('SELECT ONE OF FIVE WORLDS', style: TextStyle(color: d.a, letterSpacing: 2, fontSize: 11, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      SizedBox(height: 142, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: designs.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => _designCard(designs[i]))),
      const SizedBox(height: 22),
      SizedBox(width: double.infinity, height: 56, child: FilledButton(onPressed: _enter, style: FilledButton.styleFrom(backgroundColor: d.a, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: const Text('ENTER LIFEOZ', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)))),
    ])),
  ]);

  Widget _home() => Stack(children: [
    _fieldBackground(),
    Positioned(top: 18, left: 20, right: 20, child: Row(children: [_logo(), const Spacer(), GestureDetector(onTap: () => setState(() => _settings = !_settings), child: _orbButton(Icons.tune_rounded))])),
    Positioned.fill(top: 72, child: Column(children: [
      const Spacer(), _yansiOrb(), const SizedBox(height: 14),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 30), child: Text(_message, textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: .82), fontSize: 15, height: 1.35))),
      if (_transcript.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8, left: 28, right: 28), child: Text(_transcript, textAlign: TextAlign.center, style: TextStyle(color: d.a, fontSize: 13))),
      const SizedBox(height: 14), _cores(), const SizedBox(height: 14), _voice(), const Spacer(),
    ])),
    if (_settings) Positioned(left: 18, right: 18, bottom: 84, child: _settingsPanel()),
  ]);

  Widget _logo() => Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: d.a, width: 1.5), boxShadow: [BoxShadow(color: d.a.withValues(alpha: .4), blurRadius: 16)]), child: Icon(Icons.all_inclusive_rounded, color: d.a)), const SizedBox(width: 9), const Text('LIFEOZ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2.7))]);
  Widget _orbButton(IconData icon) => Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .05), border: Border.all(color: d.a.withValues(alpha: .45))), child: Icon(icon, color: d.a));
  Widget _yansiOrb() => AnimatedContainer(duration: const Duration(milliseconds: 280), width: _listening || _speaking ? 196 : 166, height: _listening || _speaking ? 196 : 166, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [d.a.withValues(alpha: .46), d.b.withValues(alpha: .14), Colors.transparent]), boxShadow: [BoxShadow(color: d.a.withValues(alpha: .34), blurRadius: 52, spreadRadius: 3)]), child: Center(child: Container(width: 86, height: 86, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: d.a, width: 1.5), gradient: RadialGradient(colors: [Colors.white.withValues(alpha: .18), d.a.withValues(alpha: .08), Colors.transparent])), child: Icon(_listening ? Icons.graphic_eq_rounded : Icons.auto_awesome_rounded, color: Colors.white, size: 34))));
  Widget _cores() => SizedBox(height: 62, child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(5, (i) => GestureDetector(onTap: () { setState(() => _core = i); _speak(coreVoice[i]); }, child: Container(width: 50, height: 50, decoration: BoxDecoration(shape: BoxShape.circle, color: (_core == i ? d.a : Colors.white).withValues(alpha: _core == i ? .15 : .035), border: Border.all(color: (_core == i ? d.a : Colors.white).withValues(alpha: .3))), child: Icon(coreIcons[i], color: _core == i ? d.a : Colors.white70, size: 22))))));
  Widget _voice() => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(children: [Expanded(child: TextField(controller: _text, onSubmitted: _process, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Talk to Yansi…', hintStyle: const TextStyle(color: Colors.white30), filled: true, fillColor: Colors.white.withValues(alpha: .045), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: d.a.withValues(alpha: .22))))),), const SizedBox(width: 8), GestureDetector(onTap: _listen, child: _orbButton(_listening ? Icons.stop_rounded : Icons.mic_none_rounded))]));
  Widget _settingsPanel() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF08111B), borderRadius: BorderRadius.circular(22), border: Border.all(color: d.a.withValues(alpha: .3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('PERSONAL ENVIRONMENT', style: TextStyle(color: d.a, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w800)), const SizedBox(height: 12), Wrap(spacing: 7, runSpacing: 7, children: designs.map((x) => ChoiceChip(label: Text(x.name), selected: x.id == _design, onSelected: (_) { setState(() => _design = x.id); widget.prefs.setString('lifeoz_reality', x.id); }, selectedColor: x.a.withValues(alpha: .22), labelStyle: TextStyle(color: x.id == _design ? x.a : Colors.white70))).toList()), const SizedBox(height: 12), Text('${_name.text} • $_country • $_currency • $_language', style: const TextStyle(color: Colors.white54, fontSize: 12))]));

  Widget _input(String label, TextEditingController c, String hint) => TextField(controller: c, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, hintText: hint, labelStyle: TextStyle(color: d.a), hintStyle: const TextStyle(color: Colors.white30), filled: true, fillColor: Colors.white.withValues(alpha: .04), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: d.a.withValues(alpha: .2)))));
  Widget _drop(String label, String value, List<String> values, ValueChanged<String?> change) => DropdownButtonFormField<String>(initialValue: value, dropdownColor: const Color(0xFF0B1420), style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: TextStyle(color: d.a), filled: true, fillColor: Colors.white.withValues(alpha: .04), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: d.a.withValues(alpha: .2)))), items: values.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: change);
  Widget _designCard(_Design x) => GestureDetector(onTap: () { setState(() => _design = x.id); widget.prefs.setString('lifeoz_reality', x.id); }, child: Container(width: 188, padding: const EdgeInsets.all(14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(21), gradient: LinearGradient(colors: [x.a.withValues(alpha: .17), x.b.withValues(alpha: .04)]), border: Border.all(color: x.id == _design ? x.a : x.a.withValues(alpha: .2), width: x.id == _design ? 1.5 : 1)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: x.a)), child: Icon(Icons.auto_awesome_rounded, color: x.a, size: 18)), const Spacer(), Text(x.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)), const SizedBox(height: 4), Text(x.meaning, style: const TextStyle(color: Colors.white54, fontSize: 11))]));

  Widget _fieldBackground() => CustomPaint(painter: _FieldPainter(_pulse.value, d), child: const SizedBox.expand());
}

class _FieldPainter extends CustomPainter {
  final double t; final _Design d;
  _FieldPainter(this.t, this.d);
  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height * .43);
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 1;
    for (var i = 0; i < 6; i++) { p.color = Color.lerp(d.a, d.b, i / 5)!.withValues(alpha: .06); c.drawCircle(center, 115 + i * 48, p); }
    for (var i = 0; i < 26; i++) { final a = i * 6.28318 / 26 + t * 6.28318 * (i.isEven ? 1 : -1); final r = 105 + (i % 6) * 34; final q = Offset(center.dx + r * 1.0 * (a.cos()), center.dy + r * .55 * (a.sin())); c.drawCircle(q, 1.3, Paint()..color = (i.isEven ? d.a : d.b).withValues(alpha: .22)); }
  }
  @override bool shouldRepaint(covariant _FieldPainter old) => old.t != t || old.d.id != d.id;
}

extension on num { double cos() => __cos(this.toDouble()); double sin() => __sin(this.toDouble()); }
double __cos(double v) => v == v ? _cos(v) : 0;
double __sin(double v) => v == v ? _sin(v) : 0;
