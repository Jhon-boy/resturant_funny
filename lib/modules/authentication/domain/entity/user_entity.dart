import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';

class UserEntity {
  final String id;
  final String nombre;
  final String identificacion;
  final String numeroEmpleado;
  final String email;
  final String telefono;
  final String cargo;
  final String departamento;
  final List<String> roles;
  final String estado;
  final DateTime fechaIngreso;
  final DateTime? fechaNacimiento;
  final String? avatar;
  final String? direccion;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserEntity({
    required this.id,
    required this.nombre,
    required this.identificacion,
    required this.numeroEmpleado,
    required this.email,
    required this.telefono,
    required this.cargo,
    required this.departamento,
    required this.roles,
    required this.estado,
    required this.fechaIngreso,
    this.fechaNacimiento,
    this.avatar,
    this.direccion,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'identificacion': identificacion,
      'numeroEmpleado': numeroEmpleado,
      'email': email,
      'telefono': telefono,
      'cargo': cargo,
      'departamento': departamento,
      'roles': roles,
      'estado': estado,
      'fechaIngreso': fechaIngreso.toIso8601String(),
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'avatar': avatar,
      'direccion': direccion,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // JSON Deserialization
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      identificacion: json['identificacion'] ?? '',
      numeroEmpleado: json['numeroEmpleado'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      cargo: json['cargo'] ?? '',
      departamento: json['departamento'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      estado: json['estado'] ?? '',
      fechaIngreso: DateTime.parse(
          json['fechaIngreso'] ?? DateTime.now().toIso8601String()),
      fechaNacimiento: json['fechaNacimiento'] != null
          ? DateTime.parse(json['fechaNacimiento'])
          : null,
      avatar: json['avatar'],
      direccion: json['direccion'],
      isActive: json['isActive'] ?? true,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Copy with method for creating modified instances
  UserEntity copyWith({
    String? id,
    String? nombre,
    String? identificacion,
    String? numeroEmpleado,
    String? email,
    String? telefono,
    String? cargo,
    String? departamento,
    List<RolEntity>? roles,
    String? estado,
    DateTime? fechaIngreso,
    DateTime? fechaNacimiento,
    String? avatar,
    String? direccion,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      identificacion: identificacion ?? this.identificacion,
      numeroEmpleado: numeroEmpleado ?? this.numeroEmpleado,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      cargo: cargo ?? this.cargo,
      departamento: departamento ?? this.departamento,
      roles: roles?.map((role) => role.nombre).toList() ?? this.roles,
      estado: estado ?? this.estado,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      avatar: avatar ?? this.avatar,
      direccion: direccion ?? this.direccion,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.id == id &&
        other.nombre == nombre &&
        other.identificacion == identificacion &&
        other.numeroEmpleado == numeroEmpleado &&
        other.email == email &&
        other.telefono == telefono &&
        other.cargo == cargo &&
        other.departamento == departamento &&
        other.roles.length == roles.length &&
        other.roles.every((role) => roles.contains(role)) &&
        other.estado == estado &&
        other.fechaIngreso == fechaIngreso &&
        other.fechaNacimiento == fechaNacimiento &&
        other.avatar == avatar &&
        other.direccion == direccion &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      nombre,
      identificacion,
      numeroEmpleado,
      email,
      telefono,
      cargo,
      departamento,
      Object.hashAll(roles),
      estado,
      fechaIngreso,
      fechaNacimiento,
      avatar,
      direccion,
      isActive,
      createdAt,
      updatedAt,
    );
  }

  // ToString method for debugging
  @override
  String toString() {
    return 'UserEntity(id: $id, nombre: $nombre, email: $email, cargo: $cargo, departamento: $departamento, roles: $roles, isActive: $isActive)';
  }
}
