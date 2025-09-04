import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/config/env_config.dart';
import 'package:resturant_funny/app/config/enviroment.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/services/conection_service.dart';
import 'package:resturant_funny/core/services/storage_service.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/authentication/presentation/login_page.dart';
import 'package:resturant_funny/modules/main/presentation/base_route.dart';
import 'package:resturant_funny/modules/authentication/presentation/splash_page.dart';
import 'package:resturant_funny/shared/enums/enviroment.dart';
import 'package:resturant_funny/shared/widgets/global_loader.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
// Cargar configuración del entorno
  EnvironmentConfig.initialize(EnvironmentType.development);
  debugPrint('Supabase URL: ${EnvConfig.SUPABASE_URL}');
  debugPrint('Supabase Anon Key: ${EnvConfig.SUPABASE_ANON_KEY}');
  // Inicializar servicios
  await StorageService.initialize();

  // Configurar orientación de pantalla
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar barra de estado
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  await Supabase.initialize(
    url: EnvConfig.SUPABASE_URL,
    anonKey: EnvConfig.SUPABASE_ANON_KEY,
  );

  runApp(const ProviderScope(child: MyApp())); // Riverpod
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late ConnectivityService _connectivityService;

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService();
    _connectivityService.initialize();
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  Ahora usamos Riverpod
    final appState = ref.watch(appStateProvider);

    return MaterialApp(
      title: 'Restaurant Funny',
      debugShowCheckedModeBanner: false,

      // Tema
      theme: ThemeApp.getTheme(isDarkMode: false),
      darkTheme: ThemeApp.getTheme(isDarkMode: true),
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Localización
      locale: appState.currentLocale,
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Navegación
      navigatorKey: AppUtils.navigatorKey,
      initialRoute: appState.isFirstTime ? '/splash' : '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/splash': (context) => const SplashPage(),
        '/base': (context) => const BaseRoute(),
      },

      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "¡Ups! Algo salió mal",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Por favor, inténtalo nuevamente",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (AppUtils.navigatorKey.currentState != null) {
                            AppUtils.navigatorKey.currentState!
                                .pushReplacementNamed('/splash');
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Reintentar",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        };
        return Stack(
          children: [
            child!,
            if (appState.isLoading) const GlobalLoader(),
          ],
        );
      },
    );
  }
}
