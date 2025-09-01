import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  AuthBloc() : super(AuthState.initial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

    // Listen to Firebase auth state changes
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        add(AuthStateChanged(
          isAuthenticated: true,
          userEmail: user.email,
          userName: user.displayName,
          userPhotoUrl: user.photoURL,
        ));
      } else {
        add(const AuthStateChanged(isAuthenticated: false));
      }
    });

    // Check auth status on app start
    add(const CheckAuthStatus());
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          userEmail: currentUser.email,
          userName: currentUser.displayName,
          userPhotoUrl: currentUser.photoURL,
        ));
      } else {
        // Check if user was logged in before (from SharedPreferences)
        final isLoggedIn = await _authService.isLoggedIn();
        if (isLoggedIn) {
          final userData = await _authService.getUserDataFromPrefs();
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            userEmail: userData['email'],
            userName: userData['name'],
            userPhotoUrl: userData['photoUrl'],
          ));
        } else {
          emit(state.copyWith(status: AuthStatus.unauthenticated));
        }
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to check authentication status',
      ));
    }
  }

  Future<void> _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential != null && userCredential.user != null) {
        final user = userCredential.user!;
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          userEmail: user.email,
          userName: user.displayName,
          userPhotoUrl: user.photoURL,
        ));
      } else {
        // User canceled the sign-in
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Google Sign-In failed. Please try again.',
      ));
    }
  }

  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      await _authService.signOut();
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Sign out failed. Please try again.',
      ));
    }
  }

  Future<void> _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) async {
    if (event.isAuthenticated) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        userEmail: event.userEmail,
        userName: event.userName,
        userPhotoUrl: event.userPhotoUrl,
      ));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }
}
