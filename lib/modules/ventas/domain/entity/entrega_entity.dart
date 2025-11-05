import 'package:resturant_funny/core/utils/app_util.dart';

class EntregaEntity {
  final int? idEntrega;
  final int idVenta;
  final String identificacionRepartidor;
  final int idDireccion;
  final DateTime? fechaAsignacion;
  final DateTime? fechaEntrega;
  final String? estado;
  final String? comentario;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioIngreso;
  final String? userModificacion;

  EntregaEntity({
    this.idEntrega,
    required this.idVenta,
    required this.identificacionRepartidor,
    required this.idDireccion,
    this.fechaAsignacion,
    this.fechaEntrega,
    this.estado,
    this.comentario,
    this.fCreacion,
    this.fModificacion,
    this.usuarioIngreso,
    this.userModificacion,
  });

  /// Factory constructor desde JSON de la base de datos
  factory EntregaEntity.fromJson(Map<String, dynamic> json) {
    return EntregaEntity(
      idEntrega: json['IDENTREGA'],
      idVenta: json['IDVENTA'] ?? 0,
      identificacionRepartidor: json['IDENTIFICACION_REPARTIDOR'] ?? '',
      idDireccion: json['IDDIRECCION'] ?? 0,
      fechaAsignacion: json['FECHA_ASIGNACION'] != null
          ? DateTime.parse(json['FECHA_ASIGNACION'])
          : null,
      fechaEntrega: json['FECHA_ENTREGA'] != null
          ? DateTime.parse(json['FECHA_ENTREGA'])
          : null,
      estado: json['ESTADO'],
      comentario: json['COMENTARIO'],
      fCreacion:
          json['FCREACION'] != null ? DateTime.parse(json['FCREACION']) : null,
      fModificacion: json['FMODIFICACION'] != null
          ? DateTime.parse(json['FMODIFICACION'])
          : null,
      usuarioIngreso: json['USUARIOINGRESO'],
      userModificacion: json['USERMODIFICACION'],
    );
  }

  /// Convierte la entidad a JSON para la base de datos
  Map<String, dynamic> toJson() {
    return {
      'IDENTREGA': idEntrega,
      'IDVENTA': idVenta,
      'IDENTIFICACION_REPARTIDOR': identificacionRepartidor,
      'IDDIRECCION': idDireccion,
      'FECHA_ASIGNACION': fechaAsignacion?.toIso8601String(),
      'FECHA_ENTREGA': fechaEntrega?.toIso8601String(),
      'ESTADO': estado,
      'COMENTARIO': comentario,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOINGRESO': usuarioIngreso,
      'USERMODIFICACION': userModificacion,
    };
  }

  /// Convierte la entidad a JSON para la UI (nombres en camelCase)
  Map<String, dynamic> toJsonForUI() {
    return {
      'idEntrega': idEntrega,
      'idVenta': idVenta,
      'identificacionRepartidor': identificacionRepartidor,
      'idDireccion': idDireccion,
      'fechaAsignacion': fechaAsignacion?.toIso8601String(),
      'fechaEntrega': fechaEntrega?.toIso8601String(),
      'estado': estado,
      'comentario': comentario,
      'fCreacion': fCreacion?.toIso8601String(),
      'fModificacion': fModificacion?.toIso8601String(),
      'usuarioIngreso': usuarioIngreso,
      'userModificacion': userModificacion,
    };
  }

  /// Crea una copia de la entidad con algunos campos modificados
  EntregaEntity copyWith({
    int? idEntrega,
    int? idVenta,
    String? identificacionRepartidor,
    int? idDireccion,
    DateTime? fechaAsignacion,
    DateTime? fechaEntrega,
    String? estado,
    String? comentario,
    DateTime? fCreacion,
    DateTime? fModificacion,
    String? usuarioIngreso,
    String? userModificacion,
  }) {
    return EntregaEntity(
      idEntrega: idEntrega ?? this.idEntrega,
      idVenta: idVenta ?? this.idVenta,
      identificacionRepartidor:
          identificacionRepartidor ?? this.identificacionRepartidor,
      idDireccion: idDireccion ?? this.idDireccion,
      fechaAsignacion: fechaAsignacion ?? this.fechaAsignacion,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      estado: estado ?? this.estado,
      comentario: comentario ?? this.comentario,
      fCreacion: fCreacion ?? this.fCreacion,
      fModificacion: fModificacion ?? this.fModificacion,
      usuarioIngreso: usuarioIngreso ?? this.usuarioIngreso,
      userModificacion: userModificacion ?? this.userModificacion,
    );
  }

  /// Verifica si la entrega está pendiente
  bool get isPendiente => estado?.toUpperCase() == 'PENDIENTE';

  /// Verifica si la entrega está asignada
  bool get isAsignada => estado?.toUpperCase() == 'ASIGNADA';

  /// Verifica si la entrega está en camino
  bool get isEnCamino => estado?.toUpperCase() == 'EN_CAMINO';

  /// Verifica si la entrega está entregada
  bool get isEntregada => estado?.toUpperCase() == 'ENTREGADA';

  /// Verifica si la entrega está cancelada
  bool get isCancelada => estado?.toUpperCase() == 'CANCELADA';

  /// Verifica si la entrega está retrasada
  bool get isRetrasada => estado?.toUpperCase() == 'RETRASADA';

  /// Verifica si tiene fecha de asignación
  bool get tieneFechaAsignacion => fechaAsignacion != null;

  /// Verifica si tiene fecha de entrega
  bool get tieneFechaEntrega => fechaEntrega != null;

  /// Obtiene la fecha de asignación formateada
  String get fechaAsignacionFormateada {
    if (fechaAsignacion == null) return 'Sin asignar';
    return '${fechaAsignacion!.day.toString().padLeft(2, '0')}/${fechaAsignacion!.month.toString().padLeft(2, '0')}/${fechaAsignacion!.year}';
  }

  /// Obtiene la fecha de entrega formateada
  String get fechaEntregaFormateada {
    if (fechaEntrega == null) return 'Sin entregar';
    return '${fechaEntrega!.day.toString().padLeft(2, '0')}/${fechaEntrega!.month.toString().padLeft(2, '0')}/${fechaEntrega!.year}';
  }

  /// Obtiene el estado con formato
  String get estadoFormateado {
    if (estado == null) return 'Sin estado';
    return estado!.toUpperCase().replaceAll('_', ' ');
  }

  /// Obtiene el color del estado para la UI
  String get colorEstado {
    switch (estado?.toUpperCase()) {
      case 'PENDIENTE':
        return 'amarillo';
      case 'ASIGNADA':
        return 'azul';
      case 'EN_CAMINO':
        return 'naranja';
      case 'ENTREGADA':
        return 'verde';
      case 'CANCELADA':
        return 'rojo';
      case 'RETRASADA':
        return 'rojo';
      default:
        return 'gris';
    }
  }

  /// Obtiene el icono del estado para la UI
  String get iconoEstado {
    switch (estado?.toUpperCase()) {
      case 'PENDIENTE':
        return 'schedule';
      case 'ASIGNADA':
        return 'assignment';
      case 'EN_CAMINO':
        return 'local_shipping';
      case 'ENTREGADA':
        return 'check_circle';
      case 'CANCELADA':
        return 'cancel';
      case 'RETRASADA':
        return 'warning';
      default:
        return 'help';
    }
  }

  /// Calcula el tiempo transcurrido desde la asignación
  Duration? get tiempoTranscurrido {
    if (fechaAsignacion == null) return null;
    final ahora = AppUtils.getFechaActual();
    return ahora.difference(fechaAsignacion!);
  }

  /// Obtiene el tiempo transcurrido formateado
  String get tiempoTranscurridoFormateado {
    final tiempo = tiempoTranscurrido;
    if (tiempo == null) return 'Sin asignar';

    if (tiempo.inDays > 0) {
      return '${tiempo.inDays} días';
    } else if (tiempo.inHours > 0) {
      return '${tiempo.inHours} horas';
    } else if (tiempo.inMinutes > 0) {
      return '${tiempo.inMinutes} minutos';
    } else {
      return 'Recién asignada';
    }
  }

  /// Verifica si la entrega está retrasada (más de 2 horas)
  bool get estaRetrasada {
    final tiempo = tiempoTranscurrido;
    if (tiempo == null) return false;
    return tiempo.inHours > 2 && !isEntregada;
  }

  @override
  String toString() {
    return 'EntregaEntity(idEntrega: $idEntrega, idVenta: $idVenta, estado: $estado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EntregaEntity &&
        other.idEntrega == idEntrega &&
        other.idVenta == idVenta &&
        other.identificacionRepartidor == identificacionRepartidor &&
        other.estado == estado;
  }

  @override
  int get hashCode {
    return Object.hash(
      idEntrega,
      idVenta,
      identificacionRepartidor,
      estado,
    );
  }
}
