import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Turns Yansi insights into safe, explainable actions.
///
/// Read-only and reversible actions may run immediately. Sensitive actions
/// are represented as pending confirmations and are never executed silently.
enum YansiActionRisk { safe, confirm }

enum YansiActionType {
  prioritizeTasks,
  reviewReminders,
  analyzeSpending,
  activateGoal,
  predictHousehold,
}

class YansiActionProposal {
  final YansiActionType type;
  final YansiActionRisk risk;
  final String title;
  final String explanation;
  final Map<String, dynamic> data;
  const YansiActionProposal({required this.type,required this.risk,required this.title,required this.explanation,this.data=const {}});
}

class YansiActionResult {
  final bool completed;
  final bool needsConfirmation;
  final String message;
  final Map<String,dynamic> data;
  const YansiActionResult({required this.completed,required this.needsConfirmation,required this.message,this.data=const {}});
}

class YansiActionOrchestrator {
  final SharedPreferences prefs;
  const YansiActionOrchestrator({required this.prefs});

  YansiActionProposal proposal(String action, {Map<String,dynamic> data=const {}}) {
    switch(action.toUpperCase()) {
      case 'PRIORITIZE':
        return YansiActionProposal(type:YansiActionType.prioritizeTasks,risk:YansiActionRisk.safe,title:'Prioritize today',explanation:'Rank your open tasks using urgency and existing LifeOS context.',data:data);
      case 'REVIEW':
        return YansiActionProposal(type:YansiActionType.reviewReminders,risk:YansiActionRisk.safe,title:'Review upcoming events',explanation:'Bring the most relevant reminders into focus.',data:data);
      case 'ANALYZE':
        return YansiActionProposal(type:YansiActionType.analyzeSpending,risk:YansiActionRisk.safe,title:'Analyze money pattern',explanation:'Compare recent spending and identify the main driver of change.',data:data);
      case 'ACTIVATE':
        return YansiActionProposal(type:YansiActionType.activateGoal,risk:YansiActionRisk.safe,title:'Activate a goal',explanation:'Turn a drifting goal into one small actionable step.',data:data);
      default:
        return YansiActionProposal(type:YansiActionType.predictHousehold,risk:YansiActionRisk.safe,title:'Predict household needs',explanation:'Use recurring purchase history to prepare a suggested list.',data:data);
    }
  }

  Future<YansiActionResult> execute(YansiActionProposal proposal,{bool confirmed=false}) async {
    if(proposal.risk==YansiActionRisk.confirm && !confirmed) {
      await _pending(proposal);
      return const YansiActionResult(completed:false,needsConfirmation:true,message:'I prepared the action, but I need your confirmation before I execute it.');
    }
    switch(proposal.type) {
      case YansiActionType.prioritizeTasks:
        final tasks=_records('yansi_tasks');
        tasks.sort((a,b)=>_priority(b).compareTo(_priority(a)));
        await _save('yansi_tasks',tasks.take(100).toList());
        return YansiActionResult(completed:true,needsConfirmation:false,message:'I prioritized your open tasks. Your highest-priority items are ready to review.',data:{'count':tasks.length});
      case YansiActionType.reviewReminders:
        await prefs.setString('yansi_focus_mode','calendar');
        return const YansiActionResult(completed:true,needsConfirmation:false,message:'I focused LifeOS on the reminders that need attention next.');
      case YansiActionType.analyzeSpending:
        await prefs.setString('yansi_focus_mode','money');
        return const YansiActionResult(completed:true,needsConfirmation:false,message:'I opened the money intelligence focus. Yansi can now explain the spending change.');
      case YansiActionType.activateGoal:
        await prefs.setString('yansi_focus_mode','goals');
        return const YansiActionResult(completed:true,needsConfirmation:false,message:'I activated your goals intelligence focus so the next useful step can be identified.');
      case YansiActionType.predictHousehold:
        await prefs.setString('yansi_focus_mode','household');
        return const YansiActionResult(completed:true,needsConfirmation:false,message:'I prepared household intelligence focus for recurring needs.');
    }
  }

  Future<void> _pending(YansiActionProposal p) async => prefs.setString('yansi_pending_action',jsonEncode({'type':p.type.name,'title':p.title,'explanation':p.explanation,'data':p.data,'createdAt':DateTime.now().toIso8601String()}));
  int _priority(Map<String,dynamic> t){if(t['priority'] is num)return (t['priority'] as num).toInt();final s='${t['urgency']??''}'.toLowerCase();if(s.contains('high')||s.contains('urgent'))return 3;if(s.contains('medium'))return 2;return 1;}
  List<Map<String,dynamic>> _records(String key){final raw=prefs.getStringList(key)??const <String>[];return raw.map((v){try{return Map<String,dynamic>.from(jsonDecode(v) as Map);}catch(_){return <String,dynamic>{};}}).where((e)=>e.isNotEmpty).toList();}
  Future<void> _save(String key,List<Map<String,dynamic>> records)async=>prefs.setStringList(key,records.map(jsonEncode).toList());
}
