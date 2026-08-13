/// User-authorized UI personalization for Yansi/LifeOS.
///
/// This changes runtime presentation settings, not application source code.
/// Yansi may propose a design and apply it only when the user requests it.
class YansiUiPersonalizationEngine {
  const YansiUiPersonalizationEngine();

  static const supportedThemes = <String>[
    'neural_night',
    'aurora',
    'minimal_dark',
    'glass_future',
    'custom',
  ];

  static const supportedIconModes = <String>[
    'neural',
    'orbital',
    'minimal',
    'glass',
    'custom',
  ];

  bool isValidTheme(String value) => supportedThemes.contains(value);

  bool isValidIconMode(String value) => supportedIconModes.contains(value);

  Map<String, dynamic> createProposal({
    required String theme,
    required String iconMode,
    String? accent,
    bool compactLayout = true,
  }) {
    return {
      'theme': isValidTheme(theme) ? theme : 'neural_night',
      'iconMode': isValidIconMode(iconMode) ? iconMode : 'neural',
      'accent': accent?.trim(),
      'compactLayout': compactLayout,
      'requiresUserApproval': true,
    };
  }

  String describe() =>
      'Yansi can design and personalize the LifeOS display and icons when the user asks. It changes approved runtime presentation settings, not its own application code.';
}
