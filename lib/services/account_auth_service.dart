/// Authentication contract for the production account layer.
///
/// This deliberately contains no fake OTP generation and no plaintext
/// password storage. A Firebase/Supabase implementation can be plugged in
/// later while the rest of LifeOS continues using this interface.
abstract class AccountAuthService {
  Future<AuthAccount> signInWithPhoneOtp(String phone, String verificationId, String otp);
  Future<AuthAccount> signInWithPhonePassword(String phone, String password);
  Future<AuthAccount> signInWithEmailPassword(String email, String password);
  Future<void> requestPhoneOtp(String phone);
  Future<void> resetPassword(String email);
  Future<void> signOut();
}

class AuthAccount {
  final String userId;
  final String? phone;
  final String? email;

  const AuthAccount({
    required this.userId,
    this.phone,
    this.email,
  });
}
