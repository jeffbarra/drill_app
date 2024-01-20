import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginRegisterButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  LoginRegisterButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent.shade400,
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(text,
              style: GoogleFonts.knewave(fontSize: 20, color: Colors.black)),
        ),
      ),
    );
  }
}
