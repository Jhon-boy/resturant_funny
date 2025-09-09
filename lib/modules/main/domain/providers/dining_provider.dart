import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/modules/main/domain/providers/dining_notifier.dart';
import '../entity/dining_context.dart';
import '../entity/producto_entity.dart';

/// Provider principal para el contexto de dining
final diningProvider =
    StateNotifierProvider<DiningNotifier, DiningContext>((ref) {
  return DiningNotifier();
});

/// Provider para obtener productos filtrados
final filteredProductsProvider =
    Provider.family<List<ProductoEntity>, String>((ref, query) {
  final diningContext = ref.watch(diningProvider);
  if (query.isEmpty) return diningContext.productos;
  return diningContext.buscarProductos(query);
});

/// Provider para obtener productos por categoría
final productsByCategoryProvider =
    Provider.family<List<ProductoEntity>, String>((ref, categoria) {
  final diningContext = ref.watch(diningProvider);
  return diningContext.getProductosPorCategoria(categoria);
});
