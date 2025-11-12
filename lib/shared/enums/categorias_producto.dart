// ignore_for_file: constant_identifier_names

enum ProductosCategorias {
  BEBIDA("BEBIDA", "Bebida"),
  PRODUCTO("PRODUCTO", "Producto"),
  COMIDA("COMIDA", "Comida"),
  RAPIDA("RAPIDA", "Comida Rápida"),
  PORCION("PORCION", "Porcion");

  final String code;
  final String label;
  const ProductosCategorias(this.code, this.label);

  /// Obtener lista de todos los estados de persona para dropdown
  static List<ProductosCategorias> get all => ProductosCategorias.values;
  static List<String> get allCodes => all.map((e) => e.code).toList();
  String get getCode => code.toUpperCase();
  String get getLabel => label.toUpperCase();

  static String getLabelFromCode(String code) {
    return all.firstWhere((e) => e.code == code).label;
  }
}
