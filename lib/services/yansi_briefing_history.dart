import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight persistence for ambient briefing deduplication.
/// Presentation state only: it does not execute LifeOS actions.
class YansiBriefingHistory {
  final SharedPreferences prefs;
  const YansiBriefingHistory({required this.prefs});

  String? get lastHeadline => prefs.getString('yansi_last_briefing_headline');

  DateTime? get lastPresentedAt {
    final ms = prefs.getInt('yansi_last_briefing_at_ms');
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<bool> shouldSurface(
    String headline, {
    Duration repeatAfter = const Duration(hours: 6),
    bool materiallyChanged = false,
  }) async {
    final normalized = headline.trim();
    if (normalized.isEmpty) return false;
    if (lastHeadline == null) return true;
    if (normalized != lastHeadline) return true;
    if (materiallyChanged) return true;

    final shownAt = lastPresentedAt;
    if (shownAt == null) return true;
    return DateTime.now().difference(shownAt) >= repeatAfter;
  }

  Future<void> markPresented(String headline, {DateTime? presentedAt}) async {
    final normalized = headline.trim();
    if (normalized.isEmpty) return;
    final at = presentedAt ?? DateTime.now();
    await prefs.setString('yansi_last_briefing_headline', normalized);
    await prefs.setInt('yansi_last_briefing_at_ms', at.millisecondsSinceEpoch);
  }

  /// Backward-compatible alias for older callers.
  Future<void> markSurfaced(String headline) => markPresented(headline);

  Future<void> clear() async {
    await prefs.remove('yansi_last_briefing_headline');
    await prefs.remove('yansi_last_briefing_at_ms');
  }
}
