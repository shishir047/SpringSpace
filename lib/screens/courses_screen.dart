import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:spring_space/models/user.dart' as model;
import 'package:spring_space/providers/user_providers.dart';
import 'package:spring_space/util/utils.dart';

class CoursesScreen extends StatefulWidget {
  final dept;
  const CoursesScreen({super.key, required this.dept});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  Widget build(BuildContext context) {
    model.User? user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${capitalizeWords(widget.dept)} Department',
              style:
                  const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('departments')
                  .doc(widget.dept)
                  .collection('courses')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final courses = snapshot.data!.docs;

                if (courses.isEmpty) {
                  return const Center(child: Text('No courses available.'));
                }

                return ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    final courseName = course['courseName'];
                    final users = List<String>.from(course['users']);
                    final isDone = users.contains(user!.uid);

                    return ListTile(
                      leading: isDone
                          ? const Icon(
                              Icons.check,
                              color: Colors.green,
                            )
                          : const Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                      title: Text('$courseName'),
                      trailing: ElevatedButton(
                        onPressed: isDone
                            ? null
                            : () => _markCourseAsDone(course.id, widget.dept,
                                user.uid, user.username, user.department, user.monthlyPoints, user.annualPoints),
                        child: const Text(
                          'Done',
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _markCourseAsDone(String courseId, String departmentName, String userId,
      String username, String userDepartment, int monthlyPoints, int annualPoints) async {
    try {
      await FirebaseFirestore.instance
          .collection('departments')
          .doc(departmentName)
          .collection('courses')
          .doc(courseId)
          .update({
        'users': FieldValue.arrayUnion([userId]),
      });

      await FirebaseFirestore.instance
          .collection('departments')
          .doc(departmentName)
          .update({
        'userList': FieldValue.arrayUnion([username]),
      });

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'departmentList': FieldValue.arrayUnion([departmentName]),
      });


      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      DocumentSnapshot userDoc = await userRef.get();

      int currentMonthlyPoints = userDoc['monthlyPoints'] ?? 0;
      int newMonthlyPoints = currentMonthlyPoints;

      int currentAnnualPoints = userDoc['annualPoints'] ?? 0;
      int newAnnualPoints = currentAnnualPoints;


      if(departmentName == userDepartment){
        newMonthlyPoints += 5;
        newAnnualPoints += 5;
      }else{
        newMonthlyPoints += 10;
        newAnnualPoints += 10;
      }

      await userRef.update({'monthlyPoints': newMonthlyPoints, 'annualPoints': newAnnualPoints});


    } catch (e) {
      if (kDebugMode) {
        print('Error adding user: $e');
      }
    }
  }
}
