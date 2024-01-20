import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as Path;
import '../widgets/bottom_navbar.dart';

class DataController extends GetxController {
// Variables
  var allUsers = <DocumentSnapshot>[].obs;
  var filteredUsers = <DocumentSnapshot>[].obs;

// Firebase Auth Instance
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

// Current User Instance
  final currentUser = FirebaseAuth.instance.currentUser!;

// Latest Snapshot of the Firestore Document called myDocument
  DocumentSnapshot? myDocument;

// Declares a Nullable Variable Called "_subscription" -> Manages Subscription to Doc Changes
  StreamSubscription<DocumentSnapshot>? _subscription;

// Main Function That Subscribes to Changes in a Firestore Document
  void getMyDocument() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final documentReference =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Sets Up a Listener for Changes in the Firestore Document Referenced by 'documentReference'
      _subscription = documentReference.snapshots().listen((event) {
        // Handle document changes and update 'myDocument'
        myDocument = event;
      }, onError: (error) {
        // Handle errors here
        print('Error fetching document: $error');
      });
    }
    // Call this method when you want to unsubscribe from the stream
    void dispose() {
      _subscription?.cancel();
    }
  }

// Listen for State Changes in Profile Information
  var isProfileInformationLoading = false.obs;

// Upload Image to Storage
  Future<String> uploadImageToFirebaseStorage(File image) async {
// Empty string to hold downloaded image URL
    String imageUrl = '';

// Extracts the file name from the image file path using the Path.basename method.
    String fileName = Path.basename(image.path);

// Create a folder in firebase storage called 'profileImages'
    var reference =
        FirebaseStorage.instance.ref().child('profileImages/$fileName');

// It initiates the upload by calling putFile(image) on the reference. This returns an UploadTask object representing the ongoing upload.
    UploadTask uploadTask = reference.putFile(image);

// It awaits the completion of the upload task using await uploadTask.whenComplete(() => null). The whenComplete callback is used to ensure that the upload is complete before proceeding.
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

    try {
// Retrieve the downloadURL
      imageUrl = await taskSnapshot.ref.getDownloadURL();
      print(imageUrl);
      // error handling
    } catch (e) {
      print(e.toString());
    }
    // return the imageURL
    return imageUrl;
  }

// Upload Profile Data
  void uploadProfileData(String imageUrl) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null && currentUser.email != null) {
      String uid = currentUser.uid;

      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.email)
          .update({
        'profilePic': imageUrl,
      }).then((_) {
        isProfileInformationLoading(false);
        Get.offAll(() => BottomNavBarView());
      }).catchError((error) {
        // Handle any errors that occur during the update operation.
        print("Error updating profile data: $error");
        // You can display an error message to the user or take appropriate action.
      });
    } else {
      // Handle the case where currentUser or currentUser.email is null.
      print("User not authenticated or email is null");
      // You can display an error message to the user or take appropriate action.
    }
  }

// Listen for Changes in Users
  var isUsersLoading = false.obs;

// Get Users
  getUsers() {
    //  It sets the isUsersLoading boolean to true, presumably to indicate that data fetching is in progress.
    isUsersLoading(true);
    // This part of the code listens to changes in the "users" collection in Firestore using snapshots. When there are changes, the provided callback is executed.
    FirebaseFirestore.instance.collection('users').snapshots().listen((event) {
      // It updates the allUsers variable with the documents received from the Firestore query.
      allUsers.value = event.docs;
      // This line appears to update the filteredUsers variable with the same data as allUsers
      filteredUsers.value.assignAll(allUsers);
      // Finally, it sets isUsersLoading back to false to indicate that the data fetching process is complete.
      isUsersLoading(false);
    });
  }

// Init State
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getMyDocument();
    getUsers();
  }
}
