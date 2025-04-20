abstract class PasswordResetEvent {}

class SendResetEmail extends PasswordResetEvent {
  final String email;

  SendResetEmail({required this.email});
}

class VerifyOTP extends PasswordResetEvent {
  final String email;
  final String otp;

  VerifyOTP({required this.email, required this.otp});
}

class ResetPassword extends PasswordResetEvent {
  final String newPassword;
  final String confirmPassword;

  ResetPassword({required this.newPassword, required this.confirmPassword});
}