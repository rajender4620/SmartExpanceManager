import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

class EmailSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const EmailSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class EmailSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const EmailSignUpRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class AuthStateChanged extends AuthEvent {
  final bool isAuthenticated;
  final String? userEmail;
  final String? userName;
  final String? userPhotoUrl;

  const AuthStateChanged({
    required this.isAuthenticated,
    this.userEmail,
    this.userName,
    this.userPhotoUrl,
  });

  @override
  List<Object?> get props => [isAuthenticated, userEmail, userName, userPhotoUrl];
}
