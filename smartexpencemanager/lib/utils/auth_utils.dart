import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartexpencemanager/blocs/auth/auth_bloc.dart';
import 'package:smartexpencemanager/blocs/auth/auth_event.dart';
import 'package:smartexpencemanager/blocs/auth/auth_state.dart';

class AuthUtils {
  /// Shows a comprehensive sign-out dialog with loading states and error handling
  static void showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.unauthenticated) {
              // Sign out successful
              Navigator.of(dialogContext).pop();
              _showSignOutSuccessMessage(context);
            } else if (state.hasError) {
              // Sign out failed
              Navigator.of(dialogContext).pop();
              _showSignOutError(context, state.errorMessage);
            }
          },
          builder: (context, state) {
            final isSigningOut = state.isLoading;
            
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sign Out',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to sign out of your account?',
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You will need to sign in again to access your expenses.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (isSigningOut) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Signing out...',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                if (!isSigningOut) ...[
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(const SignOutRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: Text(
                      'Sign Out',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  /// Shows a simple sign-out confirmation dialog (without BLoC integration)
  static void showQuickSignOutDialog(BuildContext context, {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Sign Out',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onConfirm != null) {
                  onConfirm();
                } else {
                  context.read<AuthBloc>().add(const SignOutRequested());
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                'Sign Out',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Direct sign-out without confirmation (use with caution)
  static void signOutDirectly(BuildContext context) {
    context.read<AuthBloc>().add(const SignOutRequested());
  }

  /// Show success message after sign-out
  static void _showSignOutSuccessMessage(BuildContext context) {
    // Small delay to ensure the dialog is dismissed
    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Successfully signed out',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    });
  }

  /// Show error message if sign-out fails
  static void _showSignOutError(BuildContext context, String? errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage ?? 'Sign out failed'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => showSignOutDialog(context),
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Check if user is currently authenticated
  static bool isAuthenticated(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState.isAuthenticated;
  }

  /// Get current user information
  static Map<String, String?> getCurrentUserInfo(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return {
      'email': authState.userEmail,
      'name': authState.userName,
      'photoUrl': authState.userPhotoUrl,
    };
  }
}
