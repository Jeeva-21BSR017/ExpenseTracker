import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  StreamSubscription<UserModel?>? _userSubscription;

  @override
  void onInit() {
    super.onInit();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _startUserStream(user.uid);
    }
  }

  @override
  void onClose() {
    _userSubscription?.cancel();
    super.onClose();
  }

  void _startUserStream(String uid) {
    _userSubscription?.cancel();
    _userSubscription = _authService.streamUser(uid).listen((user) {
      currentUser.value = user;
    });
  }

  var isLoading = false.obs;
  var currentUser = Rxn<UserModel>();
  String get displayName {
    final user = currentUser.value;

    if (user == null) return "User";

    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }

    if (user.email != null && user.email!.isNotEmpty) {
      return user.email!.split('@')[0];
    }

    return "User";
  }

  // 1. Login
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      UserModel? user = await _authService.signIn(email, password);
      // currentUser.value = user; // Handled by stream
      if (user != null) {
        _startUserStream(user.uid);
        if (user.role == 'admin') {
          Get.offAllNamed(AppRoutes.adminDashboard);
        } else {
          Get.offAllNamed(AppRoutes.userDashboard);
        }
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar("Login Failed", _getReadableErrorMessage(e));
    } catch (e) {
      _showErrorSnackbar(
        "Login Failed",
        "An unexpected error occurred. Please check your internet.",
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Register
  Future<void> register(String email, String password) async {
    isLoading.value = true;
    try {
      UserModel? user = await _authService.signUp(email, password);
      if (user != null) {
        _startUserStream(user.uid);
      }
      Get.offAllNamed(AppRoutes.userDashboard);
      Get.snackbar(
        "Success",
        "Account created successfully!",
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar("Registration Failed", _getReadableErrorMessage(e));
    } catch (e) {
      _showErrorSnackbar(
        "Error",
        "Could not create account. Please try again.",
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 3. Google Login
  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      UserModel? user = await _authService.signInWithGoogle();

      if (user != null) {
        // currentUser.value = user; // Handled by stream
        _startUserStream(user.uid);
        if (user.role == 'admin') {
          Get.offAllNamed(AppRoutes.adminDashboard);
        } else {
          Get.offAllNamed(AppRoutes.userDashboard);
        }
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar("Google Sign-In Failed", _getReadableErrorMessage(e));
    } catch (e) {
      _showErrorSnackbar(
        "Google Sign-In Failed",
        "Cancelled or Network Error.",
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 4. Logout
  Future<void> logout() async {
    _userSubscription?.cancel();
    await _authService.signOut();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  // 5. Update Profile
  Future<void> updateProfile({String? name, String? photoUrl}) async {
    final user = currentUser.value;
    if (user == null) return;

    final updatedUser = UserModel(
      uid: user.uid,
      email: user.email,
      role: user.role,
      displayName: name ?? user.displayName,
      photoUrl: photoUrl ?? user.photoUrl,
      notifications: user.notifications,
    );

    try {
      await _authService.updateUser(updatedUser);
      // Stream will update currentUser
    } catch (e) {
      _showErrorSnackbar("Update Failed", "Could not update profile.");
    }
  }

  // 6. Update Notification Settings
  Future<void> updateNotification(String key, bool value) async {
    final user = currentUser.value;
    if (user == null) return;

    final newNotifications = Map<String, bool>.from(user.notifications);
    newNotifications[key] = value;

    final updatedUser = UserModel(
      uid: user.uid,
      email: user.email,
      role: user.role,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      notifications: newNotifications,
    );

    try {
      await _authService.updateUser(updatedUser);
    } catch (e) {
      _showErrorSnackbar("Update Failed", "Could not update settings.");
    }
  }

  // 7. Send Password Reset
  Future<void> sendPasswordReset(String? email) async {
    if (email == null || email.isEmpty) return;
    try {
      await _authService.sendPasswordResetEmail(email);
      Get.snackbar(
        "Email Sent",
        "Check your inbox to reset password",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      _showErrorSnackbar("Error", "Could not send reset email.");
    }
  }

  String _getReadableErrorMessage(FirebaseAuthException e) {
    debugPrint("Firebase Auth Error Code: ${e.code}");

    switch (e.code) {
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'user-not-found':
      case 'wrong-password':
        return 'Invalid email or password. Please check your credentials.';

      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'network-request-failed':
        return 'Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user account.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red.withValues(alpha: 0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }
}
