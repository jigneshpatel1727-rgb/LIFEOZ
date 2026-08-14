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
/// Local LifeOS actions can execute automatically; sensitive actions require
/// an explicit confirmation from the user.
extension YansiActionExecutionApi on YansiBrain {
  Future<Map<String,dynamic>> executePlan(YansiActionPlan plan,YansiResult result,{bool userConfirmed=false}) async {
    final sensitive=_isSensitiveAction(plan.action,result.intent);
    final targetCore=_targetCoreFor(result.intent);
    if(sensitive&&!userConfirmed){return {'executed':false,'requiresConfirmation':true,'reason':'This action requires your confirmation before execution.','action':plan.action,'intent':result.intent.name,'targetCore':targetCore};}

    // Voice recognition can emit the same final transcript more than once.
    // Deduplicate identical actions within a short safety window so Yansi
    // cannot accidentally double-add an expense/task from one utterance.
    final fingerprint=_actionFingerprint(plan,result);
    final raw=prefs.getStringList('yansi_executed_actions')??<String>[];
    final now=DateTime.now();
    for(final value in raw.reversed.take(20)){
      try{
        final previous=Map<String,dynamic>.from(jsonDecode(value) as Map);
        final previousFingerprint=(previous['fingerprint']??'').toString();
        final previousDate=DateTime.tryParse((previous['date']??'').toString());
        if(previousFingerprint==fingerprint&&previousDate!=null&&now.difference(previousDate).inSeconds<=12){
          return {...previous,'executed':false,'duplicateSuppressed':true,'requiresConfirmation':false,'speak':'I already handled that.'};
        }
      }catch(_){ }
    }

    final execution=<String,dynamic>{'id':DateTime.now().microsecondsSinceEpoch.toString(),'intent':result.intent.name,'action':plan.action,'title':plan.title,'confidence':plan.confidence,'confirmed':userConfirmed,'executed':true,'targetCore':targetCore,'operation':'local_lifeos_update','fingerprint':fingerprint,'date':DateTime.now().toIso8601String(),'data':result.data};
    raw.add(jsonEncode(execution));if(raw.length>100){raw.removeRange(0,raw.length-100);}await prefs.setStringList('yansi_executed_actions',raw);return execution;
  }

  String _actionFingerprint(YansiActionPlan plan,YansiResult result){
    final amount=result.amount?.toStringAsFixed(2)??'';
    final item=(result.item??'').trim().toLowerCase();
    final text=result.originalText.trim().toLowerCase().replaceAll(RegExp(r'\\s+'),' ');
    return '${result.intent.name}|${plan.action.toLowerCase()}|$amount|$item|$text';
  }

  /// Produces a concise receipt for the ambient Yansi layer/UI after an action.
  /// The receipt is data-only so the UI can speak or render it without adding
  /// a chatbot-style screen.
  Map<String,dynamic> actionReceipt(Map<String,dynamic> execution){
    final core=(execution['targetCore']??'yansi').toString();
    final action=(execution['action']??'Action').toString();
    final executed=execution['executed']==true;
    final confirmed=execution['confirmed']==true;
    final needsConfirmation=execution['requiresConfirmation']==true;
    final duplicate=execution['duplicateSuppressed']==true;
    String message;
    if(needsConfirmation){
      message='I need your confirmation before I do that.';
    }else if(duplicate){
      message='I already handled that.';
    }else if(executed){
      message=confirmed?'Done. I completed the $core action.':'Done. I updated $core in LifeOS.';
    }else{
      message='I could not complete that action.';
    }
    return {'speak':message,'core':core,'action':action,'completed':executed,'duplicateSuppressed':duplicate,'requiresConfirmation':needsConfirmation,'timestamp':execution['date']??DateTime.now().toIso8601String()};
  }

  String _targetCoreFor(YansiIntent intent){switch(intent){case YansiIntent.expense:case YansiIntent.income:return 'money';case YansiIntent.task:return 'productivity';case YansiIntent.reminder:return 'calendar';case YansiIntent.household:return 'household';case YansiIntent.goal:return 'goals';case YansiIntent.diary:return 'diary';case YansiIntent.question:return 'yansi';case YansiIntent.unknown:return 'yansi';}}

  bool _isSensitiveAction(String action,YansiIntent intent){final normalized=action.toLowerCase();if(normalized.contains('transfer')||normalized.contains('send money')||normalized.contains('delete')||normalized.contains('purchase')||normalized.contains('external')||normalized.contains('permission'))return true;return intent==YansiIntent.reminder;}

  Future<List<Map<String,dynamic>>> getExecutedActions() async {
    final raw=prefs.getStringList('yansi_executed_actions')??<String>[];
    return raw.map((value){try{return Map<String,dynamic>.from(jsonDecode(value) as Map);}catch(_){return <String,dynamic>{};}}).where((item)=>item.isNotEmpty).toList();
  }
}
