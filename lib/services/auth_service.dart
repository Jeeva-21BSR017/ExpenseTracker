import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '5382402056-7r9omk6ajl8ebp7cu5im1rapt795e312.apps.googleusercontent.com'
        : null,
  );

  // 1. Register User (Email/Password)
  Future<UserModel?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _db.collection('users').doc(result.user!.uid).set({
        'email': email,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return UserModel(uid: result.user!.uid, email: email, role: 'user');
    } catch (e) {
      throw e;
    }
  }

  // 2. Login User (Email/Password)
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
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

  // 3. Google Sign In
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        DocumentSnapshot doc = await _db
            .collection('users')
            .doc(user.uid)
            .get();
        if (!doc.exists) {
          await _db.collection('users').doc(user.uid).set({
            'email': user.email,
            'role': 'user',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        String role = 'user';
        if (doc.exists && doc.data() != null) {
          role = (doc.data() as Map<String, dynamic>)['role'] ?? 'user';
        }
        return UserModel(uid: user.uid, email: user.email ?? '', role: role);
      }
      return null;
    } catch (e) {
      throw e;
    }
  }

  // 4. Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
