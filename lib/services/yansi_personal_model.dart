import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_memory_layer.dart';

/// Builds a private, user-controlled behavior/context profile from approved
/// LifeOS memories. It records observable patterns, not clinical diagnoses or
/// sensitive psychological attributes.
class YansiPersonalModel {
  final SharedPreferences prefs;
  const YansiPersonalModel({required this.prefs});

  Map<String,dynamic> get profile {
    final raw=prefs.getString('yansi_personal_model');
    if(raw==null)return <String,dynamic>{};
    try{return Map<String,dynamic>.from(jsonDecode(raw) as Map);}catch(_){return <String,dynamic>{};}
  }

  Future<Map<String,dynamic>> learnFromApprovedMemory() async {
    final memories=YansiMemoryLayer(prefs:prefs).entries;
    final counts=<String,int>{};
    final sources=<String,int>{};
    final topics=<String,int>{};
    for(final m in memories){
      counts[m.type]=(counts[m.type]??0)+1;
      sources[m.source]=(sources[m.source]??0)+1;
      for(final token in m.text.toLowerCase().split(RegExp(r'[^a-z0-9]+')).where((x)=>x.length>=4)){
        topics[token]=(topics[token]??0)+1;
      }
    }
    final topTopics=topics.entries.toList()..sort((a,b)=>b.value.compareTo(a.value));
    final next=<String,dynamic>{
      'version':1,
      'updatedAt':DateTime.now().toIso8601String(),
      'observedMemoryTypes':counts,
      'interactionSources':sources,
      'frequentTopics':topTopics.take(12).map((e)=>e.key).toList(),
      'memoryCount':memories.length,
      'learningMode':'approved-local-history',
    };
    await prefs.setString('yansi_personal_model',jsonEncode(next));
    return next;
  }

  Future<void> setPreference(String key,dynamic value) async {
    final p=profile;
    final preferences=Map<String,dynamic>.from((p['preferences'] as Map?)??{});
    preferences[key]=value;
    p['preferences']=preferences;
    p['updatedAt']=DateTime.now().toIso8601String();
    await prefs.setString('yansi_personal_model',jsonEncode(p));
  }

  Future<void> clearModel() async => prefs.remove('yansi_personal_model');
}
