import 'producto_entity.dart';
import 'sucursal_entity.dart';

/// Entidad que combina productos y sucursal para el provider
class DiningContext {
  final SucursalEntity sucursal;
  final List<ProductoEntity> productos;
  final DateTime ultimaActualizacion;
  final bool isLoading;
  final String? error;

  DiningContext({
    required this.sucursal,
    required this.productos,
    required this.ultimaActualizacion,
    this.isLoading = false,
    this.error,
  });

  /// Factory constructor para estado inicial
  factory DiningContext.initial() {
    return DiningContext(
      sucursal: SucursalEntity(nombre: 'Cargando...'),
      productos: [],
      ultimaActualizacion: DateTime.now(),
      isLoading: true,
    );
  }

  /// Factory constructor para estado de error
  factory DiningContext.error(String error) {
    return DiningContext(
      sucursal: SucursalEntity(nombre: 'Error'),
      productos: [],
      ultimaActualizacion: DateTime.now(),
      isLoading: false,
      error: error,
    );
  }

  /// Factory constructor para estado exitoso
  factory DiningContext.success({
    required SucursalEntity sucursal,
    required List<ProductoEntity> productos,
  }) {
    return DiningContext(
      sucursal: sucursal,
      productos: productos,
      ultimaActualizacion: DateTime.now(),
      isLoading: false,
      error: null,
    );
  }

  /// Crea una copia con algunos campos modificados
  DiningContext copyWith({
    SucursalEntity? sucursal,
    List<ProductoEntity>? productos,
    DateTime? ultimaActualizacion,
    bool? isLoading,
    String? error,
  }) {
    return DiningContext(
      sucursal: sucursal ?? this.sucursal,
      productos: productos ?? this.productos,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Obtiene productos por categoría
  List<ProductoEntity> getProductosPorCategoria(String categoria) {
    return productos
        .where((producto) => producto.categoria == categoria)
        .toList();
  }

  /// Obtiene todas las categorías disponibles
  List<String> get categorias {
    return productos.map((producto) => producto.categoria).toSet().toList()
      ..sort();
  }

  /// Obtiene solo productos disponibles
  List<ProductoEntity> get productosDisponibles {
    return productos.where((producto) => producto.isDisponible).toList();
  }

  /// Obtiene productos por rango de precio
  List<ProductoEntity> getProductosPorPrecio(
      double precioMin, double precioMax) {
    return productos
        .where((producto) =>
            producto.precio >= precioMin && producto.precio <= precioMax)
        .toList();
  }

  /// Busca productos por nombre
  List<ProductoEntity> buscarProductos(String query) {
    if (query.isEmpty) return productos;

    final queryLower = query.toLowerCase();
    return productos
        .where((producto) =>
            producto.nombre.toLowerCase().contains(queryLower) ||
            producto.descripcion.toLowerCase().contains(queryLower) ||
            producto.categoria.toLowerCase().contains(queryLower))
        .toList();
  }

  /// Obtiene el total de productos
  int get totalProductos => productos.length;

  /// Obtiene el total de productos disponibles
  int get totalProductosDisponibles => productosDisponibles.length;
 

  /// Verifica si hay productos
  bool get tieneProductos => productos.isNotEmpty;

  /// Verifica si está cargando
  bool get estaCargando => isLoading;

  /// Verifica si hay error
  bool get tieneError => error != null;

 

  /// Obtiene estadísticas de los productos
  Map<String, dynamic> get estadisticas {
    return {
      'totalProductos': totalProductos,
      'productosDisponibles': totalProductosDisponibles,
      'productosNoDisponibles': totalProductos - totalProductosDisponibles,
      'categorias': categorias.length, 
      'ultimaActualizacion': ultimaActualizacion.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'DiningContext(sucursal: ${sucursal.nombre}, productos: ${productos.length}, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiningContext &&
        other.sucursal == sucursal &&
        other.productos.length == productos.length &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      sucursal,
      productos.length,
      isLoading,
      error,
    );
  }
}
