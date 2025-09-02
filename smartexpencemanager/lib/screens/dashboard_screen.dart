import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartexpencemanager/blocs/navigation/navigation_bloc.dart';
import 'package:smartexpencemanager/blocs/navigation/navigation_event.dart';
import 'package:smartexpencemanager/blocs/expense/expense_bloc.dart';
import 'package:smartexpencemanager/blocs/expense/expense_event.dart';
import 'package:smartexpencemanager/blocs/expense/expense_state.dart';
import 'package:smartexpencemanager/services/firestore_database.dart';

import 'package:smartexpencemanager/services/navigation_service.dart';
import 'package:smartexpencemanager/models/expense.dart';
import 'package:smartexpencemanager/models/expense_category.dart';

import 'package:smartexpencemanager/blocs/auth/auth_bloc.dart';
import 'package:smartexpencemanager/blocs/auth/auth_state.dart';
import 'package:smartexpencemanager/utils/auth_utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Load current month data
    context.read<ExpenseBloc>().add(const LoadExpensesByTimeRange('Month'));

    // Start animations
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state.status == ExpenseStatus.loading) {
          return _buildLoadingState();
        }

        // Calculate enhanced dashboard metrics
        final currentMonthTotal = state.totalExpenses;
        final transactionCount = state.expenses.length;
        final now = DateTime.now();
        final daysInMonth = now.day;
        final avgPerDay =
            daysInMonth > 0 ? currentMonthTotal / daysInMonth : 0.0;
        final recentExpenses = state.expenses.take(5).toList();
        final daysRemaining =
            DateTime(now.year, now.month + 1, 0).day - now.day;
        final projectedSpending =
            currentMonthTotal + (avgPerDay * daysRemaining);

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: _buildModernAppBar(context),
          body: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.5, 1.0],
                        colors: [
                          Theme.of(context).colorScheme.surface,
                          Theme.of(
                            context,
                          ).colorScheme.surface.withOpacity(0.98),
                          Theme.of(context).colorScheme.surface,
                        ],
                      ),
                    ),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<ExpenseBloc>().add(
                          const RefreshExpenses(),
                        );
                        _animationController.reset();
                        _animationController.forward();
                      },
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: MediaQuery.of(context).padding.top + 60,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      FirebaseFirestoreDb().getUser(
                                        firebaseAuth.currentUser!.uid,
                                      );
                                    },
                                    child: _buildWelcomeHeader(context),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildSpendingOverview(
                                    context,
                                    currentMonthTotal,
                                    transactionCount,
                                    avgPerDay,
                                    projectedSpending,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildQuickActions(context),
                                  const SizedBox(height: 24),
                                  _buildCategoryOverview(context, state),
                                  const SizedBox(height: 24),
                                  if (recentExpenses.isNotEmpty) ...[
                                    _buildRecentExpensesSection(
                                      context,
                                      recentExpenses,
                                    ),
                                    const SizedBox(height: 24),
                                    _buildSmartInsightsSection(context, state),
                                  ] else ...[
                                    _buildGettingStartedSection(context),
                                  ],
                                  const SizedBox(height: 100), // Space for FAB
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          floatingActionButton: ScaleTransition(
            scale: _fabScaleAnimation,
            child: _buildSmartFAB(context),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Loading your financial overview...',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildModernAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: Row(
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Theme.of(context).brightness == Brightness.dark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  // Toggle theme - you'll need to implement this
                },
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState.isAuthenticated) {
                    return PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child:
                              authState.userPhotoUrl != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.network(
                                      authState.userPhotoUrl!,
                                      width: 36,
                                      height: 36,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Icon(
                                          Icons.person,
                                          size: 20,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        );
                                      },
                                    ),
                                  )
                                  : Icon(
                                    Icons.person,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'logout') {
                          _showLogoutDialog(context);
                        }
                      },
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'profile',
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          authState.userName ?? 'User',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          authState.userEmail ?? '',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem(
                              value: 'logout',
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.logout_rounded,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Sign Out',
                                      style: GoogleFonts.poppins(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final now = DateTime.now();
        final hour = now.hour;
        String greeting = 'Good morning';
        if (hour >= 12 && hour < 17) greeting = 'Good afternoon';
        if (hour >= 17) greeting = 'Good evening';

        return Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                authState.userName?.split(' ').first ?? 'User',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpendingOverview(
    BuildContext context,
    double currentMonthTotal,
    int transactionCount,
    double avgPerDay,
    double projectedSpending,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Month\'s Spending',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${currentMonthTotal.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  currentMonthTotal > 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_flat_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSpendingStat(
                  context,
                  'Transactions',
                  '$transactionCount',
                  Icons.receipt_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSpendingStat(
                  context,
                  'Daily Average',
                  '₹${avgPerDay.toStringAsFixed(0)}',
                  Icons.calendar_today_rounded,
                ),
              ),
            ],
          ),
          if (projectedSpending > currentMonthTotal) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.insights_rounded,
                    color: Colors.white.withOpacity(0.9),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Projected: ₹${projectedSpending.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpendingStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Add Expense',
                  Icons.add_circle_outline_rounded,
                  Theme.of(context).colorScheme.primary,
                  () async {
                    final result = await Navigator.pushNamed(
                      context,
                      NavigationService.expenseForm,
                    );
                    if (result != null) {
                      context.read<ExpenseBloc>().add(const RefreshExpenses());
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  'View Reports',
                  Icons.analytics_outlined,
                  Theme.of(context).colorScheme.secondary,
                  () {
                    context.read<NavigationBloc>().add(
                      const UpdateNavigationIndex(2),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Insights',
                  Icons.lightbulb_outline_rounded,
                  Colors.amber.shade700,
                  () {
                    context.read<NavigationBloc>().add(
                      const UpdateNavigationIndex(3),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  'All Expenses',
                  Icons.list_alt_rounded,
                  Colors.teal.shade600,
                  () {
                    context.read<NavigationBloc>().add(
                      const UpdateNavigationIndex(1),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryOverview(BuildContext context, ExpenseState state) {
    if (state.categoryTotals.isEmpty) return const SizedBox.shrink();

    final topCategories =
        state.categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value))
          ..take(4);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Categories',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<NavigationBloc>().add(
                    const UpdateNavigationIndex(2),
                  );
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...topCategories.map((entry) {
            final percentage = (entry.value / state.totalExpenses * 100);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCategoryItem(
                context,
                entry.key,
                entry.value,
                percentage,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String category,
    double amount,
    double percentage,
  ) {
    final categoryIcon = _getCategoryIcon(category);
    final categoryColor = _getCategoryColor(category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: categoryColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(categoryIcon, color: categoryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: categoryColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: categoryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExpensesSection(
    BuildContext context,
    List<Expense> recentExpenses,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Expenses',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<NavigationBloc>().add(
                    const UpdateNavigationIndex(1),
                  );
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recentExpenses
              .take(3)
              .map((expense) => _buildModernExpenseItem(context, expense)),
        ],
      ),
    );
  }

  Widget _buildModernExpenseItem(BuildContext context, Expense expense) {
    final categoryIcon = _getCategoryIcon(expense.category);
    final categoryColor = _getCategoryColor(expense.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(categoryIcon, color: categoryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        expense.category,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: categoryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '₹${expense.amount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartInsightsSection(BuildContext context, ExpenseState state) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<NavigationBloc>().add(const UpdateNavigationIndex(3));
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Smart Insights',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'AI',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Powered by advanced analytics',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Insights Preview Cards
                _buildInsightPreviewCards(context, state),

                const SizedBox(height: 20),

                // Action Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        context.read<NavigationBloc>().add(
                          const UpdateNavigationIndex(3),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.insights_rounded,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Unlock All Insights',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightPreviewCards(BuildContext context, ExpenseState state) {
    List<InsightCard> insights = [];

    if (state.expenses.isNotEmpty) {
      final now = DateTime.now();
      final thisWeek =
          state.expenses
              .where(
                (e) => e.date.isAfter(now.subtract(const Duration(days: 7))),
              )
              .toList();

      if (thisWeek.isNotEmpty) {
        final weekTotal = thisWeek.fold(0.0, (sum, e) => sum + e.amount);
        insights.add(
          InsightCard(
            icon: Icons.trending_up_rounded,
            title: 'Weekly Spending',
            value: '₹${weekTotal.toStringAsFixed(0)}',
            trend: 'This Week',
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      }

      // Top category insight
      if (state.categoryTotals.isNotEmpty) {
        final topCategory = state.categoryTotals.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
        );
        insights.add(
          InsightCard(
            icon: Icons.star_rounded,
            title: 'Top Category',
            value: topCategory.key,
            trend: '₹${topCategory.value.toStringAsFixed(0)}',
            color: Theme.of(context).colorScheme.secondary,
          ),
        );
      }

      // Transaction count
      insights.add(
        InsightCard(
          icon: Icons.receipt_long_rounded,
          title: 'Transactions',
          value: '${state.expenses.length}',
          trend: 'This Month',
          color: Theme.of(context).colorScheme.tertiary,
        ),
      );
    } else {
      // Default insights for empty state
      insights = [
        InsightCard(
          icon: Icons.lightbulb_outline_rounded,
          title: 'Get Started',
          value: 'Add expenses',
          trend: 'Unlock insights',
          color: Theme.of(context).colorScheme.primary,
        ),
        InsightCard(
          icon: Icons.analytics_outlined,
          title: 'Smart Analysis',
          value: 'AI powered',
          trend: 'Coming soon',
          color: Theme.of(context).colorScheme.secondary,
        ),
      ];
    }

    return Column(
      children: [
        if (insights.length >= 2)
          Row(
            children: [
              Expanded(child: _buildInsightCard(context, insights[0])),
              const SizedBox(width: 12),
              Expanded(child: _buildInsightCard(context, insights[1])),
            ],
          ),
        if (insights.length >= 3) ...[
          const SizedBox(height: 12),
          _buildInsightCard(context, insights[2]),
        ],
      ],
    );
  }

  Widget _buildInsightCard(BuildContext context, InsightCard insight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: insight.color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: insight.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(insight.icon, color: insight.color, size: 18),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up_rounded,
                color: insight.color.withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight.title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            insight.value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            insight.trend,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: insight.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGettingStartedSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to Smart Expense Manager!',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Start tracking your expenses to unlock powerful insights about your spending habits and achieve your financial goals.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              _buildGettingStartedStep(
                context,
                Icons.add_circle_outline_rounded,
                'Add Your First Expense',
                'Record daily expenses to start tracking',
                Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              _buildGettingStartedStep(
                context,
                Icons.category_outlined,
                'Organize by Categories',
                'Categorize expenses for better insights',
                Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              _buildGettingStartedStep(
                context,
                Icons.analytics_outlined,
                'View Reports & Insights',
                'Analyze spending patterns and optimize budget',
                Colors.amber.shade600,
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  NavigationService.expenseForm,
                );
                if (result != null) {
                  context.read<ExpenseBloc>().add(const RefreshExpenses());
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'Add Your First Expense',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGettingStartedStep(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartFAB(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            NavigationService.expenseForm,
          );
          if (result != null) {
            context.read<ExpenseBloc>().add(const RefreshExpenses());
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add_rounded, size: 20),
        ),
        label: Text(
          'Add Expense',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    AuthUtils.showSignOutDialog(context);
  }

  IconData _getCategoryIcon(String category) {
    final categoryObj = ExpenseCategory.categories.firstWhere(
      (cat) => cat.name == category,
      orElse: () => ExpenseCategory.categories.last, // Default to "Other"
    );
    return categoryObj.icon;
  }

  Color _getCategoryColor(String category) {
    // Define colors for different categories
    switch (category.toLowerCase()) {
      case 'food & dining':
        return Colors.orange;
      case 'transportation':
        return Colors.blue;
      case 'shopping':
        return Colors.purple;
      case 'entertainment':
        return Colors.pink;
      case 'bills & utilities':
        return Colors.red;
      case 'healthcare':
        return Colors.green;
      case 'education':
        return Colors.indigo;
      case 'travel':
        return Colors.teal;
      case 'business':
        return Colors.brown;
      case 'family':
        return Colors.amber;
      case 'personal care':
        return Colors.cyan;
      case 'gifts & donations':
        return Colors.deepPurple;
      case 'investments':
        return Colors.lightGreen;
      case 'insurance':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }
}

class InsightCard {
  final IconData icon;
  final String title;
  final String value;
  final String trend;
  final Color color;

  const InsightCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.trend,
    required this.color,
  });
}
