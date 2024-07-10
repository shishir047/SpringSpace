import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spring_space/util/colors.dart';

class LeaderboardUserCard extends StatelessWidget {
  final DocumentSnapshot snap;
  final String pointsField;
  const LeaderboardUserCard({super.key, required this.snap, required this.pointsField});

  @override
  Widget build(BuildContext context) {
    final data = snap.data() as Map<String, dynamic>;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: customGreen[100],
            backgroundImage: NetworkImage(data['photoUrl']),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data['username'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              '${data[pointsField]} pts',
              style: const TextStyle(fontSize: 10, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
