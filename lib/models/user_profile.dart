class UserProfile {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String country;
  final String currencyCode;
  final String currencySymbol;
  final String currencyName;
  final String language;
  final int themeIndex;

  const UserProfile({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.country,
    required this.currencyCode,
    required this.currencySymbol,
    required this.currencyName,
    required this.language,
    required this.themeIndex,
  });

  UserProfile copyWith({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? country,
    String? currencyCode,
    String? currencySymbol,
    String? currencyName,
    String? language,
    int? themeIndex,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      country: country ?? this.country,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyName: currencyName ?? this.currencyName,
      language: language ?? this.language,
      themeIndex: themeIndex ?? this.themeIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'email': email,
        'country': country,
        'currencyCode': currencyCode,
        'currencySymbol': currencySymbol,
        'currencyName': currencyName,
        'language': language,
        'themeIndex': themeIndex,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
      country: json['country'] as String? ?? 'India',
      currencyCode: json['currencyCode'] as String? ?? 'INR',
      currencySymbol: json['currencySymbol'] as String? ?? '₹',
      currencyName: json['currencyName'] as String? ?? 'Indian Rupee',
      language: json['language'] as String? ?? 'English',
      themeIndex: json['themeIndex'] as int? ?? 0,
    );
  }
}
