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
