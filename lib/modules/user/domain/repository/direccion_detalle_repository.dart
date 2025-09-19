import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/user/domain/entity/direccion_cliente_entity.dart';

abstract class DireccionClienteRepository {
  /// Obtener todas las direcciones de clientes
  Future<Either<Failure, List<DireccionClienteEntity>>> getAllDirecciones();

  /// Obtener dirección por ID
  Future<Either<Failure, DireccionClienteEntity>> getDireccionById(
      int idDireccion);

  /// Obtener direcciones de un cliente por su identificación
  Future<Either<Failure, List<DireccionClienteEntity>>> getDireccionesByCliente(
      String identificacion);

  /// Crear nueva dirección
  Future<Either<Failure, DireccionClienteEntity>> createDireccion(
      DireccionClienteEntity direccion, UserModel user);

  /// Actualizar dirección (sin tocar ID ni IDENTIFICACION)
  Future<Either<Failure, DireccionClienteEntity>> updateDireccion(
      int idDireccion, Map<String, dynamic> data);

  /// Activar/Desactivar dirección
  Future<Either<Failure, DireccionClienteEntity>> toggleEstadoDireccion(
      int idDireccion,
      {bool activo = true});

  /// Eliminar dirección
  Future<Either<Failure, bool>> deleteDireccion(int idDireccion);
}
