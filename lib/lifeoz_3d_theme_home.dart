import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_js/three_js.dart' as three;

import 'lifeoz_core_hub.dart';

class LifeOZTheme {
  final String name;
  final int primary;
  final int secondary;
  final int background;
  final List<int> coreColors;
  const LifeOZTheme(this.name, this.primary, this.secondary, this.background, this.coreColors);
}

const lifeOZThemes = <LifeOZTheme>[
  LifeOZTheme('Ocean Blue', 0xFF2EA8FF, 0xFF72E8FF, 0xFF020A18, [0xFF4CC9FF, 0xFF62E8C1, 0xFF76A7FF, 0xFFB58CFF, 0xFF61D9FF]),
  LifeOZTheme('Forest Green', 0xFF42D68B, 0xFFA5F28A, 0xFF03100A, [0xFF65E68C, 0xFF9BE15D, 0xFF54D9B0, 0xFFB8E986, 0xFF75C9A8]),
  LifeOZTheme('Amber Gold', 0xFFFFC857, 0xFFFFE4A0, 0xFF100B03, [0xFFFFC857, 0xFFFFE08A, 0xFFFFB347, 0xFFFFD166, 0xFFFFE7A8]),
  LifeOZTheme('Violet Purple', 0xFFA66CFF, 0xFFE0B3FF, 0xFF0A0314, [0xFFB983FF, 0xFFDA7BFF, 0xFF8E9EFF, 0xFFE1A1FF, 0xFFAF9CFF]),
  LifeOZTheme('Coral Peach', 0xFFFF806E, 0xFFFFC29E, 0xFF120504, [0xFFFF8A76, 0xFFFFB36B, 0xFFFF9D9D, 0xFFFFC47A, 0xFFFFA7B5]),
  LifeOZTheme('Graphite Gray', 0xFFBFC9D4, 0xFFEAF4FF, 0xFF05080C, [0xFFDCE8F2, 0xFFAEC8D9, 0xFFEEF6FF, 0xFFC7BDE8, 0xFFB8D6E8]),
];

class LifeOZ3DThemeHome extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZ3DThemeHome({super.key, required this.prefs});
  @override State<LifeOZ3DThemeHome> createState() => _LifeOZ3DThemeHomeState();
}

class _LifeOZ3DThemeHomeState extends State<LifeOZ3DThemeHome> {
  late three.ThreeJS threeJs;
  int themeIndex = 0;
  int activeCore = -1;
  bool themeMenu = false;
  late LifeOZTheme theme;
  final positions = <three.Vector3>[
    three.Vector3(-4.0, 2.8, 0), three.Vector3(4.0, 2.8, 0),
    three.Vector3(-4.0, -2.5, 0), three.Vector3(4.0, -2.5, 0),
    three.Vector3(0, -4.7, 0),
  ];
  final List<three.Group> groups = [];
  final List<three.Mesh> pulses = [];
  late three.Mesh center;

  @override
  void initState() {
    super.initState();
    themeIndex = (widget.prefs.getInt('lifeoz_theme') ?? 0).clamp(0, lifeOZThemes.length - 1);
    theme = lifeOZThemes[themeIndex];
    threeJs = three.ThreeJS(onSetupComplete: () { if (mounted) setState(() {}); }, setup: setup3d);
  }

  Future<void> setup3d() async {
    threeJs.camera = three.PerspectiveCamera(45, threeJs.width / threeJs.height, .05, 120);
    threeJs.camera.position.setValues(0, .35, 15.5);
    threeJs.camera.lookAt(three.Vector3(0, 0, 0));
    threeJs.scene = three.Scene();
    threeJs.scene.background = theme.background;
    threeJs.scene.add(three.AmbientLight(theme.secondary, .42));
    final light = three.PointLight(theme.primary, 3.4)..position.setValues(0, 2.5, 6);
    threeJs.scene.add(light);
    final rim = three.PointLight(theme.secondary, 2.0)..position.setValues(-5, -3, 3);
    threeJs.scene.add(rim);

    final centerMat = three.MeshPhongMaterial.fromMap({'color': theme.primary, 'emissive': theme.primary, 'emissiveIntensity': 2.8, 'shininess': 180, 'transparent': true, 'opacity': .94});
    center = three.Mesh(three.SphereGeometry(1.35, 72, 56), centerMat);
    threeJs.scene.add(center);

    // Layered transparent shells create a volumetric energy-core effect instead of a flat orb.
    final shell1 = three.Mesh(three.SphereGeometry(1.62, 48, 36), three.MeshPhongMaterial.fromMap({'color': theme.secondary, 'emissive': theme.primary, 'emissiveIntensity': 1.2, 'transparent': true, 'opacity': .10, 'side': 2}));
    final shell2 = three.Mesh(three.SphereGeometry(2.02, 40, 32), three.MeshBasicMaterial.fromMap({'color': theme.secondary, 'transparent': true, 'opacity': .045, 'side': 2}));
    center.add(shell1);
    center.add(shell2);

    for (var i = 0; i < 5; i++) {
      final ring = three.Mesh(three.TorusGeometry(1.62 + i * .34, .018 + i * .006, 14, 112), three.MeshBasicMaterial.fromMap({'color': i.isEven ? theme.primary : theme.secondary, 'transparent': true, 'opacity': .50 - i * .065}));
      ring.rotation.x = i * .42;
      ring.rotation.y = .3 + i * .2;
      center.add(ring);
    }

    groups.clear();
    pulses.clear();
    for (var i = 0; i < 5; i++) {
      final g = buildCore(i, theme.coreColors[i], positions[i]);
      groups.add(g);
      threeJs.scene.add(g);
      final p = three.Mesh(three.SphereGeometry(.075, 12, 10), three.MeshBasicMaterial.fromMap({'color': theme.coreColors[i], 'transparent': true, 'opacity': .95}));
      pulses.add(p);
      threeJs.scene.add(p);
      addPath(positions[i], theme.coreColors[i]);
    }
    addParticles();
    threeJs.addAnimationEvent((dt) {
      final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
      center.rotation.y += dt * .23;
      center.rotation.x = math.sin(t * .32) * .055;
      final s = 1 + math.sin(t * 2.2) * .05;
      center.scale.setValues(s, s, s);

      // Subtle camera breathing gives the scene depth without turning it into a video.
      threeJs.camera.position.x = math.sin(t * .16) * .28;
      threeJs.camera.position.y = .35 + math.sin(t * .21) * .18;
      threeJs.camera.position.z = 15.5 + math.sin(t * .13) * .28;
      threeJs.camera.lookAt(three.Vector3(0, 0, 0));

      for (var i = 0; i < groups.length; i++) {
        final g = groups[i];
        g.rotation.y += dt * (.20 + i * .04);
        g.rotation.z = math.sin(t * .70 + i) * .12;
        final target = activeCore == i ? 1.24 : 1.0;
        final next = g.scale.x + (target - g.scale.x) * math.min(1, dt * 7);
        g.scale.setValues(next, next, next);
        final a = (t * (.28 + i * .012) + i * .18) % 1.0;
        final p = positions[i];
        pulses[i].position.setValues(p.x * (1 - a), p.y * (1 - a), .35 + math.sin(t * 2 + i) * .3);
      }
    });
  }

  three.Group buildCore(int i, int color, three.Vector3 pos) {
    final g = three.Group()..position = pos;
    g.add(three.Mesh(three.SphereGeometry(1.0, 36, 28), three.MeshPhongMaterial.fromMap({'color': color, 'emissive': color, 'emissiveIntensity': .9, 'transparent': true, 'opacity': .15, 'side': 2})));
    g.add(three.Mesh(three.SphereGeometry(.52, 36, 28), three.MeshPhongMaterial.fromMap({'color': color, 'emissive': color, 'emissiveIntensity': 2.0, 'shininess': 150})));
    for (var j = 0; j < 4; j++) {
      final r = three.Mesh(three.TorusGeometry(1.02 + j * .17, .014 + j * .006, 12, 84), three.MeshBasicMaterial.fromMap({'color': color, 'transparent': true, 'opacity': .64 - j * .12}));
      r.rotation.x = .35 + j * .72;
      r.rotation.z = j * .52;
      g.add(r);
    }
    final shape = switch (i) {
      0 => three.DodecahedronGeometry(.34, 0),
      1 => three.ConeGeometry(.3, .58, 6),
      2 => three.TorusGeometry(.25, .07, 12, 40),
      3 => three.OctahedronGeometry(.34, 1),
      _ => three.IcosahedronGeometry(.34, 1),
    };
    final icon = three.Mesh(shape, three.MeshPhongMaterial.fromMap({'color': 0xF8FCFF, 'emissive': color, 'emissiveIntensity': 1.8, 'shininess': 170}));
    icon.rotation.x = .4;
    icon.rotation.y = .5;
    g.add(icon);
    return g;
  }

  void addPath(three.Vector3 target, int color) {
    final curve = three.CatmullRomCurve3(points: [three.Vector3(0, 0, 0), three.Vector3(target.x * .42, target.y * .42, 1.35), three.Vector3(target.x * .78, target.y * .78, .45), target.clone()]);
    threeJs.scene.add(three.Mesh(three.TubeGeometry(curve, 42, .020, 7, false), three.MeshBasicMaterial.fromMap({'color': color, 'transparent': true, 'opacity': .28})));
  }

  void addParticles() {
    final r = math.Random(7);
    for (var i = 0; i < 110; i++) {
      final a = r.nextDouble() * math.pi * 2;
      final b = math.acos(2 * r.nextDouble() - 1);
      final d = 5.5 + r.nextDouble() * 10;
      final p = three.Mesh(three.SphereGeometry(.012 + r.nextDouble() * .032, 7, 5), three.MeshBasicMaterial.fromMap({'color': i.isEven ? theme.secondary : theme.primary, 'transparent': true, 'opacity': .18 + r.nextDouble() * .5}));
      p.position.setValues(d * math.sin(b) * math.cos(a), d * math.sin(b) * math.sin(a), d * math.cos(b));
      threeJs.scene.add(p);
    }
  }

  Future<void> chooseTheme(int i) async {
    setState(() { themeIndex = i; theme = lifeOZThemes[i]; themeMenu = false; });
    await widget.prefs.setInt('lifeoz_theme', i);
    threeJs.dispose();
    threeJs = three.ThreeJS(onSetupComplete: () { if (mounted) setState(() {}); }, setup: setup3d);
  }

  Future<void> openCore(int i) async {
    setState(() => activeCore = i);
    if (!mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => LifeOZCoreHub(prefs: widget.prefs, coreIndex: i)));
    if (mounted) setState(() => activeCore = -1);
  }

  @override
  void dispose() { threeJs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Color(theme.background),
    body: Stack(children: [
      threeJs.build(),
      SafeArea(child: Stack(children: [
        const Positioned(top: 18, left: 0, right: 0, child: Center(child: Text('L I F E O Z', style: TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 5.5, fontWeight: FontWeight.w500)))),
        Positioned(top: 9, left: 12, child: _button(Icons.menu_rounded, () => setState(() => themeMenu = !themeMenu))),
        if (themeMenu) Positioned(top: 58, left: 12, right: 12, child: _themePanel()),
        _zone(0, const Alignment(-.58, -.34)),
        _zone(1, const Alignment(.58, -.34)),
        _zone(2, const Alignment(-.62, .34)),
        _zone(3, const Alignment(.62, .34)),
        _zone(4, const Alignment(0, .74)),
        Positioned(left: 18, right: 18, bottom: 18, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), decoration: BoxDecoration(color: const Color(0xD9071018), borderRadius: BorderRadius.circular(16), border: Border.all(color: Color(theme.primary).withValues(alpha: .25)), boxShadow: [BoxShadow(color: Color(theme.primary).withValues(alpha: .12), blurRadius: 24)]), child: Row(children: [Icon(Icons.auto_awesome, size: 15, color: Color(theme.secondary)), const SizedBox(width: 8), Expanded(child: Text('LifeOS is quietly connecting your life systems.', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 9))), Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: Color(theme.secondary), boxShadow: [BoxShadow(color: Color(theme.secondary).withValues(alpha: .65), blurRadius: 8)]))]))),
      ])),
    ]),
  );

  Widget _zone(int i, Alignment a) => Align(alignment: a, child: Container(constraints: const BoxConstraints.tightFor(width: 140, height: 120), child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(60), onTap: () => openCore(i)))));

  Widget _button(IconData icon, VoidCallback onTap) => Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Color(theme.primary).withValues(alpha: .55)), color: const Color(0xB309121A)), child: IconButton(onPressed: onTap, icon: Icon(icon, color: Color(theme.secondary))));

  Widget _themePanel() => Material(color: const Color(0xEE071019), borderRadius: BorderRadius.circular(18), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Choose your LIFEOZ experience', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), const SizedBox(height: 8), Wrap(spacing: 8, runSpacing: 8, children: List.generate(lifeOZThemes.length, (i) { final t = lifeOZThemes[i]; return ChoiceChip(label: Text(t.name), selected: themeIndex == i, onSelected: (_) => chooseTheme(i), selectedColor: Color(t.primary).withValues(alpha: .3), labelStyle: TextStyle(color: themeIndex == i ? Color(t.secondary) : Colors.white70)); }))])));
}
