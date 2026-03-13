import 'package:drift/drift.dart';

import 'tabla_alumnos.dart';

class TablaNotasManuales extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get alumnoId =>
      integer().references(TablaAlumnos, #id, onDelete: KeyAction.cascade)();

  IntColumn get cursoId => integer().nullable()();

  TextColumn get claveContexto => text().withLength(min: 1, max: 60)();

  TextColumn get nota => text().withLength(min: 0, max: 120)();

  DateTimeColumn get actualizadoEn =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {alumnoId, claveContexto},
  ];
}
