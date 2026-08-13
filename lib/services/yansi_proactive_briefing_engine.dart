import 'yansi_unified_intelligence_router.dart';

/// Converts unified LifeOS intelligence into quiet, high-value ambient signals.
class YansiProactiveBriefingEngine {
  final YansiUnifiedIntelligenceRouter intelligence;

  const YansiProactiveBriefingEngine({
    this.intelligence = const YansiUnifiedIntelligenceRouter(),
  });

  String? highestValueBriefing(List<Map<String, dynamic>> memories) {
    final analysis = intelligence.analyze(memories);
    final goals = List<String>.from(analysis['goalSignals'] as List);
    final routines = List<String>.from(analysis['routineSignals'] as List);

    if (goals.isNotEmpty) return goals.first;
    if (routines.isNotEmpty) return routines.first;
    return null;
  }

  bool shouldStayQuiet({required bool quietHours, required bool critical}) {
    return quietHours && !critical;
  }
}
