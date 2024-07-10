import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spring_space/screens/certificates_screen.dart';
import 'package:spring_space/screens/home_screen.dart';
import 'package:spring_space/screens/create_post_screen.dart';
import 'package:spring_space/screens/courses_screen.dart';
import 'package:provider/provider.dart';
import 'package:spring_space/models/user.dart' as model;
import 'package:spring_space/providers/user_providers.dart';
import 'package:spring_space/util/colors.dart';
import 'package:spring_space/util/utils.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<String> _departments = [];

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('departments').get();
      List<String> departments =
          snapshot.docs.map((doc) => doc['departmentName'] as String).toList();
      setState(() {
        _departments = departments;
      });
    } catch (e) {
      print('Error fetching departments: $e');
    }
  }

  Future<void> beActiveOptions(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: dialogBackgroundColor,
          children: <Widget>[
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Food'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreatePostScreen(
                            postType: 'isFood',
                          )),
                );
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Vegetable'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreatePostScreen(
                            postType: 'isVegetable',
                          )),
                );
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Whole Grains'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreatePostScreen(
                            postType: 'isWholeGrains',
                          )),
                );
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Dairy'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreatePostScreen(
                            postType: 'isDairy',
                          )),
                );
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Protein'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreatePostScreen(
                            postType: 'isProtein',
                          )),
                );
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> connectOptions(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Share Shifts'),
          backgroundColor: dialogBackgroundColor,
          children: <Widget>[
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Give Shift'),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreatePostScreen(
                            postType: 'isShareShift',
                          )),
                );
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Take Shift'),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(
                      postType: 'isShareShift',
                    ),
                  ),
                );
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> keepLearningOptions(BuildContext parentContext) async {
    model.User? user =
        Provider.of<UserProvider>(context, listen: false).getUser;
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Keep Learning'),
          backgroundColor: dialogBackgroundColor,
          children: <Widget>[
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Learn from own department'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoursesScreen(dept: user!.department),
                  ),
                );
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Learn from Cross Department'),
              onPressed: () {
                showDepartmentsList(context);
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('My certificates'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CertificatesScreen(),
                  ),
                );
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showDepartmentsList(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Department'),
          backgroundColor: dialogBackgroundColor,
          children: _departments.map((String dept) {
            return SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: Text(capitalizeWords(dept)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CoursesScreen(dept: dept)),
                );
              },
            );
          }).toList()
            ..add(
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Spring Space',
          style: TextStyle(
            fontFamily: 'AutourOne',
            fontSize: 20,
            color: Color.fromARGB(255, 1, 59, 1),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreatePostScreen(
                              postType: 'isTakeNotice',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize:
                            Size(MediaQuery.of(context).size.width * 0.35, 50),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Take Notice'),
                          SizedBox(width: 8),
                          FaIcon(FontAwesomeIcons.tree),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        beActiveOptions(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize:
                            Size(MediaQuery.of(context).size.width * 0.35, 50),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ignore: deprecated_member_use
                          FaIcon(FontAwesomeIcons.running),
                          SizedBox(width: 8),
                          Text('Be Active'),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        connectOptions(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize:
                            Size(MediaQuery.of(context).size.width * 0.35, 50),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Connect'),
                          SizedBox(width: 8),
                          FaIcon(FontAwesomeIcons.handshake),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        keepLearningOptions(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize:
                            Size(MediaQuery.of(context).size.width * 0.35, 50),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ignore: deprecated_member_use
                          FaIcon(FontAwesomeIcons.bookReader),
                          SizedBox(width: 8),
                          Text('Keep Learning'),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CreatePostScreen(
                                      postType: 'isAppreciation',
                                    )));
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize:
                            Size(MediaQuery.of(context).size.width * 0.35, 50),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Give'),
                          SizedBox(width: 8),
                          FaIcon(FontAwesomeIcons.peopleArrows),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
