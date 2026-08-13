import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Turns user-approved learning patterns into explainable suggestions.
/// It never executes actions or grants itself permissions.
class YansiPatternAdvice {
  final String title;
  final String suggestion;
  final String reason;
  final double confidence;
  const YansiPatternAdvice({required this.title,required this.suggestion,required this.reason,required this.confidence});
}

class YansiPatternAdviceService {
  final SharedPreferences prefs;
  const YansiPatternAdviceService({required this.prefs});

  bool get enabled => prefs.getBool('permission_personal_learning') == true;

  Future<YansiPatternAdvice?> build() async {
    if (!enabled) return null;
    final raw = prefs.getStringList('yansi_learned_patterns') ?? const <String>[];
    final patterns = <Map<String,dynamic>>[];
    for (final value in raw) {
      try { patterns.add(Map<String,dynamic>.from(jsonDecode(value) as Map)); } catch (_) {}
    }
    if (patterns.isEmpty) return null;
    patterns.sort((a,b) => ((b['confidence'] as num?)?.toDouble() ?? 0).compareTo((a['confidence'] as num?)?.toDouble() ?? 0));
    final p = patterns.first;
    final topic = '${p['topic'] ?? ''}'.trim();
    final observation = '${p['observation'] ?? ''}'.trim();
    if (topic.isEmpty) return null;
    final confidence = ((p['confidence'] as num?)?.toDouble() ?? .5).clamp(0,1).toDouble();
    return YansiPatternAdvice(
      title: 'A pattern I noticed',
      suggestion: 'Consider giving a little attention to $topic today.',
      reason: observation.isEmpty ? 'Based on an approved recurring LifeOS pattern.' : 'Based on this approved recurring pattern: $observation',
      confidence: confidence,
    );
  }
}
