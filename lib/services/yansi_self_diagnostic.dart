import 'package:shared_preferences/shared_preferences.dart';

/// Safe, local self-diagnostics for Yansi. It detects known runtime problems
/// and can perform only predefined, reversible data cleanup.
class YansiDiagnosticResult {
  final bool healthy;
  final List<String> checks;
  final List<String> issues;
  final List<String> recoveryActions;
  const YansiDiagnosticResult({required this.healthy,required this.checks,required this.issues,required this.recoveryActions});
}

class YansiSelfDiagnostic {
  final SharedPreferences prefs;
  const YansiSelfDiagnostic({required this.prefs});

  YansiDiagnosticResult run(){
    final checks=<String>[];
    final issues=<String>[];
    final actions=<String>[];
    final learning=prefs.getBool('permission_personal_learning')==true;
    checks.add('Personal learning permission: ${learning ? 'enabled' : 'disabled'}');
    final events=prefs.getStringList('yansi_events')??const <String>[];
    checks.add('Event intake: ${events.length} buffered events');
    if(events.length>100){issues.add('Event buffer exceeds safety limit');actions.add('Trim oldest buffered events');}
    final memory=prefs.getStringList('yansi_memory_entries')??const <String>[];
    checks.add('Memory entries: ${memory.length}');
    if(memory.length>200){issues.add('Memory exceeds retention policy');actions.add('Retain newest approved memories');}
    final voice=prefs.getString('last_yansi_voice_text');
    final response=prefs.getString('last_yansi_response');
    checks.add('Voice state: ${voice!=null&&response!=null?'available':'incomplete'}');
    if(voice!=null&&voice.trim().isNotEmpty&&(response==null||response.trim().isEmpty)){issues.add('Last voice interaction has no stored response');actions.add('Refresh Yansi response state');}
    return YansiDiagnosticResult(healthy:issues.isEmpty,checks:checks,issues:issues,recoveryActions:actions);
  }

  Future<bool> recoverSafe(YansiDiagnosticResult result)async{
    if(result.healthy)return false;
    var changed=false;
    final events=prefs.getStringList('yansi_events')??const <String>[];
    if(events.length>100){await prefs.setStringList('yansi_events',events.sublist(events.length-100));changed=true;}
    final memory=prefs.getStringList('yansi_memory_entries')??const <String>[];
    if(memory.length>200){await prefs.setStringList('yansi_memory_entries',memory.sublist(memory.length-200));changed=true;}
    return changed;
  }
}
