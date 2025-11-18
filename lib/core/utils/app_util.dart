import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/app_constants.dart';
import 'package:resturant_funny/core/models/deviceInfo_model.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/persona_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/main/domain/providers/dining_provider.dart';
import 'package:resturant_funny/modules/main/presentation/main_page.dart';
import 'package:resturant_funny/modules/notification/providers/notification_provider.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';

//CLASE Util dedicado a la desarrollo de metodos utiles en toda la aplicacion
// JB
class AppUtils {
  // Navegación sin context
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  //Informacion del dispositivo en cache
  static DeviceInfoModel? _cachedDeviceInfo;
// Muestra un SnackBar
  static void showSnackBar(String message, {bool isError = false}) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

// Esconde el input del teclado
  static void hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

// Para el manejo del input relacionado al dinero
  static String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

// Valida el Email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

// Esun telefono valido
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }

// Obtiene informacion del dispositivo
  static Future<DeviceInfoModel> getInfoDevice() async {
    if (_cachedDeviceInfo != null) {
      return _cachedDeviceInfo!;
    }
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final NetworkInfo networkInfo = NetworkInfo();
    final mobileIdentifier = MobileDeviceIdentifier();
    String deviceId = AppConstants.UNKNOWN;
    try {
      final rawDeviceId = await mobileIdentifier.getDeviceId();
      if (rawDeviceId != null && rawDeviceId.isNotEmpty) {
        deviceId = generateSha256(rawDeviceId);
      } else {
        deviceId = AppConstants.UNKNOWN;
      }
    } catch (e) {
      deviceId = AppConstants.UNKNOWN;
      debugPrint('Error al obtener el id: ${e.toString()}');
    }

    String? modelo;
    String? fabricante;
    String? sistemaOperativo;
    String? versionSO;
    String? idUnico;
    String? ip;
    String? wifiSSID;
    String? wifiBSSID;

    if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      modelo = androidInfo.model;
      fabricante = androidInfo.manufacturer;
      sistemaOperativo = "Android";
      versionSO = androidInfo.version.release;
      idUnico = deviceId;
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      modelo = iosInfo.utsname.machine;
      fabricante = "Apple";
      sistemaOperativo = "iOS";
      versionSO = iosInfo.systemVersion;
      idUnico = deviceId;
    }

    wifiSSID = await networkInfo.getWifiName();
    wifiBSSID = await networkInfo.getWifiBSSID();
    ip = await networkInfo.getWifiIP();

    _cachedDeviceInfo = DeviceInfoModel(
      modelo: modelo,
      fabricante: fabricante,
      sistemaOperativo: sistemaOperativo,
      versionSO: versionSO,
      idUnico: idUnico,
      ip: ip,
      wifiSSID: wifiSSID,
      wifiBSSID: wifiBSSID,
    );

    return _cachedDeviceInfo!;
  }

  //METODO QUE TRANSFORMA EN UN TEXTO A SHA26
  static String generateSha256(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  //METODO QUE GENERA UN TOKEN
  static String generateToken() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  //METODO QUE GENERA UN TIEMPO DE EXPIRACION
  static DateTime generateTimeExpiration() {
    return DateTime.now().add(Duration(hours: AppConstants.TOKEN_EXPIRATION));
  }

  //METODO QUE OBTIENE LA FECHA ACTUAL
  static DateTime getFechaActual() {
    final fecha = DateTime.now();
    return DateTime(fecha.year, fecha.month, fecha.day, fecha.hour,
        fecha.minute, fecha.second);
  }

  //METODO QUE VALIDA UNA CEDULA
  static bool validarCedula(String cedula) {
    String patron = r'^\d{10}$';
    RegExp regExp = RegExp(patron);
    if (!regExp.hasMatch(cedula)) {
      return false;
    }

    int digitoVerificador = int.parse(cedula.substring(9, 10));
    int sumaPares = 0;
    int sumaImpares = 0;

    for (int i = 0; i < 9; i++) {
      int digito = int.parse(cedula.substring(i, i + 1));
      if (i % 2 == 0) {
        digito *= 2;
        if (digito > 9) {
          digito -= 9;
        }
        sumaPares += digito;
      } else {
        sumaImpares += digito;
      }
    }

    int total = sumaPares + sumaImpares;
    int residuo = total % 10;
    int digitoValidador = (residuo != 0) ? (10 - residuo) : 0;

    return digitoValidador == digitoVerificador;
  }

  /// Navega de vuelta a la página de inicio
  static void backToHome() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MainPage(),
        ),
        (route) => false,
      );
    }
  }

  //METODO QUE FORMATEA LA FECHA
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Formateador de Dinero conn dos decimales
  static String formatMoney(double amount) {
    return amount.toStringAsFixed(2);
  }

  // Metodo de cerrar sesion
  static void logout(BuildContext context) {
    final navigator = AppUtils.navigatorKey.currentState;

    DialogHelper.confirm(
      context,
      message: '¿Estás seguro de querer cerrar sesión?',
      onConfirm: () {
        // Limpiar todos los providers antes de cerrar sesión
        clearProviders(context);
        navigator?.pushNamedAndRemoveUntil('/login', (route) => false);
      },
      onCancel: () {},
    );
  }

  /// Limpia todos los providers de la aplicación
  static void clearProviders(BuildContext context) {
    try {
      final container = ProviderScope.containerOf(context);

      container.read(userProvider.notifier).clearUser();

      container.read(diningProvider.notifier).limpiarDatos();
      container.read(notificationProvider.notifier).clearAll();
      container.read(navigationIndexProvider.notifier).state = 0;
      final appState = container.read(appStateProvider);
      appState.setLoading(false);
      appState.setProcessLoading(false);

      debugPrint('Todos los providers han sido limpiados');
    } catch (e) {
      debugPrint('Error al limpiar providers: $e');
    }
  }

  static cerrarSesion(BuildContext context) {
    final navigator = AppUtils.navigatorKey.currentState;
    // Limpiar todos los providers antes de cerrar sesión
    clearProviders(context);
    navigator?.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  static String getGenero(String genero) {
    String generoFormat = genero.toUpperCase();
    switch (generoFormat) {
      case 'MASCULINO':
        return 'M';
      case 'FEMENINO':
        return 'F';
      default:
        return 'N';
    }
  }

  static String? mapearGeneroDesdeBD(String? generoBD) {
    if (generoBD == null || generoBD.trim().isEmpty) return null;
    switch (generoBD.toUpperCase().trim()) {
      case 'M':
        return 'Masculino';
      case 'F':
        return 'Femenino';
      case 'N':
        return 'No especificado';
      case 'O':
        return 'Otro';
      case 'MASCULINO':
        return 'Masculino';
      case 'FEMENINO':
        return 'Femenino';
      case 'NO ESPECIFICADO':
      case 'NOESPECIFICADO':
        return 'No especificado';
      case 'OTRO':
        return 'Otro';
      default:
        return 'No especificado';
    }
  }

  static Color getStatusColor(String? estado) {
    switch (estado?.toUpperCase()) {
      case 'FINALIZADA':
      case 'COMPLETADA':
        return Colors.green;
      case 'PENDIENTE':
        return Colors.orange;
      case 'CANCELADA':
        return Colors.red;
      case 'EN_PROCESO':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  static IconData getStatusIcon(String? estado) {
    switch (estado?.toUpperCase()) {
      case 'FINALIZADA':
      case 'COMPLETADA':
        return Icons.check_circle;
      case 'PENDIENTE':
        return Icons.schedule;
      case 'CANCELADA':
        return Icons.cancel;
      case 'EN_PROCESO':
        return Icons.play_circle;
      default:
        return Icons.help_outline;
    }
  }

  // Obtiene las iniciales de la persona
  static String getInitialsName(UserModel user) {
    String firtsName = user.nombres[0];
    String lasName = user.apellidos[0];
    return firtsName + lasName;
  }

  static IconData getIconoGenero(PersonaEntity persona) {
    final genero = persona.genero?.toUpperCase() ?? '';
    if (genero.contains('FEMENINO') || genero == 'F') {
      return Icons.woman;
    } else if (genero.contains('MASCULINO') || genero == 'M') {
      return Icons.man;
    }
    return Icons.person;
  }
}
