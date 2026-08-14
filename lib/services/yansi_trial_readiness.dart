/// Central checklist for the first usable LifeOS/Yansi trial.
/// Keeps trial scope explicit so foundational work does not delay a usable app.
class YansiTrialReadiness {
  const YansiTrialReadiness();

  static const List<String> requiredCapabilities = <String>[
    'five_core_navigation',
    'one_screen_core_report',
    'yansi_voice_input_output',
    'life_context_snapshot',
    'permission_controls',
    'manual_fallback_entry',
    'hyper_futuristic_theme_shell',
  ];

  static const List<String> nextTrialLayers = <String>[
    'connect_reasoning_envelope_to_runtime',
    'verify_five_core_reports',
    'verify_voice_to_action_flow',
    'verify_permissions_and_confirmation',
    'run_flutter_analysis_and_apk_build',
  ];

  bool isCoreReady(Set<String> implemented) =>
      requiredCapabilities.every(implemented.contains);
}
