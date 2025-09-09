import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/user_entity.dart';
class UserContext {
  final UserEntity? user;
  final List<RolEntity> roles;
  final bool isLoading;
  final String? error;

  UserContext({
    this.user,
    this.roles = const [],
    this.isLoading = false,
    this.error,
  });

  factory UserContext.initial() {
    return UserContext(isLoading: true);
  }

  factory UserContext.error(String error) {
    return UserContext(isLoading: false, error: error);
  }

  factory UserContext.success({required UserEntity user, List<RolEntity>? roles}) {
    return UserContext(user: user, roles: roles ?? [], isLoading: false);
  }

  UserContext copyWith({
    UserEntity? user,
    List<RolEntity>? roles,
    bool? isLoading,
    String? error,
  }) {
    return UserContext(
      user: user ?? this.user,
      roles: roles ?? this.roles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get tieneUsuario => user != null;
  bool get tieneRoles => roles.isNotEmpty;
  bool get estaCargando => isLoading;
  bool get tieneError => error != null;

  /// Verifica si el usuario tiene un rol específico
  bool tieneRol(String nombreRol) {
    return roles.any((rol) => rol.nombre.toLowerCase() == nombreRol.toLowerCase());
  }
}
