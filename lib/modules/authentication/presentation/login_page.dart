import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/app_constants.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/data/datasource/auth_remote_data_source.dart';
import 'package:resturant_funny/modules/authentication/data/repository/auth_repository_impl.dart';
import 'package:resturant_funny/modules/authentication/domain/repository/auth_repository.dart';
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
  bool canLogin = false;
  bool isLoading = false;

  iniciarSesion() async {
    setState(() {
      isLoading = true;
    });
    if (usuarioController.text.isEmpty || passwordController.text.isEmpty) {
      SnackHelper.show(context,
          message: "Complete todos los campos", isError: true);
      return;
    }
    final result = await _authRepository.login(
        usuarioController.text, passwordController.text);
    setState(() {
      isLoading = false;
    });
    result.fold((failure) {
      DialogHelper.error(
        context,
        message: failure.message,
        onConfirmed: () {},
      );
    }, (user) {
      Navigator.of(context).pushNamedAndRemoveUntil('/base', (r) => false);
      SnackHelper.show(context, message: 'Bienvenido ${user.nombres}!');
    });
  }

  void _validateFields() {
    setState(() {
      canLogin = usuarioController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
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
                        socialButton(ThemeApp.baseText, Icons.fingerprint,
                            onTap: () {
                          debugPrint("Login con huella");
                        }),
                        const SizedBox(width: 16),
                        socialButton(ThemeApp.baseText, Icons.tag_faces,
                            onTap: () {
                          debugPrint("Login con rostro");
                        }),
                      ],
                    ),
                  ],
                ),
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
