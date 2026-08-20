import 'iamyansi_action_context.dart';
import 'iamyansi_capabilities.dart';
import 'iamyansi_executor_router.dart';

/// Small application-facing bridge between Iamyansi and the controlled
/// executor router. The AI layer can request a capability by name, while the
/// router remains the only component allowed to execute registered actions.
class IamyansiActionDispatcher {
  const IamyansiActionDispatcher(this.router);

  final IamyansiExecutorRouter router;

  Future<IamyansiActionResult> dispatch({
    required String requestId,
    required String capability,
    String userInput = '',
    bool confirmed = false,
    Map<String, String> metadata = const <String, String>{},
  }) {
    final normalized = capability.trim().toLowerCase();
    if (!IamyansiCapabilities.all.contains(normalized)) {
      return Future<IamyansiActionResult>.value(
        IamyansiActionResult.failure(
          'Unsupported Iamyansi capability: $capability',
        ),
      );
    }

    return router.execute(
      IamyansiActionContext(
        requestId: requestId,
        capability: normalized,
        createdAt: DateTime.now().toUtc(),
        userInput: userInput,
        confirmed: confirmed,
        metadata: metadata,
      ),
    );
  }
}
