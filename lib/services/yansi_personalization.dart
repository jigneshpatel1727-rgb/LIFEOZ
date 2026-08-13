import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight local personalization. It learns only from explicit action outcomes
/// and intent frequency; it never infers sensitive attributes.
class YansiPersonalization {
  final SharedPreferences prefs;
  const YansiPersonalization({required this.prefs});

  static const _key = 'yansi_personalization_v1';

  Map<String,dynamic> _read(){
    final raw=prefs.getString(_key);
    if(raw==null)return {};
    try{return Map<String,dynamic>.from(jsonDecode(raw) as Map);}catch(_){return {};}
  }

  Future<void> recordOutcome({required String action,required bool success}) async {
    final m=_read();
    final actions=Map<String,dynamic>.from((m['actions'] as Map?)??{});
    final current=Map<String,dynamic>.from((actions[action] as Map?)??{});
    current['attempts']=((current['attempts'] as num?)?.toInt()??0)+1;
    if(success)current['successes']=((current['successes'] as num?)?.toInt()??0)+1;
    current['lastAt']=DateTime.now().toIso8601String();
    actions[action]=current;m['actions']=actions;
    await prefs.setString(_key,jsonEncode(m));
  }

  double score(String action){
    final current=Map<String,dynamic>.from((_read()['actions'] as Map?)?[action] as Map? ?? {});
    final attempts=(current['attempts'] as num?)?.toInt()??0;
    final successes=(current['successes'] as num?)?.toInt()??0;
    if(attempts==0)return .5;
    return (successes/attempts).clamp(.1,.95).toDouble();
  }

  Map<String,double> rank(Iterable<String> actions){
    final result=<String,double>{for(final a in actions)a:score(a)};
    return result;
  }

  Map<String,dynamic> snapshot()=>_read();
  Future<void> forget() => prefs.remove(_key);
}
