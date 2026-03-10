// lib/infraestructura/dep_inyeccion/proveedores.dart
import 'package:flutter/foundation.dart';

import '/infraestructura/base_de_datos/base_de_datos.dart';

import '/modulos/inventario/datos/inventario_repositorio.dart';
import '/modulos/combos/datos/combos_repositorio.dart';
import '/modulos/ventas/datos/ventas_repositorio.dart';
import '/modulos/compras/datos/compras_repositorio.dart';

// NUEVO
import '/modulos/pedidos/datos/pedidos_repositorio.dart';

class Proveedores {
  Proveedores._();

  static BaseDeDatos? _baseDeDatos;
  static ComprasRepositorio? _comprasRepositorio;
  static InventarioRepositorio? _inventarioRepositorio;
  static VentasRepositorio? _ventasRepositorio;
  static CombosRepositorio? _combosRepositorio;
  static PedidosRepositorio? _pedidosRepositorio;
  static final ValueNotifier<int> datosVersion = ValueNotifier<int>(0);
  static final ValueNotifier<String?> estadoSincronizacion = ValueNotifier(
    null,
  );

  static BaseDeDatos get baseDeDatos => _baseDeDatos ??= BaseDeDatos();

  static ComprasRepositorio get comprasRepositorio =>
      _comprasRepositorio ??= ComprasRepositorio(baseDeDatos);

  static InventarioRepositorio get inventarioRepositorio =>
      _inventarioRepositorio ??= InventarioRepositorio(baseDeDatos);

  static VentasRepositorio get ventasRepositorio =>
      _ventasRepositorio ??= VentasRepositorio(baseDeDatos);

  static CombosRepositorio get combosRepositorio =>
      _combosRepositorio ??= CombosRepositorio(baseDeDatos);

  // NUEVO
  static PedidosRepositorio get pedidosRepositorio =>
      _pedidosRepositorio ??= PedidosRepositorio(baseDeDatos);

  static Future<void> cerrarDependencias() async {
    final bd = _baseDeDatos;
    if (bd != null) {
      await bd.cerrar();
    }
    _limpiarCaches();
  }

  static Future<void> recrearDependencias() async {
    await cerrarDependencias();
    _baseDeDatos = BaseDeDatos();
    notificarDatosActualizados(mensaje: 'Datos restaurados y sincronizados.');
  }

  static void notificarDatosActualizados({String? mensaje}) {
    datosVersion.value = datosVersion.value + 1;
    final t = (mensaje ?? '').trim();
    if (t.isNotEmpty) {
      estadoSincronizacion.value = t;
    }
  }

  static void limpiarEstadoSincronizacion() {
    estadoSincronizacion.value = null;
  }

  static void _limpiarCaches() {
    _baseDeDatos = null;
    _comprasRepositorio = null;
    _inventarioRepositorio = null;
    _ventasRepositorio = null;
    _combosRepositorio = null;
    _pedidosRepositorio = null;
  }
}
