import 'package:drift/drift.dart';

class TablaAlertasGestionHistorial extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get clave => text().withLength(min: 1, max: 180)();

  TextColumn get accion => text().withLength(min: 1, max: 40)();

  TextColumn get estadoAnterior => text().nullable().withLength(min: 0, max: 30)();

  TextColumn get estadoNuevo => text().withLength(min: 1, max: 30)();

  TextColumn get derivadaA => text().nullable().withLength(min: 0, max: 120)();

  TextColumn get comentario => text().nullable().withLength(min: 0, max: 300)();

  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();
}
