import 'package:drill_app/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool animationCompleted = false;

  @override
  void initState() {
    super.initState();

    // Delay for 500 milliseconds and then show the circular progress indicator
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        animationCompleted = true;
      });

      // Delay for an additional 2 seconds and then navigate to AuthGate
      Future.delayed(const Duration(seconds: 2), () {
        navigateToAuthGate();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!animationCompleted)
              Text(
                'Drill',
                style: GoogleFonts.knewave(
                  color: Colors.greenAccent.shade400,
                  fontSize: 50,
                ),
              ),
            if (!animationCompleted)
              const SizedBox(
                  height:
                      16), // Add some space between text and CircularProgressIndicator
            if (animationCompleted)
              Center(
                child: Stack(alignment: Alignment.center, children: <Widget>[
                  Icon(Icons.fitness_center_rounded,
                      color: Colors.greenAccent.shade400, size: 30),
                  Container(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      color: Colors.greenAccent.shade400,
                    ),
                  ),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  // Function to navigate to AuthGate
  void navigateToAuthGate() {
    Get.to(
      () => const AuthGate(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }
}
