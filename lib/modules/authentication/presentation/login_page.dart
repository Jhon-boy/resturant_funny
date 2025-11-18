// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/app_constants.dart';
import 'package:resturant_funny/core/services/shared_preferences_service.dart';
import 'package:resturant_funny/core/singleton/singleton_app.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/data/datasource/auth_remote_data_source.dart';
import 'package:resturant_funny/modules/authentication/data/repository/auth_repository_impl.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/authentication/domain/repository/auth_repository.dart';
import 'package:resturant_funny/modules/authentication/presentation/splash_page.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool rememberMe = false;
  bool obscureText = true;
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late final AuthRepository _authRepository;
  bool isDeviceLoggedOnce = false;
  bool canLogin = false;
  bool isLoading = false;
  bool canFingerPrint = false;
  bool canFace = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkBiometric();
      isDeviceLoggedOnce = SharedPrefsService.instance.deviceLoggedOnce();
    });

    _authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(ref: ref),
    );
    usuarioController.addListener(_validateFields);
    passwordController.addListener(_validateFields);
  }

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  final LocalAuthentication auth = LocalAuthentication();

  Future<void> iniciarSesion() async {
    setState(() {
      isLoading = true;
    });

    if (usuarioController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        isLoading = false;
      });
      SnackHelper.show(context,
          message: "Complete todos los campos", isError: true);
      return;
    }
    final result = await _authRepository.login(
      usuarioController.text,
      passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    result.fold(
      (failure) {
        DialogHelper.error(context,
            message: failure.message, onConfirmed: () {});
      },
      (user) async {
        try {
          final rolesResult =
              await _authRepository.getRolesByUser(user.idUsuario!);
          final roles = rolesResult.getOrElse(() => []);
          ref.read(userProvider.notifier).setUser(user, roles: roles);
          SingletonApp.setUserData(
            user: user,
            roles: roles,
            rolPrincipal: roles.isNotEmpty ? roles.first.codigo : null,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SplashPage()),
          );
          SnackHelper.show(context, message: 'Bienvenido ${user.nombres}!');
        } catch (e) {
          debugPrint("Error obteniendo roles o guardando usuario: $e");
          DialogHelper.error(
            context,
            message: "Error al cargar la información del usuario",
            onConfirmed: () {},
          );
        }
      },
    );
  }

  Future<void> checkDevice() async {
    final deviceInfo = await AppUtils.getInfoDevice();
    final trusDevice = await _authRepository.isTrustedDevice(deviceInfo);
    trusDevice.fold((failure) {
      debugPrint("Dispositivo no Registrado");
      DialogHelper.info(context,
          message:
              "Dispositivo no Registrado, Ingrese con usuario y contraseña",
          onConfirmed: () {});
    }, (user) async {
      try {
        final rolesResult =
            await _authRepository.getRolesByUser(user.idUsuario!);
        final roles = rolesResult.getOrElse(() => []);

        ref.read(userProvider.notifier).setUser(user, roles: roles);
        SingletonApp.setUserData(
          user: user,
          roles: roles,
          rolPrincipal: roles.isNotEmpty ? roles.first.codigo : null,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashPage()),
        );
        SnackHelper.show(context, message: 'Bienvenido ${user.nombres}!');
      } catch (e) {
        debugPrint("Error obteniendo roles o guardando usuario: $e");
        DialogHelper.error(
          context,
          message: "Error al cargar la información del usuario",
          onConfirmed: () {},
        );
      }
    });
  }

  Future<void> checkBiometric() async {
    try {
      final List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();

      setState(() {
        canFingerPrint =
            availableBiometrics.contains(BiometricType.fingerprint);
        canFace = availableBiometrics.contains(BiometricType.face);
      });
    } catch (e) {
      debugPrint("Error al verificar la biometría: $e");
    }
  }

  Future<void> iniciarConBiometria() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Autentícate para ingresar',
        biometricOnly: true,
      );

      if (didAuthenticate) {
        debugPrint("Biometría correcta");
        await checkDevice();
      } else {
        debugPrint("Autenticación biométrica fallida");
        SnackHelper.show(context,
            message: "No se pudo autenticar con biometría", isError: true);
      }
    } catch (e) {
      debugPrint("Error al autenticar con biometría: $e");
      SnackHelper.show(context,
          message: "Error al intentar verificar tu identidad", isError: true);
    }
  }

  void _validateFields() {
    setState(() {
      canLogin = usuarioController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ===== BANNER MEJORADO =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 60),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D0C22), Color(0xFF1A1A40)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Text(
                      "Iniciar Sesión",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Ingresa con tu cuenta para continuar",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ===== FORMULARIO =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("USUARIO"),
                      const SizedBox(height: 8),
                      TextFormField(
                        maxLength: AppConstants.MAX_CARACTERES_TITULOS,
                        controller: usuarioController,
                        decoration: const InputDecoration(
                          hintText: "usuario",
                          prefixIcon: Icon(Icons.people),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text("CONTRASEÑA"),
                      const SizedBox(height: 8),
                      TextFormField(
                        obscureText: obscureText,
                        controller: passwordController,
                        decoration: InputDecoration(
                            hintText: "********",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureText = !obscureText;
                                });
                              },
                              icon: Icon(
                                obscureText
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            )),
                      ),
                      const SizedBox(height: 30),

                      // ===== LOGIN BUTTON =====
                      SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            isLoading: isLoading,
                            onPressed: () {
                              iniciarSesion();
                            },
                            text: isLoading ? "Cargando..." : "Iniciar Sesión",
                            enable: canLogin,
                          )),
                      const SizedBox(height: 20),

                      // ===== SIGN UP =====
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Tienes problema en registrarte? "),
                          Text(
                            "Contáctanos",
                            style: TextStyle(
                              color: ThemeApp.link,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      if (isDeviceLoggedOnce) ...[
                        // ===== OR SOCIAL =====
                        const Row(
                          children: [
                            Expanded(child: Divider(thickness: 1)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text("O ingresa con"),
                            ),
                            Expanded(child: Divider(thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            canFingerPrint
                                ? socialButton(
                                    ThemeApp.baseText, Icons.fingerprint,
                                    onTap: () {
                                    debugPrint("Login con huella");
                                  })
                                : const SizedBox.shrink(),
                            const SizedBox(width: 16),
                            canFace
                                ? socialButton(
                                    ThemeApp.baseText, Icons.tag_faces,
                                    onTap: () {
                                    debugPrint("Login con rostro");
                                  })
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ],
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget socialButton(Color color, IconData icon, {VoidCallback? onTap}) {
    final mediaQuery = MediaQuery.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(seconds: 2),
        width: mediaQuery.size.width * 0.23,
        height: mediaQuery.size.width * 0.22,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          color: color,
          boxShadow: [
            BoxShadow(
              color: ThemeApp.apple.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: ThemeApp.baseText.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            color: ThemeApp.apple,
            size: 35,
          ),
        ),
      ),
    );
  }
}
