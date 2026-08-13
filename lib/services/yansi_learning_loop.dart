import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Small, local-first adaptation layer for Yansi.
/// It learns from explicit outcomes and repeated LifeOS patterns, not from
/// hidden personal attributes. It does not rewrite code or change permissions.
class YansiLearningProfile {
  final Map<String,int> successfulActions;
  final Map<String,int> dismissedActions;
  final Map<String,int> observedIntents;
  final DateTime updatedAt;

  const YansiLearningProfile({required this.successfulActions,required this.dismissedActions,required this.observedIntents,required this.updatedAt});

  Map<String,dynamic> toJson()=>{'successfulActions':successfulActions,'dismissedActions':dismissedActions,'observedIntents':observedIntents,'updatedAt':updatedAt.toIso8601String()};
}

class YansiLearningLoop {
  final SharedPreferences prefs;
  const YansiLearningLoop({required this.prefs});
  static const _key='yansi_learning_profile';

  YansiLearningProfile load(){
    final raw=prefs.getString(_key);
    if(raw==null)return YansiLearningProfile(successfulActions:{},dismissedActions:{},observedIntents:{},updatedAt:DateTime.now());
    try{
      final m=jsonDecode(raw) as Map;
      Map<String,int> map(dynamic v)=>Map<String,int>.from((v as Map?)?.map((k,v)=>MapEntry('$k',(v as num).toInt()))??{});
      return YansiLearningProfile(successfulActions:map(m['successfulActions']),dismissedActions:map(m['dismissedActions']),observedIntents:map(m['observedIntents']),updatedAt:DateTime.tryParse('${m['updatedAt']}')??DateTime.now());
    }catch(_){return YansiLearningProfile(successfulActions:{},dismissedActions:{},observedIntents:{},updatedAt:DateTime.now());}
  }

  Future<void> recordIntent(String intent)async{
    final p=load();final m={...p.observedIntents};m[intent]=(m[intent]??0)+1;await _save(p,m,null,null);
  }

  Future<void> recordAction(String action,{required bool successful})async{
    final p=load();final good={...p.successfulActions};final dismissed={...p.dismissedActions};
    final target=successful?good:dismissed;target[action]=(target[action]??0)+1;
    await _save(p,null,good,dismissed);
  }

  double actionAffinity(String action){
    final p=load();final good=p.successfulActions[action]??0;final bad=p.dismissedActions[action]??0;
    return ((good+1)/(good+bad+2)).clamp(.05,.95);
  }

  String? preferredAction(Iterable<String> actions){
    final list=actions.toList();if(list.isEmpty)return null;list.sort((a,b)=>actionAffinity(b).compareTo(actionAffinity(a)));return list.first;
  }

  Future<void> forget()async=>prefs.remove(_key);

  Future<void> _save(YansiLearningProfile old,Map<String,int>? intents,Map<String,int>? good,Map<String,int>? bad)async{
    await prefs.setString(_key,jsonEncode(YansiLearningProfile(successfulActions:good??old.successfulActions,dismissedActions:bad??old.dismissedActions,observedIntents:intents??old.observedIntents,updatedAt:DateTime.now()).toJson()));
  }
}
