/// Keeps a multi-step request alive until it is verified or safely stopped.
class YansiFollowThroughEngine {
  const YansiFollowThroughEngine();

  Map<String, dynamic> next({
    required List<Map<String, dynamic>> steps,
    required Set<int> verifiedSteps,
  }) {
    for (final step in steps) {
      final number = step['step'];
      if (number is int && !verifiedSteps.contains(number)) {
        return {
          'state': 'continue',
          'nextStep': number,
          'instruction': step['intent'],
        };
      }
    }
    return {
      'state': steps.isEmpty ? 'idle' : 'verified_complete',
      'nextStep': null,
    };
  }
}
