import 'yansi_behavior_pattern_engine.dart';

/// Produces proactive priorities from known personal patterns.
/// It recommends; it does not silently execute sensitive actions.
class YansiPredictivePriorityEngine {
  final YansiBehaviorPatternEngine patterns;

  const YansiPredictivePriorityEngine({this.patterns = const YansiBehaviorPatternEngine()});

  List<String> priorities(List<Map<String, dynamic>> memories) {
    final observed = patterns.inferPatterns(memories);
    if (observed.isEmpty) return const <String>[];

    return observed.map((pattern) {
      if (pattern.toLowerCase().contains('financial')) {
        return 'Review financial activity when useful.';
      }
      if (pattern.toLowerCase().contains('goal')) {
        return 'Keep active goals visible when they become relevant.';
      }
      if (pattern.toLowerCase().contains('task')) {
        return 'Surface repeated productivity activity at the right moment.';
      }
      return 'Consider this recurring personal pattern: $pattern';
    }).toList(growable: false);
  }
}
