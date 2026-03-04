import 'package:drift/drift.dart';

import 'tabla_pedidos.dart';
import 'tabla_combos.dart';
import 'tabla_productos.dart';

class TablaLineasPedido extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get pedidoId =>
      integer().references(TablaPedidos, #id, onDelete: KeyAction.cascade)();

  // Una línea puede ser combo o producto directo
  IntColumn get comboId =>
      integer().nullable().references(TablaCombos, #id, onDelete: KeyAction.restrict)();

  IntColumn get productoId =>
      integer().nullable().references(TablaProductos, #id, onDelete: KeyAction.restrict)();

  // snapshot
  TextColumn get nombre => text()();
  TextColumn get unidad => text()();

  RealColumn get cantidad => real()();
  RealColumn get precioUnitario => real().withDefault(const Constant(0))();
  RealColumn get subtotal => real().withDefault(const Constant(0))();
}