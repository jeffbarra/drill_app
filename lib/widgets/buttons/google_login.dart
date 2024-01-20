import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class SignInWithGoogleButton extends StatefulWidget {
  const SignInWithGoogleButton({super.key});

  @override
  State<SignInWithGoogleButton> createState() => _SignInWithGoogleButtonState();
}

class _SignInWithGoogleButtonState extends State<SignInWithGoogleButton> {
  late ScaffoldMessengerState _scaffoldMessenger;
  OverlayState? _overlayState;
// If the user isn't found in firebase, it signs them out which disposes the whole page, including the scaffold snackbar.
// Doing this will prevent the scaffold snackbar from disposing -> allowing it to be displayed

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    _overlayState = Overlay.of(context);
  }

// Variables
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Sign in With Google -> Only if User Already Exists
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount == null) {
        // The user canceled the sign-in process
        return;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        // Check if the user exists in the Firestore database
        final DocumentSnapshot snapshot = await _firestore
            .collection('users')
            .doc(authResult.user!
                .email) // has to be this in order for it to work based on firebase doc
            .get();
        if (!snapshot.exists) {
          // User does not exist, display a snackbar and sign out the user
          await _auth.signOut();
          // call _scaffoldMessenger from above to prevent error and show snackbar
          showTopSnackBar(
              _overlayState!,
              CustomSnackBar.success(
                icon: Icon(Icons.error_outline_rounded,
                    color: Colors.red.shade600, size: 120),
                backgroundColor: Colors.red.shade400,
                borderRadius: BorderRadius.circular(20),
                textStyle:
                    GoogleFonts.knewave(color: Colors.white, fontSize: 18),
                message: "User does not exist! Please register first",
              ),
              displayDuration: const Duration(milliseconds: 500));
          ;
          // You can handle this case as needed, e.g., navigate to a registration screen
        } else {
          // User exists, allow login
          // You can navigate to the home screen or perform other actions here
        }
      }
    } catch (error) {
      print(error.toString());
      // Handle any errors that occur during the Google sign-in process
      showTopSnackBar(
          _overlayState!,
          CustomSnackBar.success(
            icon: Icon(Icons.error_outline_rounded,
                color: Colors.red.shade600, size: 120),
            backgroundColor: Colors.red.shade400,
            borderRadius: BorderRadius.circular(20),
            textStyle: GoogleFonts.knewave(color: Colors.white, fontSize: 18),
            message: "Yikes! An error occurred...please try again later!",
          ),
          displayDuration: const Duration(milliseconds: 500));
    }
  }

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
          onPressed: () {
            signInWithGoogle(context);
          },
          label: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Sign In with Google',
              style: GoogleFonts.knewave(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
        ));
  }
}
