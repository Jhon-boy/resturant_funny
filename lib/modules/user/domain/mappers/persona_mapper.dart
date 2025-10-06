import 'package:flutter/material.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/persona_entity.dart';

class PersonaMapper {
  static PersonaEntity fromFormData({
    required String identificacion,
    required String nombres,
    required String apellidos,
    DateTime? fechaNacimiento,
    String? genero,
    String? correo,
    String? telefono,
    String? direccion,
    String? tipoIdentificacion,
    String? estado,
  }) {
    debugPrint('Genero: $genero');
    return PersonaEntity(
      identificacion: identificacion.trim(),
      nombres: nombres.trim(),
      apellidos: apellidos.trim(),
      fechaNacimiento: fechaNacimiento,
      genero: AppUtils.getGenero(genero!),
      correo: correo?.trim().isNotEmpty == true ? correo!.trim() : null,
      telefono: telefono?.trim().isNotEmpty == true ? telefono!.trim() : null,
      direccion:
          direccion?.trim().isNotEmpty == true ? direccion!.trim() : null,
      tipoIdentificacion: tipoIdentificacion,
      estado: estado,
    );
  }
}
