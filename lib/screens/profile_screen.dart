import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spring_space/resources/auth_methods.dart';
import 'package:spring_space/screens/login_screen.dart';
import 'package:spring_space/screens/message_screen.dart';
import 'package:spring_space/util/colors.dart';
import 'package:spring_space/util/utils.dart';
import 'package:spring_space/widgets/message_signout_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int monthlyPoints = 0;
  int annualPoints = 0;
  bool isOtherUser = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // Check if userSnap exists
      if (userSnap.exists) {
        userData = userSnap.data()!;
        monthlyPoints = (userSnap.data()!['monthlyPoints']);
        annualPoints = (userSnap.data()!['annualPoints']);
        isOtherUser =
            userSnap.data()!['uid'] != (FirebaseAuth.instance.currentUser!.uid);
      }

      // get post length
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      postLen = postSnap.docs.length;
    } catch (e) {
      showSnackBar(
        e.toString(),
        // ignore: use_build_context_synchronously
        context,
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<String> getOrCreateChatId(String otherUserId) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    String chatId;

    var chatSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('users', arrayContains: currentUserId)
        .get();

    var chatDocs = chatSnapshot.docs.where((doc) {
      var users = doc['users'];
      return users.contains(otherUserId);
    }).toList();

    if (chatDocs.isNotEmpty) {
      chatId = chatDocs.first.id;
    } else {
      var newChat = await FirebaseFirestore.instance.collection('chats').add({
        'users': [currentUserId, otherUserId],
        'lastMessage': '',
        'lastMessageTime': DateTime.now(),
      });
      chatId = newChat.id;
    }

    return chatId;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              toolbarHeight: 32,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: customGreen[300],
                            backgroundImage: userData['photoUrl'] != null
                                ? NetworkImage(userData['photoUrl'])
                                : null,
                            radius: 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                buildStatRow(postLen, "Posts"),
                                buildStatRow(monthlyPoints, "Monthly Points"),
                                buildStatRow(annualPoints, "Annual Points"),
                                const Padding(
                                    padding: EdgeInsets.only(
                                  top: 10,
                                )),
                                isOtherUser
                                    ? MessageSignoutButton(
                                        text: 'Message',
                                        backgroundColor: customGreen,
                                        textColor: Colors.white,
                                        borderColor: customGreen,
                                        function: () async {
                                          String chatId =
                                              await getOrCreateChatId(
                                                  userData['uid']);
                                          if (context.mounted) {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MessageScreen(
                                                        chatId: chatId,
                                                        otherUserId:
                                                            userData['uid'],
                                                        otherUsername: userData[
                                                            'username']),
                                              ),
                                            );
                                          }
                                        },
                                      )
                                    : MessageSignoutButton(
                                        text: 'Sign Out',
                                        backgroundColor: Colors.white,
                                        textColor: customGreen,
                                        borderColor: Colors.grey,
                                        function: () async {
                                          await AuthMethods().signOut();
                                          if (context.mounted) {
                                            Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const LoginScreen(),
                                              ),
                                            );
                                          }
                                        },
                                      )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 15,
                        ),
                        child: Text(
                          userData['username'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 1,
                        ),
                        child: Text(
                          'Name: ${userData['name'] ?? ''}',
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 1,
                        ),
                        child: Text(
                          'Email: ${userData['email'] ?? ''}',
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 1,
                        ),
                        child: Text(
                          'Dept: ${capitalizeWords(userData['department'])}',
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .where('isAppreciation', isEqualTo: false)
                      .where('isShareShift', isEqualTo: false)
                      .orderBy('datePublished', descending: true)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 1.5,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        DocumentSnapshot snap =
                            (snapshot.data! as dynamic).docs[index];

                        return SizedBox(
                          child: Image(
                            image: NetworkImage(snap['postUrl']),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  },
                )
              ],
            ),
          );
  }

  Row buildStatRow(int num, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: customGreen,
            ),
          ),
        ),
        Text(
          ': ${num.toString()}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
