import 'package:flutter/material.dart';

class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;

  const ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  static List<ExpenseCategory> categories = [
    ExpenseCategory(
      name: 'Food & Dining',
      icon: Icons.restaurant,
      color: Color(0xFFFF9E80),
    ),
    ExpenseCategory(
      name: 'Travel',
      icon: Icons.flight,
      color: Color(0xFF80DEEA),
    ),
    ExpenseCategory(
      name: 'Bills & Utilities',
      icon: Icons.receipt_long,
      color: Color(0xFFB39DDB),
    ),
    ExpenseCategory(
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Color(0xFFFFF59D),
    ),
    ExpenseCategory(
      name: 'Entertainment',
      icon: Icons.movie,
      color: Color(0xFFFFCC80),
    ),
    ExpenseCategory(
      name: 'Healthcare',
      icon: Icons.medical_services,
      color: Color(0xFF80CBC4),
    ),
    ExpenseCategory(
      name: 'Education',
      icon: Icons.school,
      color: Color(0xFFCE93D8),
    ),
    ExpenseCategory(
      name: 'Other',
      icon: Icons.more_horiz,
      color: Color(0xFFB0BEC5),
    ),
  ];
}
