import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

/// Persists the user's theme preference and notifies listeners on change.
class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  final ValueNotifier<ThemeMode> mode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  /// Accent (seed) color for the app theme.
  final ValueNotifier<Color> accentColor =
      ValueNotifier<Color>(const Color(0xFF6366F1));

  static const List<Color> accentOptions = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF10B981), // Green
    Color(0xFF3B82F6), // Blue
    Color(0xFFEC4899), // Pink
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Purple
    Color(0xFF14B8A6), // Teal
    Color(0xFFEF4444), // Red
  ];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(StorageKeys.themeMode);
    mode.value = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final savedAccent = prefs.getInt(StorageKeys.accentColor);
    if (savedAccent != null) {
      accentColor.value = Color(savedAccent);
    }
  }

  Future<void> setMode(ThemeMode value) async {
    mode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.themeMode, value.name);
  }

  Future<void> setAccentColor(Color color) async {
    accentColor.value = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageKeys.accentColor, color.toARGB32());
  }
}
