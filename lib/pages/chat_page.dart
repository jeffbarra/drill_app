import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class ChatMessage {
  final String sender;
  final String content;
  final DateTime timestamp;

  ChatMessage(
      {required this.sender, required this.content, required this.timestamp});
}

class UserData {
  final String email;
  final String name;
  final String fullName;

  UserData({required this.email, required this.name, required this.fullName});

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      fullName: map['fullName'] ?? '',
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.specificUserEmail}) : super(key: key);

  final String specificUserEmail;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];
  UserData currentUserData = UserData(email: "", name: "", fullName: "");
  StreamSubscription<QuerySnapshot>? _messagesListener;
  String appBarTitle = 'Chat';

  ScrollController _scrollController = ScrollController();
  bool isLoading = true;
  bool isInitialLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize the ScrollController
    _scrollController = ScrollController();

    // Get Auth Instance
    final FirebaseAuth auth = FirebaseAuth.instance;

    // Get Current User
    final User? currentUser = auth.currentUser;

    if (currentUser != null) {
      _initChatData(currentUser);
    }
  }

  void _initChatData(User currentUser) {
    // Fetch current user's data
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.email)
        .get()
        .then((userDoc) {
      setState(() {
        currentUserData = UserData.fromMap(userDoc.data() ?? {});
      });

      // Fetch the name of the user you are chatting with
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.specificUserEmail)
          .get()
          .then((chattingUserDoc) {
        final chattingUserFullName = chattingUserDoc['fullName'];
        setState(() {
          appBarTitle = 'Chat with $chattingUserFullName';
        });
      });

      // Set up message listener
      _messagesListener?.cancel(); // Cancel the previous listener if it exists
      _messagesListener = FirebaseFirestore.instance
          .collection('messages')
          .orderBy('timestamp',
              descending:
                  false) // Order messages by timestamp in ascending order
          .snapshots()
          .listen((QuerySnapshot messages) {
        // Create a temporary list to store new messages
        List<ChatMessage> newMessages = [];

        for (var message in messages.docs) {
          String sender = message['sender'];
          String receiver = message['receiver'];

          if ((sender == currentUserData.email &&
                  receiver == widget.specificUserEmail) ||
              (sender == widget.specificUserEmail &&
                  receiver == currentUserData.email)) {
            newMessages.add(ChatMessage(
              sender: sender,
              content: message['content'],
              timestamp: (message['timestamp'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
            ));
          }
        }

        setState(() {
          isLoading = false;

          // Clear the existing messages and add the new messages
          _chatMessages.clear();
          _chatMessages.addAll(newMessages);

          // Scroll to the bottom of the ListView
          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            },
          );
        });
      });
    });
  }

  void _sendMessage() async {
    String message = _messageController.text;
    if (message.isEmpty) {
      return;
    }

    _messageController.clear();

    try {
      final senderDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserData.email)
          .get();
      final senderFullName = senderDoc['fullName'];

      final receiverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.specificUserEmail)
          .get();
      final receiverFullName = receiverDoc['fullName'];

      // Add the message to the "messages" collection with the "receiverRead" field set to false
      await FirebaseFirestore.instance.collection('messages').add({
        'sender': currentUserData.email,
        'receiver': widget.specificUserEmail,
        'senderFullName': senderFullName,
        'receiverFullName': receiverFullName,
        'content': message,
        'timestamp': FieldValue.serverTimestamp(),
        'receiverRead': false,
      });
    } catch (e) {
      // Handle errors, such as Firestore exceptions, here
      debugPrint('Error sending message: $e');
    }
  }

  // Format Date and Time
  String formatDateTime(DateTime dateTime) {
    return DateFormat('MM/dd/yy - hh:mm a').format(dateTime);
  }

  @override
  void dispose() {
    _messagesListener?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

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
            appBarTitle,
            style: GoogleFonts.knewave(
              fontSize: 20,
              color: Colors.greenAccent.shade400,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Visibility(
              visible: !isLoading,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: Colors.grey.shade900, width: 1.0)),
                  color: Colors.grey.shade900,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemCount: _chatMessages.length,
                  itemBuilder: (context, index) {
                    ChatMessage message = _chatMessages[index];

                    bool isCurrentUserMessage =
                        message.sender == currentUserData.email;

                    return Column(
                      crossAxisAlignment: isCurrentUserMessage
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Text(
                            formatDateTime(message.timestamp),
                            style: GoogleFonts.knewave(
                              fontSize: 12,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10),
                          child: Container(
                            alignment: isCurrentUserMessage
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isCurrentUserMessage
                                    ? Colors.greenAccent.shade400
                                    : Colors.white,
                                borderRadius: isCurrentUserMessage
                                    ? const BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        topLeft: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                      )
                                    : const BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        topLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.2), // Shadow color
                                    spreadRadius:
                                        2, // How much the shadow should spread
                                    blurRadius:
                                        5, // How blurry the shadow should be
                                    offset: const Offset(
                                        2, 2), // Changes position of shadow
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(
                                maxWidth: 200,
                              ),
                              child: Text(
                                message.content,
                                style: GoogleFonts.knewave(
                                  color: isCurrentUserMessage
                                      ? Colors.black
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Visibility(
            visible: isLoading,
            child: Center(
              child: Stack(alignment: Alignment.center, children: <Widget>[
                Icon(Icons.fitness_center_rounded,
                    color: Colors.greenAccent.shade400, size: 30),
                Container(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                        color: Colors.greenAccent.shade400))
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      width: double.maxFinite,
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        cursorColor: Colors.grey.shade400,
                        style: GoogleFonts.knewave(color: Colors.grey.shade400),
                        controller: _messageController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade700, width: 2.0),
                              borderRadius: BorderRadius.circular(30)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.greenAccent.shade400,
                              width: 2.0,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 16), // Adjust the vertical padding
                          filled: true,
                          fillColor: Colors.grey.shade800,
                          hintText: 'Type a message...',
                          hintStyle:
                              GoogleFonts.knewave(color: Colors.grey.shade400),
                        ),
                      ),
                    ),
                  ),
                ),
                // Send Message Button
                Padding(
                  padding: const EdgeInsets.only(right: 20, bottom: 8),
                  child: IconButton(
                    icon: Icon(Icons.arrow_circle_right_rounded,
                        color: Colors.greenAccent.shade400, size: 40),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
