import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_voice_integrated_home.dart';

/// Branding shell for the finalized LifeOZ home.
/// The supplied LifeOZ logo is rendered as artwork; it is never recreated
/// with Flutter lines, text, or substitute vector shapes.
class LifeOZExactBrandShell extends StatelessWidget {
  final SharedPreferences prefs;
  const LifeOZExactBrandShell({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        YansiVoiceIntegratedHome(prefs: prefs),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 112,
          child: IgnorePointer(
            child: Container(
              color: const Color(0xFF01030A),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16, right: 74, top: 4),
              child: Image.asset(
                '02_LifeOZ_Full_Logo.png',
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
