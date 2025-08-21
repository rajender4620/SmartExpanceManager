import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartexpencemanager/blocs/navigation/navigation_bloc.dart';
import 'package:smartexpencemanager/blocs/navigation/navigation_event.dart';
import 'package:smartexpencemanager/screens/expense_form_screen.dart';
import 'package:smartexpencemanager/screens/main_layout.dart';
import 'package:smartexpencemanager/screens/onboarding_screen.dart';
import 'package:smartexpencemanager/screens/splash_screen.dart';
import 'package:smartexpencemanager/test_database.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String expenses = '/expenses';
  static const String reports = '/reports';
  static const String insights = '/insights';
  static const String expenseForm = '/expense-form';
  static const String databaseTest = '/database-test';

  /// Navigate to a specific tab in the main layout
  static void navigateToTab(BuildContext context, int tabIndex) {
    final routes = [dashboard, expenses, reports, insights];
    if (tabIndex >= 0 && tabIndex < routes.length) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        routes[tabIndex],
        (route) => false,
      );
    }
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case dashboard:
        return MaterialPageRoute(
          builder: (context) {
            // Update navigation state to Dashboard tab (index 0)
            context.read<NavigationBloc>().add(const UpdateNavigationIndex(0));
            return const MainLayout();
          },
          settings: const RouteSettings(name: dashboard),
        );
      case expenses:
        return MaterialPageRoute(
          builder: (context) {
            // Update navigation state to Expenses tab (index 1)
            context.read<NavigationBloc>().add(const UpdateNavigationIndex(1));
            return const MainLayout();
          },
          settings: const RouteSettings(name: expenses),
        );
      case reports:
        return MaterialPageRoute(
          builder: (context) {
            // Update navigation state to Reports tab (index 2)
            context.read<NavigationBloc>().add(const UpdateNavigationIndex(2));
            return const MainLayout();
          },
          settings: const RouteSettings(name: reports),
        );
      case insights:
        return MaterialPageRoute(
          builder: (context) {
            // Update navigation state to Insights tab (index 3)
            context.read<NavigationBloc>().add(const UpdateNavigationIndex(3));
            return const MainLayout();
          },
          settings: const RouteSettings(name: insights),
        );
      case expenseForm:
        final Map<String, dynamic>? expense =
            settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ExpenseFormScreen(expense: expense),
        );
      case databaseTest:
        return MaterialPageRoute(
          builder: (_) => const DatabaseTestScreen(),
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
