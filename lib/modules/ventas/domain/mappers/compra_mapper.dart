import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/detalle_venta_entity.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/venta_entity.dart';

class CompraMapper {
  static VentaEntity toVentaEntity(
      double subtotal,
      double delivery,
      bool conFactura,
      bool conDelivery,
      bool aplicaIva,
      double total,
      double montoRecibido,
      String comentario,
      String usuarioIngreso,
      int idMesa,
      String tipo,
      String cliente) {
    return VentaEntity(
        subtotal: subtotal,
        delivery: delivery,
        total: total,
        montoRecibido: montoRecibido,
        conFactura: conFactura,
        comentario:
            '$comentario | $cliente ${conDelivery ? '| Delivery ($delivery)' : ''}',
        usuarioIngreso: usuarioIngreso,
        idMesa: idMesa,
        cliente: cliente,
        tipoVenta: tipo,
        idEmpleado: int.parse(usuarioIngreso),
        fecha: AppUtils.getFechaActual(),
        fCreacion: AppUtils.getFechaActual(),
        estado: 'FINALIZADA');
  }

  static DetalleVentaEntity toDetalleVenta(VentaEntity venta, int cantidad,
      ProductoEntity producto, String usuarioIngreso, String metodoPago) {
    return DetalleVentaEntity(
        idVenta: venta.idVenta!,
        idProducto: producto.idProducto!,
        cantidad: cantidad,
        precioUnitario: producto.precio,
        subtotal: cantidad * producto.precio,
        usuarioIngreso: usuarioIngreso,
        fCreacion: AppUtils.getFechaActual(),
        metodoPago: metodoPago);
  }
}
