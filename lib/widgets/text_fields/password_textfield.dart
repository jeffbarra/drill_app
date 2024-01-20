import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordTextField({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  // Show Password Toggle
  bool _passwordVisible = false;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.black,
      focusNode: _focusNode,
      style: GoogleFonts.knewave(color: Colors.black),
      controller: widget.controller,
      obscureText: !_passwordVisible,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.lock,
          color: _isFocused ? Colors.greenAccent.shade400 : Colors.grey,
        ),
        prefixIconColor: Colors.grey,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
          icon: Icon(
            _passwordVisible ? Icons.visibility_off : Icons.visibility,
            color: _isFocused ? Colors.greenAccent.shade400 : Colors.grey,
          ),
        ),
        fillColor: Colors.white,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Colors.greenAccent.shade400, width: 2.0),
        ),
        hintText: 'Enter Password',
        hintStyle: GoogleFonts.knewave(color: Colors.grey),
      ),
    );
  }
}
