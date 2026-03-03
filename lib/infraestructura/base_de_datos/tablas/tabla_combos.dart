// lib/infraestructura/base_de_datos/tablas/tabla_combos.dart
import 'package:drift/drift.dart';

class TablaCombos extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nombre => text().withLength(min: 1, max: 120)();

  RealColumn get precioVenta => real().withDefault(const Constant(0))();

  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();
}