import 'package:drill_app/pages/client_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllClientsPage extends StatefulWidget {
  const AllClientsPage({Key? key}) : super(key: key);

  @override
  State<AllClientsPage> createState() => _AllClientsPageState();
}

class _AllClientsPageState extends State<AllClientsPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  Map<String, dynamic> clientData = {};
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    refreshClientData();
  }

  Future<void> refreshClientData() async {
    try {
      setState(() {
        isRefreshing = true;
      });

      // Simulate a 1-second delay
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedClientData = await fetchUpdatedClientData();

      if (mounted) {
        setState(() {
          clientData = updatedClientData;
          isRefreshing = false;
        });
      }
    } catch (e) {
      print('Error refreshing data: $e');
      if (mounted) {
        setState(() {
          isRefreshing = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> fetchUpdatedClientData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.email)
        .get();

    if (snapshot.exists) {
      final userData = snapshot.data() as Map<String, dynamic>;
      if (userData.containsKey('clients')) {
        List<dynamic> clients = userData['clients'];

        if (mounted) {
          return {
            'clients': clients,
          };
        }
      }
    }

    return {};
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
          child: Text(
            'Your Clients',
            style: GoogleFonts.knewave(
                fontSize: 20, color: Colors.greenAccent.shade400),
          ),
        ),
      ),
      body: Visibility(
        visible: !isRefreshing,
        replacement: Center(
            child: Stack(alignment: Alignment.center, children: <Widget>[
          Icon(Icons.fitness_center_rounded,
              color: Colors.greenAccent.shade400, size: 30),
          Container(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(
                  color: Colors.greenAccent.shade400)),
        ])),
        child: _buildClientList(),
      ),
    );
  }

  Widget _buildClientList() {
    if (clientData.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.grey.shade900,
        ),
      );
    }

    List<dynamic> clients = clientData['clients'];

    if (clients.isEmpty) {
      return Center(
        child: Text(
          'No clients yet',
          style: GoogleFonts.knewave(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final clientEmail = clients[index];
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(clientEmail)
              .get(),
          builder: (context, clientSnapshot) {
            if (clientSnapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(
                color: Colors.grey.shade900,
              );
            } else if (clientSnapshot.hasError) {
              return Text('Error: ${clientSnapshot.error}');
            } else if (!clientSnapshot.hasData || clientSnapshot.data == null) {
              return const Text('Client data not found.');
            } else {
              final clientData =
                  clientSnapshot.data!.data() as Map<String, dynamic>;
              if (clientData.containsKey('fullName')) {
                String fullName = clientData['fullName'];
                String profilePicUrl = clientData['profilePic'];

                return Padding(
                  padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                  child: Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      border: Border.all(
                        color: Colors.grey.shade700,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          spreadRadius: 2, // How much the shadow should spread
                          blurRadius: 5, // How blurry the shadow should be
                          offset:
                              const Offset(3, 3), // Changes position of shadow
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(
                          () => ClientPage(
                            clientName: fullName,
                            clientEmail: clientEmail,
                          ),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 500),
                        );
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: profilePicUrl != null &&
                                  profilePicUrl.isNotEmpty
                              ? NetworkImage(profilePicUrl)
                              : const AssetImage('lib/assets/images/avatar.png')
                                  as ImageProvider,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('messages')
                                .where('receiver', isEqualTo: currentUser.email)
                                .where('sender', isEqualTo: clientEmail)
                                .where('receiverRead', isEqualTo: false)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.active &&
                                  snapshot.hasData &&
                                  snapshot.data!.docs.isNotEmpty) {
                                return Stack(
                                  children: [
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                        ),
                                        child: Center(
                                          child: Text(
                                            snapshot.data!.docs.length
                                                .toString(),
                                            style: GoogleFonts.knewave(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ),
                        title: Text(
                          fullName,
                          style: GoogleFonts.knewave(
                            color: Colors.greenAccent.shade400,
                          ),
                        ),
                        subtitle: Text(
                          clientEmail,
                          style: GoogleFonts.knewave(
                            color: Colors.white,
                          ),
                        ),
                        trailing: Icon(
                          Icons.double_arrow_rounded,
                          size: 30,
                          color: Colors.greenAccent.shade400,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const Text('Client data incomplete.');
              }
            }
          },
        );
      },
    );
  }
}
