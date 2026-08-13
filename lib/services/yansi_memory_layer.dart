import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Small, local-first memory layer for approved LifeOS interactions.
/// Stores explicit observations, preferences and completed actions only.
/// It does not infer sensitive personal attributes and never stores raw audio.
class YansiMemoryEntry {
  final String id,type,text,source;
  final DateTime createdAt;
  final Map<String,dynamic> data;
  const YansiMemoryEntry({required this.id,required this.type,required this.text,required this.source,required this.createdAt,this.data=const {}});
  Map<String,dynamic> toJson()=>{'id':id,'type':type,'text':text,'source':source,'createdAt':createdAt.toIso8601String(),'data':data};
  static YansiMemoryEntry? fromJson(String raw){try{final m=jsonDecode(raw) as Map;return YansiMemoryEntry(id:'${m['id']}',type:'${m['type']}',text:'${m['text']}',source:'${m['source']}',createdAt:DateTime.tryParse('${m['createdAt']}')??DateTime.now(),data:Map<String,dynamic>.from((m['data'] as Map?)??{}));}catch(_){return null;}}
}

class YansiMemoryLayer {
  final SharedPreferences prefs;
  static const _key='yansi_memory_entries';
  const YansiMemoryLayer({required this.prefs});
  List<YansiMemoryEntry> get entries=>(prefs.getStringList(_key)??const <String>[]).map(YansiMemoryEntry.fromJson).whereType<YansiMemoryEntry>().toList();

  Future<void> remember({required String type,required String text,required String source,Map<String,dynamic> data=const {}})async{
    if(text.trim().isEmpty)return;
    final list=entries;
    list.add(YansiMemoryEntry(id:'ym_${DateTime.now().microsecondsSinceEpoch}',type:type,text:text.trim(),source:source,createdAt:DateTime.now(),data:data));
    final trimmed=list.length>200?list.sublist(list.length-200):list;
    await prefs.setStringList(_key,trimmed.map((e)=>jsonEncode(e.toJson())).toList());
  }

  List<YansiMemoryEntry> search(String query,{int limit=8}){
    final q=query.toLowerCase().trim();if(q.isEmpty)return entries.reversed.take(limit).toList();
    final scored=<MapEntry<YansiMemoryEntry,int>>[];
    for(final e in entries){var score=0;for(final token in q.split(RegExp(r'\s+')).where((x)=>x.length>1)){if(e.text.toLowerCase().contains(token))score++;if(e.type.toLowerCase().contains(token))score++;}if(score>0)scored.add(MapEntry(e,score));}
    scored.sort((a,b){final s=b.value.compareTo(a.value);return s!=0?s:b.key.createdAt.compareTo(a.key.createdAt);});
    return scored.take(limit).map((e)=>e.key).toList();
  }

  Future<void> forgetAll()async=>prefs.remove(_key);
  Future<void> forgetType(String type)async{final keep=entries.where((e)=>e.type!=type);await prefs.setStringList(_key,keep.map((e)=>jsonEncode(e.toJson())).toList());}
}
