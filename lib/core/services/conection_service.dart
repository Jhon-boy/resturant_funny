import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

// Verifica el estado de conexion a Internet
// JB
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  // CAMBIO: Ahora es una lista de ConnectivityResult
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  void initialize() {
    // CAMBIO: El stream ahora devuelve una lista
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((results) {
      //   CAMBIO: Verificamos si algún resultado es diferente de 'none'
      _isConnected = results.any((result) => result != ConnectivityResult.none);
    });
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }

  Future<bool> checkConnection() async {
    //   CAMBIO: checkConnectivity() ahora devuelve una lista
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  //   MÉTODO ADICIONAL: Para obtener el tipo de conexión específico
  Future<List<ConnectivityResult>> getConnectionTypes() async {
    return await _connectivity.checkConnectivity();
  }

  //   MÉTODO ADICIONAL: Para verificar si hay WiFi específicamente
  Future<bool> hasWiFi() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi);
  }

  //   MÉTODO ADICIONAL: Para verificar si hay datos móviles
  Future<bool> hasMobileData() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.mobile);
  }

  //   MÉTODO ADICIONAL: Para obtener el estado de conexión como string
  Future<String> getConnectionStatus() async {
    final results = await _connectivity.checkConnectivity();

    if (results.contains(ConnectivityResult.wifi)) {
      return 'online';
    } else if (results.contains(ConnectivityResult.mobile)) {
      return 'online';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return 'offline';
    } else {
      return 'offline';
    }
  }
}
