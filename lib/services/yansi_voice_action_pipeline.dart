import 'yansi_action_plan_engine.dart';
import 'yansi_voice_intent_engine.dart';

/// Bridges a spoken request into the existing guarded Yansi action pipeline.
class YansiVoiceActionPipeline {
  final YansiVoiceIntentEngine intent;
  final YansiActionPlanEngine planner;

  const YansiVoiceActionPipeline({
    this.intent = const YansiVoiceIntentEngine(),
    this.planner = const YansiActionPlanEngine(),
  });

  Map<String, dynamic> process(String transcript) {
    final parsed = intent.interpret(transcript);
    final request = parsed['transcript'] as String;
    return {
      'intent': parsed,
      'plan': planner.plan(request),
      'state': request.isEmpty ? 'idle' : 'planned',
    };
  }
}
