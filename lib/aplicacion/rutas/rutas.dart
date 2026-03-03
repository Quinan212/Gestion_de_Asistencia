// lib/aplicacion/rutas/rutas.dart
import 'package:flutter/material.dart';
import 'pantallas_principales.dart';

class Rutas {
  static const inicio = '/';
}

Map<String, WidgetBuilder> rutasAplicacion() {
  return {
    Rutas.inicio: (_) => const PantallasPrincipales(),
  };
}