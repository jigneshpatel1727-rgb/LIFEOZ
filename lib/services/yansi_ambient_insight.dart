import 'package:shared_preferences/shared_preferences.dart';
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
    if(plan==null || plan.items.isEmpty) return null;
    final item=plan.items.first;
    return YansiAmbientInsight(
      text:'${item.title}. ${item.reason}',
      action:item.action,
      core:item.core,
      priority:item.rank,
    );
  }

  bool get canPresent => prefs.getBool('yansi_quiet_mode')!=true && prefs.getBool('yansi_plan_ready')==true;
}
