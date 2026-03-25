import 'package:drift/drift.dart';

class TablaResponsablesGestion extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nombre => text().withLength(min: 1, max: 120)();

  TextColumn get area => text().withLength(min: 1, max: 120)();

  TextColumn get rolDestino => text().withLength(min: 1, max: 40)();

  TextColumn get nivelDestino => text().withLength(min: 1, max: 30)();

  TextColumn get dependenciaDestino => text().withLength(min: 1, max: 30)();

  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();
}
