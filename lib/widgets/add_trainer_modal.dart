import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class TrainerAddModalBottomSheet extends StatefulWidget {
  @override
  State<TrainerAddModalBottomSheet> createState() =>
      _TrainerAddModalBottomSheetState();
}

class _TrainerAddModalBottomSheetState
    extends State<TrainerAddModalBottomSheet> {
  final TextEditingController searchQueryController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  List<DocumentSnapshot>? searchResults;
  bool isSearching = false;

  Future<void> performSearch() async {
    final query = searchQueryController.text;

    if (query.isNotEmpty) {
      setState(() {
        isSearching = true;
      });

      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: query)
          .where('isPersonalTrainer', isEqualTo: true)
          .get();

      setState(() {
        searchResults = querySnapshot.docs;
        isSearching = false;
      });
    } else {
      setState(() {
        searchResults = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Add a Personal Trainer',
                style: GoogleFonts.knewave(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
          child: TextField(
            autofocus: true,
            controller: searchQueryController,
            cursorColor: Colors.grey,
            style: GoogleFonts.knewave(color: Colors.white),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                borderRadius: BorderRadius.circular(20),
              ),
              hintText: 'Search by email',
              hintStyle: GoogleFonts.knewave(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.shade700,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              // Add the clear (x) icon at the end of the field
              suffixIcon: IconButton(
                onPressed: () {
                  // Clear the search field
                  searchQueryController.clear();
                },
                icon: const Icon(Icons.clear, color: Colors.grey),
              ),
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent.shade400,
          ),
          onPressed: isSearching ? null : performSearch,
          child: Text(
            'Search',
            style: GoogleFonts.knewave(color: Colors.black),
          ),
        ),
        if (isSearching)
          CircularProgressIndicator(
            color: Colors.greenAccent.shade400,
          ),
        if (searchResults != null && searchResults!.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No trainers found',
              style: GoogleFonts.knewave(color: Colors.white),
            ),
          ),
        if (searchResults != null && searchResults!.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: searchResults!.length,
              itemBuilder: (context, index) {
                final result = searchResults![index];
                return Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
                  child: ListTile(
                    title: Text(
                      result['fullName'] ?? 'No Name',
                      style: GoogleFonts.knewave(color: Colors.white),
                    ),
                    subtitle: Text(
                      result['username'] ?? 'No Username',
                      style: GoogleFonts.knewave(color: Colors.white),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade400,
                      ),
                      onPressed: () {
                        Navigator.pop(context);

                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: ((context) => AlertDialog(
                                title: Text(
                                  'Enter Special Code',
                                  style:
                                      GoogleFonts.knewave(color: Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                                content: TextFormField(
                                  autofocus: true,
                                  controller: codeController,
                                  keyboardType: TextInputType.number,
                                  cursorColor: Colors.black,
                                  style: GoogleFonts.knewave(
                                      color: Colors.grey.shade700),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10),
                                    fillColor: Colors.white,
                                    filled: true,
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 2.0),
                                    ),
                                    hintText: "Enter Code",
                                    hintStyle: GoogleFonts.knewave(
                                        color: Colors.grey.shade500),
                                  ),
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 15.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.greenAccent.shade400,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: GoogleFonts.knewave(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 15.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.greenAccent.shade400,
                                          ),
                                          onPressed: () async {
                                            Navigator.of(context).pop();

                                            // personal trainer code check
                                            final enteredCode =
                                                codeController.text;

                                            if (enteredCode.isNotEmpty &&
                                                enteredCode ==
                                                    result['trainerCode']) {
                                              // Successfully added trainer snackbar
                                              showTopSnackBar(
                                                  Overlay.of(context),
                                                  CustomSnackBar.success(
                                                    icon: Icon(
                                                        Icons
                                                            .check_circle_outline_rounded,
                                                        color: Colors
                                                            .greenAccent
                                                            .shade700,
                                                        size: 120),
                                                    backgroundColor: Colors
                                                        .greenAccent.shade400,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    textStyle:
                                                        GoogleFonts.knewave(
                                                            color: Colors.black,
                                                            fontSize: 18),
                                                    message:
                                                        "Personal Trainer Added!",
                                                  ),
                                                  displayDuration:
                                                      const Duration(
                                                          milliseconds: 500));
                                              // Add the current user's email to the 'clients' field
                                              final currentUser = FirebaseAuth
                                                  .instance.currentUser;
                                              if (currentUser != null) {
                                                final searchedUserReference =
                                                    FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(result.id);

                                                final searchedUserEmail =
                                                    result['email'];

                                                await searchedUserReference
                                                    .update({
                                                  'clients':
                                                      FieldValue.arrayUnion(
                                                          [currentUser.email]),
                                                });

                                                // Update the current user's "PersonalTrainer" field with the searched user's email
                                                final currentUserReference =
                                                    FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(currentUser.email);

                                                await currentUserReference
                                                    .update({
                                                  'personalTrainer':
                                                      searchedUserEmail,
                                                });
                                              }
                                            } else {
                                              // Incorrect code snackbar
                                              showTopSnackBar(
                                                  Overlay.of(context),
                                                  CustomSnackBar.success(
                                                    icon: Icon(
                                                        Icons
                                                            .error_outline_rounded,
                                                        color:
                                                            Colors.red.shade600,
                                                        size: 120),
                                                    backgroundColor:
                                                        Colors.red.shade400,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    textStyle:
                                                        GoogleFonts.knewave(
                                                            color: Colors.white,
                                                            fontSize: 18),
                                                    message:
                                                        "Incorrect Code...Please Try Again!",
                                                  ),
                                                  displayDuration:
                                                      const Duration(
                                                          milliseconds: 500));
                                            }
                                          },
                                          child: Text(
                                            'Add',
                                            style: GoogleFonts.knewave(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )),
                        );
                      },
                      child: Text(
                        'Add',
                        style: GoogleFonts.knewave(color: Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
