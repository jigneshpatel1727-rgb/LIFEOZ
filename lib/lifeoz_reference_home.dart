import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LifeOZReferenceHome extends StatefulWidget {
  final SharedPreferences prefs;

  const LifeOZReferenceHome({super.key, required this.prefs});

  @override
  State<LifeOZReferenceHome> createState() => _LifeOZReferenceHomeState();
}

class _LifeOZReferenceHomeState extends State<LifeOZReferenceHome> {
  final FlutterTts _tts = FlutterTts();
  late final Uint8List _homeImage;
  String _name = '';

  @override
  void initState() {
    super.initState();
    _name = widget.prefs.getString('user_name') ?? '';
    _homeImage = base64Decode(_homeReferenceJpeg);
    _tts.setSpeechRate(0.44);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _profile() async {
    final controller = TextEditingController(text: _name);
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF07101B),
        title: const Text('PROFILE'),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('SAVE'),
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              fit: StackFit.expand,
              children: [
                FittedBox(
                  fit: BoxFit.cover,
                  child: Image.memory(_homeImage, gaplessPlayback: true),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapUp: (details) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;
                      final p = details.localPosition;
                      final points = <Offset>[
                        Offset(w * .50, h * .28),
                        Offset(w * .26, h * .43),
                        Offset(w * .74, h * .43),
                        Offset(w * .26, h * .73),
                        Offset(w * .74, h * .73),
                      ];
                      for (var i = 0; i < points.length; i++) {
                        if ((p - points[i]).distance < w * .16) {
                          _core(i);
                          return;
                        }
                      }
                      final center = Offset(w * .50, h * .53);
                      if ((p - center).distance < w * .20) {
                        _speak(_name.isEmpty ? 'I am here.' : 'I am here, $_name.');
                      }
                    },
                  ),
                ),
                Positioned(
                  left: constraints.maxWidth * .055,
                  top: constraints.maxHeight * .025,
                  width: constraints.maxWidth * .13,
                  height: constraints.maxWidth * .13,
                  child: GestureDetector(
                    onTap: _profile,
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

const String _homeReferenceJpeg = r'''
/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcU
...TRUNCATED... 
''';