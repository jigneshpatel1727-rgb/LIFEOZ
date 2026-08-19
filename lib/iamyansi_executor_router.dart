import 'iamyansi_action_context.dart';

/// Result returned by a controlled Iamyansi executor.
class IamyansiActionResult {
  const IamyansiActionResult({
    required this.success,
    required this.message,
    this.data = const <String, dynamic>{},
  });

  final bool success;
  final String message;
  final Map<String, dynamic> data;

  factory IamyansiActionResult.ok(
    String message, {
    Map<String, dynamic> data = const <String, dynamic>{},
  }) => IamyansiActionResult(success: true, message: message, data: data);

  factory IamyansiActionResult.failure(String message) =>
      IamyansiActionResult(success: false, message: message);
}

typedef IamyansiActionExecutor = Future<IamyansiActionResult> Function(
  IamyansiActionContext context,
);

/// Central allow-listed router for Iamyansi actions.
///
/// New capabilities must be explicitly registered here. This prevents the AI
/// layer from turning arbitrary text into arbitrary application code execution.
class IamyansiExecutorRouter {
  IamyansiExecutorRouter({Map<String, IamyansiActionExecutor>? executors})
      : _executors = <String, IamyansiActionExecutor>{
          ...?executors,
        };

  final Map<String, IamyansiActionExecutor> _executors;

  void register(String capability, IamyansiActionExecutor executor) {
    final key = capability.trim().toLowerCase();
    if (key.isEmpty) {
      throw ArgumentError.value(capability, 'capability', 'Cannot be empty');
    }
    _executors[key] = executor;
  }

  bool canExecute(String capability) =>
      _executors.containsKey(capability.trim().toLowerCase());

  Future<IamyansiActionResult> execute(IamyansiActionContext context) async {
    final key = context.capability.trim().toLowerCase();
    final executor = _executors[key];

    if (executor == null) {
      return IamyansiActionResult.failure(
        'Iamyansi capability is not registered: ${context.capability}',
      );
    }

    // Sensitive actions must arrive with explicit confirmation. Individual
    // executors can impose stricter rules as well.
    if (_requiresConfirmation(key) && !context.confirmed) {
      return IamyansiActionResult.failure(
        'Confirmation required before executing $key.',
      );
    }

    try {
      return await executor(context);
    } catch (error) {
      return IamyansiActionResult.failure(
        'Action failed safely: ${error.toString()}',
      );
    }
  }

  bool _requiresConfirmation(String capability) {
    const sensitive = <String>{
      'delete_expense',
      'delete_task',
      'send_message',
      'make_payment',
      'create_payment',
      'change_setting',
      'share_data',
    };
    return sensitive.contains(capability);
  }
}
