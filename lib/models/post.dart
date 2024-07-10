import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final String postId;
  final String emoji;
  // ignore: prefer_typing_uninitialized_variables
  final datePublished;
  final String postUrl;
  final String profImage;
  // ignore: prefer_typing_uninitialized_variables
  final likes;
  // ignore: prefer_typing_uninitialized_variables
  final isTakeNotice;
  // ignore: prefer_typing_uninitialized_variables
  final isFood;
  // ignore: prefer_typing_uninitialized_variables
  final isVegetable;
  // ignore: prefer_typing_uninitialized_variables
  final isWholeGrains;
  // ignore: prefer_typing_uninitialized_variables
  final isDairy;
  // ignore: prefer_typing_uninitialized_variables
  final isProtein;
  // ignore: prefer_typing_uninitialized_variables
  final isAppreciation;
  // ignore: prefer_typing_uninitialized_variables
  final appreciatingUsername;
  // ignore: prefer_typing_uninitialized_variables
  final appreciatingUserUid;
  // ignore: prefer_typing_uninitialized_variables
  final appreciatingProfImage;
  // ignore: prefer_typing_uninitialized_variables
  final isShareShift;
  // ignore: prefer_typing_uninitialized_variables
  final availableDate;
  // ignore: prefer_typing_uninitialized_variables
  final availableTimeFrom;
  // ignore: prefer_typing_uninitialized_variables
  final availableTimeTo;
  // ignore: prefer_typing_uninitialized_variables
  final isTaken;
  // ignore: prefer_typing_uninitialized_variables
  final takenBy;
  // ignore: prefer_typing_uninitialized_variables
  final takenByUid;

  const Post({
    required this.description,
    required this.uid,
    required this.username,
    required this.emoji,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.profImage,
    required this.likes,
    required this.isTakeNotice,
    required this.isFood,
    required this.isVegetable,
    required this.isWholeGrains,
    required this.isDairy,
    required this.isProtein,
    required this.isAppreciation,
    required this.isShareShift, 
    required this.availableDate, 
    required this.availableTimeFrom, 
    required this.availableTimeTo,
    required this.appreciatingUsername,
    required this.appreciatingUserUid,
    required this.appreciatingProfImage, 
    required this.isTaken, 
    required this.takenBy, 
    required this.takenByUid,
  });

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      description: snapshot["description"],
      uid: snapshot["uid"],
      emoji: snapshot["emoji"],
      likes: snapshot["likes"],
      postId: snapshot["postId"],
      datePublished: snapshot["datePublished"],
      username: snapshot["username"],
      postUrl: snapshot['postUrl'],
      profImage: snapshot['profImage'],
      isTakeNotice: snapshot['isTakeNotice'],
      isFood: snapshot['isFood'],
      isVegetable: snapshot['isVegetable'],
      isWholeGrains: snapshot['isWholeGrains'],
      isDairy: snapshot['isDairy'],
      isProtein: snapshot['isProtein'],
      isAppreciation: snapshot['isAppreciation'],
      isShareShift: snapshot['isShareShift'], 
      availableDate: snapshot['availableDate'], 
      availableTimeFrom: snapshot['availableTimeFrom'], 
      availableTimeTo: snapshot['availableTimeTo'],
      isTaken: snapshot['isTaken'],
      takenBy: snapshot['takenBy'],
      takenByUid: snapshot['takenByUid'],
      appreciatingUsername: snapshot['appreciatingUsername'],
      appreciatingUserUid: snapshot['appreciatingUserUid'],
      appreciatingProfImage: snapshot['appreciatingProfImage'], 
    );
  }

  Map<String, dynamic> toJson() => {
        "description": description,
        "uid": uid,
        "emoji": emoji,
        "likes": likes,
        "username": username,
        "postId": postId,
        "datePublished": datePublished,
        'postUrl': postUrl,
        'profImage': profImage,
        'isTakeNotice': isTakeNotice,
        'isFood': isFood,
        'isVegetable': isVegetable,
        'isWholeGrains': isWholeGrains,
        'isDairy': isDairy,
        'isProtein': isProtein,
        'isAppreciation': isAppreciation,
        'isShareShift': isShareShift,
        'availableDate': availableDate,
        'availableTimeFrom': availableTimeFrom,
        'availableTimeTo': availableTimeTo,
        'isTaken': isTaken,
        'takenBy': takenBy,
        'takenByUid': takenByUid,
        'appreciatingUsername' : appreciatingUsername,
        'appreciatingUserUid' : appreciatingUserUid,
        'appreciatingProfImage' : appreciatingProfImage,
      };
}
