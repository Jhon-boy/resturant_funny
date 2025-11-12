import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';

class ImagenPicker extends StatelessWidget {
  const ImagenPicker({
    super.key,
    required this.imagenBytes,
    required this.imagenUrl,
    required this.onPick,
    required this.onClear,
  });

  final Uint8List? imagenBytes;
  final String? imagenUrl;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    Widget preview;
    if (imagenBytes != null) {
      preview = Image.memory(
        imagenBytes!,
        fit: BoxFit.cover,
        height: 180,
        width: double.infinity,
      );
    } else if (imagenUrl != null && imagenUrl!.isNotEmpty) {
      preview = Image.network(
        imagenUrl!,
        fit: BoxFit.cover,
        height: 180,
        width: double.infinity,
      );
    } else {
      preview = Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ThemeApp.inputBorder),
          color: Colors.grey.shade100,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 40, color: ThemeApp.textSecondary),
            SizedBox(height: 8),
            Text(
              'Sin imagen seleccionada',
              style: TextStyle(color: ThemeApp.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: preview,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(ThemeApp.cardColors),
                shadowColor: WidgetStateProperty.all(Colors.transparent),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                )),
              ),
              onPressed: onPick,
              icon: const Icon(Icons.file_upload_outlined,
                  color: ThemeApp.success),
              label: const Text('Seleccionar',
                  style: TextStyle(
                      color: ThemeApp.success,
                      fontFamily: ThemeApp.fontFamily)),
            ),
            const SizedBox(width: 8),
            if (imagenBytes != null ||
                (imagenUrl != null && imagenUrl!.isNotEmpty)) ...[
              const SizedBox(width: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onClear,
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(ThemeApp.cardColors),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
                  ),
                  icon: const Icon(Icons.delete, color: ThemeApp.error),
                  label: const Text('Eliminar imagen',
                      style: TextStyle(
                          color: ThemeApp.error,
                          fontFamily: ThemeApp.fontFamily)),
                ),
              ),
            ]
          ],
        ),
      ],
    );
  }
}
