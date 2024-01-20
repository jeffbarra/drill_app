import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../text_fields/main_textfield.dart';

class AddExerciseDialogBox extends StatefulWidget {
  final TextEditingController exerciseNameController;
  final TextEditingController weightController;
  final TextEditingController repsController;
  final TextEditingController setsController;
  final TextEditingController distanceController;
  final TextEditingController timeController;
  final Function()? onPressed;

  const AddExerciseDialogBox({
    Key? key,
    required this.exerciseNameController,
    required this.weightController,
    required this.repsController,
    required this.setsController,
    required this.distanceController,
    required this.timeController,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<AddExerciseDialogBox> createState() => _AddExerciseDialogBoxState();
}

class _AddExerciseDialogBoxState extends State<AddExerciseDialogBox> {
  bool isIPhoneSE = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkScreenSize();
  }

  void checkScreenSize() {
    double screenHeight = MediaQuery.of(context).size.height;

    // The height of the iPhone SE is 568.0
    if (screenHeight == 568.0) {
      setState(() {
        isIPhoneSE = true;
      });
    }
  }

  double calculateSizedBoxHeight() {
    if (isIPhoneSE) {
      // For iPhone SE, use a smaller height
      return 5.0;
    } else {
      // For other devices, use a larger height
      return 10.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MainTextField(
          enabled: true,
          controller: widget.exerciseNameController,
          inputType: TextInputType.text,
          textStyle: GoogleFonts.knewave(color: Colors.black),
          obscureText: false,
          hintText: 'Exercise Name',
        ),
        Flexible(
          child: SizedBox(
            height: calculateSizedBoxHeight(),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: MainTextField(
                enabled: true,
                controller: widget.weightController,
                inputType: TextInputType.number,
                textStyle: isIPhoneSE
                    ? GoogleFonts.knewave(color: Colors.white)
                    : GoogleFonts.knewave(color: Colors.black),
                obscureText: false,
                hintText: 'Weight',
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: MainTextField(
                enabled: true,
                controller: widget.repsController,
                inputType: TextInputType.number,
                textStyle: GoogleFonts.knewave(color: Colors.black),
                obscureText: false,
                hintText: 'Reps',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MainTextField(
                enabled: true,
                controller: widget.setsController,
                inputType: TextInputType.number,
                textStyle: GoogleFonts.knewave(color: Colors.black),
                obscureText: false,
                hintText: 'Sets',
              ),
            ),
          ],
        ),
        Flexible(
          child: SizedBox(
            height: calculateSizedBoxHeight(),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: MainTextField(
                enabled: true,
                controller: widget.distanceController,
                inputType: TextInputType.text,
                textStyle: GoogleFonts.knewave(color: Colors.black),
                obscureText: false,
                hintText: 'Distance',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MainTextField(
                enabled: true,
                controller: widget.timeController,
                inputType: TextInputType.text,
                textStyle: GoogleFonts.knewave(color: Colors.black),
                obscureText: false,
                hintText: 'Time',
              ),
            ),
          ],
        ),
      ],
    );

    if (isIPhoneSE) {
      content = SingleChildScrollView(
        child: content,
      );
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Add Exercise',
        textAlign: TextAlign.center,
        style: GoogleFonts.knewave(color: Colors.black),
      ),
      content: content,
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
                  Navigator.pop(context);
                  widget.exerciseNameController.clear();
                  widget.weightController.clear();
                  widget.repsController.clear();
                  widget.setsController.clear();
                  widget.distanceController.clear();
                  widget.timeController.clear();
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.knewave(color: Colors.black),
                ),
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
                onPressed: widget.onPressed,
                child: Text(
                  'Add',
                  style: GoogleFonts.knewave(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
