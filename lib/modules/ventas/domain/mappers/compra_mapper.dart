import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/venta_entity.dart';

class CompraMapper {
  static VentaEntity toVentaEntity(
      double subtotal,
      double delivery,
      bool conFactura,
      bool conDelivery,
      bool aplicaIva,
      double total,
      String comentario,
      String usuarioIngreso,
      int idMesa,
      String tipo,
      String cliente) {
    return VentaEntity(
        subtotal: subtotal,
        delivery: delivery,
        total: total,
        conFactura: conFactura,
        comentario:
            '$comentario | $cliente ${conDelivery ? '| Delivery ($delivery)' : ''}',
        usuarioIngreso: usuarioIngreso,
        idMesa: idMesa,
        cliente: cliente,
        tipoVenta: tipo ,
        idEmpleado: int.parse(usuarioIngreso),
        fecha: AppUtils.getFechaActual(),
        fCreacion: AppUtils.getFechaActual(),
        estado: 'PENDIENTE');
  }
}
