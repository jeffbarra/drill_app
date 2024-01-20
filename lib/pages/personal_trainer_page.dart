import 'package:drill_app/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalTrainerPage extends StatefulWidget {
  const PersonalTrainerPage({Key? key}) : super(key: key);

  @override
  State<PersonalTrainerPage> createState() => _PersonalTrainerPageState();
}

class _PersonalTrainerPageState extends State<PersonalTrainerPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  String? _personalTrainer = "Loading...";
  String? _profilePicUrl;
  String? _fullName;
  String? _bio;
  bool _hasUnreadMessages = false;
  int _unreadMessageCount = 0;
  bool _isLoading = true; // Flag to control loading indicator

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _fetchUserData().then((_) {
        // Simulate a 1-second delay using Future.delayed
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _isLoading = false;
          });
        });
      });
    }
  }

  // Fetch User Data
  Future<void> _fetchUserData() async {
    try {
      final DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(_currentUser!.email).get();
      final personalTrainer = userSnapshot['personalTrainer'];

      if (personalTrainer != null) {
        final personalTrainerSnapshot =
            await _firestore.collection('users').doc(personalTrainer).get();
        final profilePicUrl = personalTrainerSnapshot['profilePic'];
        final fullName = personalTrainerSnapshot['fullName'];
        final bio = personalTrainerSnapshot['bio'];

        setState(() {
          _personalTrainer = personalTrainer ?? "No personal trainer found";
          _profilePicUrl = profilePicUrl;
          _fullName = fullName;
          _bio = bio;
        });

        final unreadMessagesQuery = await _firestore
            .collection('messages')
            .where('receiver', isEqualTo: _currentUser!.email)
            .where('receiverRead', isEqualTo: false)
            .get();

        setState(() {
          _unreadMessageCount = unreadMessagesQuery.docs.length;
          _hasUnreadMessages = _unreadMessageCount > 0;
        });
      } else {
        setState(() {
          _personalTrainer = "No personal trainer found";
          _profilePicUrl = null;
          _fullName = null;
          _bio = null;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _personalTrainer = "Error fetching data";
        _profilePicUrl = null;
        _fullName = null;
        _bio = null;
      });
    }
  }

  // Mark Messages as Read
  Future<void> _markMessagesAsRead(String senderEmail) async {
    try {
      final querySnapshot = await _firestore
          .collection('messages')
          .where('sender', isEqualTo: senderEmail)
          .where('receiver', isEqualTo: _currentUser!.email)
          .where('receiverRead', isEqualTo: false)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.update({'receiverRead': true});
      }
    } catch (e) {
      print("Error marking messages as read: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,

      // App Bar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade900,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            'Your Trainer',
            style: GoogleFonts.knewave(
                fontSize: 20, color: Colors.greenAccent.shade400),
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            backgroundColor: Colors.greenAccent.shade400,
            onPressed: () async {
              await _markMessagesAsRead(_personalTrainer!);
              setState(() {
                _hasUnreadMessages = false;
                _unreadMessageCount =
                    0; // Mark messages as read and reset the count
              });
              Get.to(() => ChatPage(specificUserEmail: _personalTrainer!),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 500));
            },
            child: const Icon(Icons.chat_rounded, color: Colors.black),
          ),

          // Red Tag Notifier
          if (_hasUnreadMessages)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: Center(
                  child: Text(
                    _unreadMessageCount.toString(), // Display the count
                    style: GoogleFonts.knewave(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),

      // Body
      body: _isLoading
          ? Center(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Icon(Icons.fitness_center_rounded,
                      color: Colors.greenAccent.shade400, size: 30),
                  Container(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      color: Colors.greenAccent.shade400,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Center(
                child: Column(
                  children: [
                    // Display the profile picture if available
                    _profilePicUrl != null && _profilePicUrl!.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.greenAccent.shade400, width: 2),
                              borderRadius: BorderRadius.circular(70),
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundImage: NetworkImage(_profilePicUrl!),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.greenAccent.shade400, width: 2),
                              borderRadius: BorderRadius.circular(70),
                            ),
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                              ),
                              child:
                                  Image.asset('lib/assets/images/avatar.png'),
                            ),
                          ),

                    const SizedBox(height: 20),

                    // Display the full name if available
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: Container(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          border: Border.all(
                              color: Colors.grey.shade700, width: 2.0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          title: Text('Name:',
                              style: GoogleFonts.knewave(
                                  color: Colors.grey.shade600, fontSize: 16)),
                          subtitle: Text(
                            _fullName != null
                                ? _fullName!
                                : "No full name found",
                            style: GoogleFonts.knewave(
                                fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: Container(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          border: Border.all(
                              color: Colors.grey.shade700, width: 2.0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          title: Text('Email:',
                              style: GoogleFonts.knewave(
                                  color: Colors.grey.shade600, fontSize: 16)),
                          subtitle: Text(
                            _personalTrainer ?? "Loading...",
                            style: GoogleFonts.knewave(
                                fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Display the personal trainer bio or an empty container if _bio is "Enter your bio here"
                    _bio != "Enter your bio here..."
                        ? Padding(
                            padding: const EdgeInsets.only(left: 30, right: 30),
                            child: Container(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                border: Border.all(
                                    color: Colors.grey.shade700, width: 2.0),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                title: Text('Bio:',
                                    style: GoogleFonts.knewave(
                                        color: Colors.grey.shade600,
                                        fontSize: 16)),
                                subtitle: Text(
                                  _bio ?? "Loading...",
                                  style: GoogleFonts.knewave(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
    );
  }
}
