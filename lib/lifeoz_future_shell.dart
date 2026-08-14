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

  static const List<_Reality> _realities = <_Reality>[
    _Reality('neural_void', 'NEURAL VOID', 'Living neural space', Color(0xFF00F0FF), Color(0xFF00FF9D)),
    _Reality('quantum_glass', 'QUANTUM GLASS', 'Transparent intelligence', Color(0xFFB48CFF), Color(0xFF44E7FF)),
    _Reality('holo_prism', 'HOLO PRISM', 'Volumetric cognition', Color(0xFFFF4FD8), Color(0xFF52F7FF)),
    _Reality('aurora_intelligence', 'AURORA', 'Adaptive intelligence field', Color(0xFFB4FF58), Color(0xFF00E5FF)),
    _Reality('singularity', 'SINGULARITY', 'Deep-space minimalism', Color(0xFFEAF8FF), Color(0xFF4DE7FF)),
  ];

  // The five locked LifeOS cores. Names stay hidden on the home screen.
  static const List<IconData> _coreIcons = <IconData>[
    Icons.account_balance_wallet_rounded,
    Icons.bolt_rounded,
    Icons.calendar_month_rounded,
    Icons.home_rounded,
    Icons.track_changes_rounded,
  ];

  static const List<String> _coreMeanings = <String>[
    'Money, income, expenses, bills and investments.',
    'Work, tasks, productivity and execution.',
    'Calendar, renewals, birthdays and important dates.',
    'Home, shopping, kitchen and household needs.',
    'Goals, diary, personal progress and wellbeing.',
  ];

  static const List<String> _coreVoices = <String>[
    'This is your financial intelligence. I can organize expenses, bills, income and investments for you.',
    'This is your execution intelligence. I can organize tasks and help you stay on track.',
    'This is your time intelligence. I can watch dates, renewals, bills and important events.',
    'This is your home intelligence. I can manage shopping and household needs with you.',
    'This is your personal intelligence. I can connect goals, diary and progress into one picture.',
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
      duration: const Duration(seconds: 14),
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
      if (!available || !mounted) return;
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
    await _speak('Welcome, $_name. I am Yansi. I am here whenever you need me.');
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

  void _activateCore(int index) {
    setState(() => _activeCore = index);
    _speak(_coreVoices[index]);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _motion,
      builder: (_, __) => Scaffold(
        backgroundColor: const Color(0xFF01030A),
        body: SafeArea(child: _onboarding ? _buildOnboarding() : _buildHome()),
      ),
    );
  }

  Widget _buildOnboarding() {
    return Stack(
      children: [
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
                  style: FilledButton.styleFrom(
                    backgroundColor: _reality.a,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('ENTER LIFEOZ', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.4)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHome() {
    return Stack(
      children: [
        _background(),
        Positioned(
          top: 14,
          left: 18,
          right: 18,
          child: Row(
            children: [
              _brand(),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _settings = !_settings),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .035),
                    border: Border.all(color: _reality.a.withValues(alpha: .45)),
                    boxShadow: [BoxShadow(color: _reality.a.withValues(alpha: .12), blurRadius: 18)],
                  ),
                  child: Icon(Icons.tune_rounded, color: _reality.a),
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          top: 62,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _LifeNetworkPainter(
                        phase: _motion.value,
                        activeCore: _activeCore,
                        reality: _reality,
                      ),
                    ),
                  ),
                  ..._corePositions(size).asMap().entries.map((entry) {
                    final i = entry.key;
                    final p = entry.value;
                    final nodeSize = i == 0 || i == 1 || i == 2 ? 84.0 : 78.0;
                    return Positioned(
                      left: p.dx - nodeSize / 2,
                      top: p.dy - nodeSize / 2,
                      child: _coreNode(i, nodeSize),
                    );
                  }),
                  Positioned(
                    left: size.width / 2 - 116,
                    top: size.height * .42 - 116,
                    child: _yansiNode(232),
                  ),
                  if (_message.isNotEmpty)
                    Positioned(
                      left: 28,
                      right: 28,
                      bottom: 112,
                      child: AnimatedOpacity(
                        opacity: _message.isEmpty ? 0 : 1,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _message,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withValues(alpha: .84), fontSize: 14, height: 1.3),
                        ),
                      ),
                    ),
                  if (_transcript.isNotEmpty)
                    Positioned(
                      left: 32,
                      right: 32,
                      bottom: 82,
                      child: Text(
                        _transcript,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _reality.a.withValues(alpha: .72), fontSize: 11),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 12,
                    child: _statusLine(),
                  ),
                ],
              );
            },
          ),
        ),
        if (_settings)
          Positioned(
            left: 18,
            right: 18,
            top: 68,
            child: _controlPanel(),
          ),
      ],
    );
  }

  List<Offset> _corePositions(Size size) {
    final w = size.width;
    final h = size.height;
    return <Offset>[
      Offset(w * .24, h * .28),
      Offset(w * .76, h * .28),
      Offset(w * .21, h * .68),
      Offset(w * .79, h * .68),
      Offset(w * .50, h * .14),
    ];
  }

  Widget _yansiNode(double diameter) {
    return GestureDetector(
      onTap: () {
        if (_message.isNotEmpty) _speak(_message);
        else _speak('I am Yansi. Your life is connected here.');
      },
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: CustomPaint(
          painter: _YansiPainter(
            phase: _motion.value,
            primary: _reality.a,
            secondary: _reality.b,
            active: _activeCore >= 0 || _listening || _speaking,
          ),
        ),
      ),
    );
  }

  Widget _coreNode(int index, double size) {
    final selected = _activeCore == index;
    final nodeColors = <List<Color>>[
      [const Color(0xFF00F4FF), const Color(0xFF20FFB0)],
      [const Color(0xFFFFB34A), const Color(0xFFFF5E8A)],
      [const Color(0xFF6C8CFF), const Color(0xFF00F1FF)],
      [const Color(0xFFB84DFF), const Color(0xFFFF5FEA)],
      [const Color(0xFFB9FF55), const Color(0xFF00E5FF)],
    ];
    final colors = nodeColors[index];
    return GestureDetector(
      onTap: () => _activateCore(index),
      child: AnimatedScale(
        scale: selected ? 1.12 : 1.0,
        duration: const Duration(milliseconds: 280),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: colors[0].withValues(alpha: selected ? .40 : .18), blurRadius: selected ? 30 : 18, spreadRadius: selected ? 3 : 0),
              BoxShadow(color: colors[1].withValues(alpha: .10), blurRadius: 42),
            ],
          ),
          child: CustomPaint(
            painter: _CoreNodePainter(
              phase: _motion.value,
              primary: colors[0],
              secondary: colors[1],
              icon: _coreIcons[index],
              selected: selected,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusLine() {
    return Center(
      child: AnimatedOpacity(
        opacity: (_listening || _speaking || _activeCore >= 0) ? 1 : .62,
        duration: const Duration(milliseconds: 250),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: _reality.a, boxShadow: [BoxShadow(color: _reality.a, blurRadius: 8)]),
            ),
            const SizedBox(width: 8),
            Text(
              _listening ? 'YANSI LISTENING' : (_speaking ? 'YANSI SPEAKING' : 'LIVING INTELLIGENCE'),
              style: TextStyle(color: Colors.white.withValues(alpha: .55), fontSize: 9, letterSpacing: 2.1, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _brand() => Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _reality.a, width: 1.5),
              boxShadow: [BoxShadow(color: _reality.a.withValues(alpha: .32), blurRadius: 16)],
            ),
            child: Icon(Icons.all_inclusive_rounded, color: _reality.a, size: 23),
          ),
          const SizedBox(width: 9),
          const Text('LIFEOZ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2.8)),
        ],
      );

  Widget _background() => Positioned.fill(
        child: CustomPaint(
          painter: _FuturePainter(_motion.value, _reality),
        ),
      );

  Widget _controlPanel() => Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF06101A).withValues(alpha: .97),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _reality.a.withValues(alpha: .30)),
            boxShadow: [BoxShadow(color: _reality.a.withValues(alpha: .08), blurRadius: 30)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('PERSONAL ENVIRONMENT', style: TextStyle(color: _reality.a, letterSpacing: 1.8, fontSize: 10, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  GestureDetector(onTap: () => setState(() => _settings = false), child: const Icon(Icons.close_rounded, size: 18, color: Colors.white54)),
                ],
              ),
              const SizedBox(height: 11),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: _realities.map((r) {
                  final selected = r.id == _design;
                  return ChoiceChip(
                    label: Text(r.name),
                    selected: selected,
                    onSelected: (_) => _chooseReality(r.id),
                    selectedColor: r.a.withValues(alpha: .22),
                    labelStyle: TextStyle(color: selected ? r.a : Colors.white70, fontSize: 10),
                    side: BorderSide(color: r.a.withValues(alpha: .20)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );

  Widget _realityCard(_Reality r) => GestureDetector(
        onTap: () => _chooseReality(r.id),
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(colors: [r.a.withValues(alpha: .14), r.b.withValues(alpha: .04)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            border: Border.all(color: r.id == _design ? r.a.withValues(alpha: .70) : Colors.white.withValues(alpha: .10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: CustomPaint(painter: _MiniRealityPainter(r.a, r.b, _motion.value))),
              const SizedBox(height: 6),
              Text(r.name, style: TextStyle(color: r.a, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1.1)),
              const SizedBox(height: 3),
              Text(r.meaning, style: const TextStyle(color: Colors.white54, fontSize: 9)),
            ],
          ),
        ),
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
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: Colors.white.withValues(alpha: .035),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: .08))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: .08))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _reality.a.withValues(alpha: .65))),
      );

  Widget _selector(String label, String value, List<String> values, ValueChanged<String?> onChanged) => DropdownButtonFormField<String>(
        value: value,
        dropdownColor: const Color(0xFF0A141F),
        style: const TextStyle(color: Colors.white),
        decoration: _decoration(label, ''),
        items: values.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: onChanged,
      );
}

class _FuturePainter extends CustomPainter {
  final double phase;
  final _Reality reality;
  _FuturePainter(this.phase, this.reality);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..shader = RadialGradient(colors: [reality.a.withValues(alpha: .055), const Color(0xFF01030A), const Color(0xFF000108)], stops: const [0, .45, 1]).createShader(Offset(size.width * .5, size.height * .48) & size);
    canvas.drawRect(Offset.zero & size, bg);

    final center = Offset(size.width * .5, size.height * .47);
    final maxR = math.max(size.width, size.height) * .72;
    final ring = Paint()..style = PaintingStyle.stroke..strokeWidth = 1;
    for (int i = 0; i < 9; i++) {
      ring.color = reality.a.withValues(alpha: .035 + (i == 4 ? .025 : 0));
      canvas.drawOval(Rect.fromCenter(center: center, width: maxR * (0.34 + i * .14), height: maxR * (0.26 + i * .12)), ring);
    }

    final star = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 70; i++) {
      final a = i * 2.399963 + phase * .08;
      final rr = (0.12 + ((i * 37) % 100) / 100 * .78) * maxR;
      final x = center.dx + math.cos(a) * rr;
      final y = center.dy + math.sin(a * 1.23) * rr * .72;
      if (x < -5 || x > size.width + 5 || y < -5 || y > size.height + 5) continue;
      final alpha = .06 + ((i * 13) % 7) * .018;
      star.color = (i % 5 == 0 ? reality.b : reality.a).withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), i % 9 == 0 ? 1.6 : .8, star);
    }

    final mist = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    final path = Path();
    for (int band = 0; band < 3; band++) {
      path.reset();
      for (int x = 0; x <= size.width; x += 5) {
        final y = size.height * (.77 + band * .035) + math.sin(x / 75 + phase * math.pi * 2 + band) * 12;
        if (x == 0) path.moveTo(x.toDouble(), y); else path.lineTo(x.toDouble(), y);
      }
      mist.color = (band.isEven ? reality.a : reality.b).withValues(alpha: .07);
      canvas.drawPath(path, mist);
    }
  }

  @override
  bool shouldRepaint(covariant _FuturePainter oldDelegate) => true;
}

class _LifeNetworkPainter extends CustomPainter {
  final double phase;
  final int activeCore;
  final _Reality reality;
  _LifeNetworkPainter({required this.phase, required this.activeCore, required this.reality});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .5, size.height * .42);
    final nodes = <Offset>[
      Offset(size.width * .24, size.height * .28),
      Offset(size.width * .76, size.height * .28),
      Offset(size.width * .21, size.height * .68),
      Offset(size.width * .79, size.height * .68),
      Offset(size.width * .50, size.height * .14),
    ];

    for (int i = 0; i < nodes.length; i++) {
      final p = nodes[i];
      final colors = <Color>[const Color(0xFF00F4FF), const Color(0xFFFFB34A), const Color(0xFF6C8CFF), const Color(0xFFB84DFF), const Color(0xFFB9FF55)];
      final c = colors[i];
      final active = activeCore == i;
      final glow = Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 3.2 : 1.0..color = c.withValues(alpha: active ? .42 : .16)..maskFilter = MaskFilter.blur(BlurStyle.normal, active ? 9 : 5);
      canvas.drawLine(center, p, glow);

      final line = Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 1.5 : .65..color = c.withValues(alpha: active ? .60 : .23);
      final path = Path()..moveTo(center.dx, center.dy);
      final control = Offset((center.dx + p.dx) / 2 + math.sin(phase * math.pi * 2 + i) * 24, (center.dy + p.dy) / 2 + math.cos(phase * math.pi * 2 + i) * 18);
      path.quadraticBezierTo(control.dx, control.dy, p.dx, p.dy);
      canvas.drawPath(path, line);

      final t = (phase * 1.4 + i * .17) % 1.0;
      final q = _quad(center, control, p, t);
      final particle = Paint()..color = c.withValues(alpha: .80)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(q, active ? 3.2 : 2.0, particle);
    }

    final halo = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = reality.a.withValues(alpha: .18);
    canvas.drawCircle(center, 125 + math.sin(phase * math.pi * 2) * 4, halo);
    canvas.drawCircle(center, 145 + math.cos(phase * math.pi * 2) * 5, halo..color = reality.b.withValues(alpha: .10));
  }

  Offset _quad(Offset a, Offset b, Offset c, double t) {
    final u = 1 - t;
    return Offset(u * u * a.dx + 2 * u * t * b.dx + t * t * c.dx, u * u * a.dy + 2 * u * t * b.dy + t * t * c.dy);
  }

  @override
  bool shouldRepaint(covariant _LifeNetworkPainter oldDelegate) => true;
}

class _YansiPainter extends CustomPainter {
  final double phase;
  final Color primary;
  final Color secondary;
  final bool active;
  _YansiPainter({required this.phase, required this.primary, required this.secondary, required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final pulse = 1 + math.sin(phase * math.pi * 2) * .035;

    for (int i = 0; i < 5; i++) {
      final r = (78 + i * 16) * pulse;
      final glow = Paint()..style = PaintingStyle.stroke..strokeWidth = i == 0 ? 4 : 1.2..color = Color.lerp(primary, secondary, i / 5)!.withValues(alpha: i == 0 ? .13 : .045)..maskFilter = MaskFilter.blur(BlurStyle.normal, i == 0 ? 15 : 5);
      canvas.drawCircle(c, r, glow);
    }

    final aura = Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: active ? .85 : .62), primary.withValues(alpha: .35), secondary.withValues(alpha: .10), Colors.transparent], stops: const [.0, .16, .46, 1]).createShader(Rect.fromCircle(center: c, radius: 95));
    canvas.drawCircle(c, 95, aura);

    final loop = Path();
    const turns = 1.75;
    for (int i = 0; i <= 220; i++) {
      final t = i / 220;
      final a = t * math.pi * 2 * turns + phase * math.pi * 2;
      final rr = 15 + 64 * math.sin(t * math.pi);
      final x = c.dx + math.cos(a) * rr * (.80 + .20 * math.sin(t * math.pi));
      final y = c.dy + math.sin(a) * rr * 1.10;
      if (i == 0) loop.moveTo(x, y); else loop.lineTo(x, y);
    }
    final energy = Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 5 : 3.2..strokeCap = StrokeCap.round..shader = LinearGradient(colors: [primary, Colors.white, secondary, primary]).createShader(Rect.fromCircle(center: c, radius: 75))..maskFilter = MaskFilter.blur(BlurStyle.normal, active ? 5 : 3);
    canvas.drawPath(loop, energy);

    final core = Paint()..shader = RadialGradient(colors: [Colors.white, primary, secondary.withValues(alpha: .7), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: 31));
    canvas.drawCircle(c, 31, core);
    final dot = Paint()..color = Colors.white..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(c, 6 + (active ? 2 : 0), dot);

    final vertical = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.1..color = primary.withValues(alpha: .55);
    canvas.drawLine(Offset(c.dx, c.dy + 35), Offset(c.dx, size.height), vertical);
  }

  @override
  bool shouldRepaint(covariant _YansiPainter oldDelegate) => true;
}

class _CoreNodePainter extends CustomPainter {
  final double phase;
  final Color primary;
  final Color secondary;
  final IconData icon;
  final bool selected;
  _CoreNodePainter({required this.phase, required this.primary, required this.secondary, required this.icon, required this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 3;

    final outer = Paint()..style = PaintingStyle.stroke..strokeWidth = selected ? 2.4 : 1.2..shader = SweepGradient(colors: [primary, secondary, Colors.white.withValues(alpha: .25), primary]).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, outer);

    final inner = Paint()..style = PaintingStyle.fill..shader = RadialGradient(colors: [primary.withValues(alpha: .16), secondary.withValues(alpha: .04), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r - 2, inner);

    final orbit = Paint()..style = PaintingStyle.stroke..strokeWidth = .8..color = primary.withValues(alpha: .45);
    canvas.drawOval(Rect.fromCenter(center: c, width: r * 1.55, height: r * .58), orbit);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(phase * math.pi * 2 * .35);
    canvas.translate(-c.dx, -c.dy);
    canvas.drawOval(Rect.fromCenter(center: c, width: r * 1.55, height: r * .58), orbit..color = secondary.withValues(alpha: .25));
    canvas.restore();

    final glow = Paint()..color = primary.withValues(alpha: selected ? .32 : .12)..maskFilter = MaskFilter.blur(BlurStyle.normal, selected ? 12 : 7);
    canvas.drawCircle(c, 19, glow);

    final iconPainter = TextPainter(text: TextSpan(text: String.fromCharCode(icon.codePoint), style: TextStyle(fontSize: 28, fontFamily: icon.fontFamily, package: icon.fontPackage, color: Colors.white.withValues(alpha: .90), shadows: [Shadow(color: primary, blurRadius: 10)])), textDirection: TextDirection.ltr);
    iconPainter.layout();
    iconPainter.paint(canvas, Offset(c.dx - iconPainter.width / 2, c.dy - iconPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CoreNodePainter oldDelegate) => true;
}

class _MiniRealityPainter extends CustomPainter {
  final Color a;
  final Color b;
  final double phase;
  _MiniRealityPainter(this.a, this.b, this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 2..shader = SweepGradient(colors: [a, b, a]).createShader(Rect.fromCircle(center: c, radius: 30));
    canvas.drawCircle(c, 28 + math.sin(phase * math.pi * 2) * 2, p);
    canvas.drawCircle(c, 16, p..strokeWidth = 1);
    canvas.drawCircle(c, 5, Paint()..color = Colors.white.withValues(alpha: .85)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
  }

  @override
  bool shouldRepaint(covariant _MiniRealityPainter oldDelegate) => true;
}
