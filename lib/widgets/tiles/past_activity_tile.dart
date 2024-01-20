import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PastActivityTile extends StatelessWidget {
  final String timestamp;
  final String workoutName;
  final String weight;
  final String reps;
  final String sets;
  final String distance;
  final String time;

  const PastActivityTile({
    super.key,
    required this.timestamp,
    required this.workoutName,
    required this.weight,
    required this.reps,
    required this.sets,
    required this.distance,
    required this.time,
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
      width: 280,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        border: Border.all(color: Colors.grey.shade700, width: 2.0),
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
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        timestamp.toString(),
                        style: GoogleFonts.knewave(color: Colors.white),
                      ),
                    )
                  ],
                ),
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
