import 'package:drift/drift.dart';

class TablaLegajosDocumentales extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get tipoRegistro => text().withLength(min: 1, max: 30)();

  TextColumn get categoria => text().withLength(min: 1, max: 30)();

  TextColumn get codigo => text().withLength(min: 1, max: 40)();

  TextColumn get titulo => text().withLength(min: 1, max: 160)();

  TextColumn get detalle => text().withLength(min: 0, max: 600)();

  TextColumn get responsable => text().withLength(min: 1, max: 120)();

  TextColumn get estado => text().withLength(min: 1, max: 60)();

  TextColumn get severidad => text().withLength(min: 1, max: 20)();

  TextColumn get rolDestino => text().withLength(min: 1, max: 40)();

  TextColumn get nivelDestino => text().withLength(min: 1, max: 30)();

  TextColumn get dependenciaDestino => text().withLength(min: 1, max: 30)();

  IntColumn get horasHastaVencimiento => integer().nullable()();

  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get actualizadoEn =>
      dateTime().withDefault(currentDateAndTime)();
}
