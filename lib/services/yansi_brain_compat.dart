part of 'yansi_brain.dart';

/// Compatibility/report API used by the existing LifeOS report screen.
extension YansiReportApi on YansiBrain {
  Future<List<Map<String, dynamic>>> getMemory() async {
    const keys = [YansiBrain._expenseKey,YansiBrain._incomeKey,YansiBrain._taskKey,YansiBrain._reminderKey,YansiBrain._householdKey,YansiBrain._goalKey,YansiBrain._diaryKey];
    final records=<Map<String,dynamic>>[];
    for(final key in keys){records.addAll(_readRecords(key));}
    records.sort((a,b){final ad=DateTime.tryParse((a['date']??'').toString());final bd=DateTime.tryParse((b['date']??'').toString());return (bd??DateTime.fromMillisecondsSinceEpoch(0)).compareTo(ad??DateTime.fromMillisecondsSinceEpoch(0));});
    return records;
  }

  Future<Map<String,dynamic>> getSummary() async {
    final memory=await getMemory();double income=0,expenses=0;
    for(final record in memory){final amount=(record['amount'] as num?)?.toDouble()??0;if(record['type']=='income'){income+=amount;}else if(record['type']=='expense'){expenses+=amount;}}
    return {'income':income,'expenses':expenses,'balance':income-expenses,'recordCount':memory.length};
  }
}

/// Controlled execution boundary for Yansi action plans.
extension YansiActionExecutionApi on YansiBrain {
  Future<Map<String,dynamic>> executePlan(YansiActionPlan plan,YansiResult result,{bool userConfirmed=false}) async {
    final sensitive=_isSensitiveAction(plan.action,result.intent);
    final targetCore=_targetCoreFor(result.intent);
    if(sensitive&&!userConfirmed){return {'executed':false,'requiresConfirmation':true,'reason':'This action requires your confirmation before execution.','action':plan.action,'intent':result.intent.name,'targetCore':targetCore};}
    final fingerprint=_actionFingerprint(plan,result);
    final raw=prefs.getStringList('yansi_executed_actions')??<String>[];
    final now=DateTime.now();
    for(final value in raw.reversed.take(20)){
      try{final previous=Map<String,dynamic>.from(jsonDecode(value) as Map);final previousFingerprint=(previous['fingerprint']??'').toString();final previousDate=DateTime.tryParse((previous['date']??'').toString());if(previousFingerprint==fingerprint&&previousDate!=null&&now.difference(previousDate).inSeconds<=12){return {...previous,'executed':false,'duplicateSuppressed':true,'requiresConfirmation':false,'speak':'I already handled that.'};}}catch(_){ }
    }
    final execution=<String,dynamic>{'id':DateTime.now().microsecondsSinceEpoch.toString(),'intent':result.intent.name,'action':plan.action,'title':plan.title,'confidence':plan.confidence,'confirmed':userConfirmed,'executed':true,'targetCore':targetCore,'operation':'local_lifeos_update','fingerprint':fingerprint,'date':DateTime.now().toIso8601String(),'data':result.data};
    raw.add(jsonEncode(execution));if(raw.length>100){raw.removeRange(0,raw.length-100);}await prefs.setStringList('yansi_executed_actions',raw);return execution;
  }

  Future<Map<String,dynamic>> undoLastAction() async {
    final raw=prefs.getStringList('yansi_executed_actions')??<String>[];
    if(raw.isEmpty)return {'undone':false,'reason':'There is no recent Yansi action to undo.','speak':'There is nothing recent for me to undo.'};
    Map<String,dynamic>? execution;
    for(final value in raw.reversed){try{final item=Map<String,dynamic>.from(jsonDecode(value) as Map);if(item['executed']==true&&item['data'] is Map){execution=item;break;}}catch(_){}}
    if(execution==null)return {'undone':false,'reason':'No reversible action found.','speak':'I could not find a reversible action.'};
    final intentName=(execution['intent']??'unknown').toString();
    YansiIntent? intent;
    for(final candidate in YansiIntent.values){if(candidate.name==intentName){intent=candidate;break;}}
    if(intent==null)return {'undone':false,'reason':'Unknown action type.','speak':'I cannot safely undo that action.'};
    final key=_keyForIntent(intent);final id=((execution['data'] as Map)['id']??'').toString();
    if(id.isEmpty)return {'undone':false,'reason':'The original record has no stable id.','speak':'I cannot safely undo that action.'};
    final records=_readRecords(key);final index=records.indexWhere((r)=>r['id'].toString()==id);
    if(index<0)return {'undone':false,'reason':'The original record is no longer present.','speak':'That item is already gone, so there is nothing to undo.'};
    records.removeAt(index);await _replaceRecords(key,records);
    return {'undone':true,'intent':intent.name,'targetCore':_targetCoreFor(intent),'recordId':id,'speak':'Done. I undid my last update.'};
  }

  Future<List<Map<String,dynamic>>> proactiveSuggestions() async {
    final snapshot=crossCoreSnapshot();final suggestions=<Map<String,dynamic>>[];final openTasks=(snapshot['openTaskCount'] as int?)??0;final reminders=(snapshot['reminderCount'] as int?)??0;final expenses=(snapshot['expenseCount'] as int?)??0;final goals=(snapshot['goalCount'] as int?)??0;final household=(snapshot['householdCount'] as int?)??0;
    if(openTasks>=3)suggestions.add({'priority':92,'core':'productivity','title':'Reduce task load','message':'You have $openTasks open tasks. I can help you choose the highest-value next task.','action':'prioritize_tasks'});
    if(reminders>=3)suggestions.add({'priority':88,'core':'calendar','title':'Review upcoming dates','message':'You have $reminders reminders stored. I can surface the most time-sensitive ones.','action':'review_calendar'});
    if(expenses>=5)suggestions.add({'priority':82,'core':'money','title':'Check spending pattern','message':'Your spending history is large enough for a more useful trend check.','action':'analyze_spending'});
    if(goals>0&&openTasks>0)suggestions.add({'priority':86,'core':'goals','title':'Align tasks with goals','message':'I can connect your open work to your active goals and highlight what matters most.','action':'align_goals_tasks'});
    if(household>=4)suggestions.add({'priority':76,'core':'household','title':'Predict recurring needs','message':'Your household history is sufficient to improve recurring-item suggestions.','action':'predict_household'});
    if(suggestions.isEmpty)suggestions.add({'priority':55,'core':'yansi','title':'Build your LifeOS context','message':'Keep using Yansi naturally. I will learn useful patterns from the information you choose to store.','action':'build_context'});
    suggestions.sort((a,b)=>(b['priority'] as int).compareTo(a['priority'] as int));return suggestions.take(5).toList();
  }

  Map<String,dynamic> decisionTrace(YansiResult result,YansiActionPlan plan){
    final snapshot=crossCoreSnapshot();final supportingCores=<String>[];final reasons=<String>[];
    switch(result.intent){case YansiIntent.expense:case YansiIntent.income:supportingCores.add('money');reasons.add('The request contains a financial signal.');break;case YansiIntent.task:supportingCores.add('productivity');reasons.add('The request contains an actionable task signal.');break;case YansiIntent.reminder:supportingCores.add('calendar');reasons.add('The request contains a time or reminder signal.');break;case YansiIntent.household:supportingCores.add('household');reasons.add('The request matches household or shopping context.');break;case YansiIntent.goal:supportingCores.add('goals');reasons.add('The request contains a goal or target signal.');break;case YansiIntent.diary:supportingCores.add('diary');reasons.add('The request contains personal reflection context.');break;case YansiIntent.question:supportingCores.add('yansi');reasons.add('The request is being handled as a reasoning query.');break;case YansiIntent.unknown:supportingCores.add('yansi');reasons.add('The signal is not yet specific enough for a core action.');break;}
    if((snapshot['openTaskCount'] as int? ?? 0)>0&&result.intent==YansiIntent.goal){supportingCores.add('productivity');reasons.add('Open tasks provide supporting execution context for the goal.');}
    if((snapshot['expenseCount'] as int? ?? 0)>=5&&result.intent==YansiIntent.question){supportingCores.add('money');reasons.add('Stored spending history can support the answer.');}
    final confidence=(plan.confidence*100).round().clamp(0,100);final safe=plan.safeToAutoApply&&confidence>=80;
    return {'intent':result.intent.name,'confidence':confidence,'autoApplyEligible':safe,'supportingCores':supportingCores.toSet().toList(),'reasons':reasons,'targetCore':_targetCoreFor(result.intent)};
  }

  /// Stores a compact session focus so follow-up turns can retain context without exposing raw history.
  Future<void> setSessionFocus(String focus,{String? core}) async {
    await prefs.setString('yansi_session_focus',jsonEncode({'focus':focus.trim(),'core':core,'date':DateTime.now().toIso8601String()}));
  }

  Map<String,dynamic>? getSessionFocus(){
    final raw=prefs.getString('yansi_session_focus');
    if(raw==null||raw.trim().isEmpty)return null;
    try{return Map<String,dynamic>.from(jsonDecode(raw) as Map);}catch(_){return null;}
  }

  /// Returns a safe contextual cue for a follow-up turn, without returning private history.
  Map<String,dynamic> contextualCue(){
    final focus=getSessionFocus();
    if(focus==null)return {'hasContext':false,'cue':'No active session focus.'};
    final value=(focus['focus']??'').toString().trim();
    final core=(focus['core']??'').toString().trim();
    if(value.isEmpty)return {'hasContext':false,'cue':'No active session focus.'};
    return {'hasContext':true,'focus':value,'core':core.isEmpty?null:core,'cue':'Continue the current $value context.'};
  }

  Future<void> clearSessionFocus() async => prefs.remove('yansi_session_focus');

  String _keyForIntent(YansiIntent intent){switch(intent){case YansiIntent.expense:return YansiBrain._expenseKey;case YansiIntent.income:return YansiBrain._incomeKey;case YansiIntent.task:return YansiBrain._taskKey;case YansiIntent.reminder:return YansiBrain._reminderKey;case YansiIntent.household:return YansiBrain._householdKey;case YansiIntent.goal:return YansiBrain._goalKey;case YansiIntent.diary:return YansiBrain._diaryKey;case YansiIntent.question:case YansiIntent.unknown:return '';}}
  Future<void> _replaceRecords(String key,List<Map<String,dynamic>> records) async {if(key.isEmpty)return;await prefs.setStringList(key,records.map(jsonEncode).toList());}
  String _actionFingerprint(YansiActionPlan plan,YansiResult result){final amount=result.amount?.toStringAsFixed(2)??'';final item=(result.item??'').trim().toLowerCase();final text=result.originalText.trim().toLowerCase().replaceAll(RegExp(r'\s+'),' ');return '${result.intent.name}|${plan.action.toLowerCase()}|$amount|$item|$text';}
  Map<String,dynamic> actionReceipt(Map<String,dynamic> execution){final core=(execution['targetCore']??'yansi').toString();final action=(execution['action']??'Action').toString();final executed=execution['executed']==true;final confirmed=execution['confirmed']==true;final needsConfirmation=execution['requiresConfirmation']==true;final duplicate=execution['duplicateSuppressed']==true;String message;if(needsConfirmation){message='I need your confirmation before I do that.';}else if(duplicate){message='I already handled that.';}else if(executed){message=confirmed?'Done. I completed the $core action.':'Done. I updated $core in LifeOS.';}else{message='I could not complete that action.';}return {'speak':message,'core':core,'action':action,'completed':executed,'duplicateSuppressed':duplicate,'requiresConfirmation':needsConfirmation,'timestamp':execution['date']??DateTime.now().toIso8601String()};}
  String _targetCoreFor(YansiIntent intent){switch(intent){case YansiIntent.expense:case YansiIntent.income:return 'money';case YansiIntent.task:return 'productivity';case YansiIntent.reminder:return 'calendar';case YansiIntent.household:return 'household';case YansiIntent.goal:return 'goals';case YansiIntent.diary:return 'diary';case YansiIntent.question:case YansiIntent.unknown:return 'yansi';}}
  bool _isSensitiveAction(String action,YansiIntent intent){final normalized=action.toLowerCase();if(normalized.contains('transfer')||normalized.contains('send money')||normalized.contains('delete')||normalized.contains('purchase')||normalized.contains('external')||normalized.contains('permission'))return true;return intent==YansiIntent.reminder;}
  Future<List<Map<String,dynamic>>> getExecutedActions() async {final raw=prefs.getStringList('yansi_executed_actions')??<String>[];return raw.map((value){try{return Map<String,dynamic>.from(jsonDecode(value) as Map);}catch(_){return <String,dynamic>{};}}).where((item)=>item.isNotEmpty).toList();}
}
