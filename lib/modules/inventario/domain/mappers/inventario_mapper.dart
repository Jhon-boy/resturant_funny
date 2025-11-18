import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/inventario/domain/entity/inventario_entity.dart';
import 'package:resturant_funny/shared/enums/estados_persona.dart';

class InventarioMapper {
  static InventarioEntity createInventario(
      int idSucursal,
      String nombre,
      String descripcion,
      String categoria,
      int stock,
      double precio,
      String usuarioIngreso) {
    return InventarioEntity(
        idSucursal: idSucursal,
        nombre: nombre,
        descripcion: descripcion.isEmpty ? null : descripcion,
        categoria: categoria,
        stock: stock,
        precioUnitario: precio,
        usuarioIngreso: usuarioIngreso,
        estado: EstadosPersona.ACTIVO.getState,
        fCreacion: AppUtils.getFechaActual());
  }

  static Map<String, dynamic> updateInventario(
      String nombre,
      String descripcion,
      String categoria,
      int stock,
      double precio,
      String usuarioModificacion,
      int idSucursal) {
    return {
      'NOMBRE': nombre,
      'DESCRIPCION': descripcion.isEmpty ? null : descripcion,
      'CATEGORIA': categoria.isEmpty ? null : categoria,
      'STOCK': stock,
      'PRECIO_UNITARIO': precio,
      'IDSUCURSAL': idSucursal,
      'USERMODIFICACION': usuarioModificacion,
      'FMODIFICACION': DateTime.now().toIso8601String(),
    };
  }
}
