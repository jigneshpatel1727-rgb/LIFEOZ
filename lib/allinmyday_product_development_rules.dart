/// ALLINMYDAY product-development guardrails.
///
/// These rules are internal product-development policy, not legal certification
/// or proof of novelty. They keep physical-product concepts consistent with the
/// ALLINMYDAY direction and make unverified claims explicit.
class AllinmydayProductDevelopmentRules {
  const AllinmydayProductDevelopmentRules._();

  static const motto = 'One screen. One tap. One report.';
  static const principle =
      'Less information on screen + more intelligence behind the screen.';

  static const originalDesignOnly = true;
  static const requirePrototypeValidation = true;
  static const requireSafetyReviewBeforeRelease = true;

  static const allowedStages = <String>[
    'idea',
    'concept',
    'prototype',
    'testing',
    'productionReady',
  ];

  static const requiredRecords = <String>[
    'problem',
    'originalSolution',
    'materials',
    'dimensions',
    'assembly',
    'targetCost',
    'prototypeTestPlan',
    'safetyNotes',
    'validationStatus',
  ];

  static bool canClaimProductionReady({
    required String stage,
    required bool prototypeValidated,
    required bool safetyReviewed,
  }) {
    return stage == 'productionReady' &&
        prototypeValidated &&
        safetyReviewed;
  }
}
