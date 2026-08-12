enum LifeOSLoginMethod {
  phoneOtp,
  phonePassword,
  emailPassword,
}

class LifeOSAccount {
  final String userId;
  final String phoneNumber;
  final String email;
  final bool phoneVerified;
  final bool emailVerified;
  final LifeOSLoginMethod? lastLoginMethod;

  const LifeOSAccount({
    required this.userId,
    required this.phoneNumber,
    required this.email,
    required this.phoneVerified,
    required this.emailVerified,
    required this.lastLoginMethod,
  });

  LifeOSAccount copyWith({
    String? userId,
    String? phoneNumber,
    String? email,
    bool? phoneVerified,
    bool? emailVerified,
    LifeOSLoginMethod? lastLoginMethod,
  }) {
    return LifeOSAccount(
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      emailVerified: emailVerified ?? this.emailVerified,
      lastLoginMethod: lastLoginMethod ?? this.lastLoginMethod,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'phoneNumber': phoneNumber,
        'email': email,
        'phoneVerified': phoneVerified,
        'emailVerified': emailVerified,
        'lastLoginMethod': lastLoginMethod?.name,
      };

  factory LifeOSAccount.fromJson(Map<String, dynamic> json) {
    final method = json['lastLoginMethod']?.toString();
    return LifeOSAccount(
      userId: json['userId']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneVerified: json['phoneVerified'] == true,
      emailVerified: json['emailVerified'] == true,
      lastLoginMethod: method == null
          ? null
          : LifeOSLoginMethod.values.where((item) => item.name == method).firstOrNull,
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
