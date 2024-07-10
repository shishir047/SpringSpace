import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spring_space/providers/user_providers.dart';
import 'package:spring_space/screens/message_screen.dart';
import 'package:spring_space/models/user.dart' as model;

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  @override
  Widget build(BuildContext context) {
    model.User? user = Provider.of<UserProvider>(context).getUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: user.uid)
            .where('lastMessage', isNotEqualTo: "")
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center();
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No messages yet.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var chat = snapshot.data!.docs[index];
              var lastMessage = chat['lastMessage'];
              var lastMessageTime = chat['lastMessageTime'].toDate();
              var otherUserIds =
                  chat['users'].where((uid) => uid != user.uid).toList();

              if (otherUserIds.isEmpty) {
                return const SizedBox.shrink();
              }

              var otherUserId = otherUserIds[0];
              var isNew = !chat['seenBy'].contains(user.uid);

              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder:
                    (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center();
                  }

                  if (userSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${userSnapshot.error}'),
                    );
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const Center(
                      child: Text('User data not found'),
                    );
                  }

                  var otherUser = userSnapshot.data!;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        otherUser['photoUrl'],
                      ),
                      radius: 18,
                    ),
                    title: Text(otherUser['username']),
                    subtitle: Text(lastMessage),
                    trailing: SizedBox(
                      width: 80, // Adjust the width as needed
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end, // Align to the end
                        children: [
                          Text(DateFormat('hh:mm a').format(lastMessageTime)),
                          const SizedBox(width: 10.0,),
                          if (isNew)
                            const Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 12,
                            )
                          else if(!isNew)
                            const Icon(
                              Icons.circle,
                              color: Colors.white,
                              size: 12,
                            )
                        ],
                      ),
                    ),
                    onTap: () {
                      // Mark message as seen
                      FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chat.id)
                          .update({
                        'seenBy': FieldValue.arrayUnion([user.uid])
                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MessageScreen(
                            chatId: chat.id,
                            otherUserId: otherUserId,
                            otherUsername: otherUser['username'],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
