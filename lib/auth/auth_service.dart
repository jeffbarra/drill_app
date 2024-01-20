import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// "Provider" state mgmt -> add "extends ChangeNotifier"
class AuthService extends ChangeNotifier {
// Instance for Auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

// Instance of FireStore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

// Sign User In
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      // sign in first
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // add a new doc for the user in 'users' collection just in case it doesn't already exist
      _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        // merge doc if it doesn't exist
      }, SetOptions(merge: true));

      // sign user in
      return userCredential;
    }
    // catch any errors
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

// Sign User Out
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }

// Create a New User (Register)
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password) async {
    // try signing up the user first
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // after creating the user, create a collection called 'users' and new doc (UserCredential) for the user and set fields
      _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      });

      // sign up user
      return userCredential;

      // if error -> throw exception with error code
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
}
