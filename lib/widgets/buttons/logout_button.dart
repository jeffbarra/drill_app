import 'package:drill_app/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/auth_service.dart';

class LogoutButton extends StatelessWidget {
  LogoutButton({super.key});

// Auth Service Instance
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
        child: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Text(
                    'Are you sure you want to logout?',
                    style: GoogleFonts.knewave(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent.shade400,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            // cancel button
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.knewave(color: Colors.black),
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        // logout button
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent.shade400,
                            ),
                            onPressed: () async {
                              await authService.signOut();
                              // pop the dialog box
                              Navigator.pop(context);
                              // go back to login/register page thru AuthGate
                              Get.to(() => const AuthGate(),
                                  transition: Transition.noTransition,
                                  duration: const Duration(milliseconds: 300));
                            },
                            child: Text(
                              'Logout',
                              style: GoogleFonts.knewave(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
            icon: Icon(Icons.logout_rounded,
                size: 30, color: Colors.grey.shade600)));
  }
}
