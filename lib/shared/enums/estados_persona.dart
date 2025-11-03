// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';

enum EstadosPersona {
  ACTIVO("ACT", "Activo"),
  BLOQUEADO("BLO", "Bloqueado"),
  SUSPENDIDO("SUS", "Suspendido"),
  PENDIENTE("PEN", "Pendiente"),
  INACTIVO("INA", "Inactivo");

  final String state;
  final String label;
  const EstadosPersona(this.state, this.label);

  /// Obtener lista de todos los estados de persona para dropdown
  static List<EstadosPersona> get all => EstadosPersona.values;
  static List<String> get allStates => all.map((e) => e.state).toList();
  String get getState => state.toUpperCase();
  String get getLabel => label.toUpperCase();
  Color get getColor =>
      state == EstadosPersona.ACTIVO.state ? ThemeApp.success : ThemeApp.error;
  static String getLabelFromState(String state) {
    return all.firstWhere((e) => e.state == state).label;
  }
  static Color getColorFromState(String state) {
    return all.firstWhere((e) => e.state == state).getColor;
  }
}
