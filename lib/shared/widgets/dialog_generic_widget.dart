// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';

//DIALOGO PERSONALIZADO USADO COMO BASE EN LA APP
class DialogoPersonalizadoWidget extends ConsumerWidget {
  String titulo;
  Widget child;
  VoidCallback? onAceptarPressed;
  VoidCallback? onCancelPressed;
  final String? buttonTitle;
  final String? cancelTitle;
  final bool blockButton;

  DialogoPersonalizadoWidget({
    super.key,
    required this.titulo,
    required this.child,
    this.onAceptarPressed,
    this.onCancelPressed,
    this.buttonTitle,
    this.cancelTitle,
    this.blockButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final maxHeight = size.height * 0.7;
    final dialogWidth = size.width > 520 ? 520.0 : size.width * 0.9;

    return AlertDialog(
      surfaceTintColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: dialogWidth,
        height: maxHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TitleCardInformation(titulo: titulo),
            const SizedBox(height: 4),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: child,
              ),
            ),
          ],
        ),
      ),
      actions: [
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: CustomButton(
                  colorButton: ThemeApp.textSecondary,
                  colorText: ThemeApp.baseText,
                  text: cancelTitle ?? 'Cancelar',
                  onPressed: () {
                    if (onCancelPressed != null) {
                      onCancelPressed!();
                    }
                    Navigator.of(context).pop();
                  }),
            ),
            if (onAceptarPressed != null) const SizedBox(width: 20),
            Visibility(
              visible: onAceptarPressed != null,
              child: Expanded(
                child: CustomButton(
                    text: buttonTitle ?? 'Aceptar',
                    onPressed: blockButton
                        ? () {}
                        : () {
                            if (onAceptarPressed != null) {
                              onAceptarPressed!();
                            }
                          }),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TitleCardInformation extends StatelessWidget {
  String titulo;

  _TitleCardInformation({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25),
        topRight: Radius.circular(25),
      ),
      child: Container(
        color: ThemeApp.primary,
        padding: const EdgeInsets.all(16),
        child: Text(
          titulo.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
