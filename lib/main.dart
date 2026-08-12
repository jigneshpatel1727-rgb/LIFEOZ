import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/futuristic_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    LifeOS(
      prefs: prefs,
    ),
  );
}

// ============================================================
// LIFEOS ROOT
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

    _loadUser();
  }

  // ==========================================================
  // LOAD USER
  // ==========================================================

  void _loadUser() {
    userName =
        widget.prefs.getString(
      'user_name',
    );

    country =
        widget.prefs.getString(
              'country',
            ) ??
            'India';

    currency =
        widget.prefs.getString(
              'currency',
            ) ??
            '₹';

    themeIndex =
        widget.prefs.getInt(
              'theme_index',
            ) ??
            0;

    setState(() {});
  }

  // ==========================================================
  // COMPLETE ONBOARDING
  // ==========================================================

  Future<void> finishOnboarding(
    String name,
    String selectedCountry,
    String selectedCurrency,
    int selectedTheme,
  ) async {
    await widget.prefs.setString(
      'user_name',
      name,
    );

    await widget.prefs.setString(
      'country',
      selectedCountry,
    );

    await widget.prefs.setString(
      'currency',
      selectedCurrency,
    );

    await widget.prefs.setInt(
      'theme_index',
      selectedTheme,
    );

    if (!mounted) return;

    setState(() {
      userName = name;
      country = selectedCountry;
      currency = selectedCurrency;
      themeIndex = selectedTheme;
    });
  }

  // ==========================================================
  // CHANGE THEME
  // ==========================================================

  Future<void> changeTheme(
    int index,
  ) async {
    await widget.prefs.setInt(
      'theme_index',
      index,
    );

    if (!mounted) return;

    setState(() {
      themeIndex = index;
    });
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    // --------------------------------------------------------
    // NEW USER
    // --------------------------------------------------------

    if (userName == null ||
        userName!.trim().isEmpty) {
      return MaterialApp(
        debugShowCheckedModeBanner:
            false,
        title: 'LifeOS',
        theme: ThemeData(
          brightness:
              Brightness.dark,
          useMaterial3: true,
        ),
        home: OnboardingScreen(
          onComplete:
              finishOnboarding,
        ),
      );
    }

    // --------------------------------------------------------
    // EXISTING USER
    // --------------------------------------------------------

    return MaterialApp(
      debugShowCheckedModeBanner:
          false,
      title: 'LifeOS',
      theme: ThemeData(
        brightness:
            Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor:
            const Color(
          0xFF02070B,
        ),
      ),
      home:
          FuturisticHomeScreen(
        prefs:
            widget.prefs,
        userName:
            userName!,
        country:
            country,
        currency:
            currency,
        themeIndex:
            themeIndex,
        onThemeChanged:
            changeTheme,
      ),
    );
  }
}

// ============================================================
// ONBOARDING
// ============================================================

class OnboardingScreen
    extends StatefulWidget {
  final Future<void> Function(
    String name,
    String country,
    String currency,
    int theme,
  ) onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen>
      createState() =>
          _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  final TextEditingController
      nameController =
      TextEditingController();

  String country = 'India';

  String currency = '₹';

  int selectedTheme = 0;

  // ==========================================================
  // COUNTRY / CURRENCY
  // ==========================================================

  final Map<String, String>
      countries = {
    'India': '₹',
    'United States': r'$',
    'United Kingdom': '£',
    'Europe': '€',
    'Japan': '¥',
    'Australia': r'A$',
    'Canada': r'C$',
    'UAE': 'AED',
    'Singapore': r'S$',
    'Saudi Arabia': 'SAR',
  };

  // ==========================================================
  // THEME NAMES
  // ==========================================================

  final List<String>
      themes = [
    'Aurora Nexus',
    'Void Matrix',
    'Quantum Purple',
    'Solaris Prime',
    'Frost Minimal',
  ];

  // ==========================================================
  // THEME COLORS
  // ==========================================================

  Color themePrimary(
    int index,
  ) {
    switch (index) {
      case 1:
        return const Color(
          0xFF168CFF,
        );

      case 2:
        return const Color(
          0xFFD24CFF,
        );

      case 3:
        return const Color(
          0xFFFFC928,
        );

      case 4:
        return const Color(
          0xFF147BFF,
        );

      default:
        return const Color(
          0xFF00FFD5,
        );
    }
  }

  Color themeBackground(
    int index,
  ) {
    switch (index) {
      case 1:
        return const Color(
          0xFF020611,
        );

      case 2:
        return const Color(
          0xFF0A0310,
        );

      case 3:
        return const Color(
          0xFF0B0802,
        );

      case 4:
        return const Color(
          0xFFF4FAFF,
        );

      default:
        return const Color(
          0xFF020B0B,
        );
    }
  }

  Color themeText(
    int index,
  ) {
    if (index == 4) {
      return const Color(
        0xFF08244A,
      );
    }

    return Colors.white;
  }

  // ==========================================================
  // CONTINUE
  // ==========================================================

  Future<void> continueSetup() async {
    final name =
        nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your name.',
          ),
        ),
      );

      return;
    }

    await widget.onComplete(
      name,
      country,
      currency,
      selectedTheme,
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final background =
        themeBackground(
      selectedTheme,
    );

    final primary =
        themePrimary(
      selectedTheme,
    );

    final text =
        themeText(
      selectedTheme,
    );

    return Scaffold(
      backgroundColor:
          background,
      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            24,
            30,
            24,
            40,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
            children: [
              // ------------------------------------------------
              // LOGO
              // ------------------------------------------------

              Center(
                child: Container(
                  width: 118,
                  height: 118,
                  decoration:
                      BoxDecoration(
                    shape:
                        BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            primary.withOpacity(
                          .28,
                        ),
                        blurRadius:
                            45,
                        spreadRadius:
                            5,
                      ),
                    ],
                    border:
                        Border.all(
                      color:
                          primary.withOpacity(
                        .65,
                      ),
                      width: 1.2,
                    ),
                    gradient:
                        RadialGradient(
                      colors: [
                        primary.withOpacity(
                          .25,
                        ),
                        background,
                      ],
                    ),
                  ),
                  child:
                      CustomPaint(
                    painter:
                        _OnboardingFacePainter(
                      primary:
                          primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // ------------------------------------------------
              // LIFEOS
              // ------------------------------------------------

              Text(
                'LIFEOS',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  color:
                      text,
                  fontSize:
                      32,
                  fontWeight:
                      FontWeight.w300,
                  letterSpacing:
                      7,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                'YOUR LIFE. INTELLIGENTLY.',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  color:
                      primary.withOpacity(
                    .75,
                  ),
                  fontSize:
                      10,
                  letterSpacing:
                      3,
                ),
              ),

              const SizedBox(
                height: 42,
              ),

              Text(
                'Let’s build your LifeOS',
                style:
                    TextStyle(
                  color:
                      text,
                  fontSize:
                      23,
                  fontWeight:
                      FontWeight.w300,
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // ------------------------------------------------
              // NAME
              // ------------------------------------------------

              TextField(
                controller:
                    nameController,
                style:
                    TextStyle(
                  color:
                      text,
                ),
                decoration:
                    InputDecoration(
                  hintText:
                      'Your name',
                  hintStyle:
                      TextStyle(
                    color:
                        text.withOpacity(
                      .35,
                    ),
                  ),
                  prefixIcon:
                      Icon(
                    Icons
                        .person_outline,
                    color:
                        primary,
                  ),
                  filled:
                      true,
                  fillColor:
                      text.withOpacity(
                    .045,
                  ),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    borderSide:
                        BorderSide(
                      color:
                          primary.withOpacity(
                        .20,
                      ),
                    ),
                  ),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    borderSide:
                        BorderSide(
                      color:
                          primary.withOpacity(
                        .20,
                      ),
                    ),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    borderSide:
                        BorderSide(
                      color:
                          primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              // ------------------------------------------------
              // COUNTRY
              // ------------------------------------------------

              DropdownButtonFormField<
                  String>(
                value:
                    country,
                dropdownColor:
                    background,
                style:
                    TextStyle(
                  color:
                      text,
                ),
                decoration:
                    InputDecoration(
                  prefixIcon:
                      Icon(
                    Icons.public,
                    color:
                        primary,
                  ),
                  filled:
                      true,
                  fillColor:
                      text.withOpacity(
                    .045,
                  ),
                  labelText:
                      'Country',
                  labelStyle:
                      TextStyle(
                    color:
                        text.withOpacity(
                      .45,
                    ),
                  ),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                ),
                items:
                    countries.keys
                        .map(
                  (
                    item,
                  ) {
                    return DropdownMenuItem<
                        String>(
                      value:
                          item,
                      child:
                          Text(
                        item,
                      ),
                    );
                  },
                ).toList(),
                onChanged:
                    (
                  value,
                ) {
                  if (value ==
                      null) {
                    return;
                  }

                  setState(
                    () {
                      country =
                          value;

                      currency =
                          countries[
                              value]!;
                    },
                  );
                },
              ),

              const SizedBox(
                height: 8,
              ),

              // ------------------------------------------------
              // CURRENCY
              // ------------------------------------------------

              Text(
                'Currency: $currency',
                style:
                    TextStyle(
                  color:
                      primary,
                  fontSize:
                      12,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              Text(
                'Choose your LifeOS world',
                style:
                    TextStyle(
                  color:
                      text,
                  fontSize:
                      17,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // ------------------------------------------------
              // DESIGN SELECTION
              // ------------------------------------------------

              SizedBox(
                height: 122,
                child:
                    ListView.builder(
                  scrollDirection:
                      Axis.horizontal,
                  itemCount:
                      themes.length,
                  itemBuilder:
                      (
                    context,
                    index,
                  ) {
                    final selected =
                        selectedTheme ==
                            index;

                    final itemPrimary =
                        themePrimary(
                      index,
                    );

                    final itemBackground =
                        themeBackground(
                      index,
                    );

                    final itemText =
                        themeText(
                      index,
                    );

                    return GestureDetector(
                      onTap:
                          () {
                        setState(
                          () {
                            selectedTheme =
                                index;
                          },
                        );
                      },
                      child:
                          Container(
                        width:
                            148,
                        margin:
                            const EdgeInsets
                                .only(
                          right:
                              12,
                        ),
                        padding:
                            const EdgeInsets
                                .all(
                          13,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              itemBackground,
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                          border:
                              Border.all(
                            color:
                                selected
                                    ? itemPrimary
                                    : itemPrimary
                                        .withOpacity(
                                        .18,
                                      ),
                            width:
                                selected
                                    ? 2
                                    : 1,
                          ),
                        ),
                        child:
                            Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Container(
                              width:
                                  42,
                              height:
                                  42,
                              decoration:
                                  BoxDecoration(
                                shape:
                                    BoxShape.circle,
                                border:
                                    Border.all(
                                  color:
                                      itemPrimary
                                          .withOpacity(
                                    .55,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        itemPrimary
                                            .withOpacity(
                                      .18,
                                    ),
                                    blurRadius:
                                        15,
                                  ),
                                ],
                              ),
                              child:
                                  Icon(
                                Icons
                                    .auto_awesome,
                                size:
                                    19,
                                color:
                                    itemPrimary,
                              ),
                            ),
                            const SizedBox(
                              height:
                                  8,
                            ),
                            Text(
                              themes[
                                  index],
                              textAlign:
                                  TextAlign.center,
                              style:
                                  TextStyle(
                                color:
                                    itemText,
                                fontSize:
                                    10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(
                height: 34,
              ),

              // ------------------------------------------------
              // ENTER
              // ------------------------------------------------

              SizedBox(
                height:
                    58,
                child:
                    ElevatedButton(
                  onPressed:
                      continueSetup,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        primary,
                    foregroundColor:
                        background,
                    elevation:
                        0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                    ),
                  ),
                  child:
                      const Text(
                    'ENTER LIFEOS',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      letterSpacing:
                          2,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height:
                    14,
              ),

              Text(
                'Your personal LifeOS. One screen. One tap. One intelligent report.',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  color:
                      text.withOpacity(
                    .35,
                  ),
                  fontSize:
                      10,
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
// ONBOARDING YANSI FACE
// ============================================================

class _OnboardingFacePainter
    extends CustomPainter {
  final Color primary;

  _OnboardingFacePainter({
    required this.primary,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center =
        Offset(
      size.width / 2,
      size.height / 2,
    );

    final glow =
        Paint()
          ..color =
              primary.withOpacity(
            .10,
          );

    canvas.drawCircle(
      center,
      42,
      glow,
    );

    final eye =
        Paint()
          ..color =
              primary;

    canvas.drawCircle(
      Offset(
        center.dx - 18,
        center.dy - 7,
      ),
      4,
      eye,
    );

    canvas.drawCircle(
      Offset(
        center.dx + 18,
        center.dy - 7,
      ),
      4,
      eye,
    );

    final mouth =
        Paint()
          ..style =
              PaintingStyle.stroke
          ..strokeWidth =
              1.8
          ..strokeCap =
              StrokeCap.round
          ..color =
              primary.withOpacity(
            .75,
          );

    final path =
        Path();

    path.moveTo(
      center.dx - 15,
      center.dy + 18,
    );

    path.quadraticBezierTo(
      center.dx,
      center.dy + 27,
      center.dx + 15,
      center.dy + 18,
    );

    canvas.drawPath(
      path,
      mouth,
    );
  }

  @override
  bool shouldRepaint(
    covariant _OnboardingFacePainter
        oldDelegate,
  ) {
    return false;
  }
}
