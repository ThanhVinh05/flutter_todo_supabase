import 'package:supabase_flutter/supabase_flutter.dart';

enum PasswordResetStatus { initial, loading, emailSent, otpVerified, passwordReset, failure }

class PasswordResetState {
  final PasswordResetStatus status;
  final String email;
  final Session? session;

  PasswordResetState({
    this.status = PasswordResetStatus.initial,
    this.email = '',
    this.session,
  });

  PasswordResetState copyWith({
    PasswordResetStatus? status,
    String? email,
    Session? session,
  }) {
    return PasswordResetState(
      status: status ?? this.status,
      email: email ?? this.email,
      session: session ?? this.session,
    );
  }
}