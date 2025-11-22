import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'utils/routes.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(const MyApp());
  } catch (e) {
    print("FIREBASE INIT FAILED: $e");
    runApp(ErrorApp(errorMessage: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.login,
      getPages: [
        GetPage(name: AppRoutes.login, page: () => const LoginView()),
        GetPage(name: AppRoutes.register, page: () => const RegisterView()),
        GetPage(
          name: AppRoutes.userDashboard,
          page: () =>
              const Scaffold(body: Center(child: Text("User Dashboard"))),
        ),
        GetPage(
          name: AppRoutes.adminDashboard,
          page: () =>
              const Scaffold(body: Center(child: Text("Admin Dashboard"))),
        ),
      ],
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String errorMessage;
  const ErrorApp({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  "App Failed to Start",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Likely Cause: You haven't configured Firebase keys yet.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
