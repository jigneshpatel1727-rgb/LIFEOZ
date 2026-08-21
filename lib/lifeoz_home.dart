import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lifeoz_core_hub.dart';

class LifeOZHome extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZHome({super.key, required this.prefs});

  @override
  State<LifeOZHome> createState() => _LifeOZHomeState();
}

class _LifeOZHomeState extends State<LifeOZHome>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  static const _cores = <_CoreInfo>[
    _CoreInfo('Expenses', Icons.account_balance_wallet_rounded, Color(0xFF55D9FF)),
    _CoreInfo('Tasks', Icons.check_circle_outline_rounded, Color(0xFF72E8C1)),
    _CoreInfo('Calendar', Icons.event_rounded, Color(0xFFB58CFF)),
    _CoreInfo('Household', Icons.shopping_basket_rounded, Color(0xFFFFC857)),
    _CoreInfo('Diary', Icons.menu_book_rounded, Color(0xFFFF8F9C)),
  ];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _openCore(int index) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LifeOZCoreHub(
          prefs: widget.prefs,
          coreIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020A18),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  Text(
                    'ALLINMYDAY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.6,
                    ),
                  ),
                  Spacer(),
                  _StatusDot(),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 620;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        SizedBox(height: compact ? 18 : 38),
                        AnimatedBuilder(
                          animation: _pulse,
                          builder: (context, _) => _YansiCore(
                            pulse: _pulse.value,
                          ),
                        ),
                        SizedBox(height: compact ? 22 : 38),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _cores.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.55,
                          ),
                          itemBuilder: (context, index) => _CoreCard(
                            core: _cores[index],
                            onTap: () => _openCore(index),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'ONE SCREEN  •  ONE TAP  •  ONE REPORT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 9,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xD9071018),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x3355D9FF)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 15, color: Color(0xFF72E8FF)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Yansi is quietly ready.',
                      style: TextStyle(color: Colors.white60, fontSize: 10),
                    ),
                  ),
                  Text('READY', style: TextStyle(color: Color(0xFF72E8C1), fontSize: 9, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoreInfo {
  final String title;
  final IconData icon;
  final Color color;
  const _CoreInfo(this.title, this.icon, this.color);
}

class _StatusDot extends StatelessWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context) => Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: const Color(0xFF72E8C1),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF72E8C1).withValues(alpha: .65),
              blurRadius: 10,
            ),
          ],
        ),
      );
}

class _YansiCore extends StatelessWidget {
  final double pulse;
  const _YansiCore({required this.pulse});

  @override
  Widget build(BuildContext context) {
    final glow = 38 + pulse * 16;
    return Column(
      children: [
        SizedBox(
          width: 190,
          height: 190,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: glow * 2.2,
                height: glow * 2.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF20CFFF).withValues(alpha: .035),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF20CFFF).withValues(alpha: .24),
                      blurRadius: 50 + pulse * 18,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
              Container(
                width: 112 + pulse * 8,
                height: 112 + pulse * 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFF7FFFF), Color(0xFF35D9FF), Color(0xFF073B64)],
                    stops: [0, .22, 1],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF35D9FF).withValues(alpha: .48),
                      blurRadius: 32,
                    ),
                  ],
                ),
              ),
              Container(
                width: 148,
                height: 148,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF72E8FF).withValues(alpha: .30),
                    width: 1.2,
                  ),
                ),
              ),
              const Text(
                'YANSI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  letterSpacing: 3.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ambient intelligence • ready when needed',
          style: TextStyle(color: Colors.white38, fontSize: 9),
        ),
      ],
    );
  }
}

class _CoreCard extends StatelessWidget {
  final _CoreInfo core;
  final VoidCallback onTap;
  const _CoreCard({required this.core, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xB309121A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: core.color.withValues(alpha: .22)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(core.icon, color: core.color, size: 23),
                  const SizedBox(height: 8),
                  Text(
                    core.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Open report',
                    style: TextStyle(color: Colors.white38, fontSize: 9),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
