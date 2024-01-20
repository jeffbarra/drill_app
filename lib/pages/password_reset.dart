import 'package:drill_app/auth/auth_gate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/text_fields/login_textfield.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
// Email Controller
  final _emailController = TextEditingController();

// Memory management
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Password Reset Button Method
  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      // successful email sent message
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
                child: Text(
              'Email Sent!',
              style: GoogleFonts.knewave(),
            )),
            // confirmation message box
            content: Text(
              'Check your email for a link to reset your password.',
              style: GoogleFonts.knewave(),
              textAlign: TextAlign.center,
            ),
            // back to login button
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.shade400),
                      onPressed: () {
                        Get.to(() => const AuthGate(),
                            transition: Transition.leftToRight,
                            duration: const Duration(milliseconds: 500));
                      },
                      child: Text(
                        'Back to Login',
                        style: GoogleFonts.knewave(color: Colors.black),
                      )),
                ),
              ),
            ],
          );
        },
      );
      // error handler
    } on FirebaseAuthException catch (e) {
      print(e);
      // No email found error
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Oops!',
              style: GoogleFonts.knewave(),
              textAlign: TextAlign.center,
            ),
            content: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                'No user found with that email address.',
                style: GoogleFonts.knewave(),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.grey.shade900,
        elevation: 0,
        title: Text('Reset Password',
            style: GoogleFonts.knewave(
              color: Colors.white,
              fontSize: 30,
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 50.0, bottom: 50.0),
            ),

// Instructions
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: Text(
                'Enter your email address and we will send you a link to reset your password.',
                style: GoogleFonts.knewave(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 30),

// Form Field
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Column(
                children: [
                  LoginTextField(
                      controller: _emailController,
                      hintText: 'Enter email',
                      obscureText: false,
                      prefixIcon: Icons.email),

                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade700),
                          backgroundColor: Colors.greenAccent.shade400),
                      onPressed: () {
                        passwordReset();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          'Submit',
                          style: GoogleFonts.knewave(
                              fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
