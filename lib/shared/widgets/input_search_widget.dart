import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resturant_funny/core/theme_app.dart';

// WIDGET PARA EL INPUT DE BUSQUEDA
class InputSearchWidget extends StatefulWidget {
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;
  final int? maxLength;
  final bool enabled;
  final String? Function(String?)? validator;
  final String? errorMessage;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onSuffixPressed;
  final VoidCallback? onSearchPressed;
  final bool showSearchButton;
  final bool showSuffixButton;
  final String? searchButtonText;
  final String? suffixButtonText;
  final Color? searchButtonColor;
  final Color? suffixButtonColor;
  final bool isLoading;

  const InputSearchWidget({
    super.key,
    required this.label,
    this.hint = '',
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.initialValue,
    this.maxLength,
    this.enabled = true,
    this.validator,
    this.errorMessage,
    this.onChanged,
    this.onSubmitted,
    this.onSuffixPressed,
    this.onSearchPressed,
    this.showSearchButton = true,
    this.showSuffixButton = false,
    this.searchButtonText,
    this.suffixButtonText,
    this.searchButtonColor,
    this.suffixButtonColor,
    this.isLoading = false,
  });

  @override
  State<InputSearchWidget> createState() => _InputSearchWidgetState();
}

class _InputSearchWidgetState extends State<InputSearchWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            maxLength: widget.maxLength,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, size: 34)
                  : null,
              suffixIcon: widget.showSuffixButton && widget.suffixIcon != null
                  ? IconButton(
                      icon: Icon(widget.suffixIcon),
                      onPressed: widget.onSuffixPressed,
                    )
                  : null,
              counterText: '',
              errorText: widget.errorMessage,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: ThemeApp.apple.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: ThemeApp.baseText.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ThemeApp.apple, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              filled: true,
              fillColor: widget.enabled
                  ? const Color.fromARGB(255, 213, 211, 211).withOpacity(0.3)
                  : ThemeApp.baseText,
            ),
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
          ),
        ),
        if (widget.showSearchButton) ...[
          ElevatedButton(
            onPressed: widget.isLoading ? null : _handleSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.searchButtonColor ?? ThemeApp.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(67),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(ThemeApp.baseText),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search,
                          color: ThemeApp.baseText, size: 25),
                      if (widget.searchButtonText != null) ...[
                        const SizedBox(width: 2),
                        Text(
                          widget.searchButtonText!,
                          style: const TextStyle(color: ThemeApp.baseText),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
        if (widget.showSuffixButton && widget.suffixButtonText != null) ...[
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: widget.onSuffixPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: widget.suffixButtonColor ?? ThemeApp.primary,
              side: BorderSide(
                  color: widget.suffixButtonColor ?? ThemeApp.primary),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(widget.suffixButtonText!),
          ),
        ],
      ],
    );
  }

  void _handleSearch() {
    if (widget.onSearchPressed != null) {
      widget.onSearchPressed!();
    } else if (widget.onSubmitted != null) {
      widget.onSubmitted!(_controller.text);
    }
  }

  String get value => _controller.text;

  void setValue(String value) {
    _controller.text = value;
  }
}
