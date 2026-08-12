import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(LifeOS(prefs: prefs));
}

// ============================================================
// LIFEOS
// ============================================================

class LifeOS extends StatefulWidget {
  final SharedPreferences prefs;

  const LifeOS({
    super.key,
    required this.prefs,
  });

  @override
  State<LifeOS> createState() => _LifeOSState();
}

class _LifeOSState extends State<LifeOS> {
  String? userName;
  String country = 'India';
  String currency = '₹';
  int themeIndex = 0;

  @override
  void initState() {
    super.initState();

    userName = widget.prefs.getString('user_name');
    country = widget.prefs.getString('country') ?? 'India';
    currency = widget.prefs.getString('currency') ?? '₹';
    themeIndex = widget.prefs.getInt('theme_index') ?? 0;
  }

  void finishOnboarding(
    String name,
    String selectedCountry,
    String selectedCurrency,
    int selectedTheme,
  ) async {
    await widget.prefs.setString('user_name', name);
    await widget.prefs.setString('country', selectedCountry);
    await widget.prefs.setString('currency', selectedCurrency);
    await widget.prefs.setInt('theme_index', selectedTheme);

    setState(() {
      userName = name;
      country = selectedCountry;
      currency = selectedCurrency;
      themeIndex = selectedTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userName == null || userName!.trim().isEmpty) {
      return OnboardingScreen(
        onComplete: finishOnboarding,
      );
    }

    return HomeScreen(
      prefs: widget.prefs,
      userName: userName!,
      country: country,
      currency: currency,
      themeIndex: themeIndex,
      onThemeChanged: (index) async {
        await widget.prefs.setInt('theme_index', index);

        setState(() {
          themeIndex = index;
        });
      },
    );
  }
}

// ============================================================
// THEMES
// ============================================================

class LifeTheme {
  final String name;
  final Color background;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color text;
  final Color muted;

  const LifeTheme({
    required this.name,
    required this.background,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.text,
    required this.muted,
  });
}

const List<LifeTheme> lifeThemes = [
  LifeTheme(
    name: 'Aurora Nexus',
    background: Color(0xFF020B0B),
    primary: Color(0xFF00FFD5),
    secondary: Color(0xFF35FF72),
    accent: Color(0xFF00A8FF),
    text: Color(0xFFE9FFFF),
    muted: Color(0xFF83AAA7),
  ),
  LifeTheme(
    name: 'Void Matrix',
    background: Color(0xFF020611),
    primary: Color(0xFF168CFF),
    secondary: Color(0xFF52C7FF),
    accent: Color(0xFF7E9FFF),
    text: Color(0xFFEAF5FF),
    muted: Color(0xFF7690A8),
  ),
  LifeTheme(
    name: 'Quantum Purple',
    background: Color(0xFF0A0310),
    primary: Color(0xFFD24CFF),
    secondary: Color(0xFFFF54C8),
    accent: Color(0xFF8B6CFF),
    text: Color(0xFFFFEEFF),
    muted: Color(0xFFA98EAE),
  ),
  LifeTheme(
    name: 'Solaris Prime',
    background: Color(0xFF0B0802),
    primary: Color(0xFFFFC928),
    secondary: Color(0xFFFFE48A),
    accent: Color(0xFFFF8A00),
    text: Color(0xFFFFF7D9),
    muted: Color(0xFFAA9866),
  ),
  LifeTheme(
    name: 'Frost Minimal',
    background: Color(0xFFF4FAFF),
    primary: Color(0xFF147BFF),
    secondary: Color(0xFF5AC8FF),
    accent: Color(0xFF8BE7FF),
    text: Color(0xFF08244A),
    muted: Color(0xFF68819B),
  ),
];

// ============================================================
// CORE DATA
// ============================================================

enum LifeCore {
  finance,
  goals,
  productivity,
  household,
  diary,
}

const List<String> coreNames = [
  'Financial Life',
  'Goals & Growth',
  'Productivity',
  'Household',
  'Life Diary',
];

// ============================================================
// ONBOARDING
// ============================================================

class OnboardingScreen extends StatefulWidget {
  final Function(
    String,
    String,
    String,
    int,
  ) onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final nameController = TextEditingController();

  String country = 'India';
  String currency = '₹';
  int themeIndex = 0;

  final countries = const {
    'India': '₹',
    'United States': '\$',
    'United Kingdom': '£',
    'Europe': '€',
    'Japan': '¥',
    'Australia': 'A\$',
    'Canada': 'C\$',
    'UAE': 'د.إ',
    'Singapore': 'S\$',
  };

  void continueSetup() {
    final name = nameController.text.trim();

    if (name.isEmpty) return;

    widget.onComplete(
      name,
      country,
      currency,
      themeIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = lifeThemes[themeIndex];

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // LOGO
              YansiOrb(
                theme: theme,
                size: 120,
                animate: true,
              ),

              const SizedBox(height: 22),

              Text(
                'LIFEOS',
                style: TextStyle(
                  color: theme.text,
                  fontSize: 34,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 7,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'YOUR LIFE. INTELLIGENTLY.',
                style: TextStyle(
                  color: theme.muted,
                  fontSize: 11,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 42),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Let’s build your LifeOS',
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: nameController,
                style: TextStyle(color: theme.text),
                decoration: InputDecoration(
                  hintText: 'Your name',
                  hintStyle: TextStyle(color: theme.muted),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: theme.primary,
                  ),
                  filled: true,
                  fillColor: theme.text.withOpacity(.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: theme.primary.withOpacity(.25),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: theme.primary.withOpacity(.20),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: country,
                dropdownColor: theme.background,
                style: TextStyle(color: theme.text),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.public,
                    color: theme.primary,
                  ),
                  filled: true,
                  fillColor: theme.text.withOpacity(.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                items: countries.keys.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    country = value;
                    currency = countries[value]!;
                  });
                },
              ),

              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose your world',
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 17,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: lifeThemes.length,
                  itemBuilder: (context, index) {
                    final item = lifeThemes[index];
                    final selected = index == themeIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          themeIndex = index;
                        });
                      },
                      child: Container(
                        width: 145,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: item.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? item.primary
                                : item.primary.withOpacity(.18),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            YansiOrb(
                              theme: item,
                              size: 42,
                              animate: false,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: item.text,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 34),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: continueSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: theme.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'ENTER LIFEOS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HOME
// ============================================================

class HomeScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final String userName;
  final String country;
  final String currency;
  final int themeIndex;
  final Function(int) onThemeChanged;

  const HomeScreen({
    super.key,
    required this.prefs,
    required this.userName,
    required this.country,
    required this.currency,
    required this.themeIndex,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late LifeTheme theme;

  final FlutterTts tts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  bool listening = false;
  bool thinking = false;
  String transcript = '';

  late AnimationController pulseController;

  @override
  void initState() {
    super.initState();

    theme = lifeThemes[widget.themeIndex];

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _welcome();
    });
  }

  Future<void> _welcome() async {
    await Future.delayed(
      const Duration(milliseconds: 800),
    );

    await tts.setSpeechRate(.45);
    await tts.setPitch(1.0);

    await tts.speak(
      'Welcome, ${widget.userName}. '
      'I am Yansi, your personal LifeOS AI friend. '
      'How can I help you?',
    );
  }

  @override
  void dispose() {
    pulseController.dispose();
    tts.stop();
    super.dispose();
  }

  Future<void> startListening() async {
    if (listening) {
      await speech.stop();

      setState(() {
        listening = false;
      });

      return;
    }

    final available = await speech.initialize();

    if (!available) {
      await tts.speak(
        'Voice input is not available on this device.',
      );
      return;
    }

    setState(() {
      listening = true;
      thinking = false;
      transcript = '';
    });

    await tts.stop();

    await speech.listen(
      localeId: 'en_IN',
      onResult: (result) {
        setState(() {
          transcript = result.recognizedWords;
        });

        if (result.finalResult) {
          processYansiCommand(
            result.recognizedWords,
          );
        }
      },
    );
  }

  Future<void> processYansiCommand(String text) async {
    setState(() {
      listening = false;
      thinking = true;
    });

    await speech.stop();

    final lower = text.toLowerCase();

    // --------------------------------------------------------
    // EXPENSE DETECTION
    // --------------------------------------------------------

    final amountRegex = RegExp(
      r'(?:₹|rs\.?|rupees?)\s*([0-9]+(?:\.[0-9]+)?)',
      caseSensitive: false,
    );

    final match = amountRegex.firstMatch(lower);

    if (match != null) {
      final amount = double.tryParse(match.group(1)!);

      if (amount != null) {
        String category = 'Other';

        if (lower.contains('petrol') ||
            lower.contains('fuel') ||
            lower.contains('diesel')) {
          category = 'Fuel';
        } else if (lower.contains('food') ||
            lower.contains('restaurant') ||
            lower.contains('lunch') ||
            lower.contains('dinner')) {
          category = 'Food';
        } else if (lower.contains('grocery') ||
            lower.contains('groceries') ||
            lower.contains('shopping')) {
          category = 'Shopping';
        } else if (lower.contains('electricity') ||
            lower.contains('bill')) {
          category = 'Bills';
        }

        await saveExpense(
          amount,
          category,
          text,
        );

        setState(() {
          thinking = false;
        });

        await tts.speak(
          'Got it. I added ${widget.currency}'
          '${amount.toStringAsFixed(0)} to $category for today.',
        );

        return;
      }
    }

    // --------------------------------------------------------
    // TASK DETECTION
    // --------------------------------------------------------

    if (lower.contains('need to') ||
        lower.contains('have to') ||
        lower.contains('remind me') ||
        lower.contains('task')) {
      await saveTask(text);

      setState(() {
        thinking = false;
      });

      await tts.speak(
        'Got it. I saved that as a task.',
      );

      return;
    }

    // --------------------------------------------------------
    // DIARY
    // --------------------------------------------------------

    await saveDiary(text);

    setState(() {
      thinking = false;
    });

    await tts.speak(
      'I understood you and saved this in your Life Diary.',
    );
  }

  Future<void> saveExpense(
    double amount,
    String category,
    String originalText,
  ) async {
    final list =
        widget.prefs.getStringList('expenses') ?? [];

    final entry = {
      'date': DateTime.now().toIso8601String(),
      'amount': amount,
      'category': category,
      'text': originalText,
    };

    list.add(jsonEncode(entry));

    await widget.prefs.setStringList(
      'expenses',
      list,
    );
  }

  Future<void> saveTask(String text) async {
    final list =
        widget.prefs.getStringList('tasks') ?? [];

    final entry = {
      'date': DateTime.now().toIso8601String(),
      'text': text,
      'completed': false,
    };

    list.add(jsonEncode(entry));

    await widget.prefs.setStringList(
      'tasks',
      list,
    );
  }

  Future<void> saveDiary(String text) async {
    final list =
        widget.prefs.getStringList('diary') ?? [];

    final entry = {
      'date': DateTime.now().toIso8601String(),
      'text': text,
    };

    list.add(jsonEncode(entry));

    await widget.prefs.setStringList(
      'diary',
      list,
    );
  }

  IconData iconFor(
    int core,
    int selectedTheme,
  ) {
    // Every theme gets its own icon language.
    switch (selectedTheme) {
      case 0:
        return [
          Icons.eco_outlined,
          Icons.track_changes,
          Icons.layers_outlined,
          Icons.home_outlined,
          Icons.calendar_month_outlined,
        ][core];

      case 1:
        return [
          Icons.view_in_ar_outlined,
          Icons.flag_outlined,
          Icons.hub_outlined,
          Icons.shopping_cart_outlined,
          Icons.access_time,
        ][core];

      case 2:
        return [
          Icons.diamond_outlined,
          Icons.rocket_launch_outlined,
          Icons.task_alt,
          Icons.shopping_basket_outlined,
          Icons.menu_book_outlined,
        ][core];

      case 3:
        return [
          Icons.bar_chart_outlined,
          Icons.trending_up,
          Icons.checklist_outlined,
          Icons.home_work_outlined,
          Icons.notifications_none,
        ][core];

      default:
        return [
          Icons.account_balance_wallet_outlined,
          Icons.track_changes,
          Icons.format_list_bulleted,
          Icons.shopping_bag_outlined,
          Icons.calendar_month_outlined,
        ][core];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Stack(
          children: [
            // NEURAL BACKGROUND
            Positioned.fill(
              child: CustomPaint(
                painter: NeuralBackgroundPainter(
                  color: theme.primary,
                ),
              ),
            ),

            Column(
              children: [
                // ------------------------------------------------
                // TOP BAR
                // ------------------------------------------------

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    14,
                    18,
                    0,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: openControlCenter,
                        icon: Icon(
                          Icons.menu,
                          color: theme.text,
                          size: 24,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.notifications_none,
                          color: theme.text,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'GOOD MORNING,',
                  style: TextStyle(
                    color: theme.muted,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  widget.userName,
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),

                const Spacer(),

                // ------------------------------------------------
                // YANSI
                // ------------------------------------------------

                GestureDetector(
                  onTap: startListening,
                  child: AnimatedBuilder(
                    animation: pulseController,
                    builder: (context, child) {
                      return YansiOrb(
                        theme: theme,
                        size: 205,
                        animate: true,
                        listening: listening,
                        thinking: thinking,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                if (listening)
                  Text(
                    'LISTENING...',
                    style: TextStyle(
                      color: theme.primary,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  )
                else if (thinking)
                  Text(
                    'THINKING...',
                    style: TextStyle(
                      color: theme.primary,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  )
                else
                  Text(
                    'TAP YANSI',
                    style: TextStyle(
                      color: theme.muted,
                      fontSize: 9,
                      letterSpacing: 2,
                    ),
                  ),

                if (transcript.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                    ),
                    child: Text(
                      transcript,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // ------------------------------------------------
                // FIVE CORE ORBIT
                // ------------------------------------------------

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  child: SizedBox(
                    height: 230,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(
                            double.infinity,
                            220,
                          ),
                          painter: OrbitPainter(
                            color: theme.primary,
                          ),
                        ),

                        ...List.generate(
                          5,
                          (index) {
                            final angle =
                                (-math.pi / 2) +
                                (index *
                                    (2 * math.pi / 5));

                            final radius = 82.0;

                            return Positioned(
                              left: MediaQuery.of(context)
                                      .size
                                      .width /
                                  2 +
                                  math.cos(angle) *
                                      radius -
                                  29,
                              top: 105 +
                                  math.sin(angle) *
                                      radius -
                                  29,
                              child: GestureDetector(
                                onTap: () {
                                  openCore(
                                    LifeCore.values[index],
                                  );
                                },
                                child: CoreOrb(
                                  icon: iconFor(
                                    index,
                                    widget.themeIndex,
                                  ),
                                  theme: theme,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void openCore(LifeCore core) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoreReportScreen(
          prefs: widget.prefs,
          core: core,
          currency: widget.currency,
          theme: theme,
        ),
      ),
    );
  }

  void openControlCenter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.muted,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  'LIFEOS',
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 20,
                    letterSpacing: 4,
                  ),
                ),

                const SizedBox(height: 22),

                ListTile(
                  leading: Icon(
                    Icons.palette_outlined,
                    color: theme.primary,
                  ),
                  title: Text(
                    'Change design',
                    style: TextStyle(
                      color: theme.text,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    openThemeSelector();
                  },
                ),

                ListTile(
                  leading: Icon(
                    Icons.person_outline,
                    color: theme.primary,
                  ),
                  title: Text(
                    widget.userName,
                    style: TextStyle(
                      color: theme.text,
                    ),
                  ),
                  subtitle: Text(
                    '${widget.country} • ${widget.currency}',
                    style: TextStyle(
                      color: theme.muted,
                    ),
                  ),
                ),

                ListTile(
                  leading: Icon(
                    Icons.security_outlined,
                    color: theme.primary,
                  ),
                  title: Text(
                    'Privacy & permissions',
                    style: TextStyle(
                      color: theme.text,
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void openThemeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.background,
      builder: (_) {
        return SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: lifeThemes.length,
            itemBuilder: (context, index) {
              final item = lifeThemes[index];

              return ListTile(
                leading: YansiOrb(
                  theme: item,
                  size: 46,
                  animate: false,
                ),
                title: Text(
                  item.name,
                  style: TextStyle(
                    color: item.text,
                  ),
                ),
                trailing: index == widget.themeIndex
                    ? Icon(
                        Icons.check_circle,
                        color: item.primary,
                      )
                    : null,
                onTap: () {
                  widget.onThemeChanged(index);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }
}

// ============================================================
// YANSI ORB
// ============================================================

class YansiOrb extends StatefulWidget {
  final LifeTheme theme;
  final double size;
  final bool animate;
  final bool listening;
  final bool thinking;

  const YansiOrb({
    super.key,
    required this.theme,
    required this.size,
    required this.animate,
    this.listening = false,
    this.thinking = false,
  });

  @override
  State<YansiOrb> createState() => _YansiOrbState();
}

class _YansiOrbState extends State<YansiOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    if (widget.animate) {
      controller.repeat();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return CustomPaint(
          size: Size.square(widget.size),
          painter: YansiPainter(
            theme: widget.theme,
            phase: controller.value,
            listening: widget.listening,
            thinking: widget.thinking,
          ),
        );
      },
    );
  }
}

class YansiPainter extends CustomPainter {
  final LifeTheme theme;
  final double phase;
  final bool listening;
  final bool thinking;

  YansiPainter({
    required this.theme,
    required this.phase,
    required this.listening,
    required this.thinking,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width * .32;

    // Outer glow
    final glowPaint = Paint()
      ..color = theme.primary.withOpacity(
        listening ? .22 : .12,
      )
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        18,
      );

    canvas.drawCircle(
      center,
      radius * 1.25,
      glowPaint,
    );

    // Orbit
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = theme.primary.withOpacity(.35);

    canvas.drawCircle(
      center,
      radius * 1.18,
      orbitPaint,
    );

    canvas.drawCircle(
      center,
      radius * 1.05,
      orbitPaint,
    );

    // Neural points
    for (int i = 0; i < 5; i++) {
      final angle =
          phase * math.pi * 2 +
          (i * math.pi * 2 / 5);

      final point = Offset(
        center.dx +
            math.cos(angle) *
                radius *
                1.18,
        center.dy +
            math.sin(angle) *
                radius *
                1.18,
      );

      canvas.drawCircle(
        point,
        size.width * .035,
        Paint()
          ..color = i.isEven
              ? theme.primary
              : theme.secondary,
      );
    }

    // Face
    final facePaint = Paint()
      ..color = theme.background
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      radius,
      facePaint,
    );

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .025
      ..color = theme.primary;

    canvas.drawCircle(
      center,
      radius,
      ringPaint,
    );

    // Eyes
    final eyePaint = Paint()
      ..color = theme.primary
      ..style = PaintingStyle.fill;

    final eyeY = center.dy - radius * .12;

    canvas.drawCircle(
      Offset(
        center.dx - radius * .27,
        eyeY,
      ),
      radius * .075,
      eyePaint,
    );

    canvas.drawCircle(
      Offset(
        center.dx + radius * .27,
        eyeY,
      ),
      radius * .075,
      eyePaint,
    );

    // Smile
    final smilePaint = Paint()
      ..color = theme.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .018
      ..strokeCap = StrokeCap.round;

    final smileRect = Rect.fromCenter(
      center: Offset(
        center.dx,
        center.dy + radius * .12,
      ),
      width: radius * .55,
      height: radius * .35,
    );

    canvas.drawArc(
      smileRect,
      0,
      math.pi,
      false,
      smilePaint,
    );

    // Listening waves
    if (listening) {
      for (int i = 0; i < 3; i++) {
        canvas.drawCircle(
          center,
          radius *
              (1.32 + i * .12),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = theme.primary.withOpacity(
              .45 - i * .12,
            ),
        );
      }
    }

    // Thinking particles
    if (thinking) {
      for (int i = 0; i < 8; i++) {
        final angle =
            phase * math.pi * 2 +
            i * math.pi / 4;

        final p = Offset(
          center.dx +
              math.cos(angle) *
                  radius *
                  1.45,
          center.dy +
              math.sin(angle) *
                  radius *
                  1.45,
        );

        canvas.drawCircle(
          p,
          size.width * .018,
          Paint()..color = theme.accent,
        );
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant YansiPainter oldDelegate,
  ) {
    return true;
  }
}

// ============================================================
// CORE ORB
// ============================================================

class CoreOrb extends StatelessWidget {
  final IconData icon;
  final LifeTheme theme;

  const CoreOrb({
    super.key,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.background.withOpacity(.85),
        border: Border.all(
          color: theme.primary.withOpacity(.65),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withOpacity(.18),
            blurRadius: 16,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: theme.primary,
        size: 25,
      ),
    );
  }
}

// ============================================================
// ORBIT PAINTER
// ============================================================

class OrbitPainter extends CustomPainter {
  final Color color;

  OrbitPainter({
    required this.color,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withOpacity(.25);

    canvas.drawCircle(
      center,
      82,
      paint,
    );

    canvas.drawCircle(
      center,
      102,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant OrbitPainter oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}

// ============================================================
// NEURAL BACKGROUND
// ============================================================

class NeuralBackgroundPainter
    extends CustomPainter {
  final Color color;

  NeuralBackgroundPainter({
    required this.color,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final random = math.Random(7);

    final nodes = <Offset>[];

    for (int i = 0; i < 35; i++) {
      nodes.add(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
      );
    }

    final linePaint = Paint()
      ..color = color.withOpacity(.035)
      ..strokeWidth = 1;

    final nodePaint = Paint()
      ..color = color.withOpacity(.08);

    for (final a in nodes) {
      canvas.drawCircle(
        a,
        1.5,
        nodePaint,
      );

      for (final b in nodes) {
        if ((a - b).distance < 100) {
          canvas.drawLine(
            a,
            b,
            linePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant NeuralBackgroundPainter oldDelegate,
  ) {
    return false;
  }
}

// ============================================================
// CORE REPORT
// ============================================================

class CoreReportScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final LifeCore core;
  final String currency;
  final LifeTheme theme;

  const CoreReportScreen({
    super.key,
    required this.prefs,
    required this.core,
    required this.currency,
    required this.theme,
  });

  @override
  State<CoreReportScreen> createState() =>
      _CoreReportScreenState();
}

class _CoreReportScreenState
    extends State<CoreReportScreen> {
  double totalExpense = 0;
  int taskCount = 0;
  int diaryCount = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    final expenses =
        widget.prefs.getStringList('expenses') ??
            [];

    for (final item in expenses) {
      try {
        final map =
            jsonDecode(item) as Map<String, dynamic>;

        totalExpense +=
            (map['amount'] as num).toDouble();
      } catch (_) {}
    }

    final tasks =
        widget.prefs.getStringList('tasks') ??
            [];

    taskCount = tasks.length;

    final diary =
        widget.prefs.getStringList('diary') ??
            [];

    diaryCount = diary.length;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: widget.theme.text,
        ),
        title: Text(
          coreNames[widget.core.index],
          style: TextStyle(
            color: widget.theme.text,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Main report ring
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(28),
                  border: Border.all(
                    color: widget.theme.primary
                        .withOpacity(.22),
                  ),
                  color: widget.theme.text
                      .withOpacity(.025),
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(180, 180),
                    painter: ReportRingPainter(
                      color: widget.theme.primary,
                      value: _value(),
                    ),
                    child: Center(
                      child: Text(
                        _centerText(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: widget.theme.text,
                          fontSize: 27,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: _metric(
                      'TODAY',
                      _todayText(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _metric(
                      'STATUS',
                      'ACTIVE',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(22),
                  border: Border.all(
                    color: widget.theme.primary
                        .withOpacity(.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: widget.theme.primary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _insight(),
                        style: TextStyle(
                          color: widget.theme.text,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20),
        color: widget.theme.text
            .withOpacity(.025),
        border: Border.all(
          color: widget.theme.primary
              .withOpacity(.12),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: widget.theme.muted,
              fontSize: 9,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: TextStyle(
              color: widget.theme.text,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  double _value() {
    switch (widget.core) {
      case LifeCore.finance:
        return totalExpense == 0 ? .08 : .72;

      case LifeCore.goals:
        return .56;

      case LifeCore.productivity:
        return taskCount == 0 ? .08 : .87;

      case LifeCore.household:
        return .42;

      case LifeCore.diary:
        return diaryCount == 0 ? .08 : .68;
    }
  }

  String _centerText() {
    switch (widget.core) {
      case LifeCore.finance:
        return '${widget.currency}'
            '${totalExpense.toStringAsFixed(0)}';

      case LifeCore.goals:
        return '56%\nPROGRESS';

      case LifeCore.productivity:
        return '$taskCount\nTASKS';

      case LifeCore.household:
        return '42%\nREADY';

      case LifeCore.diary:
        return '$diaryCount\nMEMORIES';
    }
  }

  String _todayText() {
    switch (widget.core) {
      case LifeCore.finance:
        return '${widget.currency}'
            '${totalExpense.toStringAsFixed(0)}';

      case LifeCore.goals:
        return '56%';

      case LifeCore.productivity:
        return '$taskCount';

      case LifeCore.household:
        return 'Active';

      case LifeCore.diary:
        return '$diaryCount';
    }
  }

  String _insight() {
    switch (widget.core) {
      case LifeCore.finance:
        return totalExpense == 0
            ? 'Yansi is ready to learn your spending.'
            : 'Yansi has recorded your expenses and will look for useful spending patterns.';

      case LifeCore.goals:
        return 'Yansi will compare your progress with your goals and suggest your next move.';

      case LifeCore.productivity:
        return taskCount == 0
            ? 'Tell Yansi what you need to do.'
            : 'Yansi is tracking your tasks and completion progress.';

      case LifeCore.household:
        return 'Your household requirements will become smarter as Yansi learns your patterns.';

      case LifeCore.diary:
        return diaryCount == 0
            ? 'Talk naturally. Yansi can turn your thoughts into diary memories.'
            : 'Yansi is building your personal Life Diary.';
    }
  }
}

// ============================================================
// REPORT RING
// ============================================================

class ReportRingPainter extends CustomPainter {
  final Color color;
  final double value;

  ReportRingPainter({
    required this.color,
    required this.value,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width * .38;

    final background = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = color.withOpacity(.10);

    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawCircle(
      center,
      radius,
      background,
    );

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(
    covariant ReportRingPainter oldDelegate,
  ) {
    return oldDelegate.value != value ||
        oldDelegate.color != color;
  }
}
