/// Describes the presentation context available to Yansi's ambient layer.
/// This is intentionally read-only: it never grants permission to execute actions.
class YansiAmbientContext {
  final bool userIsActive;
  final bool quietMode;
  final bool screenVisible;
  final bool voiceAvailable;

  const YansiAmbientContext({
    this.userIsActive = false,
    this.quietMode = false,
    this.screenVisible = true,
    this.voiceAvailable = false,
  });

  bool get maySurface => !quietMode && (userIsActive || screenVisible);

  bool get maySpeak => maySurface && voiceAvailable;

  YansiAmbientContext copyWith({
    bool? userIsActive,
    bool? quietMode,
    bool? screenVisible,
    bool? voiceAvailable,
  }) {
    return YansiAmbientContext(
      userIsActive: userIsActive ?? this.userIsActive,
      quietMode: quietMode ?? this.quietMode,
      screenVisible: screenVisible ?? this.screenVisible,
      voiceAvailable: voiceAvailable ?? this.voiceAvailable,
    );
  }
}
