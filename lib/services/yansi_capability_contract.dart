import 'yansi_phase1_context.dart';

/// Stable contract for every present and future Yansi capability.
///
/// Capabilities provide knowledge and proposals; the intelligence layer
/// remains responsible for relevance, prioritisation and presentation.
enum YansiCapabilityKind { context, knowledge, planning, action, visualization }

enum YansiPermissionState { unknown, denied, granted }

class YansiCapabilityContext {
  final YansiPhase1Context lifeContext;
  final DateTime now;
  final Map<String, dynamic> metadata;

  const YansiCapabilityContext({
    required this.lifeContext,
    required this.now,
    this.metadata = const {},
  });
}

class YansiCapabilitySignal {
  final String id;
  final String capabilityId;
  final String core;
  final String title;
  final String message;
  final int relevance;
  final bool requiresUserConfirmation;
  final Map<String, dynamic> data;

  const YansiCapabilitySignal({
    required this.id,
    required this.capabilityId,
    required this.core,
    required this.title,
    required this.message,
    required this.relevance,
    this.requiresUserConfirmation = false,
    this.data = const {},
  });
}

abstract interface class YansiCapability {
  String get id;
  String get name;
  YansiCapabilityKind get kind;

  /// Returns the permissions this capability needs for the current operation.
  Set<String> requiredPermissions(YansiCapabilityContext context);

  /// Produces context/knowledge/planning signals without performing actions.
  Future<List<YansiCapabilitySignal>> observe(YansiCapabilityContext context);

  /// Executes an explicitly approved capability operation.
  /// Implementations must reject execution when required permissions are absent.
  Future<YansiCapabilityResult> execute(
    YansiCapabilityContext context,
    YansiCapabilityRequest request,
  );
}

class YansiCapabilityRequest {
  final String operation;
  final Map<String, dynamic> arguments;
  final bool userConfirmed;

  const YansiCapabilityRequest({
    required this.operation,
    this.arguments = const {},
    this.userConfirmed = false,
  });
}

class YansiCapabilityResult {
  final bool success;
  final String message;
  final Map<String, dynamic> data;

  const YansiCapabilityResult({
    required this.success,
    required this.message,
    this.data = const {},
  });

  const YansiCapabilityResult.denied(String message)
      : success = false,
        message = message,
        data = const {};
}
