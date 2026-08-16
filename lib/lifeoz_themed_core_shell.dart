import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lifeoz_3d_theme_home.dart';
import 'screens/core_report_screen.dart';

class LifeOZThemedCoreShell extends StatefulWidget {
  final SharedPreferences prefs;
  final int coreIndex;
  const LifeOZThemedCoreShell({super.key, required this.prefs, required this.coreIndex});
  @override State<LifeOZThemedCoreShell> createState() => _LifeOZThemedCoreShellState();
}

class _LifeOZThemedCoreShellState extends State<LifeOZThemedCoreShell> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late int themeIndex;
  late LifeOZTheme theme;
  static const coreNames = ['Financial Life','Goals & Growth','Productivity','Household','Life'];
  static const coreGlyphs = ['◈','✦','⬢','◇','◉'];

  @override void initState() {
    super.initState();
    themeIndex = (widget.prefs.getInt('lifeoz_theme') ?? 0).clamp(0, lifeOZThemes.length - 1);
    theme = lifeOZThemes[themeIndex];
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }
  @override void dispose() { _pulse.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final accent = Color(theme.primary);
    final glow = Color(theme.secondary);
    return Scaffold(
      backgroundColor: Color(theme.background),
      body: Stack(children: [
        AnimatedBuilder(animation: _pulse, builder: (_, __) => CustomPaint(size: Size.infinite, painter: _ThemeCorePainter(accent, glow, _pulse.value, widget.coreIndex))),
        SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(14, 10, 14, 4), child: Row(children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back_ios_new, color: glow, size: 18)),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(coreNames[widget.coreIndex], style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 1.1)),
              Text('${theme.name} • REALTIME INTELLIGENCE', style: TextStyle(color: glow.withOpacity(.72), fontSize: 8, letterSpacing: 1.5)),
            ])),
            Text(coreGlyphs[widget.coreIndex], style: TextStyle(color: glow, fontSize: 26, shadows: [Shadow(color: glow, blurRadius: 14)])),
          ])),
          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(26)), child: Theme(data: Theme.of(context).copyWith(colorScheme: Theme.of(context).colorScheme.copyWith(primary: accent, secondary: glow)), child: CoreReportScreen(core: widget.coreIndex, currency: _currency(widget.prefs)))),
        ])),
      ]),
    );
  }

  String _currency(SharedPreferences p) => (p.getString('currency')?.trim().isNotEmpty ?? false) ? p.getString('currency')!.trim() : '₹';
}

class _ThemeCorePainter extends CustomPainter {
  final Color a, b; final double t; final int core;
  _ThemeCorePainter(this.a, this.b, this.t, this.core);
  @override void paint(Canvas c, Size s) {
    final center = Offset(s.width/2, s.height*.22);
    final p = Paint()..style=PaintingStyle.stroke..strokeWidth=1;
    for (var i=0;i<5;i++) {
      final r = 55.0 + i*28 + math.sin(t*math.pi*2+i)*5;
      p.color = (i==core ? b : a).withOpacity(.12-(i*.014));
      c.drawCircle(center, r, p);
    }
    final glow = Paint()..shader=RadialGradient(colors:[b.withOpacity(.22),a.withOpacity(.06),Colors.transparent]).createShader(Rect.fromCircle(center:center,radius:125));
    c.drawCircle(center,125,glow);
    for (var i=0;i<7;i++) {
      final ang=t*math.pi*2*(i.isEven?1:-.7)+i*.9;
      final r=85+i*18.0;
      final dot=Offset(center.dx+math.cos(ang)*r,center.dy+math.sin(ang)*r*.45);
      c.drawCircle(dot,2.2+(i==core?2:0),Paint()..color=(i==core?b:a).withOpacity(.55));
    }
  }
  @override bool shouldRepaint(covariant _ThemeCorePainter old) => old.t!=t || old.a!=a || old.b!=b || old.core!=core;
}
