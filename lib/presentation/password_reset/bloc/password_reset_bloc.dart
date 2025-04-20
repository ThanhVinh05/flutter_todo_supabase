import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:supabase_flutter_app/presentation/password_reset/bloc/password_reset_event.dart';
import 'package:supabase_flutter_app/presentation/password_reset/bloc/password_reset_state.dart';

class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  PasswordResetBloc() : super(PasswordResetState()) {
    on<SendResetEmail>(_onSendResetEmail);
    on<VerifyOTP>(_onVerifyOTP);
    on<ResetPassword>(_onResetPassword);
  }

  final _supabase = sb.Supabase.instance.client;

  Future<void> _onSendResetEmail(SendResetEmail event, Emitter<PasswordResetState> emit) async {
    emit(state.copyWith(status: PasswordResetStatus.loading));

    try {
      await _supabase.auth.resetPasswordForEmail(
        event.email.trim(),
      );

      emit(state.copyWith(
        status: PasswordResetStatus.emailSent,
        email: event.email.trim(),
      ));
    } catch (e) {
      emit(state.copyWith(status: PasswordResetStatus.failure));
    }
  }

  Future<void> _onVerifyOTP(VerifyOTP event, Emitter<PasswordResetState> emit) async {
    emit(state.copyWith(status: PasswordResetStatus.loading));

    try {
      final response = await _supabase.auth.verifyOTP(
        email: event.email,
        token: event.otp,
        type: sb.OtpType.recovery,
      );

      if (response.session != null) {
        emit(state.copyWith(
          status: PasswordResetStatus.otpVerified,
          session: response.session,
        ));
      } else {
        emit(state.copyWith(status: PasswordResetStatus.failure));
      }
    } catch (e) {
      emit(state.copyWith(status: PasswordResetStatus.failure));
    }
  }

  Future<void> _onResetPassword(ResetPassword event, Emitter<PasswordResetState> emit) async {
    if (event.newPassword != event.confirmPassword) {
      emit(state.copyWith(status: PasswordResetStatus.failure));
      return;
    }

    emit(state.copyWith(status: PasswordResetStatus.loading));

    try {
      await _supabase.auth.updateUser(
        sb.UserAttributes(
          password: event.newPassword,
        ),
      );

      emit(state.copyWith(status: PasswordResetStatus.passwordReset));
    } catch (e) {
      emit(state.copyWith(status: PasswordResetStatus.failure));
    }
  }
}