import 'package:shared_preferences/shared_preferences.dart';

/// Permission-controlled boundary for current-information providers.
/// No network call is made unless the user has enabled web access.
class YansiWebIntelligence {
  static const permissionKey = 'yansi_web_access_enabled';
  final SharedPreferences prefs;

  const YansiWebIntelligence(this.prefs);

  bool get isEnabled => prefs.getBool(permissionKey) ?? false;

  Future<void> setEnabled(bool enabled) => prefs.setBool(permissionKey, enabled);

  YansiWebRequest prepare(String question) {
    final text = question.trim();
    if (!isEnabled) {
      return YansiWebRequest(
        question: text,
        allowed: false,
        message: 'Web access is currently off. Enable web access in permissions if you want me to use current external information.',
      );
    }

    return YansiWebRequest(
      question: text,
      allowed: true,
      message: 'Web research is permitted for this request.',
    );
  }
}

class YansiWebRequest {
  final String question;
  final bool allowed;
  final String message;

  const YansiWebRequest({
    required this.question,
    required this.allowed,
    required this.message,
  });
}
