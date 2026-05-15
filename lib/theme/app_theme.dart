import 'package:flutter/material.dart';

const kBackground = Color(0xFF000000);
const kSurface = Color(0xFF0D0D0D);
const kCardBorder = Color(0xFF1A1A1A);
const kEmerald = Color(0xFF00FF88);
const kAmber = Color(0xFFFFB300);
const kCrimson = Color(0xFFFF1744);
const kTextPrimary = Color(0xFFFFFFFF);
const kTextSecondary = Color(0xFF8A8A8A);

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBackground,
    colorScheme: const ColorScheme.dark(
      primary: kEmerald,
      secondary: kAmber,
      error: kCrimson,
      surface: kSurface,
      onPrimary: kBackground,
      onSurface: kTextPrimary,
    ),
    cardColor: kSurface,
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(color: kTextSecondary),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBackground,
      elevation: 0,
      centerTitle: true,
    ),
  );
}
