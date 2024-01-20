import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drill_app/widgets/buttons/google_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../widgets/buttons/login_register_button.dart';
import '../../widgets/text_fields/login_textfield.dart';
import '../../widgets/text_fields/password_textfield.dart';

class SignUpPage extends StatefulWidget {
  final Function()? onPressed;
  const SignUpPage({super.key, required this.onPressed});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
// Text Editing Controllers
  final fullNameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

// Image URL for Profile Pic
  String imageUrl = "";

// Personal Trainer Status
  bool isPersonalTrainer = false;

// Sign User Up
  signUp() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: Colors.greenAccent.shade400),
      ),
    );

    // error handlers
    try {
// Create the User
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailTextController.text,
              password: passwordTextController.text);

      // after creating the user, create new collection called "users"
      FirebaseFirestore.instance
          // create the collection
          .collection('users')
          // create doc for userCredential
          .doc(userCredential.user!.email)
          .set({
        // set full name
        'fullName': fullNameTextController.text,
        // set 'username' -> text before @ sign in email
        'username': emailTextController.text.split('@')[0],
        // set 'bio'
        'bio': 'Enter your bio here...',
        // set profile pic
        'profilePic': imageUrl,
        // set email
        'email': userCredential.user!.email,
        // personal trainer status
        'isPersonalTrainer': isPersonalTrainer,
        // personal trainer
        'personalTrainer': null,
      });
      // pop loading circle
      if (context.mounted) Navigator.pop(context);

      // if error -> display error within snackbar
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
            textStyle: GoogleFonts.knewave(color: Colors.black, fontSize: 18),
            message: "Yikes! Invalid Login/Password...",
          ),
          displayDuration: const Duration(milliseconds: 500));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: SingleChildScrollView(
          // physics: const NeverScrollableScrollPhysics(),
          child: SafeArea(
              child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
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

                // Welcome Back Message
                Text('Hello There!',
                    style:
                        GoogleFonts.knewave(fontSize: 24, color: Colors.white)),

                const SizedBox(
                  height: 40,
                ),

                // Email Textfield
                LoginTextField(
                  controller: fullNameTextController,
                  hintText: 'Enter Name',
                  obscureText: false,
                  prefixIcon: Icons.person,
                ),

                const SizedBox(
                  height: 10,
                ),

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

                //  Password Textfield
                PasswordTextField(
                  controller: passwordTextController,
                ),

                const SizedBox(height: 20),

                // Sign Up Button
                LoginRegisterButton(text: 'Sign Up', onPressed: signUp),

                const SizedBox(
                  height: 20,
                ),

                // Google Button
                SignUpWithGoogleButton(
                  text: 'Sign Up with Google',
                ),

                const SizedBox(height: 20),

                // Go to Register Page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?',
                        style: GoogleFonts.knewave(color: Colors.white)),
                    TextButton(
                        onPressed: widget.onPressed,
                        child: Text('Login now',
                            style: GoogleFonts.knewave(
                              color: Colors.greenAccent.shade400,
                            ))),
                  ],
                )
              ],
            ),
          )),
        ));
  }
}
