import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'services/yansi_brain.dart';

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

  _Reality get _reality => _realities.firstWhere(
        (_Reality item) => item.id == _design,
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
    _design = widget.prefs.getString('lifeoz_reality') ?? 'neural_void';
    _onboarding = widget.prefs.getBool('lifeoz_master_ready') != true;

    _tts.setSpeechRate(0.44);
    _tts.setStartHandler(() {
      if (mounted) setState(() => _speaking = true);
    });
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
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
    if (mounted) setState(() => _listening = false);

    final result = await _brain.process(clean);
    if (!mounted) return;
    setState(() {
      _message = result.response;
      _transcript = '';
    });
    await _speak(result.response);
  }

  Future<void> _listen() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }

    final available = await _speech.initialize(
      onStatus: (String status) {
        if ((status == 'done' || status == 'notListening') && mounted) {
          setState(() => _listening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    );

    if (!available) {
      _toast('Microphone permission is required for Yansi.');
      return;
    }

    setState(() {
      _listening = true;
      _transcript = '';
    });

    await _speech.listen(
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      onResult: (stt.SpeechRecognitionResult result) {
        if (!mounted) return;
        setState(() => _transcript = result.recognizedWords);
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          _process(result.recognizedWords);
        }
      },
    );
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

    if (!mounted) return;
    setState(() => _onboarding = false);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await _speak(
      'Welcome, $_name. I am Yansi. Your life is now connected. Tell me what you need.',
    );
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
        builder: (BuildContext context, Widget? child) {
          return _onboarding ? _buildOnboarding() : _buildHome();
        },
      ),
    );
  }

  Widget _buildOnboarding() {
    return Stack(
      children: <Widget>[
        _environment(),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
            child: Column(
              children: <Widget>[
                _brand(76),
                const SizedBox(height: 14),
                const Text(
                  'LIFEOZ',
                  style: TextStyle(fontSize: 32, letterSpacing: 9, fontWeight: FontWeight.w200),
                ),
                const SizedBox(height: 6),
                Text(
                  'A LIFE OPERATING SYSTEM',
                  style: TextStyle(fontSize: 9, letterSpacing: 3, color: _reality.a.withValues(alpha: 0.72)),
                ),
                const SizedBox(height: 26),
                _glass(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('IDENTITY FIELD'),
                      TextField(
                        onChanged: (String value) => _name = value,
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                          hintText: 'What should Yansi call you?',
                          hintStyle: TextStyle(color: Colors.white30),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(child: _selector('LOCATION', _country, <String>['India', 'United States', 'United Kingdom', 'Canada', 'Australia', 'Other'], (String value) => setState(() => _country = value))),
                          const SizedBox(width: 10),
                          Expanded(child: _selector('CURRENCY', _currency, <String>['INR', 'USD', 'GBP', 'CAD', 'AUD', 'EUR'], (String value) => setState(() => _currency = value))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _selector('LANGUAGE', _language, <String>['English', 'Hindi', 'Gujarati'], (String value) => setState(() => _language = value)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _glass(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('CHOOSE YOUR REALITY'),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 170,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _realities.length,
                          separatorBuilder: (_, int index) => const SizedBox(width: 10),
                          itemBuilder: (_, int index) => _realityCard(_realities[index]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _primary('ENTER THE LIFEOZ FIELD', _enter),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHome() {
    return Stack(
      children: <Widget>[
        _environment(),
        SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: <Widget>[
                    _node(Icons.tune_rounded, () => setState(() => _controls = true), _reality.a),
                    const Spacer(),
                    Column(
                      children: <Widget>[
                        const Text('LIFEOZ', style: TextStyle(fontSize: 13, letterSpacing: 5, fontWeight: FontWeight.w700)),
                        Text(_name.toUpperCase(), style: TextStyle(fontSize: 7, letterSpacing: 2, color: _reality.a.withValues(alpha: 0.6))),
                      ],
                    ),
                    const Spacer(),
                    _node(_listening ? Icons.graphic_eq_rounded : Icons.mic_none_rounded, _listen, _reality.b),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 290,
                        child: Center(child: GestureDetector(onTap: _listen, child: _orb())),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          _transcript.isNotEmpty ? _transcript : _message,
                          key: ValueKey<String>(_transcript.isNotEmpty ? _transcript : _message),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, height: 1.5, color: Colors.white.withValues(alpha: 0.78)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _constellation(),
                      const SizedBox(height: 14),
                      _commandField(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_controls) _controlOverlay(),
      ],
    );
  }

  Widget _environment() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _EnvironmentPainter(_reality, _motion.value),
      ),
    );
  }

  Widget _brand(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BrandPainter(_reality.a, _reality.b)),
    );
  }

  Widget _orb() {
    return SizedBox(
      width: 250,
      height: 250,
      child: CustomPaint(
        painter: _OrbPainter(_reality, _motion.value, _listening, _speaking),
      ),
    );
  }

  Widget _constellation() {
    return SizedBox(
      width: 350,
      height: 205,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CustomPaint(
            size: const Size(340, 205),
            painter: _ConstellationPainter(_reality, _motion.value),
          ),
          for (int i = 0; i < 5; i++)
            Transform.translate(
              offset: Offset(
                math.cos(-math.pi / 2 + i * 2 * math.pi / 5) * 116,
                math.sin(-math.pi / 2 + i * 2 * math.pi / 5) * 78,
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() => _activeCore = i);
                  _speak(_coreMeanings[i]);
                },
                child: _coreGlyph(i, _activeCore == i),
              ),
            ),
          _brand(68),
        ],
      ),
    );
  }

  Widget _coreGlyph(int index, bool active) {
    const List<IconData> icons = <IconData>[
      Icons.account_balance_wallet_outlined,
      Icons.bolt_outlined,
      Icons.event_outlined,
      Icons.home_work_outlined,
      Icons.flag_outlined,
    ];
    final Color color = active ? _reality.b : _reality.a;
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xCC050912),
        border: Border.all(color: color.withValues(alpha: 0.78), width: active ? 2 : 1),
        boxShadow: <BoxShadow>[
          BoxShadow(color: color.withValues(alpha: active ? 0.28 : 0.08), blurRadius: 24),
        ],
      ),
      child: Icon(icons[index], color: color, size: 22),
    );
  }

  Widget _commandField() {
    return _glass(
      Row(
        children: <Widget>[
          Icon(Icons.auto_awesome_rounded, color: _reality.a, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _input,
              onSubmitted: _process,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Speak to Yansi…',
                hintStyle: TextStyle(color: Colors.white30),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(onPressed: _listen, icon: Icon(Icons.mic_none_rounded, color: _reality.b)),
        ],
      ),
    );
  }

  Widget _controlOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _controls = false),
        child: Container(
          color: Colors.black.withValues(alpha: 0.72),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 330,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xF0070B14),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _reality.a.withValues(alpha: 0.25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _brand(58),
                  const SizedBox(height: 12),
                  Text('CONTROL FIELD', style: TextStyle(letterSpacing: 3, color: _reality.a)),
                  const SizedBox(height: 18),
                  _action('REALITY', Icons.blur_on_rounded, _showRealities),
                  _action('IDENTITY', Icons.person_outline_rounded, () => _showInfo('IDENTITY', <String>['Name: $_name', 'Location: $_country', 'Currency: $_currency', 'Language: $_language'])),
                  _action('PERMISSIONS', Icons.shield_outlined, () => _showInfo('PERMISSIONS', <String>['Voice: controlled', 'Background AI: controlled', 'Web access: permission controlled'])),
                  _action('YANSI', Icons.auto_awesome_rounded, () => _speak('I am Yansi. I connect the information you allow me to access and turn it into useful intelligence.')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _action(String title, IconData icon, VoidCallback callback) {
    return ListTile(
      onTap: callback,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: _reality.a),
      title: Text(title, style: const TextStyle(fontSize: 11, letterSpacing: 1.8)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white30),
    );
  }

  void _showRealities() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF05080E),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _realities.length,
                separatorBuilder: (_, int index) => const SizedBox(width: 10),
                itemBuilder: (_, int index) => _realityCard(_realities[index]),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showInfo(String title, List<String> lines) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF060A12),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: TextStyle(color: _reality.a, letterSpacing: 2)),
              const SizedBox(height: 15),
              for (final String line in lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(line, style: const TextStyle(color: Colors.white70)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _realityCard(_Reality reality) {
    return GestureDetector(
      onTap: () {
        _chooseReality(reality.id);
        Navigator.of(context).maybePop();
      },
      child: Container(
        width: 155,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _design == reality.id ? reality.a : Colors.white12),
          gradient: LinearGradient(
            colors: <Color>[
              reality.a.withValues(alpha: 0.13),
              const Color(0xFF05070D),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: Center(child: _brand(70))),
            Text(reality.name, style: TextStyle(fontSize: 9, color: reality.a, letterSpacing: 1.1)),
            const SizedBox(height: 3),
            Text(reality.subtitle, style: const TextStyle(fontSize: 8, color: Colors.white38)),
          ],
        ),
      ),
    );
  }

  Widget _glass(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x66101824),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _reality.a.withValues(alpha: 0.16)),
      ),
      child: child,
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(text, style: const TextStyle(fontSize: 9, letterSpacing: 2, color: Colors.white54)),
    );
  }

  Widget _selector(String label, String value, List<String> items, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _label(label),
        DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          underline: const SizedBox.shrink(),
          dropdownColor: const Color(0xFF101620),
          items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontSize: 12)))).toList(),
          onChanged: (String? next) {
            if (next != null) onChanged(next);
          },
        ),
      ],
    );
  }

  Widget _primary(String text, VoidCallback callback) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: callback,
        style: ElevatedButton.styleFrom(
          backgroundColor: _reality.a.withValues(alpha: 0.12),
          foregroundColor: _reality.a,
          side: BorderSide(color: _reality.a.withValues(alpha: 0.45)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(text, style: const TextStyle(letterSpacing: 2, fontSize: 11)),
      ),
    );
  }

  Widget _node(IconData icon, VoidCallback callback, Color color) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.45)),
          boxShadow: <BoxShadow>[BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 18)],
        ),
        child: Icon(icon, color: color, size: 19),
      ),
    );
  }
}

class _Reality {
  final String id;
  final String name;
  final String subtitle;
  final Color a;
  final Color b;

  const _Reality(this.id, this.name, this.subtitle, this.a, this.b);
}

class _EnvironmentPainter extends CustomPainter {
  final _Reality reality;
  final double time;

  const _EnvironmentPainter(this.reality, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint glow = Paint()
      ..shader = RadialGradient(
        colors: <Color>[reality.a.withValues(alpha: 0.08), Colors.transparent],
      ).createShader(Rect.fromCircle(center: size.center(Offset.zero), radius: size.longestSide * 0.7));
    canvas.drawRect(Offset.zero & size, glow);

    final Paint line = Paint()
      ..color = reality.a.withValues(alpha: 0.035)
      ..strokeWidth = 1;
    for (int i = 0; i < 8; i++) {
      final double y = size.height * i / 8;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + math.sin(time * math.pi * 2 + i) * 10), line);
    }

    for (int i = 0; i < 24; i++) {
      final double x = (math.sin(i * 7.3 + time * math.pi * 2) * 0.5 + 0.5) * size.width;
      final double y = (math.cos(i * 4.7 + time * math.pi * 2) * 0.5 + 0.5) * size.height;
      final Paint dot = Paint()..color = (i.isEven ? reality.a : reality.b).withValues(alpha: 0.14);
      canvas.drawCircle(Offset(x, y), 1, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _EnvironmentPainter oldDelegate) => true;
}

class _BrandPainter extends CustomPainter {
  final Color a;
  final Color b;

  const _BrandPainter(this.a, this.b);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide * 0.42;
    final Paint outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = a.withValues(alpha: 0.65);
    final Paint inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = b.withValues(alpha: 0.8);
    canvas.drawCircle(center, radius, outer);
    canvas.drawCircle(center, radius * 0.62, inner);
    for (int i = 0; i < 6; i++) {
      final double angle = i * math.pi / 3;
      final Offset p = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawCircle(p, 2.2, Paint()..color = (i.isEven ? a : b));
    }
  }

  @override
  bool shouldRepaint(covariant _BrandPainter oldDelegate) => oldDelegate.a != a || oldDelegate.b != b;
}

class _OrbPainter extends CustomPainter {
  final _Reality reality;
  final double time;
  final bool listening;
  final bool speaking;

  const _OrbPainter(this.reality, this.time, this.listening, this.speaking);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double base = size.shortestSide * 0.25;
    final double pulse = math.sin(time * math.pi * 2) * 7;

    final Paint aura = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          reality.a.withValues(alpha: listening || speaking ? 0.28 : 0.16),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: base * 2.5));
    canvas.drawCircle(center, base * 2.5, aura);

    final Paint core = Paint()
      ..shader = RadialGradient(colors: <Color>[reality.a, reality.b, const Color(0xFF02131A)]).createShader(
        Rect.fromCircle(center: center, radius: base + pulse),
      );
    canvas.drawCircle(center, base + pulse, core);

    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = reality.a.withValues(alpha: 0.62);
    for (int i = 0; i < 3; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(time * math.pi * 2 * (i.isEven ? 1 : -1) + i);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: base * 3.2 + i * 14, height: base * 1.2 + i * 7), ring);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) => true;
}

class _ConstellationPainter extends CustomPainter {
  final _Reality reality;
  final double time;

  const _ConstellationPainter(this.reality, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final Paint line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = reality.a.withValues(alpha: 0.18);
    final List<Offset> points = <Offset>[];
    for (int i = 0; i < 5; i++) {
      final double angle = -math.pi / 2 + i * 2 * math.pi / 5;
      points.add(center + Offset(math.cos(angle) * 116, math.sin(angle) * 78));
    }
    for (int i = 0; i < points.length; i++) {
      canvas.drawLine(points[i], points[(i + 1) % points.length], line);
      canvas.drawLine(points[i], center, line);
    }
    canvas.drawCircle(center, 3 + math.sin(time * math.pi * 2) * 1.5, Paint()..color = reality.b);
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) => true;
}
