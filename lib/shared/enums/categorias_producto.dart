// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

enum ProductosCategorias {
  BEBIDA("BEBIDA", "Bebida"),
  PRODUCTO("PRODUCTO", "Producto"),
  COMIDA("COMIDA", "Comida"),
  RAPIDA("RAPIDA", "Comida Rápida"),
  INVENTARIO("INVENTARIO", "Inventario"),
  PORCION("PORCION", "Porcion");

  final String code;
  final String label;
  const ProductosCategorias(this.code, this.label);

  /// Obtener lista de todos los estados de persona para dropdown
  static List<ProductosCategorias> get all => ProductosCategorias.values;
  static List<String> get allCodes => all.map((e) => e.code).toList();
  String get getCode => code.toUpperCase();
  String get getLabel => label.toUpperCase();

  /// Obtener icono asociado a cada categoría
  IconData get getIcon {
    switch (this) {
      case ProductosCategorias.BEBIDA:
        return Icons.wine_bar_rounded;
      case ProductosCategorias.PRODUCTO:
        return Icons.shopping_bag;
      case ProductosCategorias.COMIDA:
        return Icons.restaurant;
      case ProductosCategorias.RAPIDA:
        return Icons.fastfood;
      case ProductosCategorias.INVENTARIO:
        return Icons.inventory;
      case ProductosCategorias.PORCION:
        return Icons.set_meal;
    }
  }

  /// Obtener color asociado a cada categoría
  Color get getColor {
    switch (this) {
      case ProductosCategorias.BEBIDA:
        return Colors.blue; // Azul para bebidas
      case ProductosCategorias.PRODUCTO:
        return Colors.purple; // Morado para productos
      case ProductosCategorias.COMIDA:
        return Colors.orange; // Naranja para comida
      case ProductosCategorias.RAPIDA:
        return Colors.red; // Rojo para comida rápida
      case ProductosCategorias.INVENTARIO:
        return Colors.grey; // Gris para inventario
      case ProductosCategorias.PORCION:
        return Colors.green; // Verde para porciones
    }
  }

  static String getLabelFromCode(String code) {
    return all.firstWhere((e) => e.code == code).label;
  }

  static IconData getIconFromCode(String code) {
    debugPrint('getIconFromCode: $code');
    return all.firstWhere((e) => e.code == code).getIcon;
  }

  static Color getColorFromCode(String code) {
    return all.firstWhere((e) => e.code == code).getColor;
  }
}
