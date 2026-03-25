import 'package:drift/drift.dart';

class TablaIncidenciasTransversalesHistorial extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get origen => text().withLength(min: 1, max: 40)();

  TextColumn get referencia => text().withLength(min: 1, max: 180)();

  TextColumn get accion => text().withLength(min: 1, max: 40)();

  TextColumn get estadoOperativo =>
      text().nullable().withLength(min: 0, max: 80)();

  TextColumn get estadoDocumental =>
      text().nullable().withLength(min: 0, max: 80)();

  TextColumn get detalle => text().nullable().withLength(min: 0, max: 500)();

  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();
}
