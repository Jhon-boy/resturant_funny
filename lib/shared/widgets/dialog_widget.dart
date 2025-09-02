import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';

class DialogHelper {
  // ================== DIÁLOGO DE ÉXITO ==================
  static void success(
    BuildContext context, {
    required String message,
    String? title,
    required VoidCallback onConfirmed,
  }) {
    _showBottomDialog(
      context,
      title: title ?? '¡Éxito!',
      message: message,
      icon: Icons.check_circle_outline,
      iconColor: Colors.green,
      onConfirmed: onConfirmed,
      dismissible: false,
    );
  }

  // ================== DIÁLOGO DE ERROR ==================
  static void error(
    BuildContext context, {
    required String message,
    String? title,
    required VoidCallback onConfirmed,
    bool dismissible = false,
  }) {
    _showBottomDialog(
      context,
      title: title ?? 'Error',
      message: message,
      icon: Icons.error_outline,
      iconColor: Colors.red,
      onConfirmed: onConfirmed,
      dismissible: dismissible,
    );
  }

  // ================== DIÁLOGO INFORMATIVO ==================
  static void info(
    BuildContext context, {
    required String message,
    String? title,
    required VoidCallback onConfirmed,
    bool dismissible = true,
  }) {
    _showBottomDialog(
      context,
      title: title ?? 'Información',
      message: message,
      icon: Icons.info_outline,
      iconColor: Colors.blue,
      onConfirmed: onConfirmed,
      dismissible: dismissible,
    );
  }

  // ================== DIÁLOGO DE CONFIRMACIÓN ==================
  static void confirm(
    BuildContext context, {
    required String message,
    String? title,
    String okText = 'OK',
    String cancelText = 'Cancelar',
    Color okColor = ThemeApp.primary,
    Color cancelColor = Colors.grey,
    Color okTextColor = Colors.white,
    Color cancelTextColor = Colors.white,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: ThemeApp.background,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title ?? 'Confirmación',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: ThemeApp.textPrimary,
                    fontFamily: ThemeApp.fontFamily,
                  ),
                  textAlign: TextAlign.center, // TITULO CENTRADO
                ),
                const SizedBox(height: 16),
                const Icon(Icons.help_outline,
                    color: ThemeApp.primary, size: 64),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: SingleChildScrollView(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: ThemeApp.textPrimary,
                        fontFamily: ThemeApp.fontFamily,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          onCancel();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cancelColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          cancelText,
                          style: TextStyle(
                            color: cancelTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: ThemeApp.fontFamily,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: okColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          okText,
                          style: TextStyle(
                            color: okTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: ThemeApp.fontFamily,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================== MÉTODO PRIVADO PARA DIÁLOGOS DESDE ABAJO ==================
  static void _showBottomDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onConfirmed,
    bool dismissible = false,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: dismissible,
      barrierLabel: '',
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedAnim =
            CurvedAnimation(parent: anim1, curve: Curves.easeOut);
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(curvedAnim),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.97,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: ThemeApp.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, // INICIO
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: ThemeApp.textPrimary,
                        fontFamily: ThemeApp.fontFamily,
                      ),
                      textAlign: TextAlign.right, 
                    ),
                    const SizedBox(height: 2),
                    Center(
                      child: Icon(icon, color: iconColor, size: 36),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 150),
                        child: SingleChildScrollView(
                          child: Text(
                            message,
                            style: const TextStyle(
                              fontSize: 15,
                              color: ThemeApp.textPrimary,
                              fontFamily: ThemeApp.fontFamily,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: ElevatedButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          onConfirmed();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeApp.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: ThemeApp.fontFamily,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
