import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final String email;
  final String username;
  final String department;
  final String uid;
  final String photoUrl;
  final int monthlyPoints;
  final int annualPoints;
  final bool isfirstUpload;
  final lastPostTakeNoticeDate;
  final lastPostBeActiveDate;
  final int consecutiveTakeNoticeDays;
  final lastConsecutiveTakeNoticeDate;
  final int appreciationUpdateCount;
  final String lastAppreciationUpdateDate;
  // ignore: prefer_typing_uninitialized_variables
  final departmentList;

  const User(
      {required this.name,
      required this.email,
      required this.username,
      required this.department,
      required this.departmentList,
      required this.uid,
      required this.photoUrl,
      required this.monthlyPoints,
      required this.annualPoints,
      required this.isfirstUpload,
      required this.lastPostTakeNoticeDate,
      required this.lastPostBeActiveDate,
      required this.consecutiveTakeNoticeDays,
      required this.lastConsecutiveTakeNoticeDate,
      required this.appreciationUpdateCount,
      required this.lastAppreciationUpdateDate,});

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      name: snapshot["name"],
      email: snapshot["email"],
      username: snapshot["username"],
      department: snapshot["department"],
      uid: snapshot["uid"],
      photoUrl: snapshot["photoUrl"],
      monthlyPoints: snapshot["monthlyPoints"],
      annualPoints: snapshot["annualPoints"], 
      departmentList: snapshot["departmentList"],
      isfirstUpload: snapshot["isfirstUpload"],
      lastPostTakeNoticeDate: snapshot["lastPostTakeNoticeDate"],
      lastPostBeActiveDate: snapshot["lastPostBeActiveDate"],
      consecutiveTakeNoticeDays: snapshot["consecutiveTakeNoticeDays"],
      lastConsecutiveTakeNoticeDate: snapshot["lastConsecutiveTakeNoticeDate"],
      appreciationUpdateCount: snapshot["appreciationUpdateCount"],
      lastAppreciationUpdateDate: snapshot["lastAppreciationUpdateDate"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "username": username,
        "department": department,
        "uid": uid,
        "photoUrl": photoUrl,
        "monthlyPoints": monthlyPoints,
        "annualPoints": annualPoints,
        "departmentList": departmentList,
        "isfirstUpload": isfirstUpload,
        "lastPostTakeNoticeDate": lastPostTakeNoticeDate,
        "lastPostBeActiveDate": lastPostBeActiveDate,
        "consecutiveTakeNoticeDays": consecutiveTakeNoticeDays,
        "lastConsecutiveTakeNoticeDate": lastConsecutiveTakeNoticeDate,
        "appreciationUpdateCount": appreciationUpdateCount,
        "lastAppreciationUpdateDate": lastAppreciationUpdateDate,
      };
}