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
  final int score;
  final double confidence;
  final String scoreReason;
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

    final scored=candidates.map((candidate){
      final core='${candidate['core']}'.toUpperCase();
      final rank=candidate['rank'] as int;
      final base=(100-rank*10).clamp(0,100);
      final focusMatch=focus.isNotEmpty&&core==focus;
      final confidenceMatch=insightCore.isNotEmpty&&core==insightCore;
      final focusBonus=focusMatch?20:0;
      final confidenceBonus=confidenceMatch?(insightConfidence*20).round():0;
      final score=(base+focusBonus+confidenceBonus).clamp(0,100);
      final confidence=confidenceMatch?insightConfidence:0.5;
      final factors=<String>[];
      factors.add('base $base');
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
