import 'yansi_ambient_cadence_policy.dart';
import 'yansi_ambient_signal_gate.dart';
import 'yansi_next_phase_orchestrator.dart';
import 'yansi_proactive_runtime.dart';

class YansiAmbientSurfaceState {
  final String? title;
  final String? message;
  final int confidence;
  final int? rankingScore;
  final String? deliveryMode;
  final String? deliveryReason;
  final bool visible;
  final bool needsConfirmation;
  final bool ambientOnly;
  final bool voiceEligible;
  final String? signalKey;

  const YansiAmbientSurfaceState({
    this.title,
    this.message,
    this.confidence = 0,
    this.rankingScore,
    this.deliveryMode,
    this.deliveryReason,
    this.visible = false,
    this.needsConfirmation = false,
    this.ambientOnly = true,
    this.voiceEligible = false,
    this.signalKey,
  });

  bool get highConfidence => confidence >= 80;
}

class YansiAmbientSurfaceController {
  final YansiNextPhaseOrchestrator orchestrator;
  final YansiAmbientSignalGate gate;
  YansiAmbientCadencePolicy cadence;

  YansiAmbientSurfaceController(this.orchestrator,{YansiAmbientSignalGate? gate,YansiAmbientCadencePolicy? cadence}) : gate=gate??const YansiAmbientSignalGate(), cadence=cadence??const YansiAmbientCadencePolicy();

  String signalIdentity({required String title,required String message,required int priority}) => '${title.trim().toLowerCase()}|${message.trim().toLowerCase()}|$priority';

  YansiAmbientSurfaceState refresh({DateTime? now}) {
    final signal=orchestrator.topPriority();
    if(signal==null)return const YansiAmbientSurfaceState();
    final score=signal.priority.clamp(0,100).toInt();
    final key=signalIdentity(title:signal.title,message:signal.message,priority:score);
    if(!_allowed(key,score,now:now))return const YansiAmbientSurfaceState();
    return YansiAmbientSurfaceState(title:signal.title,message:signal.message,confidence:score,rankingScore:score,visible:true,needsConfirmation:signal.needsConfirmation||score>=90,signalKey:key);
  }

  void recordDisplayed(YansiAmbientSurfaceState state,{DateTime? shownAt}) {if(!state.visible||state.signalKey==null)return;cadence=cadence.record(state.signalKey!,priority:state.confidence,shownAt:shownAt);}

  bool _allowed(String key,int priority,{DateTime? now}) {final cadenceAllowed=cadence.shouldSurface(signalKey:key,priority:priority,now:now);return gate.allow(visible:priority>=60,userActive:true,quietMode:false,cadenceAllowed:cadenceAllowed,priority:priority);}

  Future<YansiAmbientSurfaceState> refreshFromRuntime(YansiProactiveRuntime runtime,{bool quietMode=false,bool userActive=true,bool screenVisible=true,bool voiceAvailable=true,DateTime? now}) async {
    if(quietMode||!screenVisible)return const YansiAmbientSurfaceState();
    final plan=await runtime.prepare(userIsActive:userActive,quietMode:quietMode);
    if(plan==null||!runtime.isReady)return const YansiAmbientSurfaceState();
    final confidence=runtime.confidence.clamp(0,100).toInt();
    final title=runtime.headline;
    final item=plan.items.isEmpty?null:plan.items.first;
    final message=item?.reason;
    if(title==null||title.trim().isEmpty||message==null||message.trim().isEmpty)return const YansiAmbientSurfaceState();
    final key=signalIdentity(title:title,message:message,priority:runtime.priority);
    final surfaceAllowed=gate.allow(visible:screenVisible&&confidence>=60,userActive:userActive,quietMode:quietMode,cadenceAllowed:cadence.shouldSurface(signalKey:key,priority:runtime.priority,now:now),priority:runtime.priority);
    if(!surfaceAllowed)return const YansiAmbientSurfaceState();
    return YansiAmbientSurfaceState(title:title,message:message,confidence:confidence,rankingScore:item.score,deliveryMode:null,deliveryReason:item.scoreReason,visible:true,needsConfirmation:runtime.priority>=90,ambientOnly:true,voiceEligible:gate.allowVoice(surfaceAllowed:true,voiceAvailable:voiceAvailable,runtimeAllowsSpeech:runtime.shouldSpeak),signalKey:key);
  }

  bool shouldAllowAmbientVoice({required YansiProactiveRuntime runtime,bool quietMode=false,bool userActive=true,bool voiceAvailable=true}) => gate.allowVoice(surfaceAllowed:!quietMode&&userActive,voiceAvailable:voiceAvailable,runtimeAllowsSpeech:runtime.isReady&&runtime.shouldSpeak);

  String? ambientVoiceText(YansiAmbientSurfaceState state) {
    if(!state.voiceEligible||state.message==null)return null;
    final text=state.message!.trim();
    if(text.isEmpty)return null;
    return state.needsConfirmation?'I noticed something important. $text Please confirm before I act.':text;
  }
}
