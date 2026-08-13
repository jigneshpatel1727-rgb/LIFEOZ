import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_pattern_advice.dart';
import 'yansi_proactive_runtime.dart';

/// Presentation-neutral delivery model for Yansi's ambient insights.
/// UI/voice layers decide when and how to present it.
class YansiAmbientInsight {
  final String text;
  final String action;
  final String core;
  final int priority;
  const YansiAmbientInsight({required this.text,required this.action,required this.core,required this.priority});
}

class YansiAmbientInsightService {
  final SharedPreferences prefs;
  const YansiAmbientInsightService({required this.prefs});

  Future<YansiAmbientInsight?> prepare() async {
    final plan=await YansiProactiveRuntime(prefs:prefs).prepare(
      userIsActive:true,
      quietMode:prefs.getBool('yansi_quiet_mode')==true,
    );
    if(plan!=null && plan.items.isNotEmpty) {
      final item=plan.items.first;
      return YansiAmbientInsight(
        text:'${item.title}. ${item.reason}',
        action:item.action,
        core:item.core,
        priority:item.rank,
      );
    }

    // If there is no proactive plan, offer approved learned advice as a
    // secondary ambient insight. This still requires the user's learning
    // permission and never executes or speaks anything itself.
    final advice=await YansiPatternAdviceService(prefs:prefs).build();
    if(advice==null) return null;
    return YansiAmbientInsight(
      text:'${advice.title}. ${advice.reason}',
      action:advice.suggestion,
      core:'companion',
      priority:advice.confidence>=.8 ? 2 : 3,
    );
  }

  bool get canPresent => prefs.getBool('yansi_quiet_mode')!=true && prefs.getBool('yansi_plan_ready')==true;
}
