import 'package:drift/drift.dart';

import 'tabla_instituciones.dart';

class TablaCarreras extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get institucionId => integer()
      .references(TablaInstituciones, #id, onDelete: KeyAction.cascade)();

  TextColumn get nombre => text().withLength(min: 1, max: 160)();

  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {institucionId, nombre},
      ];
}
