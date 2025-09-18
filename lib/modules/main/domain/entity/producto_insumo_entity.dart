class ProductoInsumoEntity {
  final int? idProductoInsumo;
  final int idProducto;
  final int? idInventario;
  final int? cantidad;

  ProductoInsumoEntity({
    this.idProductoInsumo,
    required this.idProducto,
    this.idInventario,
    this.cantidad,
  });

  /// Factory constructor desde JSON de la base de datos
  factory ProductoInsumoEntity.fromJson(Map<String, dynamic> json) {
    return ProductoInsumoEntity(
      idProductoInsumo: json['IDPRODUCTO_INSUMO'],
      idProducto: json['IDPRODUCTO'] ?? 0,
      idInventario: json['IDINVENTARIO'],
      cantidad: json['CANTIDAD'],
    );
  }

  /// Convierte la entidad a JSON para la base de datos
  Map<String, dynamic> toJson() {
    return {
      'IDPRODUCTO_INSUMO': idProductoInsumo,
      'IDPRODUCTO': idProducto,
      'IDINVENTARIO': idInventario,
      'CANTIDAD': cantidad,
    };
  }

  /// Convierte la entidad a JSON para la UI (nombres en camelCase)
  Map<String, dynamic> toJsonForUI() {
    return {
      'idProductoInsumo': idProductoInsumo,
      'idProducto': idProducto,
      'idInventario': idInventario,
      'cantidad': cantidad,
    };
  }

  /// Crea una copia de la entidad con algunos campos modificados
  ProductoInsumoEntity copyWith({
    int? idProductoInsumo,
    int? idProducto,
    int? idInventario,
    int? cantidad,
  }) {
    return ProductoInsumoEntity(
      idProductoInsumo: idProductoInsumo ?? this.idProductoInsumo,
      idProducto: idProducto ?? this.idProducto,
      idInventario: idInventario ?? this.idInventario,
      cantidad: cantidad ?? this.cantidad,
    );
  }

  /// Verifica si tiene cantidad válida
  bool get tieneCantidad => (cantidad ?? 0) > 0;

  /// Verifica si tiene inventario asociado
  bool get tieneInventario => idInventario != null;

  /// Obtiene la cantidad formateada
  String get cantidadFormateada {
    if (cantidad == null) return 'Sin cantidad';
    return '$cantidad unidades';
  }

  /// Verifica si la cantidad es suficiente (mayor a 0)
  bool get cantidadSuficiente => (cantidad ?? 0) > 0;

  /// Verifica si la cantidad es crítica (menor a 5)
  bool get cantidadCritica => (cantidad ?? 0) < 5;

  @override
  String toString() {
    return 'ProductoInsumoEntity(idProductoInsumo: $idProductoInsumo, idProducto: $idProducto, idInventario: $idInventario, cantidad: $cantidad)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductoInsumoEntity &&
        other.idProductoInsumo == idProductoInsumo &&
        other.idProducto == idProducto &&
        other.idInventario == idInventario &&
        other.cantidad == cantidad;
  }

  @override
  int get hashCode {
    return Object.hash(
      idProductoInsumo,
      idProducto,
      idInventario,
      cantidad,
    );
  }
}
