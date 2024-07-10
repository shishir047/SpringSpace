import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spring_space/models/user.dart' as model;
import 'package:spring_space/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  

  Future<String> signupUser({
    required String name,
    required String email,
    required String password,
    required String username,
    required String department,
    required Uint8List dp,
  }) async {
    String res = "some error occured";
    try {
      if (name.isNotEmpty ||
          email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          department.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePicture', dp, false);

        model.User user = model.User(
          name: name,
          email: email,
          username: username,
          department: department,
          departmentList: [],
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          monthlyPoints: 0,
          annualPoints: 0,
          isfirstUpload: true, 
          lastPostTakeNoticeDate: null, 
          lastPostBeActiveDate: null,
          consecutiveTakeNoticeDays: 0,
          lastConsecutiveTakeNoticeDate: null,
          appreciationUpdateCount: 0,
          lastAppreciationUpdateDate: "",
        );

        await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());

        await _firestore.collection('users').doc(cred.user!.uid).update({
          'departmentList': FieldValue.arrayUnion([department]),
        });

        res = "success";
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }

  Future<void> addDept({
    required String username,
    required String departmentName,
  }) async {
    CollectionReference departments = _firestore.collection('departments');
    DocumentSnapshot departmentDoc =
        await departments.doc(departmentName).get();

    if (!departmentDoc.exists) {
      await departments.doc(departmentName).set({
        'departmentName': departmentName,
        'userList': [],
      });
    }

    await departments.doc(departmentName).update({
      'userList': FieldValue.arrayUnion([username]),
    });
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occured';

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'success';
      } else {
        res = 'Please enter all the fields';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String?> getUserName(String uid) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      return snap['name'];
    } catch (err) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
