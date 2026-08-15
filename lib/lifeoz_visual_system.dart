/// Locked LIFEOZ visual specification.
///
/// These identifiers are intentionally stable so UI code never falls back to
/// the old atom/sphere artwork. The binary artwork is supplied separately and
/// must be wired into these slots without redrawing it with Canvas primitives.
class LifeOZVisualSystem {
  static const appIcon = 'lifeoz_app_icon';
  static const fullLogo = 'lifeoz_full_logo';
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

  static const yansiRules = <String>[
    'ambient_only',
    'no_chat_bar',
    'no_visible_character_ui',
    'voice_and_text_assistance',
    'confirmation_for_sensitive_actions',
  ];
}
