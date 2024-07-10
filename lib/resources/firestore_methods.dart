import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:spring_space/models/post.dart';
import 'package:spring_space/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isTakeNotice = false;
  bool isFood = false;
  bool isVegetable = false;
  bool isWholeGrains = false;
  bool dairy = false;
  bool protein = false;
  bool isAppreciation = false;

  //upload the post
  Future<String> uploadPost(
      String description,
      Uint8List file,
      String selectedEmoji,
      String uid,
      String username,
      String profImage,
      bool isTakeNotice,
      bool isFood,
      bool isVegetable,
      bool isWholeGrains,
      bool isDairy,
      bool isProtein,
      bool isAppreciation,
      bool isShareShift,
      String availableDate,
      String availableTimeFrom,
      String availableTimeTo,
      String appreciatingUsername,
      String appreciatingUserUid,
      String appreciatingProfImage) async {
    String res = "Some error occurred";
    try {
      String photoUrl = isAppreciation
          ? 'https://firebasestorage.googleapis.com/v0/b/springspace-firebase.appspot.com/o/AppreciationBadge.jpg?alt=media&token=2f09a339-0a56-4ea3-804a-25cdd62174ad'
          : isShareShift
              ? 'https://firebasestorage.googleapis.com/v0/b/springspace-firebase.appspot.com/o/SharingShifts.jpg?alt=media&token=cf77f0cc-a692-450b-a793-520d0fe7ab08'
              : await StorageMethods()
                  .uploadImageToStorage('posts', file, true);
      String postId = const Uuid().v1();
      Post post = Post(
        description: description,
        uid: uid,
        emoji: selectedEmoji,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        isTakeNotice: isTakeNotice,
        isFood: isFood,
        isVegetable: isVegetable,
        isWholeGrains: isWholeGrains,
        isDairy: isDairy,
        isProtein: isProtein,
        isAppreciation: isAppreciation,
        isShareShift: isShareShift,
        isTaken: false,
        takenBy: "",
        takenByUid: "",
        availableDate: availableDate,
        availableTimeFrom: availableTimeFrom,
        availableTimeTo: availableTimeTo,
        appreciatingUsername: appreciatingUsername,
        appreciatingUserUid: appreciatingUserUid,
        appreciatingProfImage: appreciatingProfImage,
      );
      _firestore.collection('posts').doc(postId).set(post.toJson());

      await _updatePoints(
          uid,
          isTakeNotice,
          isFood,
          isVegetable,
          isWholeGrains,
          isDairy,
          isProtein,
          isShareShift,
          isAppreciation,
          appreciatingUserUid);

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> _updatePoints(
    String uid,
    bool isTakeNotice,
    bool isFood,
    bool isVegetable,
    bool isWholeGrains,
    bool isDairy,
    bool isProtein,
    bool isShareShift,
    bool isAppreciation,
    String appreciatingUserUid,
  ) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(uid);
      DocumentSnapshot userDoc = await userRef.get();

      int currentMonthlyPoints = userDoc['monthlyPoints'] ?? 0;
      int newMonthlyPoints = currentMonthlyPoints;

      int currentAnnualPoints = userDoc['annualPoints'] ?? 0;
      int newAnnualPoints = currentAnnualPoints;

      DateTime now = DateTime.now();
      String today = DateTime(now.year, now.month, now.day).toString();

      if (userDoc['isfirstUpload'] == true) {
        newMonthlyPoints += 3;
        newAnnualPoints += 3;

        userRef.update({
          'isfirstUpload': false,
        });
      }

      if (isTakeNotice) {
        if (userDoc['lastPostTakeNoticeDate'] != today ||
            userDoc['lastPostTakeNoticeDate'] == null) {
          newMonthlyPoints += 1;
          newAnnualPoints += 1;

          await userRef.update({
            'lastPostTakeNoticeDate': today,
          });
        }

        if (userDoc['consecutiveTakeNoticeDays'] != null &&
            userDoc['lastConsecutiveTakeNoticeDate'] != null) {
          DateTime lastConsecutiveDate =
              (userDoc['lastConsecutiveTakeNoticeDate'] as Timestamp).toDate();
          int consecutiveDays = userDoc['consecutiveTakeNoticeDays'];

          if (lastConsecutiveDate.add(const Duration(days: 1)).toString() ==
              today) {
            consecutiveDays += 1;
            if (consecutiveDays == 5) {
              newMonthlyPoints += 2;
              newAnnualPoints += 2;
            }
          } else {
            consecutiveDays = 1;
          }

          await userRef.update({
            'consecutiveTakeNoticeDays': consecutiveDays,
            'lastConsecutiveTakeNoticeDate': today,
          });
        } else {
          await userRef.update({
            'consecutiveTakeNoticeDays': 1,
            'lastConsecutiveTakeNoticeDate': today,
          });
        }
      }

      if (isFood || isVegetable || isWholeGrains || isDairy || isProtein) {
        if (userDoc['lastPostBeActiveDate'] != today ||
            userDoc['lastPostBeActiveDate'] == null) {
          newMonthlyPoints += 2;
          newAnnualPoints += 2;

          await userRef.update({
            'lastPostBeActiveDate': today,
          });
        }
      }

      if (isAppreciation) {
        int appreciationUpdateCount = userDoc['appreciationUpdateCount'] ?? 0;
        String lastAppreciationUpdateDate =
            userDoc['lastAppreciationUpdateDate'] ?? "";

        if (lastAppreciationUpdateDate != today) {
          appreciationUpdateCount = 0;
          lastAppreciationUpdateDate = today;
        }

        if (appreciationUpdateCount < 2) {
          newMonthlyPoints += 1;
          newAnnualPoints += 1;
          appreciationUpdateCount += 1;

          DocumentReference otherUserRef =
              _firestore.collection('users').doc(appreciatingUserUid);
          DocumentSnapshot otherUserDoc = await otherUserRef.get();

          int currentMonthlyPointsOtherUser =
              otherUserDoc['monthlyPoints'] ?? 0;
          int newMonthlyPointsOtherUser = currentMonthlyPointsOtherUser;

          int currentAnnualPointsOtherUser = otherUserDoc['annualPoints'] ?? 0;
          int newAnnualPointsOtherUser = currentAnnualPointsOtherUser;

          newMonthlyPointsOtherUser += 3;
          newAnnualPointsOtherUser += 3;

          await otherUserRef.update({
            'monthlyPoints': newMonthlyPointsOtherUser,
            'annualPoints': newAnnualPointsOtherUser,
          });

          await userRef.update({
            'appreciationUpdateCount': appreciationUpdateCount,
            'lastAppreciationUpdateDate': lastAppreciationUpdateDate,
          });
        }
      }

      await userRef.update({
        'monthlyPoints': newMonthlyPoints,
        'annualPoints': newAnnualPoints,
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error updating points: $e");
      }
    }
  }

  //like the post
  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
        if (kDebugMode) {
          print("Removed like from post: $postId by user: $uid");
        }
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
        if (kDebugMode) {
          print("Added like to post: $postId by user: $uid");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating likes: $e");
      }
    }
  }

  // Post comment
  Future<String> postComment(String postId, String text, String uid,
      String username, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'username': username,
          'uid': uid,
          'text': text,
          'postId': postId,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // deleting the post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // delete the comment
  void deleteComment(String postId, String commentId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting comment: $e");
      }
    }
  }

  Future<void> takeShift(String username, String postId, String uid) async {
    await _firestore.collection('posts').doc(postId).update({
      'isTaken': true,
    });
    await _firestore.collection('posts').doc(postId).update({
      'takenBy': username,
    });
    await _firestore.collection('posts').doc(postId).update({
      'takenByUid': uid,
    });
  }

  // Send Appreciation
  Future<void> sendAppreciation(
      String uid, String username, String message) async {
    try {
      await _firestore.collection('posts').add({
        'uid': uid,
        'username': username,
        'message': message,
        'isAppreciation': true,
        'datePublished': DateTime.now(),
      });
    } catch (err) {
      if (kDebugMode) {
        print(err.toString());
      }
    }
  }
}
