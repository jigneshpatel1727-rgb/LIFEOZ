import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'services/yansi_brain.dart';

class _Reality {
  final String id;
  final String name;
  final String meaning;
  final Color a;
  final Color b;
  const _Reality(this.id, this.name, this.meaning, this.a, this.b);
}

class LifeOZFutureShell extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZFutureShell({super.key, required this.prefs});

  @override
  State<LifeOZFutureShell> createState() => _LifeOZFutureShellState();
}

class _LifeOZFutureShellState extends State<LifeOZFutureShell>
    with SingleTickerProviderStateMixin {
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

  static const List<_Reality> _realities = <_Reality>[
    _Reality('neural_void', 'NEURAL VOID', 'Living neural space', Color(0xFF00F0FF), Color(0xFF00FF9D)),
    _Reality('quantum_glass', 'QUANTUM GLASS', 'Transparent quantum layers', Color(0xFFB48CFF), Color(0xFF44E7FF)),
    _Reality('holo_prism', 'HOLO PRISM', 'Volumetric light geometry', Color(0xFFFF4FD8), Color(0xFF52F7FF)),
    _Reality('aurora_intelligence', 'AURORA INTELLIGENCE', 'Organic adaptive field', Color(0xFFB4FF58), Color(0xFF00E5FF)),
    _Reality('singularity', 'SINGULARITY', 'Deep-space minimalism', Color(0xFFEAF8FF), Color(0xFF4DE7FF)),
    _Reality('terra_flux', 'TERRA FLUX', 'Bio-energy life topology', Color(0xFFFFB15C), Color(0xFF58FFD2)),
  ];

  static const List<String> _coreMeanings = <String>[
    'Money, income, bills and investments.',
    'Work, tasks and execution.',
    'Calendar, renewals and commitments.',
    'Home, shopping and household.',
    'Goals, diary and personal growth.',
  ];

  _Reality get _reality => _realities.firstWhere((r) => r.id == _design, orElse: () => _realities.first);

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
    _brain = YansiBrain(prefs: widget.prefs);
    _name = widget.prefs.getString('user_name') ?? '';
    _country = widget.prefs.getString('user_country') ?? 'India';
    _currency = widget.prefs.getString('user_currency') ?? 'INR';
    _language = widget.prefs.getString('user_language') ?? 'English';
    _design = widget.prefs.getString('lifeoz_reality') ?? 'neural_void';
    _onboarding = widget.prefs.getBool('lifeoz_master_ready') != true;
    _tts.setSpeechRate(0.44);
    _tts.setStartHandler(() { if (mounted) setState(() => _speaking = true); });
    _tts.setCompletionHandler(() { if (mounted) setState(() => _speaking = false); });
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    await _speech.stop();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _process(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    await _speech.stop();
    if (mounted) setState(() { _listening = false; _message = 'Thinking...'; });
    final result = await _brain.process(clean);
    if (!mounted) return;
    setState(() { _message = result.response; _transcript = ''; });
    await _speak(result.response);
  }

  Future<void> _listen() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    final available = await _speech.initialize(
      onStatus: (status) { if ((status == 'done' || status == 'notListening') && mounted) setState(() => _listening = false); },
      onError: (_) { if (mounted) setState(() => _listening = false); },
    );
    if (!available) { _toast('Microphone permission is required for Yansi.'); return; }
    setState(() { _listening = true; _transcript = ''; });
    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() => _transcript = result.recognizedWords);
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) _process(result.recognizedWords);
      },
    );
  }

  Future<void> _enter() async {
    if (_name.trim().isEmpty) { _toast('Enter your name so Yansi knows who she is assisting.'); return; }
    await widget.prefs.setString('user_name', _name.trim());
    await widget.prefs.setString('user_country', _country);
    await widget.prefs.setString('user_currency', _currency);
    await widget.prefs.setString('user_language', _language);
    await widget.prefs.setString('lifeoz_reality', _design);
    await widget.prefs.setBool('lifeoz_master_ready', true);
    if (!mounted) return;
    setState(() => _onboarding = false);
    await _speak('Welcome, $_name. I am Yansi. Your life is now connected. Tell me what you need.');
  }

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _chooseReality(String id) {
    setState(() => _design = id);
    widget.prefs.setString('lifeoz_reality', id);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _motion,
      builder: (_, __) => Scaffold(
        backgroundColor: const Color(0xFF02050B),
        body: SafeArea(child: _onboarding ? _buildOnboarding() : _buildHome()),
      ),
    );
  }

  Widget _buildOnboarding() {
    return Stack(children: [
      _background(),
      SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 28, 24, 36), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _brand(), const SizedBox(height: 28),
        Text('YOUR LIFE.\nONE INTELLIGENCE.', style: TextStyle(fontSize: 32, height: .98, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1.2)),
        const SizedBox(height: 10),
        Text('Configure the environment. Yansi will adapt around you.', style: TextStyle(color: Colors.white.withValues(alpha: .62), fontSize: 15)),
        const SizedBox(height: 26),
        _field('IDENTITY', _name, (v) => _name = v, 'Your name'),
        const SizedBox(height: 12),
        _selector('LOCATION', _country, ['India', 'United States', 'United Kingdom', 'UAE', 'Singapore', 'Other'], (v) => setState(() => _country = v!)),
        const SizedBox(height: 12),
        _selector('CURRENCY', _currency, ['INR', 'USD', 'GBP', 'AED', 'SGD', 'EUR'], (v) => setState(() => _currency = v!)),
        const SizedBox(height: 12),
        _selector('LANGUAGE', _language, ['English', 'Hindi', 'Gujarati'], (v) => setState(() => _language = v!)),
        const SizedBox(height: 20),
        Text('CHOOSE YOUR REALITY', style: TextStyle(color: _reality.a, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        SizedBox(height: 150, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _realities.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => _realityCard(_realities[i]))),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 56, child: FilledButton(onPressed: _enter, style: FilledButton.styleFrom(backgroundColor: _reality.a, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: const Text('ENTER LIFEOZ', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.4)))),
      ])),
    ]);
  }

  Widget _buildHome() {
    return Stack(children: [
      _background(),
      Positioned(top: 18, left: 20, right: 20, child: Row(children: [_brand(), const Spacer(), _controlButton()])),
      Positioned.fill(top: 86, child: Column(children: [
        const Spacer(),
        _presence(),
        const SizedBox(height: 16),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: Text(_message, textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: .82), fontSize: 15, height: 1.35))),
        if (_transcript.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10, left: 28, right: 28), child: Text(_transcript, textAlign: TextAlign.center, style: TextStyle(color: _reality.a, fontSize: 13))),
        const SizedBox(height: 18),
        _coreRing(),
        const SizedBox(height: 18),
        _voiceBar(),
        const Spacer(),
      ])),
      if (_controls) Positioned(left: 20, right: 20, bottom: 88, child: _controlPanel()),
    ]);
  }

  Widget _brand() => Row(children: [Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _reality.a, width: 1.5), boxShadow: [BoxShadow(color: _reality.a.withValues(alpha: .4), blurRadius: 14)]), child: Icon(Icons.all_inclusive_rounded, color: _reality.a, size: 21)), const SizedBox(width: 9), const Text('LIFEOZ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2.8))]);

  Widget _controlButton() => GestureDetector(onTap: () => setState(() => _controls = !_controls), child: Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .05), border: Border.all(color: _reality.a.withValues(alpha: .45))), child: Icon(Icons.tune_rounded, color: _reality.a)));

  Widget _background() => Positioned.fill(child: CustomPaint(painter: _FuturePainter(_motion.value, _reality)));

  Widget _presence() => AnimatedContainer(duration: const Duration(milliseconds: 300), width: _speaking || _listening ? 190 : 160, height: _speaking || _listening ? 190 : 160, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [_reality.a.withValues(alpha: .42), _reality.b.withValues(alpha: .13), Colors.transparent]), boxShadow: [BoxShadow(color: _reality.a.withValues(alpha: .35), blurRadius: 50, spreadRadius: 4)]), child: Center(child: Container(width: 86, height: 86, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _reality.a.withValues(alpha: .85), width: 1.5), gradient: RadialGradient(colors: [Colors.white.withValues(alpha: .18), _reality.a.withValues(alpha: .08), Colors.transparent])), child: Icon(_listening ? Icons.graphic_eq_rounded : Icons.auto_awesome_rounded, color: Colors.white, size: 34))));

  Widget _coreRing() => SizedBox(height: 104, child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(5, (i) => GestureDetector(onTap: () { setState(() => _activeCore = i); _speak(_coreMeanings[i]); }, child: Container(width: 54, height: 54, decoration: BoxDecoration(shape: BoxShape.circle, color: (_activeCore == i ? _reality.a : Colors.white).withValues(alpha: _activeCore == i ? .15 : .035), border: Border.all(color: (_activeCore == i ? _reality.a : Colors.white).withValues(alpha: .32))), child: Icon([Icons.account_balance_wallet_outlined, Icons.bolt_outlined, Icons.schedule_outlined, Icons.home_work_outlined, Icons.track_changes_outlined][i], color: _activeCore == i ? _reality.a : Colors.white.withValues(alpha: .72), size: 23))))));

  Widget _voiceBar() => Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: Row(children: [Expanded(child: TextField(controller: _input, onSubmitted: _process, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Talk to Yansi…', hintStyle: TextStyle(color: Colors.white.withValues(alpha: .35)), filled: true, fillColor: Colors.white.withValues(alpha: .045), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: _reality.a.withValues(alpha: .22))))),), const SizedBox(width: 8), GestureDetector(onTap: _listen, child: Container(width: 52, height: 52, decoration: BoxDecoration(shape: BoxShape.circle, color: _listening ? _reality.a : Colors.white.withValues(alpha: .06), border: Border.all(color: _reality.a.withValues(alpha: .55))), child: Icon(_listening ? Icons.stop_rounded : Icons.mic_none_rounded, color: _listening ? Colors.black : _reality.a)))]));

  Widget _controlPanel() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF08101A).withValues(alpha: .94), borderRadius: BorderRadius.circular(24), border: Border.all(color: _reality.a.withValues(alpha: .28))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('REALITY MATRIX', style: TextStyle(color: _reality.a, letterSpacing: 2, fontSize: 11, fontWeight: FontWeight.w800)), const SizedBox(height: 12), Wrap(spacing: 8, runSpacing: 8, children: _realities.map((r) => ChoiceChip(label: Text(r.name), selected: r.id == _design, onSelected: (_) => _chooseReality(r.id), selectedColor: r.a.withValues(alpha: .25), labelStyle: TextStyle(color: r.id == _design ? r.a : Colors.white70))).toList())]));

  Widget _field(String label, String value, ValueChanged<String> onChanged, String hint) => TextField(onChanged: onChanged, controller: TextEditingController(text: value), style: const TextStyle(color: Colors.white), decoration: _decoration(label, hint));

  InputDecoration _decoration(String label, String hint) => InputDecoration(labelText: label, hintText: hint, labelStyle: TextStyle(color: _reality.a), hintStyle: TextStyle(color: Colors.white.withValues(alpha: .35)), filled: true, fillColor: Colors.white.withValues(alpha: .04), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _reality.a.withValues(alpha: .2))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _reality.a.withValues(alpha: .2))));

  Widget _selector(String label, String value, List<String> values, ValueChanged<String?> onChanged) => DropdownButtonFormField<String>(initialValue: value, dropdownColor: const Color(0xFF0B1420), style: const TextStyle(color: Colors.white), decoration: _decoration(label, ''), items: values.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: onChanged);

  Widget _realityCard(_Reality r) => GestureDetector(onTap: () => _chooseReality(r.id), child: Container(width: 190, padding: const EdgeInsets.all(15), decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [r.a.withValues(alpha: .16), r.b.withValues(alpha: .04)]), border: Border.all(color: r.id == _design ? r.a : r.a.withValues(alpha: .22), width: r.id == _design ? 1.5 : 1)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: r.a.withValues(alpha: .7))), child: Icon(Icons.auto_awesome_rounded, color: r.a, size: 18)), const Spacer(), Text(r.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)), const SizedBox(height: 4), Text(r.meaning, style: TextStyle(color: Colors.white.withValues(alpha: .5), fontSize: 11))])));
}

class _FuturePainter extends CustomPainter {
  final double t;
  final _Reality reality;
  _FuturePainter(this.t, this.reality);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .43);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1;
    for (int i = 0; i < 7; i++) {
      paint.color = Color.lerp(reality.a, reality.b, i / 6)!.withValues(alpha: .07);
      final radius = 110 + i * 45 + math.sin(t * math.pi * 2 + i) * 8;
      canvas.drawCircle(center, radius, paint);
    }
    for (int i = 0; i < 28; i++) {
      final angle = i * math.pi * 2 / 28 + t * math.pi * 2 * (i.isEven ? 1 : -1);
      final radius = 95 + (i % 7) * 32;
      final p = Offset(center.dx + math.cos(angle) * radius, center.dy + math.sin(angle) * radius * .58);
      final dot = Paint()..color = (i.isEven ? reality.a : reality.b).withValues(alpha: .24);
      canvas.drawCircle(p, 1.2 + (i % 3) * .7, dot);
    }
  }
  @override
  bool shouldRepaint(covariant _FuturePainter oldDelegate) => oldDelegate.t != t || oldDelegate.reality.id != reality.id;
}
