import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final String label;
  final String hint;
  final List<T> items;
  final String Function(T) displayText;
  final String Function(T)? subtitleText;
  final IconData? icon;
  final Function(T?) onChanged;
  final bool enabled;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.label,
    required this.hint,
    required this.items,
    required this.displayText,
    this.subtitleText,
    this.icon,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<T>(
        value: value,
        hint: Text(hint),
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: Colors.white,
        style: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayText(item),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (subtitleText != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitleText!(item),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}
