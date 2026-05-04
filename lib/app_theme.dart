import 'package:flutter/material.dart';

const kBackground = Color(0xFF1A1A2E);
const kSurface = Color(0xFF16213E);
const kCard = Color(0xFF0F3460);
const kOrange = Color(0xFFF5890E);
const kOnSurface = Color(0xFFE0E0E0);
const kGreen = Color(0xFF00C49A);
const kRed = Color(0xFFFF6B6B);
const kGrey = Color(0xFF555577);

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBackground,
    colorScheme: const ColorScheme.dark(
      primary: kOrange,
      secondary: kOrange,
      surface: kSurface,
      onSurface: kOnSurface,
      error: kRed,
    ),
    cardTheme: CardThemeData(
      color: kCard,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kSurface,
      foregroundColor: kOnSurface,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kOrange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? kOrange : kGrey,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? kOrange.withAlpha(100)
            : kGrey.withAlpha(80),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kOrange),
      ),
      labelStyle: const TextStyle(color: kOnSurface),
    ),
    dividerColor: kGrey.withAlpha(80),
  );
}
