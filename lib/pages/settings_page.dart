import 'package:drill_app/widgets/buttons/logout_button.dart';
import 'package:drill_app/widgets/tiles/trainer_signup_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // // Define boolean variables to store the toggle states.
  // bool toggle1 = true;
  // bool toggle2 = false;
  // bool toggle3 = false;

  // // Function to handle toggle state changes.
  // void handleToggle(int toggleNumber) {
  //   setState(() {
  //     // Set the toggle states based on the selected toggleNumber.
  //     toggle1 = toggleNumber == 1;
  //     toggle2 = toggleNumber == 2;
  //     toggle3 = toggleNumber == 3;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade900,
        actions: [
          LogoutButton(),
        ],
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            'Settings',
            style: GoogleFonts.knewave(
                fontSize: 20, color: Colors.greenAccent.shade400),
          ),
        ),
      ),
      body: const Column(
        children: [
// Color Scheme Toggles
          // Container(
          //   padding: const EdgeInsets.only(top: 10, bottom: 20),
          //   child: Column(
          //     children: [
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Text(
          //             'Color Scheme',
          //             style: GoogleFonts.knewave(
          //                 fontSize: 18, color: Colors.greenAccent.shade400),
          //           ),
          //         ],
          //       ),

          //       const SizedBox(
          //         height: 10,
          //       ),

          //       // Color Scheme Toggle
          //       Padding(
          //         padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          //         child: Container(
          //           decoration: BoxDecoration(
          //             border:
          //                 Border.all(color: Colors.grey.shade800, width: 2.0),
          //             borderRadius: BorderRadius.circular(20),
          //           ),
          //           child: ListTile(
          //             title: Text(
          //               'Color Scheme 1',
          //               style: GoogleFonts.knewave(color: Colors.grey.shade600),
          //             ),
          //             trailing: Switch(
          //               inactiveThumbColor: Colors.grey.shade600,
          //               activeColor: Colors.greenAccent.shade400,
          //               value: toggle1,
          //               onChanged: (value) {
          //                 if (value) {
          //                   handleToggle(1);
          //                 }
          //               },
          //             ),
          //           ),
          //         ),
          //       ),

          //       const SizedBox(
          //         height: 10,
          //       ),

          //       // Color Scheme Toggle
          //       Padding(
          //         padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          //         child: Container(
          //           decoration: BoxDecoration(
          //             border:
          //                 Border.all(color: Colors.grey.shade800, width: 2.0),
          //             borderRadius: BorderRadius.circular(20),
          //           ),
          //           child: ListTile(
          //             title: Text('Color Scheme 2',
          //                 style:
          //                     GoogleFonts.knewave(color: Colors.grey.shade600)),
          //             trailing: Switch(
          //               inactiveThumbColor: Colors.grey.shade600,
          //               activeColor: Colors.greenAccent.shade400,
          //               value: toggle2,
          //               onChanged: (value) {
          //                 if (value) {
          //                   handleToggle(2);
          //                 }
          //               },
          //             ),
          //           ),
          //         ),
          //       ),

          //       const SizedBox(
          //         height: 10,
          //       ),

          //       // Color Scheme Toggle
          //       Padding(
          //         padding: const EdgeInsets.only(right: 30.0, left: 30.0),
          //         child: Container(
          //           decoration: BoxDecoration(
          //             border:
          //                 Border.all(color: Colors.grey.shade800, width: 2.0),
          //             borderRadius: BorderRadius.circular(20),
          //           ),
          //           child: ListTile(
          //             title: Text(
          //               'Color Scheme 3',
          //               style: GoogleFonts.knewave(color: Colors.grey.shade600),
          //             ),
          //             trailing: Switch(
          //               inactiveThumbColor: Colors.grey.shade600,
          //               activeColor: Colors.greenAccent.shade400,
          //               value: toggle3,
          //               onChanged: (value) {
          //                 if (value) {
          //                   handleToggle(3);
          //                 }
          //               },
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // Personal Trainer Sign Up Tile
          PersonalTrainerSignUpTile(),
        ],
      ),
    );
  }
}
