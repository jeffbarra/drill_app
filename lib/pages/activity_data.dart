import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ActivityDataPage extends StatefulWidget {
  ActivityDataPage({
    Key? key,
  }) : super(key: key);

  @override
  _ActivityDataPageState createState() => _ActivityDataPageState();
}

class _ActivityDataPageState extends State<ActivityDataPage> {
  List<QueryDocumentSnapshot> exercises = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      _fetchPastWorkouts();
    });
  }

  void _fetchPastWorkouts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('past_workouts')
        .orderBy('exerciseName', descending: false)
        .get();

    final pastWorkouts = snapshot.docs;

    if (mounted) {
      setState(() {
        exercises = pastWorkouts;
        isLoading = false;
      });
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
            'Your Exercise Data',
            style: GoogleFonts.knewave(color: Colors.greenAccent.shade400),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
          child: Stack(alignment: Alignment.center, children: <Widget>[
        Icon(Icons.fitness_center_rounded,
            color: Colors.greenAccent.shade400, size: 30),
        Container(
            height: 50,
            width: 50,
            child:
                CircularProgressIndicator(color: Colors.greenAccent.shade400)),
      ]));
    } else if (exercises.isEmpty) {
      return Center(
          child: Text(
        'No Exercise Data Yet',
        style: GoogleFonts.knewave(
          fontSize: 18,
          color: Colors.white,
        ),
      ));
    } else {
      return _buildExercises();
    }
  }

  Widget _buildExercises() {
    final Map<String, List<QueryDocumentSnapshot>> exerciseMap = {};

    for (final exercise in exercises) {
      final exerciseData = exercise.data() as Map<String, dynamic>;
      final exerciseName = exerciseData['exerciseName'];

      if (!exerciseMap.containsKey(exerciseName)) {
        exerciseMap[exerciseName] = [];
      }
      exerciseMap[exerciseName]!.add(exercise);
    }

    return ListView(
      children: exerciseMap.keys.map((exerciseName) {
        final exerciseList = exerciseMap[exerciseName];
        return _buildExerciseRow(exerciseName, exerciseList);
      }).toList(),
    );
  }

  Widget _buildExerciseRow(
    String exerciseName,
    List<QueryDocumentSnapshot>? exerciseList,
  ) {
    final exerciseData = exerciseList?.first.data() as Map<String, dynamic>;
    final fields = ['weight', 'reps', 'sets', 'distance', 'time'];
    final List<Widget> exerciseTiles = fields.map((field) {
      return _buildChart(exerciseList, field);
    }).toList();

    // Apply left padding to the first tile
    if (exerciseList != null &&
        exerciseList.isNotEmpty &&
        exerciseName == exerciseList.first['exerciseName']) {
      exerciseTiles.first = Padding(
        padding: const EdgeInsets.only(left: 10),
        child: exerciseTiles.first,
      );
    }

    // Apply right padding to the last tile
    if (exerciseList != null &&
        exerciseList.isNotEmpty &&
        exerciseName == exerciseList.last['exerciseName']) {
      exerciseTiles.last = Padding(
        padding: const EdgeInsets.only(right: 10),
        child: exerciseTiles.last,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            exerciseName,
            style: GoogleFonts.knewave(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: exerciseTiles,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(
    List<QueryDocumentSnapshot>? exerciseList,
    String field,
  ) {
    if (!_hasDataForField(exerciseList, field)) {
      // If there is no data for this field, return an empty container
      return Container();
    }

    final chartSeries = _generateChartSeries(exerciseList, field);
    final exerciseName = exerciseList?.first['exerciseName'];

    // Capitalize the field name
    final capitalizedField = field[0].toUpperCase() + field.substring(1);

    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          border: Border.all(color: Colors.grey.shade700, width: 2),
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
        width: 350,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 10, right: 20), // Add padding on left and right
          child: SfCartesianChart(
            zoomPanBehavior: ZoomPanBehavior(
              enablePanning: true,
              enablePinching: true,
              enableDoubleTapZooming: true,
            ),
            primaryXAxis: DateTimeAxis(
              labelStyle: GoogleFonts.knewave(
                  color: Colors.white), // Hide X-axis values
              dateFormat: DateFormat('MM/dd'),
              majorGridLines: MajorGridLines(color: Colors.grey.shade800),
            ),
            primaryYAxis: NumericAxis(
              labelStyle: GoogleFonts.knewave(
                  color: Colors.white), // Hide Y-axis values
              majorGridLines: MajorGridLines(color: Colors.grey.shade700),
            ),
            series: chartSeries,
            tooltipBehavior: TooltipBehavior(
              enable: true,
              // Customize the tooltip content
              builder: (dynamic data, dynamic point, dynamic series,
                  int pointIndex, int seriesIndex) {
                final exerciseData = data as ExerciseData;
                return Container(
                  width: 100,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    border: Border.all(color: Colors.grey.shade700),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('MM-dd-yy')
                                .format(exerciseData.timestamp),
                            style: GoogleFonts.knewave(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            exerciseData
                                .fullValue, // Display the full string value
                            style: GoogleFonts.knewave(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            title: ChartTitle(
              text: capitalizedField, // Use the capitalized field name
              textStyle: GoogleFonts.knewave(
                  color: Colors.greenAccent.shade400, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  List<ChartSeries<ExerciseData, DateTime>> _generateChartSeries(
    List<QueryDocumentSnapshot>? exerciseList,
    String field,
  ) {
    final chartSeries = <ChartSeries<ExerciseData, DateTime>>[];

    final fields = [
      'weight',
      'reps',
      'sets',
      'distance',
      'time'
    ]; // List of fields

    final colors = <Color>[
      Colors.red.shade400, // Color for 'weight' series
      Colors.greenAccent.shade400, // Color for 'reps' series
      Colors.blue.shade400, // Color for 'sets' series
      Colors.orange.shade400, // Color for 'distance' series
      Colors.yellow.shade400, // Color for 'time' series
    ];

    final index =
        fields.indexOf(field); // Get the index of the field in the list

    if (index != -1) {
      chartSeries.add(LineSeries<ExerciseData, DateTime>(
        name: field,
        dataSource: _getExerciseData(exerciseList, field),
        xValueMapper: (ExerciseData data, _) => data.timestamp,
        yValueMapper: (ExerciseData data, _) => data.numericalValue,
        color: colors[index], // Set the color for the series based on the field
        markerSettings: const MarkerSettings(isVisible: true),
      ));
    }

    return chartSeries;
  }

  List<ExerciseData> _getExerciseData(
    List<QueryDocumentSnapshot>? exerciseList,
    String field,
  ) {
    final dataList = <ExerciseData>[];

    for (final exercise in exerciseList ?? []) {
      final exerciseData = exercise.data() as Map<String, dynamic>;
      final timestamp = exerciseData['timestamp'] as Timestamp;
      final date = timestamp.toDate();
      final fullValue =
          exerciseData[field].toString(); // Store the full string value
      final numericalValue =
          _extractNumericalValue(fullValue); // Extract the numerical value

      dataList.add(ExerciseData(
        timestamp: date,
        numericalValue: numericalValue,
        fullValue: fullValue,
      ));
    }

    return dataList;
  }

  bool _hasDataForField(
      List<QueryDocumentSnapshot>? exerciseList, String field) {
    // Check if there is at least one exercise with data for the given field
    if (exerciseList == null) return false;

    for (final exercise in exerciseList) {
      final exerciseData = exercise.data() as Map<String, dynamic>;
      if (exerciseData.containsKey(field) &&
          exerciseData[field] != null &&
          exerciseData[field] != "") {
        return true;
      }
    }

    return false;
  }

  double _extractNumericalValue(String fullValue) {
    final numericPart = fullValue.replaceAll(
        RegExp(r'[^0-9.]'), ''); // Extract digits and decimal point
    return double.tryParse(numericPart) ?? 0.0; // Parse the numeric value
  }
}

class ExerciseData {
  final DateTime timestamp;
  final double numericalValue;
  final String fullValue;

  ExerciseData({
    required this.timestamp,
    required this.numericalValue,
    required this.fullValue,
  });
}
