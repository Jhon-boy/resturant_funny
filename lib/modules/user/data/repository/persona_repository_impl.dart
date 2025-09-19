import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/services/conection_service.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/persona_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/user/data/datasource/persona_data_source.dart';
import 'package:resturant_funny/modules/user/domain/repository/persona_repository.dart';

class PersonaRepositoryImpl implements PersonasRepository {
  final PersonasRemoteDataSource remote;
  final ConnectivityService _connectivity = ConnectivityService();

  PersonaRepositoryImpl(this.remote) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, PersonaEntity>> createPersona(
      PersonaEntity persona, UserModel user) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final personaCreated = await remote.createPersona(persona, user);
      return Right(personaCreated);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, bool>> deletePersona(
      String identificacion, UserModel user) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final result = await remote.deletePersona(identificacion, user);
      return Right(result);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<PersonaEntity>>> getAllPersonas({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final personas = await remote.getPersonas(
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
      return Right(personas);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, PersonaEntity>> getPersonaByIdentificacion(
      String identificacion) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final persona = await remote.getPersonaById(identificacion);
      if (persona == null) {
        return const Left(ServerFailure('Persona no encontrada'));
      }
      return Right(persona);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<PersonaEntity>>> searchPersonas({
    String? nombres,
    String? apellidos,
    String? correo,
    String? telefono,
    bool? activo,
  }) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final personas = await remote.searchPersonas(
        nombres: nombres,
        apellidos: apellidos,
        correo: correo,
        telefono: telefono,
        activo: activo,
      );
      return Right(personas);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, PersonaEntity>> toggleEstadoPersona(
      String identificacion,
      {bool activo = true}) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final persona = await remote.toggleEstadoPersona(identificacion, activo);
      return Right(persona);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, PersonaEntity>> updatePersona(
      String identificacion, Map<String, dynamic> data) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final persona = await remote.updatePersonaById(identificacion, data);
      return Right(persona);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }
}
