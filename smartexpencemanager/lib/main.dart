import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartexpencemanager/blocs/navigation/navigation_bloc.dart';
import 'package:smartexpencemanager/screens/splash_screen.dart';
import 'package:smartexpencemanager/theme/app_theme.dart';
import 'package:smartexpencemanager/services/navigation_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationBloc(),
      child: MaterialApp(
        title: 'SmartExpense Manager',
        theme: AppTheme.lightTheme,
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: NavigationService.splash,
        onGenerateRoute: NavigationService.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
