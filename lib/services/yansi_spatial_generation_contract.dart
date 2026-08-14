/// General spatial-generation contract for Yansi.
///
/// A spatial request is intentionally subject-agnostic: a city, route, home,
/// machine, travel plan, or any future user-defined subject can use the same
/// contract. Rendering engines remain implementation details.
class YansiSpatialGenerationRequest {
  final String instruction;
  final String subject;
  final String mode;
  final Map<String, dynamic> parameters;

  const YansiSpatialGenerationRequest({
    required this.instruction,
    required this.subject,
    this.mode = 'spatial',
    this.parameters = const <String, dynamic>{},
  });
}

class YansiSpatialGenerationPlan {
  final YansiSpatialGenerationRequest request;
  final List<String> dataSources;
  final List<String> requiredPermissions;
  final bool requiresExternalData;
  final bool requiresRenderer;

  const YansiSpatialGenerationPlan({
    required this.request,
    this.dataSources = const <String>[],
    this.requiredPermissions = const <String>[],
    this.requiresExternalData = false,
    this.requiresRenderer = true,
  });
}

/// Converts an approved natural-language spatial intent into a renderer-neutral
/// plan. It does not claim that a device can render holograms unless a renderer
/// capability is actually supplied later.
class YansiSpatialGenerationPlanner {
  const YansiSpatialGenerationPlanner();

  YansiSpatialGenerationPlan plan(YansiSpatialGenerationRequest request) {
    final instruction = request.instruction.trim().toLowerCase();
    final external = instruction.contains('live') ||
        instruction.contains('current') ||
        instruction.contains('real-time') ||
        instruction.contains('today');

    final sources = <String>['user_instruction'];
    if (external) sources.add('approved_external_data');

    final permissions = <String>[];
    if (external) permissions.add('web_access');

    return YansiSpatialGenerationPlan(
      request: request,
      dataSources: sources,
      requiredPermissions: permissions,
      requiresExternalData: external,
    );
  }
}
