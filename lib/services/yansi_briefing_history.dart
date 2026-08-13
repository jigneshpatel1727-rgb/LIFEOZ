import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight persistence for ambient briefing deduplication.
/// Keeps Yansi from repeating the same headline every time the app resumes.
class YansiBriefingHistory {
  final SharedPreferences prefs;
  const YansiBriefingHistory({required this.prefs});

  String? get lastHeadline => prefs.getString('yansi_last_briefing_headline');

  Future<bool> shouldSurface(String headline) async {
    final normalized = headline.trim();
    if (normalized.isEmpty) return false;
    if (normalized == lastHeadline) return false;
    return true;
  }

  Future<void> markSurfaced(String headline) async {
    final normalized = headline.trim();
    if (normalized.isEmpty) return;
    await prefs.setString('yansi_last_briefing_headline', normalized);
    await prefs.setInt('yansi_last_briefing_at_ms', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> clear() async {
    await prefs.remove('yansi_last_briefing_headline');
    await prefs.remove('yansi_last_briefing_at_ms');
  }
}
