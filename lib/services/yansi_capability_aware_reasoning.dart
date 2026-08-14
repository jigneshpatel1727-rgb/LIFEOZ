/// Lets Yansi reason about available capabilities without turning capability
/// availability into a rigid behavior tree.
class YansiCapabilityAwareReasoning {
  const YansiCapabilityAwareReasoning();

  Map<String, dynamic> assess({
    required String intent,
    required List<Map<String, dynamic>> capabilities,
    Map<String, dynamic> context = const {},
  }) {
    final normalizedIntent = intent.trim().toLowerCase();
    final matches = capabilities.where((capability) {
      final id = '${capability['id'] ?? ''}'.toLowerCase();
      final aliases = (capability['aliases'] is List)
          ? (capability['aliases'] as List).map((e) => '$e'.toLowerCase()).toList()
          : const <String>[];
      return id.contains(normalizedIntent) ||
          aliases.any((alias) => normalizedIntent.contains(alias) || alias.contains(normalizedIntent));
    }).take(5).toList();

    return {
      'intent': intent,
      'availableCapabilities': matches,
      'capabilityCount': matches.length,
      'context': context,
      'reasoningMode': matches.isEmpty ? 'discover_or_reason_without_capability' : 'capability_aware',
      'adaptive': true,
      'doesNotForceBehavior': true,
      'externalActionRequiresAuthority': true,
    };
  }

  Map<String, dynamic> chooseNextStep({required Map<String, dynamic> assessment}) {
    final capabilities = assessment['availableCapabilities'];
    if (capabilities is List && capabilities.isNotEmpty) {
      return {
        'mode': 'use_best_available_capability',
        'candidates': capabilities,
        'requiresConfirmationForSideEffect': true,
      };
    }
    return {
      'mode': 'reason_and_offer_next_best_path',
      'candidates': const [],
      'requiresConfirmationForSideEffect': true,
    };
  }
}
