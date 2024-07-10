import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spring_space/screens/profile_screen.dart';
import 'package:spring_space/widgets/leaderboard_users_card.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  LeaderboardScreenState createState() => LeaderboardScreenState();
}

class LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leaderboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Monthly'),
              Tab(text: 'Annual'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LeaderboardList(orderByField: 'monthlyPoints', pointsField: 'monthlyPoints'),
            LeaderboardList(orderByField: 'annualPoints', pointsField: 'annualPoints'),
          ],
        ),
      ),
    );
  }
}

class LeaderboardList extends StatelessWidget {
  final String orderByField;
  final String pointsField;
  const LeaderboardList({super.key, required this.orderByField, required this.pointsField});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy(orderByField, descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: snapshot.data?.docs.length ?? 0,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            return InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    uid: doc['uid'],
                  ),
                ),
              ),
              child: LeaderboardUserCard(
                snap: doc,
                pointsField: pointsField,
              ),
            );
          },
        );
      },
    );
  }
}