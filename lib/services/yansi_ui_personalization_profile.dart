/// Runtime design profile generated from user preferences.
class YansiUiPersonalizationProfile {
  final String theme;
  final String iconStyle;
  final String density;
  final String animation;

  const YansiUiPersonalizationProfile({
    required this.theme,
    required this.iconStyle,
    required this.density,
    required this.animation,
  });

  factory YansiUiPersonalizationProfile.fromIntent(Map<String, dynamic> intent) {
    return YansiUiPersonalizationProfile(
      theme: (intent['theme'] ?? 'default').toString(),
      iconStyle: (intent['iconStyle'] ?? 'default').toString(),
      density: (intent['density'] ?? 'balanced').toString(),
      animation: (intent['animation'] ?? 'adaptive').toString(),
    );
  }

  Map<String, String> toMap() => {
        'theme': theme,
        'iconStyle': iconStyle,
        'density': density,
        'animation': animation,
      };
}
