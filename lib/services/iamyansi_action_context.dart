import 'iamyansi_action_planner.dart';

/// Immutable context passed to application-owned executors.
/// Keeps user intent and planned capability separate from raw UI input.
class IamyansiActionContext {
  final IamyansiActionPlan plan;
  final DateTime createdAt;
  final String requestId;

  const IamyansiActionContext({
    required this.plan,
    required this.createdAt,
    required this.requestId,
  });
}
