import 'package:equatable/equatable.dart';
import '../../models/expense.dart';

enum ExpenseStatus { initial, loading, success, failure }

class ExpenseState extends Equatable {
  final ExpenseStatus status;
  final List<Expense> expenses;
  final Map<String, double> categoryTotals;
  final Map<String, List<Expense>> expensesByCategory;
  final List<Map<String, dynamic>> trendData;
  final double totalExpenses;
  final String? errorMessage;

  const ExpenseState({
    this.status = ExpenseStatus.initial,
    this.expenses = const [],
    this.categoryTotals = const {},
    this.expensesByCategory = const {},
    this.trendData = const [],
    this.totalExpenses = 0.0,
    this.errorMessage,
  });

  ExpenseState copyWith({
    ExpenseStatus? status,
    List<Expense>? expenses,
    Map<String, double>? categoryTotals,
    Map<String, List<Expense>>? expensesByCategory,
    List<Map<String, dynamic>>? trendData,
    double? totalExpenses,
    String? errorMessage,
  }) {
    return ExpenseState(
      status: status ?? this.status,
      expenses: expenses ?? this.expenses,
      categoryTotals: categoryTotals ?? this.categoryTotals,
      expensesByCategory: expensesByCategory ?? this.expensesByCategory,
      trendData: trendData ?? this.trendData,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        expenses,
        categoryTotals,
        expensesByCategory,
        trendData,
        totalExpenses,
        errorMessage,
      ];
}
