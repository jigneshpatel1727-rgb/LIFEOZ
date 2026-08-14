import 'yansi_multimodal_context.dart';
import 'yansi_capability_context.dart';

/// Stable input contract for the central Yansi reasoning engine.
///
/// Reasoning remains separate from UI, individual capabilities and rendering.
/// This envelope can therefore grow without replacing the intelligence core.
class YansiReasoningEnvelope {
  final YansiMultimodalContext observations;
  final YansiCapabilityContext capabilities;
  final Map<String, dynamic> memoryContext;
  final Map<String, dynamic> userIntent;
  final DateTime createdAt;

  const YansiReasoningEnvelope({
    this.observations = const YansiMultimodalContext(),
    this.capabilities = const YansiCapabilityContext(),
    this.memoryContext = const <String, dynamic>{},
    this.userIntent = const <String, dynamic>{},
    required this.createdAt,
  });

  YansiReasoningEnvelope copyWith({
    YansiMultimodalContext? observations,
    YansiCapabilityContext? capabilities,
    Map<String, dynamic>? memoryContext,
    Map<String, dynamic>? userIntent,
  }) {
    return YansiReasoningEnvelope(
      observations: observations ?? this.observations,
      capabilities: capabilities ?? this.capabilities,
      memoryContext: memoryContext ?? this.memoryContext,
      userIntent: userIntent ?? this.userIntent,
      createdAt: createdAt,
    );
  }
}
