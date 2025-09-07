class ProductosEntity {
  final int idProducto;
  final int idSucursal;
  final String nombre;
  final String? descripcion;
  final double precio;
  final String? categoria;
  final String imagen;
  final bool disponible;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioIngreso;
  final String? userModificacion;
  final String estado;

  ProductosEntity({
    required this.idProducto,
    required this.idSucursal,
    required this.nombre,
    this.descripcion,
    required this.precio,
    this.categoria,
    required this.imagen,
    required this.disponible,
    this.fCreacion,
    this.fModificacion,
    this.usuarioIngreso,
    this.userModificacion,
    required this.estado,
  });

  // Método de deserialización
  factory ProductosEntity.fromJson(Map<String, dynamic> json) {
    return ProductosEntity(
      idProducto: json['IDPRODUCTO'] ?? 0,
      idSucursal: json['IDSUCURSAL'] ?? 0,
      nombre: json['NOMBRE'] ?? '',
      descripcion: json['DESCRIPCION'],
      precio: (json['PRECIO'] != null)
          ? double.tryParse(json['PRECIO'].toString()) ?? 0.0
          : 0.0,
      categoria: json['CATEGORIA'],
      imagen: json['IMAGEN'],
      disponible: json['DISPONIBLE'] ?? false,
      fCreacion: json['FCREACION'] != null
          ? DateTime.tryParse(json['FCREACION'].toString())
          : null,
      fModificacion: json['FMODIFICACION'] != null
          ? DateTime.tryParse(json['FMODIFICACION'].toString())
          : null,
      usuarioIngreso: json['USUARIOINGRESO'],
      userModificacion: json['USERMODIFICACION'],
      estado: json['ESTADO'],
    );
  }

  // Método de serialización
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
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOINGRESO': usuarioIngreso,
      'USERMODIFICACION': userModificacion,
      'ESTADO': estado,
    };
  }
}
