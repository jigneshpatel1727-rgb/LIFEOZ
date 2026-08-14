import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_context_fusion.dart';
import 'yansi_proactive_engine.dart';

/// Converts Yansi's signals into a small, explainable plan for the user.
/// Planning is local-first and never performs sensitive actions by itself.
class YansiPlanItem {
  final String title;
  final String reason;
  final String action;
  final String core;
  final int rank;
  const YansiPlanItem({required this.title,required this.reason,required this.action,required this.core,required this.rank});
  Map<String,dynamic> toJson()=>{'title':title,'reason':reason,'action':action,'core':core,'rank':rank};
}

class YansiProactivePlan {
  final DateTime createdAt;
  final String headline;
  final List<YansiPlanItem> items;
  const YansiProactivePlan({required this.createdAt,required this.headline,required this.items});
  Map<String,dynamic> toJson()=>{'createdAt':createdAt.toIso8601String(),'headline':headline,'items':items.map((e)=>e.toJson()).toList()};
}

class YansiProactivePlanner {
  final SharedPreferences prefs;
  const YansiProactivePlanner({required this.prefs});

  Future<YansiProactivePlan> build() async {
    final context=await YansiContextFusion(prefs:prefs).build();
    final insight=await YansiProactiveEngine(prefs:prefs).scan(userIsActive:true,notificationPermissionGranted:prefs.getBool('permission_notifications')==true);
    final items=<YansiPlanItem>[];
    if(context.openTasks>0) items.add(YansiPlanItem(title:'Handle the highest-impact task',reason:'There are ${context.openTasks} open tasks.',action:'PRIORITIZE',core:'PRODUCTIVITY',rank:1));
    if(context.upcomingReminders>0) items.add(YansiPlanItem(title:'Review upcoming commitments',reason:'${context.upcomingReminders} reminders are approaching.',action:'REVIEW',core:'CALENDAR',rank:2));
    if(context.recentSpend>0) items.add(YansiPlanItem(title:'Keep an eye on recent spending',reason:'Recent 30-day spending is ${context.recentSpend}.',action:'ANALYZE',core:'MONEY',rank:3));
    if(context.goals>0) items.add(YansiPlanItem(title:'Take one step toward a goal',reason:'${context.goals} goals are stored in LifeOS.',action:'ACTIVATE',core:'GOALS',rank:4));
    if(context.householdRecords>0) items.add(YansiPlanItem(title:'Review recurring household needs',reason:'Household history is available for prediction.',action:'PREDICT',core:'HOUSEHOLD',rank:5));

    // Adaptive focus is a soft signal: it receives a score bonus rather than
    // automatically overriding stronger LifeOS signals.
    final focus=(prefs.getString('yansi_active_focus')??'').trim().toUpperCase();
    int focusBonus(YansiPlanItem item) => focus.isNotEmpty && item.core.toUpperCase()==focus ? 20 : 0;
    int signalScore(YansiPlanItem item) => (100 - item.rank * 10 + focusBonus(item)).clamp(0, 100);

    items.sort((a,b){
      final scoreCompare=signalScore(b).compareTo(signalScore(a));
      if(scoreCompare!=0)return scoreCompare;
      return a.rank.compareTo(b.rank);
    });

    if(insight!=null && items.isNotEmpty){
      // Keep the engine as a gate/validation layer; the planner remains read-only.
      items.sort((a,b){
        final scoreCompare=signalScore(b).compareTo(signalScore(a));
        if(scoreCompare!=0)return scoreCompare;
        return a.rank.compareTo(b.rank);
      });
    }
    final plan=YansiProactivePlan(createdAt:DateTime.now(),headline:items.isEmpty?'Nothing needs your attention right now.':'Here is what matters most right now.',items:items.take(5).toList());
    await prefs.setString('yansi_proactive_plan',jsonEncode(plan.toJson()));
    return plan;
  }
}
