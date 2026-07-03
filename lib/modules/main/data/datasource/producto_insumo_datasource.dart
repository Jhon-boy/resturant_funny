import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/services/supabase_service.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_insumo_entity.dart';

class ProductoInsumoDatasource {
  final WidgetRef ref;

  ProductoInsumoDatasource({required this.ref});

  Future<List<ProductoInsumoEntity>> getByProducto(int idProducto) async {
    try {
      final result = await SupabaseService.select(
        table: 'TPRODUCTO_INSUMO',
        filters: {'IDPRODUCTO': idProducto},
      );
      return result.map((j) => ProductoInsumoEntity.fromJson(j)).toList();
    } catch (e) {
      if (e is SessionException) rethrow;
      throw DatabaseException('Error al obtener insumos del producto $idProducto: $e');
    }
  }
}
