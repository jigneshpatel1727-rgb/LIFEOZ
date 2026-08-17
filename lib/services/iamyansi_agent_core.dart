import 'iamyansi_core_bridge.dart';
import 'iamyansi_intent_parser.dart';

/// iamyansi's controlled agent layer.
///
/// This is intentionally model-agnostic: it provides the agent contract,
/// context, permission gates, tool routing and verification without forcing
/// a third-party AI provider into the application.
class IamyansiAgentCore {
  final IamyansiCoreBridge bridge;
  final IamyansiIntentParser intentParser;
  const IamyansiAgentCore({required this.bridge, this.intentParser = const IamyansiIntentParser()});

  Future<IamyansiAgentResult> handle(String input, {bool confirmed = false}) async {
    final text = input.trim();
    if (text.isEmpty) return const IamyansiAgentResult.empty();

    // IMPORTANT: parse() is an instance API; keep the parser injectable for testing.
    final intent = intentParser.parse(text);
    if (intent.type == IamyansiIntentType.unknown) {
      return IamyansiAgentResult.unknown(text);
    }

    if (intent.needsConfirmation && !confirmed) {
      return IamyansiAgentResult.confirmationRequired(intent);
    }

    final write = await bridge.apply(intent);
    if (write.alreadyExists) {
      return IamyansiAgentResult.alreadyProcessed(intent, write.core);
    }
    if (!write.written) {
      return IamyansiAgentResult.notExecuted(intent);
    }

    return IamyansiAgentResult.completed(intent, write.id!, write.core!);
  }

  Map<String, dynamic> contextSnapshot() => bridge.snapshot();
}

class IamyansiAgentResult {
  final IamyansiAgentResultType type;
  final IamyansiIntent? intent;
  final String? id;
  final String? core;
  final String? message;

  const IamyansiAgentResult._({
    required this.type,
    this.intent,
    this.id,
    this.core,
    this.message,
  });

  const IamyansiAgentResult.empty()
      : this._(type: IamyansiAgentResultType.empty);

  const IamyansiAgentResult.unknown(String input)
      : this._(
          type: IamyansiAgentResultType.unknown,
          message: input,
        );

  const IamyansiAgentResult.confirmationRequired(IamyansiIntent value)
      : this._(
          type: IamyansiAgentResultType.confirmationRequired,
          intent: value,
        );

  const IamyansiAgentResult.completed(IamyansiIntent value, String valueId, String valueCore)
      : this._(
          type: IamyansiAgentResultType.completed,
          intent: value,
          id: valueId,
          core: valueCore,
        );

  const IamyansiAgentResult.alreadyProcessed(IamyansiIntent value, String? valueCore)
      : this._(
          type: IamyansiAgentResultType.alreadyProcessed,
          intent: value,
          core: valueCore,
        );

  const IamyansiAgentResult.notExecuted(IamyansiIntent value)
      : this._(
          type: IamyansiAgentResultType.notExecuted,
          intent: value,
        );
}

enum IamyansiAgentResultType {
  empty,
  unknown,
  confirmationRequired,
  completed,
  alreadyProcessed,
  notExecuted,
}
