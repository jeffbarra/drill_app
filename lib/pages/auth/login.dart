import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../auth/auth_service.dart';
import '../../widgets/buttons/google_login.dart';
import '../../widgets/buttons/login_register_button.dart';
import '../../widgets/forgot_password_link.dart';
import '../../widgets/text_fields/login_textfield.dart';
import '../../widgets/text_fields/password_textfield.dart';

class LoginPage extends StatefulWidget {
  final Function()? onPressed;
  const LoginPage({super.key, required this.onPressed});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text Editing Controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

// Sign User In
  void signIn() async {
    // get instance of auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    // show loading circle
    showDialog(
        context: context,
        builder: (context) => Center(
            child:
                CircularProgressIndicator(color: Colors.greenAccent.shade400)));
    // try login user using email controller and password controller values
    try {
      await authService.signInWithEmailAndPassword(
          emailTextController.text, passwordTextController.text);

      // if login is successful -> pop loading circle
      if (context.mounted) Navigator.pop(context);

      // if error -> show snackbar with error
    } catch (e) {
      // pop loading circle
      Navigator.pop(context);
      // display error message in snackbar
      showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.success(
            icon: Icon(Icons.error_outline_rounded,
                color: Colors.red.shade600, size: 120),
            backgroundColor: Colors.red.shade400,
            borderRadius: BorderRadius.circular(20),
            textStyle: GoogleFonts.knewave(color: Colors.white, fontSize: 18),
            message: "Oops! Invalid Credentials...",
          ),
          displayDuration: const Duration(milliseconds: 500));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: Column(
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('drill',
                            style: GoogleFonts.knewave(
                                fontSize: 60,
                                color: Colors.greenAccent.shade400)),
                      ],
                    ),
                  ),

                  // Welcome Back Text
                  Text(
                    'Welcome Back!',
                    style:
                        GoogleFonts.knewave(fontSize: 24, color: Colors.white),
                  ),

                  const SizedBox(height: 40),

                  // Email Textfield
                  LoginTextField(
                    controller: emailTextController,
                    hintText: 'Enter Email',
                    obscureText: false,
                    prefixIcon: Icons.email,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // Password Textfield
                  PasswordTextField(controller: passwordTextController),

                  // Forgot Password Link
                  const ForgotPasswordFooter(),

                  // Sign In Button
                  LoginRegisterButton(text: 'Login', onPressed: signIn),

                  const SizedBox(
                    height: 20,
                  ),

                  // Google Button
                  SignInWithGoogleButton(),

                  const SizedBox(height: 20),

                  // Go to Register Page
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Don\'t have an account?',
                          style: GoogleFonts.knewave(color: Colors.white)),
                      TextButton(
                          onPressed: widget.onPressed,
                          child: Text('Register now',
                              style: GoogleFonts.knewave(
                                color: Colors.greenAccent.shade400,
                              ))),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
