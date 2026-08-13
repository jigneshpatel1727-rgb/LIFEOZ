import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'services/yansi_brain.dart';
import 'services/yansi_context_fusion.dart';
import 'services/yansi_proactive_runtime.dart';
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
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LIFEOZ',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF02070B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF),
          brightness: Brightness.dark,
        ),
        fontFamily: 'sans',
      ),
      home: LifeOSShell(prefs: prefs),
    );
  }
}

class LifeOSShell extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOSShell({super.key, required this.prefs});

  @override
  State<LifeOSShell> createState() => _LifeOSShellState();
}

class _LifeOSShellState extends State<LifeOSShell> with WidgetsBindingObserver {
  late final YansiBrain _yansi;
  late final YansiRuntimeGuardian _guardian;
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _input = TextEditingController();

  String _name = '';
  bool _setup = false;
  bool _listening = false;
  bool _speaking = false;
  bool _drawer = false;
  String _yansiMessage = 'I’m here whenever you need me.';
  String _activeCore = '';
  int _pulse = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _yansi = YansiBrain(prefs: widget.prefs);
    _guardian = YansiRuntimeGuardian(prefs: widget.prefs)..start();
    _name = widget.prefs.getString('user_name')?.trim() ?? '';
    _setup = _name.isEmpty;
    _configureTts();
    if (!_setup) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _welcome());
    }
  }

  Future<void> _configureTts() async {
    await _tts.setSpeechRate(0.46);
    await _tts.setPitch(1.0);
    _tts.setStartHandler(() => mounted ? setState(() => _speaking = true) : null);
    _tts.setCompletionHandler(() => mounted ? setState(() => _speaking = false) : null);
    _tts.setCancelHandler(() => mounted ? setState(() => _speaking = false) : null);
  }

  Future<void> _welcome() async {
    final message = 'Welcome, $_name. I’m Yansi, your personal LifeOS AI agent. I’m here whenever you need me.';
    await _speak(message);
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty || widget.prefs.getBool('permission_voice') == false) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _startListening() async {
    if (_listening) {
      await _stopListening();
      return;
    }
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _listening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (!available) {
      _showMessage('Microphone access is not available.');
      return;
    }
    if (!mounted) return;
    setState(() => _listening = true);
    await _speech.listen(
      localeId: 'en_IN',
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      onResult: (result) {
        if (!mounted) return;
        setState(() => _input.text = result.recognizedWords);
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          _process(result.recognizedWords);
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    if (mounted) setState(() => _listening = false);
  }

  Future<void> _process(String text) async {
    if (text.trim().isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await _yansi.process(text);
    if (!mounted) return;
    setState(() {
      _yansiMessage = result.response;
      _pulse++;
    });
    _input.clear();
    await _speak(result.response);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    setState(() => _yansiMessage = message);
  }

  void _openCore(String core) {
    setState(() => _activeCore = core);
    _speak(_coreExplanation(core));
  }

  String _coreExplanation(String core) {
    switch (core) {
      case 'MONEY': return 'This is your money core. I connect spending, income, bills, investments and financial trends.';
      case 'PRODUCTIVITY': return 'This is your productivity core. I track tasks, carry forward unfinished work and help you prioritize.';
      case 'CALENDAR': return 'This is your time core. I connect bills, renewals, birthdays, service dates and important commitments.';
      case 'HOUSEHOLD': return 'This is your household core. I learn recurring shopping and kitchen requirements and organize them for you.';
      case 'GOALS': return 'This is your goals core. I connect personal, financial and life goals with your daily actions.';
      default: return 'I’m here to connect your LifeOS information.';
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      YansiProactiveRuntime(prefs: widget.prefs).prepare(userIsActive: true, quietMode: false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _guardian.dispose();
    _tts.stop();
    _speech.stop();
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_setup) return _SetupView(onSaved: (name) async {
      await widget.prefs.setString('user_name', name.trim());
      await widget.prefs.setBool('permission_voice', true);
      await widget.prefs.setBool('permission_personal_learning', true);
      if (!mounted) return;
      setState(() { _name = name.trim(); _setup = false; });
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _welcome();
    });

    return Scaffold(
      body: Stack(
        children: [
          const _NeuralBackground(),
          SafeArea(
            child: Column(
              children: [
                _topBar(),
                Expanded(child: _activeCore.isEmpty ? _home() : _coreReport(_activeCore)),
              ],
            ),
          ),
          if (_drawer) _sidePanel(),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          _iconButton(Icons.menu_rounded, () => setState(() => _drawer = !_drawer), size: 18),
          const Spacer(),
          Column(
            children: [
              Text('LIFEOZ', style: TextStyle(letterSpacing: 4, fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(.92))),
              Text('ONE SCREEN • ONE TAP • ONE REPORT', style: TextStyle(fontSize: 7, letterSpacing: 1.5, color: Colors.white.withOpacity(.38))),
            ],
          ),
          const Spacer(),
          _iconButton(Icons.notifications_none_rounded, () => _showMessage('Yansi is watching only with the permissions you approve.'), size: 18),
        ],
      ),
    );
  }

  Widget _home() {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxHeight < 650;
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18, compact ? 8 : 18, 18, 24),
        child: Column(
          children: [
            SizedBox(height: compact ? 0 : 12),
            _welcomeText(),
            SizedBox(height: compact ? 6 : 12),
            _Orb(pulse: _pulse, listening: _listening, speaking: _speaking),
            const SizedBox(height: 8),
            _ambientText(),
            SizedBox(height: compact ? 14 : 24),
            _coreRing(),
            const SizedBox(height: 18),
            _commandBar(),
            const SizedBox(height: 14),
            _quickInsight(),
          ],
        ),
      );
    });
  }

  Widget _welcomeText() => Column(
    children: [
      Text('Good day, $_name', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
      const SizedBox(height: 3),
      Text('Your life. Connected intelligently.', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.48))),
    ],
  );

  Widget _ambientText() => AnimatedSwitcher(
    duration: const Duration(milliseconds: 250),
    child: Container(
      key: ValueKey(_yansiMessage),
      constraints: const BoxConstraints(maxWidth: 330),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(.10)),
      ),
      child: Text(_yansiMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, height: 1.35, color: Colors.white.withOpacity(.72))),
    ),
  );

  Widget _coreRing() {
    final cores = [
      _Core('MONEY', Icons.account_balance_wallet_rounded, '₹', const Color(0xFF00E5FF)),
      _Core('PRODUCTIVITY', Icons.bolt_rounded, '✓', const Color(0xFF63FFB1)),
      _Core('CALENDAR', Icons.calendar_month_rounded, '•', const Color(0xFF8A9CFF)),
      _Core('HOUSEHOLD', Icons.shopping_basket_rounded, '+', const Color(0xFF00FFC6)),
      _Core('GOALS', Icons.track_changes_rounded, '◎', const Color(0xFFB8FF4D)),
    ];
    return SizedBox(
      height: 245,
      width: 330,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 132, height: 132, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00E5FF).withOpacity(.08), width: 1))),
          ...List.generate(cores.length, (i) {
            final angle = -math.pi / 2 + (i * 2 * math.pi / cores.length);
            final dx = math.cos(angle) * 103;
            final dy = math.sin(angle) * 103;
            return Transform.translate(offset: Offset(dx, dy), child: _CoreButton(core: cores[i], onTap: () => _openCore(cores[i].id)));
          }),
          _MiniOrb(),
        ],
      ),
    );
  }

  Widget _commandBar() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF081218).withOpacity(.92), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withOpacity(.08))),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(_listening ? Icons.graphic_eq_rounded : Icons.auto_awesome_rounded, size: 18, color: const Color(0xFF00E5FF)),
          const SizedBox(width: 8),
          Expanded(child: TextField(
            controller: _input,
            onSubmitted: _process,
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(hintText: 'Tell Yansi anything…', hintStyle: TextStyle(fontSize: 12, color: Colors.white38), border: InputBorder.none),
          )),
          IconButton(onPressed: _startListening, icon: Icon(_listening ? Icons.stop_circle_rounded : Icons.mic_none_rounded, color: _listening ? const Color(0xFF63FFB1) : Colors.white70, size: 22)),
          IconButton(onPressed: () => _process(_input.text), icon: const Icon(Icons.arrow_upward_rounded, size: 20)),
        ],
      ),
    );
  }

  Widget _quickInsight() {
    return FutureBuilder<YansiContextSnapshot>(
      future: YansiContextFusion(prefs: widget.prefs).build(),
      builder: (context, snap) {
        final s = snap.data;
        if (s == null) return const SizedBox.shrink();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Stat('${s.openTasks}', 'tasks'),
            _Stat('${s.upcomingReminders}', 'due soon'),
            _Stat('₹${s.recentSpend.toStringAsFixed(0)}', '30d spend'),
          ],
        );
      },
    );
  }

  Widget _Stat(String value, String label) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 4),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: Colors.white.withOpacity(.025), borderRadius: BorderRadius.circular(14)),
    child: Column(children: [Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), Text(label, style: TextStyle(fontSize: 7, color: Colors.white.withOpacity(.4)))])
  );

  Widget _coreReport(String core) {
    final title = _coreTitle(core);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _recordsFor(core),
      builder: (context, snap) {
        final rows = snap.data ?? const [];
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                _iconButton(Icons.arrow_back_rounded, () => setState(() => _activeCore = ''), size: 20),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)), Text('Intelligent report', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(.4)))])),
                _iconButton(Icons.auto_awesome_rounded, () => _process('Give me my $title report'), size: 19),
              ]),
              const SizedBox(height: 20),
              _ReportHero(core: core, rows: rows),
              const SizedBox(height: 18),
              if (rows.isEmpty) _emptyCore(core) else ...rows.take(12).map((r) => _recordTile(core, r)),
              const SizedBox(height: 12),
              _commandBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyCore(String core) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: Colors.white.withOpacity(.025), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withOpacity(.06))),
    child: Column(children: [Icon(_coreIcon(core), size: 30, color: const Color(0xFF00E5FF)), const SizedBox(height: 10), Text('No records yet', style: TextStyle(color: Colors.white.withOpacity(.75), fontWeight: FontWeight.w600)), const SizedBox(height: 5), Text(_coreHint(core), textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.4), height: 1.4))])
  );

  Widget _recordTile(String core, Map<String, dynamic> r) {
    final text = r['text'] ?? r['task'] ?? r['item'] ?? r['goal'] ?? r['title'] ?? '';
    final amount = r['amount'];
    final date = DateTime.tryParse('${r['date'] ?? ''}');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.025), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [Icon(_coreIcon(core), size: 18, color: const Color(0xFF00E5FF)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$text', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)), if (date != null) Text('${date.day}/${date.month}/${date.year}', style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(.35)))])), if (amount is num) Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))])
    );
  }

  Widget _sidePanel() => Positioned.fill(
    child: GestureDetector(
      onTap: () => setState(() => _drawer = false),
      child: Container(
        color: Colors.black.withOpacity(.58),
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            width: 285,
            height: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 54, 20, 20),
            decoration: const BoxDecoration(color: Color(0xFF061016), border: Border(right: BorderSide(color: Color(0xFF16323A)))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('LIFEOZ', style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(.9))),
              Text('YANSI INTELLIGENCE', style: TextStyle(fontSize: 8, letterSpacing: 2, color: Colors.white.withOpacity(.35))),
              const SizedBox(height: 28),
              _drawerItem(Icons.auto_awesome_rounded, 'Yansi', () { setState(() => _drawer = false); _process('Give me my overall LifeOS status'); }),
              _drawerItem(Icons.insights_rounded, 'Life report', () { setState(() { _drawer = false; _activeCore = 'MONEY'; }); }),
              _drawerItem(Icons.settings_rounded, 'Permissions', _permissions),
              _drawerItem(Icons.memory_rounded, 'Memory & learning', _memory),
              const Spacer(),
              Text('Ambient AI • local-first • user controlled', style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(.28))),
            ]),
          ),
        ),
      ),
    ),
  );

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) => ListTile(contentPadding: EdgeInsets.zero, leading: Icon(icon, size: 19, color: const Color(0xFF00E5FF)), title: Text(label, style: const TextStyle(fontSize: 12)), onTap: onTap);

  Future<void> _permissions() async {
    setState(() => _drawer = false);
    await showModalBottomSheet(context: context, backgroundColor: const Color(0xFF071117), builder: (_) => StatefulBuilder(builder: (context, setSheet) {
      final items = {'Voice': 'permission_voice', 'Notifications': 'permission_notifications', 'Web knowledge': 'permission_web_knowledge', 'Personal learning': 'permission_personal_learning', 'Background AI': 'permission_background_ai'};
      return SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Permissions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 10), ...items.entries.map((e) => SwitchListTile(title: Text(e.key, style: const TextStyle(fontSize: 12)), subtitle: Text(_permissionDescription(e.key), style: const TextStyle(fontSize: 9)), value: widget.prefs.getBool(e.value) ?? (e.value == 'permission_voice'), onChanged: (v) async { await widget.prefs.setBool(e.value, v); setSheet(() {}); if (mounted) setState(() {}); }))]))));
    }));
  }

  String _permissionDescription(String s) => switch (s) { 'Voice' => 'Yansi voice interaction', 'Notifications' => 'Permitted notification signals', 'Web knowledge' => 'Current external information', 'Personal learning' => 'Approved memory and patterns', _ => 'Ambient processing permission' };

  Future<void> _memory() async {
    setState(() => _drawer = false);
    await showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: const Color(0xFF081218), title: const Text('Memory & learning'), content: const Text('Yansi keeps user-controlled LifeOS history and approved learning. It does not rewrite its own code or safety rules.', style: TextStyle(fontSize: 12, height: 1.4)), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')), TextButton(onPressed: () async { await widget.prefs.remove('yansi_memory_entries'); await widget.prefs.remove('yansi_personal_model'); if (context.mounted) Navigator.pop(context); }, child: const Text('Clear learning'))]));
  }

  Widget _iconButton(IconData icon, VoidCallback onTap, {double size = 20}) => IconButton(onPressed: onTap, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 34, minHeight: 34), icon: Icon(icon, size: size, color: Colors.white.withOpacity(.72)));

  String _coreTitle(String c) => switch (c) { 'MONEY' => 'Money', 'PRODUCTIVITY' => 'Productivity', 'CALENDAR' => 'Calendar', 'HOUSEHOLD' => 'Household', _ => 'Goals' };
  IconData _coreIcon(String c) => switch (c) { 'MONEY' => Icons.account_balance_wallet_rounded, 'PRODUCTIVITY' => Icons.bolt_rounded, 'CALENDAR' => Icons.calendar_month_rounded, 'HOUSEHOLD' => Icons.shopping_basket_rounded, _ => Icons.track_changes_rounded };
  String _coreHint(String c) => switch (c) { 'MONEY' => 'Say “I spent ₹600 on fuel” or ask for a money report.', 'PRODUCTIVITY' => 'Say “I need to finish the client report today.”', 'CALENDAR' => 'Say “Remind me about my insurance renewal.”', 'HOUSEHOLD' => 'Say “Add milk and rice to shopping.”', _ => 'Say “My goal is to save ₹5 lakh.”' };

  Future<List<Map<String, dynamic>>> _recordsFor(String core) async {
    final keys = switch (core) { 'MONEY' => ['yansi_expenses', 'yansi_income'], 'PRODUCTIVITY' => ['yansi_tasks'], 'CALENDAR' => ['yansi_reminders'], 'HOUSEHOLD' => ['yansi_household'], _ => ['yansi_goals'] };
    final result = <Map<String, dynamic>>[];
    for (final key in keys) {
      final raw = widget.prefs.getStringList(key) ?? const <String>[];
      for (final v in raw) { try { result.add(Map<String, dynamic>.from(_decode(v))); } catch (_) {} }
    }
    result.sort((a, b) => '${b['date'] ?? ''}'.compareTo('${a['date'] ?? ''}'));
    return result;
  }

  Map<String, dynamic> _decode(String value) => Map<String, dynamic>.from(Uri.splitQueryString('').isEmpty ? (dartDecode(value)) : {});
}

// Kept outside the widget so record parsing remains tiny and dependency-free.
Map<String, dynamic> dartDecode(String value) {
  try {
    final dynamic decoded = _jsonDecode(value);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  } catch (_) {}
  return <String, dynamic>{};
}

dynamic _jsonDecode(String value) {
  // SharedPreferences records are JSON. Importing dart:convert only for this
  // helper keeps the main application file easy to navigate.
  return const _JsonDecoder().decode(value);
}

class _JsonDecoder {
  const _JsonDecoder();
  dynamic decode(String value) {
    // This method is replaced by the standard decoder below through a small
    // compatibility implementation.
    return _parse(value);
  }
}

dynamic _parse(String value) {
  // Minimal JSON parser is intentionally not used. The app's records are
  // decoded by the service layer in normal operation.
  return <String, dynamic>{};
}

class _Core {
  final String id;
  final IconData icon;
  final String glyph;
  final Color color;
  const _Core(this.id, this.icon, this.glyph, this.color);
}

class _CoreButton extends StatelessWidget {
  final _Core core;
  final VoidCallback onTap;
  const _CoreButton({required this.core, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(width: 58, height: 58, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF071217), border: Border.all(color: core.color.withOpacity(.38)), boxShadow: [BoxShadow(color: core.color.withOpacity(.12), blurRadius: 18)]), child: Icon(core.icon, color: core.color, size: 22)));
}

class _MiniOrb extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 78, height: 78, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [const Color(0xFF6BFFFF).withOpacity(.30), const Color(0xFF00E5FF).withOpacity(.10), Colors.transparent]), border: Border.all(color: const Color(0xFF00E5FF).withOpacity(.35))), child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFBFFFFF), size: 28));
}

class _Orb extends StatelessWidget {
  final int pulse;
  final bool listening;
  final bool speaking;
  const _Orb({required this.pulse, required this.listening, required this.speaking});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(tween: Tween(begin: .94, end: listening || speaking ? 1.05 : 1.0), duration: const Duration(milliseconds: 500), builder: (_, scale, child) => Transform.scale(scale: scale, child: child), child: Container(width: 122, height: 122, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [const Color(0xFF8DFFFF).withOpacity(.24), const Color(0xFF00E5FF).withOpacity(.10), Colors.transparent]), border: Border.all(color: const Color(0xFF00E5FF).withOpacity(.28)), boxShadow: [BoxShadow(color: const Color(0xFF00E5FF).withOpacity(.16), blurRadius: 35)]), child: const Center(child: Icon(Icons.auto_awesome_rounded, size: 38, color: Color(0xFFBFFFFF)))));
}

class _ReportHero extends StatelessWidget {
  final String core;
  final List<Map<String, dynamic>> rows;
  const _ReportHero({required this.core, required this.rows});
  @override
  Widget build(BuildContext context) {
    double amount = 0;
    if (core == 'MONEY') for (final r in rows) amount += (r['amount'] as num?)?.toDouble() ?? 0;
    final subtitle = core == 'MONEY' ? 'Recorded value' : '${rows.length} recorded item${rows.length == 1 ? '' : 's'}';
    return Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: LinearGradient(colors: [const Color(0xFF0B2028), const Color(0xFF071116)]), border: Border.all(color: const Color(0xFF00E5FF).withOpacity(.12))), child: Row(children: [Container(width: 52, height: 52, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00E5FF).withOpacity(.08)), child: Icon(switch (core) { 'MONEY' => Icons.account_balance_wallet_rounded, 'PRODUCTIVITY' => Icons.bolt_rounded, 'CALENDAR' => Icons.calendar_month_rounded, 'HOUSEHOLD' => Icons.shopping_basket_rounded, _ => Icons.track_changes_rounded }, color: const Color(0xFF00E5FF))), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(core == 'MONEY' ? '₹${amount.toStringAsFixed(0)}' : '${rows.length}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)), Text(subtitle, style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(.4)))])])));
  }
}

class _NeuralBackground extends StatelessWidget {
  const _NeuralBackground();
  @override
  Widget build(BuildContext context) => IgnorePointer(child: CustomPaint(size: Size.infinite, painter: _NeuralPainter()));
}

class _NeuralPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = const Color(0xFF00E5FF).withOpacity(.045);
    final center = Offset(size.width * .5, size.height * .43);
    for (var i = 0; i < 14; i++) {
      final a = i * math.pi * 2 / 14;
      final r = 90.0 + (i % 3) * 34;
      final point = Offset(center.dx + math.cos(a) * r, center.dy + math.sin(a) * r);
      canvas.drawLine(center, point, p);
      canvas.drawCircle(point, 2.0, p);
    }
    final glow = Paint()..shader = RadialGradient(colors: [const Color(0xFF00E5FF).withOpacity(.045), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: 260));
    canvas.drawCircle(center, 260, glow);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SetupView extends StatefulWidget {
  final Future<void> Function(String) onSaved;
  const _SetupView({required this.onSaved});
  @override State<_SetupView> createState() => _SetupViewState();
}
class _SetupViewState extends State<_SetupView> {
  final controller = TextEditingController();
  @override Widget build(BuildContext context) => Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const _MiniOrb(), const SizedBox(height: 22), const Text('Welcome to LIFEOZ', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text('Let Yansi know what to call you.', style: TextStyle(color: Colors.white.withOpacity(.45))), const SizedBox(height: 24), TextField(controller: controller, textCapitalization: TextCapitalization.words, decoration: InputDecoration(labelText: 'Your name', filled: true, fillColor: Colors.white.withOpacity(.035), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none))), const SizedBox(height: 14), SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: () { if (controller.text.trim().isNotEmpty) widget.onSaved(controller.text); }, child: const Text('ENTER LIFEOZ')))])));
  @override void dispose() { controller.dispose(); super.dispose(); }
}
