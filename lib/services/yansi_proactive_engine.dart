import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_notification_policy.dart';

/// Local-first predictive intelligence. It ranks permitted LifeOS signals.
class YansiProactiveInsight {
  final String title,message,priority,action,core;
  final double confidence;
  final Map<String,dynamic> data;
  const YansiProactiveInsight({required this.title,required this.message,required this.priority,required this.action,required this.core,this.confidence=.5,this.data=const {}});
}

class YansiProactiveEngine {
  final SharedPreferences prefs;
  final YansiNotificationPolicy notificationPolicy;
  const YansiProactiveEngine({required this.prefs,this.notificationPolicy=const YansiNotificationPolicy()});
  List<Map<String,dynamic>> _read(String key){final raw=prefs.getStringList(key)??const <String>[];return raw.map((v){try{return Map<String,dynamic>.from(jsonDecode(v)as Map);}catch(_){return <String,dynamic>{};}}).where((e)=>e.isNotEmpty).toList();}

  Future<YansiProactiveInsight?> scan({bool quietMode=false,bool userIsActive=true,bool notificationPermissionGranted=false}) async {
    final now=DateTime.now();final candidates=<YansiProactiveInsight>[];
    final tasks=_read('yansi_tasks'),reminders=_read('yansi_reminders'),expenses=_read('yansi_expenses'),household=_read('yansi_household'),goals=_read('yansi_goals'),events=_read('yansi_events');
    if(events.isNotEmpty){final e=events.last;final d=DateTime.tryParse('${e['at']??''}');if(d==null||now.difference(d).inHours<24){final data=Map<String,dynamic>.from((e['data']as Map?)??const {});final raw='${data['priority']??data['urgency']??''}'.toUpperCase();final priority=raw.contains('URGENT')||raw.contains('HIGH')?'HIGH':raw.contains('MEDIUM')?'MEDIUM':'LOW';candidates.add(YansiProactiveInsight(title:'NEW SIGNAL',message:'${e['title']??'A new LifeOS event'} is ready for Yansi to evaluate.',priority:priority,action:'REVIEW',core:'YANSI',confidence:.84,data:{'eventId':'${e['id']??''}','type':'${e['type']??'system'}'}));}}
    final open=tasks.where((e)=>e['completed']!=true).toList();
    if(open.isNotEmpty){final urgent=open.where((e){final s='${e['urgency']??e['priority']??''}'.toLowerCase();return s.contains('high')||s.contains('urgent');}).length;candidates.add(YansiProactiveInsight(title:'ATTENTION NEEDED',message:'You have ${open.length} unfinished tasks${urgent>0?', including $urgent high-priority':''}. I can rank the highest-impact work first.',priority:urgent>0?'HIGH':'MEDIUM',action:'PRIORITIZE',core:'PRODUCTIVITY',confidence:(.72+(urgent*.04)).clamp(0,.97).toDouble(),data:{'openTasks':open.length,'urgentTasks':urgent}));}
    final due=reminders.where((e){final d=DateTime.tryParse('${e['dueDate']??e['date']??''}');return d!=null&&!d.isAfter(now.add(const Duration(days:7)))&&!d.isBefore(now.subtract(const Duration(days:1)));}).toList();
    if(due.isNotEmpty)candidates.add(YansiProactiveInsight(title:'TIME SIGNAL',message:'${due.length} reminder${due.length==1?'':'s'} fall within the next 7 days. I can bring the most important ones into focus.',priority:due.any((e){final d=DateTime.tryParse('${e['dueDate']??e['date']??''}');return d!=null&&d.difference(now).inHours<=48;})?'HIGH':'MEDIUM',action:'REVIEW',core:'CALENDAR',confidence:.88,data:{'dueCount':due.length}));
    if(expenses.length>=4){final totals=<String,double>{};for(final e in expenses){final d=DateTime.tryParse('${e['date']??''}');if(d==null)continue;final k='${d.year}-${d.month}';totals[k]=(totals[k]??0)+((e['amount']as num?)?.toDouble()??0);}final keys=totals.keys.toList()..sort();if(keys.length>=2){final prev=totals[keys[keys.length-2]]??0,latest=totals[keys.last]??0;if(prev>0&&latest>prev*1.1){final pct=((latest/prev-1)*100).round();candidates.add(YansiProactiveInsight(title:'MONEY PULSE',message:'Latest stored monthly spending is about $pct% above the previous month. I can identify the categories driving the change.',priority:pct>=25?'HIGH':'MEDIUM',action:'ANALYZE',core:'MONEY',confidence:.82,data:{'previous':prev,'latest':latest,'increasePercent':pct}));}}}
    if(goals.isNotEmpty){final stale=goals.where((g){final d=DateTime.tryParse('${g['updatedAt']??g['date']??''}');return d==null||now.difference(d).inDays>=14;}).length;if(stale>0)candidates.add(YansiProactiveInsight(title:'GOAL DRIFT',message:'$stale goal${stale==1?'':'s'} show little recent progress. I can convert one into a small action for today.',priority:'MEDIUM',action:'ACTIVATE',core:'GOALS',confidence:.78,data:{'staleGoals':stale}));}
    if(household.length>=3){final counts=<String,int>{};for(final e in household){final item='${e['item']??''}'.trim().toLowerCase();if(item.isNotEmpty)counts[item]=(counts[item]??0)+1;}if(counts.isNotEmpty){final top=counts.entries.reduce((a,b)=>a.value>=b.value?a:b);candidates.add(YansiProactiveInsight(title:'HOUSEHOLD PREDICTION',message:'${top.key} is recurring in your household history. I can prepare a predicted shopping requirement.',priority:'LOW',action:'PREDICT',core:'HOUSEHOLD',confidence:(.6+top.value*.06).clamp(0,.94).toDouble(),data:{'item':top.key,'frequency':top.value}));}}
    if(candidates.isEmpty)return null;
    const priorityWeight={'HIGH':3.0,'MEDIUM':2.0,'LOW':1.0};
    double rankingScore(YansiProactiveInsight insight){final priority=(priorityWeight[insight.priority]??1.0)/3.0;final confidence=insight.confidence.clamp(0,1);return priority*0.75+confidence*0.25;}
    candidates.sort((a,b)=>rankingScore(b).compareTo(rankingScore(a)));
    final best=candidates.first;
    final decision=notificationPolicy.decide(priority:best.priority,quietMode:quietMode,userIsActive:userIsActive,permissionGranted:notificationPermissionGranted,confidence:best.confidence);
    await prefs.setString('yansi_last_prediction',jsonEncode({'title':best.title,'core':best.core,'priority':best.priority,'confidence':best.confidence,'rankingScore':rankingScore(best),'at':now.toIso8601String(),'data':best.data,'delivery':decision.mode.name,'deliveryReason':decision.reason,'deliveryConfidence':decision.confidence,'deliver':decision.deliver}));
    return best;
  }
}
