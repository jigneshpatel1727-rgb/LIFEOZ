import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Builds a bounded runtime profile from repeated, verified behavioral patterns.
/// It never changes permissions, code, or core policy automatically.
class YansiPersonalPatternProfile {
  final SharedPreferences prefs;
  const YansiPersonalPatternProfile({required this.prefs});

  Future<Map<String, dynamic>> build() async {
    final raw = prefs.getString('yansi_long_term_patterns');
    if (raw == null || raw.isEmpty) return {'patterns': <Map<String, dynamic>>[], 'confidence': 0.0};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return {'patterns': <Map<String, dynamic>>[], 'confidence': 0.0};
      final records = decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).where((e) {
        final observations = (e['observations'] as num?)?.toInt() ?? 0;
        return observations >= 3;
      }).toList();
      final confidence = records.isEmpty ? 0.0 : (records.length / 10.0).clamp(0.0, 1.0).toDouble();
      return {'patterns': records.take(20).toList(), 'confidence': confidence};
    } catch (_) {
      return {'patterns': <Map<String, dynamic>>[], 'confidence': 0.0};
    }
  }

  Future<void> clear() async => prefs.remove('yansi_long_term_patterns');
}
