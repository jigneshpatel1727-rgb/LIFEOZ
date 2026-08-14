import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'services/yansi_brain.dart';

class _Reality {
  final String id, name, meaning;
  final Color a, b;
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

  String _name = '';
  String _country = 'India';
  String _currency = 'INR';
  String _language = 'English';
  String _design = 'neural_void';
  String _message = '';
  String _transcript = '';
  bool _onboarding = true;
  bool _listening = false;
  bool _speaking = false;
  bool _settings = false;
  bool _ghostStarting = false;
  int _activeCore = -1;

  // LOCKED: exactly five user-selectable visual environments.
  static const List<_Reality> _realities = <_Reality>[
    _Reality('neural_void', 'NEURAL VOID', 'Living neural space', Color(0xFF00F0FF), Color(0xFF00FF9D)),
    _Reality('quantum_glass', 'QUANTUM GLASS', 'Transparent intelligence', Color(0xFFB48CFF), Color(0xFF44E7FF)),
    _Reality('holo_prism', 'HOLO PRISM', 'Volumetric cognition', Color(0xFFFF4FD8), Color(0xFF52F7FF)),
    _Reality('aurora_intelligence', 'AURORA', 'Adaptive intelligence field', Color(0xFFB4FF58), Color(0xFF00E5FF)),
    _Reality('singularity', 'SINGULARITY', 'Deep-space minimalism', Color(0xFFEAF8FF), Color(0xFF4DE7FF)),
  ];

  static const List<IconData> _coreIcons = <IconData>[
    Icons.account_balance_wallet_outlined,
    Icons.bolt_outlined,
    Icons.schedule_outlined,
    Icons.home_work_outlined,
    Icons.track_changes_outlined,
  ];

  static const List<String> _coreMeanings = <String>[
    'Money, income, bills and investments.',
    'Work, tasks and execution.',
    'Calendar, renewals and commitments.',
    'Home, shopping and household.',
    'Goals, diary and personal growth.',
  ];

  _Reality get _reality => _realities.firstWhere(
        (r) => r.id == _design,
        orElse: () => _realities.first,
      );

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _brain = YansiBrain(prefs: widget.prefs);
    _name = widget.prefs.getString('user_name') ?? '';
    _country = widget.prefs.getString('user_country') ?? 'India';
    _currency = widget.prefs.getString('user_currency') ?? 'INR';
    _language = widget.prefs.getString('user_language') ?? 'English';
    final savedDesign = widget.prefs.getString('lifeoz_reality') ?? 'neural_void';
    _design = _realities.any((r) => r.id == savedDesign) ? savedDesign : 'neural_void';
    _onboarding = widget.prefs.getBool('lifeoz_master_ready') != true;
    _tts.setSpeechRate(0.44);
    _tts.setStartHandler(() {
      if (mounted) setState(() => _speaking = true);
    });
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
      if (!_onboarding) _startGhostListening();
    });
    if (!_onboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startGhostListening());
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    await _speech.stop();
    await _tts.stop();
    await _tts.speak(text);
  }

  // Yansi has no visible microphone, chat box, orb or activation control.
  // The voice layer is intentionally ambient; Android permission remains the gate.
  Future<void> _startGhostListening() async {
    if (_onboarding || _listening || _speaking || _ghostStarting) return;
    _ghostStarting = true;
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _listening = false);
            if (!_onboarding && !_speaking) {
              Future<void>.delayed(const Duration(milliseconds: 350), _startGhostListening);
            }
          }
        },
        onError: (_) {
          if (mounted) setState(() => _listening = false);
        },
      );
      if (!available) return;
      if (!mounted) return;
      setState(() => _listening = true);
      await _speech.listen(
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
        ),
        onResult: (result) {
          if (!mounted) return;
          setState(() => _transcript = result.recognizedWords);
          if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
            _process(result.recognizedWords);
          }
        },
      );
    } finally {
      _ghostStarting = false;
    }
  }

  Future<void> _process(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    await _speech.stop();
    if (mounted) {
      setState(() {
        _listening = false;
        _message = 'Thinking…';
        _transcript = '';
      });
    }
    try {
      final result = await _brain.process(clean);
      if (!mounted) return;
      setState(() => _message = result.response);
      await _speak(result.response);
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = 'I heard you. I need a moment to complete that safely.');
      await _speak(_message);
    }
  }

  Future<void> _enter() async {
    if (_name.trim().isEmpty) {
      _toast('Enter your name first.');
      return;
    }
    await widget.prefs.setString('user_name', _name.trim());
    await widget.prefs.setString('user_country', _country);
    await widget.prefs.setString('user_currency', _currency);
    await widget.prefs.setString('user_language', _language);
    await widget.prefs.setString('lifeoz_reality', _design);
    await widget.prefs.setBool('lifeoz_master_ready', true);
    if (!mounted) return;
    setState(() => _onboarding = false);
    await _speak('Welcome, $_name. I am here whenever you need me.');
  }

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _chooseReality(String id) {
    if (!_realities.any((r) => r.id == id)) return;
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
      SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _brand(),
            const SizedBox(height: 28),
            const Text(
              'YOUR LIFE.\nONE INTELLIGENCE.',
              style: TextStyle(fontSize: 32, height: .98, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1.2),
            ),
            const SizedBox(height: 10),
            Text('Create your personal environment.', style: TextStyle(color: Colors.white.withValues(alpha: .62), fontSize: 15)),
            const SizedBox(height: 26),
            _field('IDENTITY', _name, (v) => _name = v, 'Your name'),
            const SizedBox(height: 12),
            _selector('LOCATION', _country, ['India', 'United States', 'United Kingdom', 'UAE', 'Singapore', 'Other'], (v) => setState(() => _country = v!)),
            const SizedBox(height: 12),
            _selector('CURRENCY', _currency, ['INR', 'USD', 'GBP', 'AED', 'SGD', 'EUR'], (v) => setState(() => _currency = v!)),
            const SizedBox(height: 12),
            _selector('LANGUAGE', _language, ['English', 'Hindi', 'Gujarati'], (v) => setState(() => _language = v!)),
            const SizedBox(height: 22),
            Text('SELECT ONE OF FIVE FINAL DESIGNS', style: TextStyle(color: _reality.a, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _realities.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => _realityCard(_realities[i]),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _enter,
                style: FilledButton.styleFrom(backgroundColor: _reality.a, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                child: const Text('ENTER LIFEOZ', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.4)),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildHome() {
    return Stack(children: [
      _background(),
      Positioned(top: 18, left: 20, right: 20, child: Row(children: [_brand(), const Spacer(), _environmentButton()])),
      Positioned.fill(
        top: 80,
        child: Column(
          children: [
            const Spacer(flex: 3),
            // No visible Yansi. This is deliberately an empty intelligence field.
            SizedBox(
              height: 170,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _message.isEmpty ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 350),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 38),
                    child: Text(_message, textAlign: TextAlign.center, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: .84), fontSize: 15, height: 1.35)),
                  ),
                ),
              ),
            ),
            if (_transcript.isNotEmpty)
              Padding(padding: const EdgeInsets.symmetric(horizontal: 34), child: Text(_transcript, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: _reality.a.withValues(alpha: .75), fontSize: 12))),
            const SizedBox(height: 18),
            _coreRing(),
            const Spacer(flex: 2),
          ],
        ),
      ),
      if (_settings) Positioned(left: 20, right: 20, bottom: 26, child: _controlPanel()),
    ]);
  }

  Widget _brand() => Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _reality.a, width: 1.5), boxShadow: [BoxShadow(color: _reality.a.withValues(alpha: .35), blurRadius: 15)]), child: Icon(Icons.all_inclusive_rounded, color: _reality.a, size: 23)),
        const SizedBox(width: 9),
        const Text('LIFEOZ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2.8)),
      ]);

  Widget _environmentButton() => GestureDetector(
        onTap: () => setState(() => _settings = !_settings),
        child: Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .035), border: Border.all(color: _reality.a.withValues(alpha: .45))), child: Icon(Icons.tune_rounded, color: _reality.a)),
      );

  Widget _background() => Positioned.fill(child: CustomPaint(painter: _FuturePainter(_motion.value, _reality)));

  Widget _coreRing() => SizedBox(
        height: 82,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) => GestureDetector(
                onTap: () {
                  setState(() => _activeCore = i);
                  _speak(_coreMeanings[i]);
                },
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: (_activeCore == i ? _reality.a : Colors.white).withValues(alpha: _activeCore == i ? .15 : .035), border: Border.all(color: (_activeCore == i ? _reality.a : Colors.white).withValues(alpha: .3))),
                  child: Icon(_coreIcons[i], color: _activeCore == i ? _reality.a : Colors.white.withValues(alpha: .72), size: 25),
                ),
              )),
        ),
      );

  Widget _controlPanel() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF08101A).withValues(alpha: .96), borderRadius: BorderRadius.circular(24), border: Border.all(color: _reality.a.withValues(alpha: .28))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PERSONAL ENVIRONMENT', style: TextStyle(color: _reality.a, letterSpacing: 2, fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: _realities.map((r) => ChoiceChip(label: Text(r.name), selected: r.id == _design, onSelected: (_) => _chooseReality(r.id), selectedColor: r.a.withValues(alpha: .25), labelStyle: TextStyle(color: r.id == _design ? r.a : Colors.white70))).toList()),
        ]),
      );

  Widget _field(String label, String value, ValueChanged<String> onChanged, String hint) => TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: _decoration(label, hint),
      );

  InputDecoration _decoration(String label, String hint) => InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: _reality.a),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: .35)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: .04),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _reality.a.withValues(alpha: .2))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _reality.a.withValues(alpha: .2))),
      );

  Widget _selector(String label, String value, List<String> values, ValueChanged<String?> onChanged) => DropdownButtonFormField<String>(
        initialValue: value,
        dropdownColor: const Color(0xFF0B1420),
        style: const TextStyle(color: Colors.white),
        decoration: _decoration(label, ''),
        items: values.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: onChanged,
      );

  Widget _realityCard(_Reality r) => GestureDetector(
        onTap: () => _chooseReality(r.id),
        child: Container(
          width: 190,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [r.a.withValues(alpha: .16), r.b.withValues(alpha: .04)]), border: Border.all(color: r.id == _design ? r.a : r.a.withValues(alpha: .22), width: r.id == _design ? 1.5 : 1)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: r.a.withValues(alpha: .7))), child: Icon(Icons.auto_awesome_rounded, color: r.a, size: 18)),
            const Spacer(),
            Text(r.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(r.meaning, style: TextStyle(color: Colors.white.withValues(alpha: .5), fontSize: 11)),
          ]),
        ),
      );
}

class _FuturePainter extends CustomPainter {
  final double t;
  final _Reality reality;
  _FuturePainter(this.t, this.reality);

  @override
  void paint(Canvas canvas, Size size) {
    // Ambient LifeOS field: no character, face, orb or visible Yansi.
    final center = Offset(size.width / 2, size.height * .48);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1;
    for (int i = 0; i < 8; i++) {
      paint.color = Color.lerp(reality.a, reality.b, i / 7)!.withValues(alpha: .055);
      final radius = 105 + i * 48 + math.sin(t * math.pi * 2 + i) * 7;
      canvas.drawCircle(center, radius, paint);
    }
    for (int i = 0; i < 34; i++) {
      final angle = i * math.pi * 2 / 34 + t * math.pi * 2 * (i.isEven ? .55 : -.35);
      final radius = 120 + (i % 8) * 38;
      final p = Offset(center.dx + math.cos(angle) * radius, center.dy + math.sin(angle) * radius * .62);
      final dot = Paint()..color = (i.isEven ? reality.a : reality.b).withValues(alpha: .18);
      canvas.drawCircle(p, 1.0 + (i % 3) * .55, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _FuturePainter oldDelegate) => oldDelegate.t != t || oldDelegate.reality.id != reality.id;
}
