import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lifeoz_design_home.dart';

/// Final LifeOZ visual shell. Uses supplied artwork for the brand, Yansi and
/// the six separate visual realities instead of recreating them with lines.
class LifeOZExactBrandShell extends StatelessWidget {
  final SharedPreferences prefs;
  const LifeOZExactBrandShell({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) => LifeOZDesignHome(prefs: prefs);
}
