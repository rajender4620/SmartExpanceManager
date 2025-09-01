import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartexpencemanager/blocs/navigation/navigation_bloc.dart';
import 'package:smartexpencemanager/blocs/navigation/navigation_event.dart';
import 'package:smartexpencemanager/blocs/expense/expense_bloc.dart';
import 'package:smartexpencemanager/blocs/expense/expense_event.dart';
import 'package:smartexpencemanager/blocs/expense/expense_state.dart';

import 'package:smartexpencemanager/services/navigation_service.dart';
import 'package:smartexpencemanager/models/expense.dart';
import 'package:smartexpencemanager/models/expense_category.dart';
import 'package:smartexpencemanager/widgets/theme_toggle_widget.dart';
import 'package:smartexpencemanager/blocs/auth/auth_bloc.dart';
import 'package:smartexpencemanager/blocs/auth/auth_event.dart';
import 'package:smartexpencemanager/blocs/auth/auth_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load current month data
    context.read<ExpenseBloc>().add(const LoadExpensesByTimeRange('Month'));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state.status == ExpenseStatus.loading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Calculate dashboard metrics
        final currentMonthTotal = state.totalExpenses;
        final transactionCount = state.expenses.length;
        final now = DateTime.now();
        final daysInMonth = now.day;
        final avgPerDay = daysInMonth > 0 ? currentMonthTotal / daysInMonth : 0.0;
        final recentExpenses = state.expenses.take(5).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Dashboard',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              const ThemeToggleWidget(),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState.isAuthenticated) {
                    return PopupMenuButton<String>(
                      icon: CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: authState.userPhotoUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  authState.userPhotoUrl!,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 20,
                                      color: Colors.white,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 20,
                                color: Colors.white,
                              ),
                      ),
                      onSelected: (value) {
                        if (value == 'logout') {
                          _showLogoutDialog(context);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'profile',
                          child: Row(
                            children: [
                              Icon(Icons.person_outline),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authState.userName ?? 'User',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
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
                        PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.red),
                              SizedBox(width: 12),
                              Text(
                                'Sign Out',
                                style: GoogleFonts.poppins(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
              ),
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<ExpenseBloc>().add(const RefreshExpenses());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTotalBalanceCard(context, currentMonthTotal, transactionCount, avgPerDay),
                  const SizedBox(height: 24),
                  // Only show add expense button if there are existing expenses
                  if (recentExpenses.isNotEmpty) ...[
                    _buildAddExpenseButton(context),
                    const SizedBox(height: 24),
                  ],
                  _buildRecentExpensesCard(context, recentExpenses),
                  const SizedBox(height: 24),
                  // Only show AI insights if there are expenses to analyze
                  if (recentExpenses.isNotEmpty)
                    _buildAIInsightsCard(context)
                  else
                    _buildGettingStartedCard(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalBalanceCard(BuildContext context, double currentMonthTotal, int transactionCount, double avgPerDay) {
    final bool isEmpty = currentMonthTotal == 0 && transactionCount == 0;
    
    return Card(
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'This Month',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                if (isEmpty) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.celebration,
                    color: Colors.amber.shade200,
                    size: 20,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isEmpty ? '₹0.00' : '₹${currentMonthTotal.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (isEmpty)
              Text(
                'Ready to start tracking!',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickStat(
                  context,
                  'Transactions',
                  '$transactionCount',
                  Icons.receipt_long,
                  Colors.purple.shade300,
                ),
                _buildQuickStat(
                  context,
                  isEmpty ? 'Avg/Day' : 'Avg/Day',
                  isEmpty ? '₹0' : '₹${avgPerDay.toStringAsFixed(0)}',
                  Icons.trending_up,
                  Colors.teal.shade300,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context,
    String label,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                amount,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddExpenseButton(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.pushNamed(
            context,
            NavigationService.expenseForm,
          );
          if (result != null) {
            // Refresh data when returning from expense form
            context.read<ExpenseBloc>().add(const RefreshExpenses());
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Add New Expense',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentExpensesCard(BuildContext context, List<Expense> recentExpenses) {
    return Card(
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Update the bottom navigation index to Expenses tab
                    context.read<NavigationBloc>().add(
                      const UpdateNavigationIndex(1),
                    );
                  },
                  child: Text(
                    'See All',
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentExpenses.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Welcome to Smart Expense Manager!',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start tracking your expenses to get insights\nabout your spending habits',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            NavigationService.expenseForm,
                          );
                          if (result != null) {
                            context.read<ExpenseBloc>().add(const RefreshExpenses());
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        label: Text(
                          'Add Your First Expense',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recentExpenses.map((expense) => _buildExpenseItem(
                context,
                expense.title,
                '₹${expense.amount.toStringAsFixed(2)}',
                _getCategoryIcon(expense.category),
                expense.date,
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(
    BuildContext context,
    String title,
    String amount,
    IconData icon,
    DateTime date,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Insights',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Get personalized insights about your spending patterns and recommendations to optimize your budget.',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // Update the bottom navigation index to Insights tab
                context.read<NavigationBloc>().add(
                  const UpdateNavigationIndex(3),
                );
              },
              child: Text(
                'View Insights →',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGettingStartedCard(BuildContext context) {
    return ThemeAwareCard(
      useGradient: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Getting Started',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const ThemeToggleWidget(showLabel: true),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildTipItem(
                context,
                Icons.add_circle_outline,
                'Add Expenses',
                'Record your daily expenses to track spending',
              ),
              const SizedBox(height: 12),
              _buildTipItem(
                context,
                Icons.category_outlined,
                'Categorize',
                'Organize expenses by categories for better insights',
              ),
              const SizedBox(height: 12),
              _buildTipItem(
                context,
                Icons.analytics_outlined,
                'Analyze',
                'View reports and AI insights to optimize your budget',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Sign Out',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const SignOutRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Sign Out',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    final categoryObj = ExpenseCategory.categories.firstWhere(
      (cat) => cat.name == category,
      orElse: () => ExpenseCategory.categories.last, // Default to "Other"
    );
    return categoryObj.icon;
  }
}