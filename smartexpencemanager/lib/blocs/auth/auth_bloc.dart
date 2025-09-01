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
    on<EmailSignInRequested>(_onEmailSignInRequested);
    on<EmailSignUpRequested>(_onEmailSignUpRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
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
        // Firebase user is null, user is not authenticated
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        // Clear any stale SharedPreferences data
        await _authService.signOut();
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

  Future<void> _onEmailSignInRequested(EmailSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          userEmail: user.email,
          userName: user.displayName,
          userPhotoUrl: user.photoURL,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onEmailSignUpRequested(EmailSignUpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      final userCredential = await _authService.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
        name: event.name,
      );
      
      final user = userCredential.user;
      if (user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          userEmail: user.email,
          userName: user.displayName,
          userPhotoUrl: user.photoURL,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onPasswordResetRequested(PasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      await _authService.resetPassword(event.email);
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Password reset email sent. Please check your inbox.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
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
