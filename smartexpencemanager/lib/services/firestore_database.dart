import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartexpencemanager/models/notes.dart';
import 'package:smartexpencemanager/services/fcm_service.dart';

class FirebaseFirestoreDb {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseFcmService _firebaseFcmService = FirebaseFcmService();
  final USERS = 'users';
  final NOTES = 'notes';

  Future<void> addUser(User? user) async {
    try {
      await db.collection(USERS).add({
        "name": user!.displayName,
        "email": user.email,
        "photoUrl": user.photoURL,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
        "uid": user.uid,
        "fcmToken": await _firebaseFcmService.getToken(),
      });
    } catch (e) {
      throw Exception('Failed to add user: $e');
    }
  }

  Future<void> addNote() async {
    final note = Notes(
      title: 'dummy second title',
      content: 'dummy content',
      tags: ['dummy tag'],
    );
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user signed in');

      if (currentUser != null) {
        await db
            .collection(USERS)
            .doc(currentUser!.uid)
            .collection(NOTES)
            .add(
              note.toJson()..addAll({
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp(),
              }),
            );
      }
    } catch (e) {
      throw Exception('Failed to add note: $e');
    }
  }

  Future<void> updateNote() async {
    final note = Notes(
      title: 'dummy2 title',
      content: 'dummy content',
      tags: ['dummy tag'],
    );
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('No user signed in');
    await db
        .collection(USERS)
        .doc(currentUser.uid)
        .collection(NOTES)
        .doc('LGFzMKia0LT65AKBvEoQ')
        .update({...note.toJson(), "updatedAt": FieldValue.serverTimestamp()});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getNotesStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('No user signed in');

    final notesCollection =
        db
            .collection(USERS)
            .doc(currentUser.uid)
            .collection(NOTES)
            .orderBy('createdAt', descending: true)
            .snapshots();

    return notesCollection;
  }

  // /// Add user and print the generated doc ID
  // Future<void> addUser() async {
  //   final userData = {
  //     "name": "nikil",
  //     "des": "Software Engineer",
  //     "skills": ["flutter", "python", "js"],
  //   };

  //   final docRef = await db.collection(USERS).add(userData);
  //   print("✅ User added with ID: ${docRef.id}");
  // }

  // /// Get all users
  // Future<void> getUsers() async {
  //   final snapshot = await db.collection(USERS).get();
  //   for (var doc in snapshot.docs) {
  //     print("Doc ID: ${doc.id}");
  //     print("Data: ${doc.data()}");
  //   }
  // }

  // /// Get a single user by ID
  // Future<void> getUserById(String docId) async {
  //   final doc = await db.collection(USERS).doc(docId).get();
  //   if (doc.exists) {
  //     print("Doc ID: ${doc.id}");
  //     print("Data: ${doc.data()}");
  //   } else {
  //     print("❌ No user found with id $docId");
  //   }
  // }

  // /// Update a user by ID
  // Future<void> updateUser(String docId) async {
  //   await db.collection(USERS).doc(docId).update({
  //     "des": "Senior Software Engineer",
  //     "skills": FieldValue.arrayUnion(['firebase']),
  //   });
  //   print("✅ Updated user $docId");
  // }

  // /// Delete a user by ID
  // Future<void> deleteUser(String docId) async {
  //   await db.collection(USERS).doc(docId).delete();
  //   print("🗑️ Deleted user $docId");
  // }

  // Future<void> fetchOnlySE() async {
  //   final snapshot =
  //       await db
  //           .collection(USERS)
  //           .where('des', isEqualTo: 'Software Engineer')
  //           .get();

  //   for (var snap in snapshot.docs) {
  //     print('doc id :  ${snap.id}');
  //     print('data : ${snap.data()}');
  //   }
  // }

  // Future<void> whoHaveFLutterSkills() async {
  //   final snapShot =
  //       await db
  //           .collection(USERS)
  //           .where('skills', arrayContains: 'flutter')
  //           .get();

  //   for (var snap in snapShot.docs) {
  //     print('doc id : ${snap.id}');
  //     print('data : ${snap.data()}');
  //   }
  // }

  // Future<void> firstTwoUsersOrderedbyASC() async {
  //   final snapshots =
  //       await db
  //           .collection(USERS)
  //           .orderBy('age', descending: false)
  //           .limit(2)
  //           .get();

  //   for (var snap in snapshots.docs) {
  //     print('doc id : ${snap.id}');
  //     print('data : ${snap.data()}');
  //   }
  // }

  // fetchAllGt25age() async {
  //   await db.collection(USERS).where('age', isGreaterThan: 25).get().then((
  //     value,
  //   ) {
  //     for (var snap in value.docs) {
  //       print('doc id : ${snap.id}');
  //       print('data : ${snap.data()}');
  //     }
  //   });
  // }

  // void nameStartWithB() async {
  //   final snapshots =
  //       await db.collection(USERS).orderBy('name').startAt(["B"]).endAt([
  //         'B\uf8ff',
  //       ]).get();

  //   for (var snap in snapshots.docs) {
  //     print('doc id : ${snap.id}');
  //     print('data : ${snap.data()}');
  //   }
  // }

  // void fetchUsersOrderedByNameDesc() async {
  //   final smapshot =
  //       await db.collection(USERS).orderBy("name", descending: true).get();

  //   for (var snap in smapshot.docs) {
  //     print('doc id : ${snap.id}');
  //     print('data : ${snap.data()}');
  //   }
  // }
}
