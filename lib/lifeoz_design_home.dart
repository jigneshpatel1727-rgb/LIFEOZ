import 'package:flutter/material.dart';
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
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _say(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _openCore(int index) async {
    const messages = <String>[
      'Growth intelligence is ready.',
      'Care and household intelligence is ready.',
      'Prosperity intelligence is ready.',
      'Time and commitment intelligence is ready.',
      'Personal intelligence is ready.',
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
  }

  void _showDesigns() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * .92,
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
              onTap: () async {
                await _selectDesign(index);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Image.asset(
                designs[index],
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _controls() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.black,
      builder: (ctx) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('DESIGN'),
          onTap: () {
            Navigator.pop(ctx);
            _showDesigns();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, size) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // The selected master PNG is the entire visible home surface.
                // Nothing is painted over it, so its graphics remain untouched.
                Center(
                  child: Image.asset(
                    designs[_design],
                    fit: BoxFit.contain,
                    width: size.maxWidth,
                    height: size.maxHeight,
                  ),
                ),

                // Invisible interaction zones only. They add zero pixels to the artwork.
                Positioned(
                  top: 0,
                  right: 0,
                  width: size.maxWidth * .24,
                  height: size.maxHeight * .18,
                  child: GestureDetector(onTap: _controls, child: const SizedBox.expand()),
                ),

                // Yansi / centre hotspot.
                Positioned(
                  left: size.maxWidth * .30,
                  top: size.maxHeight * .27,
                  width: size.maxWidth * .40,
                  height: size.maxHeight * .34,
                  child: GestureDetector(
                    onTap: () => _say('I am Yansi, your silent LifeOS intelligence.'),
                    child: const SizedBox.expand(),
                  ),
                ),

                // Five transparent core hotspots; the PNG itself supplies the graphics.
                _hotspot(size, .20, .38, 0),
                _hotspot(size, .80, .38, 1),
                _hotspot(size, .22, .68, 2),
                _hotspot(size, .78, .68, 3),
                _hotspot(size, .50, .80, 4),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _hotspot(BoxConstraints size, double x, double y, int core) {
    final w = size.maxWidth * .22;
    final h = size.maxHeight * .16;
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
