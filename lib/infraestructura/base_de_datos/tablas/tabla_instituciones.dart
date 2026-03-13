import 'package:drift/drift.dart';

class TablaInstituciones extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nombre => text().withLength(min: 1, max: 180)();

  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {nombre},
      ];
}
