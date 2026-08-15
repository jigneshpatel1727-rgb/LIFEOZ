import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lifeoz_core_hub.dart';

class LifeOZDesignHome extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZDesignHome({super.key, required this.prefs});

  @override
  State<LifeOZDesignHome> createState() => _LifeOZDesignHomeState();
}

class _LifeOZDesignHomeState extends State<LifeOZDesignHome> {
  final FlutterTts _tts = FlutterTts();
  int _design = 0;

  static const designs = <String>[
    '01_Oreon_Prime.png',
    '02_Terra_Flux.png',
    '03_Vortex_Nexus.png',
    '04_Crysta_Lumen.png',
    '09_Nebula_Soul-1.png',
    '10_Shadow_Core-1.png',
  ];

  static const names = <String>[
    'OREON PRIME',
    'TERRA FLUX',
    'VORTEX NEXUS',
    'CRYSTA LUMEN',
    'NEBULA SOUL',
    'SHADOW CORE',
  ];

  @override
  void initState() {
    super.initState();
    _design = (widget.prefs.getInt('lifeos_visual_design') ?? 0).clamp(0, 5);
    _tts.setSpeechRate(.44);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _tts.stop();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _say(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _openCore(int index) async {
    const messages = <String>[
      'Financial intelligence is ready.',
      'Goals and growth intelligence is ready.',
      'Productivity intelligence is ready.',
      'Household intelligence is ready.',
      'Personal life intelligence is ready.',
    ];
    await _say(messages[index]);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LifeOZCoreHub(prefs: widget.prefs, coreIndex: index),
      ),
    );
  }

  Future<void> _selectDesign(int index) async {
    await widget.prefs.setInt('lifeos_visual_design', index);
    if (mounted) setState(() => _design = index);
    if (mounted) Navigator.pop(context);
  }

  void _showDesigns() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * .94,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Row(
                  children: [
                    Text('SIX VISUAL REALITIES', style: TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 2)),
                    Spacer(),
                    Text('TAP TO ENTER', style: TextStyle(color: Color(0xFF76FFFF), fontSize: 9, letterSpacing: 1.5)),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: .62,
                  ),
                  itemCount: designs.length,
                  itemBuilder: (_, index) => GestureDetector(
                    onTap: () => _selectDesign(index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(designs[index], fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _controls() => _showDesigns();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, size) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Phase 1 visual surface: the supplied master reality PNG is the artwork.
              // Flutter paints no substitute lines, circles or generic iconography over it.
              Positioned.fill(
                child: Image.asset(
                  designs[_design],
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),

              // Design engine: deliberately invisible interaction surface.
              Positioned(
                top: 0,
                right: 0,
                width: size.maxWidth * .30,
                height: size.maxHeight * .22,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _controls,
                  child: const SizedBox.expand(),
                ),
              ),

              // Yansi is an ambient intelligence hotspot, not a chatbot panel.
              Positioned(
                left: size.maxWidth * .30,
                top: size.maxHeight * .22,
                width: size.maxWidth * .40,
                height: size.maxHeight * .38,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => _say('I am Yansi, your silent LifeOS intelligence.'),
                  child: const SizedBox.expand(),
                ),
              ),

              // Five functional core zones. The PNG supplies the visible graphics.
              _hotspot(size, .22, .36, 0),
              _hotspot(size, .78, .36, 1),
              _hotspot(size, .22, .66, 2),
              _hotspot(size, .78, .66, 3),
              _hotspot(size, .50, .82, 4),
            ],
          );
        },
      ),
    );
  }

  Widget _hotspot(BoxConstraints size, double x, double y, int core) {
    final w = size.maxWidth * .28;
    final h = size.maxHeight * .20;
    return Positioned(
      left: size.maxWidth * x - w / 2,
      top: size.maxHeight * y - h / 2,
      width: w,
      height: h,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _openCore(core),
        child: const SizedBox.expand(),
      ),
    );
  }
}
