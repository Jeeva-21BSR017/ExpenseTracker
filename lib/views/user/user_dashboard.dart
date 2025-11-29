import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import 'add_transaction_sheet.dart';
import 'set_budget_sheet.dart';
import 'insights_view.dart';
import 'profile_view.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.put(HomeController());
    final AuthController authController = Get.find();

    Widget currentBody;
    switch (_currentIndex) {
      case 0:
        currentBody = _buildHomeBodyContent(homeController, context);
        break;
      case 1:
        currentBody = _buildActivityBodyContent(homeController, context);
        break;
      case 2:
        currentBody = _buildInsightsBodyContent(homeController, context);
        break;
      case 3:
      default:
        currentBody = const ProfileView();
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _buildStaticHeader(authController, homeController),
            currentBody,
            const SizedBox(height: 100),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _currentIndex != 3
          ? Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.only(top: 24),
              child: FloatingActionButton(
                backgroundColor: AppColors.primary,
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AddTransactionSheet(),
                ),
              ),
            )
          : null,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        height: 60,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, "Home", 0),
            _buildNavItem(Icons.list_alt_rounded, "Activity", 1),
            const SizedBox(width: 48),
            _buildNavItem(Icons.pie_chart_rounded, "Insights", 2),
            _buildNavItem(Icons.person_rounded, "Profile", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return IconButton(
      onPressed: () => setState(() => _currentIndex = index),
      icon: Icon(
        icon,
        color: isSelected ? AppColors.primary : Colors.grey[400],
        size: 28,
      ),
      tooltip: label,
    );
  }

  Widget _buildStaticHeader(
    AuthController authController,
    HomeController homeController,
  ) {
    final bool isHome = _currentIndex == 0;

    final double bgHeight = isHome ? 230 : 120;
    final double totalHeight = isHome ? 290 : 120;

    String title = "";
    if (_currentIndex == 1) title = "All Transactions";
    if (_currentIndex == 2) title = "Financial Insights";
    if (_currentIndex == 3) title = "My Profile";

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: bgHeight,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, left: 24, right: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    isHome
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Welcome,",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Obx(() {
                                return Text(
                                  authController.displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }),
                            ],
                          )
                        : Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                    Row(
                      children: [
                        Obx(() {
                          final user = authController.currentUser.value;
                          if (user?.photoUrl != null) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(user!.photoUrl!),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                        IconButton(
                          onPressed: () => authController.logout(),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          tooltip: "Logout",
                        ),
                      ],
                    ),
                  ],
                ),

                if (isHome) ...[
                  const SizedBox(height: 5),
                  const Text(
                    "Your Balance",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Obx(
                    () => Text(
                      "₹${homeController.totalBalance.value.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (isHome)
            Positioned(
              bottom: 0,
              left: 20,
              right: 20,
              child: _buildFloatingSummaryCard(homeController),
            ),
        ],
      ),
    );
  }

  Widget _buildHomeBodyContent(
    HomeController controller,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 70),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Budget Goals",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  Row(
                    children: [
                      const SizedBox(width: 6),

                      GestureDetector(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const SetBudgetSheet(),
                        ),
                        child: const Text(
                          "+ Add Goal",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),
              _buildBudgetDonut(controller),
              const SizedBox(height: 10),
              _buildBudgetList(controller),
            ],
          ),
        ),

        const SizedBox(height: 25),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Latest Transactions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 1),
                child: const Text(
                  "See all",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),

        _buildTransactionList(controller, limit: 5),
      ],
    );
  }

  Widget _buildActivityBodyContent(
    HomeController controller,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(controller, 'All'),
                const SizedBox(width: 10),
                _buildFilterChip(controller, 'Income'),
                const SizedBox(width: 10),
                _buildFilterChip(controller, 'Expense'),
                const SizedBox(width: 10),
                _buildDateFilterButton(context, controller),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildTransactionList(controller, isScrollable: true),
        ],
      ),
    );
  }

  Widget _buildInsightsBodyContent(
    HomeController controller,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [const SizedBox(height: 10), const InsightsView()],
      ),
    );
  }

  Widget _buildFloatingSummaryCard(HomeController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              Icons.arrow_upward,
              AppColors.accent,
              "Income",
              controller.totalIncome,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          const SizedBox(width: 15),
          Expanded(
            child: _buildSummaryItem(
              Icons.arrow_downward,
              AppColors.error,
              "Expenses",
              controller.totalExpense,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    IconData icon,
    Color color,
    String label,
    RxDouble value,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Obx(
              () => Text(
                "₹${value.value.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Transactions list
  Widget _buildTransactionList(
    HomeController controller, {
    int limit = 0,
    bool isScrollable = false,
  }) {
    return Obx(() {
      final rawList = isScrollable
          ? controller.filteredTransactions
          : controller.transactions;

      if (rawList.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(30),
          child: Center(
            child: Text(
              "No transactions yet",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      final list = limit > 0 && rawList.length > limit
          ? rawList.sublist(0, limit)
          : rawList;

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final t = list[index];
          final isIncome = t.type == 'income';
          final color = isIncome ? AppColors.accent : AppColors.error;

          IconData icon = Icons.shopping_bag_outlined;
          if (t.category == 'Food') icon = Icons.fastfood_rounded;
          if (t.category == 'Transport')
            icon = Icons.directions_car_filled_rounded;
          if (t.category == 'Health') icon = Icons.medical_services_rounded;
          if (t.category == 'Salary') icon = Icons.attach_money_rounded;
          if (t.category == 'Entertainment')
            icon = Icons.movie_creation_rounded;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.category,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.note.isNotEmpty
                            ? t.note
                            : DateFormat('MMM d').format(t.date),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  "${isIncome ? '+' : '-'} ₹${t.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isIncome ? AppColors.accent : AppColors.error,
                  ),
                ),

                // DELETE ICON
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text("Delete transaction"),
                        content: const Text(
                          "Are you sure you want to delete this transaction?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(c).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(c).pop(true),
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      controller.deleteTransaction(t.id);
                    }
                  },
                  child: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildBudgetDonut(HomeController controller) {
    return Obx(() {
      if (controller.budgets.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Center(child: Text("No budgets set. Tap '+ Add Goal'")),
        );
      }

      final entries = controller.budgets.map((b) {
        final spent = controller.categorySpending[b.category] ?? 0.0;
        return MapEntry(b.category, spent);
      }).toList();

      final totalSpent = entries.fold<double>(0.0, (p, e) => p + e.value);

      if (totalSpent <= 0) {
        return Container(
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Center(
            child: Text(
              "No spending yet for your budget goals",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        );
      }

      List<PieChartSectionData> sections = [];
      int idx = 0;
      for (final e in entries) {
        final color = Colors.primaries[idx % Colors.primaries.length];
        final value = e.value;
        sections.add(
          PieChartSectionData(
            color: color,
            value: value,
            title: '${((value / totalSpent) * 100).toStringAsFixed(0)}%',
            radius: 46,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        idx++;
      }

      return Container(
        height: 180,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 28,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: controller.budgets.asMap().entries.map((entry) {
                final i = entry.key;
                final b = entry.value;
                final color = Colors.primaries[i % Colors.primaries.length];
                final spent = controller.categorySpending[b.category] ?? 0.0;
                final percent = totalSpent == 0
                    ? 0
                    : (spent / totalSpent) * 100;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.category,
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            "${percent.toStringAsFixed(0)}% (${spent.toStringAsFixed(0)})",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBudgetList(HomeController controller) {
    return Obx(() {
      if (controller.budgets.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text("No budgets set", style: TextStyle(color: Colors.grey)),
          ),
        );
      }

      final now = DateTime.now(); // Get current date

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.budgets.length,
        padding: const EdgeInsets.only(top: 10),
        itemBuilder: (context, index) {
          final budget = controller.budgets[index];

          // FILTER: Only count expenses from THIS MONTH
          final spent = controller.transactions
              .where(
                (t) =>
                    t.category == budget.category &&
                    t.type == 'expense' &&
                    t.date.month == now.month && // Check Month
                    t.date.year == now.year, // Check Year
              )
              .fold(0.0, (sum, t) => sum + t.amount);

          final isOverBudget = spent > budget.limit;

          double progress = 0.0;
          if (budget.limit > 0) {
            progress = spent / budget.limit;
          }
          double displayProgress = progress > 1.0 ? 1.0 : progress;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            budget.category,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "₹${spent.toStringAsFixed(0)} / ₹${budget.limit.toStringAsFixed(0)}",
                            style: TextStyle(
                              color: isOverBudget
                                  ? AppColors.error
                                  : Colors.grey[600],
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text("Delete budget"),
                            content: const Text(
                              "Are you sure you want to delete this budget goal?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(c).pop(false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(c).pop(true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          controller.deleteBudget(budget.id);
                        }
                      },
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: displayProgress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOverBudget ? AppColors.error : Colors.green,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isOverBudget ? AppColors.error : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildFilterChip(HomeController controller, String label) {
    return Obx(
      () => GestureDetector(
        onTap: () => controller.setFilter(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: controller.currentFilter.value == label
                ? AppColors.primary
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: controller.currentFilter.value == label
                  ? AppColors.primary
                  : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: controller.currentFilter.value == label
                  ? Colors.white
                  : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilterButton(
    BuildContext context,
    HomeController controller,
  ) {
    return GestureDetector(
      onTap: () async {
        final d = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (d != null) controller.setDateRange(d);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text("Date"),
      ),
    );
  }
}
