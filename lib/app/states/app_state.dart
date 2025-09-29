import 'package:flutter/material.dart';

// Estado global de la aplicación
class AppState extends ChangeNotifier {
  // Indica si está activado el modo oscuro
  bool _isDarkMode = false;

  // Idioma actual de la app
  Locale _currentLocale = const Locale('es', 'ES');

  // Marca si es la primera vez que se abre la aplicación
  bool _isFirstTime = true;

  // Indica si se debe mostrar un loader global
  bool _isLoading = false;

  bool _processLoading = false;

  // Getters
  bool get isDarkMode => _isDarkMode;
  Locale get currentLocale => _currentLocale;
  bool get isFirstTime => _isFirstTime;
  bool get isLoading => _isLoading;
  bool get isProcessLoading => _processLoading;

  // Cambia entre modo claro y oscuro
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Cambia el idioma actual
  void changeLocale(Locale locale) {
    _currentLocale = locale;
    notifyListeners();
  }

  // Marca que ya no es la primera vez que se abre la app
  void setFirstTimeComplete() {
    _isFirstTime = false;
    notifyListeners();
  }

  // Activa o desactiva el loader global
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Activa o desactiva el loader del botón
  void setProcessLoading(bool value) {
    _processLoading = value;
    notifyListeners();
  }
}
