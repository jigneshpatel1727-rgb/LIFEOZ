import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LifeOZExactMasterHome extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZExactMasterHome({super.key, required this.prefs});
  @override State<LifeOZExactMasterHome> createState() => _LifeOZExactMasterHomeState();
}

class _LifeOZExactMasterHomeState extends State<LifeOZExactMasterHome> {
  final FlutterTts _tts = FlutterTts();
  String _name = '';
  int _reality = 0;

  static const realities = <String>[
    '01_Oreon_Prime.png','02_Terra_Flux.png','03_Vortex_Nexus.png',
    '04_Crysta_Lumen.png','09_Nebula_Soul-1.png','10_Shadow_Core-1.png',
  ];

  @override void initState() {
    super.initState();
    _name = widget.prefs.getString('user_name') ?? '';
    _reality = widget.prefs.getInt('lifeoz_reality') ?? 0;
    _tts.setSpeechRate(0.44);
  }
  @override void dispose() { _tts.stop(); super.dispose(); }
  Future<void> _speak(String text) async { await _tts.stop(); await _tts.speak(text); }

  Future<void> _profile() async {
    final c = TextEditingController(text: _name);
    final value = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF050A12), title: const Text('PROFILE'),
      content: TextField(controller: c, autofocus: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Name')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')), FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('SAVE'))],
    ));
    if (value != null && value.isNotEmpty) { await widget.prefs.setString('user_name', value); if (mounted) setState(() => _name = value); }
  }

  void _core(int index) {
    const messages = ['Life and growth intelligence.','Guardian and care intelligence.','Prosperity and money intelligence.','Time and commitments intelligence.','Personal intelligence, diary and goals.'];
    _speak(messages[index]);
  }

  void _controls() => showModalBottomSheet<void>(context: context, backgroundColor: const Color(0xFF050A12), builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
    ListTile(leading: const Icon(Icons.person_outline), title: const Text('Profile'), onTap: () { Navigator.pop(ctx); _profile(); }),
    ListTile(leading: const Icon(Icons.palette_outlined), title: const Text('Design'), onTap: () { Navigator.pop(ctx); _showDesigns(); }),
    const ListTile(leading: Icon(Icons.security_outlined), title: Text('Permissions')),
    const ListTile(leading: Icon(Icons.settings_outlined), title: Text('Settings')),
  ])));

  void _showDesigns() => showModalBottomSheet<void>(context: context, isScrollControlled: true, backgroundColor: const Color(0xFF03060D), builder: (ctx) => SafeArea(child: SizedBox(
    height: MediaQuery.of(ctx).size.height * .82,
    child: Column(children: [
      const Padding(padding: EdgeInsets.all(16), child: Text('LIFEOZ VISUAL REALITIES', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w700))),
      Expanded(child: GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: .72), itemCount: realities.length,
        itemBuilder: (_, i) => GestureDetector(onTap: () async { await widget.prefs.setInt('lifeoz_reality', i); if (mounted) setState(() => _reality = i); if (ctx.mounted) Navigator.pop(ctx); }, child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Stack(fit: StackFit.expand, children: [
          Image.asset(realities[i], fit: BoxFit.cover), if (_reality == i) Container(decoration: BoxDecoration(border: Border.all(color: Colors.cyanAccent, width: 3), borderRadius: BorderRadius.circular(16))),
        ]))))),
    ]),
  )));

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF01030A),
    body: SafeArea(child: LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth, h = c.maxHeight;
      final positions = [Offset(w*.50,h*.27),Offset(w*.25,h*.43),Offset(w*.75,h*.43),Offset(w*.28,h*.67),Offset(w*.72,h*.67)];
      return Stack(children: [
        Positioned.fill(child: Image.asset(realities[_reality], fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(.13))),
        Positioned.fill(child: CustomPaint(painter: _CosmicPainter())),
        Positioned(left: 28, top: 16, width: w*.62, height: 72, child: Image.asset('02_LifeOZ_Full_Logo.png', fit: BoxFit.contain, alignment: Alignment.centerLeft)),
        Positioned(right: 20, top: 18, width: 62, height: 62, child: GestureDetector(onTap: _controls, child: Image.asset('04_Holographic_Control.png', fit: BoxFit.contain))),
        Positioned(left: w*.18, right: w*.18, top: h*.18, height: h*.44, child: IgnorePointer(child: Image.asset('03_Yansi_Silent_Intelligence.png', fit: BoxFit.contain))),
        ...List.generate(5, (i) => Positioned(left: positions[i].dx-42, top: positions[i].dy-42, width: 84, height: 84, child: GestureDetector(onTap: () => _core(i), child: _CoreSymbol(index: i)))),
        Positioned(bottom: 20, left: 0, right: 0, child: Center(child: Text(_name.isEmpty ? 'LIVING INTELLIGENCE' : 'LIVING INTELLIGENCE  •  ${_name.toUpperCase()}', style: const TextStyle(color: Colors.white70, letterSpacing: 3, fontSize: 11, fontWeight: FontWeight.w600)))),
      ]);
    })),
  );
}

class _CoreSymbol extends StatelessWidget { final int index; const _CoreSymbol({required this.index}); @override Widget build(BuildContext context) { const colors=[Color(0xFF54F58A),Color(0xFFB55CFF),Color(0xFFFFB83D),Color(0xFF42D9FF),Color(0xFFC66BFF)]; return CustomPaint(painter:_CorePainter(colors[index])); } }
class _CorePainter extends CustomPainter {
  final Color color; _CorePainter(this.color);
  @override void paint(Canvas c, Size s) { final center=Offset(s.width/2,s.height/2); final p=Paint()..color=color.withOpacity(.9)..style=PaintingStyle.stroke..strokeWidth=2.4; final g=Paint()..color=color.withOpacity(.22)..maskFilter=const MaskFilter.blur(BlurStyle.normal,14); c.drawCircle(center,18,g); c.drawOval(Rect.fromCenter(center:center,width:72,height:25),p); c.save(); c.translate(center.dx,center.dy); c.rotate(.95); c.drawOval(const Rect.fromCenter(center:Offset.zero,width:72,height:25),p); c.restore(); c.drawCircle(center,4,Paint()..color=Colors.white); }
  @override bool shouldRepaint(covariant _CorePainter oldDelegate)=>oldDelegate.color!=color;
}
class _CosmicPainter extends CustomPainter {
  @override void paint(Canvas c, Size s) { final p=Paint()..color=Colors.white.withOpacity(.22); for(var i=0;i<80;i++){final x=(i*83.0)%s.width;final y=(i*137.0)%s.height;c.drawCircle(Offset(x,y),i%7==0?1.5:.8,p);} final ring=Paint()..color=const Color(0xFF1C8CA0).withOpacity(.16)..style=PaintingStyle.stroke..strokeWidth=1; for(final r in [s.width*.32,s.width*.43,s.width*.54]) c.drawOval(Rect.fromCenter(center:Offset(s.width/2,s.height*.47),width:r*2,height:r*.58),ring); }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false;
}
