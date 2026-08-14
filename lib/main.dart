import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'services/yansi_brain.dart';
import 'services/yansi_companion_orchestrator.dart';
import 'services/yansi_context_fusion.dart';
import 'services/yansi_runtime_guardian.dart';

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
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF010509),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00E5FF),
            brightness: Brightness.dark,
          ),
        ),
        home: LifeOSShell(prefs: prefs),
      );
}

class LifeOSShell extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOSShell({super.key, required this.prefs});

  @override
  State<LifeOSShell> createState() => _LifeOSShellState();
}

class _LifeOSShellState extends State<LifeOSShell>
    with WidgetsBindingObserver {
  static const _profileVersion = 2;

  late final YansiBrain _brain;
  late final YansiRuntimeGuardian _guardian;
  late final YansiCompanionOrchestrator _companion;
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _input = TextEditingController();

  String _name = '';
  String _country = 'India';
  String _currency = 'INR';
  String _design = 'neural_flow';
  String _message = 'Yansi is ready.';
  String _activeCore = '';
  bool _onboarding = true;
  bool _listening = false;
  bool _ambientListening = false;
  bool _speaking = false;
  bool _drawer = false;
  int _pulse = 0;
  Timer? _listenRestart;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _brain = YansiBrain(prefs: widget.prefs);
    _guardian = YansiRuntimeGuardian(prefs: widget.prefs)..start();
    _companion = YansiCompanionOrchestrator(prefs: widget.prefs);
    _name = widget.prefs.getString('user_name')?.trim() ?? '';
    _country = widget.prefs.getString('user_country') ?? 'India';
    _currency = widget.prefs.getString('user_currency') ?? 'INR';
    _design = widget.prefs.getString('lifeos_design') ?? 'neural_flow';
    _onboarding = widget.prefs.getInt('lifeos_profile_version') != _profileVersion;
    _configureVoice();
    if (!_onboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _refreshCompanion();
        await _welcome();
      });
    }
  }

  Future<void> _configureVoice() async {
    await _tts.setSpeechRate(.46);
    await _tts.setPitch(1.0);
    _tts.setStartHandler(() {
      if (mounted) setState(() => _speaking = true);
    });
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
      _restartAmbientListening();
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _speaking = false);
      _restartAmbientListening();
    });
  }

  Future<void> _welcome() async {
    if (_name.isEmpty) return;
    await _speak(
      'Welcome, $_name. I’m Yansi, your personal LifeOS AI agent. I’m here whenever you need me.',
    );
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    if (widget.prefs.getBool('permission_voice') == false) return;
    await _speech.stop();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _refreshCompanion() async {
    try {
      final snapshot = await _companion.refresh(userIsActive: true);
      if (!mounted) return;
      if (snapshot.advice.trim().isNotEmpty) {
        setState(() => _message = snapshot.advice);
      }
    } catch (_) {}
  }

  Future<void> _startListening({bool ambient = false}) async {
    if (_listening) return;
    if (widget.prefs.getBool('permission_voice') == false) {
      _show('Voice is disabled in Permissions.');
      return;
    }
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _listening = false);
          if (ambient && _ambientListening && !_speaking) {
            _restartAmbientListening();
          }
        }
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
        if (ambient && _ambientListening) _restartAmbientListening();
      },
    );
    if (!available) {
      _show('Microphone access is not available. Please allow microphone permission for LIFEOZ.');
      return;
    }
    if (mounted) setState(() => _listening = true);
    await _speech.listen(
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        if (!mounted) return;
        _input.text = result.recognizedWords;
        _input.selection = TextSelection.fromPosition(
          TextPosition(offset: _input.text.length),
        );
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          _process(result.recognizedWords);
        }
      },
    );
  }

  Future<void> _stopListening() async {
    _ambientListening = false;
    _listenRestart?.cancel();
    await _speech.stop();
    if (mounted) setState(() => _listening = false);
  }

  void _restartAmbientListening() {
    _listenRestart?.cancel();
    if (!_ambientListening || _speaking || _onboarding) return;
    _listenRestart = Timer(const Duration(milliseconds: 450), () {
      if (mounted && _ambientListening && !_speaking) {
        _startListening(ambient: true);
      }
    });
  }

  Future<void> _toggleVoice() async {
    if (_listening || _ambientListening) {
      await _stopListening();
      return;
    }
    _ambientListening = true;
    await _startListening(ambient: true);
  }

  Future<void> _process(String text) async {
    if (text.trim().isEmpty) return;
    _ambientListening = false;
    await _speech.stop();
    if (mounted) setState(() => _listening = false);
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await _brain.process(text);
    if (!mounted) return;
    setState(() {
      _message = result.response;
      _pulse++;
    });
    _input.clear();
    await _refreshCompanion();
    await _speak(result.response);
  }

  void _show(String text) {
    if (mounted) setState(() => _message = text);
  }

  void _openCore(String core) {
    setState(() => _activeCore = core);
    _speak(_coreExplanation(core));
  }

  String _coreExplanation(String core) => switch (core) {
        'MONEY' => 'Money intelligence. I connect spending, income, bills and investments.',
        'PRODUCTIVITY' => 'Productivity intelligence. I track priorities, tasks and unfinished work.',
        'CALENDAR' => 'Time intelligence. I connect renewals, bills and important dates.',
        'HOUSEHOLD' => 'Household intelligence. I learn recurring shopping and kitchen requirements.',
        _ => 'Goals intelligence. I connect your targets with the actions that move them forward.',
      };

  Future<void> _completeOnboarding(_Profile profile) async {
    await widget.prefs.setString('user_name', profile.name);
    await widget.prefs.setString('user_country', profile.country);
    await widget.prefs.setString('user_currency', profile.currency);
    await widget.prefs.setString('lifeos_design', profile.design);
    await widget.prefs.setInt('lifeos_profile_version', _profileVersion);
    await widget.prefs.setBool('permission_voice', true);
    await widget.prefs.setBool('permission_personal_learning', true);
    await widget.prefs.setBool('permission_background_ai', false);
    if (!mounted) return;
    setState(() {
      _name = profile.name;
      _country = profile.country;
      _currency = profile.currency;
      _design = profile.design;
      _onboarding = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await _refreshCompanion();
    await _welcome();
    _ambientListening = true;
    _startListening(ambient: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_onboarding) {
      _refreshCompanion();
      if (_ambientListening && !_speaking) _restartAmbientListening();
    }
    if (state == AppLifecycleState.paused) {
      _speech.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _listenRestart?.cancel();
    _guardian.dispose();
    _tts.stop();
    _speech.stop();
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_onboarding) {
      return _Onboarding(
        initialName: _name,
        initialCountry: _country,
        initialCurrency: _currency,
        initialDesign: _design,
        onComplete: _completeOnboarding,
      );
    }
    final palette = _DesignPalette.from(_design);
    return Scaffold(
      body: Stack(
        children: [
          _NeuralBackground(palette: palette, pulse: _pulse),
          SafeArea(
            child: Column(
              children: [
                _topBar(palette),
                Expanded(
                  child: _activeCore.isEmpty
                      ? _home(palette)
                      : _coreReport(_activeCore, palette),
                ),
              ],
            ),
          ),
          if (_drawer) _drawerPanel(palette),
        ],
      ),
    );
  }

  Widget _topBar(_DesignPalette p) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(
          children: [
            _iconButton(Icons.menu_rounded, () => setState(() => _drawer = !_drawer), p),
            const Spacer(),
            Column(
              children: [
                Text('LIFEOZ', style: TextStyle(letterSpacing: 5, fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(.95))),
                Text('ONE SCREEN • ONE TAP • ONE REPORT', style: TextStyle(fontSize: 7, letterSpacing: 1.6, color: Colors.white.withOpacity(.35))),
              ],
            ),
            const Spacer(),
            _iconButton(Icons.notifications_none_rounded, () => _show('Yansi is monitoring only the permissions you approved.'), p),
          ],
        ),
      );

  Widget _home(_DesignPalette p) => LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(14, c.maxHeight < 700 ? 8 : 18, 14, 20),
          child: Column(
            children: [
              Text('Good day, $_name', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Your life. Connected intelligently.', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.45))),
              const SizedBox(height: 10),
              _HolographicOrb(p: p, pulse: _pulse, listening: _listening, speaking: _speaking, onTap: _toggleVoice),
              const SizedBox(height: 8),
              _ambientMessage(p),
              const SizedBox(height: 10),
              _coreRing(p),
              const SizedBox(height: 6),
              _commandBar(p),
              const SizedBox(height: 10),
              _quickInsight(p),
            ],
          ),
        ),
      );

  Widget _ambientMessage(_DesignPalette p) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        child: Container(
          key: ValueKey(_message),
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: p.surface.withOpacity(.50),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.primary.withOpacity(.15)),
            boxShadow: [BoxShadow(color: p.primary.withOpacity(.04), blurRadius: 24)],
          ),
          child: Text(_message, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, height: 1.35, color: Colors.white.withOpacity(.78))),
        ),
      );

  Widget _coreRing(_DesignPalette p) {
    final cores = [
      _Core('MONEY', Icons.account_balance_wallet_rounded, p.c1),
      _Core('PRODUCTIVITY', Icons.bolt_rounded, p.c2),
      _Core('CALENDAR', Icons.calendar_month_rounded, p.c3),
      _Core('HOUSEHOLD', Icons.shopping_basket_rounded, p.c4),
      _Core('GOALS', Icons.track_changes_rounded, p.c5),
    ];
    return SizedBox(
      height: 210,
      width: 340,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: const Size(330, 210), painter: _CoreNetworkPainter(palette: p)),
          Container(width: 132, height: 132, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.primary.withOpacity(.10)), boxShadow: [BoxShadow(color: p.primary.withOpacity(.05), blurRadius: 38)])),
          ...List.generate(cores.length, (i) {
            final angle = -math.pi / 2 + i * 2 * math.pi / cores.length;
            return Transform.translate(
              offset: Offset(math.cos(angle) * 102, math.sin(angle) * 82),
              child: _CoreButton(core: cores[i], onTap: () => _openCore(cores[i].id)),
            );
          }),
          _MiniOrb(p: p, size: 74),
        ],
      ),
    );
  }

  Widget _commandBar(_DesignPalette p) => Container(
        decoration: BoxDecoration(color: p.surface.withOpacity(.92), borderRadius: BorderRadius.circular(24), border: Border.all(color: p.primary.withOpacity(.14)), boxShadow: [BoxShadow(color: p.primary.withOpacity(.05), blurRadius: 26)]),
        child: Row(children: [
          const SizedBox(width: 14),
          Icon(_listening ? Icons.graphic_eq_rounded : Icons.auto_awesome_rounded, size: 18, color: p.primary),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: _input, onSubmitted: _process, style: const TextStyle(fontSize: 12), decoration: const InputDecoration(hintText: 'Talk to Yansi…', hintStyle: TextStyle(fontSize: 12, color: Colors.white38), border: InputBorder.none))),
          IconButton(onPressed: _toggleVoice, icon: Icon(_listening ? Icons.stop_circle_rounded : Icons.mic_none_rounded, color: _listening ? p.c2 : Colors.white70, size: 23)),
          IconButton(onPressed: () => _process(_input.text), icon: Icon(Icons.arrow_upward_rounded, size: 20, color: p.primary)),
        ]),
      );

  Widget _quickInsight(_DesignPalette p) => FutureBuilder<YansiContextSnapshot>(
        future: YansiContextFusion(prefs: widget.prefs).build(),
        builder: (context, snapshot) {
          final d = snapshot.data;
          if (d == null) return const SizedBox.shrink();
          return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _Stat('${d.openTasks}', 'tasks', p),
            _Stat('${d.upcomingReminders}', 'due soon', p),
            _Stat('${_currencySymbol(_currency)}${d.recentSpend.toStringAsFixed(0)}', '30d spend', p),
          ]);
        },
      );

  Widget _coreReport(String core, _DesignPalette p) => FutureBuilder<List<Map<String, dynamic>>>(
        future: _recordsFor(core),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <Map<String, dynamic>>[];
          final title = _coreTitle(core);
          return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 30), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _iconButton(Icons.arrow_back_rounded, () => setState(() => _activeCore = ''), p),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
              _iconButton(Icons.auto_awesome_rounded, () => _process('Give me my $title report'), p),
            ]),
            const SizedBox(height: 16),
            Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), gradient: LinearGradient(colors: [p.c1.withOpacity(.13), p.surface]), border: Border.all(color: p.primary.withOpacity(.13))), child: Row(children: [
              _MiniOrb(p: p, size: 64), const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(core == 'MONEY' ? '${_currencySymbol(_currency)}${rows.fold<double>(0, (a, r) => a + ((r['amount'] as num?)?.toDouble() ?? 0)).toStringAsFixed(0)}' : '${rows.length}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), Text(core == 'MONEY' ? 'Recorded value' : 'Recorded items', style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(.42)))])
            ])),
            const SizedBox(height: 14),
            if (rows.isEmpty) _emptyCore(core, p) else ...rows.take(20).map((r) => _recordTile(core, r, p)),
            const SizedBox(height: 8), _commandBar(p),
          ]));
        },
      );

  Widget _emptyCore(String core, _DesignPalette p) => Container(width: double.infinity, padding: const EdgeInsets.all(26), decoration: BoxDecoration(color: p.surface.withOpacity(.55), borderRadius: BorderRadius.circular(24), border: Border.all(color: p.primary.withOpacity(.08))), child: Column(children: [Icon(_coreIcon(core), size: 32, color: p.primary), const SizedBox(height: 10), const Text('No records yet'), const SizedBox(height: 6), Text(_coreHint(core), textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.42)))]));

  Widget _recordTile(String core, Map<String, dynamic> r, _DesignPalette p) {
    final value = r['text'] ?? r['task'] ?? r['item'] ?? r['goal'] ?? r['title'] ?? '';
    final amount = r['amount'];
    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: p.surface.withOpacity(.58), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(.035))), child: Row(children: [Icon(_coreIcon(core), size: 18, color: p.primary), const SizedBox(width: 10), Expanded(child: Text('$value', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))), if (amount is num) Text('${_currencySymbol(_currency)}${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))]));
  }

  Widget _drawerPanel(_DesignPalette p) => Positioned.fill(child: GestureDetector(onTap: () => setState(() => _drawer = false), child: Container(color: Colors.black.withOpacity(.68), alignment: Alignment.centerLeft, child: GestureDetector(onTap: () {}, child: Container(width: 300, height: double.infinity, padding: const EdgeInsets.fromLTRB(22, 58, 20, 20), decoration: BoxDecoration(color: const Color(0xFF041016), border: Border(right: BorderSide(color: p.primary.withOpacity(.12))), boxShadow: [BoxShadow(color: p.primary.withOpacity(.08), blurRadius: 30)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [_MiniOrb(p: p, size: 42), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('YANSI', style: TextStyle(letterSpacing: 3, color: p.primary, fontWeight: FontWeight.w800)), Text('PERSONAL AI AGENT', style: TextStyle(fontSize: 7, letterSpacing: 1.4, color: Colors.white.withOpacity(.35)))])]),
    const SizedBox(height: 26),
    _drawerItem(Icons.person_outline_rounded, 'My profile', _profile, p),
    _drawerItem(Icons.public_rounded, 'Country & currency', _localeSettings, p),
    _drawerItem(Icons.palette_outlined, 'Visual identity', _designSettings, p),
    _drawerItem(Icons.tune_rounded, 'Permissions', _permissions, p),
    _drawerItem(Icons.memory_rounded, 'Memory & learning', _memory, p),
    const Spacer(),
    Text('Ambient AI • user controlled • local-first', style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(.28))),
  ])))));

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap, _DesignPalette p) => ListTile(contentPadding: EdgeInsets.zero, leading: Icon(icon, size: 20, color: p.primary), title: Text(label, style: const TextStyle(fontSize: 12)), onTap: onTap);

  Future<void> _profile() async {
    setState(() => _drawer = false);
    final name = TextEditingController(text: _name);
    await showDialog<void>(context: context, builder: (c) => AlertDialog(backgroundColor: const Color(0xFF071218), title: const Text('My profile'), content: TextField(controller: name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Name')), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')), FilledButton(onPressed: () async { if (name.text.trim().isNotEmpty) { await widget.prefs.setString('user_name', name.text.trim()); if (mounted) setState(() => _name = name.text.trim()); } if (c.mounted) Navigator.pop(c); }, child: const Text('Save'))]));
    name.dispose();
  }

  Future<void> _localeSettings() async {
    setState(() => _drawer = false);
    final country = await _pick('Country', _countries, _country);
    if (country == null) return;
    final currency = await _pick('Currency', _currencies, _currency);
    if (currency == null) return;
    await widget.prefs.setString('user_country', country);
    await widget.prefs.setString('user_currency', currency);
    if (mounted) setState(() { _country = country; _currency = currency; });
  }

  Future<void> _designSettings() async {
    setState(() => _drawer = false);
    final chosen = await _pick('Visual identity', _designs, _design);
    if (chosen == null) return;
    await widget.prefs.setString('lifeos_design', chosen);
    if (mounted) setState(() => _design = chosen);
  }

  Future<String?> _pick(String title, Map<String, String> values, String selected) async => showModalBottomSheet<String>(context: context, backgroundColor: const Color(0xFF071218), builder: (c) => SafeArea(child: ListView(padding: const EdgeInsets.all(18), shrinkWrap: true, children: [Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)), const SizedBox(height: 10), ...values.entries.map((e) => ListTile(title: Text(e.value), trailing: e.key == selected ? const Icon(Icons.check_circle_rounded, color: Color(0xFF00E5FF)) : null, onTap: () => Navigator.pop(c, e.key)))])));

  Future<void> _permissions() async {
    setState(() => _drawer = false);
    await showModalBottomSheet<void>(context: context, backgroundColor: const Color(0xFF071218), builder: (c) => StatefulBuilder(builder: (context, setSheet) { const items = {'Voice': 'permission_voice', 'Notifications': 'permission_notifications', 'Web knowledge': 'permission_web_knowledge', 'Personal learning': 'permission_personal_learning', 'Background AI': 'permission_background_ai'}; return SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Permissions', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)), const SizedBox(height: 8), ...items.entries.map((e) => SwitchListTile(title: Text(e.key, style: const TextStyle(fontSize: 12)), value: widget.prefs.getBool(e.value) ?? false, onChanged: (v) async { await widget.prefs.setBool(e.value, v); setSheet(() {}); })]))); }));
  }

  Future<void> _memory() async {
    setState(() => _drawer = false);
    await showDialog<void>(context: context, builder: (c) => AlertDialog(backgroundColor: const Color(0xFF081218), title: const Text('Memory & learning'), content: const Text('Yansi uses only approved LifeOS history and learning. Memories are retained according to their lifecycle rules. Core safety rules and application behaviour are never self-rewritten.', style: TextStyle(fontSize: 12, height: 1.45)), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close'))]));
  }

  Widget _iconButton(IconData icon, VoidCallback onTap, _DesignPalette p) => IconButton(onPressed: onTap, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 36, minHeight: 36), icon: Icon(icon, size: 20, color: Colors.white.withOpacity(.76)));

  String _coreTitle(String core) => switch (core) { 'MONEY' => 'Money', 'PRODUCTIVITY' => 'Productivity', 'CALENDAR' => 'Calendar', 'HOUSEHOLD' => 'Household', _ => 'Goals' };
  IconData _coreIcon(String core) => switch (core) { 'MONEY' => Icons.account_balance_wallet_rounded, 'PRODUCTIVITY' => Icons.bolt_rounded, 'CALENDAR' => Icons.calendar_month_rounded, 'HOUSEHOLD' => Icons.shopping_basket_rounded, _ => Icons.track_changes_rounded };
  String _coreHint(String core) => switch (core) { 'MONEY' => 'Tell Yansi what you spent or ask for a money report.', 'PRODUCTIVITY' => 'Tell Yansi what you need to finish today.', 'CALENDAR' => 'Tell Yansi about a due date or renewal.', 'HOUSEHOLD' => 'Tell Yansi what to add to shopping.', _ => 'Tell Yansi about a goal you want to achieve.' };

  Future<List<Map<String, dynamic>>> _recordsFor(String core) async {
    final keys = switch (core) { 'MONEY' => ['yansi_expenses', 'yansi_income'], 'PRODUCTIVITY' => ['yansi_tasks'], 'CALENDAR' => ['yansi_reminders'], 'HOUSEHOLD' => ['yansi_household'], _ => ['yansi_goals'] };
    final records = <Map<String, dynamic>>[];
    for (final key in keys) {
      for (final raw in widget.prefs.getStringList(key) ?? const <String>[]) { try { final decoded = jsonDecode(raw); if (decoded is Map) records.add(Map<String, dynamic>.from(decoded)); } catch (_) {} }
    }
    records.sort((a, b) => '${b['date'] ?? ''}'.compareTo('${a['date'] ?? ''}'));
    return records;
  }
}

class _Profile {
  final String name;
  final String country;
  final String currency;
  final String design;
  const _Profile({required this.name, required this.country, required this.currency, required this.design});
}

class _Onboarding extends StatefulWidget {
  final String initialName;
  final String initialCountry;
  final String initialCurrency;
  final String initialDesign;
  final Future<void> Function(_Profile) onComplete;
  const _Onboarding({required this.initialName, required this.initialCountry, required this.initialCurrency, required this.initialDesign, required this.onComplete});
  @override
  State<_Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<_Onboarding> {
  late final PageController _pages;
  late final TextEditingController _name;
  int _page = 0;
  late String _country;
  late String _currency;
  late String _design;
  bool _saving = false;

  @override
  void initState() { super.initState(); _pages = PageController(); _name = TextEditingController(text: widget.initialName); _country = widget.initialCountry; _currency = widget.initialCurrency; _design = widget.initialDesign; }
  @override
  void dispose() { _pages.dispose(); _name.dispose(); super.dispose(); }

  Future<void> _next() async {
    if (_page == 0 && _name.text.trim().isEmpty) return;
    if (_page < 3) { setState(() => _page++); _pages.animateToPage(_page, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic); return; }
    setState(() => _saving = true);
    await widget.onComplete(_Profile(name: _name.text.trim(), country: _country, currency: _currency, design: _design));
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: Stack(children: [const _OnboardingBackground(), SafeArea(child: Column(children: [Padding(padding: const EdgeInsets.fromLTRB(22, 20, 22, 0), child: Row(children: [const Text('LIFEOZ', style: TextStyle(letterSpacing: 5, fontSize: 18, fontWeight: FontWeight.w900)), const Spacer(), Text('SETUP', style: TextStyle(fontSize: 8, letterSpacing: 2, color: Colors.white38))])), Expanded(child: PageView(controller: _pages, physics: const NeverScrollableScrollPhysics(), children: [_profilePage(), _countryPage(), _currencyPage(), _designPage()])), Padding(padding: const EdgeInsets.fromLTRB(22, 8, 22, 24), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) => AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.symmetric(horizontal: 4), width: i == _page ? 24 : 6, height: 4, decoration: BoxDecoration(color: i == _page ? const Color(0xFF00E5FF) : Colors.white12, borderRadius: BorderRadius.circular(8))))), const SizedBox(height: 14), SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: _saving ? null : _next, child: Text(_page == 3 ? 'ENTER LIFEOZ' : 'CONTINUE')))]))]))]));

  Widget _profilePage() => _step(icon: Icons.person_outline_rounded, title: 'Your identity', subtitle: 'Yansi needs a profile so LifeOS can speak to the right person.', child: TextField(controller: _name, textCapitalization: TextCapitalization.words, style: const TextStyle(fontSize: 18), decoration: _decoration('Your name')));
  Widget _countryPage() => _step(icon: Icons.public_rounded, title: 'Where do you live?', subtitle: 'This sets local dates, regional intelligence and defaults.', child: _choiceGrid(_countries, _country, (v) => setState(() => _country = v)));
  Widget _currencyPage() => _step(icon: Icons.currency_exchange_rounded, title: 'Your currency', subtitle: 'All money intelligence will use this currency.', child: _choiceGrid(_currencies, _currency, (v) => setState(() => _currency = v)));
  Widget _designPage() => _step(icon: Icons.auto_awesome_rounded, title: 'Choose Yansi’s visual identity', subtitle: 'The intelligence stays the same. The visual world changes.', child: _choiceGrid(_designs, _design, (v) => setState(() => _design = v)));

  Widget _step({required IconData icon, required String title, required String subtitle, required Widget child}) => SingleChildScrollView(padding: const EdgeInsets.fromLTRB(22, 35, 22, 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_MiniOrb(p: _DesignPalette.from(_design), size: 74), const SizedBox(height: 24), Text(title, style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.white54, height: 1.45)), const SizedBox(height: 26), child]));
  InputDecoration _decoration(String label) => InputDecoration(labelText: label, filled: true, fillColor: Colors.white.withOpacity(.035), border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none));
  Widget _choiceGrid(Map<String, String> values, String selected, ValueChanged<String> onTap) => Wrap(spacing: 10, runSpacing: 10, children: values.entries.map((e) => GestureDetector(onTap: () => onTap(e.key), child: AnimatedContainer(duration: const Duration(milliseconds: 180), width: 150, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: selected == e.key ? const Color(0xFF00E5FF).withOpacity(.10) : Colors.white.withOpacity(.025), borderRadius: BorderRadius.circular(18), border: Border.all(color: selected == e.key ? const Color(0xFF00E5FF).withOpacity(.55) : Colors.white.withOpacity(.07))), child: Row(children: [Expanded(child: Text(e.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))), if (selected == e.key) const Icon(Icons.check_rounded, size: 17, color: Color(0xFF00E5FF))])))).toList());
}

class _DesignPalette {
  final Color primary, c1, c2, c3, c4, c5, surface;
  const _DesignPalette(this.primary, this.c1, this.c2, this.c3, this.c4, this.c5, this.surface);
  static _DesignPalette from(String id) => switch (id) {
    'quantum_pulse' => const _DesignPalette(Color(0xFF8A9CFF), Color(0xFF00E5FF), Color(0xFFB06CFF), Color(0xFF8A9CFF), Color(0xFF00FFC6), Color(0xFFFF5FD2), Color(0xFF07101C)),
    'holo_prism' => const _DesignPalette(Color(0xFF00FFC6), Color(0xFF00E5FF), Color(0xFF63FFB1), Color(0xFFB8FF4D), Color(0xFF00FFC6), Color(0xFF8A9CFF), Color(0xFF061414)),
    'aurora_core' => const _DesignPalette(Color(0xFF63FFB1), Color(0xFFB8FF4D), Color(0xFF63FFB1), Color(0xFF00E5FF), Color(0xFF00FFC6), Color(0xFF8A9CFF), Color(0xFF06120F)),
    'cyber_matrix' => const _DesignPalette(Color(0xFFB8FF4D), Color(0xFFB8FF4D), Color(0xFF00FFC6), Color(0xFF00E5FF), Color(0xFF63FFB1), Color(0xFF8A9CFF), Color(0xFF071008)),
    _ => const _DesignPalette(Color(0xFF00E5FF), Color(0xFF00E5FF), Color(0xFF63FFB1), Color(0xFF8A9CFF), Color(0xFF00FFC6), Color(0xFFB8FF4D), Color(0xFF061117)),
  };
}

const _countries = <String, String>{'India': 'India', 'United States': 'United States', 'United Kingdom': 'United Kingdom', 'United Arab Emirates': 'United Arab Emirates', 'Australia': 'Australia', 'Canada': 'Canada', 'Singapore': 'Singapore'};
const _currencies = <String, String>{'INR': '₹ Indian Rupee', 'USD': '\$ US Dollar', 'GBP': '£ Pound Sterling', 'AED': 'د.إ UAE Dirham', 'AUD': 'A$ Australian Dollar', 'CAD': 'C$ Canadian Dollar', 'SGD': 'S$ Singapore Dollar'};
const _designs = <String, String>{'neural_flow': 'Neural Flow', 'quantum_pulse': 'Quantum Pulse', 'holo_prism': 'Holo Prism', 'aurora_core': 'Aurora Core', 'cyber_matrix': 'Cyber Matrix'};
String _currencySymbol(String code) => switch (code) { 'USD' => '\$', 'GBP' => '£', 'AED' => 'د.إ ', 'AUD' => 'A\$', 'CAD' => 'C\$', 'SGD' => 'S\$', _ => '₹' };

class _Core { final String id; final IconData icon; final Color color; const _Core(this.id, this.icon, this.color); }
class _CoreButton extends StatelessWidget { final _Core core; final VoidCallback onTap; const _CoreButton({required this.core, required this.onTap}); @override Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF061016), border: Border.all(color: core.color.withOpacity(.52), width: 1.2), boxShadow: [BoxShadow(color: core.color.withOpacity(.18), blurRadius: 22), BoxShadow(color: core.color.withOpacity(.07), blurRadius: 42)]), child: Icon(core.icon, color: core.color, size: 24))); }
class _MiniOrb extends StatelessWidget { final _DesignPalette p; final double size; const _MiniOrb({required this.p, required this.size}); @override Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [p.primary.withOpacity(.35), p.primary.withOpacity(.11), Colors.transparent]), border: Border.all(color: p.primary.withOpacity(.42)), boxShadow: [BoxShadow(color: p.primary.withOpacity(.16), blurRadius: 30)]), child: Icon(Icons.auto_awesome_rounded, color: Colors.white.withOpacity(.9), size: size * .36)); }
class _HolographicOrb extends StatelessWidget { final _DesignPalette p; final int pulse; final bool listening, speaking; final VoidCallback onTap; const _HolographicOrb({required this.p, required this.pulse, required this.listening, required this.speaking, required this.onTap}); @override Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: TweenAnimationBuilder<double>(key: ValueKey('$pulse-$listening-$speaking'), tween: Tween(begin: .96, end: listening || speaking ? 1.08 : 1.0), duration: const Duration(milliseconds: 500), builder: (context, scale, child) => Transform.scale(scale: scale, child: child), child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [p.primary.withOpacity(.34), p.primary.withOpacity(.12), Colors.transparent]), border: Border.all(color: p.primary.withOpacity(.48), width: 1.3), boxShadow: [BoxShadow(color: p.primary.withOpacity(.18), blurRadius: 55), BoxShadow(color: p.c2.withOpacity(.08), blurRadius: 90)]), child: Stack(alignment: Alignment.center, children: [Container(width: 112, height: 112, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.primary.withOpacity(.18))), child: CustomPaint(painter: _OrbParticlePainter(palette: p, pulse: pulse))), Icon(listening ? Icons.graphic_eq_rounded : speaking ? Icons.record_voice_over_rounded : Icons.auto_awesome_rounded, color: Colors.white.withOpacity(.95), size: 42)])))); }
class _OrbParticlePainter extends CustomPainter { final _DesignPalette palette; final int pulse; const _OrbParticlePainter({required this.palette, required this.pulse}); @override void paint(Canvas canvas, Size size) { final center = size.center(Offset.zero); final r = size.width * .38; for (var i = 0; i < 18; i++) { final a = (i / 18) * math.pi * 2 + pulse * .025; final point = Offset(center.dx + math.cos(a) * r, center.dy + math.sin(a) * r); final paint = Paint()..color = (i.isEven ? palette.primary : palette.c2).withOpacity(.45)..style = PaintingStyle.fill; canvas.drawCircle(point, i % 3 == 0 ? 2.1 : 1.2, paint); } } @override bool shouldRepaint(covariant _OrbParticlePainter oldDelegate) => oldDelegate.pulse != pulse; }
class _CoreNetworkPainter extends CustomPainter { final _DesignPalette palette; const _CoreNetworkPainter({required this.palette}); @override void paint(Canvas canvas, Size size) { final c = size.center(Offset.zero); final paint = Paint()..color = palette.primary.withOpacity(.08)..strokeWidth = .8..style = PaintingStyle.stroke; for (var i = 0; i < 5; i++) { final a = -math.pi / 2 + i * 2 * math.pi / 5; final p = Offset(c.dx + math.cos(a) * 102, c.dy + math.sin(a) * 82); canvas.drawLine(c, p, paint); canvas.drawCircle(p, 2.2, paint); } } @override bool shouldRepaint(covariant _CoreNetworkPainter oldDelegate) => false; }
class _NeuralBackground extends StatelessWidget { final _DesignPalette palette; final int pulse; const _NeuralBackground({required this.palette, required this.pulse}); @override Widget build(BuildContext context) => IgnorePointer(child: CustomPaint(size: Size.infinite, painter: _NeuralBackgroundPainter(palette: palette, pulse: pulse))); }
class _NeuralBackgroundPainter extends CustomPainter { final _DesignPalette palette; final int pulse; const _NeuralBackgroundPainter({required this.palette, required this.pulse}); @override void paint(Canvas canvas, Size size) { final center = Offset(size.width * .5, size.height * .38); final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = palette.primary.withOpacity(.055); for (var i = 0; i < 24; i++) { final a = i * math.pi * 2 / 24 + pulse * .004; final r = 130.0 + (i % 4) * 34; final point = Offset(center.dx + math.cos(a) * r, center.dy + math.sin(a) * r); canvas.drawLine(center, point, paint); canvas.drawCircle(point, 1.8, paint); } } @override bool shouldRepaint(covariant _NeuralBackgroundPainter oldDelegate) => oldDelegate.pulse != pulse; }
class _OnboardingBackground extends StatelessWidget { const _OnboardingBackground(); @override Widget build(BuildContext context) => const ColoredBox(color: Color(0xFF010509), child: CustomPaint(painter: _OnboardingPainter())); }
class _OnboardingPainter extends CustomPainter { const _OnboardingPainter(); @override void paint(Canvas canvas, Size size) { final center = Offset(size.width * .5, size.height * .32); final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0xFF00E5FF).withOpacity(.06); for (var i = 0; i < 18; i++) { final a = i * math.pi * 2 / 18; final r = 90.0 + (i % 3) * 40; canvas.drawLine(center, Offset(center.dx + math.cos(a) * r, center.dy + math.sin(a) * r), paint); } } @override bool shouldRepaint(covariant _OnboardingPainter oldDelegate) => false; }
class _Stat extends StatelessWidget { final String value, label; final _DesignPalette p; const _Stat(this.value, this.label, this.p); @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: p.surface.withOpacity(.58), borderRadius: BorderRadius.circular(15), border: Border.all(color: p.primary.withOpacity(.08))), child: Column(children: [Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)), Text(label, style: TextStyle(fontSize: 7, color: Colors.white.withOpacity(.4)))])); }
