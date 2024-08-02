import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spring_space/models/user.dart' as model;
import 'package:spring_space/providers/user_providers.dart';
import 'package:spring_space/resources/firestore_methods.dart';
import 'package:spring_space/screens/comment_screen.dart';
import 'package:spring_space/screens/message_screen.dart';
import 'package:spring_space/screens/profile_screen.dart';
import 'package:spring_space/util/colors.dart';
import 'package:spring_space/util/utils.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> snap;

  const PostCard({
    super.key,
    required this.snap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  double _imageWidth = 0;
  double _imageHeight = 0;
  bool _isLoading = true;
  int commentLen = 0;
  bool isTakeNotice = false;
  bool isFood = false;
  bool isVegetable = false;
  bool isWholeGrains = false;
  bool isDairy = false;
  bool isProtein = false;
  bool isAppreciation = false;
  bool isShareShift = false;
  bool isTaken = false;

  @override
  void initState() {
    super.initState();
    _postType();
    _fetchImageDimensions(widget.snap['postUrl']);
    _fetchCommentLen();
  }

  void _postType() {
    setState(() {
      isTakeNotice = widget.snap['isTakeNotice'] ?? false;
      isFood = widget.snap['isFood'] ?? false;
      isVegetable = widget.snap['isVegetable'] ?? false;
      isWholeGrains = widget.snap['isWholeGrains'] ?? false;
      isDairy = widget.snap['isDairy'] ?? false;
      isProtein = widget.snap['isProtein'] ?? false;
      isAppreciation = widget.snap['isAppreciation'] ?? false;
      isShareShift = widget.snap['isShareShift'] ?? false;
      isTaken = widget.snap['isTaken'] ?? false;
    });
  }

  Future<void> _fetchImageDimensions(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final image = Image.network(imagePath);
      image.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
          if (mounted) {
            setState(() {
              _imageWidth = info.image.width.toDouble();
              _imageHeight = info.image.height.toDouble();
              _isLoading = false;
            });
          }
        }),
      );
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCommentLen() async {
    try {
      QuerySnapshot commentsnap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      if (mounted) {
        setState(() {
          commentLen = commentsnap.docs.length;
        });
      }
    } catch (err) {
      showSnackBar(
        err.toString(),
        // ignore: use_build_context_synchronously
        context,
      );
    }
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
        'seenBy': [currentUserId],
      });
      chatId = newChat.id;
    }

    return chatId;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkDept(String otherUserUid, String uid) async {
    DocumentSnapshot otherUserSnapshot =
        await _firestore.collection('users').doc(otherUserUid).get();
    String otherUserDepartment = otherUserSnapshot['department'];

    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(uid).get();
    List departmentList = List.from(userSnapshot['departmentList']);

    return departmentList.contains(otherUserDepartment);
  }

  @override
  Widget build(BuildContext context) {
    model.User? user = Provider.of<UserProvider>(context).getUser;

    return Container(
      color: const Color.fromARGB(255, 255, 255, 255),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        uid: widget.snap['uid'],
                      ),
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: customGreen[300],
                    backgroundImage: NetworkImage(
                      widget.snap['profImage'] ??
                          'https://via.placeholder.com/150', // Default placeholder
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        uid: widget.snap['uid'],
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.snap['username'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isTakeNotice
                            ? widget.snap['emoji'] != ''
                                ? Text(
                                    ' is feeling ${widget.snap['emoji']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12),
                                  )
                                : const Text('')
                            : isFood
                                ? const Text(
                                    ' is having Food',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12),
                                  )
                                : isVegetable
                                    ? const Text(
                                        ' is having Vegetable',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12),
                                      )
                                    : isWholeGrains
                                        ? const Text(
                                            ' is having Whole Grains',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12),
                                          )
                                        : isDairy
                                            ? const Text(
                                                ' is having Dairy',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12),
                                              )
                                            : isProtein
                                                ? const Text(
                                                    ' is having Protein',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 12),
                                                  )
                                                : isShareShift
                                                    ? const Text(
                                                        ' is giving shift',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 12),
                                                      )
                                                    : isAppreciation
                                                        ? Row(
                                                            children: [
                                                              const Text(
                                                                ' is appreciating ',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              InkWell(
                                                                onTap: () =>
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ProfileScreen(
                                                                      uid: widget
                                                                              .snap[
                                                                          'appreciatingUserUid'],
                                                                    ),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  ' ${widget.snap['appreciatingUsername'] ?? ''} ',
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : const Text(' '),
                      ],
                    ),
                  ),
                ),
                widget.snap['uid'] == user!.uid &&
                        !isAppreciation &&
                        !isShareShift
                    ? IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: dialogBackgroundColor,
                              child: ListView(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shrinkWrap: true,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      await FireStoreMethods()
                                          .deletePost(widget.snap['postId']);
                                      // ignore: use_build_context_synchronously
                                      Navigator.of(context).pop();
                                      setState(() {});
                                    },
                                    child: const Center(
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: customGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.more_vert),
                      )
                    : const Padding(padding: EdgeInsets.all(0)),
              ],
            ),
          ),

          // Image Section
          MediaQuery.of(context).size.width < 600
              ? _isLoading
                  ? SizedBox(
                      height: MediaQuery.of(context).size.width,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: customGreen,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: MediaQuery.of(context).size.width *
                          (_imageHeight / _imageWidth),
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                  !isAppreciation
                                      ? widget.snap['postUrl'] ??
                                          'https://via.placeholder.com/600' // Default placeholder
                                      : 'https://firebasestorage.googleapis.com/v0/b/springspace-firebase.appspot.com/o/AppreciationBadge.jpg?alt=media&token=2f09a339-0a56-4ea3-804a-25cdd62174ad',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (isAppreciation)
                            Padding(
                              padding: const EdgeInsets.only(top: 110.0),
                              child: Center(
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: customGreen[300],
                                  backgroundImage: NetworkImage(
                                    widget.snap['appreciatingProfImage'] ??
                                        'https://via.placeholder.com/150', // Default placeholder
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
              : _isLoading
                  ? SizedBox(
                      height: MediaQuery.of(context).size.width * 0.35,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: customGreen,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: MediaQuery.of(context).size.width *
                          0.6 *
                          (_imageHeight / _imageWidth),
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                              !isAppreciation
                                  ? widget.snap['postUrl'] ??
                                      'https://via.placeholder.com/600' // Default placeholder
                                  : 'assets/appreciationBadge.jpg',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
          if (isShareShift)
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 10.0),
                  height: 40.0,
                  child: !isTaken
                      ? Text(
                          'Available on Date: ${widget.snap['availableDate']} from ${widget.snap['availableTimeFrom']} to ${widget.snap['availableTimeTo']}. ',
                          style: const TextStyle(
                              fontSize: 12.0, fontWeight: FontWeight.w400),
                        )
                      : Text(
                          'Not Available on Date: ${widget.snap['availableDate']} from ${widget.snap['availableTimeFrom']} to ${widget.snap['availableTimeTo']}. ',
                          style: const TextStyle(
                              fontSize: 12.0, fontWeight: FontWeight.w400),
                        ),
                ),
                isTaken
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(0.0),
                            height: 30.0,
                            child: const Text(
                              'Shift Taken by :',
                              style: TextStyle(
                                  fontSize: 15.0, fontWeight: FontWeight.w400),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                  uid: widget.snap['takenByUid'],
                                ),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(0.0),
                              height: 30.0,
                              child: Text(
                                ' ${widget.snap['takenBy']}',
                                style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Padding(padding: EdgeInsets.all(0.0)),
              ],
            ),
          if (isShareShift)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: isTaken || widget.snap['uid'] == user.uid
                      ? null
                      : () async {
                          bool canTakeShift =
                              await checkDept(widget.snap['uid'], user.uid);
                          if (!canTakeShift) {
                            showDialog(
                              // ignore: use_build_context_synchronously
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: const Text('Error'),
                                  content: const Text(
                                      'You are not allowed to take this shift.'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            await FireStoreMethods().takeShift(
                                user.username, widget.snap['postId'], user.uid);

                            DocumentReference takenUserRef = FirebaseFirestore
                                .instance
                                .collection('users')
                                .doc(user.uid);
                            DocumentSnapshot takenUserDoc =
                                await takenUserRef.get();

                            int currentMonthlyPointsTakenUser =
                                takenUserDoc['monthlyPoints'] ?? 0;
                            int newMonthlyPointsTakenUser =
                                currentMonthlyPointsTakenUser;

                            int currentAnnualPointsTakenUser =
                                takenUserDoc['annualPoints'] ?? 0;
                            int newAnnualPointsTakenUser =
                                currentAnnualPointsTakenUser;

                            newMonthlyPointsTakenUser += 10;
                            newAnnualPointsTakenUser += 10;

                            await takenUserRef.update({
                              'monthlyPoints': newMonthlyPointsTakenUser,
                              'annualPoints': newAnnualPointsTakenUser
                            });

                            DocumentReference givenUserRef = FirebaseFirestore
                                .instance
                                .collection('users')
                                .doc(widget.snap['uid']);
                            DocumentSnapshot givenUserDoc =
                                await givenUserRef.get();

                            int currentMonthlyPointsGivenUser =
                                givenUserDoc['monthlyPoints'] ?? 0;
                            int newMonthlyPointsGivenUser =
                                currentMonthlyPointsGivenUser;

                            int currentAnnualPointsGivenUser =
                                givenUserDoc['annualPoints'] ?? 0;
                            int newAnnualPointsGivenUser =
                                currentAnnualPointsGivenUser;

                            newMonthlyPointsGivenUser += 5;
                            newAnnualPointsGivenUser += 5;

                            await givenUserRef.update({
                              'monthlyPoints': newMonthlyPointsGivenUser,
                              'annualPoints': newAnnualPointsGivenUser
                            });
                            setState(() {
                              isTaken = true;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: customGreen[100]),
                  child: const Text('Take Shift'),
                ),
                ElevatedButton(
                  onPressed: widget.snap['uid'] == user.uid || isTaken
                      ? null
                      : () async {
                          String chatId =
                              await getOrCreateChatId(widget.snap['uid']);
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MessageScreen(
                                    chatId: chatId,
                                    otherUserId: widget.snap['uid'],
                                    otherUsername: widget.snap['username']),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: customGreen[100]),
                  child: const Text('Message'),
                ),
              ],
            ),

          // Like and Comment Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        Text(widget.snap['likes'].length.toString(),
                            style: TextStyle(color: customGreen[800])),
                        IconButton(
                          onPressed: () async {
                            await FireStoreMethods().likePost(
                                widget.snap['postId'],
                                user.uid,
                                widget.snap['likes']);
                            setState(() {});
                          },
                          icon: widget.snap['likes'].contains(user.uid)
                              ? Icon(
                                  Icons.thumb_up,
                                  color: customGreen[900],
                                )
                              : Icon(
                                  Icons.thumb_up_outlined,
                                  color: customGreen[300],
                                ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        Text('$commentLen',
                            style: TextStyle(color: customGreen[800])),
                        IconButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CommentsScreen(
                                postId: widget.snap['postId'].toString(),
                              ),
                            ),
                          ),
                          icon: Icon(
                            Icons.comment,
                            color: customGreen[300],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                child: Text(
                  DateFormat.yMMMd()
                      .format(widget.snap['datePublished'].toDate()),
                  style: TextStyle(
                    fontSize: 14,
                    color: customGreen[800],
                  ),
                ),
              ),
            ],
          ),

          // Description
          widget.snap['description'] != null && widget.snap['description'] != ''
              ? Container(
                  padding: const EdgeInsets.only(left: 10, right: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: customGreen),
                            children: [
                              TextSpan(
                                text: widget.snap['username'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ProfileScreen(
                                            uid: widget.snap['uid'],
                                          ),
                                        ),
                                      ),
                              ),
                              TextSpan(
                                text: ' ${widget.snap['description']}',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const Padding(padding: EdgeInsets.all(0)),
        ],
      ),
    );
  }
}
