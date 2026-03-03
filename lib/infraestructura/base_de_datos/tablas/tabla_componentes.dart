// lib/infraestructura/base_de_datos/tablas/tabla_componentes.dart
import 'package:drift/drift.dart';
import 'tabla_combos.dart';
import 'tabla_productos.dart';

class TablaComponentes extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get comboId =>
      integer().references(TablaCombos, #id, onDelete: KeyAction.cascade)();

  IntColumn get productoId => integer()
      .references(TablaProductos, #id, onDelete: KeyAction.restrict)();

  RealColumn get cantidad => real()();
}