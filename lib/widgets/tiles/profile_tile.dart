import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileTile extends StatefulWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;

  const ProfileTile({
    Key? key, // Use Key to correctly identify widgets
    required this.text,
    required this.sectionName,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<ProfileTile> createState() => _ProfileTileState();
}

class _ProfileTileState extends State<ProfileTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
      // Tile
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade700, width: 2.0),
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Shadow color
              spreadRadius: 2, // How much the shadow should spread
              blurRadius: 5, // How blurry the shadow should be
              offset: const Offset(3, 3), // Changes position of shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              // Wrap the content in a Flexible widget to allow it to expand
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header of tile
                  Text(
                    widget.sectionName,
                    style: GoogleFonts.knewave(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Content of tile
                  Text(
                    widget.text,
                    style: GoogleFonts.knewave(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            // edit button
            Container(
              padding: const EdgeInsets.all(10),
              width: 40, // Limit the width of the edit button
              child: GestureDetector(
                onTap: widget.onPressed,
                child: Icon(Icons.edit, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
