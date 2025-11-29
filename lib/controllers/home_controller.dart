import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import '../services/firestore_service.dart';

class HomeController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var transactions = <TransactionModel>[].obs;
  var budgets = <BudgetModel>[].obs;
  var categorySpending = <String, double>{}.obs;

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
    if (_auth.currentUser != null) {
      String uid = _auth.currentUser!.uid;
      transactions.bindStream(_firestoreService.getTransactions(uid));
      budgets.bindStream(_firestoreService.getBudgets(uid));
      ever(transactions, (_) => _calculateStats());
    }
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

  void setFilter(String filter) => currentFilter.value = filter;

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
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
        if (t.date.month == now.month && t.date.year == now.year) {
          if (!monthlySpending.containsKey(t.category)) {
            monthlySpending[t.category] = 0.0;
          }
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

      // Check for budget exceeded
      if (t.type == 'expense') {
        final budget = budgets.firstWhereOrNull(
          (b) => b.category == t.category,
        );
        if (budget != null) {
          final currentSpent = categorySpending[t.category] ?? 0.0;
          // Note: currentSpent might not yet include this new transaction if stream hasn't updated
          // So we add it manually for the check
          if (currentSpent + t.amount > budget.limit) {
            Get.snackbar(
              "Budget Exceeded!",
              "You have exceeded your budget for ${t.category}",
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              icon: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
              ),
              duration: const Duration(seconds: 4),
            );
            return;
          }
        }
      }

      _showSuccessSnackbar("Saved", "Transaction added successfully");
    } on FirebaseException catch (e) {
      _handleFirebaseError(e, "Could not add transaction");
    } catch (e) {
      _showErrorSnackbar("Error", "An unexpected error occurred.");
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _firestoreService.deleteTransaction(id);
    } catch (e) {
      _showErrorSnackbar("Delete Failed", "Could not delete transaction.");
    }
  }

  Future<void> setBudget(String category, double limit) async {
    try {
      if (_auth.currentUser == null) return;
      String uid = _auth.currentUser!.uid;
      final budget = BudgetModel(
        id: '',
        uid: uid,
        category: category,
        limit: limit,
      );
      await _firestoreService.setBudget(budget);
      Get.back();
      _showSuccessSnackbar("Goal Set", "Monthly budget updated for $category");
    } on FirebaseException catch (e) {
      _handleFirebaseError(e, "Could not set budget");
    } catch (e) {
      _showErrorSnackbar("Save Failed", "An unexpected error occurred.");
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      await _firestoreService.deleteBudget(id);
    } catch (e) {
      _showErrorSnackbar("Delete Failed", "Could not delete budget.");
    }
  }

  void _handleFirebaseError(FirebaseException e, String defaultMsg) {
    String message = defaultMsg;
    if (e.code == 'permission-denied') {
      message =
          "You don't have permission to do this. Check your internet or login status.";
    } else if (e.code == 'unavailable') {
      message = "You seem to be offline.";
    }
    _showErrorSnackbar("Action Failed", message);
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle, color: Colors.green),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withValues(alpha: 0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}
