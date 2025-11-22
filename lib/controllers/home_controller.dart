import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import '../services/firestore_service.dart';

class HomeController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var transactions = <TransactionModel>[].obs;
  var budgets = <BudgetModel>[].obs;
  var categorySpending =
      <String, double>{}.obs; // Tracks spending for CURRENT MONTH only

  // Filters
  var currentFilter = 'All'.obs;
  var dateRangeStart = Rxn<DateTime>();
  var dateRangeEnd = Rxn<DateTime>();

  var isLoading = true.obs;
  var totalBalance = 0.0.obs;
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    String uid = _auth.currentUser!.uid;

    transactions.bindStream(_firestoreService.getTransactions(uid));
    budgets.bindStream(_firestoreService.getBudgets(uid));

    ever(transactions, (_) => _calculateStats());
  }

  List<TransactionModel> get filteredTransactions {
    var list = transactions.toList();

    if (currentFilter.value == 'Income') {
      list = list.where((t) => t.type == 'income').toList();
    } else if (currentFilter.value == 'Expense') {
      list = list.where((t) => t.type == 'expense').toList();
    }

    if (dateRangeStart.value != null && dateRangeEnd.value != null) {
      final start = DateTime(
        dateRangeStart.value!.year,
        dateRangeStart.value!.month,
        dateRangeStart.value!.day,
      );
      final end = DateTime(
        dateRangeEnd.value!.year,
        dateRangeEnd.value!.month,
        dateRangeEnd.value!.day,
        23,
        59,
        59,
      );

      list = list.where((t) {
        return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(end.add(const Duration(seconds: 1)));
      }).toList();
    }

    return list;
  }

  void setFilter(String filter) {
    currentFilter.value = filter;
  }

  void setDateRange(DateTimeRange? range) {
    if (range == null) {
      dateRangeStart.value = null;
      dateRangeEnd.value = null;
    } else {
      dateRangeStart.value = range.start;
      dateRangeEnd.value = range.end;
    }
  }

  void _calculateStats() {
    double income = 0.0;
    double expense = 0.0;
    Map<String, double> monthlySpending = {};

    final now = DateTime.now();

    for (var t in transactions) {
      // 1. Total Balance Logic (All Time)
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;

        // 2. Budget Logic (Strictly Current Month)
        // Only add to spending map if transaction is in the current month and year
        if (t.date.month == now.month && t.date.year == now.year) {
          if (!monthlySpending.containsKey(t.category))
            monthlySpending[t.category] = 0.0;
          monthlySpending[t.category] = monthlySpending[t.category]! + t.amount;
        }
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;
    totalBalance.value = income - expense;
    categorySpending.value = monthlySpending;
  }

  Future<void> addTransaction(TransactionModel t) async {
    try {
      await _firestoreService.addTransaction(t);
      Get.back();
      Get.snackbar(
        "Saved",
        "Transaction added successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Could not save: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> deleteTransaction(String id) async {
    await _firestoreService.deleteTransaction(id);
  }

  Future<void> setBudget(String category, double limit) async {
    try {
      String uid = _auth.currentUser!.uid;
      final budget = BudgetModel(
        id: '',
        uid: uid,
        category: category,
        limit: limit,
      );
      await _firestoreService.setBudget(budget);
      Get.back();

      Get.snackbar(
        "Goal Set",
        "Monthly budget updated for $category",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        icon: const Icon(Icons.flag, color: Colors.blue),
      );
    } catch (e) {
      Get.snackbar(
        "Save Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteBudget(String id) async {
    await _firestoreService.deleteBudget(id);
  }
}
