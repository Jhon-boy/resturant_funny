import 'package:flutter/material.dart';

// LOADER DE LA APLICACION AL REALIZAR ALGUN PROCESO QUE IMPLICA EL BLOQUEO
// DE LA APP HASTA TERMINAR ALGUN PROCESO
class GlobalLoader extends StatefulWidget {
  const GlobalLoader({super.key});

  @override
  State<GlobalLoader> createState() => _GlobalLoaderState();
}

class _GlobalLoaderState extends State<GlobalLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: true, // bloquea interacción
      child: Container(
        color: Colors.black45,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      final progress = (_controller.value + (i * 0.3)) % 1.0;
                      final scale =
                          0.5 + (progress < 0.5 ? progress : 1 - progress) * 2;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        transform: Matrix4.identity()..scale(scale),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Procesando...",
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
