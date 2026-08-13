import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_ambient_insight.dart';

enum YansiPresentationMode { silent, visual, spoken }

/// Chooses a non-intrusive presentation mode. It never speaks by itself.
class YansiPresentationDecision {
  final YansiPresentationMode mode;
  final YansiAmbientInsight insight;
  const YansiPresentationDecision({required this.mode,required this.insight});
}

class YansiPresentationDecider {
  final SharedPreferences prefs;
  const YansiPresentationDecider({required this.prefs});

  YansiPresentationDecision? decide(YansiAmbientInsight? insight) {
    if(insight==null) return null;
    if(prefs.getBool('yansi_quiet_mode')==true) {
      return YansiPresentationDecision(mode:YansiPresentationMode.silent,insight:insight);
    }
    if(prefs.getBool('yansi_voice_enabled')==true && insight.priority<=2) {
      return YansiPresentationDecision(mode:YansiPresentationMode.spoken,insight:insight);
    }
    return YansiPresentationDecision(mode:YansiPresentationMode.visual,insight:insight);
  }
}
