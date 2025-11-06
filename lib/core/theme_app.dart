import 'package:flutter/material.dart';
import 'package:resturant_funny/core/utils/responsive_util.dart';
import 'package:shimmer/shimmer.dart';

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
  static const Color success = Color(0xFF00C853);
  static const Color white = Color(0xFFFFFFFF);

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
    Color? fillColor,
  }) {
    return InputDecoration(
      labelText: title,
      labelStyle: const TextStyle(color: ThemeApp.textPrimary),
      hintText: hint,
      filled: true,
      fillColor: fillColor ?? ThemeApp.inputBackground,
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
      prefixIcon: Icon(
        prefixIcon,
        color: ThemeApp.primary.withOpacity(0.5),
      ),
    );
  }

  static Widget buildShimmerLoading({int itemCount = 3}) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              height: ResponsiveUtil.byWidth<double>(
                context,
                small: 150,
                medium: 200,
                large: 300,
                xl: 350,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 16,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 12,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
