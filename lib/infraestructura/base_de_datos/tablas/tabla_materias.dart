import 'package:drift/drift.dart';

import 'tabla_carreras.dart';

class TablaMaterias extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get carreraId =>
      integer().references(TablaCarreras, #id, onDelete: KeyAction.cascade)();

  TextColumn get nombre => text().withLength(min: 1, max: 140)();

  IntColumn get anioCursada => integer()();

  TextColumn get curso => text().withLength(min: 1, max: 4)();

  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {carreraId, nombre, anioCursada, curso},
      ];
}
