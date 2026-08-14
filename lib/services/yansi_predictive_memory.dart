import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Learns recurring, user-permitted patterns without changing app code or behavior.
/// It produces predictions only; actions remain outside this service.
class YansiPrediction {
  final String key;
  final String core;
  final String title;
  final int occurrences;
  final double confidence;
  final String reason;

  const YansiPrediction({required this.key,required this.core,required this.title,required this.occurrences,required this.confidence,required this.reason});

  Map<String,dynamic> toJson()=>{'key':key,'core':core,'title':title,'occurrences':occurrences,'confidence':confidence,'reason':reason};
}

class YansiPredictiveMemory {
  final SharedPreferences prefs;
  const YansiPredictiveMemory({required this.prefs});

  List<Map<String,dynamic>> _read(String key){
    final raw=prefs.getStringList(key)??const <String>[];
    return raw.map((v){try{return Map<String,dynamic>.from(jsonDecode(v) as Map);}catch(_){return <String,dynamic>{};}}).where((e)=>e.isNotEmpty).toList();
  }

  String _normalize(String value)=>value.trim().toLowerCase().replaceAll(RegExp(r'\\s+'),' ');

  Future<List<YansiPrediction>> scan({int lookbackDays=90}) async {
    final now=DateTime.now();
    final buckets=<String,Map<String,dynamic>>{};
    void observe(String core,String title,String dateValue){
      final date=DateTime.tryParse(dateValue);if(date==null||date.isAfter(now)||now.difference(date).inDays>lookbackDays)return;
      final normalized=_normalize(title);if(normalized.isEmpty)return;
      final key='$core|$normalized';
      final bucket=buckets.putIfAbsent(key,()=>{'core':core,'title':title.trim(),'count':0,'days':<String>{}});
      bucket['count']=(bucket['count'] as int)+1;
      (bucket['days'] as Set<String>).add('${date.year}-${date.month}-${date.day}');
    }
    for(final e in _read('yansi_tasks'))observe('PRODUCTIVITY','${e['title']??e['name']??''}','${e['date']??e['createdAt']??''}');
    for(final e in _read('yansi_reminders'))observe('CALENDAR','${e['title']??e['name']??''}','${e['dueDate']??e['date']??e['createdAt']??''}');
    for(final e in _read('yansi_household'))observe('HOUSEHOLD','${e['item']??e['title']??e['name']??''}','${e['date']??e['createdAt']??''}');
    for(final e in _read('yansi_goals'))observe('GOALS','${e['title']??e['name']??''}','${e['date']??e['createdAt']??''}');
    for(final e in _read('yansi_diary'))observe('PERSONAL','${e['title']??e['theme']??e['text']??''}','${e['date']??e['createdAt']??''}');

    final predictions=<YansiPrediction>[];
    for(final entry in buckets.entries){
      final b=entry.value;final count=b['count'] as int;final distinctDays=(b['days'] as Set<String>).length;
      if(count<2)continue;
      final confidence=(0.45+(count.clamp(2,8)-2)*0.07+(distinctDays>2?0.08:0)).clamp(0,0.92).toDouble();
      predictions.add(YansiPrediction(key:entry.key,core:b['core'] as String,title:b['title'] as String,occurrences:count,confidence:confidence,reason:'Observed $count occurrences across $distinctDays days in the last $lookbackDays days.'));
    }
    predictions.sort((a,b){final c=b.confidence.compareTo(a.confidence);return c!=0?c:b.occurrences.compareTo(a.occurrences);});
    await prefs.setString('yansi_predictive_memory',jsonEncode(predictions.map((e)=>e.toJson()).toList()));
    return predictions.take(10).toList();
  }

  List<YansiPrediction> last(){
    final raw=prefs.getString('yansi_predictive_memory');if(raw==null)return const [];
    try{return (jsonDecode(raw) as List).map((e){final m=Map<String,dynamic>.from(e as Map);return YansiPrediction(key:'${m['key']}',core:'${m['core']}',title:'${m['title']}',occurrences:(m['occurrences'] as num?)?.toInt()??0,confidence:(m['confidence'] as num?)?.toDouble()??0,reason:'${m['reason']}');}).toList();}catch(_){return const [];}
  }
}
