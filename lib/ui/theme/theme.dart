import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

      textTheme: TextTheme(
        displayLarge: GoogleFonts.archivoBlack(fontSize: 24, fontWeight: FontWeight.w900),
        displayMedium: GoogleFonts.archivoBlack(fontSize: 20, fontWeight: FontWeight.w900),
        titleLarge: GoogleFonts.archivo(fontSize: 20, fontWeight: FontWeight.w400),
        bodyLarge: GoogleFonts.archivoBlack(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.archivo(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
