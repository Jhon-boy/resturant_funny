import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:resturant_funny/core/models/deviceInfo_model.dart';

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
      idUnico = androidInfo.id;
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      modelo = iosInfo.utsname.machine;
      fabricante = "Apple";
      sistemaOperativo = "iOS";
      versionSO = iosInfo.systemVersion;
      idUnico = iosInfo.identifierForVendor;
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
}
