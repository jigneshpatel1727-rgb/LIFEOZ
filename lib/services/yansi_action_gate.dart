import 'yansi_capability_registry.dart';

/// Central gate between Yansi reasoning and capability execution.
///
/// No capability may execute a proposed action without passing through this
/// policy boundary. The gate is deliberately deterministic and renderer/UI
/// independent so it can protect future web, messaging, financial, location,
/// device and spatial capabilities as well.
enum YansiActionRisk { informational, reversible, sensitive, external }

enum YansiActionDecision { allowed, confirmationRequired, denied }

class YansiActionRequest {
  final String capabilityId;
  final Set<String> requiredPermissions;
  final YansiActionRisk risk;
  final bool userConfirmed;
  final bool enabled;

  const YansiActionRequest({
    required this.capabilityId,
    this.requiredPermissions = const <String>{},
    this.risk = YansiActionRisk.informational,
    this.userConfirmed = false,
    this.enabled = true,
  });
}

class YansiActionGateResult {
  final YansiActionDecision decision;
  final List<String> reasons;

  const YansiActionGateResult(this.decision, this.reasons);

  bool get canExecute => decision == YansiActionDecision.allowed;
}

class YansiActionGate {
  const YansiActionGate();

  YansiActionGateResult evaluate({
    required YansiActionRequest request,
    required Set<String> grantedPermissions,
    required Set<String> activeEntitlements,
  }) {
    final reasons = <String>[];

    if (!request.enabled) {
      return const YansiActionGateResult(
        YansiActionDecision.denied,
        <String>['Capability is disabled.'],
      );
    }

    if (!activeEntitlements.contains(request.capabilityId)) {
      return YansiActionGateResult(
        YansiActionDecision.denied,
        <String>['Capability is not active.'],
      );
    }

    final missing = request.requiredPermissions
        .where((permission) => !grantedPermissions.contains(permission))
        .toList(growable: false);

    if (missing.isNotEmpty) {
      return YansiActionGateResult(
        YansiActionDecision.denied,
        <String>['Missing permissions: ${missing.join(', ')}.'],
      );
    }

    switch (request.risk) {
      case YansiActionRisk.informational:
      case YansiActionRisk.reversible:
        return YansiActionGateResult(
          YansiActionDecision.allowed,
          reasons,
        );
      case YansiActionRisk.sensitive:
      case YansiActionRisk.external:
        if (!request.userConfirmed) {
          return const YansiActionGateResult(
            YansiActionDecision.confirmationRequired,
            <String>['User confirmation is required before execution.'],
          );
        }
        return YansiActionGateResult(
          YansiActionDecision.allowed,
          reasons,
        );
    }
  }
}
