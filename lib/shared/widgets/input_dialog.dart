import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resturant_funny/core/theme_app.dart';

// WIDGET PARA LA CAPTURA DE CUALQUIER TIPO DE INFORMACION
// EN UN DIALOGO - INPUT
class InputDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String label,
    String? hint,
    String? initialValue,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? prefixIcon,
    Widget? suffixIcon,
    int? maxLines,
    int? maxLength,
    bool obscureText = false,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color confirmColor = ThemeApp.primary,
    Color cancelColor = Colors.grey,
    bool barrierDismissible = true,
  }) async {
    final TextEditingController controller =
        TextEditingController(text: initialValue);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    T? result;

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => WillPopScope(
        onWillPop: () async => barrierDismissible,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: ThemeApp.background,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: ThemeApp.textPrimary,
                      fontFamily: ThemeApp.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    validator: validator,
                    maxLines: maxLines ?? 1,
                    maxLength: maxLength,
                    obscureText: obscureText,
                    decoration: InputDecoration(
                      labelText: label,
                      hintText: hint,
                      prefixIcon: prefixIcon,
                      suffixIcon: suffixIcon,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: ThemeApp.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: cancelColor),
                          ),
                          child: Text(
                            cancelText,
                            style: TextStyle(
                              color: cancelColor,
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
                            if (formKey.currentState!.validate()) {
                              result = controller.text as T;
                              Navigator.of(context).pop(result);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: confirmColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            confirmText,
                            style: const TextStyle(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<String?> showTextInput({
    required BuildContext context,
    required String title,
    required String label,
    String? hint,
    String? initialValue,
    int? maxLength,
    String confirmText = 'Guardar',
    String cancelText = 'Cancelar',
    List<TextInputFormatter>? inputFormatters,
  }) async {
    return show<String>(
      context: context,
      title: title,
      label: label,
      hint: hint,
      initialValue: initialValue,
      maxLength: maxLength,
      confirmText: confirmText,
      cancelText: cancelText,
      inputFormatters: inputFormatters,
    );
  }

  static Future<int?> showNumberInput({
    required BuildContext context,
    required String title,
    required String label,
    String? hint,
    int? initialValue,
    int? min,
    int? max,
    String confirmText = 'Guardar',
    String cancelText = 'Cancelar',
    int maxLength = 10,
  }) async {
    return show<int>(
      context: context,
      title: title,
      label: label,
      hint: hint,
      initialValue: initialValue?.toString(),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'El valor es requerido';
        }
        final number = int.tryParse(value);
        if (number == null) {
          return 'Ingrese un número válido';
        }
        if (min != null && number < min) {
          return 'El valor debe ser mayor o igual a $min';
        }
        if (max != null && number > max) {
          return 'El valor debe ser menor o igual a $max';
        }
        return null;
      },
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }
}
