import 'package:resturant_funny/modules/authentication/domain/entity/persona_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/usuario_entity.dart';

class EmpleadoModel {
  final TUsuariEntity? usuario;
  final PersonaEntity persona;
  final List<int> roles;

  EmpleadoModel({
    this.usuario,
    required this.persona,
    required this.roles,
  });
}
