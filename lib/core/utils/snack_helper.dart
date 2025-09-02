import 'package:flutter/material.dart';

class SnackHelper {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    bool isSuccess = false,
  }) {
    final color = isError
        ? Colors.red
        : isSuccess
            ? Colors.green
            : Colors.blueGrey;

    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
