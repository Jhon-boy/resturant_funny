class UserModel {
  // ==== Campos obligatorios ====
  final String nombres;
  final String apellidos;

  // ==== Campos de TUSUARIO ====
  final int? idUsuario;
  final int? idSucursal;
  final String? usuario;
  final String? password;
  final bool? temporal;
  final DateTime? fCreacionUsuario;
  final DateTime? fModificacionUsuario;
  final String? usuarioIngreso;
  final String? userModificacion;

  // ==== Campos de TPERSONA ====
  final String? identificacion;
  final DateTime? fnacimiento;
  final String? genero;
  final String? correo;
  final String? telefono;
  final String? direccion;
  final String? tipoIdentificacion;
  final String? estadoPersona;
  final DateTime? fCreacionPersona;
  final DateTime? fModificacionPersona;
  final String? usuarioIngresoPersona;
  final String? userModificacionPersona;

  UserModel({
    required this.nombres,
    required this.apellidos,
    this.idUsuario,
    this.idSucursal,
    this.usuario,
    this.password,
    this.temporal,
    this.fCreacionUsuario,
    this.fModificacionUsuario,
    this.usuarioIngreso,
    this.userModificacion,
    this.identificacion,
    this.fnacimiento,
    this.genero,
    this.correo,
    this.telefono,
    this.direccion,
    this.tipoIdentificacion,
    this.estadoPersona,
    this.fCreacionPersona,
    this.fModificacionPersona,
    this.usuarioIngresoPersona,
    this.userModificacionPersona,
  });

  // ==== Factory desde JSON combinado ====
  factory UserModel.fromJson({
    required Map<String, dynamic> usuarioJson,
    required Map<String, dynamic> personaJson,
  }) {
    return UserModel(
      // TPERSONA obligatorios
      nombres: personaJson['NOMBRES'] ?? '',
      apellidos: personaJson['APELLIDOS'] ?? '',

      // TUSUARIO
      idUsuario: usuarioJson['IDUSUARIO'],
      idSucursal: usuarioJson['IDSUCURSAL'],
      usuario: usuarioJson['USUARIO'],
      password: usuarioJson['PASSWORD'],
      temporal: usuarioJson['TEMPORAL'],
      fCreacionUsuario: usuarioJson['FCREACION'] != null
          ? DateTime.parse(usuarioJson['FCREACION'])
          : null,
      fModificacionUsuario: usuarioJson['FMODIFICACION'] != null
          ? DateTime.parse(usuarioJson['FMODIFICACION'])
          : null,
      usuarioIngreso: usuarioJson['USUARIOINGRESO'],
      userModificacion: usuarioJson['USERMODIFICACION'],

      // TPERSONA
      identificacion: personaJson['IDENTIFICACION'],
      fnacimiento: personaJson['FNACIMIENTO'] != null
          ? DateTime.parse(personaJson['FNACIMIENTO'])
          : null,
      genero: personaJson['GENERO'],
      correo: personaJson['CORREO'],
      telefono: personaJson['TELEFONO'],
      direccion: personaJson['DIRECCION'],
      tipoIdentificacion: personaJson['TIPOIDENTIFICACION'],
      estadoPersona: personaJson['ESTADO'],
      fCreacionPersona: personaJson['FCREACION'] != null
          ? DateTime.parse(personaJson['FCREACION'])
          : null,
      fModificacionPersona: personaJson['FMODIFICACION'] != null
          ? DateTime.parse(personaJson['FMODIFICACION'])
          : null,
      usuarioIngresoPersona: personaJson['USUARIOINGRESO'],
      userModificacionPersona: personaJson['USERMODIFICACION'],
    );
  }

  // ==== ToJson opcional ====
  Map<String, dynamic> toJson() {
    return {
      'nombres': nombres,
      'apellidos': apellidos,
      'idUsuario': idUsuario,
      'idSucursal': idSucursal,
      'usuario': usuario,
      'password': password,
      'temporal': temporal,
      'fCreacionUsuario': fCreacionUsuario?.toIso8601String(),
      'fModificacionUsuario': fModificacionUsuario?.toIso8601String(),
      'usuarioIngreso': usuarioIngreso,
      'userModificacion': userModificacion,
      'identificacion': identificacion,
      'fnacimiento': fnacimiento?.toIso8601String(),
      'genero': genero,
      'correo': correo,
      'telefono': telefono,
      'direccion': direccion,
      'tipoIdentificacion': tipoIdentificacion,
      'estadoPersona': estadoPersona,
      'fCreacionPersona': fCreacionPersona?.toIso8601String(),
      'fModificacionPersona': fModificacionPersona?.toIso8601String(),
      'usuarioIngresoPersona': usuarioIngresoPersona,
      'userModificacionPersona': userModificacionPersona,
    };
  }
}
