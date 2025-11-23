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
        currentBody = _buildProfileBodyContent(authController, context);
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

                              Obx(
                                () => Text(
                                  authController.displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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

                    IconButton(
                      onPressed: () => authController.logout(),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
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

                if (isHome) ...[
                  const SizedBox(height: 5),
                  const Text(
                    "Your Balance",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Obx(
                    () => Text(
                      "\₹${homeController.totalBalance.value.toStringAsFixed(2)}",
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
                children: const [
                  Text(
                    "Spending Breakdown",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Icon(Icons.bar_chart, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 10),
              _buildSpendingChart(controller),
              const SizedBox(height: 25),

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

      child: Column(children: [const SizedBox(height: 10), InsightsView()]),
    );
  }

  Widget _buildProfileBodyContent(
    AuthController authController,
    BuildContext context,
  ) {
    final String email =
        authController.currentUser.value?.email ?? "user@example.com";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.secondaryBackground,
                  child: Icon(Icons.person, size: 32, color: AppColors.primary),
                ),
                const SizedBox(width: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        authController.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "General",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 10),
          _buildProfileOption(Icons.person_outline, "Edit Profile"),
          _buildProfileOption(
            Icons.notifications_none_rounded,
            "Notifications",
          ),
          _buildProfileOption(Icons.security_outlined, "Security"),
          _buildProfileOption(Icons.help_outline_rounded, "Help & Support"),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => authController.logout(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                foregroundColor: AppColors.error,
              ),
              child: const Text(
                "Log Out",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {},
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
            color: Colors.black.withOpacity(0.1),
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
            color: color.withOpacity(0.1),
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
                "\₹${value.value.toStringAsFixed(0)}",
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
                    color: color.withOpacity(0.1),
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
                  "${isIncome ? '+' : '-'} \₹${t.amount.toStringAsFixed(2)}",
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

  // SPENDING CHART
  Widget _buildSpendingChart(HomeController controller) {
    return Obx(() {
      if (controller.categorySpending.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              "No expenses this month",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      List<PieChartSectionData> sections = [];
      int index = 0;
      double monthlyTotal = 0;

      controller.categorySpending.forEach(
        (key, value) => monthlyTotal += value,
      );

      controller.categorySpending.forEach((category, amount) {
        final color = Colors.primaries[index % Colors.primaries.length];
        final percentage = monthlyTotal == 0
            ? 0
            : (amount / monthlyTotal) * 100;

        sections.add(
          PieChartSectionData(
            color: color,
            value: amount,
            title: "${percentage.toStringAsFixed(0)}%",
            radius: 40,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );

        index++;
      });

      return Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 30,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: controller.categorySpending.entries.map((e) {
                int idx = controller.categorySpending.keys.toList().indexOf(
                  e.key,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color:
                              Colors.primaries[idx % Colors.primaries.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(e.key, style: const TextStyle(fontSize: 12)),
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

  // BUDGET LIST
  Widget _buildBudgetList(HomeController controller) {
    return Obx(() {
      if (controller.budgets.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text("No budgets set", style: TextStyle(color: Colors.grey)),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.budgets.length,
        itemBuilder: (context, index) {
          final budget = controller.budgets[index];
          final spent = controller.categorySpending[budget.category] ?? 0.0;
          final progress = (spent / budget.limit).clamp(0.0, 1.0);
          final isOverBudget = spent > budget.limit;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      budget.category,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Text(
                          "\₹${spent.toStringAsFixed(0)} / \₹${budget.limit.toStringAsFixed(0)}",
                          style: TextStyle(
                            color: isOverBudget ? AppColors.error : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // DELETE ICON FOR BUDGET
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
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade100,
                    color: isOverBudget ? AppColors.error : AppColors.accent,
                    minHeight: 6,
                  ),
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
