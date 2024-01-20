import 'package:drill_app/pages/client_workout_details_page.dart';
import 'package:drill_app/pages/workout_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: must_be_immutable
class ClientWorkoutTile extends StatefulWidget {
  final String workoutName;
  final String workoutId;

  final String clientEmail;
  final String clientName;
  void Function(BuildContext)? onPressed;
  void Function(BuildContext)? onPressedTwo;

  ClientWorkoutTile({
    Key? key,
    required this.workoutName,
    required this.workoutId,
    required this.onPressed,
    required this.onPressedTwo,
    required this.clientEmail,
    required this.clientName,
  }) : super(key: key);

  @override
  State<ClientWorkoutTile> createState() => _ClientWorkoutTileState();
}

class _ClientWorkoutTileState extends State<ClientWorkoutTile> {
  // List of image paths
  List<String> imagePaths = [
    'lib/assets/images/abs.png',
    'lib/assets/images/cardio.png',
    'lib/assets/images/curls.png',
    'lib/assets/images/cycling.png',
    'lib/assets/images/jump_rope.png',
    'lib/assets/images/karate.png',
    'lib/assets/images/kickboxing.png',
    'lib/assets/images/lats.png',
    'lib/assets/images/legs.png',
    'lib/assets/images/pull_ups.png',
    'lib/assets/images/punch.png',
    'lib/assets/images/push_ups.png',
    'lib/assets/images/row.png',
    'lib/assets/images/running.png',
    'lib/assets/images/shoulders.png',
    'lib/assets/images/squats.png',
    'lib/assets/images/stretching.png',
    'lib/assets/images/swim.png',
    'lib/assets/images/weights.png',
    'lib/assets/images/yoga.png',
  ];

  String selectedImagePath = 'lib/assets/images/running.png'; // Set default

  late Future<void> imagePathInitialization;

  @override
  void initState() {
    super.initState();
    imagePathInitialization = initializeSelectedImagePath();
  }

  // Helper method to retrieve the selected image path from Firestore
  Future<void> initializeSelectedImagePath() async {
    try {
      // Fetch the value from Firestore or use the default value
      final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientEmail)
          .collection('user_workouts')
          .doc(widget.workoutId)
          .get();

      if (documentSnapshot.exists) {
        final Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        final String? imagePath = data['icon'];
        selectedImagePath = imagePath ?? 'defaultImagePath';
      } else {
        selectedImagePath = 'defaultImagePath';
      }
    } catch (e) {
      print('Error initializing selectedImagePath: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
      child: FutureBuilder(
        future: imagePathInitialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Slidable(
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: widget.onPressedTwo,
                    icon: Icons.edit_rounded,
                    foregroundColor: Colors.blue.shade400,
                    backgroundColor: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  SlidableAction(
                    onPressed: widget.onPressed,
                    icon: Icons.delete,
                    foregroundColor: Colors.red.shade400,
                    backgroundColor: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.only(
                    top: 20, bottom: 20, left: 10, right: 10),
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
                  title: Text(
                    widget.workoutName,
                    textAlign: TextAlign.center,
                    style:
                        GoogleFonts.knewave(fontSize: 20, color: Colors.white),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: () async {
                        int? selectedIndex = await showDialog<int>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              'Select an Icon',
                              style: GoogleFonts.knewave(),
                              textAlign: TextAlign.center,
                            ),
                            content: SizedBox(
                              width: double.maxFinite,
                              height: 300,
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 8.0,
                                  crossAxisSpacing: 8.0,
                                ),
                                itemCount: imagePaths.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      // Set the selected image path based on the index
                                      selectedImagePath = imagePaths[index];
                                      Navigator.pop(context, index);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Image.asset(
                                        imagePaths[index],
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );

                        if (selectedIndex != null) {
                          // Set the selected image path based on the index
                          selectedImagePath = imagePaths[selectedIndex];

                          // Update Firestore with the selected image path
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.clientEmail)
                              .collection('user_workouts')
                              .doc(widget.workoutId)
                              .update({'icon': selectedImagePath});

                          // Trigger a rebuild of the widget
                          setState(() {});
                        }
                      },
                      child: Image.asset(
                        selectedImagePath,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.double_arrow_rounded,
                    color: Colors.greenAccent.shade400,
                    size: 30,
                  ),
                  onTap: () {
                    // go to workout details page (pass on workout id and workout name)
                    Get.to(
                      () => ClientWorkoutDetailsPage(
                        workoutId: widget.workoutId,
                        workoutName: widget.workoutName,
                        clientEmail: widget.clientEmail,
                        clientName: widget.clientName,
                      ),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 500),
                    );
                  },
                ),
              ),
            );
          } else {
            return const CircularProgressIndicator(
                color: Colors.transparent); // or another loading indicator
          }
        },
      ),
    );
  }
}
