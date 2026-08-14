import 'package:shared_preferences/shared_preferences.dart';

import 'yansi_brain.dart';
import 'yansi_capability_context.dart';
import 'yansi_context_fusion.dart';
import 'yansi_multimodal_context.dart';
import 'yansi_reasoning_envelope.dart';

/// Trial-facing gateway that keeps the existing YansiBrain behavior intact
/// while supplying the new unified context boundary around each interaction.
class YansiTrialGateway {
  final SharedPreferences prefs;
  late final YansiBrain brain;

  YansiTrialGateway({required this.prefs}) {
    brain = YansiBrain(prefs: prefs);
  }

  Future<YansiReasoningEnvelope> buildContext({
    Map<String, dynamic> userIntent = const <String, dynamic>{},
    Set<String> activeEntitlements = const <String>{'core_ai'},
    Set<String> grantedPermissions = const <String>{},
  }) async {
    final lifeContext = await YansiContextFusion(prefs: prefs).build();
    return YansiReasoningEnvelope(
      observations: const YansiMultimodalContext(),
      capabilities: YansiCapabilityContext(
        lifeContext: lifeContext.toJson(),
        activeEntitlements: activeEntitlements,
        grantedPermissions: grantedPermissions,
      ),
      memoryContext: const <String, dynamic>{},
      userIntent: userIntent,
      createdAt: DateTime.now(),
    );
  }

  Future<YansiResult> process(String input, {String? voicePath}) async {
    await buildContext(userIntent: <String, dynamic>{'text': input});
    return brain.process(input, voicePath: voicePath);
  }
}
