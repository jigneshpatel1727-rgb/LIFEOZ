/// Single source of truth for the Phase 1 Launch Intelligence scope.
///
/// Phase 1 prioritizes a useful, AI-first launch over future world/hologram
/// capabilities. The UI principle remains: one screen, one tap, one report.
class YansiPhase1LaunchSpec {
  const YansiPhase1LaunchSpec();

  static const designPrinciples = <String>[
    'super_hyper_futuristic',
    'smart_simple',
    'one_screen',
    'one_tap',
    'one_report',
    'ambient_yansi',
    'minimal_text',
    'intelligence_behind_the_screen',
  ];

  static const launchCapabilities = <String>[
    'five_core_intelligence',
    'voice_to_text',
    'voice_recording',
    'ai_categorization',
    'proactive_suggestions',
    'budget_planning',
    'monthly_household_requirements',
    'message_notification_intelligence',
    'bill_receipt_scanning',
    'grocery_mall_bill_item_extraction',
    'cross_core_reasoning',
    'reports',
  ];

  static const deferredCapabilities = <String>[
    'advanced_world_intelligence',
    'live_maps',
    'city_intelligence',
    'three_dimensional_city_models',
    'holographic_interface',
    'ar_vr',
  ];

  Map<String, dynamic> checklist() => {
        'principle': 'One screen, one tap, one report.',
        'launchCapabilities': launchCapabilities,
        'deferredCapabilities': deferredCapabilities,
        'status': 'phase_1_launch_track',
        'futureArchitecturePreserved': true,
      };
}
