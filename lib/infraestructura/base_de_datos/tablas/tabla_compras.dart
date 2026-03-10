// lib/infraestructura/base_de_datos/tablas/tabla_compras.dart
import 'package:drift/drift.dart';

class TablaCompras extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get fecha => dateTime().withDefault(currentDateAndTime)();

  TextColumn get proveedor =>
      text().nullable().withLength(min: 0, max: 120)();

  RealColumn get envioMonto => real().withDefault(const Constant(0))();

  RealColumn get total => real().withDefault(const Constant(0))();

  TextColumn get nota => text().nullable().withLength(min: 0, max: 200)();
}