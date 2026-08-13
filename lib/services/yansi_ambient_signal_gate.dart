/// Final presentation gate for Yansi ambient signals.
/// This class never executes actions or mutates LifeOS data.
class YansiAmbientSignalGate {
  const YansiAmbientSignalGate();

  bool allow({
    required bool visible,
    required bool userActive,
    required bool quietMode,
    required bool cadenceAllowed,
    required int priority,
  }) {
    if (quietMode || !visible || !userActive || !cadenceAllowed) return false;
    return priority >= 60;
  }

  bool allowVoice({
    required bool surfaceAllowed,
    required bool voiceAvailable,
    required bool runtimeAllowsSpeech,
  }) {
    return surfaceAllowed && voiceAvailable && runtimeAllowsSpeech;
  }
}
