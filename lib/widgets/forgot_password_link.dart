import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/password_reset.dart';

class ForgotPasswordFooter extends StatelessWidget {
  const ForgotPasswordFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Get.to(const ResetPassword(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 500));
        },

        // Forgot Password?
        child: Text(
          'Forgot Password?',
          style: GoogleFonts.knewave(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
