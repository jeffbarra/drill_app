import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType inputType;
  final TextStyle textStyle;
  final String hintText;
  final bool obscureText;
  final bool enabled;

  const MainTextField({
    super.key,
    required this.controller,
    required this.inputType,
    required this.textStyle,
    required this.hintText,
    required this.obscureText,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      maxLines: null,
      keyboardType: inputType,
      autofocus: true,
      textInputAction: TextInputAction.next,
      style: textStyle,
      cursorColor: Colors.black,
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10),
        fillColor: Colors.white,
        filled: true,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2.0),
        ),
        hintText: hintText,
        hintStyle: GoogleFonts.knewave(color: Colors.grey.shade500),
      ),
    );
  }
}
