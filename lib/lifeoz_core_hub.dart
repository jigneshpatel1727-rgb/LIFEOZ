import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lifeoz_themed_core_shell.dart';

class LifeOZCoreHub extends StatelessWidget {
  final SharedPreferences prefs;
  final int coreIndex;
  const LifeOZCoreHub({super.key, required this.prefs, required this.coreIndex});

  @override
  Widget build(BuildContext context) {
    return LifeOZThemedCoreShell(prefs: prefs, coreIndex: coreIndex);
  }
}
