import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  // Opcionales
  final Color? colorButton;
  final Color? colorText;
  final IconData? icon;
  final double? height;
  final double? width;
  final double borderRadius;
  final bool enable;
  final bool? isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.colorButton,
    this.colorText,
    this.icon,
    this.height,
    this.width,
    this.borderRadius = 12.0,
    this.enable = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 50,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: enable
            ? isLoading == true
                ? null
                : onPressed
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enable
              ? (colorButton ?? ThemeApp.primary)
              : const Color.fromARGB(255, 241, 150, 85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading == true) ...[
              Text(
                "Cargando...",
                style: TextStyle(
                  fontFamily: ThemeApp.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorText ?? Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ] else ...[
              if (icon != null) ...[
                Icon(icon, color: colorText ?? Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontFamily: ThemeApp.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorText ?? Colors.white,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
