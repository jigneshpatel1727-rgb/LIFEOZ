import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(LifeOSApp(prefs: prefs));
}

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
        scaffoldBackgroundColor: const Color(0xFF02070D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: LifeOSRouter(prefs: prefs),
    );
  }
}

class LifeOSRouter extends StatefulWidget {
  final SharedPreferences prefs;

  const LifeOSRouter({
    super.key,
    required this.prefs,
  });

  @override
  State<LifeOSRouter> createState() => _LifeOSRouterState();
}

class _LifeOSRouterState extends State<LifeOSRouter> {
  bool get loggedIn =>
      widget.prefs.getBool('logged_in') ?? false;

  @override
  Widget build(BuildContext context) {
    if (!loggedIn) {
      return LoginScreen(
        prefs: widget.prefs,
        onLogin: () => setState(() {}),
      );
    }

    return OnboardingScreen(
      prefs: widget.prefs,
      onComplete: () => setState(() {}),
    );
  }
}

// ============================================================
// LOGIN
// ============================================================

class LoginScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final VoidCallback onLogin;

  const LoginScreen({
    super.key,
    required this.prefs,
    required this.onLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final otp = TextEditingController();

  bool phoneMode = false;
  bool otpMode = false;
  bool obscure = true;

  void login() {
    final identifier =
        phoneMode ? phone.text.trim() : email.text.trim();

    if (identifier.isEmpty) {
      snack('Enter your email or mobile number.');
      return;
    }

    if (!otpMode && password.text.isEmpty) {
      snack('Enter your password.');
      return;
    }

    if (otpMode && otp.text.length < 4) {
      snack('Enter the OTP.');
      return;
    }

    widget.prefs.setBool('logged_in', true);
    widget.onLogin();
  }

  void snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const FutureBackground(),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    const YansiOrb(size: 170),

                    const SizedBox(height: 20),

                    const Text(
                      'L I F E O S',
                      style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 8,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'ONE LIFE • ONE INTELLIGENCE',
                      style: TextStyle(
                        color: Color(0xFF55FF88),
                        fontSize: 9,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 35),

                    Row(
                      children: [
                        Expanded(
                          child: modeButton(
                            'EMAIL',
                            !phoneMode,
                            () => setState(
                              () => phoneMode = false,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: modeButton(
                            'PHONE',
                            phoneMode,
                            () => setState(
                              () => phoneMode = true,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller:
                          phoneMode ? phone : email,
                      keyboardType: phoneMode
                          ? TextInputType.phone
                          : TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: phoneMode
                            ? 'Mobile number'
                            : 'Email address',
                        prefixIcon: Icon(
                          phoneMode
                              ? Icons.phone_outlined
                              : Icons.alternate_email,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (!otpMode)
                      TextField(
                        controller: password,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon:
                              const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(
                                () => obscure = !obscure,
                              );
                            },
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),

                    if (otpMode)
                      TextField(
                        controller: otp,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'OTP',
                          prefixIcon:
                              Icon(Icons.password_outlined),
                        ),
                      ),

                    const SizedBox(height: 8),

                    TextButton(
                      onPressed: () {
                        setState(
                          () => otpMode = !otpMode,
                        );
                      },
                      child: Text(
                        otpMode
                            ? 'USE PASSWORD'
                            : 'LOGIN WITH OTP',
                        style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 10,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: login,
                        child: Text(
                          otpMode
                              ? 'VERIFY OTP'
                              : 'ENTER LIFEOS',
                          style: const TextStyle(
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () {
                        snack(
                          'Password recovery will use secure authentication.',
                        );
                      },
                      child: const Text(
                        'FORGOT PASSWORD?',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white54,
                        ),
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

  Widget modeButton(
    String text,
    bool selected,
    VoidCallback action,
  ) {
    return GestureDetector(
      onTap: action,
      child: Container(
        height: 43,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0x2200E5FF)
              : const Color(0xAA07131D),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? const Color(0xAA00E5FF)
                : const Color(0x2200E5FF),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ONBOARDING
// ============================================================

class OnboardingScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.prefs,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final name = TextEditingController();

  int step = 0;

  String country = 'India';
  String currency = 'INR ₹';
  String language = 'English';

  bool mic = false;
  bool notifications = false;
  bool calendar = false;
  bool camera = false;

  final countries = [
    'India',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'United Arab Emirates',
    'Singapore',
    'Germany',
    'France',
    'Japan',
  ];

  String getCurrency(String country) {
    switch (country) {
      case 'United States':
        return 'USD \$';
      case 'United Kingdom':
        return 'GBP £';
      case 'Canada':
        return 'CAD \$';
      case 'Australia':
        return 'AUD \$';
      case 'United Arab Emirates':
        return 'AED د.إ';
      case 'Singapore':
        return 'SGD \$';
      case 'Germany':
      case 'France':
        return 'EUR €';
      case 'Japan':
        return 'JPY ¥';
      default:
        return 'INR ₹';
    }
  }

  Future<void> finish() async {
    if (name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your name.'),
        ),
      );
      return;
    }

    await widget.prefs.setString(
      'name',
      name.text.trim(),
    );

    await widget.prefs.setString(
      'country',
      country,
    );

    await widget.prefs.setString(
      'currency',
      currency,
    );

    await widget.prefs.setString(
      'language',
      language,
    );

    await widget.prefs.setBool(
      'onboarding_complete',
      true,
    );

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.prefs.getBool('onboarding_complete') ??
        false) {
      return LifeOSHome(
        prefs: widget.prefs,
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          const FutureBackground(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  const YansiOrb(size: 115),

                  const SizedBox(height: 15),

                  Text(
                    step == 0
                        ? 'WHO ARE YOU?'
                        : step == 1
                            ? 'YOUR WORLD'
                            : step == 2
                                ? 'MAKE IT YOURS'
                                : 'YANSI PERMISSIONS',
                    style: const TextStyle(
                      fontSize: 19,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: page(),
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (step < 3) {
                          setState(() => step++);
                        } else {
                          finish();
                        }
                      },
                      child: Text(
                        step == 3
                            ? 'ENTER LIFEOS'
                            : 'CONTINUE',
                        style: const TextStyle(
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget page() {
    if (step == 0) {
      return Center(
        child: TextField(
          controller: name,
          decoration: const InputDecoration(
            hintText: 'Your name',
            prefixIcon:
                Icon(Icons.person_outline),
          ),
        ),
      );
    }

    if (step == 1) {
      return Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            DropdownButtonFormField<String>(
              value: country,
              decoration: const InputDecoration(
                labelText: 'COUNTRY',
                prefixIcon:
                    Icon(Icons.public),
              ),
              items: countries.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    country = v;
                    currency =
                        getCurrency(v);
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            Container(
              padding:
                  const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color:
                    const Color(0xCC07131D),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons
                        .account_balance_wallet_outlined,
                    color:
                        Color(0xFF55FF88),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AUTOMATIC CURRENCY',
                        style: TextStyle(
                          fontSize: 8,
                          color:
                              Colors.white38,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        currency,
                        style:
                            const TextStyle(
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (step == 2) {
      return ListView(
        padding:
            const EdgeInsets.only(top: 20),
        children: [
          setting(
            Icons.translate,
            'LANGUAGE',
            language,
            () {
              setState(() {
                language =
                    language == 'English'
                        ? 'Hindi'
                        : language == 'Hindi'
                            ? 'Gujarati'
                            : 'English';
              });
            },
          ),
          setting(
            Icons.palette_outlined,
            'DESIGN',
            'Futuristic',
            () {},
          ),
          setting(
            Icons.graphic_eq,
            'YANSI',
            'Ambient AI',
            () {},
          ),
          setting(
            Icons.notifications_none,
            'REMINDERS',
            'Smart',
            () {},
          ),
        ],
      );
    }

    return ListView(
      padding:
          const EdgeInsets.only(top: 15),
      children: [
        permission(
          Icons.mic_none,
          'MICROPHONE',
          'Voice interaction with Yansi',
          mic,
          (v) => setState(() => mic = v),
        ),
        permission(
          Icons.notifications_none,
          'NOTIFICATIONS',
          'Permitted notification intelligence',
          notifications,
          (v) =>
              setState(() => notifications = v),
        ),
        permission(
          Icons.calendar_today_outlined,
          'CALENDAR',
          'Bills and important dates',
          calendar,
          (v) =>
              setState(() => calendar = v),
        ),
        permission(
          Icons.camera_alt_outlined,
          'CAMERA',
          'Receipt scanning',
          camera,
          (v) =>
              setState(() => camera = v),
        ),
      ],
    );
  }

  Widget setting(
    IconData icon,
    String title,
    String value,
    VoidCallback action,
  ) {
    return ListTile(
      onTap: action,
      leading: Icon(
        icon,
        color: const Color(0xFF55FF88),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 9,
          letterSpacing: 1,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 12,
        ),
      ),
      trailing:
          const Icon(Icons.chevron_right),
    );
  }

  Widget permission(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> changed,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: const Color(0xCC07131D),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: changed,
        secondary: Icon(
          icon,
          color:
              const Color(0xFF55FF88),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 1,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 8,
            color: Colors.white38,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LIFEOS HOME
// ============================================================

class LifeOSHome extends StatefulWidget {
  final SharedPreferences prefs;

  const LifeOSHome({
    super.key,
    required this.prefs,
  });

  @override
  State<LifeOSHome> createState() =>
      _LifeOSHomeState();
}

class _LifeOSHomeState extends State<LifeOSHome> {
  final tts = FlutterTts();
  final speech = SpeechToText();

  String yansiText =
      'Yansi is here whenever you need me.';

  bool listening = false;
  bool menu = false;

  String get userName =>
      widget.prefs.getString('name') ?? 'User';

  String get currency =>
      widget.prefs.getString('currency') ?? 'INR ₹';

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(milliseconds: 800),
      welcome,
    );
  }

  Future<void> welcome() async {
    final text =
        'Welcome, $userName. I’m Yansi, your personal LifeOS AI agent. I’m here whenever you need me.';

    setState(() => yansiText = text);

    await tts.setLanguage('en-IN');
    await tts.setSpeechRate(.47);
    await tts.speak(text);
  }

  Future<void> listen() async {
    if (listening) return;

    final available =
        await speech.initialize();

    if (!available) {
      setState(() {
        yansiText =
            'Microphone permission is required.';
      });
      return;
    }

    setState(() {
      listening = true;
      yansiText =
          'Yansi is listening...';
    });

    String words = '';

    await speech.listen(
      onResult: (result) {
        words = result.recognizedWords;
      },
    );

    await Future.delayed(
      const Duration(seconds: 5),
    );

    await speech.stop();

    setState(() => listening = false);

    if (words.isNotEmpty) {
      await process(words);
    }
  }

  Future<void> process(
    String text,
  ) async {
    final lower = text.toLowerCase();

    String type = 'other';
    String category = 'Other';
    double amount = 0;

    final match =
        RegExp(r'(\d+(?:\.\d+)?)')
            .firstMatch(lower);

    if (match != null) {
      amount =
          double.tryParse(
                match.group(1)!,
              ) ??
              0;
    }

    if (has(
      lower,
      ['petrol', 'fuel', 'diesel'],
    )) {
      type = 'expense';
      category = 'Fuel';
    } else if (has(
      lower,
      ['food', 'lunch', 'dinner', 'restaurant'],
    )) {
      type = 'expense';
      category = 'Food';
    } else if (has(
      lower,
      ['medicine', 'doctor', 'hospital'],
    )) {
      type = 'expense';
      category = 'Medical';
    } else if (has(
      lower,
      ['task', 'todo', 'to do', 'finish', 'need to'],
    )) {
      type = 'productivity';
    } else if (has(
      lower,
      ['goal', 'target', 'achieve'],
    )) {
      type = 'goal';
    } else if (has(
      lower,
      ['grocery', 'shopping', 'milk', 'vegetables'],
    )) {
      type = 'household';
    } else if (has(
      lower,
      [
        'remind',
        'appointment',
        'birthday',
        'anniversary',
        'tomorrow',
        'due'
      ],
    )) {
      type = 'calendar';
    }

    final data =
        widget.prefs.getString(
      'lifeos_entries',
    );

    List list = [];

    if (data != null) {
      try {
        list = jsonDecode(data);
      } catch (_) {}
    }

    list.insert(
      0,
      {
        'type': type,
        'category': category,
        'text': text,
        'amount': amount,
        'date':
            DateTime.now()
                .toIso8601String(),
      },
    );

    await widget.prefs.setString(
      'lifeos_entries',
      jsonEncode(list),
    );

    String response;

    if (type == 'expense' && amount > 0) {
      response =
          'Got it. I added ${currency}${amount.toStringAsFixed(0)} to $category for today.';
    } else if (type == 'productivity') {
      response =
          'Done. I added that to your productivity.';
    } else if (type == 'goal') {
      response =
          'Done. I added that to your goals.';
    } else if (type == 'household') {
      response =
          'Done. I added that to your household list.';
    } else if (type == 'calendar') {
      response =
          'Done. I added that to your calendar intelligence.';
    } else {
      response =
          'I heard you. I’ll keep that in your LifeOS data.';
    }

    setState(() => yansiText = response);

    await tts.speak(response);
  }

  bool has(
    String text,
    List<String> words,
  ) =>
      words.any(text.contains);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const FutureBackground(),

          SafeArea(
            child: Column(
              children: [
                header(),

                Expanded(
                  child: LayoutBuilder(
                    builder:
                        (context, box) {
                      return Stack(
                        children: [
                          Positioned(
                            top: 18,
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
                                Text(
                                  userName
                                      .toUpperCase(),
                                  style:
                                      const TextStyle(
                                    fontSize: 8,
                                    letterSpacing:
                                        3,
                                    color:
                                        Colors.white38,
                                  ),
                                ),
                                const SizedBox(
                                    height: 5),
                                const Text(
                                  'LIFE INTELLIGENCE',
                                  style:
                                      TextStyle(
                                    fontSize: 16,
                                    letterSpacing:
                                        2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Positioned(
                            top: box.maxHeight * .22,
                            left: box.maxWidth / 2 - 90,
                            child: GestureDetector(
                              onTap: listen,
                              child:
                                  const YansiOrb(
                                size: 180,
                              ),
                            ),
                          ),

                          core(
                            7,
                            box.maxHeight * .20,
                            Icons
                                .account_balance_wallet_outlined,
                            'MONEY',
                            'expense',
                          ),

                          core(
                            null,
                            box.maxHeight * .20,
                            Icons.flag_outlined,
                            'GOALS',
                            'goal',
                            right: 7,
                          ),

                          core(
                            7,
                            box.maxHeight * .56,
                            Icons.bolt_outlined,
                            'PRODUCTIVITY',
                            'productivity',
                          ),

                          core(
                            null,
                            box.maxHeight * .56,
                            Icons.shopping_bag_outlined,
                            'HOUSEHOLD',
                            'household',
                            right: 7,
                          ),

                          Positioned(
                            bottom: 20,
                            left: box.maxWidth / 2 - 54,
                            child: coreButton(
                              Icons.calendar_today_outlined,
                              'CALENDAR',
                              'calendar',
                            ),
                          ),

                          Positioned(
                            bottom: 77,
                            left: 18,
                            right: 18,
                            child: Container(
                              padding:
                                  const EdgeInsets.all(11),
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(0xDD07131D),
                                borderRadius:
                                    BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      const Color(0x3300E5FF),
                                ),
                              ),
                              child: Text(
                                yansiText,
                                textAlign:
                                    TextAlign.center,
                                maxLines: 3,
                                overflow:
                                    TextOverflow.ellipsis,
                                style:
                                    const TextStyle(
                                  fontSize: 9,
                                  height: 1.4,
                                  color:
                                      Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          if (menu) controlMenu(),

          if (listening)
            Positioned(
              bottom: 15,
              left: 25,
              right: 25,
              child: Container(
                padding:
                    const EdgeInsets.all(12),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xFF07131D),
                  borderRadius:
                      BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        const Color(0xFF55FF88),
                  ),
                ),
                child: const Text(
                  'YANSI • LISTENING',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color:
                        Color(0xFF55FF88),
                    fontSize: 9,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget header() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Row(
        children: [
          smallIcon(
            Icons.menu_rounded,
            () => setState(
              () => menu = !menu,
            ),
          ),
          const Spacer(),
          const Text(
            'L I F E O S',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 5,
            ),
          ),
          const Spacer(),
          smallIcon(
            Icons.notifications_none,
            () {},
          ),
        ],
      ),
    );
  }

  Widget smallIcon(
    IconData icon,
    VoidCallback action,
  ) {
    return GestureDetector(
      onTap: action,
      child: Container(
        width: 30,
        height: 27,
        decoration: BoxDecoration(
          color:
              const Color(0xDD07131D),
          borderRadius:
              BorderRadius.circular(7),
          border: Border.all(
            color:
                const Color(0x3300E5FF),
          ),
        ),
        child: Icon(
          icon,
          size: 15,
          color:
              const Color(0xFF55FF88),
        ),
      ),
    );
  }

  Widget core(
    double? left,
    double top,
    IconData icon,
    String title,
    String type, {
    double? right,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child:
          coreButton(icon, title, type),
    );
  }

  Widget coreButton(
    IconData icon,
    String title,
    String type,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CoreScreen(
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
          horizontal: 7,
          vertical: 10,
        ),
        decoration:
            BoxDecoration(
          color:
              const Color(0xDD07131D),
          borderRadius:
              BorderRadius.circular(9),
          border: Border.all(
            color:
                const Color(0x3300E5FF),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 15,
              color:
                  const Color(0xFF55FF88),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 7,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget controlMenu() {
    return Positioned(
      top: 40,
      left: 7,
      child: Container(
        width: 235,
        padding:
            const EdgeInsets.all(15),
        decoration:
            BoxDecoration(
          color:
              const Color(0xFF07131D),
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color:
                const Color(0x5500E5FF),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
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
            const SizedBox(height: 12),
            menuItem(
              Icons.insights_outlined,
              'LIFE REPORT',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LifeReport(
                      prefs: widget.prefs,
                    ),
                  ),
                );
              },
            ),
            menuItem(
              Icons.person_outline,
              'PROFILE',
              () {},
            ),
            menuItem(
              Icons.security,
              'PRIVACY',
              () {},
            ),
            menuItem(
              Icons.settings_outlined,
              'SETTINGS',
              () {},
            ),
            menuItem(
              Icons.logout,
              'LOG OUT',
              () {
                widget.prefs
                    .setBool(
                  'logged_in',
                  false,
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LoginScreen(
                      prefs:
                          widget.prefs,
                      onLogin: () {},
                    ),
                  ),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget menuItem(
    IconData icon,
    String title,
    VoidCallback action,
  ) {
    return GestureDetector(
      onTap: action,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 9,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color:
                  const Color(0xFF55FF88),
            ),
            const SizedBox(width: 12),
            Text(
              title,
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
}

// ============================================================
// CORE SCREEN
// ============================================================

class CoreScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final raw =
        prefs.getString(
      'lifeos_entries',
    );

    List items = [];

    if (raw != null) {
      try {
        items = jsonDecode(raw);
      } catch (_) {}
    }

    final filtered = items
        .where(
          (e) => e['type'] == type,
        )
        .toList();

    double total = 0;

    for (final e in filtered) {
      if (e['amount'] is num) {
        total +=
            (e['amount'] as num)
                .toDouble();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Stack(
        children: [
          const FutureBackground(),

          ListView(
            padding:
                const EdgeInsets.all(18),
            children: [
              Container(
                padding:
                    const EdgeInsets.all(15),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xDD07131D),
                  borderRadius:
                      BorderRadius.circular(12),
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
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Yansi is analyzing this area of your life.',
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              Colors.white60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              if (type == 'expense')
                Container(
                  padding:
                      const EdgeInsets.all(18),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(0xDD07131D),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Text(
                    'TOTAL  ₹${total.toStringAsFixed(0)}',
                    style:
                        const TextStyle(
                      color:
                          Color(0xFF55FF88),
                      fontSize: 18,
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              if (filtered.isEmpty)
                const Padding(
                  padding:
                      EdgeInsets.all(30),
                  child: Text(
                    'No data yet.\n\nSpeak naturally to Yansi and the information will appear here.',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color:
                          Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ),

              ...filtered.map(
                (item) => Container(
                  margin:
                      const EdgeInsets.only(
                    bottom: 8,
                  ),
                  padding:
                      const EdgeInsets.all(14),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(0xCC07131D),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Text(
                    item['text']
                            ?.toString() ??
                        item['category']
                            ?.toString() ??
                        '',
                    style:
                        const TextStyle(
                      fontSize: 10,
                    ),
                  ),
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
// LIFE REPORT
// ============================================================

class LifeReport extends StatelessWidget {
  final SharedPreferences prefs;

  const LifeReport({
    super.key,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    final raw =
        prefs.getString(
      'lifeos_entries',
    );

    List items = [];

    if (raw != null) {
      try {
        items = jsonDecode(raw);
      } catch (_) {}
    }

    double expenses = 0;
    int goals = 0;
    int tasks = 0;
    int household = 0;
    int calendar = 0;

    for (final e in items) {
      if (e['type'] == 'expense' &&
          e['amount'] is num) {
        expenses +=
            (e['amount'] as num)
                .toDouble();
      }

      if (e['type'] == 'goal') goals++;
      if (e['type'] == 'productivity') tasks++;
      if (e['type'] == 'household') household++;
      if (e['type'] == 'calendar') calendar++;
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
                const EdgeInsets.all(18),
            children: [
              const Center(
                child: YansiOrb(size: 110),
              ),
              const SizedBox(height: 15),
              const Center(
                child: Text(
                  'LIFEOS SNAPSHOT',
                  style: TextStyle(
                    color:
                        Color(0xFF00E5FF),
                    letterSpacing: 3,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              report(
                'MONEY',
                '₹${expenses.toStringAsFixed(0)}',
                Icons
                    .account_balance_wallet_outlined,
              ),
              report(
                'GOALS',
                '$goals',
                Icons.flag_outlined,
              ),
              report(
                'PRODUCTIVITY',
                '$tasks',
                Icons.bolt_outlined,
              ),
              report(
                'HOUSEHOLD',
                '$household',
                Icons.shopping_bag_outlined,
              ),
              report(
                'CALENDAR',
                '$calendar',
                Icons.calendar_today_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget report(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 9,
      ),
      padding:
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
        color:
            const Color(0xCC07131D),
        borderRadius:
            BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                const Color(0xFF55FF88),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(
                fontSize: 9,
                color:
                    Colors.white38,
                letterSpacing: 1,
              ),
            ),
          ),
          Text(
            value,
            style:
                const TextStyle(
              fontSize: 15,
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

class FutureBackground extends StatelessWidget {
  const FutureBackground({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: FuturePainter(),
    );
  }
}

class FuturePainter extends CustomPainter {
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

    final grid = Paint()
      ..color =
          const Color(0x1000E5FF)
      ..strokeWidth = .5;

    for (
      double x = 0;
      x < size.width;
      x += 30
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
      y += 30
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        grid,
      );
    }

    final glow = Paint()
      ..shader =
          const RadialGradient(
        colors: [
          Color(0x2500E5FF),
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

class YansiOrb extends StatelessWidget {
  final double size;

  const YansiOrb({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: YansiPainter(),
        child: Center(
          child: Icon(
            Icons.auto_awesome,
            size: size * .23,
            color:
                const Color(0xFF55FF88),
          ),
        ),
      ),
    );
  }
}

class YansiPainter extends CustomPainter {
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

    final paint = Paint()
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 9; i++) {
      paint.color = i.isEven
          ? const Color(0x6600E5FF)
          : const Color(0x4455FF88);

      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width:
              radius *
              (1 + i * .12),
          height:
              radius *
              (.5 + i * .08),
        ),
        paint,
      );
    }

    final nodes = Paint()
      ..color =
          const Color(0xAA00E5FF);

    for (int i = 0; i < 24; i++) {
      final angle =
          i * math.pi * 2 / 24;

      final point =
          center +
          Offset(
            radius *
                .82 *
                math.cos(angle),
            radius *
                .55 *
                math.sin(angle),
          );

      canvas.drawCircle(
        point,
        1.6,
        nodes,
      );

      paint.color =
          const Color(0x2200E5FF);

      canvas.drawLine(
        center,
        point,
        paint,
      );
    }

    final core = Paint()
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
              radius * .7,
        ),
      );

    canvas.drawCircle(
      center,
      radius * .65,
      core,
    );
  }

  @override
  bool shouldRepaint(
    CustomPainter oldDelegate,
  ) =>
      false;
}
