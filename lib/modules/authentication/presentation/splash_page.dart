// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/authentication/presentation/login_page.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      verificarDispositivoConfianza();
    });
  }

  Future<void> verificarDispositivoConfianza() async {
    ref.read(appStateProvider.notifier).setLoading(true);
    await Future.delayed(const Duration(seconds: 5));

    // Desactivar loader
    ref.read(appStateProvider.notifier).setLoading(false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApp.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.restaurant_menu,
              size: 100,
              color: ThemeApp.baseText,
            ),
            const SizedBox(height: 24),
            Text(
              "Restaurant Funny",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: ThemeApp.baseText,
                    fontFamily: ThemeApp.fontFamily,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              "Cargando información...",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ThemeApp.baseText,
                    fontFamily: ThemeApp.fontFamily,
                  ),
            )
          ],
        ),
      ),
    );
  }
}
