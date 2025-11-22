import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController adminController = Get.put(AdminController());
    final AuthController authController = Get.find();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text(
          "Admin",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => adminController.fetchPlatformStats(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Platform Overview",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Real-time usage metrics",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            Obx(() {
              if (adminController.isLoading.isTrue) {
                return const Center(child: CircularProgressIndicator());
              }

              double adoptionRate = 0;
              if (adminController.totalUsers.value > 0) {
                adoptionRate =
                    (adminController.activeBudgetUsers.value /
                        adminController.totalUsers.value) *
                    100;
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "Total Users",
                          adminController.totalUsers.value.toString(),
                          Icons.people_alt_outlined,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          "Total Transactions",
                          adminController.totalTransactions.value.toString(),
                          Icons.receipt_long_outlined,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  _buildStatCard(
                    "Budget Feature Usage",
                    "${adminController.activeBudgetUsers.value}",
                    Icons.track_changes_outlined,
                    Colors.orange,
                    subtitle:
                        "Adoption Rate: ${adoptionRate.toStringAsFixed(1)}%",
                  ),
                ],
              );
            }),

            const SizedBox(height: 40),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: Colors.red),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Privacy Protocol Active",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          "As an Admin, you can view aggregate platform metrics, but individual user transaction data remains private and encrypted.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
