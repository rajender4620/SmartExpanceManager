import '../models/insight.dart';
import '../models/expense.dart';
import '../services/database_service.dart';

class InsightsService {
  static const double SPENDING_INCREASE_THRESHOLD = 0.2; // 20% increase
  static const double BUDGET_WARNING_THRESHOLD = 0.8; // 80% of budget
  static const int MIN_TRANSACTIONS_FOR_INSIGHTS = 3;

  static Future<List<Insight>> generateInsights() async {
    final databaseService = DatabaseService();
    final List<Insight> insights = [];
    
    try {
      // Get current month expenses
      final currentMonthExpenses = await databaseService.getCurrentMonthExpenses();
      
      // Get previous month expenses for comparison
      final now = DateTime.now();
      final previousMonthStart = DateTime(now.year, now.month - 1, 1);
      final previousMonthEnd = DateTime(now.year, now.month, 0);
      final previousMonthExpenses = await databaseService.getExpensesByDateRange(
        previousMonthStart,
        previousMonthEnd,
      );

      // Generate category-based insights
      insights.addAll(await _generateCategoryInsights(
        currentMonthExpenses,
        previousMonthExpenses,
      ));

      // Generate spending pattern insights
      insights.addAll(await _generateSpendingPatternInsights(currentMonthExpenses));

      // Generate budget insights
      insights.addAll(await _generateBudgetInsights(currentMonthExpenses));

      // Generate trend insights
      insights.addAll(await _generateTrendInsights(currentMonthExpenses));

      // Generate savings insights
      insights.addAll(await _generateSavingsInsights(currentMonthExpenses, previousMonthExpenses));

    } catch (e) {
      insights.add(Insight(
        message: 'Unable to generate insights at this time. Please try again later.',
        type: InsightType.info,
        timestamp: DateTime.now(),
      ));
    }

    // If no specific insights, add general tips
    if (insights.isEmpty) {
      insights.addAll(_getGeneralTips());
    }

    // Sort by importance (warnings first, then tips)
    insights.sort((a, b) {
      const typeOrder = {
        InsightType.warning: 0,
        InsightType.success: 1,
        InsightType.info: 2,
        InsightType.tip: 3,
      };
      return (typeOrder[a.type] ?? 3).compareTo(typeOrder[b.type] ?? 3);
    });

    return insights.take(6).toList(); // Limit to 6 insights
  }

  static Future<List<Insight>> _generateCategoryInsights(
    List<Expense> currentMonth,
    List<Expense> previousMonth,
  ) async {
    final List<Insight> insights = [];
    
    if (currentMonth.length < MIN_TRANSACTIONS_FOR_INSIGHTS) {
      return insights;
    }

    // Group expenses by category
    final currentCategoryTotals = _groupByCategory(currentMonth);
    final previousCategoryTotals = _groupByCategory(previousMonth);

    for (final category in currentCategoryTotals.keys) {
      final currentTotal = currentCategoryTotals[category] ?? 0.0;
      final previousTotal = previousCategoryTotals[category] ?? 0.0;

      if (previousTotal > 0) {
        final changePercentage = (currentTotal - previousTotal) / previousTotal;
        
        if (changePercentage > SPENDING_INCREASE_THRESHOLD) {
          insights.add(Insight(
            message: 'You spent ${(changePercentage * 100).toStringAsFixed(1)}% more on $category this month compared to last month.',
            type: InsightType.warning,
            timestamp: DateTime.now(),
          ));
        } else if (changePercentage < -0.1) { // 10% decrease
          insights.add(Insight(
            message: 'Great job! You reduced $category spending by ${(changePercentage.abs() * 100).toStringAsFixed(1)}% this month.',
            type: InsightType.success,
            timestamp: DateTime.now(),
          ));
        }
      } else if (currentTotal > 0) {
        insights.add(Insight(
          message: 'New spending category detected: $category. Consider setting a budget for this category.',
          type: InsightType.info,
          timestamp: DateTime.now(),
        ));
      }
    }

    return insights;
  }

  static Future<List<Insight>> _generateSpendingPatternInsights(
    List<Expense> expenses,
  ) async {
    final List<Insight> insights = [];
    
    if (expenses.isEmpty) return insights;

    // Analyze spending frequency
    final dayOfWeekSpending = <int, double>{};
    for (final expense in expenses) {
      final dayOfWeek = expense.date.weekday;
      dayOfWeekSpending[dayOfWeek] = (dayOfWeekSpending[dayOfWeek] ?? 0) + expense.amount;
    }

    // Find highest spending day
    final maxSpendingDay = dayOfWeekSpending.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = dayNames[maxSpendingDay.key - 1];

    insights.add(Insight(
      message: 'You tend to spend most on $dayName. Consider planning your budget accordingly.',
      type: InsightType.tip,
      timestamp: DateTime.now(),
    ));

    return insights;
  }

  static Future<List<Insight>> _generateBudgetInsights(
    List<Expense> expenses,
  ) async {
    final List<Insight> insights = [];
    
    if (expenses.isEmpty) return insights;

    final totalSpending = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysElapsed = now.day;
    
    // Simple budget estimation based on spending rate
    final dailySpendingRate = totalSpending / daysElapsed;
    final projectedMonthlySpending = dailySpendingRate * daysInMonth;

    if (daysElapsed > 15) { // Only provide projection after mid-month
      insights.add(Insight(
        message: 'At your current spending rate, you\'re projected to spend ₹${projectedMonthlySpending.toStringAsFixed(2)} this month.',
        type: InsightType.info,
        timestamp: DateTime.now(),
      ));
    }

    return insights;
  }

  static Future<List<Insight>> _generateTrendInsights(
    List<Expense> expenses,
  ) async {
    final List<Insight> insights = [];
    
    if (expenses.length < 7) return insights; // Need at least a week of data

    // Analyze recent spending trend (last 7 days vs previous 7 days)
    final now = DateTime.now();
    final last7Days = expenses.where((expense) =>
        expense.date.isAfter(now.subtract(const Duration(days: 7)))).toList();
    final previous7Days = expenses.where((expense) =>
        expense.date.isAfter(now.subtract(const Duration(days: 14))) &&
        expense.date.isBefore(now.subtract(const Duration(days: 7)))).toList();

    if (last7Days.isNotEmpty && previous7Days.isNotEmpty) {
      final recentTotal = last7Days.fold(0.0, (sum, expense) => sum + expense.amount);
      final previousTotal = previous7Days.fold(0.0, (sum, expense) => sum + expense.amount);
      
      final trendPercentage = (recentTotal - previousTotal) / previousTotal;
      
      if (trendPercentage > 0.15) {
        insights.add(Insight(
          message: 'Your spending increased by ${(trendPercentage * 100).toStringAsFixed(1)}% in the last week.',
          type: InsightType.warning,
          timestamp: DateTime.now(),
        ));
      } else if (trendPercentage < -0.1) {
        insights.add(Insight(
          message: 'Your spending decreased by ${(trendPercentage.abs() * 100).toStringAsFixed(1)}% in the last week. Keep it up!',
          type: InsightType.success,
          timestamp: DateTime.now(),
        ));
      }
    }

    return insights;
  }

  static Future<List<Insight>> _generateSavingsInsights(
    List<Expense> currentMonth,
    List<Expense> previousMonth,
  ) async {
    final List<Insight> insights = [];
    
    if (currentMonth.isEmpty || previousMonth.isEmpty) return insights;

    final currentTotal = currentMonth.fold(0.0, (sum, expense) => sum + expense.amount);
    final previousTotal = previousMonth.fold(0.0, (sum, expense) => sum + expense.amount);
    
    final savings = previousTotal - currentTotal;
    
    if (savings > 0) {
      insights.add(Insight(
        message: 'You saved ₹${savings.toStringAsFixed(2)} this month compared to last month!',
        type: InsightType.success,
        timestamp: DateTime.now(),
      ));
    }

    return insights;
  }

  static Map<String, double> _groupByCategory(List<Expense> expenses) {
    final Map<String, double> categoryTotals = {};
    for (final expense in expenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  static List<Insight> _getGeneralTips() {
    return [
      Insight(
        message: 'Track your expenses daily to build better financial habits.',
        type: InsightType.tip,
        timestamp: DateTime.now(),
      ),
      Insight(
        message: 'Consider setting monthly budgets for each spending category.',
        type: InsightType.tip,
        timestamp: DateTime.now(),
      ),
      Insight(
        message: 'Review your spending patterns weekly to identify areas for improvement.',
        type: InsightType.tip,
        timestamp: DateTime.now(),
      ),
    ];
  }
}
