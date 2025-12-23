// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:resturant_funny/core/app_constants.dart';
import 'package:resturant_funny/core/services/shared_preferences_service.dart';
import 'package:resturant_funny/core/singleton/singleton_app.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/core/utils/imagenes.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/data/datasource/auth_remote_data_source.dart';
import 'package:resturant_funny/modules/authentication/data/datasource/sesion_remote_data_source.dart';
import 'package:resturant_funny/modules/authentication/data/repository/auth_repository_impl.dart';
import 'package:resturant_funny/modules/authentication/data/repository/sesion_repository_impl.dart';
import 'package:resturant_funny/modules/authentication/domain/mappers/auth_mapper.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/authentication/domain/repository/auth_repository.dart';
import 'package:resturant_funny/modules/authentication/domain/repository/sesion_repository.dart';
import 'package:resturant_funny/modules/authentication/presentation/splash_page.dart';
import 'package:resturant_funny/modules/sucursales/data/datasource/sucursal_remote_datasource.dart';
import 'package:resturant_funny/modules/sucursales/presentation/sucursales_lista_page.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

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
  late final SesionRepository _sesionRepository;
  bool isDeviceLoggedOnce = false;
  bool canLogin = false;
  bool isLoading = false;
  bool canFingerPrint = false;
  bool canFace = false;
  String versionApp = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUtils.getVersionApp().then((value) => {
            setState(() {
              versionApp = value;
            })
          });
      checkBiometric();
      isDeviceLoggedOnce = SharedPrefsService.instance.deviceLoggedOnce();
    });

    _authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(ref: ref),
    );
    _sesionRepository = SessionRepositoryImpl(
      SessionRemoteDataSource(ref: ref),
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
        await _loadUserDataAndNavigate(user);
      },
    );
  }

  Future<void> _loadUserDataAndNavigate(UserModel user) async {
    try {
      final rolesResult = await _authRepository.getRolesByUser(user.idUsuario!);
      final roles = rolesResult.getOrElse(() => []);
      ref.read(userProvider.notifier).setUser(user, roles: roles);

      // Obtener nombre de la sucursal desde la base de datos (si aplica)
      String? sucursalNombre;
      try {
        if (user.idSucursal != null) {
          final sucursalDataSource = SucursalRemoteDataSource(ref: ref);
          final sucursalEntity =
              await sucursalDataSource.getSucursalById(user.idSucursal!);
          sucursalNombre = sucursalEntity?.nombre;
        }
      } catch (e) {
        debugPrint('Error obteniendo sucursal del usuario: $e');
      }

      SingletonApp.setUserData(
        user: user,
        roles: roles,
        rolPrincipal: roles.isNotEmpty ? roles.first.codigo : null,
        sucursalNombre: sucursalNombre,
      );

      await _crearSesion(user);

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
  }

  Future<void> _crearSesion(UserModel user) async {
    try {
      final result = await _sesionRepository.createSesion(
          AuthMapper.toSesionEntity(user), user);

      result.fold(
        (failure) {
          debugPrint("Error al crear sesión: ${failure.message}");
        },
        (sesionCreada) {
          debugPrint("Sesión creada exitosamente: ${sesionCreada.idSesion}");
        },
      );
    } catch (e) {
      debugPrint("Error al crear sesión: $e");
    }
  }

  Future<void> checkDevice() async {
    final deviceInfo = await AppUtils.getInfoDevice();
    if (deviceInfo.idUnico == AppConstants.UNKNOWN) {
      DialogHelper.info(context,
          message:
              "Error al obtener el id del dispositivo, Inicie con usuario y contraseña",
          onConfirmed: () {});
      return;
    }
    final trusDevice = await _authRepository.isTrustedDevice(deviceInfo);
    trusDevice.fold((failure) {
      debugPrint("Dispositivo no Registrado");
      DialogHelper.info(context,
          message:
              "Dispositivo no Registrado, Ingrese con usuario y contraseña",
          onConfirmed: () {});
    }, (user) async {
      await _loadUserDataAndNavigate(user);
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

  Future<bool> supportAuthWithCredentials() async {
    bool isSupported = await auth.isDeviceSupported();
    bool canCheckBiometrics;

    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (_) {
      canCheckBiometrics = false;
    }

    if (Platform.isAndroid) {
      List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return false;
      }
    }

    if (isSupported && canCheckBiometrics) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> iniciarConBiometria() async {
    try {
      setState(() {
        isLoading = true;
      });
      final bool supportsAuth = await supportAuthWithCredentials();
      if (!supportsAuth) {
        SnackHelper.show(
          context,
          message: "Este dispositivo no soporta autenticación biométrica",
          isError: true,
        );
        return;
      }

      // Realizar autenticación biométrica
      final bool authenticated = await auth.authenticate(
        localizedReason:
            'Escanee su huella digital (o su rostro) para autenticarse',
        biometricOnly: true,
      );

      if (authenticated) {
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
    } finally {
      setState(() {
        isLoading = false;
      });
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ===== LOGO Y TÍTULO LIMPIO =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Logo limpio y simple
                    Hero(
                      tag: 'logo',
                      child: Image.asset(
                        Imagenes.logoApp,
                        width: size.width * 0.5,
                        height: size.width * 0.40,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Text(
                      "¡Bienvenido!",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C3E50),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),

              // ===== FORMULARIO =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Ingresa tus credenciales para continuar"),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          maxLength: AppConstants.MAX_CARACTERES_TITULOS,
                          controller: usuarioController,
                          decoration: InputDecoration(
                            focusColor: ThemeApp.primary,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: ThemeApp.primary),
                            ),
                            labelText: "Usuario",
                            labelStyle: const TextStyle(color: ThemeApp.apple),
                            hintText: "Ingresa tu usuario",
                            prefixIcon: Icon(Icons.person_outline,
                                color: Colors.red.shade700),
                            filled: true,
                            fillColor: Colors.white,
                            counterText: "",
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          obscureText: obscureText,
                          controller: passwordController,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: ThemeApp.primary),
                            ),
                            labelText: "Contraseña",
                            labelStyle: const TextStyle(color: ThemeApp.apple),
                            hintText: "Ingresa tu contraseña",
                            prefixIcon: Icon(Icons.lock_outline,
                                color: Colors.red.shade700),
                            filled: true,
                            fillColor: Colors.white,
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
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
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
                      const SizedBox(height: 15),

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
                      const SizedBox(height: 25),
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
                        const SizedBox(height: 15),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isDeviceLoggedOnce) ...[
                            socialButton(ThemeApp.baseText, Icons.fingerprint,
                                title: "Biometria", onTap: () {
                              iniciarConBiometria();
                            }),
                          ],
                          const SizedBox(width: 16),
                          socialButton(ThemeApp.baseText, Icons.map,
                              title: "Sucursales", onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SucursalesListaPage(),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          versionApp,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ThemeApp.textSecondary),
                        ),
                      )
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget socialButton(Color color, IconData icon,
      {VoidCallback? onTap, String? title}) {
    final mediaQuery = MediaQuery.of(context);
    return GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            AnimatedContainer(
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
                  size: 45,
                ),
              ),
            ),
            if (title != null) ...[
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    color: ThemeApp.textSecondary),
              ),
            ],
            const SizedBox(height: 10),
          ],
        ));
  }
}
