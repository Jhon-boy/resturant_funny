import 'package:flutter/services.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

class LetterOnlyTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final filtered = newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '');
    return TextEditingValue(
      text: filtered,
      selection: newValue.selection,
    );
  }
}

class CurrencyTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Permitir solo números y punto decimal
    final filtered = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    // Evitar múltiples puntos decimales
    final parts = filtered.split('.');
    String formatted;
    if (parts.length > 2) {
      formatted = '${parts[0]}.${parts.sublist(1).join()}';
    } else {
      formatted = filtered;
    }

    // Limitar decimales a 2
    if (formatted.contains('.')) {
      final decimalParts = formatted.split('.');
      if (decimalParts.length > 1 && decimalParts[1].length > 2) {
        formatted = '${decimalParts[0]}.${decimalParts[1].substring(0, 2)}';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
