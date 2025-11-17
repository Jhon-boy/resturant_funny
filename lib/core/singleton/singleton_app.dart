// ignore_for_file: unnecessary_getters_setters, collection_methods_unrelated_type
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';

class SingletonApp {
  static final SingletonApp _singleton = SingletonApp._internal();
  SingletonApp._internal();

  UserModel? _user;
  String? _nombreUsuario;
  List<RolEntity> _roles = [];
  String? _rolPrincipal;

  // Métodos para obtener valores
  static UserModel? getUser() => _singleton._user;
  static String? getNombreUsuario() => _singleton._nombreUsuario;
  static List<RolEntity> getRoles() => _singleton._roles;
  static String? getRolPrincipal() => _singleton._rolPrincipal;

  // Setear datos del usuario
  static void setUserData({
    required UserModel user,
    required List<RolEntity> roles,
    String? rolPrincipal,
  }) {
    final instance = _singleton;
    instance._user = user;
    instance._nombreUsuario = user.nombres;
    instance._roles = roles;
    if (rolPrincipal != null && roles.contains(rolPrincipal)) {
      instance._rolPrincipal = rolPrincipal;
    } else if (roles.isNotEmpty) {
      instance._rolPrincipal = roles.first.codigo;
    } else {
      instance._rolPrincipal = null;
    }
  }

  // Cambiar rol principal
  static void cambiarRolPrincipal(String nuevoRol) {
    final instance = _singleton;
    if (instance._roles.contains(nuevoRol)) {
      instance._rolPrincipal = nuevoRol;
    }
  }

  // Limpiar todos los datos
  static void clear() {
    final instance = _singleton;
    instance._user = null;
    instance._nombreUsuario = null;
    instance._roles = [];
    instance._rolPrincipal = null;
  }

  bool tieneRol(String nombreRol) {
    for (RolEntity rol in _roles) {
      if (rol.nombre == nombreRol) {
        return true;
      }
    }
    return false;
  }
}
