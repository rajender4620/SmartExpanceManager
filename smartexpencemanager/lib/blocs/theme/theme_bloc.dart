import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeBloc() : super(ThemeState.initial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
    on<SetTheme>(_onSetTheme);
    
    // Load saved theme on initialization
    add(const LoadTheme());
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_themeKey) ?? 0;
      final themeMode = ThemeMode.values[themeModeIndex];
      
      emit(state.copyWith(
        themeMode: themeMode,
        isDarkMode: themeMode == ThemeMode.dark,
      ));
    } catch (e) {
      // If loading fails, use default light theme
      emit(ThemeState.initial());
    }
  }

  Future<void> _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) async {
    final newThemeMode = state.isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await _saveThemeMode(newThemeMode);
    
    emit(state.copyWith(
      themeMode: newThemeMode,
      isDarkMode: newThemeMode == ThemeMode.dark,
    ));
  }

  Future<void> _onSetTheme(SetTheme event, Emitter<ThemeState> emit) async {
    await _saveThemeMode(event.themeMode);
    
    emit(state.copyWith(
      themeMode: event.themeMode,
      isDarkMode: event.themeMode == ThemeMode.dark,
    ));
  }

  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);
    } catch (e) {
      // Handle error silently for now
      debugPrint('Error saving theme: $e');
    }
  }
}
