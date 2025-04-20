import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter_app/presentation/password_reset/bloc/password_reset_bloc.dart';
import 'package:supabase_flutter_app/presentation/password_reset/bloc/password_reset_event.dart';
import 'package:supabase_flutter_app/presentation/password_reset/bloc/password_reset_state.dart';
import 'package:supabase_flutter_app/presentation/password_reset/pages/resetPassword_page.dart';

class ForgotPasswordPage extends StatelessWidget {
  final String email;
  const ForgotPasswordPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PasswordResetBloc(),
      child: ForgotPasswordView(email: email),
    );
  }
}

class ForgotPasswordView extends StatefulWidget {
  final String email;
  const ForgotPasswordView({super.key, required this.email});

  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _otpController = TextEditingController();

  void _verifyOTP() {
    context.read<PasswordResetBloc>().add(
      VerifyOTP(
        email: widget.email,
        otp: _otpController.text,
      ),
    );
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<PasswordResetBloc, PasswordResetState>(
        listener: (context, state) {
          if (state.status == PasswordResetStatus.failure) {
            _showDialog('Mã OTP không đúng hoặc đã hết hạn!');
          } else if (state.status == PasswordResetStatus.otpVerified && state.session != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordPage(
                  session: state.session!,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 82),
                  Text(
                    'Forgot Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 43, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Verify Code',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter Your OTP Code Sent To Your Email',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: 300),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: state.status == PasswordResetStatus.loading ? null : _verifyOTP,
                      child: state.status == PasswordResetStatus.loading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Submit',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}