import 'iamyansi_action_planner.dart';
import 'iamyansi_confirmation_gate.dart';
import 'iamyansi_event_bus.dart';
import 'iamyansi_result_bus.dart';

/// Routes an approved plan to an application-owned executor.
/// Iamyansi never receives arbitrary executable code from user input.
abstract class IamyansiExecutor {
  Future<IamyansiExecutionResult> execute(IamyansiActionPlan plan);
}

class IamyansiExecutorRouter {
  final Map<String, IamyansiExecutor> executors;
  final IamyansiEventBus eventBus;
  final IamyansiResultBus resultBus;

  const IamyansiExecutorRouter({
    required this.executors,
    required this.eventBus,
    required this.resultBus,
  });

  Future<IamyansiExecutionResult> executeApproved({
    required IamyansiActionPlan plan,
    IamyansiConfirmationRequest? confirmation,
    bool userApproved = false,
  }) async {
    final capability = plan.capability?.name;
    if (capability == null || capability.isEmpty) {
      return const IamyansiExecutionResult.failure('No executable capability was selected.');
    }
    if (confirmation != null && !userApproved) {
      eventBus.publish(type: 'action.execution_blocked', data: {
        'capability': capability,
        'reason': 'explicit_confirmation_required',
      });
      return const IamyansiExecutionResult.failure('Explicit user confirmation is required.');
    }
    final executor = executors[capability];
    if (executor == null) {
      resultBus.failure(capability: capability, message: 'No application executor is registered for this capability.');
      return const IamyansiExecutionResult.failure('No executor is registered for this capability.');
    }
    eventBus.publish(type: 'action.execution_started', data: {'capability': capability});
    try {
      final result = await executor.execute(plan);
      if (result.success) {
        resultBus.success(capability: capability, message: result.message);
      } else {
        resultBus.failure(capability: capability, message: result.message);
      }
      return result;
    } catch (error) {
      final message = 'Execution failed safely: $error';
      resultBus.failure(capability: capability, message: message);
      return IamyansiExecutionResult.failure(message);
    }
  }
}

class IamyansiExecutionResult {
  final bool success;
  final String message;

  const IamyansiExecutionResult({required this.success, required this.message});
  const IamyansiExecutionResult.failure(String message) : success = false, message = message;
}
