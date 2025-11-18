import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  // Singleton
  SharedPrefsService._();
  static final SharedPrefsService instance = SharedPrefsService._();

  SharedPreferences? _prefs;

  // Keys
  static const String _keyHasLoggedDevice = "has_logged_device";
  static const String _keyUseBiometrics = "use_biometrics";

  // Init
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Marca si el dispositivo ya inició sesión antes
  Future<void> setDeviceLoggedOnce(bool value) async {
    await _prefs?.setBool(_keyHasLoggedDevice, value);
  }

  bool deviceLoggedOnce() {
    return _prefs?.getBool(_keyHasLoggedDevice) ?? false;
  }

  // Guarda si se usa biometría
  Future<void> setBiometricsEnabled(bool value) async {
    await _prefs?.setBool(_keyUseBiometrics, value);
  }

  bool biometricsEnabled() {
    return _prefs?.getBool(_keyUseBiometrics) ?? false;
  }

  // Limpia todo
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
