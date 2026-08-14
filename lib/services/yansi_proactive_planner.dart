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

  double _calibrateConfidence({required double evidence,required int score,required int pressure,required bool temporalMatch,required bool focusMatch}){
    var value=evidence.clamp(0.0,1.0).toDouble();
    if(score>=80)value+=0.08;
    if(pressure>=65)value+=0.05;
    if(temporalMatch)value+=0.05;
    if(focusMatch)value+=0.04;
    return value.clamp(0.0,1.0).toDouble();
  }

  bool _shouldSurface({required int score,required double confidence,required int pressure,required bool permissionGranted,required bool userActive}){
    if(!permissionGranted||!userActive)return false;
    if(score>=82&&confidence>=0.72)return true;
    if(score>=70&&confidence>=0.82)return true;
    if(pressure>=75&&score>=65&&confidence>=0.68)return true;
    return false;
  }

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
    final pressure=context.situationalPressure.clamp(0,100);
    final notificationPermission=prefs.getBool('permission_notifications')==true;
    const userActive=true;

    int temporalBonus(String core){
      if((temporal.contains('productivity')||temporal.contains('task'))&&core=='PRODUCTIVITY')return 12;
      if(temporal.contains('commitment')&&core=='CALENDAR')return 12;
      if(temporal.contains('money')&&core=='MONEY')return 12;
      return 0;
    }

    int pressureBonus(String core){
      if(pressure<35)return 0;
      if(core=='PRODUCTIVITY'&&context.openTasks>0)return (pressure*0.16).round();
      if(core=='CALENDAR'&&context.upcomingReminders>0)return (pressure*0.18).round();
      if(core=='MONEY'&&context.recentSpend>0)return (pressure*0.08).round();
      return (pressure*0.04).round();
    }

    for(final prediction in predictions.take(10)){
      final core=prediction.core.toUpperCase();
      final match=candidates.where((c)=>'${c['core']}'.toUpperCase()==core).isNotEmpty;
      final base=match?62:48;
      final predictionBonus=(prediction.confidence*22).round();
      final recurrenceBonus=prediction.occurrences>=4?8:prediction.occurrences>=3?5:2;
      final timeBonus=temporalBonus(core);
      final pressureValue=pressureBonus(core);
      candidates.add({'title':'${prediction.title} may matter again','reason':'${prediction.reason} Yansi can prepare for this pattern without taking action automatically.','action':'PREDICT','core':core,'rank':6,'predictionConfidence':prediction.confidence,'predictionScore':(base+predictionBonus+recurrenceBonus+timeBonus+pressureValue).clamp(0,100),'predictionKey':prediction.key});
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
      final contextPressureBonus=pressureBonus(core);
      final score=(base+focusBonus+confidenceBonus+contextTimeBonus+contextPressureBonus).clamp(0,100);
      final evidence=((candidate['predictionConfidence'] as num?)?.toDouble()??(confidenceMatch?insightConfidence:0.5)).clamp(0,1).toDouble();
      final confidence=_calibrateConfidence(evidence:evidence,score:score,pressure:pressure,temporalMatch:contextTimeBonus>0,focusMatch:focusMatch);
      final factors=<String>['base $base'];
      if(candidate['predictionConfidence']!=null)factors.add('recurring pattern');
      if(contextTimeBonus>0)factors.add('time context +$contextTimeBonus');
      if(contextPressureBonus>0)factors.add('situational pressure +$contextPressureBonus');
      if(focusMatch)factors.add('active focus +$focusBonus');
      if(confidenceMatch)factors.add('insight confidence +$confidenceBonus');
      final shouldSurface=_shouldSurface(score:score,confidence:confidence,pressure:pressure,permissionGranted:notificationPermission,userActive:userActive);
      return {'item':YansiPlanItem(title:candidate['title'] as String,reason:candidate['reason'] as String,action:candidate['action'] as String,core:core,rank:rank,score:score,confidence:confidence,scoreReason:factors.join(', ')),'shouldSurface':shouldSurface};
    }).toList();
    scored.sort((a,b){final ai=a['item'] as YansiPlanItem;final bi=b['item'] as YansiPlanItem;final scoreCompare=bi.score.compareTo(ai.score);if(scoreCompare!=0)return scoreCompare;return ai.rank.compareTo(bi.rank);});
    final visible=scored.where((e)=>e['shouldSurface']==true).map((e)=>e['item'] as YansiPlanItem).take(5).toList();
    final plan=YansiProactivePlan(createdAt:DateTime.now(),headline:visible.isEmpty?'Yansi is staying quiet — nothing has enough evidence to interrupt you.':'Here is what matters most right now.',items:visible);
    await prefs.setString('yansi_proactive_plan',jsonEncode(plan.toJson()));
    return plan;
  }
}
