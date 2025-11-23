import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var isLoading = true.obs;

  // Metrics
  var totalUsers = 0.obs;
  var totalTransactions = 0.obs;
  var activeBudgetUsers = 0.obs;
  var adoptionRate = 0.0.obs;

  // Data for Graph & List
  var userList = <Map<String, dynamic>>[].obs;
  var userGrowthData = <FlSpotData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlatformStats();
  }

  Future<void> fetchPlatformStats() async {
    try {
      isLoading.value = true;

      // 1. Fetch All Users
      QuerySnapshot userSnapshot = await _db
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      totalUsers.value = userSnapshot.docs.length;

      // Process User List
      var allUsers = userSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'email': data['email'] ?? 'Unknown',
          'role': data['role'] ?? 'user',
          'joined': data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
        };
      }).toList();

      // FILTER: Only show 'user' role, hide 'admin'
      userList.value = allUsers.where((u) => u['role'] != 'admin').toList();

      // Process Graph Data
      _generateUserGrowthChart(allUsers);

      // 2. Get Total Transactions count
      AggregateQuerySnapshot txCount = await _db
          .collection('transactions')
          .count()
          .get();
      totalTransactions.value = txCount.count ?? 0;

      // 3. Calculate Adoption
      AggregateQuerySnapshot budgetCount = await _db
          .collection('budgets')
          .count()
          .get();
      activeBudgetUsers.value = budgetCount.count ?? 0;

      // 4. Calculate Percentage
      if (totalUsers.value > 0) {
        adoptionRate.value = (activeBudgetUsers.value / totalUsers.value) * 100;
      } else {
        adoptionRate.value = 0.0;
      }
    } catch (e) {
      print("Admin Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _generateUserGrowthChart(List<Map<String, dynamic>> users) {
    Map<int, int> monthlyCounts = {};

    for (var user in users) {
      DateTime date = user['joined'];
      int month = date.month;
      if (!monthlyCounts.containsKey(month)) monthlyCounts[month] = 0;
      monthlyCounts[month] = monthlyCounts[month]! + 1;
    }

    List<FlSpotData> spots = [];
    monthlyCounts.forEach((month, count) {
      spots.add(FlSpotData(month.toDouble(), count.toDouble()));
    });

    spots.sort((a, b) => a.x.compareTo(b.x));
    userGrowthData.value = spots;
  }
}

class FlSpotData {
  final double x;
  final double y;
  FlSpotData(this.x, this.y);
}
