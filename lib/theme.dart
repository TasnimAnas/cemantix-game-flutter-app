import 'package:flutter/material.dart';

const Color kPrimary = Color(0xFF6EE7F5); // cyan
const Color kPrimaryVariant = Color(0xFF8A9B68); // fallback
const Color kAccent = Color(0xFFFFFFFF); // bright accent for title
const Color kLabelColor = Color(0xFFD5DDBC); // keep beige for labels
const Color kBackgroundSolid = Color(0xFF071028); // deep navy
const Color kCard = Color(0xFF0F1B2B); // slightly lighter for contrast
const double kCardElevation = 8.0;

/// Text color tokens (derived from white with opacities)
const Color kTextPrimary = Color(0xFFFFFFFF);
const Color kTextSecondary = Color(0xB3FFFFFF); // ~70% white
const Color kTextMuted = Color(0x99FFFFFF); // ~60% white
const Color kTextHint = Color(0x61FFFFFF); // ~38% white
const Color kDividerColor = Color(0x1AFFFFFF); // ~10% white

// Minimalistic design: use solid background (no gradients)
const BoxDecoration kScaffoldDecoration = BoxDecoration(
  color: kBackgroundSolid,
);

const Duration kAnimationDuration = Duration(milliseconds: 420);
const Curve kAnimationCurve = Curves.easeOutCubic;
const BorderRadius kCardRadius = BorderRadius.all(Radius.circular(12));

ThemeData appTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: kPrimary,
    scaffoldBackgroundColor: kBackgroundSolid,
    colorScheme: ColorScheme.dark(
      primary: kPrimary,
      primaryContainer: kPrimaryVariant,
      secondary: kAccent,
      background: kBackgroundSolid,
      surface: kCard,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: kTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: kTextPrimary,
      ),
      iconTheme: IconThemeData(color: kTextSecondary),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 36,
        color: kTextPrimary,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        color: kTextSecondary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: kTextSecondary),
      bodyMedium: TextStyle(fontSize: 14, color: kTextMuted),
      labelLarge: TextStyle(fontSize: 14, color: kLabelColor),
    ),
    cardTheme: CardThemeData(
      color: kCard,
      elevation: kCardElevation,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: kCardRadius),
      shadowColor: Colors.black45,
    ),
    shadowColor: Colors.black54,
    dividerColor: kDividerColor,
    // Slightly rounded input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
    ),
    useMaterial3: false,
  );
}
