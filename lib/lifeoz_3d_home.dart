import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_js/three_js.dart' as three;

import 'lifeoz_core_hub.dart';

class LifeOZ3DHome extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZ3DHome({super.key, required this.prefs});

  @override
  State<LifeOZ3DHome> createState() => _LifeOZ3DHomeState();
}

class _LifeOZ3DHomeState extends State<LifeOZ3DHome> {
  late final three.ThreeJS _three;
  final FlutterTts _tts = FlutterTts();
  int _activeCore = -1;
  bool _menuOpen = false;
  bool _ready = false;
  late List<three.Group> _coreGroups;
  late three.Mesh _yansi;
  late three.Group _yansiRig;
  late List<three.Mesh> _energy;
  late List<three.Vector3> _corePositions;

  static const _colors = <int>[
    0xFFFFB84D,
    0xFF55F2A0,
    0xFF24D9FF,
    0xFFB56CFF,
    0xFFFF5D8D,
  ];

  static const _messages = <String>[
    'Financial intelligence is ready.',
    'Goals and growth intelligence is ready.',
    'Productivity intelligence is ready.',
    'Household intelligence is ready.',
    'Personal life intelligence is ready.',
  ];

  @override
  void initState() {
    super.initState();
    _tts.setSpeechRate(0.44);
    _three = three.ThreeJS(
      onSetupComplete: () {
        if (mounted) setState(() => _ready = true);
      },
      setup: _setup3D,
    );
  }

  Future<void> _setup3D() async {
    _three.camera = three.PerspectiveCamera(
      48,
      _three.width / _three.height,
      0.1,
      100,
    );
    _three.camera.position.setValues(0, 0.5, 14.5);
    _three.camera.lookAt(three.Vector3(0, 0, 0));

    _three.scene = three.Scene();
    _three.scene.background = 0x01050D;

    _three.scene.add(three.AmbientLight(0x16304A, 0.42));

    final keyLight = three.PointLight(0x67DFFF, 2.4);
    keyLight.position.setValues(0, 2, 6);
    _three.scene.add(keyLight);

    final warmLight = three.PointLight(0xFFB84D, 1.25);
    warmLight.position.setValues(-6, 4, 2);
    _three.scene.add(warmLight);

    final violetLight = three.PointLight(0x9E6CFF, 1.2);
    violetLight.position.setValues(6, -3, 1);
    _three.scene.add(violetLight);

    _corePositions = <three.Vector3>[
      three.Vector3(-4.0, 2.6, 0.2),
      three.Vector3(4.0, 2.6, 0.2),
      three.Vector3(-4.1, -2.6, 0.1),
      three.Vector3(4.1, -2.6, 0.1),
      three.Vector3(0, -4.7, 0.15),
    ];

    _yansiRig = three.Group();
    _three.scene.add(_yansiRig);

    final yansiMaterial = three.MeshPhongMaterial.fromMap({
      'color': 0x168BFF,
      'emissive': 0x006DFF,
      'emissiveIntensity': 2.7,
      'shininess': 120,
      'transparent': true,
      'opacity': 0.92,
    });
    _yansi = three.Mesh(three.SphereGeometry(1.38, 64, 48), yansiMaterial);
    _yansiRig.add(_yansi);

    for (var i = 0; i < 4; i++) {
      final ring = three.Mesh(
        three.TorusGeometry(1.75 + i * 0.34, 0.018 + i * 0.008, 12, 96),
        three.MeshBasicMaterial.fromMap({
          'color': i.isEven ? 0x37E7FF : 0x8A62FF,
          'transparent': true,
          'opacity': 0.56 - i * 0.07,
        }),
      );
      ring.rotation.x = i * 0.45;
      ring.rotation.y = 0.35 + i * 0.2;
      _yansiRig.add(ring);
    }

    for (var i = 0; i < 3; i++) {
      final shell = three.Mesh(
        three.SphereGeometry(1.75 + i * 0.23, 32, 24),
        three.MeshBasicMaterial.fromMap({
          'color': 0x19BFFF,
          'transparent': true,
          'opacity': 0.035 - i * 0.007,
          'depthWrite': false,
        }),
      );
      _yansiRig.add(shell);
    }

    _coreGroups = [];
    for (var i = 0; i < 5; i++) {
      final group = _buildCore(i, _colors[i], _corePositions[i]);
      _coreGroups.add(group);
      _three.scene.add(group);
      _addEnergyPath(_corePositions[i], i);
    }

    _energy = [];
    for (var i = 0; i < 5; i++) {
      final dot = three.Mesh(
        three.SphereGeometry(0.075, 12, 8),
        three.MeshBasicMaterial.fromMap({
          'color': _colors[i],
          'emissive': _colors[i],
          'emissiveIntensity': 3,
        }),
      );
      _energy.add(dot);
      _three.scene.add(dot);
    }

    _addParticleField();

    _three.addAnimationEvent((dt) {
      final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
      _yansiRig.rotation.y += dt * 0.17;
      _yansiRig.rotation.x = math.sin(time * 0.45) * 0.05;
      final pulse = 1.0 + math.sin(time * 2.0) * 0.045;
      _yansi.scale.setValues(pulse, pulse, pulse);

      for (var i = 0; i < _coreGroups.length; i++) {
        final g = _coreGroups[i];
        g.rotation.y += dt * (0.22 + i * 0.035);
        g.rotation.z = math.sin(time * 0.7 + i) * 0.12;
        final target = _activeCore == i ? 1.22 : 1.0;
        final current = g.scale.x;
        final next = current + (target - current) * math.min(1, dt * 7);
        g.scale.setValues(next, next, next);

        final a = (time * 0.32 + i * 0.19) % 1.0;
        final p = _corePositions[i];
        _energy[i].position.setValues(
          p.x * (1 - a),
          p.y * (1 - a),
          p.z * (1 - a) + math.sin(time * 2 + i) * 0.35,
        );
      }
    });
  }

  three.Group _buildCore(int index, int color, three.Vector3 position) {
    final group = three.Group();
    group.position = position;

    final outer = three.Mesh(
      three.SphereGeometry(0.92, 32, 24),
      three.MeshPhongMaterial.fromMap({
        'color': color,
        'emissive': color,
        'emissiveIntensity': 1.15,
        'transparent': true,
        'opacity': 0.18,
        'shininess': 80,
      }),
    );
    group.add(outer);

    final orb = three.Mesh(
      three.SphereGeometry(0.55, 32, 24),
      three.MeshPhongMaterial.fromMap({
        'color': color,
        'emissive': color,
        'emissiveIntensity': 2.0,
        'shininess': 130,
      }),
    );
    group.add(orb);

    for (var j = 0; j < 3; j++) {
      final ring = three.Mesh(
        three.TorusGeometry(1.0 + j * 0.17, 0.015 + j * 0.006, 10, 72),
        three.MeshBasicMaterial.fromMap({
          'color': color,
          'transparent': true,
          'opacity': 0.66 - j * 0.13,
        }),
      );
      ring.rotation.x = j * 0.8 + 0.35;
      ring.rotation.z = j * 0.55;
      group.add(ring);
    }

    final coreShape = index == 0
        ? three.BoxGeometry(0.34, 0.34, 0.34)
        : index == 1
            ? three.TorusGeometry(0.26, 0.07, 12, 40)
            : index == 2
                ? three.ConeGeometry(0.25, 0.55, 6)
                : index == 3
                    ? three.OctahedronGeometry(0.34, 1)
                    : three.IcosahedronGeometry(0.34, 1);
    final iconMesh = three.Mesh(
      coreShape,
      three.MeshPhongMaterial.fromMap({
        'color': 0xF8FCFF,
        'emissive': color,
        'emissiveIntensity': 1.8,
        'shininess': 150,
      }),
    );
    iconMesh.rotation.x = 0.35;
    iconMesh.rotation.y = 0.55;
    group.add(iconMesh);

    return group;
  }

  void _addEnergyPath(three.Vector3 target, int index) {
    final curve = three.CatmullRomCurve3(
      points: <three.Vector3>[
        three.Vector3(0, 0, 0),
        three.Vector3(target.x * 0.42, target.y * 0.42, 1.2),
        three.Vector3(target.x * 0.78, target.y * 0.78, 0.45),
        target.clone(),
      ],
    );
    final geometry = three.TubeGeometry(curve, 36, 0.018, 6, false);
    final material = three.MeshBasicMaterial.fromMap({
      'color': _colors[index],
      'transparent': true,
      'opacity': 0.28,
    });
    _three.scene.add(three.Mesh(geometry, material));
  }

  void _addParticleField() {
    final random = math.Random(42);
    for (var i = 0; i < 90; i++) {
      final theta = random.nextDouble() * math.pi * 2;
      final phi = math.acos(2 * random.nextDouble() - 1);
      final radius = 6.0 + random.nextDouble() * 8.0;
      final p = three.Mesh(
        three.SphereGeometry(0.018 + random.nextDouble() * 0.035, 6, 4),
        three.MeshBasicMaterial.fromMap({
          'color': i % 5 == 0 ? 0xB46CFF : 0x45DFFF,
          'transparent': true,
          'opacity': 0.28 + random.nextDouble() * 0.5,
        }),
      );
      p.position.setValues(
        radius * math.sin(phi) * math.cos(theta),
        radius * math.sin(phi) * math.sin(theta),
        radius * math.cos(phi),
      );
      _three.scene.add(p);
    }
  }

  Future<void> _welcome() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    await _speak('Welcome to LifeOS. I am Yansi, your personal AI. I am here whenever you need me.');
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _selectCore(int index) async {
    setState(() => _activeCore = index);
    await _speak(_messages[index]);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LifeOZCoreHub(prefs: widget.prefs, coreIndex: index),
      ),
    );
    if (mounted) setState(() => _activeCore = -1);
  }

  @override
  void dispose() {
    _three.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01050D),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _three.build(),
          SafeArea(
            child: Stack(
              children: [
                const Positioned(
                  top: 18,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: Text(
                        'L I F E O S',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          letterSpacing: 5.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 12,
                  child: _glassButton(
                    Icons.menu_rounded,
                    () => setState(() => _menuOpen = !_menuOpen),
                  ),
                ),
                if (_menuOpen) Positioned(top: 58, left: 12, child: _menu()),
                _tapZone(0, const Alignment(-0.58, -0.34)),
                _tapZone(1, const Alignment(0.58, -0.34)),
                _tapZone(2, const Alignment(-0.62, 0.34)),
                _tapZone(3, const Alignment(0.62, 0.34)),
                _tapZone(4, const Alignment(0.0, 0.74)),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0xD607111B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x3300E5FF)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x3300CFFF), blurRadius: 22),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 15, color: Color(0xFF59FF9A)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _activeCore < 0
                                ? 'Yansi is quietly connecting your life systems.'
                                : _messages[_activeCore],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white60, fontSize: 9),
                          ),
                        ),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _ready ? const Color(0xFF59FF9A) : Colors.orange,
                            boxShadow: [
                              BoxShadow(
                                color: _ready ? const Color(0xFF59FF9A) : Colors.orange,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tapZone(int index, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SizedBox(
          width: 120,
          height: 120,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _selectCore(index),
          ),
        ),
      ),
    );
  }

  Widget _glassButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xB5081118),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x6600E5FF)),
          boxShadow: const [BoxShadow(color: Color(0x3300E5FF), blurRadius: 18)],
        ),
        child: const Icon(Icons.menu_rounded, size: 21, color: Color(0xFF70FFD0)),
      ),
    );
  }

  Widget _menu() {
    return Container(
      width: 225,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xF008121A),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0x6600E5FF)),
        boxShadow: const [BoxShadow(color: Color(0x4400E5FF), blurRadius: 28)],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LIFE CONTROL', style: TextStyle(color: Color(0xFF76FFFF), fontSize: 9, letterSpacing: 2)),
          SizedBox(height: 9),
          Text('YANSI INTELLIGENCE', style: TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1)),
          SizedBox(height: 12),
          Text('LIFE REPORT', style: TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1)),
          SizedBox(height: 12),
          Text('PRIVACY', style: TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1)),
          SizedBox(height: 12),
          Text('SETTINGS', style: TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 1)),
        ],
      ),
    );
  }
}
