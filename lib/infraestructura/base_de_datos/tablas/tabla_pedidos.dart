import 'package:drift/drift.dart';

import 'tabla_ventas.dart';

class TablaPedidos extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get fecha => dateTime().withDefault(currentDateAndTime)();

  TextColumn get cliente => text().nullable()();
  TextColumn get nota => text().nullable()();

  RealColumn get envioMonto => real().withDefault(const Constant(0))();

  // "Efectivo" | "Tarjeta" | "Transferencia"
  TextColumn get medioPago => text().withDefault(const Constant('Efectivo'))();

  // "pendiente" | "pagado" | "parcial"
  TextColumn get estadoPago => text().withDefault(const Constant('pendiente'))();

  // "borrador" | "encargado" | "preparado" | "entregado" | "cancelado"
  TextColumn get estado => text().withDefault(const Constant('borrador'))();

  RealColumn get subtotal => real().withDefault(const Constant(0))();
  RealColumn get total => real().withDefault(const Constant(0))();
  BoolColumn get stockDescontado => boolean().withDefault(const Constant(false))();

  IntColumn get ventaId => integer().nullable().references(TablaVentas, #id)();
}