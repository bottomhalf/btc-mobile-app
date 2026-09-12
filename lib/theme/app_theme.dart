import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ─── Dark Mode Brand Colours (Shiny Black / Obsidian) ────────
  static const Color _primaryIndigo = Color(0xFF6264A7);
  static const Color _accentPurple = Color(0xFF7B83EB);
  static const Color _surfaceDark = Color(0xFF09090C);       // Pitch-black canvas base
  static const Color _cardDark = Color(0xFF131318);          // Sleek shiny obsidian card surface
  static const Color _cardDarkAlt = Color(0xFF1E1E26);       // Shiny elevated surface & input fill
  static const Color _textPrimaryDark = Color(0xFFF8F9FD);   // Crisp luminescent white text
  static const Color _textSecondaryDark = Color(0xFFA2A2B2); // Polished platinum metallic silver
  static const Color _dividerDark = Color(0xFF2A2A34);       // Specular highlight border
  static const Color _errorRed = Color(0xFFFF6B6B);
  static const Color _successGreen = Color(0xFF4ADE80);

  // ─── Light Mode Brand Colours ──────────────────────────────────
  static const Color _surfaceLight = Color(
    0xFFEFF1F5,
  ); // Slightly darker off-white for better card contrast
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _cardLightAlt = Color(
    0xFFE4E7EC,
  ); // Darker input field background
  static const Color _textPrimaryLight = Color(
    0xFF111827,
  ); // Darker text for readability
  static const Color _textSecondaryLight = Color(0xFF4B5563);
  static const Color _dividerLight = Color(0xFFD1D5DB); // Darker divider

  // ─── Gradient ──────────────────────────────────────────────────
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF6264A7), Color(0xFF7B83EB), Color(0xFF9B59B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF22222A), Color(0xFF131318), Color(0xFF0A0A0E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Dark Theme ────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _surfaceDark,
      primaryColor: _primaryIndigo,
      colorScheme: const ColorScheme.dark(
        primary: _primaryIndigo,
        secondary: _accentPurple,
        surface: _cardDark,
        error: _errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _textPrimaryDark,
        onError: Colors.white,
      ),
      fontFamily: 'Segoe UI',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: _textPrimaryDark,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: _textPrimaryDark),
      ),
      cardTheme: CardThemeData(
        color: _cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _dividerDark, width: 0.8),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _dividerDark, width: 0.8),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _cardDark,
        modalBackgroundColor: _cardDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _cardDarkAlt,
        hintStyle: const TextStyle(color: _textSecondaryDark, fontSize: 14),
        labelStyle: const TextStyle(color: _textSecondaryDark, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _dividerDark.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _accentPurple, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryIndigo,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      dividerColor: _dividerDark,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: _textPrimaryDark,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _textPrimaryDark,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _textPrimaryDark,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _textPrimaryDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: _textPrimaryDark,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: _textSecondaryDark,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _textPrimaryDark,
        ),
      ),
    );
  }

  // ─── Light Theme ───────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: _surfaceLight,
      primaryColor: _primaryIndigo,
      colorScheme: const ColorScheme.light(
        primary: _primaryIndigo,
        secondary: _accentPurple,
        surface: _cardLight,
        error: _errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _textPrimaryLight,
        onError: Colors.white,
      ),
      fontFamily: 'Segoe UI',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: _textPrimaryLight,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: _textPrimaryLight),
      ),
      cardTheme: CardThemeData(
        color: _cardLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _cardLightAlt,
        hintStyle: const TextStyle(color: _textSecondaryLight, fontSize: 14),
        labelStyle: const TextStyle(color: _textSecondaryLight, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _dividerLight.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _accentPurple, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryIndigo,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      dividerColor: _dividerLight,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: _textPrimaryLight,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _textPrimaryLight,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _textPrimaryLight,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _textPrimaryLight,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: _textPrimaryLight,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: _textSecondaryLight,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _textPrimaryLight,
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────
  // We provide getters that resolve based on current active brightness.
  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? _surfaceDark
      : _surfaceLight;
  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _cardDark : _cardLight;
  static Color cardAlt(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? _cardDarkAlt
      : _cardLightAlt;
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? _textPrimaryDark
      : _textPrimaryLight;
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? _textSecondaryDark
      : _textSecondaryLight;
  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? _dividerDark
      : _dividerLight;

  static Color get primaryIndigo => _primaryIndigo;
  static Color get accentPurple => _accentPurple;
  static Color get errorRed => _errorRed;
  static Color get successGreen => _successGreen;

  /// Returns a rich full-page background gradient reflecting the current theme.
  /// In dark mode, provides a deep obsidian shiny-black roll-off gradient.
  static LinearGradient pageGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF16161C), Color(0xFF09090C)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3F5FA), Color(0xFFE8ECF5)],
          );
  }

  /// Returns a shiny specular card gradient reflecting current theme.
  static LinearGradient shinyCardGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF24242D), Color(0xFF141418), Color(0xFF0E0E12)],
            stops: [0.0, 0.5, 1.0],
          )
        : cardGradient;
  }
}
