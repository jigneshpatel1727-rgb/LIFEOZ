import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight persistence for ambient briefing deduplication and attention memory.
/// Presentation state only: it does not execute LifeOS actions.
class YansiBriefingHistory {
  final SharedPreferences prefs;
  const YansiBriefingHistory({required this.prefs});

  String? get lastHeadline => prefs.getString('yansi_last_briefing_headline');
  DateTime? get lastPresentedAt { final ms=prefs.getInt('yansi_last_briefing_at_ms'); return ms==null?null:DateTime.fromMillisecondsSinceEpoch(ms); }

  Map<String,dynamic>? get lastAttention { final raw=prefs.getString('yansi_last_attention'); if(raw==null)return null; try{return Map<String,dynamic>.from(jsonDecode(raw) as Map);}catch(_){return null;} }

  Future<bool> shouldSurface(String headline,{Duration repeatAfter=const Duration(hours:6),bool materiallyChanged=false}) async {
    final normalized=headline.trim();
    if(normalized.isEmpty)return false;
    if(lastHeadline==null)return true;
    if(normalized!=lastHeadline)return true;
    if(materiallyChanged)return true;
    final shownAt=lastPresentedAt;
    if(shownAt==null)return true;
    return DateTime.now().difference(shownAt)>=repeatAfter;
  }

  Future<bool> shouldSurfaceWithContext(String headline,{required int priority,required int confidence,Duration repeatAfter=const Duration(hours:6)}) async {
    final normalized=headline.trim();
    if(normalized.isEmpty)return false;
    if(lastHeadline==null||normalized!=lastHeadline)return true;
    final oldPriority=prefs.getInt('yansi_last_briefing_priority');
    final oldConfidence=prefs.getInt('yansi_last_briefing_confidence');
    final priorityChanged=oldPriority==null||(priority-oldPriority).abs()>=10;
    final confidenceChanged=oldConfidence==null||(confidence-oldConfidence).abs()>=10;
    final attention=lastAttention;
    final dismissed=attention?['state']=='dismissed';
    final acted=attention?['state']=='acted';
    if(dismissed&&!priorityChanged&&!confidenceChanged)return false;
    if(acted&&!priorityChanged&&!confidenceChanged)return false;
    return shouldSurface(normalized,repeatAfter:repeatAfter,materiallyChanged:priorityChanged||confidenceChanged);
  }

  Future<void> markPresented(String headline,{DateTime? presentedAt,int? priority,int? confidence,String? core,String? key}) async {
    final normalized=headline.trim(); if(normalized.isEmpty)return;
    final at=presentedAt??DateTime.now();
    await prefs.setString('yansi_last_briefing_headline',normalized);
    await prefs.setInt('yansi_last_briefing_at_ms',at.millisecondsSinceEpoch);
    if(priority!=null)await prefs.setInt('yansi_last_briefing_priority',priority.clamp(0,100));
    if(confidence!=null)await prefs.setInt('yansi_last_briefing_confidence',confidence.clamp(0,100));
    await prefs.setString('yansi_last_attention',jsonEncode({'state':'presented','at':at.toIso8601String(),'headline':normalized,'priority':priority?.clamp(0,100),'confidence':confidence?.clamp(0,100),'core':core,'key':key}));
  }

  Future<void> markAttention(String state,{String? headline,int? priority,int? confidence,String? core,String? key}) async {
    final normalized=(headline??lastHeadline??'').trim(); if(normalized.isEmpty)return;
    final at=DateTime.now();
    await prefs.setString('yansi_last_attention',jsonEncode({'state':state.trim().toLowerCase(),'at':at.toIso8601String(),'headline':normalized,'priority':priority?.clamp(0,100),'confidence':confidence?.clamp(0,100),'core':core,'key':key}));
  }

  Future<void> markDismissed({String? headline,String? core,String? key})=>markAttention('dismissed',headline:headline,core:core,key:key);
  Future<void> markActed({String? headline,String? core,String? key})=>markAttention('acted',headline:headline,core:core,key:key);
  Future<void> markIgnored({String? headline,String? core,String? key})=>markAttention('ignored',headline:headline,core:core,key:key);

  /// Backward-compatible alias for older callers.
  Future<void> markSurfaced(String headline)=>markPresented(headline);

  Future<void> clear() async {
    await prefs.remove('yansi_last_briefing_headline');
    await prefs.remove('yansi_last_briefing_at_ms');
    await prefs.remove('yansi_last_briefing_priority');
    await prefs.remove('yansi_last_briefing_confidence');
    await prefs.remove('yansi_last_attention');
  }
}
