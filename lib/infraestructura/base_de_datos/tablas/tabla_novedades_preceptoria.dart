import 'package:drift/drift.dart';

class TablaNovedadesPreceptoria extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get tipoNovedad => text().withLength(min: 1, max: 40)();

  TextColumn get categoria => text().withLength(min: 1, max: 30)();

  TextColumn get cursoReferencia =>
      text().withLength(min: 0, max: 120).nullable()();

  TextColumn get alumnoReferencia =>
      text().withLength(min: 0, max: 120).nullable()();

  TextColumn get estado => text().withLength(min: 1, max: 40)();

  TextColumn get prioridad => text().withLength(min: 1, max: 20)();

  TextColumn get responsable => text().withLength(min: 1, max: 120)();

  TextColumn get observaciones => text().withLength(min: 0, max: 800)();

  DateTimeColumn get fechaSeguimiento => dateTime().nullable()();

  TextColumn get rolDestino => text().withLength(min: 1, max: 40)();

  TextColumn get nivelDestino => text().withLength(min: 1, max: 30)();

  TextColumn get dependenciaDestino => text().withLength(min: 1, max: 30)();

  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get actualizadoEn =>
      dateTime().withDefault(currentDateAndTime)();
}
