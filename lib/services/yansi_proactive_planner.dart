import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_context_fusion.dart';
import 'yansi_predictive_memory.dart';
import 'yansi_proactive_engine.dart';

/// Converts current context, time-aware signals and recurring memory into an explainable plan.
/// Local-first: it never performs sensitive actions by itself.
class YansiPlanItem {
  final String title,reason,action,core,scoreReason;
  final int rank,score;
  final double confidence;
  const YansiPlanItem({required this.title,required this.reason,required this.action,required this.core,required this.rank,required this.score,required this.confidence,required this.scoreReason});
  Map<String,dynamic> toJson()=>{'title':title,'reason':reason,'action':action,'core':core,'rank':rank,'score':score,'confidence':confidence,'scoreReason':scoreReason};
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
    final predictions=await YansiPredictiveMemory(prefs:prefs).scan();
    final insight=await YansiProactiveEngine(prefs:prefs).scan(userIsActive:true,notificationPermissionGranted:prefs.getBool('permission_notifications')==true);
    final candidates=<Map<String,dynamic>>[];
    if(context.openTasks>0)candidates.add({'title':'Handle the highest-impact task','reason':'There are ${context.openTasks} open tasks.','action':'PRIORITIZE','core':'PRODUCTIVITY','rank':1});
    if(context.upcomingReminders>0)candidates.add({'title':'Review upcoming commitments','reason':'${context.upcomingReminders} reminders are approaching.','action':'REVIEW','core':'CALENDAR','rank':2});
    if(context.recentSpend>0)candidates.add({'title':'Keep an eye on recent spending','reason':'Recent 30-day spending is ${context.recentSpend}.','action':'ANALYZE','core':'MONEY','rank':3});
    if(context.goals>0)candidates.add({'title':'Take one step toward a goal','reason':'${context.goals} goals are stored in LifeOS.','action':'ACTIVATE','core':'GOALS','rank':4});
    if(context.householdRecords>0)candidates.add({'title':'Review recurring household needs','reason':'Household history is available for prediction.','action':'PREDICT','core':'HOUSEHOLD','rank':5});

    final configuredFocus=(prefs.getString('yansi_active_focus')??'').trim();
    final legacyFocus=(prefs.getString('yansi_focus_mode')??'').trim();
    final focus=(configuredFocus.isNotEmpty?configuredFocus:legacyFocus).toUpperCase();
    final insightCore='${insight?.core??''}'.trim().toUpperCase();
    final rawConfidence=insight?.confidence??0;
    final insightConfidence=rawConfidence.isNaN?0.0:rawConfidence.clamp(0,1).toDouble();
    final temporal=context.temporalSignal.toLowerCase();

    int temporalBonus(String core){
      if((temporal.contains('productivity')||temporal.contains('task'))&&core=='PRODUCTIVITY')return 12;
      if((temporal.contains('commitment'))&&core=='CALENDAR')return 12;
      if(temporal.contains('money')&&core=='MONEY')return 12;
      return 0;
    }

    for(final prediction in predictions.take(10)){
      final core=prediction.core.toUpperCase();
      final match=candidates.where((c)=>'${c['core']}'.toUpperCase()==core).isNotEmpty;
      final base=match?62:48;
      final predictionBonus=(prediction.confidence*22).round();
      final recurrenceBonus=prediction.occurrences>=4?8:prediction.occurrences>=3?5:2;
      final timeBonus=temporalBonus(core);
      candidates.add({'title':'${prediction.title} may matter again','reason':'${prediction.reason} Yansi can prepare for this pattern without taking action automatically.','action':'PREDICT','core':core,'rank':6,'predictionConfidence':prediction.confidence,'predictionScore':(base+predictionBonus+recurrenceBonus+timeBonus).clamp(0,100),'predictionKey':prediction.key,'temporalBonus':timeBonus});
    }

    final scored=candidates.map((candidate){
      final core='${candidate['core']}'.toUpperCase();
      final rank=candidate['rank'] as int;
      final base=(candidate['predictionScore'] as int?)??(100-rank*10).clamp(0,100);
      final focusMatch=focus.isNotEmpty&&core==focus;
      final confidenceMatch=insightCore.isNotEmpty&&core==insightCore;
      final focusBonus=focusMatch?20:0;
      final confidenceBonus=confidenceMatch?(insightConfidence*20).round():0;
      final contextTimeBonus=temporalBonus(core);
      final score=(base+focusBonus+confidenceBonus+contextTimeBonus).clamp(0,100);
      final confidence=((candidate['predictionConfidence'] as num?)?.toDouble()??(confidenceMatch?insightConfidence:0.5)).clamp(0,1).toDouble();
      final factors=<String>['base $base'];
      if(candidate['predictionConfidence']!=null)factors.add('recurring pattern');
      if(contextTimeBonus>0)factors.add('time context +$contextTimeBonus');
      if(focusMatch)factors.add('active focus +$focusBonus');
      if(confidenceMatch)factors.add('insight confidence +$confidenceBonus');
      return YansiPlanItem(title:candidate['title'] as String,reason:candidate['reason'] as String,action:candidate['action'] as String,core:core,rank:rank,score:score,confidence:confidence,scoreReason:factors.join(', '));
    }).toList();
    scored.sort((a,b){final scoreCompare=b.score.compareTo(a.score);if(scoreCompare!=0)return scoreCompare;return a.rank.compareTo(b.rank);});
    final plan=YansiProactivePlan(createdAt:DateTime.now(),headline:scored.isEmpty?'Nothing needs your attention right now.':'Here is what matters most right now.',items:scored.take(5).toList());
    await prefs.setString('yansi_proactive_plan',jsonEncode(plan.toJson()));
    return plan;
  }
}
