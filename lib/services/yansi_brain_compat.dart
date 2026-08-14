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
    if(sensitive&&!userConfirmed){return {'executed':false,'requiresConfirmation':true,'reason':'This action requires your confirmation before execution.','action':plan.action,'intent':result.intent.name};}
    final execution=<String,dynamic>{'id':DateTime.now().microsecondsSinceEpoch.toString(),'intent':result.intent.name,'action':plan.action,'title':plan.title,'confidence':plan.confidence,'confirmed':userConfirmed,'executed':true,'date':DateTime.now().toIso8601String(),'data':result.data};
    final raw=prefs.getStringList('yansi_executed_actions')??<String>[];raw.add(jsonEncode(execution));if(raw.length>100){raw.removeRange(0,raw.length-100);}await prefs.setStringList('yansi_executed_actions',raw);return execution;
  }

  bool _isSensitiveAction(String action,YansiIntent intent){final normalized=action.toLowerCase();if(normalized.contains('transfer')||normalized.contains('send money')||normalized.contains('delete')||normalized.contains('purchase')||normalized.contains('external')||normalized.contains('permission'))return true;return intent==YansiIntent.reminder;}

  Future<List<Map<String,dynamic>>> getExecutedActions() async {
    final raw=prefs.getStringList('yansi_executed_actions')??<String>[];
    return raw.map((value){try{return Map<String,dynamic>.from(jsonDecode(value) as Map);}catch(_){return <String,dynamic>{};}}).where((item)=>item.isNotEmpty).toList();
  }
}
