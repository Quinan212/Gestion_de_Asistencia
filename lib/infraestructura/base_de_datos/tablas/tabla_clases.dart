import 'package:drift/drift.dart';

import 'tabla_cursos.dart';

class TablaClases extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get cursoId =>
      integer().references(TablaCursos, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get fecha => dateTime().withDefault(currentDateAndTime)();

  TextColumn get tema => text().nullable().withLength(min: 0, max: 200)();

  TextColumn get observacion =>
      text().nullable().withLength(min: 0, max: 250)();

  TextColumn get actividadDia =>
      text().nullable().withLength(min: 0, max: 400)();
}
