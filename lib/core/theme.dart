import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF051A3A);
  static const Color surface = Color(0xFF082955);
  static const Color secondarySurface = Color(0xFF0B3970);
  static const Color border = Color(0xFF159DFF);
  static const Color cyan = Color(0xFF14D9FF);
  static const Color primaryBlue = Color(0xFF008CFF);
  static const Color purple = Color(0xFF8C3EFF);
  static const Color pink = Color(0xFFED36E8);
  static const Color gold = Color(0xFFFFB800);
  static const Color orange = Color(0xFFFF8A00);
  static const Color green = Color(0xFF45D21D);
  static const Color mutedText = Color(0xFFA8C2DF);
  
  static const Color white = Colors.white;
}

final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primaryBlue,
  fontFamily: 'Chakra Petch', // Using one of the fonts from assets
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: AppColors.mutedText),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 2),
      ),
    ),
  ),
);
