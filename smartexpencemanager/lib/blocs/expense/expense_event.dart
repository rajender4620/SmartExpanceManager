import 'package:equatable/equatable.dart';
import '../../models/expense.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  const LoadExpenses();
}

class LoadExpensesByDateRange extends ExpenseEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadExpensesByDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}

class LoadExpensesByTimeRange extends ExpenseEvent {
  final String timeRange; // 'Week', 'Month', 'Year'

  const LoadExpensesByTimeRange(this.timeRange);

  @override
  List<Object> get props => [timeRange];
}

class AddExpense extends ExpenseEvent {
  final Expense expense;

  const AddExpense(this.expense);

  @override
  List<Object> get props => [expense];
}

class UpdateExpense extends ExpenseEvent {
  final Expense expense;

  const UpdateExpense(this.expense);

  @override
  List<Object> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final String expenseId;

  const DeleteExpense(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

class RefreshExpenses extends ExpenseEvent {
  const RefreshExpenses();
}
