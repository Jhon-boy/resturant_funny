// ignore_for_file: constant_identifier_names
// ENUMERADO DEDICADO PARA DECLARAR LAS RUTAS DE LAS PETICIONES HTTP
//
enum Endpoints {
  LOGIN('/login', 'POST', 'REALIZA LOGIN DE USUARIO'),
  LOGOUT('/login', 'POST', 'CIERRA SESIÓN DE USUARIO'),
  CHECK_AUTH('/check-auth', 'GET', 'VERIFICA SI EL USUARIO ESTÁ AUTENTICADO'),
  REGISTER('/register', 'POST', 'REGISTRA UN NUEVO USUARIO'),
  FORGOT_PASSWORD(
      '/forgot-password', 'POST', 'ENVIAR CORREO PARA RECUPERAR CONTRASEÑA'),
  RESET_PASSWORD('/reset-password', 'POST', 'RESTAURAR CONTRASEÑA'),
  VERIFY_PASSWORD('/verify-password', 'POST', 'VERIFICAR CONTRASEÑA'),
  GET_USER('/user', 'GET', 'OBTENER DATOS DEL USUARIO');

  const Endpoints(this.path, this.method, this.description);

  final String path;
  final String method;
  final String description;

  /// Obtener solo el path
  String get getPath => path;

  /// Obtener solo el método
  String get getMethod => method;

  /// Obtener URL completa con base URL
  String getFullUrl(String baseUrl) => '$baseUrl$path';
}
