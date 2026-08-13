/// Prepares a lightweight pre-response check for Yansi.
class YansiSelfCheckEngine {
  const YansiSelfCheckEngine();

  Map<String, dynamic> check({
    required bool hasContext,
    required bool actionVerified,
    required bool requiresConfirmation,
  }) {
    final warnings = <String>[];
    if (!hasContext) warnings.add('limited_context');
    if (!actionVerified) warnings.add('action_not_verified');
    if (requiresConfirmation) warnings.add('confirmation_required');

    return {
      'ready': warnings.isEmpty,
      'warnings': List.unmodifiable(warnings),
    };
  }
}
