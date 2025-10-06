class PersonaEntity {
  final String identificacion;
  final String nombres;
  final String apellidos;
  final DateTime? fechaNacimiento;
  final String? genero;
  final String? correo;
  final String? telefono;
  final String? direccion;
  final String? tipoIdentificacion;
  final String? estado;
  

  PersonaEntity({
    required this.identificacion,
    required this.nombres,
    required this.apellidos,
    this.fechaNacimiento,
    this.genero,
    this.correo,
    this.telefono,
    this.direccion,
    this.tipoIdentificacion,
    this.estado,
  });

  // Método de deserialización
  factory PersonaEntity.fromJson(Map<String, dynamic> json) {
    return PersonaEntity(
      identificacion: json['IDENTIFICACION'] ?? '',
      nombres: json['NOMBRES'] ?? '',
      apellidos: json['APELLIDOS'] ?? '',
      fechaNacimiento: json['FNACIMIENTO'] != null
          ? DateTime.parse(json['FNACIMIENTO'])
          : null,
      genero: json['GENERO'],
      correo: json['CORREO'],
      telefono: json['TELEFONO'],
      direccion: json['DIRECCION'],
      tipoIdentificacion: json['TIPOIDENTIFICACION'],
      estado: json['ESTADO'],
    );
  }

  // Método de serialización
  Map<String, dynamic> toJson() {
    return {
      'IDENTIFICACION': identificacion,
      'NOMBRES': nombres,
      'APELLIDOS': apellidos,
      'FNACIMIENTO': fechaNacimiento?.toIso8601String(),
      'GENERO': genero,
      'CORREO': correo,
      'TELEFONO': telefono,
      'DIRECCION': direccion,
      'TIPOIDENTIFICACION': tipoIdentificacion,
      'ESTADO': estado,
    };
  }
}
