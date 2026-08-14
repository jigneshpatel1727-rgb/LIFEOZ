import 'yansi_capability_context.dart';
import 'yansi_multimodal_context.dart';
import 'yansi_reasoning_envelope.dart';

/// Builds the single input envelope consumed by the future central Yansi
/// reasoning engine. This class deliberately does not perform reasoning or
/// execute actions; it only normalizes approved context at the boundary.
class YansiReasoningBridge {
  const YansiReasoningBridge();

  YansiReasoningEnvelope build({
    YansiMultimodalContext observations = const YansiMultimodalContext(),
    YansiCapabilityContext capabilities = const YansiCapabilityContext(),
    Map<String, dynamic> memoryContext = const <String, dynamic>{},
    Map<String, dynamic> userIntent = const <String, dynamic>{},
  }) {
    return YansiReasoningEnvelope(
      observations: observations,
      capabilities: capabilities,
      memoryContext: Map<String, dynamic>.unmodifiable(memoryContext),
      userIntent: Map<String, dynamic>.unmodifiable(userIntent),
      createdAt: DateTime.now(),
    );
  }
}
