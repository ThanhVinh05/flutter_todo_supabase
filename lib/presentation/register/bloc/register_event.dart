abstract class RegisterInEvent{}

class RegisterSignUp extends RegisterInEvent{
  final String email;
  final String password;
  final String confirmPassword;

  RegisterSignUp({
    required this.email,
    required this.password,
    required this.confirmPassword
  });
}

