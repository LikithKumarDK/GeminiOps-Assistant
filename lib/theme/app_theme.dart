import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Light Theme Palette
  static const Color primaryColor = Color(0xFF4F46E5); // Vibrant Indigo
  static const Color secondaryColor = Color(0xFF06B6D4); // Bright Cyan
  static const Color backgroundColor = Color(0xFFF8FAFC); // Very Light Slate
  static const Color surfaceColor = Colors.white;
  static const Color accentColor = Color(0xFF818CF8);

  // Light Style Gradients
  static const Color gradientStart = Color(0xFFF1F5F9);
  static const Color gradientEnd = Color(0xFFF8FAFC);
  static const Color userBubbleColor = Color(0xFF4F46E5);
  static const Color aiBubbleColor = Color(0xFFF1F5F9);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF1E293B), // Slate 800
    ),
    scaffoldBackgroundColor: backgroundColor,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white.withValues(alpha: 0.8),
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1E293B),
        letterSpacing: 0.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 4,
        shadowColor: primaryColor.withValues(alpha: 0.3),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),
  );
}
