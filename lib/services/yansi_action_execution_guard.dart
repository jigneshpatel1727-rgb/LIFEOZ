/// Final execution guard for Yansi data-changing actions.
class YansiActionExecutionGuard {
  const YansiActionExecutionGuard();

  Map<String, dynamic> check({
    required Map<String, dynamic> authorization,
    required bool explicitConfirmation,
  }) {
    final sensitive = authorization['sensitive'] == true;
    final authorized = authorization['authorized'] == true;

    final permitted =
        authorized && (!sensitive || explicitConfirmation);

    return {
      'permitted': permitted,
      'sensitive': sensitive,
      'explicitConfirmation': explicitConfirmation,
      'executionAllowed': permitted,
      'reason': permitted
          ? 'approved'
          : 'confirmation_or_authorization_required',
    };
  }
}
