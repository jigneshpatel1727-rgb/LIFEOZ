import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LifeOZExactMasterHome extends StatefulWidget {
  final SharedPreferences prefs;
  const LifeOZExactMasterHome({super.key, required this.prefs});
  @override
  State<LifeOZExactMasterHome> createState() => _LifeOZExactMasterHomeState();
}

class _LifeOZExactMasterHomeState extends State<LifeOZExactMasterHome> {
  final FlutterTts _tts = FlutterTts();
  String _name = '';

  @override
  void initState() {
    super.initState();
    _name = widget.prefs.getString('user_name') ?? '';
    _tts.setSpeechRate(0.44);
  }

  @override
  void dispose() { _tts.stop(); super.dispose(); }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _profile() async {
    final c = TextEditingController(text: _name);
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF050A12),
        title: const Text('PROFILE'),
        content: TextField(controller: c, autofocus: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('SAVE')),
        ],
      ),
    );
    if (value != null && value.isNotEmpty) {
      await widget.prefs.setString('user_name', value);
      if (mounted) setState(() => _name = value);
    }
  }

  void _core(int index) {
    const messages = [
      'Life and growth intelligence.',
      'Guardian and care intelligence.',
      'Prosperity and money intelligence.',
      'Time and commitments intelligence.',
      'Personal intelligence, diary and goals.',
    ];
    _speak(messages[index]);
  }

  void _controls() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF050A12),
      builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.person_outline), title: const Text('Profile'), onTap: () { Navigator.pop(ctx); _profile(); }),
        const ListTile(leading: Icon(Icons.palette_outlined), title: Text('Design')),
        const ListTile(leading: Icon(Icons.security_outlined), title: Text('Permissions')),
        const ListTile(leading: Icon(Icons.settings_outlined), title: Text('Settings')),
      ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.memory(base64Decode(_masterHomeJpeg), fit: BoxFit.cover, filterQuality: FilterQuality.high, gaplessPlayback: true);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth, h = c.maxHeight;
          return Stack(fit: StackFit.expand, children: [
            image,
            Positioned.fill(child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp: (details) {
                final p = details.localPosition;
                final points = <Offset>[
                  Offset(w * .50, h * .22),
                  Offset(w * .26, h * .39),
                  Offset(w * .74, h * .39),
                  Offset(w * .27, h * .69),
                  Offset(w * .73, h * .69),
                ];
                for (var i = 0; i < points.length; i++) {
                  if ((p - points[i]).distance < w * .14) { _core(i); return; }
                }
              },
            )),
            Positioned(left: w*.03, top: h*.01, width: w*.16, height: h*.12, child: GestureDetector(onTap: _profile)),
            Positioned(right: w*.03, top: h*.01, width: w*.16, height: h*.12, child: GestureDetector(onTap: _controls)),
          ]);
        }),
      ),
    );
  }
}

const String _masterHomeJpeg = r'''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''';
