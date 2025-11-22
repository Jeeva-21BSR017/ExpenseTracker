import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import 'home_controller.dart';
import '../services/pdf_service.dart';

class ReportController extends GetxController {
  final HomeController _homeController = Get.find<HomeController>();
  final PdfService _pdfService = PdfService();

  var monthlyStats = <MonthlyStat>[].obs;
  var highestSpendMonth = "".obs;
  var averageMonthlySpend = 0.0.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_homeController.transactions, (_) => generateReport());
    if (_homeController.transactions.isNotEmpty) {
      generateReport();
    }
  }

  void generateReport() {
    isLoading.value = true;
    Map<String, MonthlyStat> statsMap = {};

    for (var t in _homeController.transactions) {
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

    if (sortedStats.length > 6) {
      sortedStats = sortedStats.sublist(sortedStats.length - 6);
    }

    monthlyStats.value = sortedStats;
    _calculateMetrics(sortedStats);
    isLoading.value = false;
  }

  void _calculateMetrics(List<MonthlyStat> stats) {
    if (stats.isEmpty) return;
    double totalExpense = 0;
    double maxExpense = -1;
    String maxMonth = "";

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
        "Could not generate PDF. Please try again.",
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
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
