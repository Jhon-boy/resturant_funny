import 'package:resturant_funny/modules/authentication/domain/entity/user_entity.dart';

class AuthState {
  final UserEntity? user;
  final String? token;
  final bool isLoading;

  AuthState({this.user, this.token, this.isLoading = false});

  AuthState copyWith({
    UserEntity? user,
    String? token,
    bool? isLoading,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
