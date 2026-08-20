/// UI-agnostic status model for reporting the current Iamyansi action stage.
/// Keeps the ambient AI experience free of chatbot-specific UI assumptions.
enum IamyansiActionStage {
  idle,
  understanding,
  awaitingConfirmation,
  executing,
  completed,
  failed,
}

class IamyansiActionStatus {
  const IamyansiActionStatus({
    required this.stage,
    this.requestId,
    this.message = '',
  });

  final IamyansiActionStage stage;
  final String? requestId;
  final String message;

  bool get isBusy =>
      stage == IamyansiActionStage.understanding ||
      stage == IamyansiActionStage.executing;

  bool get needsConfirmation =>
      stage == IamyansiActionStage.awaitingConfirmation;

  bool get isTerminal =>
      stage == IamyansiActionStage.completed ||
      stage == IamyansiActionStage.failed;

  IamyansiActionStatus copyWith({
    IamyansiActionStage? stage,
    String? requestId,
    String? message,
  }) {
    return IamyansiActionStatus(
      stage: stage ?? this.stage,
      requestId: requestId ?? this.requestId,
      message: message ?? this.message,
    );
  }
}
