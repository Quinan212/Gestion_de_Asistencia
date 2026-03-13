import 'package:drift/drift.dart';

import 'tabla_alumnos.dart';
import 'tabla_cursos.dart';

class TablaInscripciones extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get alumnoId =>
      integer().references(TablaAlumnos, #id, onDelete: KeyAction.cascade)();

  IntColumn get cursoId =>
      integer().references(TablaCursos, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get fechaAlta => dateTime().withDefault(currentDateAndTime)();

  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {alumnoId, cursoId},
  ];
}
