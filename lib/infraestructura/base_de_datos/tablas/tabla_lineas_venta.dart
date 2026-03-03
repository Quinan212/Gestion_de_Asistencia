// lib/infraestructura/base_de_datos/tablas/tabla_lineas_venta.dart
import 'package:drift/drift.dart';
import 'tabla_ventas.dart';
import 'tabla_combos.dart';

class TablaLineasVenta extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get ventaId =>
      integer().references(TablaVentas, #id, onDelete: KeyAction.cascade)();

  IntColumn get comboId =>
      integer().references(TablaCombos, #id, onDelete: KeyAction.restrict)();

  RealColumn get cantidad => real()();

  RealColumn get precioUnitario => real().withDefault(const Constant(0))();

  RealColumn get subtotal => real().withDefault(const Constant(0))();
}