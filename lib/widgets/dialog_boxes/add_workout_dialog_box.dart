import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../text_fields/main_textfield.dart';

class AddWorkoutDialogBox extends StatelessWidget {
  final TextEditingController controller;
  final Function()? onPressed;
  const AddWorkoutDialogBox(
      {super.key, required this.controller, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Add Workout',
        textAlign: TextAlign.center,
        style: GoogleFonts.knewave(color: Colors.black),
      ),
      content: MainTextField(
        enabled: true,
        inputType: TextInputType.text,
        textStyle: GoogleFonts.knewave(color: Colors.black),
        hintText: 'Workout Name',
        obscureText: false,
        controller: controller,
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cancel Button
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade400),
                onPressed: () {
                  Navigator.pop(context);

                  controller.clear();
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

            // Add Button
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade400,
                ),
                onPressed: onPressed,
                child: Text('Add',
                    style: GoogleFonts.knewave(color: Colors.black)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
