import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand Colors (Light) ───────────────────────────────────────────────────
  static const Color primary = Color(0xFF0F6CBD);
  static const Color primaryLight = Color(0xFFEAF4FB);
  static const Color primaryBorder = Color(0xFFbfdbfe);
  static const Color darkBlue = Color(0xFF073B4C); // IUST Navy
  static const Color lightBlueprint = Color(0xFFf8fafc);
  static const Color textBody = Color(0xFF334155);
  static const Color textMuted = Color(0xFF6F7F89);
  static const Color textPrimary = darkBlue;
  static const Color textSecondary = textMuted;
  static const Color bgBlueprint = Color(0xFFfafbfc);
  static const Color lightBg = Color(0xFFF6F9FC);
  static const Color lightBorder = Color(0xFFDCE8EE);
  static const Color gold = Color(0xFFF5B82E);

  // ── Brand Colors (Dark Theme) ──────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF071822);
  static const Color darkSurface = Color(0xFF0E2232);
  static const Color darkSurfaceLighter = Color(0xFF142B3E);
  static const Color darkBorder = Color(0xFF1E3A52);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBlueAccent = Color(0xFF2A85FF);

  // ── Context Color Helpers ──────────────────────────────────────────────────
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color getBg(BuildContext context) =>
      isDark(context) ? darkBackground : lightBg;

  static Color getCardBg(BuildContext context) =>
      isDark(context) ? darkSurface : Colors.white;

  static Color getTextMain(BuildContext context) =>
      isDark(context) ? darkTextPrimary : const Color(0xFF0B2E3B);

  static Color getTextSub(BuildContext context) =>
      isDark(context) ? darkTextSecondary : textMuted;

  static Color getBorder(BuildContext context) =>
      isDark(context) ? darkBorder : lightBorder;

  static Color getLightBlue(BuildContext context) =>
      isDark(context) ? const Color(0xFF163248) : primaryLight;

  static Color getHeaderBg(BuildContext context) =>
      isDark(context) ? darkSurface : Colors.white;

  // ── 1. Light Theme ─────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.cairoTextTheme();
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: GoogleFonts.cairo().fontFamily,
      primaryColor: primary,
      scaffoldBackgroundColor: lightBg,
      cardColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: darkBlue,
        surface: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textBody, fontWeight: FontWeight.w400),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textBody, fontWeight: FontWeight.w400),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: textSecondary, fontWeight: FontWeight.w400),
        displayLarge: baseTextTheme.displayLarge?.copyWith(color: darkBlue, fontWeight: FontWeight.w700),
        displayMedium: baseTextTheme.displayMedium?.copyWith(color: darkBlue, fontWeight: FontWeight.w700),
        displaySmall: baseTextTheme.displaySmall?.copyWith(color: darkBlue, fontWeight: FontWeight.w700),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: darkBlue, fontWeight: FontWeight.w700),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: darkBlue, fontWeight: FontWeight.w700),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: darkBlue, fontWeight: FontWeight.w700),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: darkBlue, fontWeight: FontWeight.w600),
        titleSmall: baseTextTheme.titleSmall?.copyWith(color: darkBlue, fontWeight: FontWeight.w600),
        labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      primaryTextTheme: baseTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: darkBlue,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.cairo(
          color: darkBlue,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        titleTextStyle: GoogleFonts.cairo(
          color: darkBlue,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.cairo(
          color: textBody,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: gold,
        unselectedItemColor: textMuted,
        selectedLabelStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.white,
        filled: true,
        hintStyle: GoogleFonts.cairo(
          color: textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.cairo(
          color: textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: lightBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  // ── 2. Dark Theme ──────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.cairo().fontFamily,
      primaryColor: darkBlueAccent,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSurface,
      canvasColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: darkBlueAccent,
        secondary: gold,
        surface: darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: darkTextPrimary,
      ),
      textTheme: baseTextTheme.copyWith(
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w400),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w400),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: darkTextSecondary, fontWeight: FontWeight.w400),
        displayLarge: baseTextTheme.displayLarge?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w700),
        displayMedium: baseTextTheme.displayMedium?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w700),
        displaySmall: baseTextTheme.displaySmall?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w700),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w700),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w700),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w700),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w600),
        titleSmall: baseTextTheme.titleSmall?.copyWith(color: darkTextPrimary, fontWeight: FontWeight.w600),
        labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: darkTextPrimary),
      ),
      primaryTextTheme: baseTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.cairo(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        titleTextStyle: GoogleFonts.cairo(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.cairo(
          color: darkTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: gold,
        unselectedItemColor: darkTextSecondary,
        selectedLabelStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: darkSurfaceLighter,
        filled: true,
        hintStyle: GoogleFonts.cairo(
          color: darkTextSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.cairo(
          color: darkTextSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: darkBlueAccent, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          side: const BorderSide(color: darkBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
