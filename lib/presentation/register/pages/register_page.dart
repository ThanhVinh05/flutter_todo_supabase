import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter_app/presentation/register/bloc/register_bloc.dart';
import 'package:supabase_flutter_app/presentation/register/bloc/register_event.dart';
import 'package:supabase_flutter_app/presentation/register/bloc/register_state.dart';


class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterBloc(),
      child: RegisterPageView(),
    );
  }
}

class RegisterPageView extends StatefulWidget {
  const RegisterPageView({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPageView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _supabase = Supabase.instance.client;


  Future<void> _signUp() async {
    context.read<RegisterBloc>().add(
        RegisterSignUp(
            email: _emailController.text,
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text
        )
    );
  }

  // Future<void> _signUp() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   try {
  //     final response = await _supabase.auth.signUp(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text.trim(),
  //     );
  //
  //     if (response.user != null) {
  //       _showDialog('Đăng ký thành công! Vui lòng kiểm tra email của bạn.');
  //     }
  //   } catch (e) {
  //     _showDialog('Vui lòng điền đầy đủ thông tin.');
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
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state.status == RegisterStatus.success) {
            // _showDialog('Đăng ký thành công! Vui lòng kiểm tra email của bạn.');
            Navigator.pop(
                context
            );
          } else if (state.status == RegisterStatus.failureCheck) {
            _showDialog('Vui lòng điền khớp thông tin Password.');
          } else if (state.status == RegisterStatus.failure) {
            _showDialog('Vui lòng điền đầy đủ thông tin.');
          } else if (state.status == RegisterStatus.duplicateEmail) {
            _showDialog('Email đã tồn tại.');
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
                    'Sign Up',
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
                  SizedBox(height: 24),
                  Text(
                    'Confirm Password',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _confirmPasswordController,
                    style: TextStyle(color: Colors.white),
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Re-enter your password',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: 120),
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
                      onPressed: _signUp,
                      child: Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(
                        context
                      );
                    },
                    child: Text(
                      'You Already Have An Account? Login',
                      style: TextStyle(color: Colors.white70),
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
