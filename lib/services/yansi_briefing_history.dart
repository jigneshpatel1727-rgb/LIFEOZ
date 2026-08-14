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

  Future<bool> shouldSurfaceWithContext(
    String headline, {
    required int priority,
    required int confidence,
    Duration repeatAfter = const Duration(hours: 6),
  }) async {
    final normalized = headline.trim();
    if (normalized.isEmpty) return false;
    if (lastHeadline == null || normalized != lastHeadline) return true;

    final oldPriority = prefs.getInt('yansi_last_briefing_priority');
    final oldConfidence = prefs.getInt('yansi_last_briefing_confidence');
    final priorityChanged = oldPriority == null || (priority - oldPriority).abs() >= 10;
    final confidenceChanged = oldConfidence == null || (confidence - oldConfidence).abs() >= 10;
    return shouldSurface(normalized, repeatAfter: repeatAfter, materiallyChanged: priorityChanged || confidenceChanged);
  }

  Future<void> markPresented(String headline, {DateTime? presentedAt, int? priority, int? confidence}) async {
    final normalized = headline.trim();
    if (normalized.isEmpty) return;
    final at = presentedAt ?? DateTime.now();
    await prefs.setString('yansi_last_briefing_headline', normalized);
    await prefs.setInt('yansi_last_briefing_at_ms', at.millisecondsSinceEpoch);
    if (priority != null) await prefs.setInt('yansi_last_briefing_priority', priority.clamp(0, 100));
    if (confidence != null) await prefs.setInt('yansi_last_briefing_confidence', confidence.clamp(0, 100));
  }

  /// Backward-compatible alias for older callers.
  Future<void> markSurfaced(String headline) => markPresented(headline);

  Future<void> clear() async {
    await prefs.remove('yansi_last_briefing_headline');
    await prefs.remove('yansi_last_briefing_at_ms');
    await prefs.remove('yansi_last_briefing_priority');
    await prefs.remove('yansi_last_briefing_confidence');
  }
}
