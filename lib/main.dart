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
// LIFEOS
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
          seedColor: const Color(0xFF00E5FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: LifeOSController(
        prefs: prefs,
      ),
    );
  }
}

// ============================================================
// CONTROLLER
// ============================================================

class LifeOSController extends StatefulWidget {
  final SharedPreferences prefs;

  const LifeOSController({
    super.key,
    required this.prefs,
  });

  @override
  State<LifeOSController> createState() =>
      _LifeOSControllerState();
}

class _LifeOSControllerState
    extends State<LifeOSController> {
  bool onboardingComplete = false;

  String name = '';
  String email = '';
  String phone = '';
  String country = 'India';
  String currency = 'INR ₹';
  String language = 'English';

  @override
  void initState() {
    super.initState();

    onboardingComplete =
        widget.prefs.getBool(
              'onboarding_complete',
            ) ??
            false;

    name =
        widget.prefs.getString(
              'name',
            ) ??
            '';

    email =
        widget.prefs.getString(
              'email',
            ) ??
            '';

    phone =
        widget.prefs.getString(
              'phone',
            ) ??
            '';

    country =
        widget.prefs.getString(
              'country',
            ) ??
            'India';

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

  Future<void> finishOnboarding(
    Map<String, String> data,
  ) async {
    name = data['name'] ?? '';
    email = data['email'] ?? '';
    phone = data['phone'] ?? '';
    country = data['country'] ?? 'India';
    currency =
        data['currency'] ?? 'INR ₹';
    language =
        data['language'] ?? 'English';

    await widget.prefs.setString(
      'name',
      name,
    );

    await widget.prefs.setString(
      'email',
      email,
    );

    await widget.prefs.setString(
      'phone',
      phone,
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

    setState(() {
      onboardingComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!onboardingComplete) {
      return OnboardingFlow(
        onComplete: finishOnboarding,
      );
    }

    return LifeOSHome(
      prefs: widget.prefs,
      name: name,
      country: country,
      currency: currency,
      language: language,
    );
  }
}

// ============================================================
// ONBOARDING
// ============================================================

class OnboardingFlow extends StatefulWidget {
  final Future<void> Function(
    Map<String, String>,
  ) onComplete;

  const OnboardingFlow({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingFlow> createState() =>
      _OnboardingFlowState();
}

class _OnboardingFlowState
    extends State<OnboardingFlow> {
  final PageController pages =
      PageController();

  final nameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  int page = 0;

  String loginMethod = 'email';

  String country = 'India';

  String currency = 'INR ₹';

  String language = 'English';

  bool passwordVisible = false;

  bool otpMode = false;

  bool microphonePermission = false;

  bool notificationPermission = false;

  bool calendarPermission = false;

  bool cameraPermission = false;

  final countries = const [
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

  @override
  void dispose() {
    pages.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void next() {
    if (page < 4) {
      setState(() {
        page++;
      });

      pages.animateToPage(
        page,
        duration:
            const Duration(
          milliseconds: 350,
        ),
        curve: Curves.easeOut,
      );
    } else {
      complete();
    }
  }

  void back() {
    if (page > 0) {
      setState(() {
        page--;
      });

      pages.animateToPage(
        page,
        duration:
            const Duration(
          milliseconds: 350,
        ),
        curve: Curves.easeOut,
      );
    }
  }

  void selectCountry(
    String value,
  ) {
    setState(() {
      country = value;
      currency =
          currencyForCountry(
        value,
      );
    });
  }

  String currencyForCountry(
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

  Future<void> complete() async {
    if (nameController.text.trim().isEmpty) {
      _message(
        'Please enter your name.',
      );
      return;
    }

    if (loginMethod == 'email' &&
        emailController.text.trim().isEmpty) {
      _message(
        'Please enter your email.',
      );
      return;
    }

    if (loginMethod == 'phone' &&
        phoneController.text.trim().isEmpty) {
      _message(
        'Please enter your mobile number.',
      );
      return;
    }

    await widget.onComplete({
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'country': country,
      'currency': currency,
      'language': language,
    });
  }

  void _message(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
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
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    18,
                    12,
                    18,
                    4,
                  ),
                  child: Row(
                    children: [
                      if (page > 0)
                        IconButton(
                          onPressed: back,
                          icon:
                              const Icon(
                            Icons
                                .arrow_back_ios_new,
                            size: 17,
                          ),
                        ),

                      const Spacer(),

                      const Text(
                        'L I F E O S',
                        style: TextStyle(
                          letterSpacing: 5,
                          fontSize: 14,
                        ),
                      ),

                      const Spacer(),

                      const SizedBox(
                        width: 48,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView(
                    controller: pages,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    children: [
                      _loginPage(),
                      _profilePage(),
                      _countryPage(),
                      _personalizePage(),
                      _permissionPage(),
                    ],
                  ),
                ),

                _bottomButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginPage() {
    return _page(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const YansiOrb(
            size: 170,
          ),

          const SizedBox(
            height: 20,
          ),

          const Text(
            'WELCOME TO LIFEOS',
            style: TextStyle(
              fontSize: 22,
              letterSpacing: 3,
              fontWeight:
                  FontWeight.w300,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          const Text(
            'YOUR LIFE. ONE INTELLIGENCE.',
            style: TextStyle(
              color:
                  Color(0xFF55FF88),
              fontSize: 9,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(
            height: 32,
          ),

          Row(
            children: [
              Expanded(
                child: _methodButton(
                  'EMAIL',
                  loginMethod ==
                      'email',
                  () {
                    setState(() {
                      loginMethod =
                          'email';
                    });
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: _methodButton(
                  'PHONE',
                  loginMethod ==
                      'phone',
                  () {
                    setState(() {
                      loginMethod =
                          'phone';
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          if (loginMethod ==
              'email')
            _field(
              emailController,
              'Email address',
              Icons
                  .alternate_email,
              keyboard:
                  TextInputType
                      .emailAddress,
            )
          else
            _field(
              phoneController,
              'Mobile number',
              Icons.phone_outlined,
              keyboard:
                  TextInputType.phone,
            ),

          const SizedBox(
            height: 12,
          ),

          if (!otpMode)
            _passwordField(),

          const SizedBox(
            height: 10,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    otpMode = !otpMode;
                  });
                },
                child: Text(
                  otpMode
                      ? 'USE PASSWORD'
                      : 'LOGIN WITH OTP',
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF00E5FF),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          if (otpMode)
            const Text(
              'OTP verification will be connected to the secure authentication service in the Android/backend phase.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Colors.white38,
                fontSize: 9,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }

  Widget _profilePage() {
    return _page(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const YansiOrb(
            size: 120,
          ),

          const SizedBox(
            height: 25,
          ),

          const Text(
            'YOUR PROFILE',
            style: TextStyle(
              letterSpacing: 3,
              fontSize: 18,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          const Text(
            'Yansi needs to know who it is helping.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  Colors.white54,
              fontSize: 10,
            ),
          ),

          const SizedBox(
            height: 25,
          ),

          _field(
            nameController,
            'Your name',
            Icons.person_outline,
          ),

          const SizedBox(
            height: 14,
          ),

          const Text(
            'Your name is used by Yansi for personalized interaction.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  Colors.white30,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _countryPage() {
    return _page(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.public,
            size: 48,
            color:
                Color(0xFF55FF88),
          ),

          const SizedBox(
            height: 20,
          ),

          const Text(
            'WHERE ARE YOU?',
            style: TextStyle(
              fontSize: 20,
              letterSpacing: 3,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          const Text(
            'LifeOS will automatically configure your regional settings.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  Colors.white54,
              fontSize: 10,
            ),
          ),

          const SizedBox(
            height: 28,
          ),

          DropdownButtonFormField<
              String>(
            value: country,
            decoration:
                const InputDecoration(
              labelText:
                  'COUNTRY',
              prefixIcon:
                  Icon(
                Icons.language,
              ),
            ),
            items:
                countries.map(
              (c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c),
                );
              },
            ).toList(),
            onChanged: (value) {
              if (value != null) {
                selectCountry(
                  value,
                );
              }
            },
          ),

          const SizedBox(
            height: 18,
          ),

          Container(
            padding:
                const EdgeInsets.all(
              18,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xCC07131D,
              ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              border: Border.all(
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
                      .account_balance_wallet_outlined,
                  color:
                      Color(0xFF55FF88),
                ),
                const SizedBox(
                  width: 14,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Text(
                        'AUTOMATIC CURRENCY',
                        style:
                            TextStyle(
                          fontSize: 8,
                          letterSpacing:
                              2,
                          color:
                              Colors.white38,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        currency,
                        style:
                            const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _personalizePage() {
    return _page(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const YansiOrb(
            size: 130,
          ),

          const SizedBox(
            height: 20,
          ),

          const Text(
            'MAKE LIFEOS YOURS',
            style: TextStyle(
              fontSize: 20,
              letterSpacing: 3,
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          _selectionCard(
            Icons.translate,
            'LANGUAGE',
            language,
            () {
              _languageDialog();
            },
          ),

          _selectionCard(
            Icons.palette_outlined,
            'VISUAL MODE',
            'Futuristic',
            () {},
          ),

          _selectionCard(
            Icons.record_voice_over_outlined,
            'YANSI',
            'Ambient voice',
            () {},
          ),

          _selectionCard(
            Icons.notifications_none,
            'REMINDERS',
            'Smart & quiet',
            () {},
          ),
        ],
      ),
    );
  }

  Widget _permissionPage() {
    return _page(
      child: ListView(
        padding:
            const EdgeInsets.symmetric(
          vertical: 20,
        ),
        children: [
          const YansiOrb(
            size: 110,
          ),

          const SizedBox(
            height: 15,
          ),

          const Text(
            'YANSI PERMISSIONS',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              letterSpacing: 3,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          const Text(
            'Yansi is ambient, not hidden. You control every permission.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  Colors.white54,
              fontSize: 10,
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          _permission(
            Icons.mic_none,
            'MICROPHONE',
            'Voice interaction with Yansi',
            microphonePermission,
            (v) {
              setState(() {
                microphonePermission =
                    v;
              });
            },
          ),

          _permission(
            Icons.notifications_none,
            'NOTIFICATIONS',
            'Useful permitted notifications',
            notificationPermission,
            (v) {
              setState(() {
                notificationPermission =
                    v;
              });
            },
          ),

          _permission(
            Icons.calendar_today_outlined,
            'CALENDAR',
            'Bills, appointments and important dates',
            calendarPermission,
            (v) {
              setState(() {
                calendarPermission =
                    v;
              });
            },
          ),

          _permission(
            Icons.camera_alt_outlined,
            'CAMERA',
            'Receipt and document scanning',
            cameraPermission,
            (v) {
              setState(() {
                cameraPermission =
                    v;
              });
            },
          ),

          const SizedBox(
            height: 10,
          ),

          const Text(
            'Android will request the actual system permissions when these integrations are connected.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  Colors.white30,
              fontSize: 9,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _permission(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> changed,
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
            BorderRadius.circular(
          11,
        ),
        border: Border.all(
          color:
              const Color(0x2200E5FF),
        ),
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
          style:
              const TextStyle(
            fontSize: 10,
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

  Widget _selectionCard(
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
              BorderRadius.circular(
            11,
          ),
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
                  const Color(
                0xFF55FF88,
              ),
            ),
            const SizedBox(
              width: 14,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 8,
                      color:
                          Colors.white38,
                      letterSpacing:
                          1,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
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

  Widget _methodButton(
    String text,
    bool selected,
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
          color: selected
              ? const Color(
                  0x2200E5FF,
                )
              : const Color(
                  0xAA07131D,
                ),
          borderRadius:
              BorderRadius.circular(
            8,
          ),
          border: Border.all(
            color: selected
                ? const Color(
                    0xAA00E5FF,
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
            fontSize: 9,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller:
          passwordController,
      obscureText:
          !passwordVisible,
      decoration:
          InputDecoration(
        hintText:
            'Password',
        prefixIcon:
            const Icon(
          Icons.lock_outline,
        ),
        suffixIcon:
            IconButton(
          onPressed: () {
            setState(() {
              passwordVisible =
                  !passwordVisible;
            });
          },
          icon: Icon(
            passwordVisible
                ? Icons
                    .visibility_off_outlined
                : Icons
                    .visibility_outlined,
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType? keyboard,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration:
          InputDecoration(
        hintText: hint,
        prefixIcon:
            Icon(icon),
      ),
    );
  }

  Widget _page({
    required Widget child,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 25,
      ),
      child: child,
    );
  }

  Widget _bottomButton() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        5,
        20,
        15,
      ),
      child: SizedBox(
        width:
            double.infinity,
        height: 51,
        child: ElevatedButton(
          onPressed: next,
          child: Text(
            page == 4
                ? 'ENTER LIFEOS'
                : 'CONTINUE',
            style:
                const TextStyle(
              letterSpacing: 2,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  void _languageDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title:
              const Text('Language'),
          content:
              DropdownButtonFormField<
                  String>(
            value: language,
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
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  language =
                      value;
                });

                Navigator.pop(
                  context,
                );
              }
            },
          ),
        );
      },
    );
  }
}

// ============================================================
// HOME
// ============================================================

class LifeOSHome extends StatefulWidget {
  final SharedPreferences prefs;
  final String name;
  final String country;
  final String currency;
  final String language;

  const LifeOSHome({
    super.key,
    required this.prefs,
    required this.name,
    required this.country,
    required this.currency,
    required this.language,
  });

  @override
  State<LifeOSHome> createState() =>
      _LifeOSHomeState();
}

class _LifeOSHomeState
    extends State<LifeOSHome> {
  final SpeechToText speech =
      SpeechToText();

  final FlutterTts tts =
      FlutterTts();

  List<Map<String, dynamic>>
      entries = [];

  bool listening = false;
  bool menuOpen = false;

  String yansiMessage =
      'I am here whenever you need me.';

  @override
  void initState() {
    super.initState();

    loadEntries();

    Future.delayed(
      const Duration(
        milliseconds: 800,
      ),
      () {
        welcome();
      },
    );
  }

  Future<void> welcome() async {
    final message =
        'Welcome, ${widget.name}. I’m Yansi, your personal LifeOS AI agent. I’m here whenever you need me.';

    setState(() {
      yansiMessage =
          message;
    });

    await speak(message);
  }

  Future<void> speak(
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

  void loadEntries() {
    final raw =
        widget.prefs.getString(
      'lifeos_entries',
    );

    if (raw == null) return;

    try {
      final list =
          jsonDecode(raw) as List;

      entries = list
          .map(
            (e) => Map<String,
                dynamic>.from(e),
          )
          .toList();
    } catch (_) {}
  }

  Future<void> saveEntries() async {
    await widget.prefs.setString(
      'lifeos_entries',
      jsonEncode(entries),
    );
  }

  Future<void> activateYansi() async {
    if (listening) return;

    final available =
        await speech.initialize();

    if (!available) {
      setState(() {
        yansiMessage =
            'Microphone permission is required for voice interaction.';
      });
      return;
    }

    setState(() {
      listening = true;
      yansiMessage =
          'Yansi is listening...';
    });

    String spoken = '';

    await speech.listen(
      onResult: (result) {
        spoken =
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

    if (spoken.trim().isEmpty) {
      return;
    }

    await processYansi(
      spoken,
    );
  }

  Future<void> processYansi(
    String input,
  ) async {
    final text =
        input.toLowerCase();

    // EXPENSE
    if (containsAny(
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
          extractAmount(text);

      if (amount > 0) {
        final category =
            expenseCategory(text);

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

        await saveEntries();

        final response =
            'Got it. I added ₹${amount.toStringAsFixed(0)} to $category for today.';

        setState(() {
          yansiMessage =
              response;
        });

        await speak(response);
        return;
      }
    }

    // PRODUCTIVITY
    if (containsAny(
      text,
      [
        'task',
        'todo',
        'to do',
        'need to',
        'have to',
        'finish',
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

      await saveEntries();

      const response =
          'Done. I added that to your productivity list.';

      setState(() {
        yansiMessage =
            response;
      });

      await speak(response);
      return;
    }

    // HOUSEHOLD
    if (containsAny(
      text,
      [
        'grocery',
        'groceries',
        'shopping',
        'milk',
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

      await saveEntries();

      const response =
          'Added that to your household requirement list.';

      setState(() {
        yansiMessage =
            response;
      });

      await speak(response);
      return;
    }

    // GOAL
    if (containsAny(
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

      await saveEntries();

      const response =
          'I created that as a LifeOS goal.';

      setState(() {
        yansiMessage =
            response;
      });

      await speak(response);
      return;
    }

    // CALENDAR
    if (containsAny(
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

      await saveEntries();

      const response =
          'Understood. I added that to your LifeOS calendar intelligence.';

      setState(() {
        yansiMessage =
            response;
      });

      await speak(response);
      return;
    }

    const response =
        'I heard you. Tell me about an expense, goal, task, household requirement or important date.';

    setState(() {
      yansiMessage =
          response;
    });

    await speak(response);
  }

  bool containsAny(
    String text,
    List<String> words,
  ) {
    return words.any(
      text.contains,
    );
  }

  double extractAmount(
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

  String expenseCategory(
    String text,
  ) {
    if (containsAny(
      text,
      [
        'petrol',
        'fuel',
        'diesel',
      ],
    )) {
      return 'Fuel';
    }

    if (containsAny(
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

    if (containsAny(
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

    if (containsAny(
      text,
      [
        'electricity',
        'light bill',
      ],
    )) {
      return 'Electricity';
    }

    if (containsAny(
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

    if (containsAny(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),

          SafeArea(
            child: Column(
              children: [
                topBar(),

                Expanded(
                  child: homeMap(),
                ),
              ],
            ),
          ),

          if (menuOpen)
            controlCenter(),

          if (listening)
            listeningBar(),
        ],
      ),
    );
  }

  Widget topBar() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        8,
        4,
        8,
        4,
      ),
      child: Row(
        children: [
          smallButton(
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
            ),
          ),

          const Spacer(),

          smallButton(
            Icons.notifications_none,
            () {},
          ),
        ],
      ),
    );
  }

  Widget smallButton(
    IconData icon,
    VoidCallback action,
  ) {
    return GestureDetector(
      onTap: action,
      child: Container(
        width: 31,
        height: 28,
        decoration:
            BoxDecoration(
          color:
              const Color(0xDD07131D),
          borderRadius:
              BorderRadius.circular(
            7,
          ),
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

  Widget homeMap() {
    return LayoutBuilder(
      builder:
          (context, size) {
        return Stack(
          children: [
            Positioned(
              top: 15,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    widget.name
                        .toUpperCase(),
                    style:
                        const TextStyle(
                      fontSize: 8,
                      letterSpacing: 3,
                      color:
                          Colors.white38,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  const Text(
                    'LIFE INTELLIGENCE',
                    style: TextStyle(
                      fontSize: 17,
                      letterSpacing: 2,
                      fontWeight:
                          FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left:
                  size.maxWidth / 2 - 90,
              top:
                  size.maxHeight * .23,
              child:
                  GestureDetector(
                onTap:
                    activateYansi,
                child:
                    const YansiOrb(
                  size: 180,
                ),
              ),
            ),

            core(
              left: 7,
              top:
                  size.maxHeight * .18,
              icon: Icons
                  .account_balance_wallet_outlined,
              title: 'MONEY',
              type: 'expense',
            ),

            core(
              right: 7,
              top:
                  size.maxHeight * .18,
              icon:
                  Icons.flag_outlined,
              title: 'GOALS',
              type: 'goal',
            ),

            core(
              left: 7,
              top:
                  size.maxHeight * .57,
              icon:
                  Icons.bolt_outlined,
              title: 'PRODUCTIVITY',
              type: 'productivity',
            ),

            core(
              right: 7,
              top:
                  size.maxHeight * .57,
              icon: Icons
                  .shopping_bag_outlined,
              title: 'HOUSEHOLD',
              type: 'household',
            ),

            Positioned(
              bottom: 14,
              left:
                  size.maxWidth / 2 - 54,
              child: coreButton(
                Icons
                    .calendar_today_outlined,
                'CALENDAR',
                'calendar',
              ),
            ),

            Positioned(
              bottom: 67,
              left: 22,
              right: 22,
              child: messageBox(),
            ),
          ],
        );
      },
    );
  }

  Widget core({
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
      child: coreButton(
        icon,
        title,
        type,
      ),
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
            builder: (_) =>
                CoreReport(
              prefs: widget.prefs,
              title: title,
              type: type,
              icon: icon,
              currency:
                  widget.currency,
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
              BorderRadius.circular(
            9,
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
              size: 16,
              color:
                  const Color(
                0xFF55FF88,
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(
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

  Widget messageBox() {
    return Container(
      padding:
          const EdgeInsets.all(11),
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
          fontSize: 9,
          height: 1.4,
          color:
              Colors.white70,
        ),
      ),
    );
  }

  Widget controlCenter() {
    return Positioned(
      top: 42,
      left: 7,
      child: Container(
        width: 245,
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
                const Color(0x5500E5FF),
          ),
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
              height: 12,
            ),
            menuItem(
              Icons.person_outline,
              'PROFILE',
              () {},
            ),
            menuItem(
              Icons.security,
              'YANSI PERMISSIONS',
              () {},
            ),
            menuItem(
              Icons.insights_outlined,
              'LIFE REPORT',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LifeReport(
                      entries:
                          entries,
                      currency:
                          widget.currency,
                    ),
                  ),
                );
              },
            ),
            menuItem(
              Icons.settings_outlined,
              'SETTINGS',
              () {},
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
              size: 17,
              color:
                  const Color(
                0xFF55FF88,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
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

  Widget listeningBar() {
    return Positioned(
      bottom: 10,
      left: 18,
      right: 18,
      child: Container(
        padding:
            const EdgeInsets.all(
          12,
        ),
        decoration:
            BoxDecoration(
          color:
              const Color(0xFF07131D),
          borderRadius:
              BorderRadius.circular(
            10,
          ),
          border: Border.all(
            color:
                const Color(0x8855FF88),
          ),
        ),
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            Icon(
              Icons.graphic_eq,
              color:
                  Color(0xFF55FF88),
              size: 18,
            ),
            SizedBox(
              width: 9,
            ),
            Text(
              'YANSI • LISTENING',
              style: TextStyle(
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
// CORE REPORT
// ============================================================

class CoreReport extends StatefulWidget {
  final SharedPreferences prefs;
  final String title;
  final String type;
  final IconData icon;
  final String currency;

  const CoreReport({
    super.key,
    required this.prefs,
    required this.title,
    required this.type,
    required this.icon,
    required this.currency,
  });

  @override
  State<CoreReport> createState() =>
      _CoreReportState();
}

class _CoreReportState
    extends State<CoreReport> {
  List<Map<String, dynamic>>
      items = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() {
    final raw =
        widget.prefs.getString(
      'lifeos_entries',
    );

    if (raw == null) return;

    try {
      final list =
          jsonDecode(raw) as List;

      setState(() {
        items = list
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
    double total = 0;

    for (final item in items) {
      if (item['amount'] is num) {
        total +=
            (item['amount'] as num)
                .toDouble();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              widget.icon,
              color:
                  const Color(
                0xFF55FF88,
              ),
              size: 18,
            ),
            const SizedBox(
              width: 9,
            ),
            Text(
              widget.title,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          const FuturisticBackground(),

          ListView(
            padding:
                const EdgeInsets.all(
              16,
            ),
            children: [
              Container(
                padding:
                    const EdgeInsets.all(
                  17,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xDD07131D,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                  border: Border.all(
                    color:
                        const Color(
                      0x3300E5FF,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const YansiOrb(
                      size: 65,
                    ),
                    const SizedBox(
                      width: 13,
                    ),
                    Expanded(
                      child: Text(
                        widget.type ==
                                'expense'
                            ? 'Yansi is monitoring your financial activity.'
                            : 'Yansi is keeping this part of your life organized.',
                        style:
                            const TextStyle(
                          fontSize: 10,
                          color:
                              Colors.white60,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              if (widget.type ==
                  'expense')
                _total(
                  '${widget.currency} ${total.toStringAsFixed(0)}',
                ),

              const SizedBox(
                height: 10,
              ),

              if (items.isEmpty)
                const Padding(
                  padding:
                      EdgeInsets.all(
                    30,
                  ),
                 
