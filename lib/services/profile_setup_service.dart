import 'package:shared_preferences/shared_preferences.dart';

import '../models/currency_option.dart';
import '../models/lifeos_design.dart';
import '../models/user_profile.dart';
import 'user_profile_service.dart';

/// Single entry point for profile preferences used throughout LifeOS.
/// Country and currency are intentionally independent.
class ProfileSetupService {
  final SharedPreferences prefs;
  final UserProfileService profileService;

  ProfileSetupService(this.prefs) : profileService = UserProfileService(prefs);

  UserProfile? load() => profileService.load();

  Future<void> save({
    required String fullName,
    String phoneNumber = '',
    String email = '',
    required String country,
    required CurrencyOption currency,
    String language = 'English',
    int themeIndex = 0,
  }) {
    return profileService.save(
      UserProfile(
        fullName: fullName.trim(),
        phoneNumber: phoneNumber.trim(),
        email: email.trim(),
        country: country,
        currencyCode: currency.code,
        currencySymbol: currency.symbol,
        currencyName: currency.name,
        language: language,
        themeIndex: designByIndex(themeIndex).index,
      ),
    );
  }
}
