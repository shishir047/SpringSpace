import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spring_space/models/user.dart' as model;
import 'package:spring_space/providers/user_providers.dart';
import 'package:spring_space/screens/message_list_screen.dart';
import 'package:spring_space/widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  final String postType;
  const HomeScreen({super.key, required this.postType});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String getCurrMonth() {
    var month = DateTime.now();
    final formatted = DateFormat('MMM').format(month);
    return formatted;
  }

  void navigateToMessage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const MessageListScreen()));
  }

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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }

            if (snapshot.hasError) {
              return const Text(
                'Error loading points',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text(
                '--',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              );
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>?;
            var monthlyPoints = userData?['monthlyPoints'] ?? 0;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.postType != 'isShareShift' ? Text(
                  '${getCurrMonth()}: $monthlyPoints pts',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ) : const Padding(padding: EdgeInsets.all(0.0)),
                const Text(
                  'Spring Space',
                  style: TextStyle(
                    fontFamily: 'AutourOne',
                    fontSize: 18,
                    color: Color.fromARGB(255, 1, 59, 1),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.message,
                  ),
                  onPressed: navigateToMessage,
                ),
              ],
            );
          },
        ),
      ),
      body: StreamBuilder(
        stream: widget.postType != 'isShareShift' 
          ? FirebaseFirestore.instance
            .collection('posts')
            .orderBy('datePublished', descending: true)
            .snapshots() 
          : 
            FirebaseFirestore.instance
            .collection('posts')
            .orderBy('datePublished', descending: true)
            .where("isShareShift", isEqualTo: true)
            .where("isTaken", isEqualTo: false)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('An error occurred while loading posts: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No posts available'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) => PostCard(
              snap: snapshot.data!.docs[index].data(),
            ),
          );
        },
      ),
    );
  }
}
