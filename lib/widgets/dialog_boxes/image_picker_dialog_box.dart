import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImagePickerDialogBox extends StatelessWidget {
  final Function()? onTapOne;
  final Function()? onTapTwo;
  const ImagePickerDialogBox(
      {super.key, required this.onTapOne, required this.onTapTwo});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Upload Image',
        style: GoogleFonts.knewave(fontSize: 20, color: Colors.black),
        textAlign: TextAlign.center,
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: onTapOne,
            child:
                Icon(Icons.camera_alt, size: 40, color: Colors.grey.shade700),
          ),
          const SizedBox(
            width: 30,
          ),
          InkWell(
            onTap: onTapTwo,
            child: Icon(Icons.photo_library_rounded,
                size: 40, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
