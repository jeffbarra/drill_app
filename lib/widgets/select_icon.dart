import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectIconPage extends StatelessWidget {
  const SelectIconPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade900,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            'Select Icon',
            style: GoogleFonts.knewave(
              fontSize: 20,
              color: Colors.greenAccent.shade400,
            ),
          ),
        ),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemCount: _iconList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Pass the selected image path back to the previous screen
              Navigator.pop(context, _iconList[index]);
            },
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Image.asset(
                _iconList[index],
                width: 30,
                height: 30,
              ),
            ),
          );
        },
      ),
    );
  }
}

List<String> _iconList = [
  'lib/assets/images/abs.png',
  'lib/assets/images/cardio.png',
  'lib/assets/images/curls.png',
  'lib/assets/images/cycling.png',
  'lib/assets/images/kickboxing.png',
  'lib/assets/images/lats.png',
  'lib/assets/images/legs.png',
  'lib/assets/images/shoulders.png',
  'lib/assets/images/squats.png',
  'lib/assets/images/stretching.png',
  'lib/assets/images/swim.png',
  'lib/assets/images/weights.png',
  'lib/assets/images/yoga.png',
];
