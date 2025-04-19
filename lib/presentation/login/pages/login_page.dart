import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supabase_flutter_app/forgotPassword_page.dart';
import 'package:supabase_flutter_app/presentation/login/bloc/login_bloc.dart';
import 'package:supabase_flutter_app/presentation/login/bloc/login_event.dart';
import 'package:supabase_flutter_app/presentation/login/bloc/login_state.dart';
import 'package:supabase_flutter_app/presentation/todos/pages/home_page.dart';
import 'package:supabase_flutter_app/presentation/register/pages/register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: LoginPageView(),
    );
  }
}

class LoginPageView extends StatefulWidget {
  const LoginPageView({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPageView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailSendController = TextEditingController();
  final _supabase = Supabase.instance.client;

  Future<void> _signIn() async {
    context.read<LoginBloc>().add(
        LoginSignIn(
            email: _emailController.text,
            password: _passwordController.text)
    );
  }
  Future<void> _sendGmail() async {
    try {
      // await _supabase.auth.signInWithOtp(
      //   email: _emailSendController.text.trim(),
      //   shouldCreateUser: false, // Không tạo user mới nếu email chưa tồn tại
      // );
      await _supabase.auth.resetPasswordForEmail(
        _emailSendController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ForgotPasswordPage(
            email: _emailSendController.text.trim(),
          ),
        ),
      );
    } on AuthException catch (e) {
      if (e.message.contains('user not found')) {
        _showDialog('Email không tồn tại!');
      } else {
        _showDialog('Lỗi hệ thống: ${e.message}');
      }
    } catch (e) {
      _showDialog('Lỗi không xác định!');
    }
  }

  // Future<void> _signIn() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   try {
  //     final response = await _supabase.auth.signInWithPassword(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text.trim(),
  //     );
  //
  //     if (response.user != null) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => HomeScreen()),
  //       );
  //     }
  //   } catch (e) {
  //     _showDialog('Thông tin tài khoản không chính xác');
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }
  

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
      ),
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.success) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (state.status == LoginStatus.failure) {
            _showDialog('Thông tin tài khoản không chính xác');
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
                    'Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Email',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Password',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    style: TextStyle(color: Colors.white),
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: 200),
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
                      onPressed: _signIn,
                      child: Text(
                        'Sign In',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(),
                        ),
                      );
                    },
                    child:Text(
                      'Don\'t have an account? Sign Up',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: Text('Email'),
                            content: TextField(
                              controller: _emailSendController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Enter your email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              autofocus: true,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: _sendGmail,
                                child: Text('Send'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 40.0),
                    ),
                    child: Text(
                      'Forgot password!',
                      style: TextStyle(color: Colors.white70),),
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
