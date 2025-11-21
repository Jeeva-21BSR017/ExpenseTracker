import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  var isLoading = false.obs;
  var currentUser = Rxn<UserModel>();

  // 1. Email/Password Login
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
        Get.snackbar(
          "Success",
          "Welcome back!",
          backgroundColor: Colors.green.withValues(alpha: 0.5),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Login Failed",
        e.toString(),
        backgroundColor: Colors.red.withValues(alpha: 0.5),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Email/Password Register
  Future<void> register(String email, String password) async {
    isLoading.value = true;
    try {
      await _authService.signUp(email, password);
      Get.offAllNamed(AppRoutes.userDashboard);
      Get.snackbar(
        "Success",
        "Account created successfully!",
        backgroundColor: Colors.green.withValues(alpha: 0.5),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red.withValues(alpha: 0.5),
        colorText: Colors.white,
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
        Get.snackbar(
          "Success",
          "Logged in with Google",
          backgroundColor: Colors.green.withValues(alpha: 0.5),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Google Login Failed",
        e.toString(),
        backgroundColor: Colors.red.withValues(alpha: 0.5),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
