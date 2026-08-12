import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(LifeOS(prefs: prefs));
}

// ============================================================
// LIFEOS APP
// ============================================================

class LifeOS extends StatelessWidget {
  final SharedPreferences prefs;

  const LifeOS({
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
            const Color(0xFF01060A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: RouterScreen(prefs: prefs),
    );
  }
}

// ============================================================
// ROUTER
// ============================================================

class RouterScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const RouterScreen({
    super.key,
    required this.prefs,
  });

  @override
  State<RouterScreen> createState() =>
      _RouterScreenState();
}

class _RouterScreenState
    extends State<RouterScreen> {
  @override
  Widget build(BuildContext context) {
    if (!(widget.prefs.getBool('logged_in') ??
        false)) {
      return LoginScreen(
        prefs: widget.prefs,
        refresh: () => setState(() {}),
      );
    }

    if (!(widget.prefs
            .getBool('onboarding_complete') ??
        false)) {
      return OnboardingScreen(
        prefs: widget.prefs,
        refresh: () => setState(() {}),
      );
    }

    return HomeScreen(
      prefs: widget.prefs,
    );
  }
}

// ============================================================
// FUTURISTIC BACKGROUND
// ============================================================

class FutureBackground
    extends StatelessWidget {
  const FutureBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BackgroundPainter(),
      size: Size.infinite,
    );
  }
}

class BackgroundPainter
    extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color =
            const Color(0xFF01060A),
    );

    final grid = Paint()
      ..color =
          const Color(0x1200E5FF)
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

    final glow = Paint()
      ..shader =
          const RadialGradient(
        colors: [
          Color(0x2800E5FF),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width / 2,
            size.height / 2,
          ),
          radius: size.width * .7,
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
    return CustomPaint(
      size: Size(size, size),
      painter: YansiPainter(),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Icon(
            Icons.auto_awesome,
            color:
                const Color(0xFF55FF88),
            size: size * .22,
          ),
        ),
      ),
    );
  }
}

class YansiPainter
    extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2;

    final ring = Paint()
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 9; i++) {
      ring.color = i.isEven
          ? const Color(0x5500E5FF)
          : const Color(0x4455FF88);

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

    final node = Paint()
      ..color =
          const Color(0xFF55FF88);

    for (int i = 0; i < 24; i++) {
      final a =
          i * math.pi * 2 / 24;

      final p = center +
          Offset(
            radius *
                .82 *
                math.cos(a),
            radius *
                .55 *
                math.sin(a),
          );

      canvas.drawCircle(
        p,
        1.5,
        node,
      );

      ring.color =
          const Color(0x2200E5FF);

      canvas.drawLine(
        center,
        p,
        ring,
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
          radius: radius * .7,
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

// ============================================================
// LOGIN
// ============================================================

class LoginScreen
    extends StatefulWidget {
  final SharedPreferences prefs;
  final VoidCallback refresh;

  const LoginScreen({
    super.key,
    required this.prefs,
    required this.refresh,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final identifier =
      TextEditingController();

  final password =
      TextEditingController();

  final otp =
      TextEditingController();

  bool phone = false;
  bool useOtp = false;
  bool hidePassword = true;

  void login() {
    if (identifier.text.trim().isEmpty) {
      message(
        'Enter your email or mobile number.',
      );
      return;
    }

    if (useOtp) {
      if (otp.text.length < 4) {
        message('Enter the OTP.');
        return;
      }
    } else {
      if (password.text.isEmpty) {
        message('Enter your password.');
        return;
      }
    }

    widget.prefs.setBool(
      'logged_in',
      true,
    );

    widget.refresh();
  }

  void message(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(text),
      ),
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
                padding:
                    const EdgeInsets.all(25),
                child: Column(
                  children: [
                    const YansiOrb(
                      size: 175,
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    const Text(
                      'L I F E O S',
                      style: TextStyle(
                        fontSize: 21,
                        letterSpacing: 8,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'YOUR LIFE • YOUR INTELLIGENCE',
                      style: TextStyle(
                        color:
                            Color(0xFF55FF88),
                        fontSize: 8,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(
                      height: 32,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: loginMode(
                            'EMAIL',
                            !phone,
                            () {
                              setState(
                                () => phone =
                                    false,
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: loginMode(
                            'PHONE',
                            phone,
                            () {
                              setState(
                                () => phone =
                                    true,
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    TextField(
                      controller:
                          identifier,
                      keyboardType: phone
                          ? TextInputType.phone
                          : TextInputType
                              .emailAddress,
                      decoration:
                          InputDecoration(
                        hintText: phone
                            ? 'Mobile number'
                            : 'Email address',
                        prefixIcon: Icon(
                          phone
                              ? Icons
                                  .phone_outlined
                              : Icons
                                  .alternate_email,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    if (!useOtp)
                      TextField(
                        controller:
                            password,
                        obscureText:
                            hidePassword,
                        decoration:
                            InputDecoration(
                          hintText:
                              'Password',
                          prefixIcon:
                              const Icon(
                            Icons
                                .lock_outline,
                          ),
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setState(
                                () =>
                                    hidePassword =
                                        !hidePassword,
                              );
                            },
                            icon: Icon(
                              hidePassword
                                  ? Icons
                                      .visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),

                    if (useOtp)
                      TextField(
                        controller: otp,
                        keyboardType:
                            TextInputType.number,
                        decoration:
                            const InputDecoration(
                          hintText: 'OTP',
                          prefixIcon:
                              Icon(
                            Icons
                                .password_outlined,
                          ),
                        ),
                      ),

                    TextButton(
                      onPressed: () {
                        setState(
                          () => useOtp =
                              !useOtp,
                        );
                      },
                      child: Text(
                        useOtp
                            ? 'USE PASSWORD'
                            : 'LOGIN WITH OTP',
                        style:
                            const TextStyle(
                          color:
                              Color(0xFF00E5FF),
                          fontSize: 9,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: login,
                        child: Text(
                          useOtp
                              ? 'VERIFY OTP'
                              : 'ENTER LIFEOS',
                          style:
                              const TextStyle(
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    TextButton(
                      onPressed: () {
                        message(
                          'Secure password recovery will be connected to the authentication service.',
                        );
                      },
                      child:
                          const Text(
                        'FORGOT PASSWORD?',
                        style:
                            TextStyle(
                          fontSize: 8,
                          color:
                              Colors.white38,
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

  Widget loginMode(
    String text,
    bool active,
    VoidCallback action,
  ) {
    return GestureDetector(
      onTap: action,
      child: Container(
        height: 42,
        alignment:
            Alignment.center,
        decoration:
            BoxDecoration(
          color: active
              ? const Color(
                  0x2200E5FF,
                )
              : const Color(
                  0xAA07131D,
                ),
          borderRadius:
              BorderRadius.circular(8),
          border: Border.all(
            color: active
                ? const Color(
                    0x9900E5FF,
                  )
                : const Color(
                    0x2200E5FF,
                  ),
          ),
        ),
        child: Text(
          text,
          style:
              const TextStyle(
            fontSize: 8,
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

class OnboardingScreen
    extends StatefulWidget {
  final SharedPreferences prefs;
  final VoidCallback refresh;

  const OnboardingScreen({
    super.key,
    required this.prefs,
    required this.refresh,
  });

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  final name =
      TextEditingController();

  int step = 0;

  String country = 'India';
  String currency = 'INR ₹';
  String language = 'English';
  String theme = 'Futuristic';

  bool microphone = false;
  bool notification = false;
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

  String currencyFor(
    String value,
  ) {
    switch (value) {
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
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Enter your name.'),
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

    await widget.prefs.setString(
      'theme',
      theme,
    );

    await widget.prefs.setBool(
      'permission_microphone',
      microphone,
    );

    await widget.prefs.setBool(
      'permission_notification',
      notification,
    );

    await widget.prefs.setBool(
      'permission_calendar',
      calendar,
    );

    await widget.prefs.setBool(
      'permission_camera',
      camera,
    );

    await widget.prefs.setBool(
      'onboarding_complete',
      true,
    );

    widget.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const FutureBackground(),

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.all(22),
              child: Column(
                children: [
                  const YansiOrb(
                    size: 110,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    step == 0
                        ? 'YOUR IDENTITY'
                        : step == 1
                            ? 'YOUR WORLD'
                            : step == 2
                                ? 'YOUR STYLE'
                                : 'YANSI ACCESS',
                    style:
                        const TextStyle(
                      fontSize: 17,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Expanded(
                    child:
                        onboardingPage(),
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 50,
                    child:
                        ElevatedButton(
                      onPressed: () {
                        if (step < 3) {
                          setState(
                            () => step++,
                          );
                        } else {
                          finish();
                        }
                      },
                      child: Text(
                        step == 3
                            ? 'ENTER LIFEOS'
                            : 'CONTINUE',
                        style:
                            const TextStyle(
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

  Widget onboardingPage() {
    if (step == 0) {
      return Center(
        child: TextField(
          controller: name,
          decoration:
              const InputDecoration(
            hintText:
                'What should Yansi call you?',
            prefixIcon:
                Icon(
              Icons.person_outline,
            ),
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
            DropdownButtonFormField<
                String>(
              value: country,
              decoration:
                  const InputDecoration(
                labelText: 'COUNTRY',
                prefixIcon:
                    Icon(
                  Icons.public,
                ),
              ),
              items:
                  countries.map(
                (item) {
                  return DropdownMenuItem(
                    value: item,
                    child:
                        Text(item),
                  );
                },
              ).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    country =
                        value;
                    currency =
                        currencyFor(
                            value);
                  });
                }
              },
            ),

            const SizedBox(
              height: 18,
            ),

            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                17,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xCC07131D,
                ),
                borderRadius:
                    BorderRadius.circular(
                  11,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons
                        .account_balance_wallet_outlined,
                    color:
                        Color(0xFF55FF88),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    'Currency: $currency',
                    style:
                        const TextStyle(
                      fontSize: 12,
                    ),
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
            const EdgeInsets.only(
          top: 20,
        ),
        children: [
          choice(
            Icons.palette_outlined,
            'DESIGN',
            theme,
            () {
              setState(() {
                theme =
                    theme == 'Futuristic'
                        ? 'Midnight'
                        : 'Futuristic';
              });
            },
          ),
          choice(
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
          choice(
            Icons.auto_awesome,
            'YANSI',
            'Ambient Ghost AI',
            () {},
          ),
        ],
      );
    }

    return ListView(
      padding:
          const EdgeInsets.only(
        top: 12,
      ),
      children: [
        permission(
          Icons.mic_none,
          'MICROPHONE',
          'Voice interaction with Yansi',
          microphone,
          (v) => setState(
            () => microphone = v,
          ),
        ),
        permission(
          Icons.notifications_none,
          'NOTIFICATIONS',
          'Read permitted useful notifications',
          notification,
          (v) => setState(
            () => notification = v,
          ),
        ),
        permission(
          Icons.calendar_today_outlined,
          'CALENDAR',
          'Bills, renewals and important dates',
          calendar,
          (v) => setState(
            () => calendar = v,
          ),
        ),
        permission(
          Icons.camera_alt_outlined,
          'CAMERA',
          'Receipt and bill scanning',
          camera,
          (v) => setState(
            () => camera = v,
          ),
        ),
      ],
    );
  }

  Widget choice(
    IconData icon,
    String title,
    String value,
    VoidCallback action,
  ) {
    return GestureDetector(
      onTap: action,
      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 10,
        ),
        padding:
            const EdgeInsets.all(15),
        decoration:
            BoxDecoration(
          color:
              const Color(0xCC07131D),
          borderRadius:
              BorderRadius.circular(10),
          border: Border.all(
            color:
                const Color(0x2200E5FF),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  const Color(0xFF55FF88),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 8,
                      color:
                          Colors.white38,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    value,
                    style:
                        const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget permission(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> change,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 9,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xCC07131D),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child:
          SwitchListTile(
        value: value,
        onChanged: change,
        secondary: Icon(
          icon,
          color:
              const Color(0xFF55FF88),
        ),
        title: Text(
          title,
          style:
              const TextStyle(
            fontSize: 9,
            letterSpacing: 1,
          ),
        ),
        subtitle: Text(
          subtitle,
          style:
              const TextStyle(
            fontSize: 8,
            color:
                Colors.white38,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HOME
// ============================================================

class HomeScreen
    extends StatefulWidget {
  final SharedPreferences prefs;

  const HomeScreen({
    super.key,
    required this.prefs,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen>
    with
        SingleTickerProviderStateMixin {
  late AnimationController
      animation;

  final tts = FlutterTts();
  final speech =
      SpeechToText();

  bool listening = false;
  bool menuOpen = false;

  String yansiMessage =
      'Yansi is here whenever you need me.';

  String get name =>
      widget.prefs.getString(
        'name',
      ) ??
      'User';

  String get currency =>
      widget.prefs.getString(
        'currency',
      ) ??
      'INR ₹';

  @override
  void initState() {
    super.initState();

    animation = AnimationController(
      vsync: this,
      duration:
          const Duration(
        seconds: 10,
      ),
    )..repeat();

    Future.delayed(
      const Duration(
        milliseconds: 900,
      ),
      welcome,
    );
  }

  @override
  void dispose() {
    animation.dispose();
    tts.stop();
    speech.stop();
    super.dispose();
  }

  Future<void> welcome() async {
    final message =
        'Welcome, $name. I’m Yansi, your personal LifeOS AI agent. I’m here whenever you need me.';

    setState(() {
      yansiMessage = message;
    });

    await tts.setLanguage(
      'en-IN',
    );

    await tts.setSpeechRate(
      .45,
    );

    await tts.speak(
      message,
    );
  }

  Future<void> listen() async {
    if (listening) return;

    final available =
        await speech.initialize();

    if (!available) {
      setState(() {
        yansiMessage =
            'Microphone permission is required before Yansi can listen.';
      });
      return;
    }

    setState(() {
      listening = true;
      yansiMessage =
          'Yansi is listening...';
    });

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

    if (words.trim().isNotEmpty) {
      await understand(words);
    }
  }

  Future<void> understand(
    String text,
  ) async {
    final lower =
        text.toLowerCase();

    final number =
        RegExp(
      r'(\d+(?:\.\d+)?)',
    ).firstMatch(lower);

    double amount = 0;

    if (number != null) {
      amount =
          double.tryParse(
                number.group(1)!,
              ) ??
              0;
    }

    String type = 'note';
    String category = 'Other';

    if (contains(
      lower,
      [
        'petrol',
        'fuel',
        'diesel',
      ],
    )) {
      type = 'expense';
      category = 'Fuel';
    } else if (contains(
      lower,
      [
        'food',
        'lunch',
        'dinner',
        'restaurant',
      ],
    )) {
      type = 'expense';
      category = 'Food';
    } else if (contains(
      lower,
      [
        'medicine',
        'doctor',
        'hospital',
      ],
    )) {
      type = 'expense';
      category = 'Medical';
    } else if (contains(
      lower,
      [
        'grocery',
        'milk',
        'vegetable',
        'shopping',
      ],
    )) {
      type = 'household';
      category =
          'Household';
    } else if (contains(
      lower,
      [
        'goal',
        'target',
        'achieve',
      ],
    )) {
      type = 'goal';
      category = 'Goal';
    } else if (contains(
      lower,
      [
        'task',
        'todo',
        'to do',
        'finish',
        'complete',
      ],
    )) {
      type = 'productivity';
      category =
          'Task';
    } else if (contains(
      lower,
      [
        'remind',
        'birthday',
        'anniversary',
        'appointment',
        'bill',
        'tomorrow',
        'due',
      ],
    )) {
      type = 'calendar';
      category =
          'Calendar';
    }

    await saveEntry(
      type,
      category,
      text,
      amount,
    );

    String response;

    if (type == 'expense' &&
        amount > 0) {
      response =
          'Got it. I added $currency${amount.toStringAsFixed(0)} to $category for today.';
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
          'Done. I added that to your calendar.';
    } else {
      response =
          'I heard you and saved that in LifeOS.';
    }

    setState(() {
      yansiMessage = response;
    });

    await tts.speak(
      response,
    );
  }

  bool contains(
    String text,
    List<String> words,
  ) {
    return words.any(
      text.contains,
    );
  }

  Future<void> saveEntry(
    String type,
    String category,
    String text,
    double amount,
  ) async {
    final raw =
        widget.prefs.getString(
      'lifeos_entries',
    );

    List entries = [];

    if (raw != null) {
      try {
        entries =
            jsonDecode(raw);
      } catch (_) {}
    }

    entries.insert(
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
      jsonEncode(entries),
    );
  }

  void openCore(
    String title,
    String type,
    IconData icon,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CoreScreen(
          prefs:
              widget.prefs,
          title: title,
          type: type,
          icon: icon,
        ),
      ),
    );
  }

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
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 14,
                            ),

                            Text(
                              name
                                  .toUpperCase(),
                              style:
                                  const TextStyle(
                                fontSize: 8,
                                color:
                                    Colors.white38,
                                letterSpacing:
                                    3,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            const Text(
                              'LIFE INTELLIGENCE',
                              style:
                                  TextStyle(
                                fontSize: 15,
                                letterSpacing:
                                    2,
                              ),
                            ),

                            Expanded(
                              child:
                                  LayoutBuilder(
                                builder:
                                    (
                                  context,
                                  box,
                                ) {
                                  return Stack(
                                    alignment:
                                        Alignment.center,
                                    children: [
                                      AnimatedBuilder(
                                        animation:
                                            animation,
                                        builder:
                                            (
                                          context,
                                          child,
                                        ) {
                                          return Transform.rotate(
                                            angle:
                                                animation.value *
                                                    math.pi *
                                                    2,
                                            child:
                                                CustomPaint(
                                              size:
                                                  const Size(
                                                310,
                                                310,
                                              ),
                                              painter:
                                                  NeuralPainter(),
                                            ),
                                          );
                                        },
                                      ),

                                      GestureDetector(
                                        onTap:
                                            listen,
                                        child:
                                            const YansiOrb(
                                          size:
                                              145,
                                        ),
                                      ),

                                      node(
                                        alignment:
                                            const Alignment(
                                          0,
                                          -.78,
                                        ),
                                        icon:
                                            Icons.account_balance_wallet_outlined,
                                        action:
                                            () => openCore(
                                          'EXPENSE',
                                          'expense',
                                          Icons.account_balance_wallet_outlined,
                                        ),
                                      ),

                                      node(
                                        alignment:
                                            const Alignment(
                                          .82,
                                          -.20,
                                        ),
                                        icon:
                                            Icons.flag_outlined,
                                        action:
                                            () => openCore(
                                          'GOALS',
                                          'goal',
                                          Icons.flag_outlined,
                                        ),
                                      ),

                                      node(
                                        alignment:
                                            const Alignment(
                                          .56,
                                          .67,
                                        ),
                                        icon:
                                            Icons.bolt_outlined,
                                        action:
                                            () => openCore(
                                          'PRODUCTIVITY',
                                          'productivity',
                                          Icons.bolt_outlined,
                                        ),
                                      ),

                                      node(
                                        alignment:
                                            const Alignment(
                                          -.56,
                                          .67,
                                        ),
                                        icon:
                                            Icons.shopping_bag_outlined,
                                        action:
                                            () => openCore(
                                          'HOUSEHOLD',
                                          'household',
                                          Icons.shopping_bag_outlined,
                                        ),
                                      ),

                                      node(
                                        alignment:
                                            const Alignment(
                                          -.82,
                                          -.20,
                                        ),
                                        icon:
                                            Icons.calendar_today_outlined,
                                        action:
                                            () => openCore(
                                          'CALENDAR',
                                          'calendar',
                                          Icons.calendar_today_outlined,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            Container(
                              margin:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    18,
                              ),
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    13,
                                vertical:
                                    11,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xCC07131D,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  10,
                                ),
                                border:
                                    Border.all(
                                  color:
                                      const Color(
                                    0x3300E5FF,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons
                                        .auto_awesome,
                                    size: 14,
                                    color:
                                        Color(
                                      0xFF55FF88,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 9,
                                  ),
                                  Expanded(
                                    child:
                                        Text(
                                      yansiMessage,
                                      maxLines:
                                          2,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                      style:
                                          const TextStyle(
                                        fontSize:
                                            8,
                                        color:
                                            Colors.white60,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.circle,
                                    size: 5,
                                    color:
                                        Color(
                                      0xFF55FF88,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (menuOpen)
            controlCenter(),
        ],
      ),
    );
  }

  Widget header() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      child: Row(
        children: [
          topButton(
            Icons.menu_rounded,
            () {
              setState(
                () => menuOpen =
                    !menuOpen,
              );
            },
          ),
          const Spacer(),
          const Text(
            'L I F E O S',
            style:
                TextStyle(
              fontSize: 12,
              letterSpacing: 5,
            ),
          ),
          const Spacer(),
          topButton(
            Icons.notifications_none_rounded,
            () {},
          ),
        ],
      ),
    );
  }

  Widget topButton(
    IconData icon,
    VoidCallback action,
  ) {
    return GestureDetector(
      onTap: action,
      child: Container(
        width: 30,
        height: 27,
        decoration:
            BoxDecoration(
          color:
              const Color(0xDD061219),
          borderRadius:
              BorderRadius.circular(7),
          border:
              Border.all(
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

  Widget node({
    required Alignment alignment,
    required IconData icon,
    required VoidCallback action,
  }) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: action,
        child: Container(
          width: 55,
          height: 55,
          decoration:
              BoxDecoration(
            shape: BoxShape.circle,
            color:
                const Color(0xDD07151C),
            border:
                Border.all(
              color:
                  const Color(0x7700E5FF),
            ),
            boxShadow: const [
              BoxShadow(
                color:
                    Color(0x3300E5FF),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 21,
            color:
                const Color(0xFF55FF88),
          ),
        ),
      ),
    );
  }

  Widget controlCenter() {
    return Positioned(
      top: 45,
      left: 7,
      child: Container(
        width: 225,
        padding:
            const EdgeInsets.all(
          15,
        ),
        decoration:
            BoxDecoration(
          color:
              const Color(0xFF061219),
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          border:
              Border.all(
            color:
                const Color(0x6600E5FF),
          ),
          boxShadow:
              const [
            BoxShadow(
              color:
                  Color(0x5500E5FF),
              blurRadius: 25,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'CONTROL CENTER',
              style:
                  TextStyle(
                color:
                    Color(0xFF00E5FF),
                fontSize: 9,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            menuItem(
              Icons.auto_awesome,
              'YANSI',
            ),

            menuItem(
              Icons.insights_outlined,
              'LIFE REPORT',
            ),

            menuItem(
              Icons.person_outline,
              'PROFILE',
            ),

            menuItem(
              Icons.security_outlined,
              'PRIVACY',
            ),

            menuItem(
              Icons.settings_outlined,
              'SETTINGS',
            ),

            menuItem(
              Icons.logout,
              'LOG OUT',
              logout: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget menuItem(
    IconData icon,
    String text, {
    bool logout = false,
  }) {
    return GestureDetector(
      onTap: logout
          ? () {
              widget.prefs
                  .setBool(
                'logged_in',
                false,
              );

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      LifeOS(
                    prefs:
                        widget.prefs,
                  ),
                ),
                (_) => false,
              );
            }
          : null,
