import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Register User
  Future<UserModel?> signUp(String email, String password) async {
    try {
      // Create Auth User
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create User Document in Firestore
      // Note: By default, anyone signing up is a 'user'.
      // Admins are usually created manually in the database console.
      await _db.collection('users').doc(result.user!.uid).set({
        'email': email,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return UserModel(uid: result.user!.uid, email: email, role: 'user');
    } catch (e) {
      throw e; // Pass error to controller
    }
  }

  // 2. Login User
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch Role details from Firestore
      DocumentSnapshot doc = await _db
          .collection('users')
          .doc(result.user!.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(
          doc.data() as Map<String, dynamic>,
          result.user!.uid,
        );
      }
      return null;
    } catch (e) {
      throw e;
    }
  }

  // 3. Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
