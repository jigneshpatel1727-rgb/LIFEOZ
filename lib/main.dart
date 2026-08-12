import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const LifeOS());
}

const Color bg = Color(0xFF02070D);
const Color cyan = Color(0xFF00E5FF);
const Color green = Color(0xFF55FF88);
const Color darkPanel = Color(0xFF07131D);

class LifeOS extends StatelessWidget {
  const LifeOS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeOS',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: cyan,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

// ============================================================
// WELCOME / USER LOGIN
// ============================================================

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 25),

                    const YansiOrb(size: 145),

                    const SizedBox(height: 25),

                    const Text(
                      'L I F E O S',
                      style: TextStyle(
                        fontSize: 25,
                        letterSpacing: 8,
                        fontWeight: FontWeight.w300,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'YOUR LIFE. ONE INTELLIGENCE.',
                      style: TextStyle(
                        color: cyan,
                        fontSize: 10,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 35),

                    const Text(
                      'WELCOME',
                      style: TextStyle(
                        color: green,
                        fontSize: 11,
                        letterSpacing: 4,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Let Yansi know you.',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                      ),
                    ),

                    const SizedBox(height: 25),

                    LifeField(
                      controller: nameController,
                      label: 'YOUR NAME',
                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 12),

                    LifeField(
                      controller: emailController,
                      label: 'EMAIL',
                      icon: Icons.alternate_email,
                    ),

                    const SizedBox(height: 25),

                    LifeButton(
                      text: 'ENTER LIFEOS',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () {
                        final name =
                            nameController.text.trim();

                        if (name.isEmpty) {
                          _message(
                            context,
                            'Please enter your name.',
                          );
                          return;
                        }

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PermissionScreen(
                              userName: name,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Your data stays under your control.',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
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

  void _message(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

// ============================================================
// PERMISSION SCREEN
// ============================================================

class PermissionScreen extends StatefulWidget {
  final String userName;

  const PermissionScreen({
    super.key,
    required this.userName,
  });

  @override
  State<PermissionScreen> createState() =>
      _PermissionScreenState();
}

class _PermissionScreenState
    extends State<PermissionScreen> {
  bool microphone = false;
  bool notifications = false;
  bool calendar = false;
  bool camera = false;
  bool health = false;

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
                const SizedBox(height: 10),

                const YansiOrb(size: 95),

                const SizedBox(height: 20),

                const Text(
                  'YANSI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: green,
                    letterSpacing: 5,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Permission Center',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w300,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Yansi can connect your life systems '
                  'only when you allow it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 25),

                PermissionTile(
                  title: 'Voice',
                  subtitle:
                      'Speak naturally with Yansi.',
                  icon: Icons.mic_none,
                  value: microphone,
                  onChanged: (v) {
                    setState(() {
                      microphone = v;
                    });
                  },
                ),

                PermissionTile(
                  title: 'Notifications',
                  subtitle:
                      'Let Yansi understand useful alerts.',
                  icon: Icons.notifications_none,
                  value: notifications,
                  onChanged: (v) {
                    setState(() {
                      notifications = v;
                    });
                  },
                ),

                PermissionTile(
                  title: 'Calendar',
                  subtitle:
                      'Bills, renewals and important dates.',
                  icon: Icons.calendar_today_outlined,
                  value: calendar,
                  onChanged: (v) {
                    setState(() {
                      calendar = v;
                    });
                  },
                ),

                PermissionTile(
                  title: 'Camera',
                  subtitle:
                      'Scan receipts and bills.',
                  icon: Icons.camera_alt_outlined,
                  value: camera,
                  onChanged: (v) {
                    setState(() {
                      camera = v;
                    });
                  },
                ),

                PermissionTile(
                  title: 'Health',
                  subtitle:
                      'Optional health integrations.',
                  icon: Icons.favorite_border,
                  value: health,
                  onChanged: (v) {
                    setState(() {
                      health = v;
                    });
                  },
                ),

                const SizedBox(height: 20),

                LifeButton(
                  text: 'ACTIVATE LIFEOS',
                  icon: Icons.bolt,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            HomeScreen(
                          userName:
                              widget.userName,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                const Text(
                  'Ghost mode never means secret surveillance. '
                  'Android permissions remain user-controlled.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MAIN LIFEOS SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({
    super.key,
    required this.userName,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  bool menuOpen = false;
  bool listening = false;

  String lastCommand = '';

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
                  child: _lifeHud(),
                ),
              ],
            ),
          ),

          if (menuOpen)
            _controlCenter(),

          if (listening)
            _listeningPanel(),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      child: Row(
        children: [
          SmallIcon(
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
              fontSize: 15,
              letterSpacing: 5,
              fontWeight: FontWeight.w300,
            ),
          ),

          const Spacer(),

          SmallIcon(
            icon:
                Icons.notifications_none_rounded,
            dot: true,
            onTap: () {
              _say(
                context,
                'Yansi has no new alerts.',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _lifeHud() {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints size,
      ) {
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: NeuralPainter(),
              ),
            ),

            Positioned(
              top: 22,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'GOOD DAY, '
                    '${widget.userName.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 9,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 8),

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

            // CENTRAL YANSI
            Positioned(
              left:
                  size.maxWidth / 2 - 82,
              top:
                  size.maxHeight / 2 - 90,
              child: GestureDetector(
                onTap: _activateYansi,
                child: const YansiOrb(
                  size: 165,
                ),
              ),
            ),

            // MONEY
            _core(
              left: 12,
              top: size.maxHeight * .24,
              icon:
                  Icons.account_balance_wallet_outlined,
              title: 'MONEY',
              type: CoreType.money,
            ),

            // GOALS
            _core(
              right: 12,
              top: size.maxHeight * .24,
              icon: Icons.flag_outlined,
              title: 'GOALS',
              type: CoreType.goals,
            ),

            // PRODUCTIVITY
            _core(
              left: 12,
              top: size.maxHeight * .68,
              icon: Icons.bolt_outlined,
              title: 'PRODUCTIVITY',
              type: CoreType.productivity,
            ),

            // HOUSEHOLD
            _core(
              right: 12,
              top: size.maxHeight * .68,
              icon:
                  Icons.shopping_bag_outlined,
              title: 'HOUSEHOLD',
              type: CoreType.household,
            ),

            // CALENDAR
            Positioned(
              bottom: 17,
              left:
                  size.maxWidth / 2 - 45,
              child: GestureDetector(
                onTap: () {
                  _openCore(
                    context,
                    'CALENDAR',
                    Icons.calendar_today_outlined,
                    CoreType.calendar,
                  );
                },
                child: _calendarButton(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _core({
    double? left,
    double? right,
    required double top,
    required IconData icon,
    required String title,
    required CoreType type,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: GestureDetector(
        onTap: () {
          _openCore(
            context,
            title,
            icon,
            type,
          );
        },
        child: Container(
          width: 112,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 11,
          ),
          decoration: lifeDecoration(),
          child: Row(
            children: [
              Icon(
                icon,
                color: green,
                size: 19,
              ),

              const SizedBox(width: 7),

              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _calendarButton() {
    return Container(
      width: 90,
      height: 45,
      decoration: lifeDecoration(),
      child: const Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: green,
            size: 17,
          ),
          SizedBox(height: 2),
          Text(
            'CALENDAR',
            style: TextStyle(
              fontSize: 7,
              letterSpacing: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // YANSI
  // ==========================================================

  void _activateYansi() {
    setState(() {
      listening = true;
    });

    _say(
      context,
      'Yansi voice connection is ready. '
      'Voice permissions can be connected next.',
    );
  }

  void _say(
    BuildContext context,
    String text,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.auto_awesome,
              color: green,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text),
            ),
          ],
        ),
      ),
    );

    Future.delayed(
      const Duration(seconds: 3),
      () {
        if (mounted) {
          setState(() {
            listening = false;
          });
        }
      },
    );
  }

  Widget _listeningPanel() {
    return Positioned(
      left: 15,
      right: 15,
      bottom: 15,
      child: Container(
        padding:
            const EdgeInsets.all(13),
        decoration: lifeDecoration(),
        child: Row(
          children: [
            const Icon(
              Icons.graphic_eq,
              color: green,
            ),

            const SizedBox(width: 10),

            const Expanded(
              child: Text(
                'YANSI • AMBIENT MODE ACTIVE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ),

            IconButton(
              onPressed: () {
                setState(() {
                  listening = false;
                });
              },
              icon: const Icon(
                Icons.close,
                color: cyan,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // CONTROL CENTER
  // ==========================================================

  Widget _controlCenter() {
    return Positioned(
      top: 52,
      left: 8,
      child: Container(
        width: 230,
        padding:
            const EdgeInsets.all(15),
        decoration:
            lifeDecoration().copyWith(
          color: darkPanel,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'CONTROL CENTER',
              style: TextStyle(
                color: cyan,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 8),

            _menuRow(
              Icons.person_outline,
              'PROFILE',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProfileScreen(
                      userName:
                          widget.userName,
                    ),
                  ),
                );
              },
            ),

            _menuRow(
              Icons.security,
              'YANSI PERMISSIONS',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PermissionScreen(
                      userName:
                          widget.userName,
                    ),
                  ),
                );
              },
            ),

            _menuRow(
              Icons.auto_awesome,
              'YANSI',
              () {
                _say(
                  context,
                  'I am Yansi. I connect your five LifeOS systems.',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuRow(
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
        padding:
            const EdgeInsets.symmetric(
          vertical: 13,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: green,
              size: 19,
            ),

            const SizedBox(width: 12),

            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCore(
    BuildContext context,
    String title,
    IconData icon,
    CoreType type,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoreScreen(
          title: title,
          icon: icon,
          type: type,
        ),
      ),
    );
  }
}

// ============================================================
// CORE SCREEN
// ============================================================

enum CoreType {
  money,
  goals,
  productivity,
  household,
  calendar,
}

class CoreScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final CoreType type;

  const CoreScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.type,
  });

  String get description {
    switch (type) {
      case CoreType.money:
        return 'Expenses, spending patterns and financial intelligence.';
      case CoreType.goals:
        return 'Goals, progress and future planning.';
      case CoreType.productivity:
        return 'Tasks, completion and daily productivity.';
      case CoreType.household:
        return 'Shopping, household requirements and supplies.';
      case CoreType.calendar:
        return 'Bills, renewals, birthdays and important dates.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),

          SafeArea(
            child: ListView(
              padding:
                  const EdgeInsets.all(18),
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: green,
                      size: 25,
                    ),

                    const SizedBox(width: 10),

                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        letterSpacing: 2,
                        fontWeight:
                            FontWeight.w300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Container(
                  padding:
                      const EdgeInsets.all(18),
                  decoration:
                      lifeDecoration(),
                  child: Row(
                    children: [
                      const YansiOrb(
                        size: 80,
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'YANSI ANALYSIS',
                              style: TextStyle(
                                color: green,
                                fontSize: 10,
                                letterSpacing: 2,
                              ),
                            ),

                            const SizedBox(
                              height: 7,
                            ),

                            Text(
                              description,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white60,
                                height: 1.5,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _analysisCard(
                  'TODAY',
                  'Your LifeOS data will appear here.',
                  Icons.today_outlined,
                ),

                _analysisCard(
                  'THIS WEEK',
                  'Yansi will identify patterns and pending items.',
                  Icons.date_range_outlined,
                ),

                _analysisCard(
                  'THIS MONTH',
                  'Monthly intelligence and recommendations.',
                  Icons.insights_outlined,
                ),

                const SizedBox(height: 15),

                LifeButton(
                  text: 'ASK YANSI',
                  icon: Icons.auto_awesome,
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Yansi is ready for your question.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _analysisCard(
    String title,
    String text,
    IconData icon,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      padding:
          const EdgeInsets.all(16),
      decoration:
          lifeDecoration(),
      child: Row(
        children: [
          Icon(
            icon,
            color: cyan,
            size: 22,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: green,
                    fontSize: 9,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
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

class ProfileScreen extends StatelessWidget {
  final String userName;

  const ProfileScreen({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),

          SafeArea(
            child: ListView(
              padding:
                  const EdgeInsets.all(22),
              children: [
                const YansiOrb(size: 100),

                const SizedBox(height: 20),

                const Text(
                  'PROFILE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: cyan,
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(height: 25),

                Container(
                  padding:
                      const EdgeInsets.all(20),
                  decoration:
                      lifeDecoration(),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: green,
                        size: 50,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        userName,
                        style:
                            const TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.w300,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'LifeOS user profile',
                        style: TextStyle(
                          color:
                              Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                LifeButton(
                  text: 'EDIT PROFILE',
                  icon: Icons.edit_outlined,
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Profile editor will be connected in the next build stage.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PERMISSION TILE
// ============================================================

class PermissionTile
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const PermissionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 8),
      decoration:
          lifeDecoration(),
      child: SwitchListTile(
        secondary: Icon(
          icon,
          color: green,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
          ),
        ),
        value: value,
        activeColor: green,
        onChanged: onChanged,
      ),
    );
  }
}

// ============================================================
// BUTTON
// ============================================================

class LifeButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const LifeButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          text,
          style: const TextStyle(
            letterSpacing: 1.5,
          ),
        ),
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFF09202A),
          foregroundColor: green,
          side:
              const BorderSide(
            color: cyan,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FIELD
// ============================================================

class LifeField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const LifeField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white54,
          fontSize: 11,
        ),
        prefixIcon: Icon(
          icon,
          color: green,
        ),
        filled: true,
        fillColor: darkPanel,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: BorderSide(
            color:
                cyan.withOpacity(.20),
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: BorderSide(
            color:
                cyan.withOpacity(.18),
          ),
        ),
        focusedBorder:
            const OutlineInputBorder(
          borderSide:
              BorderSide(color: cyan),
        ),
      ),
    );
  }
}

// ============================================================
// SMALL TOP ICON
// ============================================================

class SmallIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool dot;

  const SmallIcon({
    super.key,
    required this.icon,
    required this.onTap,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 38,
        height: 34,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 32,
                height: 30,
                decoration:
                    BoxDecoration(
                  color: darkPanel,
                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),
                  border: Border.all(
                    color:
                        cyan.withOpacity(.25),
                  ),
                ),
                child: Icon(
                  icon,
                  color: green,
                  size: 18,
                ),
              ),
            ),

            if (dot)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration:
                      const BoxDecoration(
                    color: green,
                    shape:
                        BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
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
            color: green,
            size: size * .34,
          ),
        ),
      ),
    );
  }
}

class YansiPainter
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

    final paint = Paint()
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // NEURAL RINGS
    for (int i = 0; i < 6; i++) {
      paint.color = i.isEven
          ? cyan.withOpacity(.28)
          : green.withOpacity(.18);

      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width:
              radius *
                  (1 + i * .15),
          height:
              radius *
                  (.60 + i * .10),
        ),
        paint,
      );
    }

    // NODES
    final nodePaint = Paint()
      ..color =
          cyan.withOpacity(.75);

    for (int i = 0; i < 14; i++) {
      final angle =
          i * math.pi * 2 / 14;

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
        2,
        nodePaint,
      );

      paint.color =
          cyan.withOpacity(.10);

      canvas.drawLine(
        center,
        point,
        paint,
      );
    }

    // CENTRAL CORE
    final corePaint = Paint()
      ..shader =
          RadialGradient(
        colors: [
          green.withOpacity(.55),
          cyan.withOpacity(.20),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: radius * .55,
        ),
      );

    canvas.drawCircle(
      center,
      radius * .52,
      corePaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

// ============================================================
// NEURAL BACKGROUND
// ============================================================

class NeuralPainter
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

    final paint = Paint()
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = .8
      ..color =
          cyan.withOpacity(.10);

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width:
            size.width * .88,
        height:
            size.height * .62,
      ),
      paint,
    );

    paint.color =
        green.withOpacity(.06);

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width:
            size.width * .62,
        height:
            size.height * .44,
      ),
      paint,
    );

    final nodes = [
      Offset(
        60,
        size.height * .25,
      ),
      Offset(
        size.width - 60,
        size.height * .25,
      ),
      Offset(
        60,
        size.height * .70,
      ),
      Offset(
        size.width - 60,
        size.height * .70,
      ),
      Offset(
        size.width / 2,
        size.height - 30,
      ),
    ];

    for (final node in nodes) {
      paint.color =
          cyan.withOpacity(.08);

      canvas.drawLine(
        center,
        node,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

// ============================================================
// FUTURISTIC BACKGROUND
// ============================================================

class FuturisticBackground
    extends StatelessWidget {
  const FuturisticBackground({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter:
          BackgroundPainter(),
      size: Size.infinite,
    );
  }
}

class BackgroundPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = bg,
    );

    final grid = Paint()
      ..color =
          cyan.withOpacity(.025)
      ..strokeWidth = .6;

    for (
      double x = 0;
      x < size.width;
      x += 36
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
      y += 36
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        grid,
      );
    }

    // HORIZONTAL SCAN LINES
    final scan = Paint()
      ..color =
          green.withOpacity(.015)
      ..strokeWidth = 1;

    for (
      double y = 0;
      y < size.height;
      y += 80
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        scan,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

// ============================================================
// DECORATION
// ============================================================

BoxDecoration lifeDecoration() {
  return BoxDecoration(
    color:
        darkPanel.withOpacity(.82),
    borderRadius:
        BorderRadius.circular(12),
    border: Border.all(
      color:
          cyan.withOpacity(.20),
    ),
    boxShadow: [
      BoxShadow(
        color:
            cyan.withOpacity(.04),
        blurRadius: 18,
        spreadRadius: 1,
      ),
    ],
  );
}
