import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drill_app/widgets/bottom_navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class PersonalTrainerSignUpTile extends StatefulWidget {
  const PersonalTrainerSignUpTile({Key? key}) : super(key: key);

  @override
  State<PersonalTrainerSignUpTile> createState() =>
      _PersonalTrainerSignUpTileState();
}

class _PersonalTrainerSignUpTileState extends State<PersonalTrainerSignUpTile> {
  late final currentUser = FirebaseAuth.instance.currentUser!;
  late bool isActivated;
  late String? trainerCode;
  late StreamSubscription<DocumentSnapshot>? trainerCodeSubscription;
  bool dataLoaded = false; // Track whether data has been loaded or not

  @override
  void initState() {
    super.initState();
    // Initialize isActivated as false initially
    isActivated = false;
    // Fetch the trainerCode from Firestore initially
    fetchData();

    // Initialize trainerCodeSubscription
    trainerCodeSubscription = FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser.email)
        .snapshots()
        .listen((event) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.email)
          .get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final personalTrainerStatus = data["isPersonalTrainer"] ?? false;
        final code = data["trainerCode"];

        setState(() {
          isActivated = personalTrainerStatus;
          trainerCode = code;
          dataLoaded = true; // Mark data as loaded
        });
      }
    } catch (error) {
      print("Error checking Firestore: $error");
    }
  }

  Future<void> updateClientsField() async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.email)
          .update({
        "isPersonalTrainer": true,
        "clients": [],
      });
    } catch (error) {
      print("Error updating Firestore: $error");
    }
  }

  Future<void> generateAndSetTrainerCode() async {
    final Random random = Random();
    final int min = 100000;
    final int max = 999999;
    final int trainerCode = min + random.nextInt(max - min);

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.email)
          .update({
        "isPersonalTrainer": true,
        "trainerCode": trainerCode.toString(),
      });
    } catch (error) {
      print("Error updating Firestore: $error");
    }
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    trainerCodeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!dataLoaded) {
      // If data is not loaded, show a loading indicator or placeholder
      return const CircularProgressIndicator(color: Colors.transparent);
    } else {
      // If data is loaded, display the actual widget
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              border: Border.all(color: Colors.grey.shade700, width: 2.0),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: ListTile(
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isActivated && trainerCode != null
                            ? 'Your Trainer Code'
                            : 'Activate Trainer Mode',
                        style: GoogleFonts.knewave(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                ],
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: isActivated
                        ? Colors.greenAccent.shade400
                        : Colors.grey.shade700),
                onPressed: () {
                  isActivated && trainerCode != null
                      // Trainer Code Dialog Box
                      ? showDialog(
                          context: context,
                          builder: ((context) => AlertDialog(
                                title: Text(
                                  'Your Trainer Code:',
                                  style:
                                      GoogleFonts.knewave(color: Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                                content: Text(
                                  trainerCode!,
                                  style: GoogleFonts.knewave(
                                      color: Colors.black, fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                              )))
                      // Sign Up Dialog Box
                      : showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              'Sign Up as a Personal Trainer?',
                              style: GoogleFonts.knewave(),
                              textAlign: TextAlign.center,
                            ),
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Cancel Button
                                Container(
                                  width: 90,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.greenAccent.shade400,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.knewave(
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                // Sign Up Button
                                Container(
                                  width: 90,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.greenAccent.shade400,
                                    ),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      Get.to(() => BottomNavBarView(),
                                          transition: Transition.noTransition,
                                          duration: const Duration(
                                              milliseconds: 500));
                                      showTopSnackBar(
                                          Overlay.of(context),
                                          CustomSnackBar.success(
                                            icon: Icon(
                                                Icons
                                                    .check_circle_outline_rounded,
                                                color:
                                                    Colors.greenAccent.shade700,
                                                size: 120),
                                            backgroundColor:
                                                Colors.greenAccent.shade400,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            textStyle: GoogleFonts.knewave(
                                                color: Colors.black,
                                                fontSize: 18),
                                            message: "Successfully Signed Up!",
                                          ),
                                          displayDuration: const Duration(
                                              milliseconds: 500));
                                      await updateClientsField();
                                      await generateAndSetTrainerCode();
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(currentUser.email)
                                            .update({
                                          "isPersonalTrainer": true,
                                        });
                                        setState(() {
                                          isActivated = true;
                                        });
                                      } catch (error) {
                                        print(
                                            "Error updating Firestore: $error");
                                      }
                                    },
                                    child: Text(
                                      'Sign Up',
                                      style: GoogleFonts.knewave(
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                },
                child: Text(
                  isActivated && trainerCode != null ? 'View' : 'Activate',
                  style: GoogleFonts.knewave(
                      color: isActivated ? Colors.black : Colors.white),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}
