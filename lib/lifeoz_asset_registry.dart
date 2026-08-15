/// Single source of truth for the LIFEOZ master artwork.
///
/// Binary artwork is intentionally referenced by stable paths. The UI must
/// never substitute generic Material icons for these slots.
class LifeOZAssetRegistry {
  static const appIcon = 'assets/lifeoz/app_icon.webp';
  static const fullLogo = 'assets/lifeoz/full_logo.webp';
  static const yansi = 'assets/lifeoz/yansi.webp';
  static const holographicControl = 'assets/lifeoz/holographic_control.webp';

  static const realities = <String>[
    'assets/lifeoz/realities/oreon_prime.webp',
    'assets/lifeoz/realities/terra_flux.webp',
    'assets/lifeoz/realities/vortex_nexus.webp',
    'assets/lifeoz/realities/crysta_lumen.webp',
    'assets/lifeoz/realities/nebula_soul.webp',
    'assets/lifeoz/realities/shadow_core.webp',
  ];

  static const coreRoles = <String>[
    'life_growth',
    'guardian_care',
    'prosperity_money',
    'time_commitments',
    'mind_personal_intelligence',
  ];
}
