import 'package:drill_app/pages/add_client_workout_page.dart';
import 'package:drill_app/pages/chat_page.dart';
import 'package:drill_app/pages/client_activity.dart';
import 'package:drill_app/widgets/tiles/past_exercise_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ClientPage extends StatefulWidget {
  final String clientName;
  final String clientEmail;

  const ClientPage(
      {Key? key, required this.clientName, required this.clientEmail})
      : super(key: key);

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  List<Map<String, dynamic>> _groupedWorkouts = [];
  DateTime? _selectedDay;
  String currentMonthYear = DateFormat('yyyy').format(DateTime.now());
  int currentStreak = 0;
  int longestStreak = 0;

  // Get Current User
  final currentUser = FirebaseAuth.instance.currentUser!;

  bool chatIconClicked = false;

  bool _isLoading = true; // Flag to track if the page is loading

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Simulate a 1-second delay before showing content
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

    // Initialize _unreadMessagesCount
    _updateUnreadMessagesCount();
  }

  // Add this method to update _unreadMessagesCount
  void _updateUnreadMessagesCount() async {
    final CollectionReference messagesCollection =
        FirebaseFirestore.instance.collection('messages');

    // Query for messages where the 'receiver' is the current user's email and 'receiverRead' is false
    QuerySnapshot unreadMessages = await messagesCollection
        .where('receiver', isEqualTo: currentUser.email)
        .where('sender', isEqualTo: widget.clientEmail)
        .where('receiverRead', isEqualTo: false)
        .get();

    setState(() {
      _unreadMessagesCount = unreadMessages.docs.length;
    });
  }

  // Fetch Past Client Workouts
  void _fetchPastWorkouts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.clientEmail)
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

    final groupedWorkouts = groupWorkoutsByDay(pastWorkouts);

    if (_groupedWorkouts.isNotEmpty) {
      final mostRecentDate = (_groupedWorkouts.last['workouts'][0]
              .data()['timestamp'] as Timestamp)
          .toDate();

      if (mounted) {
        setState(() {
          _selectedDay = mostRecentDate;
        });
        // print("Most recent date: $mostRecentDate");
      }
    }

    // Calculate streaks
    int currentStreakCount = 0;
    int longestStreakCount = 0;
    DateTime? previousDate;

    for (final group in _groupedWorkouts) {
      final timestamp =
          (group['workouts'][0].data()['timestamp'] as Timestamp).toDate();

      if (previousDate != null &&
          (timestamp.year == previousDate.year &&
              timestamp.month == previousDate.month &&
              timestamp.day - 1 == previousDate.day)) {
        currentStreakCount++;
        if (currentStreakCount > longestStreakCount) {
          longestStreakCount = currentStreakCount;
        }
      } else {
        currentStreakCount = 1;
      }

      previousDate = timestamp;
    }

    if (longestStreakCount == 0 && currentStreakCount == 1) {
      longestStreakCount = 1;
    }

    if (mounted) {
      setState(() {
        currentStreak = currentStreakCount;
        longestStreak = longestStreakCount;
      });
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

  int _unreadMessagesCount = 0;

  void markMessagesAsRead() async {
    final CollectionReference messagesCollection =
        FirebaseFirestore.instance.collection('messages');

    // Query for messages where the 'receiver' is the current user's email and 'receiverRead' is false
    QuerySnapshot unreadMessages = await messagesCollection
        .where('receiver', isEqualTo: currentUser.email)
        .where('sender', isEqualTo: widget.clientEmail)
        .where('receiverRead', isEqualTo: false)
        .get();

    // Clear the count of unread messages
    _unreadMessagesCount = 0;

    for (QueryDocumentSnapshot messageDoc in unreadMessages.docs) {
      await messagesCollection.doc(messageDoc.id).update({
        'receiverRead': true,
      });
    }

    // Set chatIconClicked to true
    setState(() {
      chatIconClicked = true;
    });
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
            widget.clientName,
            style: GoogleFonts.knewave(
              fontSize: 20,
              color: Colors.greenAccent.shade400,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      Get.to(
                          () => ClientActivityDataPage(
                                clientEmail: widget.clientEmail,
                                clientName: widget.clientName,
                              ),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 500));
                    },
                    icon: const Icon(Icons.trending_up_rounded,
                        size: 30, color: Colors.white)),
                IconButton(
                  onPressed: () {
                    // Mark messages as read
                    markMessagesAsRead();

                    // Navigate to the chat page
                    Get.to(
                      () => ChatPage(
                        specificUserEmail: widget.clientEmail,
                      ),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 500),
                    );
                  },
                  icon: Stack(
                    children: [
                      const Icon(Icons.chat_rounded, size: 30),
                      if (_unreadMessagesCount >
                          0) // Only display the tag if there are unread messages
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Center(
                              child: Text(
                                _unreadMessagesCount.toString(),
                                style: GoogleFonts.knewave(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: FloatingActionButton(
          backgroundColor: Colors.greenAccent.shade400,
          onPressed: () {
            Get.to(
              () => AddClientWorkoutPage(
                clientName: widget.clientName,
                clientEmail: widget.clientEmail,
              ),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 500),
            );
          },
          child:
              const Icon(Icons.assignment_add, color: Colors.black, size: 30),
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
        // Display current and longest streaks
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
          ),
          child: Container(
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              border: Border.all(color: Colors.grey.shade700, width: 2.0),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Shadow color
                  spreadRadius: 2, // How much the shadow should spread
                  blurRadius: 5, // How blurry the shadow should be
                  offset: const Offset(3, 3), // Changes position of shadow
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 8),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: 'Current Streak',
                        style: GoogleFonts.knewave(
                          color: Colors
                              .white, // Set the text color for "Longest Streak"
                          fontSize: 14,
                        ),
                        children: [
                          WidgetSpan(
                              child: Icon(Icons.bolt_rounded,
                                  color: Colors.yellow.shade400)),
                        ]),
                    TextSpan(
                      text: '$currentStreak days',
                      style: GoogleFonts.knewave(
                        color: Colors.greenAccent
                            .shade400, // Set the text color for "$longestStreak days"
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            border: Border.all(color: Colors.grey.shade700, width: 2.0),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Shadow color
                spreadRadius: 2, // How much the shadow should spread
                blurRadius: 5, // How blurry the shadow should be
                offset: const Offset(3, 3), // Changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 10),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                      text: 'Longest Streak',
                      style: GoogleFonts.knewave(
                        color: Colors
                            .white, // Set the text color for "Longest Streak"
                        fontSize: 14,
                      ),
                      children: [
                        WidgetSpan(
                            child: Icon(Icons.bolt_rounded,
                                color: Colors.yellow.shade400)),
                      ]),
                  TextSpan(
                    text: '$longestStreak days',
                    style: GoogleFonts.knewave(
                      color: Colors.greenAccent
                          .shade400, // Set the text color for "$longestStreak days"
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

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
                  final timestamp = (_groupedWorkouts[index]['workouts'][0]
                          .data()['timestamp'] as Timestamp)
                      .toDate();

                  return GestureDetector(
                    onTap: () {
                      setState(() {
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
          padding: const EdgeInsets.only(top: 10, bottom: 20),
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
          padding: const EdgeInsets.only(left: 40, right: 40, bottom: 10),
          child: PastExerciseTile(
              workoutName: workoutData['workoutName'],
              exerciseName: workoutData['exerciseName'],
              weight: workoutData['weight'],
              reps: workoutData['reps'],
              sets: workoutData['sets'],
              distance: workoutData['distance'],
              time: workoutData['time'],
              border: Border.all(color: Colors.grey.shade700, width: 2.0),
              color: Colors.grey.shade800),
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
