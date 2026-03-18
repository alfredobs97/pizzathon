import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF8EEE3), 
      colorScheme: const ColorScheme(
        brightness: Brightness.light, 
        
        primary: Color(0xFFE36414),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFE36414), 
        onPrimaryContainer: Color(0xFFF8EEE3),
        
        secondary: Color(0xFF540B0E),
        onSecondary: Color(0xFFF8EEE3),
        secondaryContainer: Color(0xFF540B0E), 
        onSecondaryContainer: Color(0xFFF1DAC1),
        
        error: Colors.redAccent,
        onError: Colors.white,
        surface: Color(0xFF1E1E1E), 
        onSurface: Colors.white,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Archivo Black',
          fontSize: 24,
          fontWeight: FontWeight.w900, 
        ),
        displayMedium: TextStyle(
          fontFamily: 'Archivo Black',
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Archivo',
          fontSize: 20,
          fontWeight: FontWeight.w400, 
        ),
      ),
    );
  }
}