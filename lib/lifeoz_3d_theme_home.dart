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
  @override
  State<LifeOZ3DThemeHome> createState() => _LifeOZ3DThemeHomeState();
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
    themeIndex = widget.prefs.getInt('lifeoz_theme') ?? 0;
    theme = lifeOZThemes[themeIndex.clamp(0, lifeOZThemes.length - 1)];
    threeJs = three.ThreeJS(onSetupComplete: () { if (mounted) setState(() {}); }, setup: setup3d);
  }

  Future<void> setup3d() async {
    threeJs.camera = three.PerspectiveCamera(48, threeJs.width / threeJs.height, .1, 100);
    threeJs.camera.position.setValues(0, .4, 14.5);
    threeJs.camera.lookAt(three.Vector3(0, 0, 0));
    threeJs.scene = three.Scene();
    threeJs.scene.background = theme.background;
    threeJs.scene.add(three.AmbientLight(theme.secondary, .38));
    final light = three.PointLight(theme.primary, 3.0)..position.setValues(0, 2, 6);
    threeJs.scene.add(light);
    final rim = three.PointLight(theme.secondary, 1.6)..position.setValues(-5, -2, 3);
    threeJs.scene.add(rim);

    final centerMat = three.MeshPhongMaterial.fromMap({'color': theme.primary, 'emissive': theme.primary, 'emissiveIntensity': 2.4, 'shininess': 150, 'transparent': true, 'opacity': .9});
    center = three.Mesh(three.SphereGeometry(1.35, 64, 48), centerMat);
    threeJs.scene.add(center);
    for (var i = 0; i < 4; i++) {
      final ring = three.Mesh(three.TorusGeometry(1.7 + i * .32, .018 + i * .006, 12, 96), three.MeshBasicMaterial.fromMap({'color': i.isEven ? theme.primary : theme.secondary, 'transparent': true, 'opacity': .48 - i * .07}));
      ring.rotation.x = i * .42; ring.rotation.y = .3 + i * .2; center.add(ring);
    }

    groups.clear(); pulses.clear();
    for (var i = 0; i < 5; i++) {
      final g = buildCore(i, theme.coreColors[i], positions[i]);
      groups.add(g); threeJs.scene.add(g);
      final p = three.Mesh(three.SphereGeometry(.07, 10, 8), three.MeshBasicMaterial.fromMap({'color': theme.coreColors[i], 'transparent': true, 'opacity': .9}));
      pulses.add(p); threeJs.scene.add(p);
      addPath(positions[i], theme.coreColors[i]);
    }
    addParticles();
    threeJs.addAnimationEvent((dt) {
      final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
      center.rotation.y += dt * .2;
      final s = 1 + math.sin(t * 2.0) * .045;
      center.scale.setValues(s, s, s);
      for (var i = 0; i < groups.length; i++) {
        final g = groups[i];
        g.rotation.y += dt * (.18 + i * .035);
        g.rotation.z = math.sin(t * .65 + i) * .1;
        final target = activeCore == i ? 1.2 : 1.0;
        final next = g.scale.x + (target - g.scale.x) * math.min(1, dt * 7);
        g.scale.setValues(next, next, next);
        final a = (t * .26 + i * .18) % 1.0;
        final p = positions[i];
        pulses[i].position.setValues(p.x * (1 - a), p.y * (1 - a), .3 + math.sin(t * 2 + i) * .25);
      }
    });
  }

  three.Group buildCore(int i, int color, three.Vector3 pos) {
    final g = three.Group()..position = pos;
    g.add(three.Mesh(three.SphereGeometry(.9, 32, 24), three.MeshPhongMaterial.fromMap({'color': color, 'emissive': color, 'emissiveIntensity': .8, 'transparent': true, 'opacity': .13})));
    g.add(three.Mesh(three.SphereGeometry(.5, 32, 24), three.MeshPhongMaterial.fromMap({'color': color, 'emissive': color, 'emissiveIntensity': 1.8, 'shininess': 120})));
    for (var j = 0; j < 3; j++) {
      final r = three.Mesh(three.TorusGeometry(1.0 + j * .16, .014 + j * .006, 10, 72), three.MeshBasicMaterial.fromMap({'color': color, 'transparent': true, 'opacity': .62 - j * .13}));
      r.rotation.x = .35 + j * .72; r.rotation.z = j * .52; g.add(r);
    }
    final shape = switch (i) {
      0 => three.DodecahedronGeometry(.34, 0),
      1 => three.ConeGeometry(.3, .55, 6),
      2 => three.TorusGeometry(.25, .07, 12, 40),
      3 => three.OctahedronGeometry(.34, 1),
      _ => three.IcosahedronGeometry(.34, 1),
    };
    final icon = three.Mesh(shape, three.MeshPhongMaterial.fromMap({'color': 0xF8FCFF, 'emissive': color, 'emissiveIntensity': 1.7, 'shininess': 150}));
    icon.rotation.x = .4; icon.rotation.y = .5; g.add(icon);
    return g;
  }

  void addPath(three.Vector3 target, int color) {
    final curve = three.CatmullRomCurve3(points: [three.Vector3(0,0,0), three.Vector3(target.x*.42,target.y*.42,1.1), three.Vector3(target.x*.78,target.y*.78,.4), target.clone()]);
    threeJs.scene.add(three.Mesh(three.TubeGeometry(curve, 36, .018, 6, false), three.MeshBasicMaterial.fromMap({'color': color, 'transparent': true, 'opacity': .26})));
  }

  void addParticles() {
    final r = math.Random(7);
    for (var i = 0; i < 80; i++) {
      final a = r.nextDouble() * math.pi * 2, b = math.acos(2*r.nextDouble()-1), d = 6 + r.nextDouble()*8;
      final p = three.Mesh(three.SphereGeometry(.015+r.nextDouble()*.025, 6, 4), three.MeshBasicMaterial.fromMap({'color': theme.secondary, 'transparent': true, 'opacity': .2+r.nextDouble()*.45}));
      p.position.setValues(d*math.sin(b)*math.cos(a), d*math.sin(b)*math.sin(a), d*math.cos(b)); threeJs.scene.add(p);
    }
  }

  Future<void> chooseTheme(int i) async {
    setState(() { themeIndex = i; theme = lifeOZThemes[i]; themeMenu = false; });
    await widget.prefs.setInt('lifeoz_theme', i);
    // Recreate the renderer so lighting, materials and geometry all adopt the selected theme.
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
        _zone(0, Alignment(-.58,-.34)), _zone(1, Alignment(.58,-.34)), _zone(2, Alignment(-.62,.34)), _zone(3, Alignment(.62,.34)), _zone(4, Alignment(0,.74)),
        Positioned(left: 18, right: 18, bottom: 18, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), decoration: BoxDecoration(color: const Color(0xD9071018), borderRadius: BorderRadius.circular(16), border: Border.all(color: Color(theme.primary).withValues(alpha: .25)), boxShadow: [BoxShadow(color: Color(theme.primary).withValues(alpha: .12), blurRadius: 24)]), child: Row(children: [Icon(Icons.auto_awesome, size: 15, color: Color(theme.secondary)), const SizedBox(width: 8), Expanded(child: Text('LifeOS is quietly connecting your life systems.', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 9))), Container(width: 7,height:7,decoration: BoxDecoration(shape: BoxShape.circle,color: Color(theme.secondary),boxShadow:[BoxShadow(color:Color(theme.secondary).withValues(alpha:.65),blurRadius:8)]))]))),
      ])),
    ]),
  );

  Widget _zone(int i, Alignment a) => Align(alignment: a, child: FractionallySizedBox(width: .34, height: .27, child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(60), onTap: () => openCore(i)))));
  Widget _button(IconData icon, VoidCallback onTap) => Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Color(theme.primary).withValues(alpha:.55)), color: const Color(0xB309121A)), child: IconButton(onPressed:onTap, icon:Icon(icon,color:Color(theme.secondary))));
  Widget _themePanel() => Material(color: const Color(0xEE071019), borderRadius: BorderRadius.circular(18), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Choose your LIFEOZ experience', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), const SizedBox(height: 8), Wrap(spacing: 8, runSpacing: 8, children: List.generate(lifeOZThemes.length, (i) { final t=lifeOZThemes[i]; return ChoiceChip(label: Text(t.name), selected: themeIndex==i, onSelected: (_) => chooseTheme(i), selectedColor: Color(t.primary).withValues(alpha:.3), labelStyle: TextStyle(color: themeIndex==i?Color(t.secondary):Colors.white70)); }))])));
}
