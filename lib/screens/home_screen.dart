import 'package:flutter/material.dart';

import 'expense_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02070B),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _BackgroundPainter(),
              ),
            ),

            Column(
              children: [
                const SizedBox(height: 25),

                const Icon(
                  Icons.hub_rounded,
                  size: 78,
                  color: Colors.cyanAccent,
                ),

                const SizedBox(height: 8),

                const Text(
                  'LIFEOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 6,
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 330,
                      height: 430,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _core(
                            context,
                            icon: Icons.account_balance_wallet_rounded,
                            angle: -90,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ExpenseScreen(),
                                ),
                              );
                            },
                          ),

                          _core(
                            context,
                            icon: Icons.track_changes_rounded,
                            angle: -18,
                          ),

                          _core(
                            context,
                            icon: Icons.bolt_rounded,
                            angle: 54,
                          ),

                          _core(
                            context,
                            icon: Icons.shopping_cart_rounded,
                            angle: 126,
                          ),

                          _core(
                            context,
                            icon: Icons.calendar_month_rounded,
                            angle: 198,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              left: 15,
              top: 15,
              child: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _core(
    BuildContext context, {
    required IconData icon,
    required double angle,
    VoidCallback? onTap,
  }) {
    return Transform.rotate(
      angle: angle * 3.1415926535 / 180,
      child: Align(
        alignment: Alignment(
          (angle == -90 || angle == 90)
              ? 0
              : angle > 0
                  ? 0.75
                  : -0.75,
          angle == -90
              ? -0.8
              : angle == 198
                  ? 0.7
                  : 0,
        ),
        child: Transform.rotate(
          angle: -angle * 3.1415926535 / 180,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF153C43),
                    Color(0xFF07171D),
                  ],
                ),
                border: Border.all(
                  color: Colors.cyanAccent
                      .withOpacity(0.85),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan
                        .withOpacity(0.25),
                    blurRadius: 25,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: Colors.greenAccent
                        .withOpacity(0.10),
                    blurRadius: 45,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 38,
                color: Colors.cyanAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF061217),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                15,
                24,
                25,
              ),
              child: Text(
                'LIFEOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 5,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(
                Icons.psychology_outlined,
                color: Colors.cyanAccent,
              ),
              title: const Text(
                'Chat with Yansi',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Yansi chat will be connected next.',
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.analytics_outlined,
                color: Colors.cyanAccent,
              ),
              title: const Text(
                'Reports',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.history_rounded,
                color: Colors.cyanAccent,
              ),
              title: const Text(
                'History',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.settings_outlined,
                color: Colors.cyanAccent,
              ),
              title: const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
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
      ..strokeWidth = 0.7
      ..color = Colors.cyan.withOpacity(0.035);

    for (int i = 0; i < 14; i++) {
      final offset = Offset(
        center.dx +
            (i - 7) * 55,
        center.dy -
            100 +
            (i % 4) * 80,
      );

      canvas.drawLine(
        center,
        offset,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _BackgroundPainter oldDelegate,
  ) {
    return false;
  }
}
