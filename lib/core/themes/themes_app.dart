import 'package:flutter/material.dart';

class ThemesApp {
  // Colores principales
  static final Color primary =
      Colors.cyan[800]!; //primary_color en Values/Colors.xml
  static final Color primaryLigth = Colors.cyan[600]!; //primary_light_color
  static const Color secondary = Colors.white;
  static const Color onPrimary = Colors.white;
  static final Color scaffoldBackground = Colors.grey.shade200;
  // Colores de Superficie y Fondo (¡Aquí está tu control!)

  // LIGHT: Tarjetas y Superficie
  static const Color cardLight = Colors.white;
  static final Color backgroundLight = Colors.grey.shade300;

  // DARK: Tarjetas y Superficie (Lo que quieres controlar)
  static final Color backgroundDark = Colors
      .grey
      .shade900; // Fondo del Scaffold (más oscuro) background_dark en values/colors.xml
  static final Color cardDark = Colors
      .grey
      .shade900; // 💡 Fondo de Card, Dialog, Surface (MENOS OSCURO que el fondo)

  // Light theme
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    cardColor: cardLight,
    //scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.light(
      primary: primary,
      onPrimary: onPrimary,
      secondary: primaryLigth,
      onSecondary: onPrimary,
      surface: cardLight, // Superficie (Cards, Sheets, Dialogs)
      error: Colors.red,
    ),

    primaryColor: primary,
    scaffoldBackgroundColor: scaffoldBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      elevation: 0,
      centerTitle: true,
      foregroundColor: secondary,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: primary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: primary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: primary),
      ),
      labelStyle: const TextStyle(color: Colors.black),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey[200]!,
      selectedColor: primary,
      padding: const EdgeInsets.all(8.0),
    ),
    cardTheme: CardThemeData(
      surfaceTintColor: Colors.white,
      shadowColor: primary,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryLigth,
      linearTrackColor: primary,
      circularTrackColor: Colors.white,
      strokeWidth: 4.0,
      refreshBackgroundColor: Colors.grey[300],
    ),
    iconTheme: IconThemeData(color: primary),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: secondary,
        elevation: 5,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: primary,
      unselectedItemColor: Colors.grey,
      selectedIconTheme: const IconThemeData(size: 32),
      unselectedIconTheme: const IconThemeData(size: 24),
      type: BottomNavigationBarType.fixed,
      enableFeedback: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryLigth,
      foregroundColor: Colors.white,
      focusColor: primaryLigth,
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    cardColor: cardDark,

    //scaffoldBackgroundColor: backgroundDark,
    colorScheme: ColorScheme.dark(
      primary: primary,
      onPrimary: onPrimary,
      secondary: primaryLigth,
      onSecondary: onPrimary,
      surface: cardDark, // Color de superficie oscuro (el mismo que la tarjeta)
      error: Colors.redAccent,
    ),

    primaryColor: primaryLigth,
    scaffoldBackgroundColor: Colors.grey[800], //background_light
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[800],
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.white70,
      titleTextStyle: const TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: primaryLigth),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: primaryLigth),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.white54),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
      fillColor: Colors.grey[800],
      filled: true,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey[700]!,
      selectedColor: primaryLigth,
      padding: const EdgeInsets.all(8.0),
      labelStyle: const TextStyle(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: Colors.grey[800],
      shadowColor: Colors.black,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryLigth,
      linearTrackColor: Colors.grey[700],
      circularTrackColor: Colors.grey[800],
      strokeWidth: 4.0,
      refreshBackgroundColor: Colors.grey[900],
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLigth,
        foregroundColor: Colors.white,
        elevation: 5,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[850],
      selectedItemColor: primaryLigth,
      unselectedItemColor: Colors.white54,
      selectedIconTheme: const IconThemeData(size: 32),
      unselectedIconTheme: const IconThemeData(size: 24),
      type: BottomNavigationBarType.fixed,
      enableFeedback: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryLigth,
      foregroundColor: Colors.white,
      focusColor: primary,
    ),
  );
}
