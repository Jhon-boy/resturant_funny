// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/models/deviceInfo_model.dart';
import 'package:resturant_funny/core/services/shared_preferences_service.dart';
import 'package:resturant_funny/core/singleton/singleton_app.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/data/datasource/auth_remote_data_source.dart';
import 'package:resturant_funny/modules/authentication/data/repository/auth_repository_impl.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/dispositivo_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/authentication/domain/repository/auth_repository.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';
import 'package:shimmer/shimmer.dart';

class DispositivoWidget extends ConsumerStatefulWidget {
  final int idUsuario;

  const DispositivoWidget({
    super.key,
    required this.idUsuario,
  });

  @override
  ConsumerState<DispositivoWidget> createState() => _DispositivoWidgetState();
}

class _DispositivoWidgetState extends ConsumerState<DispositivoWidget> {
  DispositivoEntity? dispositivo;
  DeviceInfoModel? currentDeviceInfo;
  bool isLoading = false;
  late final AuthRepository _authRepository;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(ref: ref),
    );
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      setState(() {
        isLoading = true;
      });
      currentDeviceInfo = await AppUtils.getInfoDevice();

      final deviceResult = await _authRepository.getDeviceByIdDispositivo(
        currentDeviceInfo!.idUnico!,
      );

      deviceResult.fold(
        (failure) {
          setState(() {
            dispositivo = null;
          });
        },
        (device) {
          setState(() {
            dispositivo = device;
          });
        },
      );
    } catch (e) {
      debugPrint("Error cargando información del dispositivo: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _registerDevice() async {
    try {
      final bool isDeviceSupported = await auth.isDeviceSupported();
      final bool canCheckBiometrics = await auth.canCheckBiometrics;

      if (!isDeviceSupported || !canCheckBiometrics) {
        DialogHelper.info(
          context,
          message:
              "Este dispositivo no soporta autenticación biométrica. No se puede registrar para este dispositivo.",
          onConfirmed: () {},
        );
        return;
      }

      // Verificar que haya biometrías disponibles
      final List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        DialogHelper.info(
          context,
          message:
              "No hay biometrías configuradas en este dispositivo. Por favor, configura una huella dactilar o reconocimiento facial en la configuración del dispositivo.",
          onConfirmed: () {},
        );
        return;
      }

      // Solicitar autenticación biométrica
      final bool didAuthenticate = await auth.authenticate(
        localizedReason:
            'Autentícate con biometría para registrar este dispositivo',
        biometricOnly: true,
      );

      if (!didAuthenticate) {
        SnackHelper.show(
          context,
          message: "Autenticación biométrica cancelada",
          isError: true,
        );
        return;
      }
    } on PlatformException catch (e) {
      debugPrint("Error de plataforma al verificar biometría: ${e.message}");
      DialogHelper.info(
        context,
        message:
            "Error al verificar la biometría. Asegúrate de que tu dispositivo tenga biometría configurada.",
        onConfirmed: () {},
      );
      return;
    } catch (e) {
      debugPrint("Error al autenticar con biometría: $e");
      SnackHelper.show(
        context,
        message: "Error al verificar tu identidad",
        isError: true,
      );
      return;
    }

    try {
      final user = SingletonApp.getUser() ?? ref.read(userProvider).user;
      if (user == null) {
        SnackHelper.show(
          context,
          message: "No se pudo obtener la información del usuario",
          isError: true,
        );
        return;
      }

      // Validar que tenemos la información del dispositivo actual
      if (currentDeviceInfo == null || currentDeviceInfo!.idUnico == null) {
        SnackHelper.show(
          context,
          message: "No se pudo obtener la información del dispositivo",
          isError: true,
        );
        return;
      }

      final result =
          await _authRepository.registerTrustedDevice(user, currentDeviceInfo!);
      result.fold(
        (failure) {
          SnackHelper.show(
            context,
            message: "Error al registrar el dispositivo: ${failure.message}",
            isError: true,
          );
        },
        (success) async {
          if (success) {
            await SharedPrefsService.instance.setDeviceLoggedOnce(true);
            SnackHelper.show(
              context,
              message: "Dispositivo registrado exitosamente",
              isSuccess: true,
            );
            await _loadDeviceInfo();
          } else {
            SnackHelper.show(
              context,
              message: "No se pudo registrar el dispositivo",
              isError: true,
            );
          }
        },
      );
    } catch (e) {
      debugPrint("Error registrando dispositivo: $e");
      SnackHelper.show(
        context,
        message: "Error inesperado al registrar el dispositivo",
        isError: true,
      );
    }
  }

  Future<void> _removeDevice() async {
    if (dispositivo == null || dispositivo!.imei == null) {
      return;
    }

    DialogHelper.confirm(
      context,
      title: "Eliminar dispositivo",
      message: "¿Estás seguro de que deseas eliminar este dispositivo?",
      onConfirm: () async {
        try {
          final result = await _authRepository.removeTrustedDevice(
            dispositivo!.imei!,
          );

          result.fold(
            (failure) {
              DialogHelper.error(
                context,
                message: "Error al eliminar el dispositivo: ${failure.message}",
                onConfirmed: () {},
              );
            },
            (success) async {
              if (success) {
                await SharedPrefsService.instance.setDeviceLoggedOnce(false);
                DialogHelper.success(context,
                    message:
                        "Dispositivo eliminado exitosamente. Vuelve a iniciar sesión para continuar",
                    onConfirmed: () {
                  AppUtils.cerrarSesion(context);
                });
              } else {
                DialogHelper.error(
                  context,
                  message: "No se pudo eliminar el dispositivo",
                  onConfirmed: () {},
                );
              }
            },
          );
        } catch (e) {
          debugPrint("Error eliminando dispositivo: $e");
          SnackHelper.show(
            context,
            message: "Error inesperado al eliminar el dispositivo",
            isError: true,
          );
        }
      },
      onCancel: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Card(
        color: ThemeApp.cardColors,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 16,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 4,
      color: ThemeApp.cardColors,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
            dispositivo == null ? _buildNoDeviceView() : _buildDeviceInfoView(),
      ),
    );
  }

  Widget _buildNoDeviceView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: ThemeApp.primary.withOpacity(0.2),
              child: const Icon(
                Icons.phone_android,
                color: ThemeApp.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Dispositivo no registrado",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeApp.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (currentDeviceInfo != null) ...[
          _infoRow(Icons.phone_android, 'Modelo',
              currentDeviceInfo!.modelo ?? 'Desconocido'),
          const SizedBox(height: 10),
          _infoRow(Icons.business, 'Marca',
              currentDeviceInfo!.fabricante ?? 'Desconocida'),
          const SizedBox(height: 10),
        ],
        CustomButton(
          text: "Vincular dispositivo",
          colorButton: ThemeApp.success,
          onPressed: _registerDevice,
          enable: !ref.watch(appStateProvider).isLoading,
          isLoading: ref.watch(appStateProvider).isLoading,
          icon: Icons.fingerprint,
        ),
        const SizedBox(height: 12),
        const Text(
          "Al registrar, podrás usar biometría para iniciar sesión",
          style: TextStyle(
            fontSize: 12,
            color: ThemeApp.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDeviceInfoView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: ThemeApp.success.withOpacity(0.2),
              child: const Icon(
                Icons.phone_android,
                color: ThemeApp.success,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Dispositivo registrado",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeApp.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeApp.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: ThemeApp.success,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "Activo",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ThemeApp.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _infoRow(Icons.phone_android, 'Modelo',
            dispositivo!.modelo ?? 'Desconocido'),
        const SizedBox(height: 10),
        _infoRow(Icons.business, 'Marca', dispositivo!.marca ?? 'Desconocida'),
        const SizedBox(height: 10),
        _infoRow(
            Icons.calendar_today,
            'Registrado el',
            dispositivo!.fCreacion != null
                ? AppUtils.formatDate(dispositivo!.fCreacion!)
                : 'No disponible'),
        const SizedBox(height: 16),
        CustomButton(
          text: "Eliminar dispositivo",
          onPressed: _removeDevice,
          enable: !ref.watch(appStateProvider).isLoading,
          isLoading: ref.watch(appStateProvider).isLoading,
          icon: Icons.delete_outline,
          colorButton: ThemeApp.textSecondary,
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: ThemeApp.primary.withOpacity(0.2),
              child: Icon(icon, size: 18, color: ThemeApp.primary),
            ),
            const SizedBox(width: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ThemeApp.headerBackground,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Flexible(
          child: RichText(
            textAlign: TextAlign.end,
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: ThemeApp.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
