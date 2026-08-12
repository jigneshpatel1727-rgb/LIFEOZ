import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

/// Persists the user's LifeOS identity and presentation preferences.
/// Authentication credentials are deliberately not stored here.
class UserProfileService {
  static const String _key = 'lifeos_user_profile';

  final SharedPreferences prefs;

  const UserProfileService(this.prefs);

  UserProfile? load() {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;

    try {
      return UserProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(UserProfile profile) async {
    await prefs.setString(_key, jsonEncode(profile.toJson()));

    // Compatibility with the existing application while the new profile
    // model is connected to every screen.
    await prefs.setString('user_name', profile.fullName);
    await prefs.setString('phone_number', profile.phoneNumber);
    await prefs.setString('email', profile.email);
    await prefs.setString('country', profile.country);
    await prefs.setString('currency', profile.currencySymbol);
    await prefs.setString('currency_code', profile.currencyCode);
    await prefs.setString('currency_name', profile.currencyName);
    await prefs.setString('language', profile.language);
    await prefs.setInt('theme_index', profile.themeIndex);
  }

  Future<void> clear() async {
    await prefs.remove(_key);
  }
}
