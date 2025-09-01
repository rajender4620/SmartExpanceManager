import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/expense.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final DatabaseService _databaseService;

  ExpenseBloc({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService(),
        super(const ExpenseState()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<LoadExpensesByDateRange>(_onLoadExpensesByDateRange);
    on<LoadExpensesByTimeRange>(_onLoadExpensesByTimeRange);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<RefreshExpenses>(_onRefreshExpenses);
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(state.copyWith(status: ExpenseStatus.loading));
    
    try {
      final expenses = await _databaseService.getAllExpenses();
      final categoryTotals = await _databaseService.getTotalExpensesByCategory();
      final expensesByCategory = _groupExpensesByCategory(expenses);
      final totalExpenses = categoryTotals.values.fold(0.0, (sum, value) => sum + value);
      final trendData = await _generateTrendData(expenses);

      emit(state.copyWith(
        status: ExpenseStatus.success,
        expenses: expenses,
        categoryTotals: categoryTotals,
        expensesByCategory: expensesByCategory,
        totalExpenses: totalExpenses,
        trendData: trendData,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadExpensesByDateRange(
    LoadExpensesByDateRange event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(state.copyWith(status: ExpenseStatus.loading));
    
    try {
      final expenses = await _databaseService.getExpensesByDateRange(
        event.startDate,
        event.endDate,
      );
      final expensesByCategory = _groupExpensesByCategory(expenses);
      final categoryTotals = _calculateCategoryTotals(expensesByCategory);
      final totalExpenses = categoryTotals.values.fold(0.0, (sum, value) => sum + value);
      final trendData = await _generateTrendData(expenses);

      emit(state.copyWith(
        status: ExpenseStatus.success,
        expenses: expenses,
        categoryTotals: categoryTotals,
        expensesByCategory: expensesByCategory,
        totalExpenses: totalExpenses,
        trendData: trendData,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadExpensesByTimeRange(
    LoadExpensesByTimeRange event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(state.copyWith(status: ExpenseStatus.loading));
    
    try {
      final now = DateTime.now();
      late DateTime startDate;
      late DateTime endDate;

      switch (event.timeRange) {
        case 'Week':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          startDate = DateTime(startDate.year, startDate.month, startDate.day);
          endDate = startDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
          break;
        case 'Month':
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          break;
        case 'Year':
          startDate = DateTime(now.year, 1, 1);
          endDate = DateTime(now.year, 12, 31, 23, 59, 59);
          break;
        default:
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      }

      add(LoadExpensesByDateRange(startDate: startDate, endDate: endDate));
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await _databaseService.insertExpense(event.expense);
      add(const RefreshExpenses());
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await _databaseService.updateExpense(event.expense);
      add(const RefreshExpenses());
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await _databaseService.deleteExpense(event.expenseId);
      add(const RefreshExpenses());
    } catch (e) {
      emit(state.copyWith(
        status: ExpenseStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshExpenses(
    RefreshExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    add(const LoadExpenses());
  }

  Map<String, List<Expense>> _groupExpensesByCategory(List<Expense> expenses) {
    final Map<String, List<Expense>> grouped = {};
    for (final expense in expenses) {
      if (!grouped.containsKey(expense.category)) {
        grouped[expense.category] = [];
      }
      grouped[expense.category]!.add(expense);
    }
    return grouped;
  }

  Map<String, double> _calculateCategoryTotals(Map<String, List<Expense>> expensesByCategory) {
    final Map<String, double> totals = {};
    expensesByCategory.forEach((category, expenses) {
      totals[category] = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    });
    return totals;
  }

  Future<List<Map<String, dynamic>>> _generateTrendData(List<Expense> expenses) async {
    final now = DateTime.now();
    final List<Map<String, dynamic>> trendData = [];
    
    // Generate data for the last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final dayExpenses = expenses.where((expense) =>
          expense.date.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
          expense.date.isBefore(dayEnd.add(const Duration(seconds: 1)))).toList();
      
      final dayTotal = dayExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
      
      trendData.add({
        'day': DateFormat('EEE').format(date),
        'date': date,
        'amount': dayTotal,
      });
    }
    
    return trendData;
  }
}
