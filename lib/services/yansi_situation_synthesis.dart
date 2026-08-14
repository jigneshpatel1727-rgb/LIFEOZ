import 'package:shared_preferences/shared_preferences.dart';

/// Turns multiple trusted LifeOS signals into one concise, human-level situation.
/// Read-only: it explains signals and never performs actions.
class YansiSituationSynthesis {
  final SharedPreferences prefs;
  const YansiSituationSynthesis({required this.prefs});

  Map<String, dynamic> synthesize(Map<String, dynamic> ranked) {
    final rawCores = ranked['supportingCores'];
    final cores = rawCores is List
        ? rawCores.map((e) => e.toString().trim().toLowerCase()).where((e) => e.isNotEmpty).toSet().toList()
        : <String>[];
    final best = '${ranked['core'] ?? ''}'.trim().toLowerCase();
    final score = ((ranked['score'] as num?)?.toInt() ?? 0).clamp(0, 100);
    final confidence = ((ranked['confidence'] as num?)?.toInt() ?? 0).clamp(0, 100);
    final multiCore = ranked['multiCore'] == true && cores.length >= 2;

    String title;
    String message;
    String nextStep;
    if (multiCore) {
      final joined = cores.take(3).map(_label).join(' + ');
      title = 'A connected situation is emerging';
      message = 'Your $joined signals are pointing in the same direction.';
      nextStep = 'Review the combined situation before deciding what to do.';
    } else if (best.isNotEmpty) {
      title = '${_label(best)} needs attention';
      message = 'The strongest trusted signal currently comes from ${_label(best)}.';
      nextStep = 'Review the signal and decide whether it needs action.';
    } else {
      title = 'LifeOS is observing';
      message = 'There is not enough trusted evidence to form a specific situation yet.';
      nextStep = 'Stay ambient until stronger evidence appears.';
    }

    final result = <String, dynamic>{
      'title': title,
      'message': message,
      'nextStep': nextStep,
      'primaryCore': best.isEmpty ? null : best,
      'supportingCores': cores,
      'multiCore': multiCore,
      'score': score,
      'confidence': confidence,
      'reason': ranked['reason'],
    };
    return result;
  }

  String _label(String core) => switch (core) {
        'calendar' => 'calendar',
        'tasks' || 'productivity' => 'productivity',
        'expense' || 'money' => 'money',
        'goals' => 'goals',
        'household' => 'household',
        _ => core,
      };
}
