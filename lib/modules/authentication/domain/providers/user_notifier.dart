import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/authentication/domain/user_context.dart';

class UserNotifier extends StateNotifier<UserContext> {
  UserNotifier() : super(UserContext.initial());

  /// Setear usuario y roles después del login
  void setUser(UserModel user, {List<RolEntity>? roles}) {
    state = UserContext.success(user: user, roles: roles);
  }

  UserModel? getUser() {
    return state.user;
  }

  /// Limpiar usuario (logout)
  void clearUser() {
    state = UserContext.initial();
  }

  /// Actualizar datos del usuario
  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }

  /// Actualizar lista de roles
  void updateRoles(List<RolEntity> roles) {
    state = state.copyWith(roles: roles);
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Verificar si el usuario tiene rol de administrador
  bool get esAdmin {
    return tieneRol('admin');
  }

  /// Verifica si tiene un rol específico
  bool tieneRol(String nombreRol) {
    return state.roles
        .any((rol) => rol.nombre.toLowerCase() == nombreRol.toLowerCase());
  }
}
