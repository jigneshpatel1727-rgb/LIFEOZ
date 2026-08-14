import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_briefing_history.dart';
import 'yansi_priority_memory.dart';
import 'yansi_proactive_planner.dart';
import 'yansi_cross_core_priority.dart';
import 'yansi_proactive_pipeline.dart';

/// Runtime bridge for Yansi's ambient/proactive intelligence.
/// It prepares intelligence only; presentation is recorded separately.
class YansiProactiveRuntime {
  final SharedPreferences prefs;
  const YansiProactiveRuntime({required this.prefs});

  Future<YansiProactivePlan?> prepare({bool userIsActive=true,bool quietMode=false}) async {
    if(quietMode||!userIsActive)return null;
    final plan=await YansiProactivePlanner(prefs:prefs).build();
    if(plan.items.isEmpty)return null;

    final top=plan.items.first;
    final priority=top.score.clamp(0,100).toInt();
    final memory=YansiPriorityMemory(prefs:prefs);
    final escalation=memory.isEscalation(priority);
    final history=YansiBriefingHistory(prefs:prefs);
    final historyAllows=await history.shouldSurface(plan.headline);
    if(!escalation&&!historyAllows)return null;

    final signals=<Map<String,dynamic>>[
      for(final item in plan.items)
        {'core':item.core.toLowerCase(),'priority':item.score.clamp(0,100).toInt(),'confidence':item.score.clamp(0,100).toInt(),'readOnly':true,'scoreReason':item.scoreReason},
    ];
    final fused=<String,dynamic>{'signals':{for(final signal in signals)signal['core'].toString():signal}};
    final decision=const YansiProactivePipeline(priorityEngine:YansiCrossCorePriority()).evaluate(
      fusedSignals:fused,
      insight:top.reason,
      repeated:false,
      quietHours:quietMode,
    );
    if(decision['surface']!=true)return null;

    await prefs.setBool('yansi_plan_ready',true);
    await prefs.setString('yansi_plan_headline',plan.headline);
    await prefs.setBool('yansi_decision_speak',decision['speak']==true);
    await prefs.setInt('yansi_decision_priority',(decision['priority'] as num?)?.clamp(0,100).toInt()??priority);
    await prefs.setInt('yansi_decision_confidence',(decision['confidence'] as num?)?.clamp(0,100).toInt()??top.score);
    await prefs.setString('yansi_decision_reason',top.scoreReason);
    return plan;
  }

  Future<void> markPresented() async {
    final headline=prefs.getString('yansi_plan_headline');
    if(headline==null||headline.trim().isEmpty)return;
    final currentPriority=priority;
    await YansiBriefingHistory(prefs:prefs).markPresented(headline);
    await YansiPriorityMemory(prefs:prefs).remember(currentPriority);
  }

  bool get isReady=>prefs.getBool('yansi_plan_ready')==true;
  String? get headline=>prefs.getString('yansi_plan_headline');
  bool get shouldSpeak=>prefs.getBool('yansi_decision_speak')==true;
  int get priority=>prefs.getInt('yansi_decision_priority')??0;
  int get confidence=>prefs.getInt('yansi_decision_confidence')??0;
  String? get decisionReason=>prefs.getString('yansi_decision_reason');

  Future<void> clearReady() async {
    await prefs.remove('yansi_plan_ready');
    await prefs.remove('yansi_plan_headline');
    await prefs.remove('yansi_decision_speak');
    await prefs.remove('yansi_decision_priority');
    await prefs.remove('yansi_decision_confidence');
    await prefs.remove('yansi_decision_reason');
  }
}
