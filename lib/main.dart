import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'services/yansi_brain.dart';
import 'services/yansi_companion_orchestrator.dart';
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

class _LifeOSShellState extends State<LifeOSShell>
    with WidgetsBindingObserver {
  late final YansiBrain _brain;
  late final YansiRuntimeGuardian _guardian;
  late final YansiCompanionOrchestrator _companion;
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _input = TextEditingController();

  String _name = '';
  String _message = 'I’m here whenever you need me.';
  String _activeCore = '';
  bool _setup = false;
  bool _listening = false;
  bool _speaking = false;
  bool _drawer = false;
  int _pulse = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _brain = YansiBrain(prefs: widget.prefs);
    _guardian = YansiRuntimeGuardian(prefs: widget.prefs)..start();
    _companion = YansiCompanionOrchestrator(prefs: widget.prefs);
    _name = widget.prefs.getString('user_name')?.trim() ?? '';
    _setup = _name.isEmpty;
    _configureVoice();
    if (!_setup) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _refreshCompanion();
        await _welcome();
      });
    }
  }

  Future<void> _configureVoice() async {
    await _tts.setSpeechRate(0.46);
    await _tts.setPitch(1.0);
    _tts.setStartHandler(() {
      if (mounted) setState(() => _speaking = true);
    });
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
  }

  Future<void> _welcome() async {
    await _speak(
      'Welcome, $_name. I’m Yansi, your personal LifeOS AI agent. I’m here whenever you need me.',
    );
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    if (widget.prefs.getBool('permission_voice') == false) return;
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
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    );

    if (!available) {
      _show('Microphone access is not available.');
      return;
    }

    if (mounted) setState(() => _listening = true);
    await _speech.listen(
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

  Future<void> _process(String text) async {
    if (text.trim().isEmpty) return;
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
        'MONEY' => 'Your money intelligence connects spending, income, bills and investments.',
        'PRODUCTIVITY' => 'Your productivity intelligence tracks tasks, priorities and unfinished work.',
        'CALENDAR' => 'Your time intelligence connects bills, renewals and important dates.',
        'HOUSEHOLD' => 'Your household intelligence learns recurring shopping and kitchen needs.',
        _ => 'Your goals intelligence connects your targets with your daily actions.',
      };

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      YansiProactiveRuntime(prefs: widget.prefs)
          .prepare(userIsActive: true, quietMode: false);
      _refreshCompanion();
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
    if (_setup) {
      return _SetupView(onSaved: (name) async {
        await widget.prefs.setString('user_name', name.trim());
        await widget.prefs.setBool('permission_voice', true);
        await widget.prefs.setBool('permission_personal_learning', true);
        await widget.prefs.setBool('permission_background_ai', true);
        if (!mounted) return;
        setState(() {
          _name = name.trim();
          _setup = false;
        });
        await _refreshCompanion();
        await Future<void>.delayed(const Duration(milliseconds: 250));
        await _welcome();
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          const _NeuralBackground(),
          SafeArea(
            child: Column(
              children: [
                _topBar(),
                Expanded(
                  child: _activeCore.isEmpty
                      ? _home()
                      : _coreReport(_activeCore),
                ),
              ],
            ),
          ),
          if (_drawer) _drawerPanel(),
        ],
      ),
    );
  }

  Widget _topBar() => Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(
          children: [
            _iconButton(Icons.menu_rounded, () {
              setState(() => _drawer = !_drawer);
            }),
            const Spacer(),
            Column(
              children: [
                Text(
                  'LIFEOZ',
                  style: TextStyle(
                    letterSpacing: 4,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(.92),
                  ),
                ),
                Text(
                  'ONE SCREEN • ONE TAP • ONE REPORT',
                  style: TextStyle(
                    fontSize: 7,
                    letterSpacing: 1.5,
                    color: Colors.white.withOpacity(.38),
                  ),
                ),
              ],
            ),
            const Spacer(),
            _iconButton(Icons.notifications_none_rounded, () {
              _show('Yansi is active according to your approved settings.');
            }),
          ],
        ),
      );

  Widget _home() => LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 650;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(18, compact ? 8 : 18, 18, 24),
            child: Column(
              children: [
                _welcomeText(),
                SizedBox(height: compact ? 8 : 14),
                _Orb(
                  pulse: _pulse,
                  listening: _listening,
                  speaking: _speaking,
                ),
                const SizedBox(height: 8),
                _ambientMessage(),
                SizedBox(height: compact ? 12 : 20),
                _coreRing(),
                const SizedBox(height: 12),
                _commandBar(),
                const SizedBox(height: 12),
                _quickInsight(),
              ],
            ),
          );
        },
      );

  Widget _welcomeText() => Column(
        children: [
          Text(
            'Good day, $_name',
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(
            'Your life. Connected intelligently.',
            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.48)),
          ),
        ],
      );

  Widget _ambientMessage() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: Container(
          key: ValueKey(_message),
          constraints: const BoxConstraints(maxWidth: 330),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.035),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF00E5FF).withOpacity(.10),
            ),
          ),
          child: Text(
            _message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              height: 1.35,
              color: Colors.white.withOpacity(.72),
            ),
          ),
        ),
      );

  Widget _coreRing() {
    final cores = [
      _Core('MONEY', Icons.account_balance_wallet_rounded, const Color(0xFF00E5FF)),
      _Core('PRODUCTIVITY', Icons.bolt_rounded, const Color(0xFF63FFB1)),
      _Core('CALENDAR', Icons.calendar_month_rounded, const Color(0xFF8A9CFF)),
      _Core('HOUSEHOLD', Icons.shopping_basket_rounded, const Color(0xFF00FFC6)),
      _Core('GOALS', Icons.track_changes_rounded, const Color(0xFFB8FF4D)),
    ];

    return SizedBox(
      height: 225,
      width: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00E5FF).withOpacity(.08),
              ),
            ),
          ),
          ...List.generate(cores.length, (i) {
            final angle = -math.pi / 2 + i * 2 * math.pi / cores.length;
            return Transform.translate(
              offset: Offset(math.cos(angle) * 94, math.sin(angle) * 94),
              child: _CoreButton(
                core: cores[i],
                onTap: () => _openCore(cores[i].id),
              ),
            );
          }),
          const _MiniOrb(),
        ],
      ),
    );
  }

  Widget _commandBar() => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF081218).withOpacity(.92),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(.08)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(
              _listening
                  ? Icons.graphic_eq_rounded
                  : Icons.auto_awesome_rounded,
              size: 18,
              color: const Color(0xFF00E5FF),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _input,
                onSubmitted: _process,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  hintText: 'Tell Yansi anything…',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.white38),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              onPressed: _listen,
              icon: Icon(
                _listening
                    ? Icons.stop_circle_rounded
                    : Icons.mic_none_rounded,
                color: _listening
                    ? const Color(0xFF63FFB1)
                    : Colors.white70,
                size: 22,
              ),
            ),
            IconButton(
              onPressed: () => _process(_input.text),
              icon: const Icon(Icons.arrow_upward_rounded, size: 20),
            ),
          ],
        ),
      );

  Widget _quickInsight() => FutureBuilder<YansiContextSnapshot>(
        future: YansiContextFusion(prefs: widget.prefs).build(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) return const SizedBox.shrink();
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Stat('${data.openTasks}', 'tasks'),
              _Stat('${data.upcomingReminders}', 'due soon'),
              _Stat('₹${data.recentSpend.toStringAsFixed(0)}', '30d spend'),
            ],
          );
        },
      );

  Widget _coreReport(String core) => FutureBuilder<List<Map<String, dynamic>>>(
        future: _recordsFor(core),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <Map<String, dynamic>>[];
          final title = _coreTitle(core);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _iconButton(Icons.arrow_back_rounded, () {
                      setState(() => _activeCore = '');
                    }),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _iconButton(Icons.auto_awesome_rounded, () {
                      _process('Give me my $title report');
                    }),
                  ],
                ),
                const SizedBox(height: 18),
                _ReportHero(core: core, rows: rows),
                const SizedBox(height: 14),
                if (rows.isEmpty)
                  _emptyCore(core)
                else
                  ...rows.take(12).map((row) => _recordTile(core, row)),
                const SizedBox(height: 10),
                _commandBar(),
              ],
            ),
          );
        },
      );

  Widget _emptyCore(String core) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.025),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(.06)),
        ),
        child: Column(
          children: [
            Icon(_coreIcon(core), size: 30, color: const Color(0xFF00E5FF)),
            const SizedBox(height: 10),
            const Text('No records yet'),
            const SizedBox(height: 6),
            Text(
              _coreHint(core),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.4)),
            ),
          ],
        ),
      );

  Widget _recordTile(String core, Map<String, dynamic> record) {
    final value = record['text'] ??
        record['task'] ??
        record['item'] ??
        record['goal'] ??
        record['title'] ??
        '';
    final amount = record['amount'];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.025),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(_coreIcon(core), size: 18, color: const Color(0xFF00E5FF)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$value',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          if (amount is num)
            Text(
              '₹${amount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }

  Widget _drawerPanel() => Positioned.fill(
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
                color: const Color(0xFF061016),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LIFEOZ', style: TextStyle(letterSpacing: 4, color: Colors.white.withOpacity(.9))),
                    Text('YANSI INTELLIGENCE', style: TextStyle(fontSize: 8, letterSpacing: 2, color: Colors.white.withOpacity(.35))),
                    const SizedBox(height: 28),
                    _drawerItem(Icons.auto_awesome_rounded, 'Yansi', () {
                      setState(() => _drawer = false);
                      _process('Give me my overall LifeOS status');
                    }),
                    _drawerItem(Icons.insights_rounded, 'Life report', () {
                      setState(() { _drawer = false; _activeCore = 'MONEY'; });
                    }),
                    _drawerItem(Icons.settings_rounded, 'Permissions', _permissions),
                    _drawerItem(Icons.memory_rounded, 'Memory & learning', _memory),
                    const Spacer(),
                    Text('Ambient AI • local-first • user controlled', style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(.28))),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, size: 19, color: const Color(0xFF00E5FF)),
        title: Text(label, style: const TextStyle(fontSize: 12)),
        onTap: onTap,
      );

  Future<void> _permissions() async {
    setState(() => _drawer = false);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF071117),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheet) {
          const items = <String, String>{
            'Voice': 'permission_voice',
            'Notifications': 'permission_notifications',
            'Web knowledge': 'permission_web_knowledge',
            'Personal learning': 'permission_personal_learning',
            'Background AI': 'permission_background_ai',
          };
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Permissions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ...items.entries.map(
                    (entry) => SwitchListTile(
                      title: Text(entry.key, style: const TextStyle(fontSize: 12)),
                      value: widget.prefs.getBool(entry.value) ?? entry.value == 'permission_voice',
                      onChanged: (value) async {
                        await widget.prefs.setBool(entry.value, value);
                        setSheet(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _memory() async {
    setState(() => _drawer = false);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF081218),
        title: const Text('Memory & learning'),
        content: const Text(
          'Yansi uses user-approved LifeOS history and learning. Core safety rules and application behaviour are not self-rewritten.',
          style: TextStyle(fontSize: 12, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              await widget.prefs.remove('yansi_memory_entries');
              await widget.prefs.remove('yansi_personal_model');
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Clear learning'),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) => IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
        icon: Icon(icon, size: 19, color: Colors.white.withOpacity(.72)),
      );

  String _coreTitle(String core) => switch (core) {
        'MONEY' => 'Money',
        'PRODUCTIVITY' => 'Productivity',
        'CALENDAR' => 'Calendar',
        'HOUSEHOLD' => 'Household',
        _ => 'Goals',
      };

  IconData _coreIcon(String core) => switch (core) {
        'MONEY' => Icons.account_balance_wallet_rounded,
        'PRODUCTIVITY' => Icons.bolt_rounded,
        'CALENDAR' => Icons.calendar_month_rounded,
        'HOUSEHOLD' => Icons.shopping_basket_rounded,
        _ => Icons.track_changes_rounded,
      };

  String _coreHint(String core) => switch (core) {
        'MONEY' => 'Tell Yansi what you spent or ask for a money report.',
        'PRODUCTIVITY' => 'Tell Yansi what you need to finish today.',
        'CALENDAR' => 'Tell Yansi about a due date or renewal.',
        'HOUSEHOLD' => 'Tell Yansi what to add to shopping.',
        _ => 'Tell Yansi about a goal you want to achieve.',
      };

  Future<List<Map<String, dynamic>>> _recordsFor(String core) async {
    final keys = switch (core) {
      'MONEY' => ['yansi_expenses', 'yansi_income'],
      'PRODUCTIVITY' => ['yansi_tasks'],
      'CALENDAR' => ['yansi_reminders'],
      'HOUSEHOLD' => ['yansi_household'],
      _ => ['yansi_goals'],
    };
    final records = <Map<String, dynamic>>[];
    for (final key in keys) {
      for (final raw in widget.prefs.getStringList(key) ?? const <String>[]) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map) records.add(Map<String, dynamic>.from(decoded));
        } catch (_) {}
      }
    }
    records.sort((a, b) => '${b['date'] ?? ''}'.compareTo('${a['date'] ?? ''}'));
    return records;
  }
}

class _Core {
  final String id;
  final IconData icon;
  final Color color;
  const _Core(this.id, this.icon, this.color);
}

class _CoreButton extends StatelessWidget {
  final _Core core;
  final VoidCallback onTap;
  const _CoreButton({required this.core, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF071217),
            border: Border.all(color: core.color.withOpacity(.38)),
            boxShadow: [BoxShadow(color: core.color.withOpacity(.12), blurRadius: 18)],
          ),
          child: Icon(core.icon, color: core.color, size: 22),
        ),
      );
}

class _MiniOrb extends StatelessWidget {
  const _MiniOrb();

  @override
  Widget build(BuildContext context) => Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFF6BFFFF).withOpacity(.30),
              const Color(0xFF00E5FF).withOpacity(.10),
              Colors.transparent,
            ],
          ),
          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(.35)),
        ),
        child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFBFFFFF), size: 28),
      );
}

class _Orb extends StatelessWidget {
  final int pulse;
  final bool listening;
  final bool speaking;
  const _Orb({required this.pulse, required this.listening, required this.speaking});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        key: ValueKey('$pulse-$listening-$speaking'),
        tween: Tween(begin: .94, end: listening || speaking ? 1.05 : 1.0),
        duration: const Duration(milliseconds: 500),
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: Container(
          width: 122,
          height: 122,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF8DFFFF).withOpacity(.24),
                const Color(0xFF00E5FF).withOpacity(.10),
                Colors.transparent,
              ],
            ),
            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(.28)),
            boxShadow: [BoxShadow(color: const Color(0xFF00E5FF).withOpacity(.16), blurRadius: 35)],
          ),
          child: const Center(child: Icon(Icons.auto_awesome_rounded, size: 38, color: Color(0xFFBFFFFF))),
        ),
      );
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.025),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            Text(label, style: TextStyle(fontSize: 7, color: Colors.white.withOpacity(.4))),
          ],
        ),
      );
}

class _ReportHero extends StatelessWidget {
  final String core;
  final List<Map<String, dynamic>> rows;
  const _ReportHero({required this.core, required this.rows});

  @override
  Widget build(BuildContext context) {
    double amount = 0;
    if (core == 'MONEY') {
      for (final row in rows) {
        amount += (row['amount'] as num?)?.toDouble() ?? 0;
      }
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: [Color(0xFF0B2028), Color(0xFF071116)]),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(.12)),
      ),
      child: Row(
        children: [
          const _MiniOrb(),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                core == 'MONEY' ? '₹${amount.toStringAsFixed(0)}' : '${rows.length}',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              Text(
                core == 'MONEY' ? 'Recorded value' : 'Recorded items',
                style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(.4)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NeuralBackground extends StatelessWidget {
  const _NeuralBackground();

  @override
  Widget build(BuildContext context) => const IgnorePointer(
        child: CustomPaint(size: Size.infinite, painter: _NeuralPainter()),
      );
}

class _NeuralPainter extends CustomPainter {
  const _NeuralPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7
      ..color = const Color(0xFF00E5FF).withOpacity(.045);
    final center = Offset(size.width * .5, size.height * .43);
    for (var i = 0; i < 14; i++) {
      final angle = i * math.pi * 2 / 14;
      final radius = 90.0 + (i % 3) * 34;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawLine(center, point, paint);
      canvas.drawCircle(point, 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NeuralPainter oldDelegate) => false;
}

class _SetupView extends StatefulWidget {
  final Future<void> Function(String) onSaved;
  const _SetupView({required this.onSaved});

  @override
  State<_SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends State<_SetupView> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _MiniOrb(),
                const SizedBox(height: 22),
                const Text('Welcome to LIFEOZ', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Let Yansi know what to call you.', style: TextStyle(color: Colors.white.withOpacity(.45))),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Your name',
                    filled: true,
                    fillColor: Colors.white.withOpacity(.035),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      final name = _controller.text.trim();
                      if (name.isNotEmpty) widget.onSaved(name);
                    },
                    child: const Text('ENTER LIFEOZ'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
