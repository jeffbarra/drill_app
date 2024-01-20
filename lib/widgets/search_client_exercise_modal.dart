import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drill_app/widgets/tiles/past_exercise_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SearchClientPastExerciseBottomSheet extends StatefulWidget {
  final String workoutId;
  final String clientEmail;

  const SearchClientPastExerciseBottomSheet(
      {Key? key, required this.workoutId, required this.clientEmail})
      : super(key: key);

  @override
  State<SearchClientPastExerciseBottomSheet> createState() =>
      _SearchClientPastExerciseBottomSheetState();
}

class _SearchClientPastExerciseBottomSheetState
    extends State<SearchClientPastExerciseBottomSheet> {
  final TextEditingController searchQueryController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  List<DocumentSnapshot>? searchResults;
  bool isSearching = false;

  Future<void> performSearch() async {
    final query = searchQueryController.text;

    if (query.isNotEmpty) {
      setState(() {
        isSearching = true;
      });

      final RegExp regExp = RegExp(query, caseSensitive: false);

      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientEmail)
          .collection('past_workouts')
          .where('exerciseName', isNotEqualTo: null)
          .get();

      final List<DocumentSnapshot> filteredResults = querySnapshot.docs
          .where((doc) =>
              regExp.hasMatch(doc['exerciseName'].toString().toLowerCase()))
          .toList();

      setState(() {
        searchResults = filteredResults;
        isSearching = false;
      });
    } else {
      setState(() {
        searchResults = null;
      });
    }
  }

  Future<void> addExerciseToUserWorkouts({
    required String workoutId,
    required String exerciseId,
    required String workoutName,
    required String exerciseName,
    required String weight,
    required String reps,
    required String sets,
    required String distance,
    required String time,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Handle the case where the user is not logged in.
        return;
      }

      final userWorkoutsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientEmail)
          .collection('user_workouts')
          .doc(workoutId)
          .collection('exercises')
          .doc(); // Provide the correct document path

      final data = {
        'workoutName': workoutName,
        'exerciseName': exerciseName,
        'weight': weight,
        'reps': reps,
        'sets': sets,
        'distance': distance,
        'time': time,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await userWorkoutsRef.set(data);

      // Show the snackbar after adding the exercise
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.success(
          icon: Icon(Icons.check_circle_outline_rounded,
              color: Colors.greenAccent.shade700, size: 120),
          backgroundColor: Colors.greenAccent.shade400,
          borderRadius: BorderRadius.circular(20),
          textStyle: GoogleFonts.knewave(color: Colors.black, fontSize: 18),
          message: "$exerciseName Added!",
        ),
        displayDuration: const Duration(milliseconds: 500),
      );

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (error) {
      // Handle any potential errors
      print('Error adding exercise: $error');
      // You can also show an error snackbar here if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Search Exercises',
                style: GoogleFonts.knewave(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
          child: TextField(
            autofocus: true,
            controller: searchQueryController,
            cursorColor: Colors.grey,
            style: GoogleFonts.knewave(color: Colors.white),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                borderRadius: BorderRadius.circular(20),
              ),
              hintText: 'Search',
              hintStyle: GoogleFonts.knewave(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.shade700,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              // Add the clear (x) icon at the end of the field
              suffixIcon: IconButton(
                onPressed: () {
                  // Clear the search field
                  searchQueryController.clear();
                },
                icon: const Icon(Icons.clear, color: Colors.grey),
              ),
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent.shade400,
          ),
          onPressed: isSearching ? null : performSearch,
          child: Text(
            'Search',
            style: GoogleFonts.knewave(color: Colors.black),
          ),
        ),
        if (isSearching)
          CircularProgressIndicator(
            color: Colors.greenAccent.shade400,
          ),
        if (searchResults != null && searchResults!.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No exercises found',
              style: GoogleFonts.knewave(color: Colors.white),
            ),
          ),
        if (searchResults != null && searchResults!.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: searchResults!.length,
              itemBuilder: (context, index) {
                final result = searchResults![index];
                final workoutData = result.data() as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
                  child: Slidable(
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (BuildContext context) {
                            addExerciseToUserWorkouts(
                              workoutId: widget.workoutId,
                              workoutName: workoutData['workoutName'],
                              exerciseName: workoutData['exerciseName'],
                              weight: workoutData['weight'],
                              reps: workoutData['reps'],
                              sets: workoutData['sets'],
                              distance: workoutData['distance'],
                              time: workoutData['time'],
                              exerciseId: '',
                            );
                          },
                          icon: Icons.add_circle_rounded,
                          foregroundColor: Colors.greenAccent.shade400,
                          backgroundColor: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ],
                    ),
                    child: PastExerciseTile(
                        workoutName: workoutData['workoutName'],
                        exerciseName: workoutData['exerciseName'],
                        weight: workoutData['weight'],
                        reps: workoutData['reps'],
                        sets: workoutData['sets'],
                        distance: workoutData['distance'],
                        time: workoutData['time'],
                        border:
                            Border.all(color: Colors.grey.shade600, width: 2.0),
                        color: Colors.grey.shade700),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
