import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-first proactive intelligence layer.
/// It observes permitted LifeOS data and prepares explainable next actions.
/// It never silently performs sensitive actions.
class YansiProactiveInsight {
  final String title;
  final String message;
  final String priority;
  final String action;
  final String core;
  final Map<String,dynamic> data;
  const YansiProactiveInsight({required this.title,required this.message,required this.priority,required this.action,required this.core, this.data=const {}});
}

class YansiProactiveEngine {
  final SharedPreferences prefs;
  const YansiProactiveEngine({required this.prefs});

  List<Map<String,dynamic>> _read(String key){
    final raw=prefs.getStringList(key)??const <String>[];
    return raw.map((v){try{return Map<String,dynamic>.from(jsonDecode(v) as Map);}catch(_){return <String,dynamic>{};}}).where((e)=>e.isNotEmpty).toList();
  }

  Future<YansiProactiveInsight?> scan() async {
    final now=DateTime.now();
    final tasks=_read('yansi_tasks');
    final reminders=_read('yansi_reminders');
    final expenses=_read('yansi_expenses');
    final household=_read('yansi_household');
    final goals=_read('yansi_goals');

    // Highest priority: neglected productivity signal.
    final open=tasks.where((e)=>e['completed']!=true).toList();
    if(open.length>=5){
      return YansiProactiveInsight(title:'ATTENTION NEEDED',message:'You have ${open.length} unfinished tasks. I can rank them by urgency and help you clear the highest-impact work first.',priority:'HIGH',action:'PRIORITIZE',core:'PRODUCTIVITY',data:{'openTasks':open.length});
    }

    // Calendar signal: reminders saved recently or explicitly marked due.
    final due=reminders.where((e){
      final dueText='${e['dueDate']??e['date']??''}';
      final d=DateTime.tryParse(dueText);
      return d!=null && !d.isAfter(now.add(const Duration(days:2)));
    }).toList();
    if(due.isNotEmpty){
      return YansiProactiveInsight(title:'TIME SIGNAL',message:'I found ${due.length} reminder${due.length==1?'':'s'} that may need attention soon. I can help you review the next action.',priority:'HIGH',action:'REVIEW',core:'CALENDAR',data:{'dueCount':due.length});
    }

    // Money signal: compare the latest two calendar-month totals when enough history exists.
    if(expenses.length>=4){
      final monthTotals=<String,double>{};
      for(final e in expenses){
        final d=DateTime.tryParse('${e['date']??''}')??now;
        final key='${d.year}-${d.month}';
        monthTotals[key]=(monthTotals[key]??0)+((e['amount'] as num?)?.toDouble()??0);
      }
      final keys=monthTotals.keys.toList()..sort();
      if(keys.length>=2){
        final previous=monthTotals[keys[keys.length-2]]??0;
        final latest=monthTotals[keys.last]??0;
        if(previous>0 && latest>=previous*1.2){
          final pct=((latest/previous-1)*100).round();
          return YansiProactiveInsight(title:'MONEY ANOMALY',message:'Your latest stored monthly spending is about $pct% higher than the previous month. I can break down where the change came from.',priority:'HIGH',action:'ANALYZE',core:'MONEY',data:{'previous':previous,'latest':latest,'increasePercent':pct});
        }
      }
    }

    // Goal signal: goals exist but have no recent progress marker.
    if(goals.isNotEmpty){
      final stale=goals.where((g){
        final d=DateTime.tryParse('${g['updatedAt']??g['date']??''}');
        return d==null || now.difference(d).inDays>=14;
      }).length;
      if(stale>0){
        return YansiProactiveInsight(title:'GOAL DRIFT',message:'$stale goal${stale==1?'':'s'} have not shown recent progress. I can help turn one into a small action for today.',priority:'MEDIUM',action:'ACTIVATE',core:'GOALS',data:{'staleGoals':stale});
      }
    }

    // Household prediction signal.
    if(household.length>=3){
      final counts=<String,int>{};
      for(final e in household){final item='${e['item']??''}'.trim().toLowerCase();if(item.isNotEmpty)counts[item]=(counts[item]??0)+1;}
      if(counts.isNotEmpty){
        final top=counts.entries.reduce((a,b)=>a.value>=b.value?a:b);
        return YansiProactiveInsight(title:'HOUSEHOLD MEMORY',message:'$top is recurring in your household history. I can predict the next shopping requirement from your pattern.',priority:'LOW',action:'PREDICT',core:'HOUSEHOLD',data:{'item':top.key,'frequency':top.value});
      }
    }

    return null;
  }
}
