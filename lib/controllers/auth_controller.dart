import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  // Reactive variables (.obs)
  var isLoading = false.obs;
  var currentUser = Rxn<UserModel>(); // Rxn allows null

  // Login Logic
  Future<void> login(String email, String password) async {
    isLoading.value = true; // Update state

    try {
      UserModel? user = await _authService.signIn(email, password);
      currentUser.value = user;

      if (user != null) {
        // GetX Navigation
        if (user.role == 'admin') {
          Get.offAllNamed(AppRoutes.adminDashboard);
        } else {
          Get.offAllNamed(AppRoutes.userDashboard);
        }
        Get.snackbar(
          "Success",
          "Welcome back!",
          backgroundColor: Colors.green.withOpacity(0.5),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Login Failed",
        e.toString(),
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false; // Stop loading
    }
  }

  // Register Logic
  Future<void> register(String email, String password) async {
    isLoading.value = true;

    try {
      await _authService.signUp(email, password);
      // Navigate to dashboard or login
      Get.offAllNamed(AppRoutes.userDashboard);
      Get.snackbar("Success", "Account created successfully!");
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
