import 'package:drift/drift.dart';

import 'tabla_alumnos.dart';
import 'tabla_clases.dart';

class TablaAsistencias extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get claseId =>
      integer().references(TablaClases, #id, onDelete: KeyAction.cascade)();

  IntColumn get alumnoId =>
      integer().references(TablaAlumnos, #id, onDelete: KeyAction.cascade)();

  TextColumn get estado => text().withDefault(const Constant('presente'))();

  TextColumn get observacion =>
      text().nullable().withLength(min: 0, max: 250)();

  BoolColumn get justificada => boolean().withDefault(const Constant(false))();

  TextColumn get detalleJustificacion =>
      text().nullable().withLength(min: 0, max: 500)();

  BoolColumn get actividadEntregada =>
      boolean().withDefault(const Constant(false))();

  TextColumn get notaActividad =>
      text().nullable().withLength(min: 0, max: 120)();

  TextColumn get detalleActividad =>
      text().nullable().withLength(min: 0, max: 500)();

  DateTimeColumn get registradoEn =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {claseId, alumnoId},
  ];
}
