import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

const Color cyan = Color(0xFF00E5FF);
const Color green = Color(0xFF55FF88);
const Color background = Color(0xFF02070D);
const Color panel = Color(0xFF07131D);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LifeOS());
}

class LifeOS extends StatelessWidget {
  const LifeOS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeOS',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: cyan,
          brightness: Brightness.dark,
        ),
      ),
      home: const BootScreen(),
    );
  }
}

// ============================================================
// BOOT
// ============================================================

class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  @override
  void initState() {
    super.initState();
    _openApp();
  }

  Future<void> _openApp() async {
    final prefs = await SharedPreferences.getInstance();

    await Future.delayed(
      const Duration(milliseconds: 800),
    );

    if (!mounted) return;

    final name = prefs.getString('name');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) {
          if (name == null || name.trim().isEmpty) {
            return const OnboardingScreen();
          }

          return const HomeScreen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            YansiOrb(size: 120),
            SizedBox(height: 22),
            Text(
              'L I F E O S',
              style: TextStyle(
                fontSize: 24,
                letterSpacing: 8,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'INTELLIGENCE FOR EVERYDAY LIFE',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 2,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ONBOARDING
// ============================================================

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  String language = 'English';
  String currency = 'INR (₹)';

  Future<void> _createLifeOS() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name.'),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', name);
    await prefs.setString(
      'email',
      emailController.text.trim(),
    );
    await prefs.setString('language', language);
    await prefs.setString('currency', currency);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const PermissionCenter(),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const YansiOrb(size: 105),

                const SizedBox(height: 20),

                const Text(
                  'MEET YANSI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: green,
                    letterSpacing: 4,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Your personal LifeOS AI agent.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w300,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Tell LifeOS about yourself once. '
                  'Yansi will make the experience personal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                HudField(
                  controller: nameController,
                  label: 'YOUR NAME',
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 12),

                HudField(
                  controller: emailController,
                  label: 'EMAIL (OPTIONAL)',
                  icon: Icons.alternate_email,
                ),

                const SizedBox(height: 12),

                _dropdown(
                  'LANGUAGE',
                  language,
                  [
                    'English',
                    'Hindi',
                    'Gujarati',
                  ],
                  (value) {
                    setState(() {
                      language = value;
                    });
                  },
                ),

                const SizedBox(height: 12),

                _dropdown(
                  'CURRENCY',
                  currency,
                  [
                    'INR (₹)',
                    'USD (\$)',
                    'EUR (€)',
                  ],
                  (value) {
                    setState(() {
                      currency = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                HudButton(
                  text: 'CREATE MY LIFEOS',
                  icon: Icons.arrow_forward_rounded,
                  onTap: _createLifeOS,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> values,
    ValueChanged<String> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: hudDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: panel,
          items: values
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}

// ============================================================
// PERMISSION CENTER
// ============================================================

class PermissionCenter extends StatefulWidget {
  const PermissionCenter({super.key});

  @override
  State<PermissionCenter> createState() =>
      _PermissionCenterState();
}

class _PermissionCenterState
    extends State<PermissionCenter> {
  final Map<String, bool> permissions = {
    'Microphone / Voice': false,
    'Notifications': false,
    'Calendar': false,
    'Camera / Receipts': false,
    'Contacts': false,
    'Location': false,
    'Health data': false,
  };

  Future<void> _enterLifeOS() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'permissions_seen',
      true,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(
          firstOpen: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'YANSI PERMISSION CENTER',
                  style: TextStyle(
                    color: cyan,
                    letterSpacing: 3,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Yansi works with your permission.',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Ghost mode is ambient and unobtrusive. '
                  'It never means secret recording. '
                  'You control Android permissions.',
                  style: TextStyle(
                    color: Colors.white54,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                ...permissions.keys.map(
                  (permission) =>
                      _permissionTile(permission),
                ),

                const SizedBox(height: 15),

                HudButton(
                  text: 'ENTER LIFEOS',
                  icon: Icons.bolt,
                  onTap: _enterLifeOS,
                ),

                const SizedBox(height: 12),

                const Text(
                  'If a permission is denied, manual entry remains available.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionTile(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: hudDecoration(),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(
          _permissionDescription(title),
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
          ),
        ),
        secondary: Icon(
          _permissionIcon(title),
          color: green,
        ),
        value: permissions[title]!,
        activeColor: green,
        onChanged: (value) async {
          if (title == 'Microphone / Voice' &&
              value) {
            final speech = stt.SpeechToText();
            await speech.initialize();
          }

          setState(() {
            permissions[title] = value;
          });
        },
      ),
    );
  }

  String _permissionDescription(String title) {
    switch (title) {
      case 'Microphone / Voice':
        return 'Speak naturally with Yansi.';
      case 'Notifications':
        return 'Allow Yansi to process permitted notifications.';
      case 'Calendar':
        return 'Bills, appointments and important dates.';
      case 'Camera / Receipts':
        return 'Scan receipts and household bills.';
      case 'Contacts':
        return 'Optional contact-based reminders.';
      case 'Location':
        return 'Optional location-aware features.';
      case 'Health data':
        return 'Optional health integrations.';
      default:
        return 'Optional LifeOS integration.';
    }
  }

  IconData _permissionIcon(String title) {
    if (title.startsWith('Microphone')) {
      return Icons.mic_none;
    }

    if (title.startsWith('Notifications')) {
      return Icons.notifications_none;
    }

    if (title.startsWith('Calendar')) {
      return Icons.calendar_month;
    }

    if (title.startsWith('Camera')) {
      return Icons.camera_alt_outlined;
    }

    if (title.startsWith('Contacts')) {
      return Icons.contacts_outlined;
    }

    if (title.startsWith('Location')) {
      return Icons.location_on_outlined;
    }

    return Icons.favorite_border;
  }
}

// ============================================================
// HOME + YANSI
// ============================================================

class HomeScreen extends StatefulWidget {
  final bool firstOpen;

  const HomeScreen({
    super.key,
    this.firstOpen = false,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts tts = FlutterTts();
  final stt.SpeechToText speech =
      stt.SpeechToText();

  bool listening = false;
  bool menuOpen = false;

  String heard = '';
  String userName = 'there';

  @override
  void initState() {
    super.initState();
    _initializeYansi();
  }

  Future<void> _initializeYansi() async {
    final prefs =
        await SharedPreferences.getInstance();

    userName =
        prefs.getString('name') ?? 'there';

    await tts.setLanguage('en-IN');
    await tts.setSpeechRate(0.46);
    await tts.setPitch(1.0);

    if (widget.firstOpen) {
      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      await _speak(
        'Welcome, $userName. '
        'I am Yansi, your personal LifeOS AI agent. '
        'I am here whenever you need me.',
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _speak(String text) async {
    await tts.stop();
    await tts.speak(text);
  }

  Future<void> _activateYansi() async {
    if (listening) {
      await speech.stop();

      setState(() {
        listening = false;
      });

      return;
    }

    final available =
        await speech.initialize();

    if (!available) {
      await _speak(
        'Voice recognition is not available. '
        'You can still enter information manually.',
      );
      return;
    }

    setState(() {
      listening = true;
      heard = '';
    });

    await speech.listen(
      localeId: 'en_IN',
      listenFor: const Duration(
        seconds: 30,
      ),
      pauseFor: const Duration(
        seconds: 4,
      ),
      partialResults: true,
      onResult: (result) async {
        if (!mounted) return;

        setState(() {
          heard = result.recognizedWords;
        });

        if (result.finalResult) {
          setState(() {
            listening = false;
          });

          await _processSpeech(
            result.recognizedWords,
          );
        }
      },
    );
  }

  Future<void> _processSpeech(
    String text,
  ) async {
    final lower =
        text.toLowerCase();

    final amount =
        _extractAmount(text);

    // EXPENSE
    if (amount != null &&
        (lower.contains('spent') ||
            lower.contains('paid') ||
            lower.contains('expense') ||
            lower.contains('petrol') ||
            lower.contains('fuel') ||
            lower.contains('diesel'))) {
      final category =
          _expenseCategory(lower);

      final prefs =
          await SharedPreferences.getInstance();

      final expenses =
          prefs.getStringList('expenses') ??
              [];

      expenses.add(
        '${DateTime.now().toIso8601String()}|'
        '$category|$amount|$text',
      );

      await prefs.setStringList(
        'expenses',
        expenses,
      );

      await _speak(
        'Got it. I added '
        '${amount.toStringAsFixed(0)} '
        'to $category for today.',
      );

      return;
    }

    // HOUSEHOLD
    if (lower.contains('buy ') ||
        lower.contains('shopping') ||
        lower.contains('milk') ||
        lower.contains('vegetable')) {
      await _saveRecord(
        'household',
        text,
      );

      await _speak(
        'Got it. I added that to your household list.',
      );

      return;
    }

    // CALENDAR
    if (lower.contains('remind') ||
        lower.contains('tomorrow') ||
        lower.contains('due')) {
      await _saveRecord(
        'calendar',
        text,
      );

      await _speak(
        'Done. I added that to your reminders.',
      );

      return;
    }

    // GOALS
    if (lower.contains('goal') ||
        lower.contains('target') ||
        lower.contains('achieve')) {
      await _saveRecord(
        'goals',
        text,
      );

      await _speak(
        'Done. I saved that as a goal.',
      );

      return;
    }

    // PRODUCTIVITY
    if (lower.contains('task') ||
        lower.contains('todo') ||
        lower.contains('finish') ||
        lower.contains('complete')) {
      await _saveRecord(
        'tasks',
        text,
      );

      await _speak(
        'Done. I saved that as a productivity task.',
      );

      return;
    }

    await _speak(
      'Tell me an expense, goal, task, '
      'household requirement, or reminder.',
    );
  }

  Future<void> _saveRecord(
    String key,
    String value,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final records =
        prefs.getStringList(key) ?? [];

    records.add(
      '${DateTime.now().toIso8601String()}|$value',
    );

    await prefs.setStringList(
      key,
      records,
    );
  }

  double? _extractAmount(String text) {
    final match = RegExp(
      r'(\d+(?:,\d{3})*(?:\.\d+)?)',
    ).firstMatch(
      text.replaceAll('₹', ''),
    );

    if (match == null) {
      return null;
    }

    return double.tryParse(
      match
          .group(1)!
          .replaceAll(',', ''),
    );
  }

  String _expenseCategory(
    String text,
  ) {
    if (text.contains('petrol') ||
        text.contains('fuel') ||
        text.contains('diesel') ||
        text.contains('cng')) {
      return 'Fuel';
    }

    if (text.contains('food') ||
        text.contains('restaurant') ||
        text.contains('lunch') ||
        text.contains('dinner')) {
      return 'Food';
    }

    if (text.contains('medical') ||
        text.contains('doctor') ||
        text.contains('medicine')) {
      return 'Medical';
    }

    if (text.contains('electric')) {
      return 'Electricity';
    }

    if (text.contains('emi') ||
        text.contains('loan')) {
      return 'EMI';
    }

    if (text.contains('mobile') ||
        text.contains('recharge')) {
      return 'Mobile';
    }

    return 'Other';
  }

  @override
  void dispose() {
    speech.stop();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),

          SafeArea(
            child: Column(
              children: [
                _topBar(),
                Expanded(
                  child: _mainHud(),
                ),
              ],
            ),
          ),

          if (menuOpen) _controlCenter(),

          if (listening) _voicePanel(),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          SmallHudIcon(
            icon: Icons.menu_rounded,
            onTap: () {
              setState(() {
                menuOpen = !menuOpen;
              });
            },
          ),

          const Spacer(),

          const Text(
            'L I F E O S',
            style: TextStyle(
              letterSpacing: 5,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),

          const Spacer(),

          SmallHudIcon(
            icon: Icons.notifications_none,
            dot: true,
            onTap: () {
              _speak(
                'You have no new LifeOS alerts.',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _mainHud() {
    return LayoutBuilder(
      builder: (context, size) {
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: NeuralPainter(),
              ),
            ),

            Positioned(
              top: 28,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'GOOD DAY, '
                    '${userName.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 9,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'YOUR LIFE, CONNECTED.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: size.maxWidth / 2 - 80,
              top: size.maxHeight / 2 - 85,
              child: GestureDetector(
                onTap: _activateYansi,
                child: const YansiOrb(
                  size: 160,
                ),
              ),
            ),

            _coreNode(
              left: 16,
              top: size.maxHeight * .25,
              icon: Icons.account_balance_wallet_outlined,
              label: 'MONEY',
              storageKey: 'expenses',
            ),

            _coreNode(
              right: 16,
              top: size.maxHeight * .25,
              icon: Icons.flag_outlined,
              label: 'GOALS',
              storageKey: 'goals',
            ),

            _coreNode(
              left: 16,
              top: size.maxHeight * .68,
              icon: Icons.bolt_outlined,
              label: 'PRODUCTIVITY',
              storageKey: 'tasks',
            ),

            _coreNode(
              right: 16,
              top: size.maxHeight * .68,
              icon: Icons.shopping_bag_outlined,
              label: 'HOUSEHOLD',
              storageKey: 'household',
            ),

            Positioned(
              bottom: 20,
              left: size.maxWidth / 2 - 45,
              child: GestureDetector(
                onTap: () {
                  _openCore(
                    'Calendar',
                    Icons.calendar_today,
                    'calendar',
                  );
                },
                child: Container(
                  width: 90,
                  height: 45,
                  decoration: hudDecoration(),
                  child: const Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: green,
                        size: 17,
                      ),
                      Text(
                        'CALENDAR',
                        style: TextStyle(
                          fontSize: 7,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _coreNode({
    double? left,
    double? right,
    required double top,
    required IconData icon,
    required String label,
    required String storageKey,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: GestureDetector(
        onTap: () {
          _openCore(
            label,
            icon,
            storageKey,
          );
        },
        child: Container(
          width: 108,
          padding: const EdgeInsets.all(11),
          decoration: hudDecoration(),
          child: Row(
            children: [
              Icon(
                icon,
                color: green,
                size: 20,
              ),

              const SizedBox(width: 7),

              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 8,
                    letterSpacing: 1.1,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCore(
    String title,
    IconData icon,
    String storageKey,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoreScreen(
          title: title,
          icon: icon,
          storageKey: storageKey,
        ),
      ),
    );
  }

  Widget _controlCenter() {
    return Positioned(
      top: 50,
      left: 8,
      child: Container(
        width: 225,
        padding: const EdgeInsets.all(14),
        decoration: hudDecoration().copyWith(
          color: panel,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'CONTROL CENTER',
              style: TextStyle(
                color: cyan,
                letterSpacing: 2,
                fontSize: 10,
              ),
            ),

            _menuItem(
              Icons.person_outline,
              'Profile',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ProfileScreen(),
                  ),
                );
              },
            ),

            _menuItem(
              Icons.security,
              'Yansi Permissions',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const PermissionCenter(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    VoidCallback action,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          menuOpen = false;
        });

        action();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 11,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: green,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _voicePanel() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: hudDecoration(),
        child: Row(
          children: [
            const Icon(
              Icons.graphic_eq,
              color: green,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                heard.isEmpty
                    ? 'Yansi is listening…'
                    : heard,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
              ),
            ),

            IconButton(
              onPressed: _activateYansi,
              icon: const Icon(
                Icons.stop_circle_outlined,
                color: cyan,
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
  final String title;
  final IconData icon;
  final String storageKey;

  const CoreScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.storageKey,
  });

  @override
  State<CoreScreen> createState() =>
      _CoreScreenState();
}

class _CoreScreenState extends State<CoreScreen> {
  List<String> records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final prefs =
        await SharedPreferences.getInstance();

    setState(() {
      records =
          prefs.getStringList(
                widget.storageKey,
              ) ??
              [];
    });
  }

  Future<void> _manualAdd() async {
    final controller =
        TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            'Add to ${widget.title}',
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration:
                const InputDecoration(
