import 'iamyansi_capability_policy.dart';
import 'iamyansi_action_planner.dart';

/// Contract for real feature executors. Iamyansi can prepare an action, but
/// execution remains in application-owned code behind this interface.
abstract interface class IamyansiExecutor {
  IamyansiCapability get capability;

  Future<IamyansiExecutionResult> execute(
    IamyansiExecutionContext context,
  );
}

class IamyansiExecutionContext {
  final String input;
  final IamyansiActionPlan plan;
  final bool userConfirmed;

  const IamyansiExecutionContext({
    required this.input,
    required this.plan,
    this.userConfirmed = false,
  });
}

class IamyansiExecutionResult {
  final bool success;
  final String message;
  final Map<String, dynamic> data;

  const IamyansiExecutionResult({
    required this.success,
    required this.message,
    this.data = const {},
  });
}
