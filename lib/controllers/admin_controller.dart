import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var isLoading = true.obs;

  var totalUsers = 0.obs;
  var totalTransactions = 0.obs;
  var activeBudgetUsers = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlatformStats();
  }

  Future<void> fetchPlatformStats() async {
    try {
      isLoading.value = true;
      AggregateQuerySnapshot userCount = await _db
          .collection('users')
          .count()
          .get();
      totalUsers.value = userCount.count ?? 0;
      AggregateQuerySnapshot txCount = await _db
          .collection('transactions')
          .count()
          .get();
      totalTransactions.value = txCount.count ?? 0;
      AggregateQuerySnapshot budgetCount = await _db
          .collection('budgets')
          .count()
          .get();
      activeBudgetUsers.value = budgetCount.count ?? 0;
    } catch (e) {
      Get.snackbar("Error", "Could not fetch admin stats: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
