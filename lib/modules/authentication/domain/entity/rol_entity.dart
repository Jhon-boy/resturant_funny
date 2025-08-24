// ENTIDAD PARA LOS ROLES DE USUARIOS
class RolEntity {
  final String id;
  final String nombre;
  final String descripcion;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RolEntity({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // JSON Deserialization
  factory RolEntity.fromJson(Map<String, dynamic> json) {
    return RolEntity(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Copy with method for creating modified instances
  RolEntity copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RolEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RolEntity &&
        other.id == id &&
        other.nombre == nombre &&
        other.descripcion == descripcion &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      nombre,
      descripcion,
      isActive,
      createdAt,
      updatedAt,
    );
  }

  // ToString method for debugging
  @override
  String toString() {
    return 'RolEntity(id: $id, nombre: $nombre, descripcion: $descripcion, isActive: $isActive)';
  }
}
