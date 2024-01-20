import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drill_app/widgets/dialog_boxes/complete_exercise.dart';
import 'package:drill_app/widgets/text_fields/main_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ExerciseTile extends StatefulWidget {
  final String workoutId;
  final String workoutName;
  String exerciseName;
  String weight;
  String reps;
  String sets;
  String distance;
  String time;
  final String exerciseId;
  final void Function(BuildContext)? onPressed;

  ExerciseTile({
    Key? key,
    required this.workoutId,
    required this.workoutName,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.sets,
    required this.distance,
    required this.time,
    required this.exerciseId,
    required this.onPressed,
  });

  @override
  State<ExerciseTile> createState() => _ExerciseTileState();
}

class _ExerciseTileState extends State<ExerciseTile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isExerciseComplete = false;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    getUserExerciseStatus();
  }

  Future<void> getUserExerciseStatus() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.email)
          .collection('user_workouts')
          .doc(widget.workoutId)
          .collection('exercises')
          .doc(widget.exerciseId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final isComplete = data['isExerciseComplete'] ?? false;
        setState(() {
          isExerciseComplete = isComplete;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> toggleExerciseCompletion(String exerciseId) async {
    try {
      final isComplete = !isExerciseComplete;
      final pastWorkoutRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.email)
          .collection('past_workouts')
          .doc(exerciseId);

      if (isComplete) {
        await pastWorkoutRef.set({
          'workoutId': widget.workoutId,
          'workoutName': widget.workoutName,
          'exerciseId': widget.exerciseId,
          'exerciseName': widget.exerciseName,
          'weight': widget.weight,
          'reps': widget.reps,
          'sets': widget.sets,
          'distance': widget.distance,
          'time': widget.time,
          'timestamp': Timestamp.now(),
        });
      } else {
        await pastWorkoutRef.delete();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.email)
          .collection('user_workouts')
          .doc(widget.workoutId)
          .collection('exercises')
          .doc(exerciseId)
          .update({'isExerciseComplete': isComplete});

      setState(() {
        isExerciseComplete = isComplete;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _showCompletionDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CompleteExerciseDialogBox(onYesPressed: () {
          Navigator.of(context).pop();
          _handleCompletionChoice(true);
          deleteExercise(widget.exerciseId);
        }, onNoPressed: () {
          Navigator.pop(context);
        });
      },
    );
  }

  Future<void> _handleCompletionChoice(bool completed) async {
    if (completed) {
      showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.success(
            icon: Icon(Icons.check_circle_outline_rounded,
                color: Colors.greenAccent.shade700, size: 120),
            backgroundColor: Colors.greenAccent.shade400,
            borderRadius: BorderRadius.circular(20),
            textStyle: GoogleFonts.knewave(color: Colors.black, fontSize: 18),
            message: "${widget.exerciseName} Completed!",
          ),
          displayDuration: const Duration(milliseconds: 500));
    }
    toggleExerciseCompletion(widget.exerciseId);
  }

  Future<void> deleteExercise(String exerciseId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.email)
          .collection('user_workouts')
          .doc(widget.workoutId)
          .collection('exercises')
          .doc(exerciseId)
          .delete();
    } catch (e) {
      print('Error deleting exercise: $e');
    }
  }

  void _editExerciseNameDialog() {
    TextEditingController exerciseNameController =
        TextEditingController(text: widget.exerciseName);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Exercise Name',
            style: GoogleFonts.knewave(),
            textAlign: TextAlign.center,
          ),
          content: MainTextField(
            enabled: true,
            controller: exerciseNameController,
            inputType: TextInputType.text,
            textStyle: GoogleFonts.knewave(color: Colors.black),
            obscureText: false,
            hintText: 'Enter name',
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade400),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.knewave(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade400),
                    child: Text('Save',
                        style: GoogleFonts.knewave(color: Colors.black)),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_auth.currentUser!.email)
                          .collection('user_workouts')
                          .doc(widget.workoutId)
                          .collection('exercises')
                          .doc(widget.exerciseId)
                          .update(
                              {'exerciseName': exerciseNameController.text});

                      setState(() {
                        widget.exerciseName = exerciseNameController.text;
                      });

                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.success(
                          icon: Icon(Icons.check_circle_outline_rounded,
                              color: Colors.greenAccent.shade700, size: 120),
                          backgroundColor: Colors.greenAccent.shade400,
                          borderRadius: BorderRadius.circular(20),
                          textStyle: GoogleFonts.knewave(
                              color: Colors.black, fontSize: 18),
                          message: "Exercise Updated!",
                        ),
                        displayDuration: const Duration(milliseconds: 500),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _editWeightDialog() {
    TextEditingController weightController =
        TextEditingController(text: widget.weight);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Weight',
            style: GoogleFonts.knewave(),
            textAlign: TextAlign.center,
          ),
          content: MainTextField(
            enabled: true,
            controller: weightController,
            inputType: TextInputType.number,
            textStyle: GoogleFonts.knewave(color: Colors.black),
            obscureText: false,
            hintText: 'Enter weight',
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade400),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.knewave(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade400),
                    child: Text('Save',
                        style: GoogleFonts.knewave(color: Colors.black)),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_auth.currentUser!.email)
                          .collection('user_workouts')
                          .doc(widget.workoutId)
                          .collection('exercises')
                          .doc(widget.exerciseId)
                          .update({'weight': weightController.text});

                      setState(() {
                        widget.weight = weightController.text;
                      });

                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.success(
                          icon: Icon(Icons.check_circle_outline_rounded,
                              color: Colors.greenAccent.shade700, size: 120),
                          backgroundColor: Colors.greenAccent.shade400,
                          borderRadius: BorderRadius.circular(20),
                          textStyle: GoogleFonts.knewave(
                              color: Colors.black, fontSize: 18),
                          message: "Exercise Updated!",
                        ),
                        displayDuration: const Duration(milliseconds: 500),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _editRepsDialog() {
    TextEditingController repsController =
        TextEditingController(text: widget.reps);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Reps',
            style: GoogleFonts.knewave(),
            textAlign: TextAlign.center,
          ),
          content: MainTextField(
            enabled: true,
            controller: repsController,
            inputType: TextInputType.number,
            textStyle: GoogleFonts.knewave(color: Colors.black),
            obscureText: false,
            hintText: 'Enter reps',
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade400),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.knewave(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade400),
                    child: Text('Save',
                        style: GoogleFonts.knewave(color: Colors.black)),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_auth.currentUser!.email)
                          .collection('user_workouts')
                          .doc(widget.workoutId)
                          .collection('exercises')
                          .doc(widget.exerciseId)
                          .update({'reps': repsController.text});

                      setState(() {
                        widget.reps = repsController.text;
                      });

                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.success(
                          icon: Icon(Icons.check_circle_outline_rounded,
                              color: Colors.greenAccent.shade700, size: 120),
                          backgroundColor: Colors.greenAccent.shade400,
                          borderRadius: BorderRadius.circular(20),
                          textStyle: GoogleFonts.knewave(
                              color: Colors.black, fontSize: 18),
                          message: "Exercise Updated!",
                        ),
                        displayDuration: const Duration(milliseconds: 500),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _editSetsDialog() {
    TextEditingController setsController =
        TextEditingController(text: widget.sets);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Sets',
            style: GoogleFonts.knewave(),
            textAlign: TextAlign.center,
          ),
          content: MainTextField(
            enabled: true,
            controller: setsController,
            inputType: TextInputType.number,
            textStyle: GoogleFonts.knewave(color: Colors.black),
            obscureText: false,
            hintText: 'Enter sets',
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade400),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.knewave(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade400),
                    child: Text('Save',
                        style: GoogleFonts.knewave(color: Colors.black)),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_auth.currentUser!.email)
                          .collection('user_workouts')
                          .doc(widget.workoutId)
                          .collection('exercises')
                          .doc(widget.exerciseId)
                          .update({'sets': setsController.text});

                      setState(() {
                        widget.sets = setsController.text;
                      });

                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.success(
                          icon: Icon(Icons.check_circle_outline_rounded,
                              color: Colors.greenAccent.shade700, size: 120),
                          backgroundColor: Colors.greenAccent.shade400,
                          borderRadius: BorderRadius.circular(20),
                          textStyle: GoogleFonts.knewave(
                              color: Colors.black, fontSize: 18),
                          message: "Exercise Updated!",
                        ),
                        displayDuration: const Duration(milliseconds: 500),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _editDistanceDialog() {
    TextEditingController distanceController =
        TextEditingController(text: widget.distance);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Distance',
            style: GoogleFonts.knewave(),
            textAlign: TextAlign.center,
          ),
          content: MainTextField(
            enabled: true,
            controller: distanceController,
            inputType: TextInputType.text,
            textStyle: GoogleFonts.knewave(color: Colors.black),
            obscureText: false,
            hintText: 'Enter distance',
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade400),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.knewave(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade400),
                    child: Text('Save',
                        style: GoogleFonts.knewave(color: Colors.black)),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_auth.currentUser!.email)
                          .collection('user_workouts')
                          .doc(widget.workoutId)
                          .collection('exercises')
                          .doc(widget.exerciseId)
                          .update({'distance': distanceController.text});

                      setState(() {
                        widget.distance = distanceController.text;
                      });

                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.success(
                          icon: Icon(Icons.check_circle_outline_rounded,
                              color: Colors.greenAccent.shade700, size: 120),
                          backgroundColor: Colors.greenAccent.shade400,
                          borderRadius: BorderRadius.circular(20),
                          textStyle: GoogleFonts.knewave(
                              color: Colors.black, fontSize: 18),
                          message: "Exercise Updated!",
                        ),
                        displayDuration: const Duration(milliseconds: 500),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _editTimeDialog() {
    TextEditingController timeController =
        TextEditingController(text: widget.time);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Time',
            style: GoogleFonts.knewave(),
            textAlign: TextAlign.center,
          ),
          content: MainTextField(
            enabled: true,
            controller: timeController,
            inputType: TextInputType.text,
            textStyle: GoogleFonts.knewave(color: Colors.black),
            obscureText: false,
            hintText: 'Enter time',
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade400),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.knewave(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade400),
                    child: Text('Save',
                        style: GoogleFonts.knewave(color: Colors.black)),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_auth.currentUser!.email)
                          .collection('user_workouts')
                          .doc(widget.workoutId)
                          .collection('exercises')
                          .doc(widget.exerciseId)
                          .update({'time': timeController.text});

                      setState(() {
                        widget.time = timeController.text;
                      });

                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.success(
                          icon: Icon(Icons.check_circle_outline_rounded,
                              color: Colors.greenAccent.shade700, size: 120),
                          backgroundColor: Colors.greenAccent.shade400,
                          borderRadius: BorderRadius.circular(20),
                          textStyle: GoogleFonts.knewave(
                              color: Colors.black, fontSize: 18),
                          message: "Exercise Updated!",
                        ),
                        displayDuration: const Duration(milliseconds: 500),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if the values are empty
    String weightValue =
        widget.weight.isEmpty ? 'No Weight' : '${widget.weight} lbs';
    String repsValue = widget.reps.isEmpty ? 'No Reps' : '${widget.reps} Reps';
    String setsValue = widget.sets.isEmpty ? 'No Sets' : '${widget.sets} Sets';
    String distanceValue =
        widget.distance.isEmpty ? 'Stationary' : widget.distance;
    String timeValue = widget.time.isEmpty ? 'No Time Limit' : widget.time;

    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40, top: 20),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (p0) {
                if (isExerciseComplete) {
                  toggleExerciseCompletion(widget.exerciseId);
                  setState(() {
                    isExerciseComplete = false;
                  });
                } else {
                  _showCompletionDialog();
                }
              },
              icon: Icons.check_rounded,
              foregroundColor: Colors.greenAccent.shade400,
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
          padding:
              const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
          decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade700, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Shadow color
                  spreadRadius: 2, // How much the shadow should spread
                  blurRadius: 5, // How blurry the shadow should be
                  offset: const Offset(3, 3), // Changes position of shadow
                ),
              ]),
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _editExerciseNameDialog();
                      },
                      child: Text(
                        widget.exerciseName,
                        style: GoogleFonts.knewave(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _editWeightDialog();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.red.shade400, width: 2.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.2), // Shadow color
                                  spreadRadius:
                                      2, // How much the shadow should spread
                                  blurRadius:
                                      5, // How blurry the shadow should be
                                  offset: const Offset(
                                      3, 3), // Changes position of shadow
                                ),
                              ],
                            ),
                            child: Text(
                              weightValue, // Use the modified value here
                              style: GoogleFonts.knewave(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            _editRepsDialog();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  Colors.greenAccent.shade400.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.greenAccent.shade400,
                                  width: 2.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.2), // Shadow color
                                  spreadRadius:
                                      2, // How much the shadow should spread
                                  blurRadius:
                                      5, // How blurry the shadow should be
                                  offset: const Offset(
                                      3, 3), // Changes position of shadow
                                ),
                              ],
                            ),
                            child: Text(
                              repsValue, // Use the modified value here
                              style: GoogleFonts.knewave(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            _editSetsDialog();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade400.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.blue.shade400, width: 2.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.2), // Shadow color
                                  spreadRadius:
                                      2, // How much the shadow should spread
                                  blurRadius:
                                      5, // How blurry the shadow should be
                                  offset: const Offset(
                                      3, 3), // Changes position of shadow
                                ),
                              ],
                            ),
                            child: Text(
                              setsValue, // Use the modified value here
                              style: GoogleFonts.knewave(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _editDistanceDialog();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade400.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.orange.shade400, width: 2.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.2), // Shadow color
                                  spreadRadius:
                                      2, // How much the shadow should spread
                                  blurRadius:
                                      5, // How blurry the shadow should be
                                  offset: const Offset(
                                      3, 3), // Changes position of shadow
                                ),
                              ],
                            ),
                            child: Text(
                              distanceValue, // Use the modified value here
                              style: GoogleFonts.knewave(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            _editTimeDialog();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.yellow.shade400.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.yellow.shade400, width: 2.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.2), // Shadow color
                                  spreadRadius:
                                      2, // How much the shadow should spread
                                  blurRadius:
                                      5, // How blurry the shadow should be
                                  offset: const Offset(
                                      3, 3), // Changes position of shadow
                                ),
                              ],
                            ),
                            child: Text(
                              timeValue, // Use the modified value here
                              style: GoogleFonts.knewave(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
