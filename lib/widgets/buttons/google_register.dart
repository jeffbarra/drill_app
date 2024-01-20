import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpWithGoogleButton extends StatelessWidget {
// Text Editing Controllers
  final fullNameTextController = TextEditingController();
  final emailTextController = TextEditingController();

// Get Auth Instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

// Google Sign In Method
  final GoogleSignIn googleSignIn = GoogleSignIn();

// Image URL for Profile Pic
  String imageUrl = "";

// Handle Google Sign Up
  Future<User?> _handleSignUp() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        // Request access to the user's Google profile information
        final GoogleSignInAccount googleUser = await googleSignInAccount;
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        // Extract the user's full name from the Google profile
        final String fullName = googleUser.displayName ?? '';

        // Add the user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.email)
            .set({
          'fullName': fullName,
          'username': user.email!.split('@')[0],
          'bio': 'Enter your bio here...',
          'profilePic': imageUrl,
          'email': user.email,
        });

        return user;
      }
    } catch (error) {
      print(error);
      return null;
    }
    return null;
  }

  final String text;
  SignUpWithGoogleButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.black)),
        icon: const Image(
          image: AssetImage(
            'lib/assets/images/google_logo.png',
          ),
          width: 30,
        ),
        onPressed: () async {
          final User? user = await _handleSignUp();
          if (user != null) {
            // User signed in successfully, navigate to your app's main screen.
          } else {
            // Handle sign-in error.
          }
        },
        label: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            text,
            style: GoogleFonts.knewave(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}


// // Add this to the Info.plist file

// 	<!-- Google Sign-in Section -->
// <key>CFBundleURLTypes</key>
// <array>
// 	<dict>
// 		<key>CFBundleTypeRole</key>
// 		<string>Editor</string>
// 		<key>CFBundleURLSchemes</key>
// 		<array>
// 			<!-- TODO Replace this value: -->
// 			<!-- Copied from GoogleService-Info.plist key REVERSED_CLIENT_ID -->
// 			<string>com.googleusercontent.apps.277268262224-mk4d859lgpgg7cjk1ac81nj7vo8d4fm0</string>
// 		</array>
// 	</dict>
// </array>
// <!-- End of the Google Sign-in Section -->
