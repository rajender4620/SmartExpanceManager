import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/theme/theme_bloc.dart';
import '../blocs/theme/theme_event.dart';
import '../blocs/theme/theme_state.dart';

class ThemeToggleWidget extends StatelessWidget {
  final bool showLabel;
  final bool isFloatingActionButton;

  const ThemeToggleWidget({
    super.key,
    this.showLabel = false,
    this.isFloatingActionButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        if (isFloatingActionButton) {
          return FloatingActionButton(
            mini: true,
            heroTag: "theme_toggle",
            onPressed: () {
              context.read<ThemeBloc>().add(const ToggleTheme());
            },
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                themeState.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(themeState.isDarkMode),
                color: Colors.white,
              ),
            ),
          );
        }

        if (showLabel) {
          return InkWell(
            onTap: () {
              context.read<ThemeBloc>().add(const ToggleTheme());
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      themeState.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      key: ValueKey(themeState.isDarkMode),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    themeState.isDarkMode ? 'Light Mode' : 'Dark Mode',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return IconButton(
          onPressed: () {
            context.read<ThemeBloc>().add(const ToggleTheme());
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              themeState.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              key: ValueKey(themeState.isDarkMode),
            ),
          ),
          tooltip: themeState.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
        );
      },
    );
  }
}

class ThemeAwareCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final bool useGradient;

  const ThemeAwareCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: elevation ?? (isDarkMode ? 4 : 2),
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Container(
        padding: padding,
        decoration: useGradient ? BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode ? [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ] : [
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ],
          ),
        ) : null,
        child: child,
      ),
    );
  }
}
