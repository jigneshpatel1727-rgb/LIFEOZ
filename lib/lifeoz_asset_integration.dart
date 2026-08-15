import 'dart:typed_data';
import 'package:flutter/widgets.dart';

/// Central asset integration layer for the locked LIFEOZ visual system.
///
/// The UI must consume these slots rather than drawing substitute atoms,
/// circles, or generic Material icons. Binary artwork can be supplied later
/// without changing the home-screen interaction code.
class LifeOZAssetIntegration {
  static const appIcon = 'lifeoz_app_icon';
  static const logo = 'lifeoz_full_logo';
  static const yansi = 'yansi_silent_intelligence';
  static const holographicControl = 'holographic_control';

  static const realities = <String>[
    'oreon_prime',
    'terra_flux',
    'vortex_nexus',
    'crysta_lumen',
    'nebula_soul',
    'shadow_core',
  ];

  static const coreRoles = <String>[
    'life_growth',
    'guardian_care',
    'prosperity_money',
    'time_commitments',
    'mind_personal_intelligence',
  ];

  /// Creates a Flutter image from binary artwork supplied by the asset pack.
  static Image image(Uint8List bytes, {BoxFit fit = BoxFit.contain}) =>
      Image.memory(bytes, fit: fit, filterQuality: FilterQuality.high,
          gaplessPlayback: true);
}
