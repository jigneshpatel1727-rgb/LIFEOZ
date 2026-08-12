import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    LifeOSApp(prefs: prefs),
  );
}

// ============================================================
// LIFEOS APP
// ============================================================

class LifeOSApp extends StatelessWidget {
  final SharedPreferences prefs;

  const LifeOSApp({
    super.key,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeOS',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor:
            const Color(0xFF02070D),
        colorScheme: ColorScheme.fromSeed(
          seedColor:
              const Color(0xFF00E5FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: LifeOSRoot(
        prefs: prefs,
      ),
    );
  }
}

// ============================================================
// ROOT
// ============================================================

class LifeOSRoot extends StatefulWidget {
  final SharedPreferences prefs;

  const LifeOSRoot({
    super.key,
    required this.prefs,
  });

  @override
  State<LifeOSRoot> createState() =>
      _LifeOSRootState();
}

class _LifeOSRootState
    extends State<LifeOSRoot> {
  String userName = '';

  @override
  void initState() {
    super.initState();

    userName =
        widget.prefs.getString(
              'user_name',
            ) ??
            '';
  }

  Future<void> saveName(
    String name,
  ) async {
    await widget.prefs.setString(
      'user_name',
      name,
    );

    setState(() {
      userName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userName.isEmpty) {
      return LoginScreen(
        onComplete: saveName,
      );
    }

    return HomeScreen(
      prefs: widget.prefs,
      userName: userName,
    );
  }
}

// ============================================================
// LOGIN / PROFILE
// ============================================================

class LoginScreen extends StatefulWidget {
  final Future<void> Function(String)
      onComplete;

  const LoginScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final nameController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const FutureBackground(),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.all(28),
                child: Column(
                  children: [
                    const YansiOrb(
                      size: 180,
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    const Text(
                      'L I F E O S',
                      style: TextStyle(
                        fontSize: 25,
                        letterSpacing: 8,
                        fontWeight:
                            FontWeight.w300,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      'ONE LIFE • ONE INTELLIGENCE',
                      style: TextStyle(
                        color:
                            Color(0xFF00E5FF),
                        fontSize: 9,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(
                      height: 55,
                    ),

                    const Text(
                      'INITIALIZE YOUR LIFEOS',
                      style: TextStyle(
                        color:
                            Color(0xFF55FF88),
                        fontSize: 11,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    const Text(
                      'What should Yansi call you?',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.w300,
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    TextField(
                      controller:
                          nameController,
                      textCapitalization:
                          TextCapitalization
                              .words,
                      decoration:
                          InputDecoration(
                        hintText:
                            'Your name',
                        prefixIcon:
                            const Icon(
                          Icons
                              .person_outline,
                        ),
                        filled: true,
                        fillColor:
                            const Color(
                          0xFF07131D,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      height: 54,
                      child:
                          ElevatedButton(
                        onPressed:
                            _continue,
                        child:
                            const Text(
                          'ENTER LIFEOS',
                          style:
                              TextStyle(
                            letterSpacing:
                                2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    const Text(
                      'Your data remains under your control.',
                      style: TextStyle(
                        color:
                            Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _continue() async {
    final name =
        nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Please enter your name.'),
        ),
      );
      return;
    }

    await widget.onComplete(name);
  }
}

// ============================================================
// HOME
// ============================================================

class HomeScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final String userName;

  const HomeScreen({
    super.key,
    required this.prefs,
    required this.userName,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  final SpeechToText speech =
      SpeechToText();

  final FlutterTts tts =
      FlutterTts();

  bool listening = false;
  bool menuOpen = false;
  bool notifications = false;

  String yansiMessage =
      'I am here whenever you need me.';

  List<Map<String, dynamic>>
      entries = [];

  @override
  void initState() {
    super.initState();

    _loadEntries();

    Future.delayed(
      const Duration(
        milliseconds: 900,
      ),
      () {
        if (mounted) {
          setState(() {
            yansiMessage =
                'Welcome, ${widget.userName}. I’m Yansi, your personal LifeOS AI agent. I’m here whenever you need me.';
          });

          _speak(
            'Welcome, ${widget.userName}. I’m Yansi, your personal LifeOS AI agent. I’m here whenever you need me.',
          );
        }
      },
    );
  }

  @override
  void dispose() {
    speech.stop();
    tts.stop();
    super.dispose();
  }

  void _loadEntries() {
    final raw =
        widget.prefs.getString(
      'lifeos_entries',
    );

    if (raw == null) return;

    try {
      final decoded =
          jsonDecode(raw);

      if (decoded is List) {
        setState(() {
          entries =
              List<Map<String, dynamic>>
                  .from(
            decoded.map(
              (e) => Map<String,
                  dynamic>.from(e),
            ),
          );
        });
      }
    } catch (_) {}
  }

  Future<void> _saveEntries() async {
    await widget.prefs.setString(
      'lifeos_entries',
      jsonEncode(entries),
    );
  }

  // ==========================================================
  // YANSI
  // ==========================================================

  Future<void> _listenToYansi() async {
    if (listening) return;

    setState(() {
      listening = true;
      yansiMessage =
          'Yansi is listening...';
    });

    final available =
        await speech.initialize();

    if (!available) {
      setState(() {
        listening = false;
        yansiMessage =
            'Microphone access is required for voice interaction.';
      });
      return;
    }

    String words = '';

    await speech.listen(
      onResult: (result) {
        words =
            result.recognizedWords;
      },
    );

    await Future.delayed(
      const Duration(
        seconds: 5,
      ),
    );

    await speech.stop();

    setState(() {
      listening = false;
    });

    if (words.trim().isEmpty) {
      setState(() {
        yansiMessage =
            'I did not catch that. Tap Yansi and try again.';
      });
      return;
    }

    await _processYansi(words);
  }

  Future<void> _processYansi(
    String input,
  ) async {
    final text =
        input.toLowerCase();

    // --------------------------------------------------------
    // EXPENSE
    // --------------------------------------------------------

    if (_containsAny(
      text,
      [
        'spent',
        'paid',
        'expense',
        'bought',
        'purchase',
      ],
    )) {
      final amount =
          _extractAmount(text);

      if (amount > 0) {
        String category =
            _expenseCategory(text);

        entries.insert(
          0,
          {
            'type': 'expense',
            'title': category,
            'description': input,
            'amount': amount,
            'date':
                DateTime.now()
                    .toIso8601String(),
          },
        );

        await _saveEntries();

        final response =
            'Got it. I added ₹${amount.toStringAsFixed(0)} to $category for today.';

        setState(() {
          yansiMessage =
              response;
        });

        await _speak(response);
        return;
      }
    }

    // --------------------------------------------------------
    // TASK
    // --------------------------------------------------------

    if (_containsAny(
      text,
      [
        'task',
        'todo',
        'to do',
        'need to',
        'have to',
        'finish',
        'complete',
      ],
    )) {
      entries.insert(
        0,
        {
          'type': 'productivity',
          'title': input,
          'description': input,
          'amount': 0,
          'completed': false,
          'date':
              DateTime.now()
                  .toIso8601String(),
        },
      );

      await _saveEntries();

      const response =
          'Done. I added that to your productivity list.';

      setState(() {
        yansiMessage =
            response;
      });

      await _speak(response);
      return;
    }

    // --------------------------------------------------------
    // HOUSEHOLD
    // --------------------------------------------------------

    if (_containsAny(
      text,
      [
        'grocery',
        'groceries',
        'shopping',
        'buy milk',
        'vegetables',
        'household',
      ],
    )) {
      entries.insert(
        0,
        {
          'type': 'household',
          'title': input,
          'description': input,
          'amount': 0,
          'date':
              DateTime.now()
                  .toIso8601String(),
        },
      );

      await _saveEntries();

      const response =
          'Added that to your household requirement list.';

      setState(() {
        yansiMessage =
            response;
      });

      await _speak(response);
      return;
    }

    // --------------------------------------------------------
    // GOAL
    // --------------------------------------------------------

    if (_containsAny(
      text,
      [
        'goal',
        'target',
        'save for',
        'want to achieve',
      ],
    )) {
      entries.insert(
        0,
        {
          'type': 'goal',
          'title': input,
          'description': input,
          'amount': 0,
          'date':
              DateTime.now()
                  .toIso8601String(),
        },
      );

      await _saveEntries();

      const response =
          'I created a goal from that. Yansi will keep it connected to your LifeOS.';

      setState(() {
        yansiMessage =
            response;
      });

      await _speak(response);
      return;
    }

    // --------------------------------------------------------
    // CALENDAR
    // --------------------------------------------------------

    if (_containsAny(
      text,
      [
        'remind me',
        'reminder',
        'appointment',
        'birthday',
        'anniversary',
        'due',
        'tomorrow',
      ],
    )) {
      entries.insert(
        0,
        {
          'type': 'calendar',
          'title': input,
          'description': input,
          'amount': 0,
          'date':
              DateTime.now()
                  .toIso8601String(),
        },
      );

      await _saveEntries();

      const response =
          'Understood. I added that to your LifeOS calendar intelligence.';

      setState(() {
        yansiMessage =
            response;
      });

      await _speak(response);
      return;
    }

    // --------------------------------------------------------
    // GENERAL
    // --------------------------------------------------------

    final response =
        'I heard you. Tell me about an expense, goal, task, household requirement or important date, and I will organize it.';

    setState(() {
      yansiMessage =
          response;
    });

    await _speak(response);
  }

  bool _containsAny(
    String text,
    List<String> words,
  ) {
    return words.any(
      text.contains,
    );
  }

  double _extractAmount(
    String text,
  ) {
    final match =
        RegExp(
      r'(\d+(?:\.\d+)?)',
    ).firstMatch(text);

    if (match == null) {
      return 0;
    }

    return double.tryParse(
          match.group(1)!,
        ) ??
        0;
  }

  String _expenseCategory(
    String text,
  ) {
    if (_containsAny(
      text,
      [
        'petrol',
        'fuel',
        'diesel',
      ],
    )) {
      return 'Fuel';
    }

    if (_containsAny(
      text,
      [
        'food',
        'restaurant',
        'lunch',
        'dinner',
        'breakfast',
      ],
    )) {
      return 'Food';
    }

    if (_containsAny(
      text,
      [
        'medicine',
        'medical',
        'doctor',
        'hospital',
      ],
    )) {
      return 'Medical';
    }

    if (_containsAny(
      text,
      [
        'electricity',
        'light bill',
      ],
    )) {
      return 'Electricity';
    }

    if (_containsAny(
      text,
      [
        'travel',
        'ticket',
        'flight',
        'train',
      ],
    )) {
      return 'Travel';
    }

    if (_containsAny(
      text,
      [
        'shopping',
        'clothes',
      ],
    )) {
      return 'Shopping';
    }

    return 'Other';
  }

  Future<void> _speak(
    String text,
  ) async {
    await tts.setLanguage(
      'en-IN',
    );

    await tts.setSpeechRate(
      .47,
    );

    await tts.speak(text);
  }

  // ==========================================================
  // HOME UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const FutureBackground(),

          SafeArea(
            child: Column(
              children: [
                _topBar(),

                Expanded(
                  child: _lifeMap(),
                ),
              ],
            ),
          ),

          if (menuOpen)
            _controlCenter(),

          if (listening)
            _listeningIndicator(),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        9,
        5,
        9,
        4,
      ),
      child: Row(
        children: [
          _miniButton(
            Icons.menu_rounded,
            () {
              setState(() {
                menuOpen =
                    !menuOpen;
              });
            },
          ),

          const Spacer(),

          const Text(
            'L I F E O S',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 5,
              fontWeight:
                  FontWeight.w300,
            ),
          ),

          const Spacer(),

          _miniButton(
            notifications
                ? Icons
                    .notifications_active_outlined
                : Icons
                    .notifications_none_outlined,
            () {
              setState(() {
                notifications =
                    !notifications;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _miniButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 29,
        decoration:
            BoxDecoration(
          color:
              const Color(0xCC07131D),
          borderRadius:
              BorderRadius.circular(
            7,
          ),
          border: Border.all(
            color:
                const Color(0x4400E5FF),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color:
              const Color(0xFF55FF88),
        ),
      ),
    );
  }

  Widget _lifeMap() {
    return LayoutBuilder(
      builder:
          (context, constraints) {
        final w =
            constraints.maxWidth;

        return Stack(
          children: [
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    widget.userName
                        .toUpperCase(),
                    style:
                        const TextStyle(
                      color:
                          Colors.white38,
                      fontSize: 8,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  const Text(
                    'LIFE INTELLIGENCE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),

            // Central Yansi
            Positioned(
              left:
                  w / 2 - 95,
              top:
                  constraints.maxHeight *
                      .27,
              child:
                  GestureDetector(
                onTap:
                    _listenToYansi,
                child:
                    const YansiOrb(
                  size: 190,
                ),
              ),
            ),

            // MONEY
            _core(
              left: 9,
              top:
                  constraints.maxHeight *
                      .20,
              icon: Icons
                  .account_balance_wallet_outlined,
              title: 'MONEY',
              type: 'expense',
            ),

            // GOALS
            _core(
              right: 9,
              top:
                  constraints.maxHeight *
                      .20,
              icon:
                  Icons.flag_outlined,
              title: 'GOALS',
              type: 'goal',
            ),

            // PRODUCTIVITY
            _core(
              left: 9,
              top:
                  constraints.maxHeight *
                      .60,
              icon:
                  Icons.bolt_outlined,
              title: 'PRODUCTIVITY',
              type: 'productivity',
            ),

            // HOUSEHOLD
            _core(
              right: 9,
              top:
                  constraints.maxHeight *
                      .60,
              icon: Icons
                  .shopping_bag_outlined,
              title: 'HOUSEHOLD',
              type: 'household',
            ),

            // CALENDAR
            Positioned(
              bottom: 17,
              left:
                  w / 2 - 54,
              child: _coreButton(
                Icons
                    .calendar_today_outlined,
                'CALENDAR',
                'calendar',
              ),
            ),

            // Yansi message
            Positioned(
              left: 24,
              right: 24,
              bottom: 77,
              child:
                  _yansiMessage(),
            ),
          ],
        );
      },
    );
  }

  Widget _core({
    double? left,
    double? right,
    double? top,
    required IconData icon,
    required String title,
    required String type,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: _coreButton(
        icon,
        title,
        type,
      ),
    );
  }

  Widget _coreButton(
    IconData icon,
    String title,
    String type,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CoreScreen(
              prefs: widget.prefs,
              title: title,
              type: type,
              icon: icon,
            ),
          ),
        );
      },
      child: Container(
        width: 108,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),
        decoration:
            BoxDecoration(
          color:
              const Color(0xDD07131D),
          borderRadius:
              BorderRadius.circular(
            9,
          ),
          border: Border.all(
            color:
                const Color(0x3300E5FF),
          ),
        ),
        child: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color:
                  const Color(
                0xFF55FF88,
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 7,
                  letterSpacing: 1,
                  color:
                      Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _yansiMessage() {
    return Container(
      padding:
          const EdgeInsets.all(12),
      decoration:
          BoxDecoration(
        color:
            const Color(0xDD07131D),
        borderRadius:
            BorderRadius.circular(
          11,
        ),
        border: Border.all(
          color:
              const Color(0x3300E5FF),
        ),
      ),
      child: Text(
        yansiMessage,
        textAlign:
            TextAlign.center,
        maxLines: 3,
        overflow:
            TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 10,
          color:
              Colors.white70,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _controlCenter() {
    return Positioned(
      top: 45,
      left: 8,
      child: Container(
        width: 240,
        padding:
            const EdgeInsets.all(15),
        decoration:
            BoxDecoration(
          color:
              const Color(0xFF07131D),
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          border: Border.all(
            color:
                const Color(0x6600E5FF),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  const Color(
                0x4400E5FF,
              ),
              blurRadius: 25,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            const Text(
              'CONTROL CENTER',
              style: TextStyle(
                color:
                    Color(0xFF00E5FF),
                fontSize: 9,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            _controlItem(
              Icons.person_outline,
              'PROFILE',
              _profile,
            ),
            _controlItem(
              Icons.security,
              'AI PERMISSIONS',
              _permissions,
            ),
            _controlItem(
              Icons.insights_outlined,
              'LIFE REPORT',
              _reports,
            ),
            _controlItem(
              Icons.settings_outlined,
              'SETTINGS',
              () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlItem(
    IconData icon,
    String text,
    VoidCallback action,
  ) {
    return GestureDetector(
      onTap: action,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  const Color(
                0xFF55FF88,
              ),
              size: 18,
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              text,
              style:
                  const TextStyle(
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _profile() {
    setState(() {
      menuOpen = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProfileScreen(
          prefs: widget.prefs,
          currentName:
              widget.userName,
        ),
      ),
    );
  }

  void _permissions() {
    setState(() {
      menuOpen = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const PermissionScreen(),
      ),
    );
  }

  void _reports() {
    setState(() {
      menuOpen = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ReportScreen(
          entries: entries,
        ),
      ),
    );
  }

  Widget _listeningIndicator() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 12,
      child: Container(
        padding:
            const EdgeInsets.all(13),
        decoration:
            BoxDecoration(
          color:
              const Color(0xFF07131D),
          borderRadius:
              BorderRadius.circular(
            11,
          ),
          border: Border.all(
            color:
                const Color(
              0x8855FF88,
            ),
          ),
        ),
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.graphic_eq,
              color:
                  Color(0xFF55FF88),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'YANSI • LISTENING',
              style: TextStyle(
                color:
                    Colors.white70,
                fontSize: 9,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CORE SCREEN
// ============================================================

class CoreScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final String title;
  final String type;
  final IconData icon;

  const CoreScreen({
    super.key,
    required this.prefs,
    required this.title,
    required this.type,
    required this.icon,
  });

  @override
  State<CoreScreen> createState() =>
      _CoreScreenState();
}

class _CoreScreenState
    extends State<CoreScreen> {
  List<Map<String, dynamic>>
      entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final raw =
        widget.prefs.getString(
      'lifeos_entries',
    );

    if (raw == null) return;

    try {
      final list =
          jsonDecode(raw) as List;

      setState(() {
        entries =
            list
                .map(
                  (e) => Map<String,
                      dynamic>.from(e),
                )
                .where(
                  (e) =>
                      e['type'] ==
                      widget.type,
                )
                .toList();
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        title: Row(
          children: [
            Icon(
              widget.icon,
              color:
                  const Color(
                0xFF55FF88,
              ),
              size: 19,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(widget.title),
          ],
        ),
      ),
      body: Stack(
        children: [
          const FutureBackground(),

          ListView(
            padding:
                const EdgeInsets.all(
              16,
            ),
            children: [
              _summary(),

              const SizedBox(
                height: 18,
              ),

              if (entries.isEmpty)
                const Padding(
                  padding:
                      EdgeInsets.all(30),
                  child: Text(
                    'Nothing recorded yet.\n\nTell Yansi naturally and it will appear here.',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color:
                          Colors.white38,
                      height: 1.6,
                    ),
                  ),
                ),

              ...entries.map(
                (entry) =>
                    _entry(entry),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summary() {
    double total = 0;

    for (final e in entries) {
      if (e['amount'] is num) {
        total +=
            (e['amount'] as num)
                .toDouble();
      }
    }

    return Container(
      padding:
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
        color:
            const Color(0xDD07131D),
        borderRadius:
            BorderRadius.circular(
          13,
        ),
        border: Border.all(
          color:
              const Color(0x3300E5FF),
        ),
      ),
      child: Row(
        children: [
          const YansiOrb(
            size: 72,
          ),
          const SizedBox(
            width: 14,
          ),
          Expanded(
            child: Text(
              _summaryText(total),
              style:
                  const TextStyle(
                color:
                    Colors.white70,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _summaryText(
    double total,
  ) {
    switch (widget.type) {
      case 'expense':
        return 'Yansi is monitoring your money. Recorded total: ₹${total.toStringAsFixed(0)}.';
      case 'goal':
        return 'Yansi is tracking your goals and keeping them connected to the rest of your life.';
      case 'productivity':
        return 'Yansi is tracking your tasks and productivity.';
      case 'household':
        return 'Yansi is organizing your household requirements.';
      case 'calendar':
        return 'Yansi is keeping important dates and reminders connected.';
      default:
        return 'Yansi is analyzing this area of your life.';
    }
  }

  Widget _entry(
    Map<String, dynamic> entry,
  ) {
    final amount =
        entry['amount'];

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 9,
      ),
      padding:
          const EdgeInsets.all(14),
      decoration:
          BoxDecoration(
        color:
            const Color(0xDD07131D),
        borderRadius:
            BorderRadius.circular(
          10,
        ),
        border: Border.all(
          color:
              const Color(0x2200E5FF),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.circle,
            size: 6,
            color:
                Color(0xFF55FF88),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              entry['title']
                      ?.toString() ??
                  '',
              style:
                  const TextStyle(
                fontSize: 11,
                color:
                    Colors.white70,
              ),
            ),
          ),
          if (amount is num &&
              amount > 0)
            Text(
              '₹${amount.toStringAsFixed(0)}',
              style:
                  const TextStyle(
                color:
                    Color(0xFF55FF88),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE
// ============================================================

class ProfileScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final String currentName;

  const ProfileScreen({
    super.key,
    required this.prefs,
    required this.currentName,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  late TextEditingController name;
  String currency = 'INR ₹';
  String language = 'English';

  @override
  void initState() {
    super.initState();

    name = TextEditingController(
      text: widget.currentName,
    );

    currency =
        widget.prefs.getString(
              'currency',
            ) ??
            'INR ₹';

    language =
        widget.prefs.getString(
              'language',
            ) ??
            'English';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('PROFILE'),
      ),
      body: Stack(
        children: [
          const FutureBackground(),

          ListView(
            padding:
                const EdgeInsets.all(
              20,
            ),
            children: [
              const YansiOrb(
                size: 110,
              ),

              const SizedBox(
                height: 20,
              ),

              TextField(
                controller: name,
                decoration:
                    const InputDecoration(
                  labelText:
                      'YOUR NAME',
                  prefixIcon:
                      Icon(Icons.person),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              DropdownButtonFormField<
                  String>(
                value: currency,
                decoration:
                    const InputDecoration(
                  labelText:
                      'CURRENCY',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'INR ₹',
                    child:
                        Text('INR ₹'),
                  ),
                  DropdownMenuItem(
                    value: 'USD \$',
                    child:
                        Text('USD \$'),
                  ),
                  DropdownMenuItem(
                    value: 'EUR €',
                    child:
                        Text('EUR €'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      currency = v;
                    });
                  }
                },
              ),

              const SizedBox(
                height: 16,
              ),

              DropdownButtonFormField<
                  String>(
                value: language,
                decoration:
                    const InputDecoration(
                  labelText:
                      'LANGUAGE',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'English',
                    child:
                        Text('English'),
                  ),
                  DropdownMenuItem(
                    value: 'Hindi',
                    child:
                        Text('Hindi'),
                  ),
                  DropdownMenuItem(
                    value: 'Gujarati',
                    child:
                        Text('Gujarati'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      language = v;
                    });
                  }
                },
              ),

              const SizedBox(
                height: 25,
              ),

              ElevatedButton(
                onPressed: () async {
                  await widget.prefs
                      .setString(
                    'user_name',
                    name.text.trim(),
                  );

                  await widget.prefs
                      .setString(
                    'currency',
                    currency,
                  );

                  await widget.prefs
                      .setString(
                    'language',
                    language,
                  );

                  if (mounted) {
                    Navigator.pop(
                      context,
                    );
                  }
                },
                child: const Text(
                  'SAVE PROFILE',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PERMISSIONS
// ============================================================

class PermissionScreen
    extends StatefulWidget {
  const PermissionScreen({
    super.key,
  });

  @override
  State<PermissionScreen> createState() =>
      _PermissionScreenState();
}

class _PermissionScreenState
    extends State<PermissionScreen> {
  final SpeechToText speech =
      SpeechToText();

  bool microphone = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('YANSI PERMISSIONS'),
      ),
      body: Stack(
        children: [
          const FutureBackground(),

          ListView(
            padding:
                const EdgeInsets.all(20),
            children: [
              const YansiOrb(
                size: 130,
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                'Yansi needs your permission before accessing device information.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      Colors.white70,
                  height: 1.5,
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              _permission(
                Icons.mic_none,
                'MICROPHONE',
                'Voice interaction with Yansi',
                microphone,
                _microphone,
              ),

              _permission(
                Icons.notifications_none,
                'NOTIFICATIONS',
                'Allow Yansi to understand useful permitted notifications',
                false,
                () {},
              ),

              _permission(
                Icons.calendar_today_outlined,
                'CALENDAR',
                'Important dates, bills and reminders',
                false,
                () {},
              ),

              _permission(
                Icons.camera_alt_outlined,
                'CAMERA',
                'Receipt and document scanning',
                false,
                () {},
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                'Privacy rule: Yansi must never secretly record conversations. Voice activation remains user-controlled.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      Colors.white38,
                  fontSize: 10,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _permission(
    IconData icon,
    String title,
    String subtitle,
    bool enabled,
    VoidCallback action,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xDD07131D),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color:
              const Color(0x2200E5FF),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              const Color(0xFF55FF88),
        ),
        title: Text(
          title,
          style:
              const TextStyle(
            fontSize: 11,
          ),
        ),
        subtitle: Text(
          subtitle,
          style:
              const TextStyle(
            fontSize: 9,
            color:
                Colors.white38,
          ),
        ),
        trailing: Switch(
          value: enabled,
          onChanged: (_) {
            action();
          },
        ),
      ),
    );
  }

  Future<void> _microphone() async {
    final result =
        await speech.initialize();

    setState(() {
      microphone = result;
    });
  }
}

// ============================================================
// REPORTS
// ============================================================

class ReportScreen extends StatelessWidget {
  final List<Map<String, dynamic>>
      entries;

  const ReportScreen({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    double expenses = 0;

    int tasks = 0;
    int household = 0;
    int goals = 0;
    int calendar = 0;

    for (final e in entries) {
      if (e['type'] == 'expense' &&
          e['amount'] is num) {
        expenses +=
            (e['amount'] as num)
                .toDouble();
      }

      if (e['type'] ==
          'productivity') {
        tasks++;
      }

      if (e['type'] ==
          'household') {
        household++;
      }

      if (e['type'] == 'goal') {
        goals++;
      }

      if (e['type'] == 'calendar') {
        calendar++;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('LIFE REPORT'),
      ),
      body: Stack(
        children: [
          const FutureBackground(),

          ListView(
            padding:
                const EdgeInsets.all(20),
            children: [
              const YansiOrb(
                size: 130,
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                'YOUR LIFEOS SNAPSHOT',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  letterSpacing: 3,
                  color:
                      Color(0xFF00E5FF),
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              _reportCard(
                'TOTAL RECORDED EXPENSE',
                '₹${expenses.toStringAsFixed(0)}',
                Icons
                    .account_balance_wallet_outlined,
              ),

              _reportCard(
                'PRODUCTIVITY ITEMS',
                '$tasks',
                Icons.bolt_outlined,
              ),

              _reportCard(
                'HOUSEHOLD ITEMS',
                '$household',
                Icons
                    .shopping_bag_outlined,
              ),

              _reportCard(
                'GOALS',
                '$goals',
                Icons.flag_outlined,
              ),

              _reportCard(
                'CALENDAR ITEMS',
                '$calendar',
                Icons
                    .calendar_today_outlined,
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                'Yansi will eventually combine these systems to identify patterns, savings opportunities, productivity trends and upcoming obligations.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      Colors.white38,
                  fontSize: 10,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reportCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
        color:
            const Color(0xDD07131D),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color:
              const Color(0x3300E5FF),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                const Color(
              0xFF55FF88,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(
                color:
                    Colors.white54,
                fontSize: 9,
                letterSpacing:
                    1,
              ),
            ),
          ),
          Text(
            value,
            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FUTURISTIC BACKGROUND
// ============================================================

class FutureBackground
    extends StatelessWidget {
  const FutureBackground({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter:
          _FutureBackgroundPainter(),
      size: Size.infinite,
    );
  }
}

class _FutureBackgroundPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color =
            const Color(0xFF02070D),
    );

    final grid =
        Paint()
          ..color =
              const Color(
            0x1000E5FF,
          )
          ..strokeWidth = .5;

    for (
      double x = 0;
      x < size.width;
      x += 32
    ) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        grid,
      );
    }

    for (
      double y = 0;
      y < size.height;
      y += 32
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        grid,
      );
    }

    final glow =
        Paint()
          ..shader =
              const RadialGradient(
            colors: [
              Color(0x2200E5FF),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(
                size.width / 2,
                size.height / 2,
              ),
              radius:
                  size.width * .7,
            ),
          );

    canvas.drawCircle(
      Offset(
        size.width / 2,
        size.height / 2,
      ),
      size.width * .7,
      glow,
    );
  }

  @override
  bool shouldRepaint(
    CustomPainter oldDelegate,
  ) =>
      false;
}

// ============================================================
// YANSI ORB
// ============================================================

class YansiOrb
    extends StatelessWidget {
  final double size;

  const YansiOrb({
    super.key,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter:
            _YansiPainter(),
        child: Center(
          child: Icon(
            Icons.auto_awesome,
            color:
                const Color(
              0xFF55FF88,
            ),
            size:
                size * .25,
          ),
        ),
      ),
    );
  }
}

class _YansiPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius =
        size.width / 2;

    final ring =
        Paint()
          ..style =
              PaintingStyle.stroke
          ..strokeWidth = 1.1;

    for (int i = 0; i < 8; i++) {
      ring.color =
          i.isEven
              ? const Color(
                  0x6600E5FF,
                )
              : const Color(
                  0x4455FF88,
                );

      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width:
              radius *
                  (1 + i * .13),
          height:
              radius *
                  (.55 + i * .08),
        ),
        ring,
      );
    }

    final nodes =
        Paint()
          ..color =
              const Color(
            0xAA00E5FF,
          );

    for (int i = 0;
        i < 20;
        i++) {
      final angle =
          i *
              math.pi *
              2 /
              20;

      final p =
          center +
              Offset(
                radius *
                    .82 *
                    math.cos(
                      angle,
                    ),
                radius *
                    .54 *
                    math.sin(
                      angle,
                    ),
              );

      canvas.drawCircle(
        p,
        1.8,
        nodes,
      );

      ring.color =
          const Color(
        0x2200E5FF,
      );

      canvas.drawLine(
        center,
        p,
        ring,
      );
    }

    final core =
        Paint()
          ..shader =
              const RadialGradient(
            colors: [
              Color(0x9955FF88),
              Color(0x4400E5FF),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: center,
              radius:
                  radius * .65,
            ),
          );

    canvas.drawCircle(
      center,
      radius * .62,
      core,
    );
  }

  @override
  bool shouldRepaint(
    CustomPainter oldDelegate,
  ) =>
      false;
}
