import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartexpencemanager/blocs/navigation/navigation_bloc.dart';
import 'package:smartexpencemanager/blocs/expense/expense_bloc.dart';
import 'package:smartexpencemanager/blocs/theme/theme_bloc.dart';
import 'package:smartexpencemanager/blocs/theme/theme_state.dart';
import 'package:smartexpencemanager/blocs/auth/auth_bloc.dart';
import 'package:smartexpencemanager/theme/app_theme.dart';
import 'package:smartexpencemanager/services/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationBloc>(
          create: (_) => NavigationBloc(),
        ),
        BlocProvider<ExpenseBloc>(
          create: (_) => ExpenseBloc(),
        ),
        BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'SmartExpense Manager',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            navigatorKey: NavigationService.navigatorKey,
            initialRoute: NavigationService.authWrapper,
            onGenerateRoute: NavigationService.generateRoute,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
