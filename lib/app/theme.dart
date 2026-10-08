import 'package:flutter/material.dart';

/// Builds Mora's light and dark Material 3 themes.
class MoraTheme {
  static const _green = Color(0xff078B65);
  static const _darkGreen = Color(0xff03684C);
  static const _ink = Color(0xff152620);
  static const _muted = Color(0xff718079);
  static const _canvas = Color(0xffF5F7F5);

  /// Returns the light appearance.
  static ThemeData light() => _build(Brightness.light);

  /// Returns the dark appearance.
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: _green,
      brightness: brightness,
      primary: dark ? const Color(0xff72DDB5) : _green,
      surface: dark ? const Color(0xff14221D) : Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? const Color(0xff0D1713) : _canvas,
      cardTheme: CardThemeData(
        color: dark ? const Color(0xff14221D) : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xff0D1713) : _canvas,
        foregroundColor: dark ? Colors.white : _ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: dark ? Colors.white : _ink,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? const Color(0xff14221D) : Colors.white,
        indicatorColor: dark ? _darkGreen : const Color(0xffDDF3EA),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: dark ? Colors.white70 : _muted,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xff1A2B24) : const Color(0xffF3F6F3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
      ),
      textTheme: Typography.material2021().black.apply(
        bodyColor: dark ? const Color(0xffF2F5F2) : _ink,
        displayColor: dark ? Colors.white : _ink,
      ),
    );
  }
}
