import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';

class CartProduct {
  final ProductoEntity producto;
  int cantidad;
  CartProduct({required this.producto, required this.cantidad});
}