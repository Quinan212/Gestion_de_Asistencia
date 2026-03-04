// lib/infraestructura/dep_inyeccion/proveedores.dart
import '/infraestructura/base_de_datos/base_de_datos.dart';

import '/modulos/inventario/datos/inventario_repositorio.dart';
import '/modulos/combos/datos/combos_repositorio.dart';
import '/modulos/ventas/datos/ventas_repositorio.dart';
import '/modulos/compras/datos/compras_repositorio.dart';

// NUEVO
import '/modulos/pedidos/datos/pedidos_repositorio.dart';

class Proveedores {
  Proveedores._();

  static final BaseDeDatos baseDeDatos = BaseDeDatos();

  static final ComprasRepositorio comprasRepositorio =
  ComprasRepositorio(baseDeDatos);

  static final InventarioRepositorio inventarioRepositorio =
  InventarioRepositorio(baseDeDatos);

  static final VentasRepositorio ventasRepositorio =
  VentasRepositorio(baseDeDatos);

  static final CombosRepositorio combosRepositorio =
  CombosRepositorio(baseDeDatos);

  // NUEVO
  static final PedidosRepositorio pedidosRepositorio =
  PedidosRepositorio(baseDeDatos);
}
