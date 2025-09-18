import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import '../dining_context.dart';
import '../entity/producto_entity.dart';

/// Notifier para manejar el DiningContext
class DiningNotifier extends StateNotifier<DiningContext> {
  DiningNotifier() : super(DiningContext.initial());

  void setSucursal(SucursalEntity sucursal) {
    state = state.copyWith(
      sucursal: sucursal,
      ultimaActualizacion: DateTime.now(),
    );
  }

  /// Reemplaza toda la lista de productos
  void setProductos(List<ProductoEntity> productos) {
    state = state.copyWith(
      productos: List<ProductoEntity>.from(productos),
      ultimaActualizacion: DateTime.now(),
    );
  }

  void agregarProducto(ProductoEntity producto) {
    final productos = List<ProductoEntity>.from(state.productos)..add(producto);

    state = state.copyWith(
      productos: productos,
      ultimaActualizacion: DateTime.now(),
    );
  }

  /// Reducir cantidad de un producto (venta)
  void reducirCantidadProducto(int idProducto, int cantidadVendida) {
    final productos = List<ProductoEntity>.from(state.productos);
    final index = productos.indexWhere((p) => p.idProducto == idProducto);

    if (index != -1) {
      final producto = productos[index];
      final nuevaCantidad = (producto.cantidad ?? 0) - cantidadVendida;

      productos[index] = producto.copyWith(
        cantidad: nuevaCantidad,
        disponible: nuevaCantidad > 0,
      );

      state = state.copyWith(
        productos: productos,
        ultimaActualizacion: DateTime.now(),
      );
    }
  }

  /// Aumentar cantidad de un producto (stock recibido)
  void aumentarCantidadProducto(int idProducto, int cantidadRecibida) {
    final productos = List<ProductoEntity>.from(state.productos);
    final index = productos.indexWhere((p) => p.idProducto == idProducto);

    if (index != -1) {
      final producto = productos[index];
      final nuevaCantidad = (producto.cantidad ?? 0) + cantidadRecibida;

      productos[index] = producto.copyWith(
        cantidad: nuevaCantidad,
        disponible: nuevaCantidad > 0,
      );

      state = state.copyWith(
        productos: productos,
        ultimaActualizacion: DateTime.now(),
      );
    }
  }

  /// Actualizar disponibilidad manual de un producto
  void actualizarDisponibilidadProducto(int idProducto, bool disponible) {
    final productos = List<ProductoEntity>.from(state.productos);
    final index = productos.indexWhere((p) => p.idProducto == idProducto);

    if (index != -1) {
      productos[index] = productos[index].copyWith(disponible: disponible);

      state = state.copyWith(
        productos: productos,
        ultimaActualizacion: DateTime.now(),
      );
    }
  }

  /// Obtener producto por ID
  ProductoEntity? obtenerProductoPorId(int idProducto) {
    try {
      return state.productos.firstWhere((p) => p.idProducto == idProducto);
    } catch (_) {
      return null;
    }
  }

  /// Verificar disponibilidad de un producto
  bool verificarDisponibilidadProducto(int idProducto, int cantidadSolicitada) {
    final producto = obtenerProductoPorId(idProducto);
    if (producto == null || !producto.isDisponible) return false;

    if (producto.cantidad != null) {
      return producto.cantidad! >= cantidadSolicitada;
    }
    return true;
  }

  /// Productos con stock bajo
  List<ProductoEntity> obtenerProductosStockBajo({int limiteStock = 5}) {
    return state.productos.where((producto) {
      if (producto.cantidad == null) return false;
      return producto.cantidad! <= limiteStock && producto.cantidad! > 0;
    }).toList();
  }

  /// Productos agotados
  List<ProductoEntity> obtenerProductosAgotados() {
    return state.productos.where((producto) {
      if (producto.cantidad == null) return false;
      return producto.cantidad! <= 0;
    }).toList();
  }

  /// Limpiar error
  void limpiarError() {
    state = state.copyWith(error: null);
  }

  /// Limpiar todos los datos
  void limpiarDatos() {
    state = DiningContext.initial();
  }
}
