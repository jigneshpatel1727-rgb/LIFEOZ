import 'yansi_personal_intelligence_loop.dart';

/// Converts Yansi's structured intelligence into a short, human-friendly
/// briefing suitable for voice or a compact ambient UI.
class YansiDailyLifeBriefing {
  final YansiPersonalIntelligenceLoop intelligence;

  const YansiDailyLifeBriefing(this.intelligence);

  Map<String, dynamic> build() {
    final snapshot = intelligence.snapshot();
    final suggestions = intelligence.suggestions();
    final hour = DateTime.now().hour;

    final greeting = hour < 12
        ? 'Good morning.'
        : hour < 18
            ? 'Good afternoon.'
            : 'Good evening.';

    return {
      'greeting': greeting,
      'suggestions': suggestions,
      'budget': snapshot['budget'],
      'household': snapshot['household_predictions'],
      'behaviour': snapshot['behaviour'],
      'generated_at': snapshot['generated_at'],
    };
  }

  String toSpeech() {
    final briefing = build();
    final suggestions = (briefing['suggestions'] as List<dynamic>).cast<String>();
    return '${briefing['greeting']} I have reviewed your LifeOS pattern. '
        '${suggestions.isEmpty ? 'There is nothing urgent right now.' : suggestions.first}';
  }
}
