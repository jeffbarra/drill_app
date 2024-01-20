import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrainerCodeDialogBox extends StatefulWidget {
  const TrainerCodeDialogBox({super.key});

  @override
  State<TrainerCodeDialogBox> createState() => _TrainerCodeDialogBoxState();
}

class _TrainerCodeDialogBoxState extends State<TrainerCodeDialogBox> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Enter Special Code',
        style: GoogleFonts.knewave(color: Colors.black),
        textAlign: TextAlign.center,
      ),
      content: TextFormField(
        keyboardType: TextInputType.number,
        cursorColor: Colors.black,
        style: GoogleFonts.knewave(color: Colors.grey.shade700),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10),
          fillColor: Colors.white,
          filled: true,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2.0),
          ),
          hintText: "Enter Code",
          hintStyle: GoogleFonts.knewave(color: Colors.grey.shade500),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cancel Button
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade400,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.knewave(color: Colors.black),
                  )),
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
                  onPressed: () {},
                  child: Text(
                    'Add',
                    style: GoogleFonts.knewave(color: Colors.black),
                  )),
            ),
          ],
        )
      ],
    );
  }
}
