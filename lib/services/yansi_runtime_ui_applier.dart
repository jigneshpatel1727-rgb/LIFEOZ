import 'yansi_ui_personalization_profile.dart';

/// Converts a personalization profile into UI-safe runtime values.
class YansiRuntimeUiApplier {
  const YansiRuntimeUiApplier();

  Map<String, dynamic> apply(YansiUiPersonalizationProfile profile) {
    return {
      'themeMode': profile.theme,
      'iconMode': profile.iconStyle,
      'layoutDensity': profile.density,
      'motionMode': profile.animation,
      'runtimeApplied': true,
    };
  }

  bool canApply({required bool userRequested}) => userRequested;
}
