import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../controllers/report_controller.dart';
import '../../controllers/home_controller.dart';
import '../../utils/app_colors.dart';

class InsightsView extends StatelessWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportController controller = Get.put(ReportController());
    final HomeController homeController = Get.find();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // 1. SPENDING BY CATEGORY
          const Text(
            "Spending by category",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 15),
          _buildCategorySplit(homeController),

          const SizedBox(height: 32),

          // 2. WEEKLY EXPENSE
          const Text(
            "Weekly Expense Report",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 15),
          _buildWeeklyBarChart(controller),

          const SizedBox(height: 32),

          // 3. MONTHLY TREND
          const Text(
            "Monthly Spending Trend",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 15),
          _buildTradingLineChart(controller),

          const SizedBox(height: 32),

          // 4. METRICS
          const Text(
            "Key Metrics",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 15),
          _buildMetricsGrid(controller),

          const SizedBox(height: 32),

          // 5. DOWNLOAD
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => controller.exportPdf(),
              icon: const Icon(Icons.download_rounded, size: 20),
              label: const Text(
                "Download Full Report",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCategorySplit(HomeController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Obx(() {
              if (controller.categorySpending.isEmpty) {
                return PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 50,
                    sections: [
                      PieChartSectionData(
                        value: 1,
                        color: Colors.grey.shade200,
                        radius: 30,
                        showTitle: false,
                      ),
                    ],
                  ),
                );
              }
              return PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 60,
                  sections: _buildPieSections(controller),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.categorySpending.isEmpty)
              return const Text("No expenses yet");
            int index = 0;
            double total = controller.totalExpense.value;

            return Column(
              children: controller.categorySpending.entries.take(5).map((e) {
                final color = Colors.primaries[index % Colors.primaries.length];
                final percent = total == 0 ? 0 : (e.value / total) * 100;
                index++;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            e.key,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${percent.toStringAsFixed(0)}%",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  // --- 2. WEEKLY BAR CHART ---
  Widget _buildWeeklyBarChart(ReportController controller) {
    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _calculateMaxYWeekly(controller.weeklyStats),
            barTouchData: BarTouchData(enabled: false),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < controller.weeklyStats.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('E')
                              .format(controller.weeklyStats[index].date)
                              .substring(0, 3),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
            barGroups: controller.weeklyStats.asMap().entries.map((entry) {
              int idx = entry.key;
              DayStat stat = entry.value;
              return BarChartGroupData(
                x: idx,
                barRods: [
                  BarChartRodData(
                    toY: stat.amount,
                    color: stat.amount > 0
                        ? AppColors.accent
                        : Colors.grey.shade200,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: _calculateMaxYWeekly(controller.weeklyStats),
                      color: Colors.grey.shade50,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      }),
    );
  }

  // --- MONTHLY GRAPH ---
  Widget _buildTradingLineChart(ReportController controller) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.monthlyStats.isEmpty)
          return const Center(child: Text("No monthly data yet"));

        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: Colors.grey.shade200, strokeWidth: 1),
              getDrawingVerticalLine: (value) =>
                  FlLine(color: Colors.grey.shade200, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    value >= 1000
                        ? '${(value / 1000).toStringAsFixed(1)}k'
                        : value.toInt().toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < controller.monthlyStats.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat(
                            'MMM',
                          ).format(controller.monthlyStats[index].date),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.shade200),
            ),
            minX: 0,
            maxX: (controller.monthlyStats.length - 1).toDouble(),
            minY: 0,
            maxY: _calculateMaxY(controller.monthlyStats) * 1.1,
            lineBarsData: [
              LineChartBarData(
                spots: controller.monthlyStats.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value.expense);
                }).toList(),
                isCurved: false, // TRADING STYLE: SHARP LINES
                color: AppColors.primary,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: AppColors.primary,
                      ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  List<PieChartSectionData> _buildPieSections(HomeController controller) {
    List<PieChartSectionData> sections = [];
    int index = 0;
    double total = controller.totalExpense.value;

    controller.categorySpending.forEach((category, amount) {
      final color = Colors.primaries[index % Colors.primaries.length];
      final percent = total == 0 ? 0 : (amount / total) * 100;

      sections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          title: "${percent.toStringAsFixed(0)}%",
          radius: 25,
          showTitle: false,
          badgeWidget: _buildFloatingBadge(
            percent.toStringAsFixed(0) + "%",
            color,
          ),
          badgePositionPercentageOffset: 1.3,
        ),
      );
      index++;
    });
    return sections;
  }

  Widget _buildFloatingBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(ReportController controller) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              "Avg. Monthly",
              "\₹${controller.averageMonthlySpend.value.toStringAsFixed(0)}",
              Icons.pie_chart_outline_rounded,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildMetricCard(
              "Peak Month",
              controller.highestSpendMonth.value,
              Icons.trending_up_rounded,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value.isEmpty ? "-" : value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateMaxYWeekly(List<DayStat> stats) {
    double max = 0;
    for (var s in stats) {
      if (s.amount > max) max = s.amount;
    }
    return max == 0 ? 100 : max * 1.2;
  }

  double _calculateMaxY(List<MonthlyStat> stats) {
    double max = 0;
    for (var s in stats) {
      if (s.expense > max) max = s.expense;
    }
    return max == 0 ? 100 : max;
  }

  double _calculateInterval(List<MonthlyStat> stats) {
    double max = _calculateMaxY(stats);
    return max / 4;
  }
}
