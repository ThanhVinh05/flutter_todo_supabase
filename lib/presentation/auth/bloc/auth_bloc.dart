import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:supabase_flutter_app/presentation/Auth/bloc/auth_event.dart';
import 'package:supabase_flutter_app/presentation/Auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent,AuthState>{
  AuthBloc() : super(
    AuthState(
      isAuthenticated: false,
      status: AuthStatus.initial
    )){
      on<AuthCheck>(_onAuthCheck);
  }

  void _onAuthCheck(AuthCheck event, Emitter<AuthState> emit) async{
      emit (state.copyWith(status : AuthStatus.loading));

      final supabase = sb.Supabase.instance.client;
      final user = supabase.auth.currentSession?.user;

      if(user != null){
        emit(state.copyWith(
          isAuthenticated: true,
          status: AuthStatus.success,
        ));
      }else{
        emit(state.copyWith(
          isAuthenticated: false,
          status: AuthStatus.initial,
        ));
      }

  }
}