import 'package:drill_app/widgets/search_exercise_modal.dart';
import 'package:drill_app/widgets/tiles/past_exercise_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ChoosePastWorkoutPage extends StatefulWidget {
  final String workoutId;

  const ChoosePastWorkoutPage({
    Key? key,
    required this.workoutId,
  });

  @override
  State<ChoosePastWorkoutPage> createState() => _ChoosePastWorkoutPageState();
}

class _ChoosePastWorkoutPageState extends State<ChoosePastWorkoutPage> {
  List<Map<String, dynamic>> _groupedWorkouts = [];
  DateTime? _selectedDay;
  String currentMonthYear = DateFormat('yyyy').format(DateTime.now());

  bool _isLoading = true; // Flag to track if the page is loading

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        if (mounted) {
          // Check if the widget is still mounted to avoid calling setState on a disposed widget
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
    _fetchPastWorkouts();
  }

  // Fetch Past Workouts
  void _fetchPastWorkouts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('past_workouts')
        .orderBy('timestamp', descending: true)
        .get();

    final pastWorkouts = snapshot.docs;
    _groupedWorkouts = groupWorkoutsByDay(pastWorkouts);

    _groupedWorkouts.sort((a, b) {
      final DateTime timeA =
          (a['workouts'][0].data()['timestamp'] as Timestamp).toDate();
      final DateTime timeB =
          (b['workouts'][0].data()['timestamp'] as Timestamp).toDate();
      return timeB.compareTo(timeA);
    });

    _groupedWorkouts = _groupedWorkouts.reversed.toList();

    if (_groupedWorkouts.isNotEmpty) {
      _selectedDay = (_groupedWorkouts.last['workouts'][0].data()['timestamp']
              as Timestamp)
          .toDate();
    }
  }

  void _updateCurrentMonthYear() {
    if (_selectedDay != null && _groupedWorkouts.isNotEmpty) {
      final selectedGroup = _groupedWorkouts.firstWhere(
        (group) => group['day'] == _selectedDay,
        orElse: () => {'day': '', 'workouts': []},
      );

      if (selectedGroup['workouts'].isNotEmpty) {
        final timestamp =
            (selectedGroup['workouts'][0].data()['timestamp'] as Timestamp?)
                ?.toDate();

        if (timestamp != null) {
          final newMonthYear = DateFormat('yyyy').format(timestamp);
          setState(() {
            currentMonthYear = newMonthYear;
          });
        }
      }
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
          .doc(user.email)
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
          displayDuration: const Duration(milliseconds: 500));
    } catch (e) {
      print('Error adding exercise to user_workouts collection: $e');
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
            'Past Exercises',
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
                      content: Text(
                        'Slide the exercise tile to the left to add it to your workout',
                        style: GoogleFonts.knewave(),
                        textAlign: TextAlign.center,
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
        padding: const EdgeInsets.only(right: 10),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: Colors.greenAccent.shade400,
          onPressed: () {
            showModalBottomSheet(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              backgroundColor: Colors.grey.shade800,
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return FractionallySizedBox(
                  heightFactor: 0.9, // Set the height factor to 80%
                  child: SearchExerciseBottomSheet(
                    workoutId: widget.workoutId,
                  ),
                );
              },
            );
          },
          child: const Icon(Icons.search_rounded, color: Colors.black),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Stack(alignment: Alignment.center, children: <Widget>[
                Icon(Icons.fitness_center_rounded,
                    color: Colors.greenAccent.shade400, size: 30),
                Container(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                        color: Colors.greenAccent.shade400))
              ]),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHorizontalScrollableTiles(),
                Expanded(child: _buildPastExercisesContainer()),
              ],
            ),
    );
  }

  // Build Horizontal Scrollable Tiles
  Widget _buildHorizontalScrollableTiles() {
    if (_groupedWorkouts.isEmpty) {
      return Container(); // If no workouts are available, display an empty container
    }

    // Find the index of the most recent date
    int mostRecentDateIndex = -1;
    if (_selectedDay != null) {
      for (int i = 0; i < _groupedWorkouts.length; i++) {
        final timestamp = (_groupedWorkouts[i]['workouts'][0]
                .data()['timestamp'] as Timestamp)
            .toDate();
        if (timestamp.isAtSameMomentAs(_selectedDay!)) {
          mostRecentDateIndex = i;
          break;
        }
      }
    }

    // Scroll to the most recent date when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        mostRecentDateIndex * 75.0, // Adjust the value as needed
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });

    return Column(
      children: [
        const SizedBox(height: 20),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentMonthYear,
                  style: GoogleFonts.knewave(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade800, width: 2.0),
                  top: BorderSide(color: Colors.grey.shade800, width: 2.0),
                ),
              ),
              height: 75, // Adjust the height as needed
              child: ListView.builder(
                controller: _scrollController, // Use the ScrollController
                physics: ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: _groupedWorkouts.length,
                itemBuilder: (context, index) {
                  final group = _groupedWorkouts[index];
                  final day = group['day'];

                  final timestamp =
                      (group['workouts'][0].data()['timestamp'] as Timestamp)
                          .toDate();

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        // Update the selected day as a DateTime object
                        _selectedDay = timestamp;
                        _updateCurrentMonthYear();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Container(
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: _selectedDay != null &&
                                  _selectedDay!.isAtSameMomentAs(timestamp)
                              ? Border.all(color: Colors.white, width: 2.0)
                              : Border.all(
                                  color: Colors.grey.shade700, width: 2.0),
                          color: _selectedDay != null &&
                                  _selectedDay!.isAtSameMomentAs(timestamp)
                              ? Colors.greenAccent.shade400
                              : Colors.grey.shade800,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(0.2), // Shadow color
                              spreadRadius:
                                  2, // How much the shadow should spread
                              blurRadius: 5, // How blurry the shadow should be
                              offset: const Offset(
                                  3, 3), // Changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              DateFormat('MMM').format(timestamp).toUpperCase(),
                              style: GoogleFonts.knewave(
                                fontSize: 12,
                                color: _selectedDay != null &&
                                        _selectedDay!
                                            .isAtSameMomentAs(timestamp)
                                    ? Colors.black
                                    : Colors.greenAccent.shade400,
                              ),
                            ),
                            Text(
                              DateFormat('d').format(timestamp),
                              style: GoogleFonts.knewave(
                                fontSize: 14,
                                color: _selectedDay != null &&
                                        _selectedDay!
                                            .isAtSameMomentAs(timestamp)
                                    ? Colors.black
                                    : Colors.greenAccent.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build Past Exercises Container
  Widget _buildPastExercisesContainer() {
    if (_selectedDay == null) {
      return Center(
        child: Text(
          'No past activity yet',
          style: GoogleFonts.knewave(fontSize: 18, color: Colors.white),
        ),
      );
    }

    // Find the selected day's group using a DateTime object
    final selectedGroup = _groupedWorkouts.firstWhere(
      (group) {
        final timestamp =
            (group['workouts'][0].data()['timestamp'] as Timestamp).toDate();
        return timestamp.isAtSameMomentAs(_selectedDay!);
      },
      orElse: () => {'day': '', 'workouts': []},
    );

    final pastExercises = (selectedGroup['workouts'] as List)
        .map((item) => item as QueryDocumentSnapshot)
        .toList();

    // Sort the past exercises by workoutName
    pastExercises.sort((a, b) {
      final workoutDataA = a.data() as Map<String, dynamic>;
      final workoutDataB = b.data() as Map<String, dynamic>;
      final workoutNameA = workoutDataA['workoutName'];
      final workoutNameB = workoutDataB['workoutName'];
      return workoutNameA.compareTo(workoutNameB);
    });

    // Display "No exercises found" if no past exercises exist for that day
    if (pastExercises.isEmpty) {
      return Center(
        child: Text(
          'No exercises found for this day',
          style: GoogleFonts.knewave(fontSize: 18, color: Colors.white),
        ),
      );
    }

    // Create a list of widgets to store the grouped exercises
    final groupedExerciseWidgets = <Widget>[];

    // Initialize a variable to keep track of the current workoutName
    String? currentWorkoutName;

    for (final exercise in pastExercises) {
      final workoutData = exercise.data() as Map<String, dynamic>;
      final workoutName = workoutData['workoutName'];

      // Check if the workoutName has changed (edited), and if so, add a section header
      if (currentWorkoutName != workoutName) {
        groupedExerciseWidgets.add(Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            workoutName,
            style: GoogleFonts.knewave(
              fontSize: 20,
              color: Colors.greenAccent.shade400,
            ),
            textAlign: TextAlign.center,
          ),
        ));
        currentWorkoutName = workoutName;
      }

      // Add the PastExerciseTile for the current exercise
      groupedExerciseWidgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
          child: Slidable(
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (BuildContext context) {
                    addExerciseToUserWorkouts(
                      workoutId:
                          widget.workoutId, // Provide the correct workout ID

                      workoutName: selectedGroup['workouts'][0]['workoutName'],
                      exerciseName: workoutData['exerciseName'],
                      weight: workoutData['weight'],
                      reps: workoutData['reps'],
                      sets: workoutData['sets'],
                      distance: workoutData['distance'],
                      time: workoutData['time'], exerciseId: '',
                    );
                  },
                  icon: Icons.add_circle_rounded,
                  foregroundColor: Colors.greenAccent.shade400,
                  backgroundColor: Colors.grey.shade900,
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
              color: Colors.grey.shade800,
              border: Border.all(color: Colors.grey.shade700, width: 2.0),
            ),
          ),
        ),
      );
    }

    return ListView(
      children: groupedExerciseWidgets,
    );
  }

  // Group Workouts by Day
  List<Map<String, dynamic>> groupWorkoutsByDay(
    List<QueryDocumentSnapshot> workouts,
  ) {
    final groupedWorkouts = <String, Map<String, dynamic>>{};

    for (final workout in workouts) {
      final workoutData = workout.data() as Map<String, dynamic>;
      final timestamp = (workoutData['timestamp'] as Timestamp).toDate();
      final day = DateFormat('d-MMM-yyyy').format(timestamp);

      if (!groupedWorkouts.containsKey(day)) {
        groupedWorkouts[day] = {
          'day': day,
          'workouts': <QueryDocumentSnapshot>[],
        };
      }

      groupedWorkouts[day]!['workouts'].add(workout);
    }

    return groupedWorkouts.values.toList();
  }
}
