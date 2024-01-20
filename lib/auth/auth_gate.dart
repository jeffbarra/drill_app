import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import 'login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        // listens for changes in auth state
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
// If user IS logged in
          if (snapshot.connectionState == ConnectionState.active) {
            final User? user = snapshot.data;
            // Check if the user is logged in
            if (user != null) {
              // User is logged in, navigate to the home screen
              return BottomNavBarView();
            } else {
              // User is not logged in, navigate to the login screen
              return const LoginOrRegister();
            }
          }
          // Handle other connection states (loading, etc.)
          return CircularProgressIndicator(
            color: Colors.greenAccent.shade400,
          );
        },
      ),
    );
  }
}
