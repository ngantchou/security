import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFFFF3B30); // Red for alerts
  static const Color secondaryColor = Color(0xFF007AFF); // Blue
  static const Color accentColor = Color(0xFF34C759); // Green
  static const Color warningColor = Color(0xFFFF9500); // Orange
  static const Color errorColor = Color(0xFFFF3B30); // Red
  static const Color backgroundColor = Color(0xFFF2F2F7);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimaryColor = Color(0xFF000000);
  static const Color textSecondaryColor = Color(0xFF8E8E93);
  static const Color dividerColor = Color(0xFFE5E5EA);

  // Alert Level Colors
  static const Color level1Color = Color(0xFF34C759); // Green - Low
  static const Color level2Color = Color(0xFFFFCC00); // Yellow - Medium-Low
  static const Color level3Color = Color(0xFFFF9500); // Orange - Medium
  static const Color level4Color = Color(0xFFFF6B6B); // Red-Orange - High
  static const Color level5Color = Color(0xFFFF3B30); // Red - Critical

  // Danger Type Colors
  static const Map<String, Color> dangerTypeColors = {
    'fire': Color(0xFFFF3B30),
    'flood': Color(0xFF007AFF),
    'armedRobbery': Color(0xFF8E8E93),
    'kidnapping': Color(0xFFFF2D55),
    'separatistConflict': Color(0xFF5856D6),
    'bokoHaram': Color(0xFFAF52DE),
    'landslide': Color(0xFF8B4513),
    'riot': Color(0xFFFF9500),
    'accident': Color(0xFFFFCC00),
    'medicalEmergency': Color(0xFFFF375F),
    'epidemic': Color(0xFF5AC8FA),
    'livestockTheft': Color(0xFF32ADE6),
    'naturalDisaster': Color(0xFF64D2FF),
    'other': Color(0xFF8E8E93),
  };

  static Color getAlertLevelColor(int level) {
    switch (level) {
      case 1:
        return level1Color;
      case 2:
        return level2Color;
      case 3:
        return level3Color;
      case 4:
        return level4Color;
      case 5:
        return level5Color;
      default:
        return textSecondaryColor;
    }
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: cardColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: cardColor,
        foregroundColor: textPrimaryColor,
        iconTheme: IconThemeData(color: textPrimaryColor),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: cardColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundColor,
        selectedColor: primaryColor.withOpacity(0.2),
        labelStyle: const TextStyle(color: textPrimaryColor),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: const Color(0xFF1C1C1E),
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF1C1C1E),
        foregroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFF1C1C1E),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: Color(0xFF1C1C1E),
        selectedItemColor: primaryColor,
        unselectedItemColor: Color(0xFF8E8E93),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
