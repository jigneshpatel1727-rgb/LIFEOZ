/// Selects display behavior for ambient, focused, dashboard, and immersive modes.
class YansiDisplayModeEngine {
  const YansiDisplayModeEngine();

  String choose({
    required bool ambient,
    required bool focus,
    required bool immersive,
  }) {
    if (immersive) return 'immersive';
    if (focus) return 'focus';
    if (ambient) return 'ambient';
    return 'dashboard';
  }

  bool showSecondaryInformation(String mode) =>
      mode == 'dashboard' || mode == 'immersive';
}
