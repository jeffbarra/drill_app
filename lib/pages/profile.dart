import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drill_app/controllers/data_controller.dart';
import 'package:drill_app/pages/personal_trainer_page.dart';
import 'package:drill_app/widgets/add_trainer_modal.dart';
import 'package:drill_app/widgets/buttons/logout_button.dart';
import 'package:drill_app/widgets/tiles/trainer_signup_tile.dart';
import 'package:drill_app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../widgets/tiles/profile_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isImagePicked = false;
  bool isNetworkImage = false;
  File? profileImage;
  late DataController? dataController;

  bool _initialLoadingCompleted = false;

  imagePickDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
              child: Text('Upload Image',
                  style: GoogleFonts.knewave(color: Colors.black))),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  final ImagePicker _picker = ImagePicker();
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    profileImage = File(image.path);
                    setState(() {});
                    Navigator.pop(context);
                  }
                },
                child: const Icon(
                  Icons.camera_alt,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                width: 30,
              ),
              InkWell(
                onTap: () async {
                  final ImagePicker _picker = ImagePicker();
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    profileImage = File(image.path);
                    setState(() {});
                    Navigator.pop(context);
                  }
                },
                child: const Icon(
                  Icons.photo_library_rounded,
                  size: 40,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCameraIcon() {
    return Positioned(
      top: 0,
      right: 0,
      child: InkWell(
        onTap: () {
          imagePickDialog();
          isImagePicked = !isImagePicked;
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            border: Border.all(color: Colors.grey.shade600, width: 2.0),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Shadow color
                spreadRadius: 2, // How much the shadow should spread
                blurRadius: 5, // How blurry the shadow should be
                offset: const Offset(3, 3), // Changes position of shadow
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    dataController = Get.put(DataController());
    try {
      profileImage = dataController!.myDocument!.get('profilePic');
    } catch (e) {
      profileImage = null;
    }
    _startInitialLoadingTimer();
  }

  void _startInitialLoadingTimer() {
    // Simulate initial loading by showing the progress indicator for 1 second.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _initialLoadingCompleted = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.transparent),
        elevation: 0,
        backgroundColor: Colors.grey.shade900,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text('Your Profile',
              style: GoogleFonts.knewave(
                  fontSize: 20, color: Colors.greenAccent.shade400)),
        ),
        actions: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'To search for & add a personal trainer, tap "Add"',
                                style: GoogleFonts.knewave(),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                'To sign up to be a personal trainer, tap "Activate"',
                                style: GoogleFonts.knewave(),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.info_outline_rounded,
                        size: 30, color: Colors.grey.shade600)),
              ),
              LogoutButton(),
            ],
          )
        ],
      ),
      body: _initialLoadingCompleted
          ? StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final hasPersonalTrainer =
                      userData.containsKey('personalTrainer') &&
                          userData['personalTrainer'] != null;

                  return ListView(
                    children: [
                      InkWell(
                        onTap: () {
                          imagePickDialog();
                          isImagePicked = !isImagePicked;
                        },
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(2),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.greenAccent.shade400,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(70),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                  0.2), // Shadow color
                                              spreadRadius:
                                                  2, // How much the shadow should spread
                                              blurRadius:
                                                  5, // How blurry the shadow should be
                                              offset: const Offset(3,
                                                  3), // Changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 55,
                                              backgroundColor:
                                                  Colors.grey.shade900,
                                              child: userData['profilePic'] ==
                                                          '' &&
                                                      profileImage == null
                                                  ? const Icon(
                                                      Icons.person_rounded,
                                                      color: Colors.white,
                                                      size: 80,
                                                    )
                                                  : isImagePicked
                                                      ? CircleAvatar(
                                                          radius: 55,
                                                          backgroundColor:
                                                              Colors.white,
                                                          backgroundImage:
                                                              FileImage(
                                                                  profileImage!),
                                                        )
                                                      : CircleAvatar(
                                                          radius: 55,
                                                          backgroundColor:
                                                              Colors.white,
                                                          backgroundImage:
                                                              NetworkImage(userData[
                                                                  'profilePic']),
                                                        ),
                                            ),
                                            buildCameraIcon(), // Place the camera icon here
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentUser.email!,
                            style: GoogleFonts.knewave(
                                fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ProfileTile(
                        text: userData['username'],
                        sectionName: 'Username',
                        onPressed: () => editField(context, 'username'),
                      ),
                      const SizedBox(height: 10),
                      ProfileTile(
                        text: userData['bio'],
                        sectionName: 'Bio',
                        onPressed: () => editField(context, 'bio'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Settings',
                            style: GoogleFonts.knewave(
                                color: Colors.greenAccent.shade400,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 30.0, right: 30.0),
                            child: Container(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                border: Border.all(
                                    color: Colors.grey.shade700, width: 2.0),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.2), // Shadow color
                                    spreadRadius:
                                        2, // How much the shadow should spread
                                    blurRadius:
                                        5, // How blurry the shadow should be
                                    offset: const Offset(
                                        3, 3), // Changes position of shadow
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Personal Trainer',
                                            style: GoogleFonts.knewave(
                                                color: Colors.white)),
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    hasPersonalTrainer
                                                        ? Colors.greenAccent
                                                            .shade400
                                                        : Colors.grey.shade700),
                                            onPressed: () {
                                              if (hasPersonalTrainer) {
                                                Get.to(
                                                    () =>
                                                        const PersonalTrainerPage(),
                                                    transition:
                                                        Transition.rightToLeft,
                                                    duration: const Duration(
                                                        milliseconds: 500));
                                              } else {
                                                showModalBottomSheet(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0),
                                                  ),
                                                  backgroundColor:
                                                      Colors.grey.shade800,
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder:
                                                      (BuildContext context) {
                                                    return FractionallySizedBox(
                                                        heightFactor:
                                                            0.8, // Set the height factor to 80%
                                                        child:
                                                            TrainerAddModalBottomSheet());
                                                  },
                                                );
                                              }
                                            },
                                            child: Text(
                                                hasPersonalTrainer
                                                    ? 'View'
                                                    : 'Add',
                                                style: GoogleFonts.knewave(
                                                    color: hasPersonalTrainer
                                                        ? Colors.black
                                                        : Colors.white))),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Padding(
                            padding: EdgeInsets.only(left: 30, right: 30),
                            child: PersonalTrainerSignUpTile(),
                          ),
                          const SizedBox(height: 20.0),
                        ],
                      ),
                      Obx(
                        () => dataController!.isProfileInformationLoading.value
                            ? Center(
                                child: CircularProgressIndicator(
                                    color: Colors.greenAccent.shade400),
                              )
                            : Container(
                                height: 50,
                                margin:
                                    const EdgeInsets.only(left: 30, right: 30),
                                width: Get.width,
                                child: isImagePicked
                                    ? ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.greenAccent.shade400,
                                        ),
                                        child: Text(
                                          'Save',
                                          style: GoogleFonts.knewave(
                                              fontSize: 18,
                                              color: Colors.black),
                                        ),
                                        onPressed: () async {
                                          dataController!
                                              .isProfileInformationLoading(
                                                  true);
                                          String imageUrl =
                                              await dataController!
                                                  .uploadImageToFirebaseStorage(
                                                      profileImage!);
                                          dataController!.uploadProfileData(
                                            imageUrl,
                                          );
                                          showTopSnackBar(
                                              Overlay.of(context),
                                              CustomSnackBar.success(
                                                icon: Icon(
                                                    Icons
                                                        .check_circle_outline_rounded,
                                                    color: Colors
                                                        .greenAccent.shade700,
                                                    size: 120),
                                                backgroundColor:
                                                    Colors.greenAccent.shade400,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                textStyle: GoogleFonts.knewave(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                                message: "Profile Updated!",
                                              ),
                                              displayDuration: const Duration(
                                                  milliseconds: 500));
                                        },
                                      )
                                    : Container(),
                              ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Container();
                }
                return Center(
                  child: CircularProgressIndicator(color: Colors.grey.shade900),
                );
              },
            )
          : Center(
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
    );
  }
}
