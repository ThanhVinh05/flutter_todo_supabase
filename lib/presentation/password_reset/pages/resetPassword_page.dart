import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_app/presentation/login/pages/login_page.dart';
import 'package:supabase_flutter_app/presentation/password_reset/bloc/password_reset_bloc.dart';
import 'package:supabase_flutter_app/presentation/password_reset/bloc/password_reset_event.dart';
import 'package:supabase_flutter_app/presentation/password_reset/bloc/password_reset_state.dart';

class ResetPasswordPage extends StatelessWidget {
  final Session session;
  const ResetPasswordPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PasswordResetBloc(),
      child: ResetPasswordView(session: session),
    );
  }
}

class ResetPasswordView extends StatefulWidget {
  final Session session;
  const ResetPasswordView({super.key, required this.session});

  @override
  _ResetPasswordViewState createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _viewNewPassword = true;
  bool _viewConfirmPassword = true;

  void _resetPassword() {
    context.read<PasswordResetBloc>().add(
      ResetPassword(
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
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
            _showDialog('Mật khẩu không trùng khớp hoặc có lỗi xảy ra!');
          } else if (state.status == PasswordResetStatus.passwordReset) {
            // Đăng xuất và quay lại màn hình login
            _supabase.auth.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false,
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
                  SizedBox(height: 32),
                  Text(
                    'Reset Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 45, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 32),
                  Text(
                    'New Password',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: _viewNewPassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter New Password',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _viewNewPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _viewNewPassword = !_viewNewPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Re-Enter New Password',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _viewConfirmPassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Re-enter New Password',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _viewConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _viewConfirmPassword = !_viewConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 240),
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
                      onPressed: state.status == PasswordResetStatus.loading ? null : _resetPassword,
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