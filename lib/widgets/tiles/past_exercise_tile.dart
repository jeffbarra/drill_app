import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PastExerciseTile extends StatelessWidget {
  final String workoutName;
  final String exerciseName;
  final String weight;
  final String reps;
  final String sets;
  final String distance;
  final String time;
  final Color color;
  final Border border;

  const PastExerciseTile({
    super.key,
    required this.workoutName,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.sets,
    required this.distance,
    required this.time,
    required this.color,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the values are empty
    String weightValue = weight.isEmpty ? 'No Weight' : '${weight} lbs';
    String repsValue = reps.isEmpty ? 'No Reps' : '${reps} Reps';
    String setsValue = sets.isEmpty ? 'No Sets' : '${sets} Sets';
    String distanceValue = distance.isEmpty ? 'Stationary' : distance;
    String timeValue = time.isEmpty ? 'No Time Limit' : time;

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: color,
        border: border,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow color
            spreadRadius: 2, // How much the shadow should spread
            blurRadius: 5, // How blurry the shadow should be
            offset: const Offset(3, 3), // Changes position of shadow
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  exerciseName,
                  style: GoogleFonts.knewave(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: Colors.red.shade400, width: 2.0),
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
                      child: Text(
                        weightValue, // Use the modified value here
                        style: GoogleFonts.knewave(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade400.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.greenAccent.shade400, width: 2.0),
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
                      child: Text(
                        repsValue, // Use the modified value here
                        style: GoogleFonts.knewave(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade400.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: Colors.blue.shade400, width: 2.0),
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
                      child: Text(
                        setsValue, // Use the modified value here
                        style: GoogleFonts.knewave(
                          fontSize: 12,
                          color: Colors.white,
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
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade400.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.orange.shade400, width: 2.0),
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
                      child: Text(
                        distanceValue, // Use the modified value here
                        style: GoogleFonts.knewave(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade400.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.yellow.shade400, width: 2.0),
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
                      child: Text(
                        timeValue, // Use the modified value here
                        style: GoogleFonts.knewave(
                          fontSize: 12,
                          color: Colors.white,
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
    );
  }
}
