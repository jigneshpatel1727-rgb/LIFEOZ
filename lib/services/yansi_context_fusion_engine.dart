import 'yansi_temporal_context_engine.dart';

/// Fuses time, LifeOS state and user-approved context into one reasoning input.
class YansiContextFusionEngine {
  final YansiTemporalContextEngine temporal;

  const YansiContextFusionEngine({this.temporal = const YansiTemporalContextEngine()});

  Map<String, dynamic> fuse({
    required Map<String, dynamic> lifeState,
    Map<String, dynamic>? personalContext,
    DateTime? now,
  }) {
    return {
      'time': temporal.now(value: now),
      'lifeState': Map<String, dynamic>.from(lifeState),
      'personalContext': personalContext == null
          ? const <String, dynamic>{}
          : Map<String, dynamic>.from(personalContext),
    };
  }
}
