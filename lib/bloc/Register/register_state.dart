enum RegisterStatus {init, loading, success, failure, failureCheck, duplicateEmail }

class RegisterState{
  final RegisterStatus status;

  RegisterState({
    required this.status
  });
  RegisterState copyWith({RegisterStatus? status}){
    return RegisterState(
        status: status?? this.status
    );
  }
}