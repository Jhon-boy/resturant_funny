import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/user_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/auth_state.dart';

// NOTIFICADOR PARA LA AUTENTICACION
// ESTADO DE LA AUTENTICACION
class UserNotifier extends StateNotifier<AuthState> {
  UserNotifier() : super(AuthState()) {
    _startInactivityTimer();
  }

  Timer? _inactivityTimer;
  static const _timeout = Duration(minutes: 10);

  // ==================== SETTERS ====================
  void setUser(UserEntity user) {
    state = state.copyWith(user: user);
    resetInactivity();
  }

  void setToken(String token) {
    state = state.copyWith(token: token);
    resetInactivity();
  }

  void logout() {
    state = AuthState();
    _inactivityTimer?.cancel();
  }

  // ==================== INACTIVIDAD ====================
  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_timeout, () {
      logout();
    });
  }

  void resetInactivity() {
    _startInactivityTimer();
  }

// ==================== SET LOADING ====================
  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  // ==================== GETTERS ====================
  UserEntity? get user => state.user;

  String? get token => state.token;

  List<String> get roles => [];

  bool get isAdmin => roles.contains('ADMIN');
}

// ==================== PROVIDER GLOBAL ====================
final userProvider = StateNotifierProvider<UserNotifier, AuthState>(
  (ref) => UserNotifier(),
);
