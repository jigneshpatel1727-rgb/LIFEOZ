import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_briefing_history.dart';
import 'yansi_proactive_planner.dart';

/// Small runtime bridge for Yansi's ambient/proactive layer.
/// It prepares intelligence without speaking or executing actions by itself.
class YansiProactiveRuntime {
  final SharedPreferences prefs;
  const YansiProactiveRuntime({required this.prefs});

  Future<YansiProactivePlan?> prepare({bool userIsActive=true,bool quietMode=false}) async {
    if(quietMode) return null;
    final plan=await YansiProactivePlanner(prefs:prefs).build();
    if(plan.items.isEmpty) return null;

    final history=YansiBriefingHistory(prefs:prefs);
    if(!await history.shouldSurface(plan.headline)) {
      return null;
    }

    await prefs.setBool('yansi_plan_ready',true);
    await prefs.setString('yansi_plan_headline',plan.headline);
    await history.markSurfaced(plan.headline);
    return plan;
  }

  bool get isReady => prefs.getBool('yansi_plan_ready')==true;
  String? get headline => prefs.getString('yansi_plan_headline');
  Future<void> clearReady() async {
    await prefs.remove('yansi_plan_ready');
    await prefs.remove('yansi_plan_headline');
  }
}
