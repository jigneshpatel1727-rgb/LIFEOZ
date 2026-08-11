import 'package:flutter/material.dart';

void main() {
  runApp(const LifeOSApp());
}

class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeOS',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF06131A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5A0),
          brightness: Brightness.dark,
        ),
      ),
      home: const LifeOSHome(),
    );
  }
}

class LifeOSHome extends StatefulWidget {
  const LifeOSHome({super.key});

  @override
  State<LifeOSHome> createState() => _LifeOSHomeState();
}

class _LifeOSHomeState extends State<LifeOSHome> {
  bool menuOpen = false;

  final List<Map<String, dynamic>> cores = [
    {
      'icon': Icons.account_balance_wallet_rounded,
      'title': 'Money',
    },
    {
      'icon': Icons.favorite_rounded,
      'title': 'Health',
    },
    {
      'icon': Icons.work_rounded,
      'title': 'Work',
    },
    {
      'icon': Icons.home_rounded,
      'title': 'Home',
    },
    {
      'icon': Icons.track_changes_rounded,
      'title': 'Goals',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background glow
            Positioned(
              top: -100,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E5A0).withOpacity(0.08),
                ),
              ),
            ),

            Column(
              children: [
                // TOP BAR
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            menuOpen = !menuOpen;
                          });
                        },
                        icon: Icon(
                          menuOpen
                              ? Icons.close_rounded
                              : Icons.menu_rounded,
                          color: const Color(0xFF00E5A0),
                          size: 30,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'LifeOS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // YANSI
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Yansi visual
                        Container(
                          width: 145,
                          height: 145,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF00E5A0),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5A0)
                                    .withOpacity(0.35),
                                blurRadius: 35,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              size: 65,
                              color: Color(0xFF00E5A0),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        const Text(
                          'Yansi',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00E5A0),
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Your LifeOS AI',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Greeting
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFF00E5A0)
                                  .withOpacity(0.25),
                            ),
                            color: const Color(0xFF0B2028),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'Hello 👋',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'I am Yansi. Tell me what is happening in your life.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Voice button
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Voice assistant will be connected next.',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF00E5A0),
                                  Color(0xFF00AFC4),
                                ],
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.mic_rounded,
                                  color: Colors.black,
                                  size: 27,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Talk to Yansi',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          'Your Life at a Glance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        // 5 core icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: cores.map((core) {
                            return _coreIcon(
                              core['icon'],
                              core['title'],
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // DROPDOWN MENU
            if (menuOpen)
              Positioned(
                top: 68,
                left: 12,
                child: Container(
                  width: 230,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B2028),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF00E5A0).withOpacity(0.4),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    children: cores.map((core) {
                      return ListTile(
                        leading: Icon(
                          core['icon'],
                          color: const Color(0xFF00E5A0),
                        ),
                        title: Text(
                          core['title'],
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            menuOpen = false;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _coreIcon(IconData icon, String title) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0B2028),
          border: Border.all(
            color: const Color(0xFF00E5A0).withOpacity(0.45),
          ),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF00E5A0),
          size: 25,
        ),
      ),
    );
  }
}
