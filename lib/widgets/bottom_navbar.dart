import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/profile.dart';
import '../pages/all_clients_page.dart';
import '../pages/past_workouts.dart';

class BottomNavBarView extends StatefulWidget {
  BottomNavBarView({Key? key}) : super(key: key);

  @override
  State<BottomNavBarView> createState() => _BottomNavBarViewState();
}

class _BottomNavBarViewState extends State<BottomNavBarView> {
  bool isPersonalTrainer = false;
  int currentIndex = 1; // Set an initial value (e.g., Home Page)

  @override
  void initState() {
    super.initState();
    listenForUserChanges();
  }

  void listenForUserChanges() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.email)
          .snapshots()
          .listen((DocumentSnapshot userDoc) {
        if (userDoc.exists) {
          setState(() {
            isPersonalTrainer = userDoc['isPersonalTrainer'] ?? false;

            if (isPersonalTrainer) {
              currentIndex =
                  1; // Redirect to the "All Clients" tab for trainers
            } else {
              currentIndex =
                  1; // Redirect to the "PastWorkouts" tab for non-trainers
            }
          });
        }
      });
    }
  }

  void onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  List<Widget> widgetOption() {
    List<Widget> options = [
      const HomePage(),
      const PastWorkoutsPage(),
      const ProfilePage(),
    ];

    if (isPersonalTrainer) {
      options.insert(2, const AllClientsPage());
    }

    return options;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey.shade900,
        onTap: onItemTapped,
        currentIndex: currentIndex,
        unselectedItemColor: Colors.grey.shade700,
        selectedItemColor: Colors.greenAccent.shade400,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.fitness_center_rounded,
              size: 35,
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.event_available_rounded,
              size: 35,
            ),
            label: '',
          ),
          if (isPersonalTrainer)
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.group_rounded,
                size: 35,
              ),
              label: '',
            ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
              size: 35,
            ),
            label: '',
          ),
        ],
      ),
      body: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: widgetOption()[currentIndex]),
    );
  }
}
