import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:supabase_flutter_app/presentation/login/bloc/login_event.dart';
import 'package:supabase_flutter_app/presentation/login/bloc/login_state.dart';


class LoginBloc extends Bloc<LoginInEvent,LoginState>{
  LoginBloc() : super(
      LoginState(
          status: LoginStatus.init
      )){
    on<LoginSignIn>(_onSignIn);
  }
  void _onSignIn(LoginSignIn event, Emitter<LoginState> emit) async{
    emit (state.copyWith(status : LoginStatus.loading));

    final _supabase = sb.Supabase.instance.client;


    try {
      final response = await _supabase.auth.signInWithPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );

      if (response.user != null) {
        emit (state.copyWith(status : LoginStatus.success));
      }
    } catch (e) {
      emit (state.copyWith(status : LoginStatus.failure));
    }
  }
}