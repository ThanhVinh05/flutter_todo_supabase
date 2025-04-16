abstract class LoginInEvent {}

class LoginSignIn extends LoginInEvent{
  final String email;
  final String password;

  LoginSignIn({
    required this.email,
    required this.password});

}
