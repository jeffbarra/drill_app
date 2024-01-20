import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

// Edit Workout Name
Future<void> editWorkout(
    context, String workoutId, String currentName, String pastWorkoutId) async {
  // Get auth instance for current user
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController newWorkoutNameController = TextEditingController();
  // shows currentName in field
  newWorkoutNameController.text = currentName;
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Edit Workout Name',
          textAlign: TextAlign.center,
          style: GoogleFonts.knewave(fontSize: 20, color: Colors.black),
        ),
        content: TextField(
          controller: newWorkoutNameController,
          autofocus: true,
          style: GoogleFonts.knewave(color: Colors.black),
          cursorColor: Colors.black,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: 'Enter new workout name',
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
                    // pop dialog with new value of edit field
                    Navigator.of(context).pop();
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
                  child: Text('Save',
                      style: GoogleFonts.knewave(color: Colors.black)),
                  onPressed: () async {
                    // Get the new name from the text field
                    String newWorkoutName = newWorkoutNameController.text;

                    // Update the workout name in Firestore
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_auth.currentUser!.email)
                          .collection('user_workouts')
                          .doc(workoutId)
                          .update({'workoutName': newWorkoutName});
                    } catch (e) {
                      print('Error updating workout name: $e');
                    }

                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_auth.currentUser!.email)
                          .collection('past_workouts')
                          .doc(pastWorkoutId)
                          .update({'workoutName': newWorkoutName});
                    } catch (e) {
                      print('Error updating past workout name: $e');
                    }

                    // pop dialog box
                    Navigator.of(context).pop();

                    // show snackbar
                    // ignore: use_build_context_synchronously
                    showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.success(
                          icon: Icon(Icons.check_circle_outline_rounded,
                              color: Colors.greenAccent.shade400),
                          backgroundColor: Colors.greenAccent.shade400,
                          borderRadius: BorderRadius.circular(20),
                          textStyle: GoogleFonts.knewave(
                              color: Colors.black, fontSize: 18),
                          message: "Workout Updated!",
                        ),
                        displayDuration: const Duration(milliseconds: 500));
                  },
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

// Delete Exercises & THEN delete Workout
Future<void> deleteExerciseAndWorkout(String workoutId) async {
  try {
    // performs multiple writes in single operation
    final batch = FirebaseFirestore.instance.batch();

    // Delete all documents within the "exercises" collection
    final exercisesQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('user_workouts')
        .doc(workoutId)
        .collection('exercises');
    // create exerciseDocs -> await exercisesQuery -> batch delete docs
    final exerciseDocs = await exercisesQuery.get();
    for (final doc in exerciseDocs.docs) {
      batch.delete(doc.reference);
    }

    // Delete the workout document
    final workoutRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('user_workouts')
        .doc(workoutId);

    batch.delete(workoutRef);

    // Commit the batched write operation
    await batch.commit();
  } catch (e) {
    print('Error deleting exercise and workout: $e');
  }
}

// Delete Client Exercises & THEN delete Workout
Future<void> deleteClientExerciseAndWorkout(
    String workoutId, String clientEmail) async {
  try {
    // performs multiple writes in single operation
    final batch = FirebaseFirestore.instance.batch();

    // Delete all documents within the "exercises" collection
    final exercisesQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(clientEmail)
        .collection('user_workouts')
        .doc(workoutId)
        .collection('exercises');
    // create exerciseDocs -> await exercisesQuery -> batch delete docs
    final exerciseDocs = await exercisesQuery.get();
    for (final doc in exerciseDocs.docs) {
      batch.delete(doc.reference);
    }

    // Delete the workout document
    final workoutRef = FirebaseFirestore.instance
        .collection('users')
        .doc(clientEmail)
        .collection('user_workouts')
        .doc(workoutId);

    batch.delete(workoutRef);

    // Commit the batched write operation
    await batch.commit();
  } catch (e) {
    print('Error deleting exercise and workout: $e');
  }
}

Future<void> editField(context, String field) async {
  // Get Current User
  final currentUser = FirebaseAuth.instance.currentUser!;

  // Reference to ALL Users called usersCollection
  final usersCollection = FirebaseFirestore.instance.collection('users');
  final pastWorkoutsCollection = FirebaseFirestore.instance.collection('users');

  // Create empty string value
  String newValue = "";

  bool savePressed = false; // Flag to check if Save button was pressed

  await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Edit $field',
        textAlign: TextAlign.center,
        style: GoogleFonts.knewave(fontSize: 20, color: Colors.black),
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height * 0.5, // Adjust as needed
          ),
          child: Container(
            width: double.maxFinite,
            child: TextField(
              maxLines: null, // Allows unlimited lines.
              autofocus: true,
              style: GoogleFonts.knewave(color: Colors.black),
              cursorColor: Colors.black,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
                hintText: 'Enter new $field',
                hintStyle: GoogleFonts.knewave(color: Colors.grey.shade500),
              ),
              onChanged: (value) {
                // Update the 'newValue' variable as the user types.
                newValue = value;
              },
            ),
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cancel Button
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade400,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel',
                    style: GoogleFonts.knewave(color: Colors.black)),
              ),
            ),
            const SizedBox(
              width: 10,
            ),

            // Save Button
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade400,
                ),
                onPressed: () {
                  savePressed = true; // Set flag when Save button is pressed
                  Navigator.of(context).pop(newValue);
                  showTopSnackBar(
                    Overlay.of(context),
                    CustomSnackBar.success(
                      icon: Icon(Icons.check_circle_outline_rounded,
                          color: Colors.greenAccent.shade700, size: 120),
                      backgroundColor: Colors.greenAccent.shade400,
                      borderRadius: BorderRadius.circular(20),
                      textStyle: GoogleFonts.knewave(
                          color: Colors.black, fontSize: 18),
                      message: "Profile Updated!",
                    ),
                    displayDuration: const Duration(milliseconds: 500),
                  );
                },
                child: Text('Save',
                    style: GoogleFonts.knewave(color: Colors.black)),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  // Update the field only if the Save button was pressed
  if (savePressed && newValue.isNotEmpty) {
    // Update the current user's document in Firestore
    await usersCollection.doc(currentUser.email).update({field: newValue});
    // You may want to update other collections, e.g., pastWorkoutsCollection
    // await pastWorkoutsCollection.doc(currentUser.email).update({field: newValue});
  }
}
