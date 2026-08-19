/// Immutable execution context passed from Iamyansi planning into an action executor.
///
/// The context deliberately contains no credentials or unrestricted callbacks.
/// Executors should use the request id for audit correlation and the capability
/// to decide which controlled action is allowed.
class IamyansiActionContext {
  const IamyansiActionContext({
    required this.requestId,
    required this.capability,
    required this.createdAt,
    this.userInput = '',
    this.confirmed = false,
    this.metadata = const <String, String>{},
  });

  final String requestId;
  final String capability;
  final DateTime createdAt;
  final String userInput;
  final bool confirmed;
  final Map<String, String> metadata;

  IamyansiActionContext copyWith({
    String? requestId,
    String? capability,
    DateTime? createdAt,
    String? userInput,
    bool? confirmed,
    Map<String, String>? metadata,
  }) {
    return IamyansiActionContext(
      requestId: requestId ?? this.requestId,
      capability: capability ?? this.capability,
      createdAt: createdAt ?? this.createdAt,
      userInput: userInput ?? this.userInput,
      confirmed: confirmed ?? this.confirmed,
      metadata: metadata ?? this.metadata,
    );
  }
}
