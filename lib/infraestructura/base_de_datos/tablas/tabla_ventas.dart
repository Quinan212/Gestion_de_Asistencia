// lib/infraestructura/base_de_datos/tablas/tabla_ventas.dart
import 'package:drift/drift.dart';

class TablaVentas extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get fecha => dateTime().withDefault(currentDateAndTime)();

  RealColumn get total => real().withDefault(const Constant(0))();

  TextColumn get nota => text().nullable().withLength(min: 0, max: 200)();
}