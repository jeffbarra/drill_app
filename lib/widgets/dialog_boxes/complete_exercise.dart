import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompleteExerciseDialogBox extends StatelessWidget {
  final void Function()? onYesPressed;
  final void Function()? onNoPressed;

  const CompleteExerciseDialogBox(
      {super.key, required this.onYesPressed, required this.onNoPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Complete This Exercise?',
        style: GoogleFonts.knewave(fontSize: 18, color: Colors.black),
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // no button
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade400,
                  ),
                  onPressed: onNoPressed,
                  child: Text('No',
                      style: GoogleFonts.knewave(color: Colors.black))),
            ),

            const SizedBox(width: 10),
            // yes button
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade400,
                  ),
                  onPressed: onYesPressed,
                  child: Text('Yes',
                      style: GoogleFonts.knewave(color: Colors.black))),
            ),
          ],
        ),
      ],
    );
  }
}
