import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  var isLoading = false.obs;
  var currentUser = Rxn<UserModel>();

  // 1. Login
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      UserModel? user = await _authService.signIn(email, password);
      currentUser.value = user;

      if (user != null) {
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
      await _authService.signUp(email, password);
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
        currentUser.value = user;
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
    await _authService.signOut();
    Get.offAllNamed(AppRoutes.login);
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
