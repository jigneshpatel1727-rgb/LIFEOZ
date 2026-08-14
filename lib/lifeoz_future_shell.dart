import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'services/yansi_brain.dart';

/// LIFEOZ / YANSI — visual home universe.
/// Design follows the supplied master reference: central Yansi, five symbolic
/// cores, luminous links, holographic control, adaptive environments and six
/// visual realities.
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
  String _realityId = 'oreon_prime';
  String _environment = 'focus';
  String _message = '';
  String _transcript = '';
  bool _onboarding = true;
  bool _listening = false;
  bool _speaking = false;
  bool _ghostStarting = false;
  bool _hologram = false;
  bool _settings = false;
  int _activeCore = -1;
  int _activeControl = -1;

  static const _RealityData defaultReality = _RealityData(
    'oreon_prime', 'OREON PRIME', 'Living Cosmic Organism',
    Color(0xFF20D9FF), Color(0xFFFFB84A),
  );

  static const List<_RealityData> realities = [
    _RealityData('oreon_prime', 'OREON PRIME', 'Living Cosmic Organism', Color(0xFF20D9FF), Color(0xFFFFB84A)),
    _RealityData('terra_flux', 'TERRA FLUX', 'Organic Nature Tech', Color(0xFF36E6A4), Color(0xFFB8FF68)),
    _RealityData('vortex_nexus', 'VORTEX NEXUS', 'Dimensional Rings', Color(0xFF47BFFF), Color(0xFFFFB35C)),
    _RealityData('crysta_lumen', 'CRYSTA LUMEN', 'Light Geometry', Color(0xFFB58CFF), Color(0xFF5AE7FF)),
    _RealityData('nebula_soul', 'NEBULA SOUL', 'Emotion & Energy', Color(0xFFFF5CA8), Color(0xFFFF9D42)),
    _RealityData('shadow_core', 'SHADOW CORE', 'Minimal Dark Matter', Color(0xFFE8F2FF), Color(0xFF7D9BB8)),
  ];

  // The five visual symbols are intentionally icon-only on the home screen.
  static const List<_CoreData> cores = [
    _CoreData(Icons.account_balance_wallet_rounded, 'Money, income, expenses, bills and investments.', 'This is your financial intelligence. I organize money, expenses, bills and investments into one picture.', Color(0xFF40E6A2), 'FINANCE'),
    _CoreData(Icons.favorite_rounded, 'Goals, wellbeing, diary and personal growth.', 'This is your personal intelligence. I connect goals, diary, wellbeing and progress.', Color(0xFFFF6B75), 'LIFE'),
    _CoreData(Icons.bolt_rounded, 'Work, tasks, productivity and execution.', 'This is your execution intelligence. I organize tasks and help you move through the day.', Color(0xFFFFC45A), 'ACTION'),
    _CoreData(Icons.calendar_month_rounded, 'Calendar, renewals, bills, birthdays and commitments.', 'This is your time intelligence. I watch dates, renewals, bills and important commitments.', Color(0xFF4CCBFF), 'TIME'),
    _CoreData(Icons.home_rounded, 'Home, shopping, kitchen and household needs.', 'This is your home intelligence. I organize household needs and shopping with you.', Color(0xFFB77BFF), 'HOME'),
  ];

  static const List<_EnvironmentData> environments = [
    _EnvironmentData('morning', 'Morning', Icons.wb_sunny_rounded, Color(0xFFFFB347)),
    _EnvironmentData('work', 'Work', Icons.workspaces_rounded, Color(0xFF43C8FF)),
    _EnvironmentData('evening', 'Evening', Icons.nightlight_round, Color(0xFFFF8C68)),
    _EnvironmentData('focus', 'Focus', Icons.center_focus_strong_rounded, Color(0xFFC07CFF)),
    _EnvironmentData('rest', 'Rest', Icons.spa_rounded, Color(0xFF67E5B3)),
  ];

  static const List<_ControlData> controls = [
    _ControlData('Profile', Icons.person_rounded),
    _ControlData('Design', Icons.auto_awesome_rounded),
    _ControlData('Permissions', Icons.shield_rounded),
    _ControlData('Yansi', Icons.psychology_rounded),
    _ControlData('Settings', Icons.tune_rounded),
  ];

  _RealityData get reality => realities.firstWhere(
        (r) => r.id == _realityId,
        orElse: () => defaultReality,
      );

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(vsync: this, duration: const Duration(seconds: 16))..repeat();
    _brain = YansiBrain(prefs: widget.prefs);
    _name = widget.prefs.getString('user_name') ?? '';
    _country = widget.prefs.getString('user_country') ?? 'India';
    _currency = widget.prefs.getString('user_currency') ?? 'INR';
    _language = widget.prefs.getString('user_language') ?? 'English';
    _realityId = widget.prefs.getString('lifeoz_reality') ?? 'oreon_prime';
    _environment = widget.prefs.getString('lifeoz_environment') ?? 'focus';
    _onboarding = widget.prefs.getBool('lifeoz_master_ready') != true;
    _tts.setSpeechRate(0.44);
    _tts.setStartHandler(() { if (mounted) setState(() => _speaking = true); });
    _tts.setCompletionHandler(() { if (mounted) setState(() => _speaking = false); if (!_onboarding) _startGhostListening(); });
    if (!_onboarding) WidgetsBinding.instance.addPostFrameCallback((_) => _startGhostListening());
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
            if (!_onboarding && !_speaking) Future<void>.delayed(const Duration(milliseconds: 400), _startGhostListening);
          }
        },
        onError: (_) { if (mounted) setState(() => _listening = false); },
      );
      if (!available || !mounted) return;
      setState(() => _listening = true);
      await _speech.listen(
        listenOptions: stt.SpeechListenOptions(partialResults: true, cancelOnError: false, listenMode: stt.ListenMode.dictation),
        onResult: (result) {
          if (!mounted) return;
          setState(() => _transcript = result.recognizedWords);
          if (result.finalResult && result.recognizedWords.trim().isNotEmpty) _process(result.recognizedWords);
        },
      );
    } finally { _ghostStarting = false; }
  }

  Future<void> _process(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    await _speech.stop();
    if (mounted) setState(() { _listening = false; _message = 'Thinking…'; _transcript = ''; });
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
    if (_name.trim().isEmpty) { _toast('Enter your name first.'); return; }
    await widget.prefs.setString('user_name', _name.trim());
    await widget.prefs.setString('user_country', _country);
    await widget.prefs.setString('user_currency', _currency);
    await widget.prefs.setString('user_language', _language);
    await widget.prefs.setString('lifeoz_reality', _realityId);
    await widget.prefs.setString('lifeoz_environment', _environment);
    await widget.prefs.setBool('lifeoz_master_ready', true);
    if (!mounted) return;
    setState(() => _onboarding = false);
    await _speak('Welcome, $_name. I am Yansi, your personal LifeOS intelligence. I am here whenever you need me.');
  }

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: const Color(0xFF0B1725), content: Text(text)));
  }

  void _chooseReality(String id) {
    if (!realities.any((r) => r.id == id)) return;
    setState(() { _realityId = id; _settings = false; });
    widget.prefs.setString('lifeoz_reality', id);
  }

  void _chooseEnvironment(String id) {
    setState(() => _environment = id);
    widget.prefs.setString('lifeoz_environment', id);
  }

  void _activateCore(int index) {
    setState(() { _activeCore = index; _hologram = false; _activeControl = -1; });
    _speak(cores[index].voice);
  }

  void _activateControl(int index) {
    setState(() => _activeControl = index);
    switch (index) {
      case 0:
        _speak(_name.isEmpty ? 'Your profile is ready to be configured.' : 'Profile for $_name. Your LifeOS environment is ready.');
        break;
      case 1:
        setState(() { _hologram = false; _settings = true; });
        break;
      case 2:
        _speak('Permissions stay under your control. LifeOS only uses capabilities you allow.');
        break;
      case 3:
        setState(() => _hologram = false);
        _speak('I am Yansi. I listen, understand, organize, remind, protect and grow with you.');
        break;
      case 4:
        setState(() { _hologram = false; _settings = true; });
        break;
    }
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
    return Stack(children: [
      _background(),
      SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _brand(),
          const SizedBox(height: 28),
          const Text('YOUR LIFE.\nONE INTELLIGENCE.', style: TextStyle(fontSize: 32, height: .98, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1.2)),
          const SizedBox(height: 10),
          Text('Create your personal universe.', style: TextStyle(color: Colors.white.withOpacity(.62), fontSize: 15)),
          const SizedBox(height: 26),
          _field('IDENTITY', _name, (v) => _name = v, 'Your name'),
          const SizedBox(height: 12),
          _selector('LOCATION', _country, ['India', 'United States', 'United Kingdom', 'UAE', 'Singapore', 'Other'], (v) => setState(() => _country = v!)),
          const SizedBox(height: 12),
          _selector('CURRENCY', _currency, ['INR', 'USD', 'GBP', 'AED', 'SGD', 'EUR'], (v) => setState(() => _currency = v!)),
          const SizedBox(height: 12),
          _selector('LANGUAGE', _language, ['English', 'Hindi', 'Gujarati'], (v) => setState(() => _language = v!)),
          const SizedBox(height: 24),
          Text('CHOOSE YOUR VISUAL REALITY', style: TextStyle(color: reality.a, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          SizedBox(height: 154, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: realities.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => _realityCard(realities[i]))),
          const SizedBox(height: 22),
          _environmentStrip(),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 56, child: FilledButton(onPressed: _enter, style: FilledButton.styleFrom(backgroundColor: reality.a, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: const Text('ENTER LIFEOZ', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.4)))),
        ]),
      ),
    ]);
  }

  Widget _buildHome() {
    return Stack(children: [
      _background(),
      Positioned(top: 10, left: 18, right: 18, child: Row(children: [_brand(), const Spacer(), _topPill()])),
      Positioned.fill(
        top: 56,
        child: LayoutBuilder(builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final center = Offset(size.width / 2, size.height * .46);
          return Stack(children: [
            Positioned.fill(child: CustomPaint(painter: _LifeNetworkPainter(phase: _motion.value, activeCore: _activeCore, reality: reality))),
            ..._corePositions(size).asMap().entries.map((entry) {
              final i = entry.key; final p = entry.value;
              return Positioned(left: p.dx - 48, top: p.dy - 48, child: _coreNode(i, 96));
            }),
            Positioned(left: center.dx - 126, top: center.dy - 126, child: _yansiNode(252)),
            Positioned(left: 18, right: 18, bottom: 78, child: _yansiCaption()),
            Positioned(left: 0, right: 0, bottom: 14, child: _statusLine()),
          ]);
        }),
      ),
      if (_hologram) Positioned.fill(child: _holographicControl()),
      if (_settings) Positioned(left: 16, right: 16, top: 62, child: _universePanel()),
      if (_message.isNotEmpty && !_hologram) Positioned(left: 28, right: 28, bottom: 122, child: IgnorePointer(child: Text(_message, textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(.86), fontSize: 14, height: 1.3)))),
      if (_transcript.isNotEmpty && !_hologram) Positioned(left: 30, right: 30, bottom: 94, child: Text(_transcript, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: reality.a.withOpacity(.78), fontSize: 11))),
    ]);
  }

  List<Offset> _corePositions(Size size) {
    final w = size.width, h = size.height;
    return [Offset(w * .23, h * .30), Offset(w * .77, h * .30), Offset(w * .17, h * .70), Offset(w * .83, h * .70), Offset(w * .50, h * .12)];
  }

  Widget _coreNode(int index, double size) {
    final core = cores[index];
    final active = _activeCore == index;
    return GestureDetector(onTap: () => _activateCore(index), child: AnimatedContainer(duration: const Duration(milliseconds: 260), width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(.12), boxShadow: [BoxShadow(color: core.color.withOpacity(active ? .48 : .18), blurRadius: active ? 34 : 22, spreadRadius: active ? 3 : 0)]), child: CustomPaint(painter: _CoreSymbolPainter(index: index, color: core.color, accent: reality.a, active: active, phase: _motion.value))));
  }

  Widget _yansiNode(double diameter) {
    return GestureDetector(onTap: () => setState(() => _hologram = true), child: SizedBox(width: diameter, height: diameter, child: CustomPaint(painter: _YansiPainter(phase: _motion.value, primary: reality.a, secondary: reality.b, speaking: _speaking || _listening, active: _activeCore >= 0))));
  }

  Widget _yansiCaption() => Column(children: [
    Text('YANSI', style: TextStyle(color: Colors.white.withOpacity(.92), fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 5)),
    const SizedBox(height: 4),
    Text('Your Silent Intelligence', style: TextStyle(color: reality.a.withOpacity(.82), fontSize: 11, letterSpacing: 1.2)),
    const SizedBox(height: 5),
    Text('Tap the core • Tap Yansi to open your universe', style: TextStyle(color: Colors.white.withOpacity(.42), fontSize: 9)),
  ]);

  Widget _statusLine() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(_listening ? Icons.graphic_eq_rounded : Icons.auto_awesome_rounded, size: 14, color: reality.a),
    const SizedBox(width: 7),
    Text(_listening ? 'YANSI LISTENING' : 'LIFEOZ • LIVING OPERATING SYSTEM', style: TextStyle(color: Colors.white.withOpacity(.45), fontSize: 9, letterSpacing: 1.5)),
  ]);

  Widget _topPill() => GestureDetector(onTap: () => setState(() => _hologram = true), child: Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.035), border: Border.all(color: reality.a.withOpacity(.45)), boxShadow: [BoxShadow(color: reality.a.withOpacity(.12), blurRadius: 18)]), child: Icon(Icons.hub_rounded, size: 19, color: reality.a)));

  Widget _holographicControl() {
    return GestureDetector(
      onTap: () => setState(() => _hologram = false),
      child: Container(color: const Color(0xFF01030A).withOpacity(.90), child: Center(child: LayoutBuilder(builder: (context, constraints) {
        final radius = math.min(constraints.maxWidth * .38, constraints.maxHeight * .31);
        return SizedBox(width: radius * 2.7, height: radius * 2.7, child: Stack(alignment: Alignment.center, children: [
          CustomPaint(size: Size(radius * 2.7, radius * 2.7), painter: _HologramPainter(phase: _motion.value, primary: reality.a, secondary: reality.b)),
          ...controls.asMap().entries.map((entry) {
            final i = entry.key; final a = (-math.pi / 2) + i * (2 * math.pi / 5); final r = radius * .82;
            final x = radius * 1.35 + math.cos(a) * r; final y = radius * 1.35 + math.sin(a) * r;
            return Positioned(left: x - 42, top: y - 42, child: _controlNode(i));
          }),
          GestureDetector(onTap: () => setState(() => _hologram = false), child: Container(width: 92, height: 92, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: reality.a.withOpacity(.7), width: 1.5), boxShadow: [BoxShadow(color: reality.a.withOpacity(.40), blurRadius: 30)]), child: CustomPaint(painter: _YansiPainter(phase: _motion.value, primary: reality.a, secondary: reality.b, speaking: _speaking, active: true)))),
          Positioned(bottom: 10, child: Text('HOLOGRAPHIC CONTROL', style: TextStyle(color: Colors.white.withOpacity(.80), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2))),
        ]);
      })));
    );
  }

  Widget _controlNode(int index) {
    final control = controls[index]; final active = _activeControl == index;
    return GestureDetector(onTap: () => _activateControl(index), child: SizedBox(width: 84, height: 84, child: Column(children: [
      AnimatedContainer(duration: const Duration(milliseconds: 220), width: 54, height: 54, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? reality.a.withOpacity(.18) : Colors.black.withOpacity(.35), border: Border.all(color: active ? reality.a : Colors.white.withOpacity(.20)), boxShadow: [BoxShadow(color: reality.a.withOpacity(active ? .32 : .08), blurRadius: 18)]), child: Icon(control.icon, color: active ? reality.a : Colors.white.withOpacity(.76), size: 24)),
      const SizedBox(height: 5),
      Text(control.name, style: TextStyle(color: Colors.white.withOpacity(.72), fontSize: 9)),
    ])));
  }

  Widget _universePanel() {
    return Material(color: Colors.transparent, child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF07111C).withOpacity(.97), borderRadius: BorderRadius.circular(24), border: Border.all(color: reality.a.withOpacity(.35)), boxShadow: [BoxShadow(color: reality.a.withOpacity(.16), blurRadius: 35)]),
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text('YOUR UNIVERSE', style: TextStyle(color: reality.a, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)), const Spacer(), GestureDetector(onTap: () => setState(() => _settings = false), child: const Icon(Icons.close_rounded, color: Colors.white54))]),
        const SizedBox(height: 14),
        _environmentStrip(),
        const SizedBox(height: 14),
        Text('6 VISUAL REALITIES', style: TextStyle(color: Colors.white.withOpacity(.62), fontSize: 10, letterSpacing: 1.6, fontWeight: FontWeight.w700)),
        const SizedBox(height: 9),
        Wrap(spacing: 8, runSpacing: 8, children: realities.map((r) => ChoiceChip(label: Text(r.name), selected: r.id == _realityId, onSelected: (_) => _chooseReality(r.id), selectedColor: r.a.withOpacity(.22), backgroundColor: Colors.white.withOpacity(.04), labelStyle: TextStyle(color: r.id == _realityId ? r.a : Colors.white.withOpacity(.65), fontSize: 10), side: BorderSide(color: r.id == _realityId ? r.a.withOpacity(.65) : Colors.white.withOpacity(.12)))).toList()),
        const SizedBox(height: 13),
        Text('THE FIVE CORE INTELLIGENCE SYMBOLS', style: TextStyle(color: Colors.white.withOpacity(.62), fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w700)),
        const SizedBox(height: 7),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(cores.length, (i) => GestureDetector(onTap: () { setState(() => _settings = false); _activateCore(i); }, child: CustomPaint(size: const Size(44, 54), painter: _CoreSymbolPainter(index: i, color: cores[i].color, accent: reality.a, active: false, phase: _motion.value))))),
      ])),
    ));
  }

  Widget _environmentStrip() => SizedBox(height: 78, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: environments.map((e) {
    final active = _environment == e.id;
    return GestureDetector(onTap: () => _chooseEnvironment(e.id), child: Column(mainAxisSize: MainAxisSize.min, children: [
      AnimatedContainer(duration: const Duration(milliseconds: 220), width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? e.color.withOpacity(.16) : Colors.white.withOpacity(.025), border: Border.all(color: active ? e.color.withOpacity(.78) : Colors.white.withOpacity(.12)), boxShadow: [BoxShadow(color: e.color.withOpacity(active ? .28 : .04), blurRadius: 18)]), child: Icon(e.icon, color: e.color, size: 20)),
      const SizedBox(height: 4),
      Text(e.name, style: TextStyle(color: active ? e.color : Colors.white.withOpacity(.54), fontSize: 9)),
    ]));
  }).toList()));

  Widget _brand() => Row(children: [
    Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: reality.a, width: 1.5), boxShadow: [BoxShadow(color: reality.a.withOpacity(.30), blurRadius: 18)]), child: Icon(Icons.all_inclusive_rounded, color: reality.a, size: 24)),
    const SizedBox(width: 9),
    const Text('LifeOZ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2.8, fontSize: 17)),
  ]);

  Widget _background() => Positioned.fill(child: CustomPaint(painter: _CosmicBackgroundPainter(phase: _motion.value, reality: reality, environment: _environment)));

  Widget _realityCard(_RealityData r) {
    final active = r.id == _realityId;
    return GestureDetector(onTap: () => _chooseReality(r.id), child: Container(width: 150, padding: const EdgeInsets.all(10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: Colors.white.withOpacity(.025), border: Border.all(color: active ? r.a : Colors.white.withOpacity(.10), width: active ? 1.5 : 1)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: CustomPaint(painter: _RealityMiniPainter(phase: _motion.value, primary: r.a, secondary: r.b, styleIndex: realities.indexOf(r)), child: const SizedBox.expand())),
      const SizedBox(height: 6),
      Text(r.name, style: TextStyle(color: active ? r.a : Colors.white.withOpacity(.82), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
      const SizedBox(height: 2),
      Text(r.meaning, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(.42), fontSize: 8)),
    ]));
  }

  Widget _field(String label, String value, ValueChanged<String> onChanged, String hint) => TextField(onChanged: onChanged, style: const TextStyle(color: Colors.white), decoration: _decoration(label, hint));

  InputDecoration _decoration(String label, String hint) => InputDecoration(labelText: label, hintText: hint, labelStyle: TextStyle(color: reality.a), hintStyle: TextStyle(color: Colors.white.withOpacity(.32)), filled: true, fillColor: Colors.white.withOpacity(.025), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(.10))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: reality.a.withOpacity(.65))));

  Widget _selector(String label, String value, List<String> options, ValueChanged<String?> onChanged) => DropdownButtonFormField<String>(value: value, dropdownColor: const Color(0xFF08111C), style: const TextStyle(color: Colors.white), decoration: _decoration(label, ''), items: options.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: onChanged);
}

class _RealityData { final String id, name, meaning; final Color a, b; const _RealityData(this.id, this.name, this.meaning, this.a, this.b); }
class _CoreData { final IconData icon; final String meaning, voice, debugName; final Color color; const _CoreData(this.icon, this.meaning, this.voice, this.color, this.debugName); }
class _EnvironmentData { final String id, name; final IconData icon; final Color color; const _EnvironmentData(this.id, this.name, this.icon, this.color); }
class _ControlData { final String name; final IconData icon; const _ControlData(this.name, this.icon); }

class _CosmicBackgroundPainter extends CustomPainter {
  final double phase; final _RealityData reality; final String environment;
  _CosmicBackgroundPainter({required this.phase, required this.reality, required this.environment});
  @override void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(colors: [Color(0xFF07182A), Color(0xFF01030A)], center: Alignment.center, radius: 1.05).createShader(rect));
    final random = math.Random(913);
    for (var i = 0; i < 85; i++) { final x = random.nextDouble()*size.width, y=random.nextDouble()*size.height, r=.4+random.nextDouble()*1.5, c=i.isEven?reality.a:reality.b; canvas.drawCircle(Offset(x,y),r,Paint()..color=c.withOpacity(.08+random.nextDouble()*.15)); }
    final center=Offset(size.width/2,size.height*.46);
    for(var i=0;i<7;i++){final radius=100+i*75.0;canvas.drawOval(Rect.fromCenter(center:center,width:radius*2.2,height:radius*.86),Paint()..style=PaintingStyle.stroke..strokeWidth=i==2?1.4:.7..color=(i.isEven?reality.a:reality.b).withOpacity(.055));}
    final wave=Paint()..style=PaintingStyle.stroke..strokeWidth=1.2..color=reality.a.withOpacity(.08);final path=Path();
    for(var x=0.0;x<=size.width;x+=5){final y=size.height*.84+math.sin(x/62+phase*math.pi*2)*7+math.sin(x/23+phase*5)*2;if(x==0)path.moveTo(x,y);else path.lineTo(x,y);}canvas.drawPath(path,wave);
  }
  @override bool shouldRepaint(covariant _CosmicBackgroundPainter oldDelegate)=>true;
}

class _LifeNetworkPainter extends CustomPainter {
  final double phase; final int activeCore; final _RealityData reality;
  _LifeNetworkPainter({required this.phase,required this.activeCore,required this.reality});
  @override void paint(Canvas canvas, Size size){
    final center=Offset(size.width/2,size.height*.46);final points=[Offset(size.width*.23,size.height*.30),Offset(size.width*.77,size.height*.30),Offset(size.width*.17,size.height*.70),Offset(size.width*.83,size.height*.70),Offset(size.width*.50,size.height*.12)];
    for(var i=0;i<points.length;i++){final active=i==activeCore;final paint=Paint()..style=PaintingStyle.stroke..strokeWidth=active?2.1:1.0..color=(i.isEven?reality.a:reality.b).withOpacity(active?.58:.22);final p=points[i],dx=(p.dx-center.dx)*.55,dy=(p.dy-center.dy)*.55;final path=Path()..moveTo(p.dx,p.dy)..cubicTo(p.dx-dx*.3,p.dy-dy*.05,center.dx+dx*.15,center.dy+dy*.08,center.dx,center.dy);canvas.drawPath(path,paint);final t=(phase+i*.17)%1;final q=_bezier(p,Offset(p.dx-dx*.3,p.dy-dy*.05),Offset(center.dx+dx*.15,center.dy+dy*.08),center,t);canvas.drawCircle(q,active?4:2.2,Paint()..color=(i.isEven?reality.a:reality.b).withOpacity(.55)..maskFilter=const MaskFilter.blur(BlurStyle.normal,8));}
  }
  Offset _bezier(Offset p0,Offset p1,Offset p2,Offset p3,double t){final u=1-t;return Offset(u*u*u*p0.dx+3*u*u*t*p1.dx+3*u*t*t*p2.dx+t*t*t*p3.dx,u*u*u*p0.dy+3*u*u*t*p1.dy+3*u*t*t*p2.dy+t*t*t*p3.dy);}
  @override bool shouldRepaint(covariant _LifeNetworkPainter oldDelegate)=>true;
}

class _YansiPainter extends CustomPainter {
  final double phase; final Color primary, secondary; final bool speaking, active;
  _YansiPainter({required this.phase,required this.primary,required this.secondary,required this.speaking,required this.active});
  @override void paint(Canvas canvas, Size size){
    final c=Offset(size.width/2,size.height/2),s=size.shortestSide;canvas.drawCircle(c,s*.30,Paint()..color=primary.withOpacity(speaking?.34:.22)..maskFilter=MaskFilter.blur(BlurStyle.normal,speaking?30:22));
    for(var i=0;i<5;i++){final r=s*(.25+i*.065);canvas.drawOval(Rect.fromCenter(center:c,width:r*2,height:r*1.55),Paint()..style=PaintingStyle.stroke..strokeWidth=i==2?1.7:.8..color=(i.isEven?primary:secondary).withOpacity(active?.38:.22));}
    final outer=Paint()..style=PaintingStyle.stroke..strokeWidth=2..shader=SweepGradient(colors:[primary,secondary,primary.withOpacity(.15),primary]).createShader(Rect.fromCircle(center:c,radius:s*.37));canvas.save();canvas.translate(c.dx,c.dy);canvas.rotate(phase*math.pi*2);canvas.drawOval(Rect.fromCenter(center:Offset.zero,width:s*.72,height:s*.45),outer);canvas.restore();
    canvas.drawCircle(c,s*.16,Paint()..shader=RadialGradient(colors:[Colors.white,primary,secondary.withOpacity(.65),Colors.transparent]).createShader(Rect.fromCircle(center:c,radius:s*.16)));canvas.drawCircle(c,s*.045,Paint()..color=Colors.white..maskFilter=const MaskFilter.blur(BlurStyle.normal,8));
    final path=Path()..moveTo(c.dx-s*.33,c.dy+s*.24)..cubicTo(c.dx-s*.15,c.dy+s*.08,c.dx-s*.10,c.dy+s*.20,c.dx,c.dy+s*.34)..cubicTo(c.dx+s*.10,c.dy+s*.20,c.dx+s*.15,c.dy+s*.08,c.dx+s*.33,c.dy+s*.24);canvas.drawPath(path,Paint()..style=PaintingStyle.stroke..strokeWidth=2.2..color=secondary.withOpacity(.65));
  }
  @override bool shouldRepaint(covariant _YansiPainter oldDelegate)=>true;
}

class _CoreSymbolPainter extends CustomPainter {
  final int index; final Color color, accent; final bool active; final double phase;
  _CoreSymbolPainter({required this.index,required this.color,required this.accent,required this.active,required this.phase});
  @override void paint(Canvas canvas, Size size){
    final c=Offset(size.width/2,size.height/2),s=size.shortestSide;canvas.drawCircle(c,s*.30,Paint()..color=color.withOpacity(active?.30:.15)..maskFilter=MaskFilter.blur(BlurStyle.normal,active?18:11));canvas.drawOval(Rect.fromCenter(center:c,width:s*.78,height:s*.62),Paint()..style=PaintingStyle.stroke..strokeWidth=active?2:1..color=color.withOpacity(active?.72:.35));final p=Paint()..style=PaintingStyle.stroke..strokeWidth=2.1..strokeCap=StrokeCap.round..color=color,q=Paint()..style=PaintingStyle.stroke..strokeWidth=1.2..color=accent.withOpacity(.75);
    switch(index){case 0:_leaf(canvas,c,s,p,q);break;case 1:_heart(canvas,c,s,p,q);break;case 2:_spiral(canvas,c,s,p,q);break;case 3:_orb(canvas,c,s,p,q);break;case 4:_crystal(canvas,c,s,p,q);break;}canvas.drawCircle(c,s*.035,Paint()..color=Colors.white..maskFilter=const MaskFilter.blur(BlurStyle.normal,4));
  }
  void _leaf(Canvas canvas,Offset c,double s,Paint p,Paint q){final path=Path()..moveTo(c.dx,c.dy+s*.30)..cubicTo(c.dx-s*.22,c.dy+s*.12,c.dx-s*.23,c.dy-s*.15,c.dx,c.dy-s*.30)..cubicTo(c.dx+s*.23,c.dy-s*.15,c.dx+s*.22,c.dy+s*.12,c.dx,c.dy+s*.30);canvas.drawPath(path,p);canvas.drawLine(Offset(c.dx,c.dy-s*.25),Offset(c.dx,c.dy+s*.26),q);canvas.drawLine(Offset(c.dx,c.dy-s*.05),Offset(c.dx-s*.13,c.dy-s*.14),q);canvas.drawLine(Offset(c.dx,c.dy+s*.04),Offset(c.dx+s*.14,c.dy-s*.05),q);}
  void _heart(Canvas canvas,Offset c,double s,Paint p,Paint q){final path=Path()..moveTo(c.dx,c.dy+s*.29)..cubicTo(c.dx-s*.08,c.dy+s*.18,c.dx-s*.30,c.dy+s*.04,c.dx-s*.26,c.dy-s*.12)..cubicTo(c.dx-s*.23,c.dy-s*.29,c.dx-s*.05,c.dy-s*.31,c.dx,c.dy-s*.17)..cubicTo(c.dx+s*.05,c.dy-s*.31,c.dx+s*.23,c.dy-s*.29,c.dx+s*.26,c.dy-s*.12)..cubicTo(c.dx+s*.30,c.dy+s*.04,c.dx+s*.08,c.dy+s*.18,c.dx,c.dy+s*.29);canvas.drawPath(path,p);canvas.drawCircle(c,s*.07,q);}
  void _spiral(Canvas canvas,Offset c,double s,Paint p,Paint q){final path=Path();for(var i=0;i<=90;i++){final t=i/90,a=t*math.pi*4.4,r=s*.27*(1-t),x=c.dx+math.cos(a)*r,y=c.dy+math.sin(a)*r;if(i==0)path.moveTo(x,y);else path.lineTo(x,y);}canvas.drawPath(path,p);canvas.drawCircle(c,s*.045,q);}
  void _orb(Canvas canvas,Offset c,double s,Paint p,Paint q){canvas.drawCircle(c,s*.20,p);canvas.drawOval(Rect.fromCenter(center:c,width:s*.70,height:s*.25),q);canvas.drawLine(Offset(c.dx,c.dy-s*.30),Offset(c.dx,c.dy+s*.30),q);}
  void _crystal(Canvas canvas,Offset c,double s,Paint p,Paint q){final path=Path()..moveTo(c.dx,c.dy-s*.30)..lineTo(c.dx+s*.18,c.dy-s*.06)..lineTo(c.dx+s*.12,c.dy+s*.24)..lineTo(c.dx,c.dy+s*.31)..lineTo(c.dx-s*.12,c.dy+s*.24)..lineTo(c.dx-s*.18,c.dy-s*.06)..close();canvas.drawPath(path,p);canvas.drawLine(Offset(c.dx,c.dy-s*.30),Offset(c.dx,c.dy+s*.31),q);}
  @override bool shouldRepaint(covariant _CoreSymbolPainter oldDelegate)=>true;
}

class _HologramPainter extends CustomPainter {
  final double phase; final Color primary, secondary;
  _HologramPainter({required this.phase,required this.primary,required this.secondary});
  @override void paint(Canvas canvas,Size size){final c=Offset(size.width/2,size.height/2),maxR=size.shortestSide*.45;for(var i=0;i<6;i++){final r=maxR*(.28+i*.12);canvas.drawCircle(c,r,Paint()..style=PaintingStyle.stroke..strokeWidth=i==3?1.7:.7..color=(i.isEven?primary:secondary).withOpacity(.15));}final p=Paint()..style=PaintingStyle.stroke..strokeWidth=1.3..color=primary.withOpacity(.28);for(var i=0;i<5;i++){final a=phase*math.pi*2+i*2*math.pi/5;canvas.drawLine(Offset(c.dx+math.cos(a)*maxR*.24,c.dy+math.sin(a)*maxR*.24),Offset(c.dx+math.cos(a)*maxR,c.dy+math.sin(a)*maxR),p);}}
  @override bool shouldRepaint(covariant _HologramPainter oldDelegate)=>true;
}

class _RealityMiniPainter extends CustomPainter {
  final double phase; final Color primary,secondary; final int styleIndex;
  _RealityMiniPainter({required this.phase,required this.primary,required this.secondary,required this.styleIndex});
  @override void paint(Canvas canvas,Size size){final c=Offset(size.width/2,size.height/2),p=Paint()..style=PaintingStyle.stroke..strokeWidth=1.4..color=primary.withOpacity(.65),q=Paint()..color=secondary.withOpacity(.30)..maskFilter=const MaskFilter.blur(BlurStyle.normal,10);if(styleIndex==1){for(var i=0;i<5;i++){final x=size.width*(.16+i*.17);canvas.drawCircle(Offset(x,size.height*(.30+math.sin(i)*.08)),7+i.toDouble(),q);}canvas.drawLine(Offset(size.width*.15,size.height*.75),Offset(size.width*.85,size.height*.20),p);}else if(styleIndex==5){final path=Path()..moveTo(c.dx,size.height*.12)..cubicTo(size.width*.82,size.height*.30,size.width*.18,size.height*.70,c.dx,size.height*.88);canvas.drawPath(path,p);canvas.drawCircle(c,12,q);}else{for(var i=0;i<4;i++){canvas.drawOval(Rect.fromCenter(center:c,width:size.width*(.28+i*.16),height:size.height*(.20+i*.08)),p);}canvas.drawCircle(c,8+styleIndex.toDouble(),q);}}
  @override bool shouldRepaint(covariant _RealityMiniPainter oldDelegate)=>true;
}
