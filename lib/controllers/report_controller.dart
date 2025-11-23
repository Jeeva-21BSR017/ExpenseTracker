import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import 'home_controller.dart';
import '../services/pdf_service.dart';

class ReportController extends GetxController {
  final HomeController _homeController = Get.find<HomeController>();
  final PdfService _pdfService = PdfService();

  // Data Observables
  var monthlyStats = <MonthlyStat>[].obs;
  var weeklyStats = <DayStat>[].obs;
  var categorySpending = <String, double>{}.obs; // For Donut Chart

  // Metrics
  var highestSpendMonth = "-".obs;
  var averageMonthlySpend = 0.0.obs;
  var totalSpentInPeriod = 0.0.obs;
  var isLoading = true.obs;

  // Filter State
  var selectedTimeRange = 'Month'.obs; // Default

  @override
  void onInit() {
    super.onInit();
    _initEmptyWeeklyStats();
    ever(_homeController.transactions, (_) => generateReport());
    if (_homeController.transactions.isNotEmpty) {
      generateReport();
    } else {
      isLoading.value = false;
    }
  }

  void setTimeRange(String range) {
    selectedTimeRange.value = range;
    generateReport(); // Recalculate everything based on new range
  }

  void _initEmptyWeeklyStats() {
    List<DayStat> days = [];
    DateTime now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      days.add(DayStat(date: day, amount: 0.0));
    }
    weeklyStats.assignAll(days);
  }

  void generateReport() {
    isLoading.value = true;

    // 1. Filter Transactions based on Time Range
    List<TransactionModel> filteredList = _filterTransactionsByTime();

    // 2. Generate Charts Data
    _generateCategoryStats(filteredList);
    _generateMonthlyStats(filteredList);
    _generateWeeklyStats(filteredList);

    // 3. Calculate Total for the Donut Center
    double total = 0;
    for (var t in filteredList) {
      if (t.type == 'expense') total += t.amount;
    }
    totalSpentInPeriod.value = total;

    isLoading.value = false;
  }

  List<TransactionModel> _filterTransactionsByTime() {
    final now = DateTime.now();
    List<TransactionModel> all = _homeController.transactions;

    if (selectedTimeRange.value == 'Week') {
      // Last 7 days
      final start = now.subtract(const Duration(days: 7));
      return all.where((t) => t.date.isAfter(start)).toList();
    } else if (selectedTimeRange.value == 'Month') {
      // Current Month
      return all
          .where((t) => t.date.month == now.month && t.date.year == now.year)
          .toList();
    } else if (selectedTimeRange.value == 'Year') {
      // Current Year
      return all.where((t) => t.date.year == now.year).toList();
    }
    return all;
  }

  void _generateCategoryStats(List<TransactionModel> transactions) {
    Map<String, double> spending = {};
    for (var t in transactions) {
      if (t.type == 'expense') {
        if (!spending.containsKey(t.category)) spending[t.category] = 0.0;
        spending[t.category] = spending[t.category]! + t.amount;
      }
    }
    categorySpending.assignAll(spending);
  }

  void _generateMonthlyStats(List<TransactionModel> transactions) {
    Map<String, MonthlyStat> statsMap = {};

    for (var t in transactions) {
      String key = "${t.date.year}-${t.date.month.toString().padLeft(2, '0')}";
      if (!statsMap.containsKey(key)) {
        statsMap[key] = MonthlyStat(monthYear: key, date: t.date);
      }
      if (t.type == 'income') {
        statsMap[key]!.income += t.amount;
      } else {
        statsMap[key]!.expense += t.amount;
      }
    }

    var sortedStats = statsMap.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // For charts, we usually want at least a few data points
    if (sortedStats.length > 6) {
      sortedStats = sortedStats.sublist(sortedStats.length - 6);
    }

    monthlyStats.assignAll(sortedStats);
    _calculateMetrics(sortedStats);
  }

  void _generateWeeklyStats(List<TransactionModel> transactions) {
    List<DayStat> days = [];
    DateTime now = DateTime.now();
    // Create bucket for last 7 days
    for (int i = 6; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      days.add(DayStat(date: day, amount: 0.0));
    }

    for (var t in transactions) {
      if (t.type == 'expense') {
        for (var dayStat in days) {
          if (t.date.year == dayStat.date.year &&
              t.date.month == dayStat.date.month &&
              t.date.day == dayStat.date.day) {
            dayStat.amount += t.amount;
          }
        }
      }
    }
    weeklyStats.assignAll(days);
  }

  void _calculateMetrics(List<MonthlyStat> stats) {
    if (stats.isEmpty) {
      averageMonthlySpend.value = 0.0;
      highestSpendMonth.value = "-";
      return;
    }

    double totalExpense = 0;
    double maxExpense = -1;
    String maxMonth = "-";

    for (var s in stats) {
      totalExpense += s.expense;
      if (s.expense > maxExpense) {
        maxExpense = s.expense;
        maxMonth = DateFormat('MMMM').format(s.date);
      }
    }

    averageMonthlySpend.value = totalExpense / stats.length;
    highestSpendMonth.value = maxMonth;
  }

  Future<void> exportPdf() async {
    if (monthlyStats.isEmpty) {
      Get.snackbar(
        "No Data",
        "Add transactions before exporting.",
        backgroundColor: Colors.orange.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    try {
      await _pdfService.generateAndDownloadPdf(
        monthlyStats,
        averageMonthlySpend.value,
        highestSpendMonth.value,
      );
    } catch (e) {
      Get.snackbar(
        "Export Failed",
        "$e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class MonthlyStat {
  final String monthYear;
  final DateTime date;
  double income = 0.0;
  double expense = 0.0;
  MonthlyStat({required this.monthYear, required this.date});
}

class DayStat {
  final DateTime date;
  double amount;
  DayStat({required this.date, required this.amount});
}
