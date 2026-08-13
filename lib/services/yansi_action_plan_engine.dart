/// Converts a natural goal into a safe, ordered action plan.
class YansiActionPlanEngine {
  const YansiActionPlanEngine();

  List<Map<String, dynamic>> plan(String request) {
    final text = request.trim();
    if (text.isEmpty) return const <Map<String, dynamic>>[];

    return [
      {
        'step': 1,
        'intent': text,
        'state': 'understand',
        'requiresConfirmation': false,
      },
      {
        'step': 2,
        'intent': 'Check relevant LifeOS context and required permissions.',
        'state': 'prepare',
        'requiresConfirmation': false,
      },
      {
        'step': 3,
        'intent': 'Execute only approved actions and verify each result.',
        'state': 'execute_guarded',
        'requiresConfirmation': true,
      },
      {
        'step': 4,
        'intent': 'Report the verified outcome.',
        'state': 'verify_and_report',
        'requiresConfirmation': false,
      },
    ];
  }
}
