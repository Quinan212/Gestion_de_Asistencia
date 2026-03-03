// lib/infraestructura/base_de_datos/tablas/tabla_movimientos.dart
import 'package:drift/drift.dart';
import 'tabla_productos.dart';

class TablaMovimientos extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get productoId =>
      integer().references(TablaProductos, #id, onDelete: KeyAction.cascade)();

  TextColumn get tipo => text().withLength(min: 1, max: 20)();
  // ingreso, egreso, ajuste, devolucion

  RealColumn get cantidad => real()();

  DateTimeColumn get fecha =>
      dateTime().withDefault(currentDateAndTime)();

  TextColumn get nota => text().nullable().withLength(min: 0, max: 200)();

  TextColumn get referencia =>
      text().nullable().withLength(min: 0, max: 40)(); // venta/compra/id opcional
}