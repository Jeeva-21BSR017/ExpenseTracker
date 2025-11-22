// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';
// import '../../controllers/report_controller.dart';
// import '../../utils/app_colors.dart';

// class InsightsView extends StatelessWidget {
//   const InsightsView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final ReportController controller = Get.put(ReportController());

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Financial Trends",
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 5),
//           const Text(
//             "Income vs Expense (Last 6 Months)",
//             style: TextStyle(color: Colors.grey, fontSize: 12),
//           ),

//           const SizedBox(height: 20),

//           Container(
//             height: 350,
//             padding: const EdgeInsets.fromLTRB(15, 30, 25, 10),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.grey.shade200),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.03),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Obx(() {
//               if (controller.isLoading.isTrue)
//                 return const Center(child: CircularProgressIndicator());
//               if (controller.monthlyStats.isEmpty)
//                 return const Center(
//                   child: Text("Not enough data for insights"),
//                 );

//               return BarChart(
//                 BarChartData(
//                   alignment: BarChartAlignment.spaceAround,
//                   maxY: _calculateMaxY(controller.monthlyStats) * 1.2,

//                   barTouchData: BarTouchData(
//                     enabled: true,
//                     touchTooltipData: BarTouchTooltipData(
//                       tooltipPadding: const EdgeInsets.all(12),
//                       tooltipMargin: 8,
//                       getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                         return BarTooltipItem(
//                           '${rodIndex == 0 ? 'Income' : 'Expense'}\n',
//                           const TextStyle(
//                             color: Colors.white70,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                           children: [
//                             TextSpan(
//                               text: '\$${rod.toY.round()}',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w900,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ),

//                   gridData: FlGridData(
//                     show: true,
//                     drawVerticalLine: false,
//                     horizontalInterval: _calculateInterval(
//                       controller.monthlyStats,
//                     ),
//                     getDrawingHorizontalLine: (value) =>
//                         FlLine(color: Colors.grey.shade100, strokeWidth: 1),
//                   ),
//                   borderData: FlBorderData(show: false),

//                   titlesData: FlTitlesData(
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                     topTitles: AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                     rightTitles: AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 40,
//                         getTitlesWidget: (value, meta) {
//                           int index = value.toInt();
//                           if (index >= 0 &&
//                               index < controller.monthlyStats.length) {
//                             return Padding(
//                               padding: const EdgeInsets.only(top: 12.0),
//                               child: Text(
//                                 DateFormat(
//                                   'MMM',
//                                 ).format(controller.monthlyStats[index].date),
//                                 style: const TextStyle(
//                                   color: Colors.grey,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             );
//                           }
//                           return const Text('');
//                         },
//                       ),
//                     ),
//                   ),

//                   barGroups: controller.monthlyStats.asMap().entries.map((
//                     entry,
//                   ) {
//                     int idx = entry.key;
//                     MonthlyStat stat = entry.value;
//                     return BarChartGroupData(
//                       x: idx,
//                       barsSpace: 12,
//                       barRods: [
//                         BarChartRodData(
//                           toY: stat.income,
//                           color: AppColors.accent,
//                           width: 24,
//                           borderRadius: const BorderRadius.vertical(
//                             top: Radius.circular(6),
//                           ),
//                         ),

//                         BarChartRodData(
//                           toY: stat.expense,
//                           color: AppColors.error,
//                           width: 24,
//                           borderRadius: const BorderRadius.vertical(
//                             top: Radius.circular(6),
//                           ),
//                         ),
//                       ],
//                     );
//                   }).toList(),
//                 ),
//               );
//             }),
//           ),

//           const SizedBox(height: 30),
//           const Text(
//             "Key Metrics",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 15),

//           Obx(
//             () => Row(
//               children: [
//                 Expanded(
//                   child: _buildMetricCard(
//                     "Avg. Monthly Spend",
//                     "\₹${controller.averageMonthlySpend.value.toStringAsFixed(0)}",
//                     Icons.analytics_outlined,
//                     Colors.blue,
//                   ),
//                 ),
//                 const SizedBox(width: 15),
//                 Expanded(
//                   child: _buildMetricCard(
//                     "Highest Spend Month",
//                     controller.highestSpendMonth.value,
//                     Icons.calendar_month_outlined,
//                     Colors.orange,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 30),

//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               onPressed: () => controller.exportPdf(),
//               icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
//               label: const Text(
//                 "Download Report (PDF)",
//                 style: TextStyle(
//                   color: AppColors.primary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 18),
//                 side: const BorderSide(color: AppColors.primary, width: 1.5),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   double _calculateMaxY(List<MonthlyStat> stats) {
//     double max = 0;
//     for (var s in stats) {
//       if (s.income > max) max = s.income;
//       if (s.expense > max) max = s.expense;
//     }
//     return max == 0 ? 100 : max;
//   }

//   double _calculateInterval(List<MonthlyStat> stats) {
//     double max = _calculateMaxY(stats);
//     return max / 4;
//   }

//   Widget _buildMetricCard(
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.02),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: color, size: 28),
//           const SizedBox(height: 10),
//           Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//           const SizedBox(height: 5),
//           Text(
//             value.isEmpty ? "-" : value,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textPrimary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../controllers/report_controller.dart';
import '../../utils/app_colors.dart';

class InsightsView extends StatelessWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportController controller = Get.put(ReportController());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Financial Trends",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Income vs Expense (Last 6 Months)",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),

          const SizedBox(height: 20),

          // --- CHART CONTAINER ---
          Container(
            height: 380,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // 1. LEGEND
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem("Income", AppColors.accent),
                    const SizedBox(width: 24),
                    _buildLegendItem("Expense", AppColors.error),
                  ],
                ),
                const SizedBox(height: 30),

                // 2. THE CHART
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.isTrue)
                      return const Center(child: CircularProgressIndicator());
                    if (controller.monthlyStats.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart,
                              size: 48,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Add transactions to see trends",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _calculateMaxY(controller.monthlyStats) * 1.2,

                        // Tooltip configuration
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            tooltipMargin: 8,
                            // FIX: Use tooltipBgColor for version 0.65.0
                            tooltipBgColor: Colors.blueGrey.shade900,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              String label = rodIndex == 0
                                  ? 'Income'
                                  : 'Expense';
                              return BarTooltipItem(
                                '$label\n',
                                const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                children: [
                                  TextSpan(
                                    text: '\₹${rod.toY.round()}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        // Subtle Grid
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _calculateInterval(
                            controller.monthlyStats,
                          ),
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.shade100,
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          ),
                        ),
                        borderData: FlBorderData(show: false),

                        // Labels
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= 0 &&
                                    index < controller.monthlyStats.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Text(
                                      DateFormat('MMM').format(
                                        controller.monthlyStats[index].date,
                                      ),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),

                        // Bars
                        barGroups: controller.monthlyStats.asMap().entries.map((
                          entry,
                        ) {
                          int idx = entry.key;
                          MonthlyStat stat = entry.value;
                          return BarChartGroupData(
                            x: idx,
                            barsSpace: 16,
                            barRods: [
                              _buildRod(stat.income, AppColors.accent),
                              _buildRod(stat.expense, AppColors.error),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          const Text(
            "Key Metrics",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 15),

          // Metrics Cards
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    "Avg. Monthly Spend",
                    "\₹${controller.averageMonthlySpend.value.toStringAsFixed(0)}",
                    Icons.analytics_outlined,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildMetricCard(
                    "Highest Spend Month",
                    controller.highestSpendMonth.value,
                    Icons.calendar_month_outlined,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Export Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => controller.exportPdf(),
              icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
              label: const Text(
                "Download Report (PDF)",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartRodData _buildRod(double yValue, Color color) {
    return BarChartRodData(
      toY: yValue,
      color: color,
      width: 18,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      backDrawRodData: BackgroundBarChartRodData(
        show: true,
        toY: _calculateMaxY(Get.find<ReportController>().monthlyStats) * 1.2,
        color: color.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  double _calculateMaxY(List<MonthlyStat> stats) {
    double max = 0;
    for (var s in stats) {
      if (s.income > max) max = s.income;
      if (s.expense > max) max = s.expense;
    }
    return max == 0 ? 100 : max;
  }

  double _calculateInterval(List<MonthlyStat> stats) {
    double max = _calculateMaxY(stats);
    return max / 4;
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            value.isEmpty ? "-" : value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
