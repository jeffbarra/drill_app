import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drill_app/pages/choose_past_workout_page.dart';
import 'package:drill_app/widgets/dialog_boxes/add_exercise_dialog_box.dart';
import 'package:drill_app/widgets/dialog_boxes/delete_exercise.dart';
import 'package:drill_app/widgets/tiles/exercise_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class WorkoutDetailsPage extends StatefulWidget {
  final String workoutId;
  final String workoutName;

  WorkoutDetailsPage({required this.workoutId, required this.workoutName});

  @override
  State<WorkoutDetailsPage> createState() => _WorkoutDetailsPageState();
}

class _WorkoutDetailsPageState extends State<WorkoutDetailsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController exerciseNameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController distanceController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  Timestamp? lastFetchTimestamp;
  bool _dataLoaded = false; // Track data loading state

  void _showExerciseDialog(
    BuildContext context,
    User user,
    String workoutId,
    String exerciseName,
  ) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AddExerciseDialogBox(
          exerciseNameController: exerciseNameController,
          repsController: repsController,
          weightController: weightController,
          setsController: setsController,
          distanceController: distanceController,
          timeController: timeController,
          onPressed: () {
            if (exerciseNameController.text.isNotEmpty) {
              _addExercise(
                context,
                user,
                workoutId,
                exerciseNameController.text, // Pass exercise name
                // Pass other parameters like weight, reps, sets, distance, and time here
                weightController.text,
                repsController.text,
                setsController.text,
                distanceController.text,
                timeController.text,
              );

              showTopSnackBar(
                Overlay.of(context),
                CustomSnackBar.success(
                  icon: Icon(Icons.check_circle_outline_rounded,
                      color: Colors.greenAccent.shade700, size: 120),
                  backgroundColor: Colors.greenAccent.shade400,
                  borderRadius: BorderRadius.circular(20),
                  textStyle:
                      GoogleFonts.knewave(color: Colors.black, fontSize: 18),
                  message: "${exerciseNameController.text} Added!",
                ),
                displayDuration: const Duration(milliseconds: 500),
              );
            } else {
              (e) {
                print("Error adding exercise: $e");
              };
            }
          },
        );
      },
    );
  }

  void _addExercise(
    BuildContext context,
    User user,
    String workoutId,
    String exerciseName,
    String weight,
    String reps,
    String sets,
    String distance,
    String time,
  ) async {
    if (exerciseName.isNotEmpty) {
      Navigator.pop(context);
      final exerciseData = {
        'exerciseName': exerciseName,
        'timestamp': FieldValue.serverTimestamp(),
        'isExerciseComplete': false,
      };

      if (weight.isNotEmpty) {
        exerciseData['weight'] = weight;
      }

      if (reps.isNotEmpty) {
        exerciseData['reps'] = reps;
      }

      if (sets.isNotEmpty) {
        exerciseData['sets'] = sets;
      }

      if (distance.isNotEmpty) {
        exerciseData['distance'] = distance;
      }

      if (time.isNotEmpty) {
        exerciseData['time'] = time;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .collection('user_workouts')
          .doc(workoutId)
          .collection('exercises')
          .add(exerciseData);
    }

    exerciseNameController.clear();
    weightController.clear();
    repsController.clear();
    setsController.clear();
    distanceController.clear();
    timeController.clear();
  }

  Future<void> deleteExercise(String exerciseId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('user_workouts')
          .doc(widget.workoutId)
          .collection('exercises')
          .doc(exerciseId)
          .delete();
    } catch (e) {
      print('Error deleting exercise: $e');
    }
  }

  Future<void> _fetchLatestExercises() async {
    try {
      // Simulate a 2-second delay
      await Future.delayed(const Duration(seconds: 1));

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.email)
          .collection('user_workouts')
          .doc(widget.workoutId)
          .collection('exercises')
          .where('timestamp', isGreaterThan: lastFetchTimestamp)
          .orderBy('timestamp', descending: false)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        lastFetchTimestamp = querySnapshot.docs.last.get('timestamp');
      }
    } catch (e) {
      print("Error fetching latest exercise data: $e");
    }
  }

  void _showWorkoutBottomSheet(BuildContext context, User user) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: Container(
            height: MediaQuery.of(context).copyWith().size.height * 0.38,
            color: Colors.grey.shade800,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Add Exercise',
                        style: GoogleFonts.knewave(
                          color: Colors.greenAccent.shade400,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 20,
                    bottom: 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      border: Border.all(
                        color: Colors.grey.shade600,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      title: Text(
                        "New Exercise",
                        style: GoogleFonts.knewave(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showExerciseDialog(context, user, widget.workoutId,
                            exerciseNameController.text);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    bottom: 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      border: Border.all(
                        color: Colors.grey.shade600,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      title: Text(
                        "Previous Exercise",
                        style: GoogleFonts.knewave(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(
                            () => ChoosePastWorkoutPage(
                                  workoutId: widget.workoutId,
                                ),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 500));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
          child: Text(widget.workoutName,
              style: GoogleFonts.knewave(
                  fontSize: 20, color: Colors.greenAccent.shade400)),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Slide the exercise tile to the left to complete it or delete it',
                            style: GoogleFonts.knewave(),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            'To edit any part of an exercise, tap the box within the exercise tile that you would like to edit',
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
          onPressed: () {
            _showWorkoutBottomSheet(context, _auth.currentUser!);
          },
          child: const Icon(Icons.add_rounded, size: 30, color: Colors.black),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .collection('user_workouts')
            .doc(widget.workoutId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.grey.shade900,
              ),
            );
          }

          if (!snapshot.data!.exists) {
            return buildExerciseList([]); // Pass an empty list
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.email)
                .collection('user_workouts')
                .doc(widget.workoutId)
                .collection('exercises')
                .orderBy('timestamp', descending: false)
                .snapshots(),
            builder: (context, exercisesSnapshot) {
              if (exercisesSnapshot.hasError) {
                return Text('Error: ${exercisesSnapshot.error}');
              }

              if (!exercisesSnapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.grey.shade900,
                  ),
                );
              }

              // Extract exercises data
              final exerciseDocs = exercisesSnapshot.data!.docs;
              _dataLoaded = true; // Data is loaded
              return buildExerciseList(exerciseDocs);
            },
          );
        },
      ),
    );
  }

  Widget buildExerciseList(List<DocumentSnapshot> exercises) {
    if (exercises.isEmpty) {
      if (_dataLoaded) {
        return Center(
          child: Text(
            'Add some exercises 💪',
            style: GoogleFonts.knewave(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        );
      } else {
        return Center(
          child: CircularProgressIndicator(
            color: Colors.grey.shade900,
          ),
        );
      }
    } else {
      return ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exerciseDocument = exercises[index];
          final exerciseData = exerciseDocument.data() as Map<String, dynamic>?;

          if (exerciseData != null) {
            final exerciseId = exerciseDocument.id;
            final exerciseName = exerciseData['exerciseName'] as String? ?? '';
            final weight = exerciseData['weight'] as String? ?? '';
            final reps = exerciseData['reps'] as String? ?? '';
            final sets = exerciseData['sets'] as String? ?? '';
            final distance = exerciseData['distance'] as String? ?? '';
            final time = exerciseData['time'] as String? ?? '';

            return ExerciseTile(
              workoutId: widget.workoutId,
              workoutName: widget.workoutName,
              exerciseName: exerciseName,
              weight: weight,
              reps: reps,
              sets: sets,
              distance: distance,
              time: time,
              exerciseId: exerciseId,
              onPressed: (p0) {
                showDialog(
                  context: context,
                  builder: (context) => DeleteExerciseDialogBox(
                    onYesPressed: () {
                      deleteExercise(exerciseId);
                      Navigator.pop(context);
                      showTopSnackBar(
                          Overlay.of(context),
                          CustomSnackBar.success(
                            icon: Icon(Icons.check_circle_outline_rounded,
                                color: Colors.greenAccent.shade700, size: 120),
                            backgroundColor: Colors.greenAccent.shade400,
                            borderRadius: BorderRadius.circular(20),
                            textStyle: GoogleFonts.knewave(
                                color: Colors.black, fontSize: 18),
                            message: "$exerciseName Deleted!",
                          ),
                          displayDuration: const Duration(milliseconds: 500));
                    },
                    onNoPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            );
          } else {
            return const Text('Error: Exercise data is null');
          }
        },
      );
    }
  }
}
