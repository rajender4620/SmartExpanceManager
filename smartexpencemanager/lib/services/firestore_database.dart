import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseFirestoreDb {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  void adduser(User user) {
    db
        .collection('users')
        .add({
          "uid": user.uid,
          "name": user.displayName,
          "email": user.email,
          "photoUrl": user.photoURL,
          "lastSeen": FieldValue.serverTimestamp(),
          "isOnline": true,
        })
        .then((value) {
          print('User added to firestore');
        })
        .catchError((error) {
          print('Error adding user to firestore: $error');
        });
  }

  void getUser(String uid) {
    print('Getting user from firestore: $uid');
    db
        .collection('users')
        .doc(uid)
        .get()
        .then((value) {
          print('User fetched from firestore: ${value.data()}');
        })
        .catchError((error) {
          print('Error fetching user from firestore: $error');
        });
  }
}
