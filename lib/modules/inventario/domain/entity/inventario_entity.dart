class InventarioEntity {
  final int? idInventario;
  final int idSucursal;
  final String nombre;
  final String? descripcion;
  final String? categoria;
  final int? stock;
  final double? precioUnitario;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioIngreso;
  final String? userModificacion;
  final String? estado;

  InventarioEntity({
    this.idInventario,
    required this.idSucursal,
    required this.nombre,
    this.descripcion,
    this.categoria,
    this.stock,
    this.precioUnitario,
    this.fCreacion,
    this.fModificacion,
    this.usuarioIngreso,
    this.userModificacion,
    this.estado,
  });

  /// Factory constructor desde JSON de la base de datos
  factory InventarioEntity.fromJson(Map<String, dynamic> json) {
    return InventarioEntity(
      idInventario: json['IDINVENTARIO'],
      idSucursal: json['IDSUCURSAL'] ?? 0,
      nombre: json['NOMBRE'] ?? '',
      descripcion: json['DESCRIPCION'],
      categoria: json['CATEGORIA'],
      stock: json['STOCK'],
      precioUnitario: json['PRECIO_UNITARIO']?.toDouble(),
      fCreacion:
          json['FCREACION'] != null ? DateTime.parse(json['FCREACION']) : null,
      fModificacion: json['FMODIFICACION'] != null
          ? DateTime.parse(json['FMODIFICACION'])
          : null,
      usuarioIngreso: json['USUARIOINGRESO'],
      userModificacion: json['USERMODIFICACION'],
      estado: json['ESTADO'],
    );
  }

  /// Convierte la entidad a JSON para la base de datos
  Map<String, dynamic> toJson() {
    return {
      'IDINVENTARIO': idInventario,
      'IDSUCURSAL': idSucursal,
      'NOMBRE': nombre,
      'DESCRIPCION': descripcion,
      'CATEGORIA': categoria,
      'STOCK': stock,
      'PRECIO_UNITARIO': precioUnitario,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOINGRESO': usuarioIngreso,
      'USERMODIFICACION': userModificacion,
      'ESTADO': estado,
    };
  }

  /// Convierte la entidad a JSON para la UI (nombres en camelCase)
  Map<String, dynamic> toJsonForUI() {
    return {
      'idInventario': idInventario,
      'idSucursal': idSucursal,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'stock': stock,
      'precioUnitario': precioUnitario,
      'fCreacion': fCreacion?.toIso8601String(),
      'fModificacion': fModificacion?.toIso8601String(),
      'usuarioIngreso': usuarioIngreso,
      'userModificacion': userModificacion,
      'estado': estado,
    };
  }

  /// Crea una copia de la entidad con algunos campos modificados
  InventarioEntity copyWith({
    int? idInventario,
    int? idSucursal,
    String? nombre,
    String? descripcion,
    String? categoria,
    int? stock,
    double? precioUnitario,
    DateTime? fCreacion,
    DateTime? fModificacion,
    String? usuarioIngreso,
    String? userModificacion,
    String? estado,
  }) {
    return InventarioEntity(
      idInventario: idInventario ?? this.idInventario,
      idSucursal: idSucursal ?? this.idSucursal,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      stock: stock ?? this.stock,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      fCreacion: fCreacion ?? this.fCreacion,
      fModificacion: fModificacion ?? this.fModificacion,
      usuarioIngreso: usuarioIngreso ?? this.usuarioIngreso,
      userModificacion: userModificacion ?? this.userModificacion,
      estado: estado ?? this.estado,
    );
  }

  /// Verifica si el inventario está activo
  bool get isActivo => estado == 'ACTIVO' || estado == null;

  /// Verifica si hay stock disponible
  bool get tieneStock => (stock ?? 0) > 0;

  /// Verifica si el stock está bajo (menos de 10 unidades)
  bool get stockBajo => (stock ?? 0) < 10;

  /// Verifica si el stock está agotado
  bool get stockAgotado => (stock ?? 0) <= 0;

  /// Obtiene el stock formateado
  String get stockFormateado {
    if (stock == null) return 'Sin stock';
    return '$stock unidades';
  }

  /// Obtiene el precio formateado
  String get precioFormateado {
    if (precioUnitario == null) return '\$0.00';
    return '\$${precioUnitario!.toStringAsFixed(2)}';
  }

  /// Obtiene el valor total del inventario
  double get valorTotal {
    if (stock == null || precioUnitario == null) return 0.0;
    return stock! * precioUnitario!;
  }

  /// Obtiene el valor total formateado
  String get valorTotalFormateado {
    return '\$${valorTotal.toStringAsFixed(2)}';
  }

  /// Obtiene el estado con formato
  String get estadoFormateado {
    if (estado == null) return 'Sin estado';
    return estado!.toUpperCase();
  }

  @override
  String toString() {
    return 'InventarioEntity(idInventario: $idInventario, nombre: $nombre, stock: $stock)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InventarioEntity &&
        other.idInventario == idInventario &&
        other.idSucursal == idSucursal &&
        other.nombre == nombre &&
        other.stock == stock;
  }

  @override
  int get hashCode {
    return Object.hash(
      idInventario,
      idSucursal,
      nombre,
      stock,
    );
  }
}
