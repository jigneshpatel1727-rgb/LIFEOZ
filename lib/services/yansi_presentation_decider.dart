import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_ambient_insight.dart';

enum YansiPresentationMode { silent, visual, spoken }

class YansiPresentationDecision {
  final YansiPresentationMode mode;
  final YansiAmbientInsight insight;
  const YansiPresentationDecision({required this.mode,required this.insight});
}

/// Final user-authority gate for Yansi presentation.
/// Intelligence may recommend a mode, but this layer controls whether speech
/// is actually permitted. It never invokes TTS itself.
class YansiPresentationDecider {
  final SharedPreferences prefs;
  const YansiPresentationDecider({required this.prefs});

  YansiPresentationDecision? decide(YansiAmbientInsight? insight) {
    if(insight==null) return null;
    if(prefs.getBool('yansi_quiet_mode')==true) {
      return YansiPresentationDecision(mode:YansiPresentationMode.silent,insight:insight);
    }

    final voiceAllowed=prefs.getBool('yansi_voice_enabled')==true;
    final proactiveSpeechAllowed=prefs.getBool('yansi_proactive_speech_allowed')==true;
    final sensitive=insight.core=='MONEY' || insight.core=='HEALTH';

    // Sensitive information is never proactively spoken.
    if(voiceAllowed && proactiveSpeechAllowed && !sensitive && insight.priority<=2) {
      return YansiPresentationDecision(mode:YansiPresentationMode.spoken,insight:insight);
    }
    return YansiPresentationDecision(mode:YansiPresentationMode.visual,insight:insight);
  }
}
