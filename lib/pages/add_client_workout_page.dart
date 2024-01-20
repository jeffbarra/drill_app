import 'package:drill_app/widgets/dialog_boxes/add_workout_dialog_box.dart';
import 'package:drill_app/widgets/dialog_boxes/delete_workout.dart';
import 'package:drill_app/widgets/tiles/client_workout_tile.dart';
import 'package:drill_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AddClientWorkoutPage extends StatefulWidget {
  final String clientName;
  final String clientEmail;
  const AddClientWorkoutPage(
      {Key? key, required this.clientName, required this.clientEmail})
      : super(key: key);

  @override
  State<AddClientWorkoutPage> createState() => _AddClientWorkoutPageState();
}

class _AddClientWorkoutPageState extends State<AddClientWorkoutPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController workoutNameController = TextEditingController();

  bool isLoading = true;
  QuerySnapshot? _clientWorkoutSnapshot;

  void _addClientWorkout(BuildContext context, User user) async {
    String workoutName = workoutNameController.text;
    if (workoutName.isNotEmpty) {
      Navigator.pop(context);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientEmail)
          .collection('user_workouts')
          .add({
        'workoutName': workoutName,
        'icon': 'lib/assets/images/weights.png',
        'timestamp': FieldValue.serverTimestamp(),
      });

      workoutNameController.clear();
    }
  }

  void _showAddClientWorkoutDialog(BuildContext context, User user) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AddWorkoutDialogBox(
          controller: workoutNameController,
          onPressed: () {
            _addClientWorkout(context, user);
            workoutNameController.text.isEmpty
                ? null
                : showTopSnackBar(
                    Overlay.of(context),
                    CustomSnackBar.success(
                      icon: Icon(Icons.check_circle_outline_rounded,
                          color: Colors.greenAccent.shade700, size: 120),
                      backgroundColor: Colors.greenAccent.shade400,
                      borderRadius: BorderRadius.circular(20),
                      textStyle: GoogleFonts.knewave(
                          color: Colors.black, fontSize: 18),
                      message: "${workoutNameController.text} Added!",
                    ),
                    displayDuration: const Duration(milliseconds: 500));
          },
        );
      },
    );
  }

  Future<String?> editClientWorkout(BuildContext context, String workoutId,
      String workoutName, String pastWorkoutId) async {
    return showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Edit Workout Name',
            textAlign: TextAlign.center,
            style: GoogleFonts.knewave(fontSize: 20, color: Colors.black),
          ),
          content: TextField(
            controller: workoutNameController,
            autofocus: true,
            style: GoogleFonts.knewave(color: Colors.black),
            cursorColor: Colors.black,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              fillColor: Colors.white,
              filled: true,
              hintText: 'Workout Name',
              hintStyle: GoogleFonts.knewave(color: Colors.grey.shade500),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0),
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade400,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      workoutNameController.clear();
                    },
                    child: Text('Cancel',
                        style: GoogleFonts.knewave(color: Colors.black)),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade400,
                    ),
                    onPressed: () {
                      String newWorkoutName = workoutNameController.text.trim();
                      Navigator.pop(context, newWorkoutName);
                      workoutNameController.clear();
                      showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.success(
                            icon: Icon(Icons.check_circle_outline_rounded,
                                color: Colors.greenAccent.shade700, size: 120),
                            backgroundColor: Colors.greenAccent.shade400,
                            borderRadius: BorderRadius.circular(20),
                            textStyle: GoogleFonts.knewave(
                                color: Colors.black, fontSize: 18),
                            message: "Workout Updated!",
                          ),
                          displayDuration: const Duration(milliseconds: 500));
                    },
                    child: Text('Save',
                        style: GoogleFonts.knewave(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> updateClientWorkoutName(
      String workoutId, String newWorkoutName) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.clientEmail)
        .collection('user_workouts')
        .doc(workoutId)
        .update({'workoutName': newWorkoutName});
  }

  Future<void> updatePastClientWorkoutName(
      String workoutId, String newWorkoutName) async {
    final userSnapshots = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.clientEmail)
        .collection('past_workouts')
        .where('workoutId', isEqualTo: workoutId)
        .get();

    for (final doc in userSnapshots.docs) {
      await doc.reference.update({'workoutName': newWorkoutName});
    }
  }

  Future<void> _fetchLatestClientWorkouts() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientEmail)
          .collection('user_workouts')
          .orderBy('timestamp', descending: false)
          .get();

      // Simulate a 1-second delay
      await Future.delayed(Duration(seconds: 1));

      setState(() {
        _clientWorkoutSnapshot = querySnapshot;
      });
    } catch (e) {
      print("Error fetching latest data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade900,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            '${widget.clientName}\'s Workouts',
            style: GoogleFonts.knewave(
              fontSize: 20,
              color: Colors.greenAccent.shade400,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 10),
            child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'To edit or delete a workout, slide the workout tile to the left',
                            style: GoogleFonts.knewave(),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'To change the workout icon, tap it and select the desired icon',
                            style: GoogleFonts.knewave(),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.info_outline_rounded,
                    size: 30, color: Colors.grey.shade600)),
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: Colors.greenAccent.shade400,
          onPressed: () async {
            User? user = _auth.currentUser;
            if (user != null) {
              _showAddClientWorkoutDialog(context, user);
            } else {
              // Handle user not signed in
            }
          },
          child: const Icon(Icons.add_rounded, size: 30, color: Colors.black),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _auth.currentUser == null
            ? const Stream.empty()
            : FirebaseFirestore.instance
                .collection('users')
                .doc(widget.clientEmail)
                .collection('user_workouts')
                .orderBy('timestamp', descending: false)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.grey.shade900,
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            isLoading = false;
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Add some workouts 💪',
                style: GoogleFonts.knewave(fontSize: 18, color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final workoutData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final workoutId = snapshot.data!.docs[index].id;
              final workoutName = workoutData['workoutName'] as String;
              final pastWorkoutId = snapshot.data!.docs[index].id;

              return ClientWorkoutTile(
                onPressed: (p0) {
                  showDialog(
                    context: context,
                    builder: ((context) => DeleteWorkoutDialogBox(
                          onYesPressed: () {
                            deleteClientExerciseAndWorkout(
                                workoutId, widget.clientEmail);
                            showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.success(
                                  icon: Icon(Icons.check_circle_outline_rounded,
                                      color: Colors.greenAccent.shade700,
                                      size: 120),
                                  backgroundColor: Colors.greenAccent.shade400,
                                  borderRadius: BorderRadius.circular(20),
                                  textStyle: GoogleFonts.knewave(
                                      color: Colors.black, fontSize: 18),
                                  message: "$workoutName Deleted!",
                                ),
                                displayDuration:
                                    const Duration(milliseconds: 500));
                            Navigator.pop(context);
                          },
                          onNoPressed: () {
                            Navigator.pop(context);
                          },
                        )),
                  );
                },
                onPressedTwo: (p0) async {
                  final newWorkoutName = await editClientWorkout(
                    context,
                    workoutId,
                    workoutName,
                    pastWorkoutId,
                  );

                  if (newWorkoutName != null && newWorkoutName.isNotEmpty) {
                    await updateClientWorkoutName(workoutId, newWorkoutName);
                    await updatePastClientWorkoutName(
                        workoutId, newWorkoutName);
                  }
                },
                workoutName: workoutName,
                workoutId: workoutId,
                clientEmail: widget.clientEmail,
                clientName: widget.clientName,
              );
            },
          );
        },
      ),
    );
  }
}
