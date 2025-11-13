import 'package:flutter/services.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.toUpperCase();
    final selection = TextSelection.collapsed(
      offset: newText.length < newValue.selection.start
          ? newText.length
          : newValue.selection.start,
    );
    return TextEditingValue(
      text: newText,
      selection: selection,
    );
  }
}

class SentenceCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final lower = newValue.text.toLowerCase();
    final sentence =
        lower.isEmpty ? lower : lower[0].toUpperCase() + lower.substring(1);

    final selection = TextSelection.collapsed(
      offset: sentence.length < newValue.selection.start
          ? sentence.length
          : newValue.selection.start,
    );

    return TextEditingValue(text: sentence, selection: selection);
  }
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.toLowerCase();
    final selection = TextSelection.collapsed(
      offset: newText.length < newValue.selection.start
          ? newText.length
          : newValue.selection.start,
    );
    return TextEditingValue(
      text: newText,
      selection: selection,
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

    int removedBeforeBase = 0;
    int removedBeforeExtent = 0;

    for (int i = 0; i < newValue.text.length; i++) {
      final char = newValue.text[i];
      final isRemoved = !RegExp(r'[a-zA-Z0-9 ]').hasMatch(char);

      if (isRemoved) {
        if (i < newValue.selection.baseOffset) {
          removedBeforeBase++;
        }
        if (i < newValue.selection.extentOffset) {
          removedBeforeExtent++;
        }
      }
    }

    final newBaseOffset = (newValue.selection.baseOffset - removedBeforeBase)
        .clamp(0, filtered.length);
    final newExtentOffset =
        (newValue.selection.extentOffset - removedBeforeExtent)
            .clamp(0, filtered.length);

    return TextEditingValue(
      text: filtered,
      selection: TextSelection(
        baseOffset: newBaseOffset,
        extentOffset: newExtentOffset,
      ),
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
