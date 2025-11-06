class SucursalEntity {
  final int? idSucursal;
  final String nombre;
  final String? direccion;
  final String? telefono;
  final String? email;
  final bool? estado;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioIngreso;
  final String? userModificacion;

  SucursalEntity({
    this.idSucursal,
    required this.nombre,
    this.direccion,
    this.telefono,
    this.email,
    this.estado,
    this.fCreacion,
    this.fModificacion,
    this.usuarioIngreso,
    this.userModificacion,
  });

  /// Factory constructor desde JSON de la base de datos
  factory SucursalEntity.fromJson(Map<String, dynamic> json) {
    // Manejar estado como booleano o string (para compatibilidad)
    bool? estado;
    if (json['ESTADO'] != null) {
      if (json['ESTADO'] is bool) {
        estado = json['ESTADO'] as bool;
      } else if (json['ESTADO'] is String) {
        estado = json['ESTADO'].toString().toUpperCase() == 'ACTIVO' ||
            json['ESTADO'].toString().toUpperCase() == 'TRUE';
      }
    }

    return SucursalEntity(
      idSucursal: json['IDSUCURSAL'],
      nombre: json['NOMBRE'] ?? '',
      direccion: json['DIRECCION'],
      telefono: json['TELEFONO'],
      email: json['EMAIL'],
      estado: estado,
      fCreacion:
          json['FCREACION'] != null ? DateTime.parse(json['FCREACION']) : null,
      fModificacion: json['FMODIFICACION'] != null
          ? DateTime.parse(json['FMODIFICACION'])
          : null,
      usuarioIngreso: json['USUARIOINGRESO'],
      userModificacion: json['USERMODIFICACION'],
    );
  }

  /// Convierte la entidad a JSON para la base de datos
  Map<String, dynamic> toJson() {
    return {
      'IDSUCURSAL': idSucursal,
      'NOMBRE': nombre,
      'DIRECCION': direccion,
      'TELEFONO': telefono,
      'EMAIL': email,
      'ESTADO': estado,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOINGRESO': usuarioIngreso,
      'USERMODIFICACION': userModificacion,
    };
  }

  /// Convierte la entidad a JSON para la UI (nombres en camelCase)
  Map<String, dynamic> toJsonForUI() {
    return {
      'idSucursal': idSucursal,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'estado': estado,
      'fCreacion': fCreacion?.toIso8601String(),
      'fModificacion': fModificacion?.toIso8601String(),
      'usuarioIngreso': usuarioIngreso,
      'userModificacion': userModificacion,
    };
  }

  /// Crea una copia de la entidad con algunos campos modificados
  SucursalEntity copyWith({
    int? idSucursal,
    String? nombre,
    String? direccion,
    String? telefono,
    String? email,
    bool? estado,
    DateTime? fCreacion,
    DateTime? fModificacion,
    String? usuarioIngreso,
    String? userModificacion,
  }) {
    return SucursalEntity(
      idSucursal: idSucursal ?? this.idSucursal,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      estado: estado ?? this.estado,
      fCreacion: fCreacion ?? this.fCreacion,
      fModificacion: fModificacion ?? this.fModificacion,
      usuarioIngreso: usuarioIngreso ?? this.usuarioIngreso,
      userModificacion: userModificacion ?? this.userModificacion,
    );
  }

  /// Verifica si la sucursal está activa
  bool get isActiva => estado == true;

  /// Obtiene la información de contacto formateada
  String get contactoFormateado {
    List<String> contactos = [];
    if (telefono != null && telefono!.isNotEmpty) {
      contactos.add('Tel: $telefono');
    }
    if (email != null && email!.isNotEmpty) {
      contactos.add('Email: $email');
    }
    return contactos.join(' | ');
  }

  @override
  String toString() {
    return 'SucursalEntity(idSucursal: $idSucursal, nombre: $nombre, direccion: $direccion)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SucursalEntity &&
        other.idSucursal == idSucursal &&
        other.nombre == nombre &&
        other.direccion == direccion &&
        other.telefono == telefono &&
        other.email == email &&
        other.estado == estado;
  }

  @override
  int get hashCode {
    return Object.hash(
      idSucursal,
      nombre,
      direccion,
      telefono,
      email,
      estado,
    );
  }
}
