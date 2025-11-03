import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/persona_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';

abstract class PersonasRepository {
  /// Obtener todas las personas
  Future<Either<Failure, List<PersonaEntity>>> getAllPersonas({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    bool includeDeletes = false,
  });

  /// Obtener persona por identificación
  Future<Either<Failure, PersonaEntity>> getPersonaByIdentificacion(
      String identificacion);

  /// Crear una nueva persona
  Future<Either<Failure, PersonaEntity>> createPersona(
    PersonaEntity persona,
    UserModel user,
  );

  /// Actualizar datos de persona (excepto la identificación)
  Future<Either<Failure, PersonaEntity>> updatePersona(
    String identificacion,
    Map<String, dynamic> data,
  );

  /// Eliminar persona (lógicamente: estado INACTIVO)
  Future<Either<Failure, bool>> deletePersona(
    String identificacion,
    UserModel user,
  );

  /// Buscar personas con filtros opcionales
  Future<Either<Failure, List<PersonaEntity>>> searchPersonas({
    String? nombres,
    String? apellidos,
    String? correo,
    String? telefono,
    bool? activo,
  });

  /// Cambiar estado de una persona (ACTIVO/INACTIVO)
  Future<Either<Failure, PersonaEntity>> toggleEstadoPersona(
    String identificacion, {
    bool activo = true,
  });
}
