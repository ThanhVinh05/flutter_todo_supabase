import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:supabase_flutter_app/bloc/Register/register_event.dart';
import 'package:supabase_flutter_app/bloc/Register/register_state.dart';

class RegisterBloc extends Bloc<RegisterInEvent,RegisterState> {
  RegisterBloc() : super(
      RegisterState(
          status: RegisterStatus.init
      )) {
    on<RegisterSignUp>(_onSignUp);
  }
  void _onSignUp(RegisterSignUp event, Emitter<RegisterState> emit) async{
    emit (state.copyWith(status : RegisterStatus.loading));

    if (event.password.trim() != event.confirmPassword.trim()) {
      emit(state.copyWith(status: RegisterStatus.failureCheck));
      return;
    }

    final _supabase = sb.Supabase.instance.client;


    try {

      final request = await _supabase.auth.signUp(
        email: event.email.trim(),
        password: event.password.trim(),
      );

      if(request.user?.userMetadata?.isEmpty ?? false){
        emit (state.copyWith(status : RegisterStatus.duplicateEmail));
      }
      else {
        emit (state.copyWith(status : RegisterStatus.success));
      }
    } catch (e) {
      emit (state.copyWith(status : RegisterStatus.failure));
    }
  }
}