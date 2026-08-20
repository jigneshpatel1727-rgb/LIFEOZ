/// Structured request produced by the Iamyansi understanding layer before
/// dispatching an action to the controlled application executor.
class IamyansiActionRequest {
  const IamyansiActionRequest({
    required this.requestId,
    required this.capability,
    this.userInput = '',
    this.confirmed = false,
    this.parameters = const <String, dynamic>{},
  });

  final String requestId;
  final String capability;
  final String userInput;
  final bool confirmed;
  final Map<String, dynamic> parameters;

  IamyansiActionRequest copyWith({
    String? requestId,
    String? capability,
    String? userInput,
    bool? confirmed,
    Map<String, dynamic>? parameters,
  }) {
    return IamyansiActionRequest(
      requestId: requestId ?? this.requestId,
      capability: capability ?? this.capability,
      userInput: userInput ?? this.userInput,
      confirmed: confirmed ?? this.confirmed,
      parameters: parameters ?? this.parameters,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'requestId': requestId,
        'capability': capability,
        'userInput': userInput,
        'confirmed': confirmed,
        'parameters': parameters,
      };
}
