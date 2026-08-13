/// Builds repeatable personal workflows from previously verified actions.
class YansiPersonalWorkflowEngine {
  const YansiPersonalWorkflowEngine();

  Map<String, dynamic> build({
    required String name,
    required List<String> steps,
  }) {
    final cleanSteps = steps.where((step) => step.trim().isNotEmpty).toList(growable: false);
    return {
      'name': name.trim(),
      'steps': List.unmodifiable(cleanSteps),
      'stepCount': cleanSteps.length,
      'mode': 'verified_sequence',
      'requiresPerStepVerification': true,
    };
  }
}
