import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NYTColors {
  static const black = Color(0xFF121212);
  static const white = Color(0xFFFAF9F6);
  static const lightGrey = Color(0xFFF7F7F5);
  static const midGrey = Color(0xFFDEDEDE);
  static const darkGrey = Color(0xFF666666);
  static const accent = Color(0xFFB94040); // NYT red
  static const gold = Color(0xFFB5A642);
  static const sectionBlue = Color(0xFF326891);
}

class NYTTheme {
  static ThemeData get theme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: NYTColors.white,
        colorScheme: ColorScheme.light(
          primary: NYTColors.black,
          secondary: NYTColors.accent,
          surface: NYTColors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: NYTColors.white,
          foregroundColor: NYTColors.black,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: NYTColors.midGrey,
          titleTextStyle: GoogleFonts.unna(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: NYTColors.black,
            letterSpacing: 0.5,
          ),
          centerTitle: true,
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.unna(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: NYTColors.black,
            height: 1.1,
          ),
          displayMedium: GoogleFonts.unna(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: NYTColors.black,
            height: 1.15,
          ),
          displaySmall: GoogleFonts.unna(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: NYTColors.black,
            height: 1.2,
          ),
          headlineMedium: GoogleFonts.unna(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: NYTColors.black,
          ),
          bodyLarge: GoogleFonts.sourceSerif4(
            fontSize: 16,
            color: NYTColors.black,
            height: 1.6,
          ),
          bodyMedium: GoogleFonts.sourceSerif4(
            fontSize: 14,
            color: NYTColors.black,
            height: 1.5,
          ),
          bodySmall: GoogleFonts.sourceSerif4(
            fontSize: 12,
            color: NYTColors.darkGrey,
          ),
          labelLarge: GoogleFonts.frankRuhlLibre(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: NYTColors.black,
            letterSpacing: 0.5,
          ),
          labelSmall: GoogleFonts.frankRuhlLibre(
            fontSize: 11,
            color: NYTColors.darkGrey,
            letterSpacing: 0.8,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: NYTColors.midGrey,
          thickness: 1,
          space: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: NYTColors.lightGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: NYTColors.midGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: NYTColors.midGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: NYTColors.black, width: 1.5),
          ),
          hintStyle: GoogleFonts.sourceSerif4(
            color: NYTColors.darkGrey,
            fontSize: 14,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: NYTColors.white,
          selectedItemColor: NYTColors.black,
          unselectedItemColor: NYTColors.darkGrey,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
      );
}

