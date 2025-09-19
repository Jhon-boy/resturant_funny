class ProductoEntity {
  final int? idProducto;
  final int idSucursal;
  final String nombre;
  final String descripcion;
  final double precio;
  final String categoria;
  final String? imagen;
  final bool? disponible;
  final int? cantidad;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioIngreso;
  final String? userModificacion;
  final String? estado;

  ProductoEntity({
    this.idProducto,
    required this.idSucursal,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    this.imagen,
    this.disponible,
    this.cantidad,
    this.fCreacion,
    this.fModificacion,
    this.usuarioIngreso,
    this.userModificacion,
    this.estado,
  });

  /// Factory constructor desde JSON de la base de datos
  factory ProductoEntity.fromJson(Map<String, dynamic> json) {
    return ProductoEntity(
      idProducto: json['IDPRODUCTO'],
      idSucursal: json['IDSUCURSAL'] ?? 0,
      nombre: json['NOMBRE'] ?? '',
      descripcion: json['DESCRIPCION'] ?? '',
      precio: (json['PRECIO'] ?? 0.0).toDouble(),
      categoria: json['CATEGORIA'] ?? '',
      imagen: json['IMAGEN'],
      disponible: json['DISPONIBLE'],
      cantidad: json['CANTIDAD'],
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
      'IDPRODUCTO': idProducto,
      'IDSUCURSAL': idSucursal,
      'NOMBRE': nombre,
      'DESCRIPCION': descripcion,
      'PRECIO': precio,
      'CATEGORIA': categoria,
      'IMAGEN': imagen,
      'DISPONIBLE': disponible,
      'CANTIDAD': cantidad,
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
      'idProducto': idProducto,
      'idSucursal': idSucursal,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'categoria': categoria,
      'imagen': imagen,
      'disponible': disponible,
      'cantidad': cantidad,
      'fCreacion': fCreacion?.toIso8601String(),
      'fModificacion': fModificacion?.toIso8601String(),
      'usuarioIngreso': usuarioIngreso,
      'userModificacion': userModificacion,
      'estado': estado,
    };
  }

  /// Crea una copia de la entidad con algunos campos modificados
  ProductoEntity copyWith({
    int? idProducto,
    int? idSucursal,
    String? nombre,
    String? descripcion,
    double? precio,
    String? categoria,
    String? imagen,
    bool? disponible,
    int? cantidad,
    DateTime? fCreacion,
    DateTime? fModificacion,
    String? usuarioIngreso,
    String? userModificacion,
    String? estado,
  }) {
    return ProductoEntity(
      idProducto: idProducto ?? this.idProducto,
      idSucursal: idSucursal ?? this.idSucursal,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      categoria: categoria ?? this.categoria,
      imagen: imagen ?? this.imagen,
      disponible: disponible ?? this.disponible,
      cantidad: cantidad ?? this.cantidad,
      fCreacion: fCreacion ?? this.fCreacion,
      fModificacion: fModificacion ?? this.fModificacion,
      usuarioIngreso: usuarioIngreso ?? this.usuarioIngreso,
      userModificacion: userModificacion ?? this.userModificacion,
      estado: estado ?? this.estado,
    );
  }

  /// Verifica si el producto está disponible
  bool get isDisponible => disponible == true;
  String get precioFormateado => '\$${precio.toStringAsFixed(2)}';

  /// Obtiene la cantidad disponible (0 si es null)
  int get cantidadDisponible => cantidad ?? 0;

  /// Verifica si hay stock disponible
  bool get tieneStock => cantidadDisponible > 0;

  /// Verifica si el stock está bajo (menos de 5 unidades)
  bool get stockBajo => cantidadDisponible > 0 && cantidadDisponible < 5;

  String? get imagenUrl {
    if (imagen == null || imagen!.isEmpty) return null;
    return imagen;
  }

  /// Verifica si el producto tiene imagen
  bool get tieneImagen => imagen != null && imagen!.isNotEmpty;

  /// Obtiene las primeras palabras de la descripción
  String get descripcionCorta {
    if (descripcion.length <= 50) return descripcion;
    return '${descripcion.substring(0, 50)}...';
  }

  @override
  String toString() {
    return 'ProductoEntity(idProducto: $idProducto, nombre: $nombre, precio: $precio, categoria: $categoria, disponible: $disponible)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductoEntity &&
        other.idProducto == idProducto &&
        other.idSucursal == idSucursal &&
        other.nombre == nombre &&
        other.descripcion == descripcion &&
        other.precio == precio &&
        other.categoria == categoria &&
        other.imagen == imagen &&
        other.disponible == disponible &&
        other.estado == estado;
  }

  @override
  int get hashCode {
    return Object.hash(
      idProducto,
      idSucursal,
      nombre,
      descripcion,
      precio,
      categoria,
      imagen,
      disponible,
      estado,
    );
  }
  
}
