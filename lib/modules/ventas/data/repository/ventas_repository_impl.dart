import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/services/conection_service.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/ventas/data/datasource/ventas_data_source.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/venta_entity.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/venta_repository.dart';
import 'package:resturant_funny/modules/ventas/domain/models/venta_card_model.dart';
import 'package:resturant_funny/modules/ventas/domain/models/producto_mas_vendido_model.dart';

class VentaRepositoryImpl implements VentaRepository {
  final VentasRemoteDataSource remote;
  final ConnectivityService _connectivity = ConnectivityService();

  VentaRepositoryImpl(this.remote) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, VentaEntity>> createVenta(
      VentaEntity venta, UserModel user) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final created = await remote.createVenta(venta, user);
      return Right(created);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, VentaEntity>> getVentaById(int idVenta) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final venta = await remote.getVentaById(idVenta);
      if (venta == null) {
        return const Left(NotFoundFailure('Venta no encontrada'));
      }
      return Right(venta);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<VentaEntity>>> getVentas({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final ventas = await remote.getAllVentas(
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
      return Right(ventas);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<VentaEntity>>> getVentasBySucursal(
      int idSucursal) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final ventas = await remote.getVentasBySucursal(idSucursal);
      return Right(ventas);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<VentaCardModel>>> getVentasByUsuario(
      String identificacion) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final ventas = await remote.getVentaByCliente(identificacion);
      return Right(ventas);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, VentaEntity>> updateVenta(
      int idVenta, Map<String, dynamic> data) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final updated = await remote.updateVenta(idVenta, data);
      return Right(updated);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, VentaEntity>> toggleEstadoVenta(int idVenta,
      {required String nuevoEstado}) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final venta = await remote.toggleEstadoVenta(idVenta, nuevoEstado);
      return Right(venta);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<VentaEntity>>> getVentasBy(int idEmpleado,
      {DateTime? fechaDesde, DateTime? fechaHasta}) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final ventas = await remote.getVentasBy(
        idEmpleado,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
      return Right(ventas);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<VentaCardModel>>> getVentaCardsBy(
    int idEmpleado, {
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final rows = await remote.getVentasConDetalles(
        idEmpleado,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
      final cards = rows.map<VentaCardModel>((v) {
        final persona = v['TPERSONA'] as Map<String, dynamic>?;
        final nombreCliente = [
          (persona?['NOMBRES'] ?? '').toString(),
          (persona?['APELLIDOS'] ?? '').toString(),
        ].where((e) => e.isNotEmpty).join(' ');
        String? nombreProducto;
        int? cantidad;
        if (v['TDETALLEVENTA'] is List &&
            (v['TDETALLEVENTA'] as List).isNotEmpty) {
          final det =
              (v['TDETALLEVENTA'] as List).first as Map<String, dynamic>;
          final prod = det['TPRODUCTO'] as Map<String, dynamic>?;
          nombreProducto = (prod?['NOMBRE'])?.toString();
          cantidad = (det['CANTIDAD'] as num?)?.toInt();
        }
        return VentaCardModel(
          idVenta: (v['IDVENTA'] as num).toInt(),
          idMesa: (v['IDMESA'] as num).toInt(),
          nombreCliente: nombreCliente,
          identificacionCliente: (v['CLIENTE'])?.toString(),
          nombreProducto: nombreProducto,
          cantidadProducto: cantidad,
          total: (v['TOTAL'] as num?)?.toDouble() ?? 0,
          fecha: v['FECHA'] != null
              ? DateTime.tryParse(v['FECHA'].toString())
              : null,
          estado: v['ESTADO']?.toString(),
        );
      }).toList();
      return Right(cards);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<ProductoMasVendidoModel>>>
      getProductosMasVendidos(
    int idEmpleado, {
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final rows = await remote.getVentasConDetalles(
        idEmpleado,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );

      final Map<int, _ProductoAcumulado> acumulado = {};

      for (final v in rows) {
        final detalles = v['TDETALLEVENTA'];
        if (detalles is! List) continue;

        for (final detRaw in detalles) {
          if (detRaw is! Map) continue;
          final det = Map<String, dynamic>.from(detRaw);

          final idProd = (det['IDPRODUCTO'] as num?)?.toInt();
          if (idProd == null) continue;

          final prod = det['TPRODUCTO'] as Map?;
          final prodMap = prod?.cast<String, dynamic>();
          final nombre = (prodMap?['NOMBRE'] ?? '').toString();

          final cantidad = (det['CANTIDAD'] as num?)?.toInt() ?? 0;
          final subtotal = (det['SUBTOTAL'] as num?)?.toDouble();
          final precioUnit =
              (det['PRECIO_UNITARIO'] as num?)?.toDouble() ?? 0.0;
          final ingreso = subtotal ?? (precioUnit * cantidad);

          final actual = acumulado[idProd];
          if (actual == null) {
            acumulado[idProd] = _ProductoAcumulado(
              idProducto: idProd,
              nombreProducto: nombre,
              cantidadVendida: cantidad,
              ingresosTotales: ingreso,
            );
          } else {
            actual.cantidadVendida += cantidad;
            actual.ingresosTotales += ingreso;
          }
        }
      }

      final lista = acumulado.values
          .map(
            (p) => ProductoMasVendidoModel(
              idProducto: p.idProducto,
              nombreProducto: p.nombreProducto,
              cantidadVendida: p.cantidadVendida,
              ingresosTotales: p.ingresosTotales,
            ),
          )
          .toList();

      lista.sort(
        (a, b) => b.cantidadVendida.compareTo(a.cantidadVendida),
      );

      return Right(lista);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }
}

class _ProductoAcumulado {
  final int idProducto;
  final String nombreProducto;
  int cantidadVendida;
  double ingresosTotales;

  _ProductoAcumulado({
    required this.idProducto,
    required this.nombreProducto,
    required this.cantidadVendida,
    required this.ingresosTotales,
  });
}
