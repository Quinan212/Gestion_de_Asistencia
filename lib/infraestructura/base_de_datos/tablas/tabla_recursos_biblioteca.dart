import 'package:drift/drift.dart';

class TablaRecursosBiblioteca extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get tipoRecurso => text().withLength(min: 1, max: 40)();

  TextColumn get categoria => text().withLength(min: 1, max: 30)();

  TextColumn get codigo => text().withLength(min: 1, max: 40)();

  TextColumn get titulo => text().withLength(min: 1, max: 180)();

  TextColumn get autorReferencia =>
      text().withLength(min: 0, max: 160).nullable()();

  TextColumn get estado => text().withLength(min: 1, max: 40)();

  TextColumn get responsable => text().withLength(min: 1, max: 120)();

  TextColumn get destinatario =>
      text().withLength(min: 0, max: 120).nullable()();

  TextColumn get cursoReferencia =>
      text().withLength(min: 0, max: 120).nullable()();

  IntColumn get cantidadTotal => integer().withDefault(const Constant(1))();

  IntColumn get cantidadDisponible =>
      integer().withDefault(const Constant(1))();

  DateTimeColumn get fechaVencimiento => dateTime().nullable()();

  TextColumn get observaciones => text().withLength(min: 0, max: 800)();

  TextColumn get rolDestino => text().withLength(min: 1, max: 40)();

  TextColumn get nivelDestino => text().withLength(min: 1, max: 30)();

  TextColumn get dependenciaDestino => text().withLength(min: 1, max: 30)();

  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get actualizadoEn =>
      dateTime().withDefault(currentDateAndTime)();
}
