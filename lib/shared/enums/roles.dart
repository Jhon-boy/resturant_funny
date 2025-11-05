// ignore_for_file: constant_identifier_names

enum Rol {
  ADMIN(1,"ADM", "ADMIN"),
  EMPLEADO(2,"EPG", "EMPLEADO GENERAL"),
  EMPLEADO_COCINA(3, "EPC", "EMPLEADO DE COCINA"),
  CLIENTE(4, "CLT", "CLIENTE");

  final int id;
  final String code;
  final String label;
  const Rol(this.id, this.code, this.label);

  static List<Rol> get all => Rol.values;
  static List<String> get allCodes => all.map((e) => e.code).toList();
  String get getCode => code.toUpperCase();
  String get getLabel => label.toUpperCase();

  static String getLabelFromCode(String code) {
    return all.firstWhere((e) => e.code == code).label;
  }
  static String getCodeFromId(int id) {
    return all.firstWhere((e) => e.id == id).code;
  }

}