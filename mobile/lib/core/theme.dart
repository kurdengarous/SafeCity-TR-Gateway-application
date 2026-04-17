import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1976D2),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1976D2),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}

class AppColors {
  static const Color earthquake = Color(0xFFE53935);
  static const Color weather = Color(0xFF43A047);
  static const Color aqiGood = Color(0xFF4CAF50);
  static const Color aqiModerate = Color(0xFFFFEB3B);
  static const Color aqiUnhealthy = Color(0xFFFF5722);
  static const Color prayer = Color(0xFF9C27B0);
  static const Color currency = Color(0xFFFF9800);

  static Color getAQIColor(int aqi) {
    if (aqi <= 50) return aqiGood;
    if (aqi <= 100) return aqiModerate;
    if (aqi <= 150) return aqiUnhealthy;
    if (aqi <= 200) return const Color(0xFFE53935);
    if (aqi <= 300) return const Color(0xFF9C27B0);
    return const Color(0xFF880E4F);
  }

  static Color getMagnitudeColor(double magnitude) {
    if (magnitude < 3) return const Color(0xFF4CAF50);
    if (magnitude < 5) return const Color(0xFFFFEB3B);
    if (magnitude < 6) return const Color(0xFFFF9800);
    if (magnitude < 7) return const Color(0xFFFF5722);
    return const Color(0xFFE53935);
  }
}
