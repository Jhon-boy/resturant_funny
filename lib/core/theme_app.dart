import 'package:flutter/material.dart';

class ThemeApp {
  // === Colores principales ===
  static const Color primary = Color(0xFFFF6B00);
  static const Color background = Color(0xFFF5F5F5);
  static const Color headerBackground = Color(0xFF0D0C22);

  // === Inputs ===
  static const Color inputBackground = Color(0xFFF0F0F0);
  static const Color inputBorder = Color(0xFFE0E0E0);

  // === Textos ===
  static const Color baseText = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color link = Color(0xFFFF6B00);
  static const Color error = Color(0xFFD32F2F);
  static const Color cardColors = Color.fromARGB(255, 235, 233, 233);

  // === Social Buttons ===
  static const Color apple = Color(0xFF000000);

  // === TIPO DE LETRA PARA TODA LA APP
  static const String fontFamily = 'Poppins';

  // === Método de tema ===
  static ThemeData getTheme({bool isDarkMode = false}) {
    return ThemeData(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: isDarkMode ? Colors.white : textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: isDarkMode ? Colors.grey[300] : textSecondary,
          fontSize: 14,
        ),
        titleLarge: TextStyle(
          color: isDarkMode ? Colors.white : textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: inputBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  static InputDecoration inputDecoration(
    String title,
    String hint,
    IconData prefixIcon, {
    String? Function(String?)? validator,
    bool isRequired = false,
  }) {
    return InputDecoration(
      labelText: title,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: ThemeApp.inputBorder,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isRequired ? ThemeApp.error : ThemeApp.inputBorder,
        ),
      ),
      counterText: '',
      prefixIcon: Icon(prefixIcon),
    );
  }
}
