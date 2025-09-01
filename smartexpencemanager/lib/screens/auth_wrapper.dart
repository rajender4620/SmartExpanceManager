import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import 'login_screen.dart';
import 'splash_screen.dart';
import 'main_layout.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with TickerProviderStateMixin {
  AuthStatus? _previousStatus;
  late AnimationController _transitionController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));
    
    _transitionController.forward();
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Prevent back navigation from authenticated screens
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        final state = context.read<AuthBloc>().state;
        // Only allow back navigation if user is not authenticated
        if (state.status != AuthStatus.authenticated) {
          Navigator.of(context).pop();
        }
      },
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Handle smooth transitions between auth states
          if (_previousStatus != null && _previousStatus != state.status) {
            if (_previousStatus == AuthStatus.authenticated && 
                state.status == AuthStatus.unauthenticated) {
              // User just signed out - show smooth transition
              _transitionController.reset();
              _transitionController.forward();
            }
          }
          _previousStatus = state.status;
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            Widget child;
            
            switch (state.status) {
              case AuthStatus.initial:
              case AuthStatus.loading:
                child = const SplashScreen();
                break;
              case AuthStatus.authenticated:
                // Always show MainLayout for authenticated users
                // This prevents navigation stack issues
                child = const MainLayout();
                break;
              case AuthStatus.unauthenticated:
              case AuthStatus.error:
                child = const LoginScreen();
                break;
            }

            // Add smooth fade transition for sign-out
            if (_previousStatus == AuthStatus.authenticated && 
                state.status == AuthStatus.unauthenticated) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: child,
              );
            }

            return child;
          },
        ),
      ),
    );
  }
}
