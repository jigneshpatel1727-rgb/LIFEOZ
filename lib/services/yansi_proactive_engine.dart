import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-first proactive intelligence. It never performs sensitive actions;
/// it only detects useful signals and prepares an explainable suggestion.
class YansiProactiveInsight {
  final String title;
  final String message;
  final String priority;
  final String action;
  const YansiProactiveInsight({required this.title,required this.message,required this.priority,required this.action});
}

class YansiProactiveEngine {
  final SharedPreferences prefs;
  const YansiProactiveEngine({required this.prefs});

  List<Map<String,dynamic>> _read(String key){
    final raw=prefs.getStringList(key)??const <String>[];
    return raw.map((v){try{return Map<String,dynamic>.from(jsonDecode(v) as Map);}catch(_){return <String,dynamic>{};}}).where((e)=>e.isNotEmpty).toList();
  }

  Future<YansiProactiveInsight?> scan() async {
    final tasks=_read('yansi_tasks');
    final reminders=_read('yansi_reminders');
    final expenses=_read('yansi_expenses');
    final household=_read('yansi_household');
    final now=DateTime.now();

    final openTasks=tasks.where((e)=>e['completed']!=true).length;
    if(openTasks>=5){
      return const YansiProactiveInsight(title:'ATTENTION NEEDED',message:'You have several unfinished tasks. I can help you prioritize the most important ones.',priority:'HIGH',action:'PRIORITIZE');
    }

    final recentReminders=reminders.where((e){
      final d=DateTime.tryParse('${e['date']??''}');
      return d!=null && now.difference(d).inDays<=1;
    }).length;
    if(recentReminders>0){
      return const YansiProactiveInsight(title:'LIFE SIGNAL',message:'You have a recent reminder in your LifeOS memory. I can help turn it into a clear next action.',priority:'MEDIUM',action:'REVIEW');
    }

    if(expenses.length>=4){
      final recent=expenses.take(10).fold<double>(0,(s,e)=>s+((e['amount'] as num?)?.toDouble()??0));
      if(recent>0){
        return YansiProactiveInsight(title:'MONEY PULSE',message:'I detected recent spending activity. I can analyze the pattern and look for a saving opportunity.',priority:'MEDIUM',action:'ANALYZE');
      }
    }

    if(household.length>=3){
      final counts=<String,int>{};
      for(final e in household){final item='${e['item']??''}'.trim().toLowerCase();if(item.isNotEmpty)counts[item]=(counts[item]??0)+1;}
      if(counts.isNotEmpty){
        final top=counts.entries.reduce((a,b)=>a.value>=b.value?a:b);
        return YansiProactiveInsight(title:'HOUSEHOLD MEMORY',message:'$top is appearing repeatedly in your household history. I can help predict recurring needs.',priority:'LOW',action:'PREDICT');
      }
    }

    return null;
  }
}
