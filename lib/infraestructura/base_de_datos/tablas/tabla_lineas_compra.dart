// lib/infraestructura/base_de_datos/tablas/tabla_lineas_compra.dart
import 'package:drift/drift.dart';
import 'tabla_compras.dart';
import 'tabla_productos.dart';

class TablaLineasCompra extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get compraId =>
      integer().references(TablaCompras, #id, onDelete: KeyAction.cascade)();

  IntColumn get productoId =>
      integer().references(TablaProductos, #id, onDelete: KeyAction.restrict)();

  RealColumn get cantidad => real()();

  RealColumn get costoUnitario => real().withDefault(const Constant(0))();

  RealColumn get subtotal => real().withDefault(const Constant(0))();
}