import 'package:drift/drift.dart';
import 'tabla_instituciones.dart';
import 'tabla_carreras.dart';

class TablaAlumnos extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get apellido => text().withLength(min: 1, max: 100)();

  TextColumn get nombre => text().withLength(min: 1, max: 100)();

  IntColumn get edad => integer().nullable()();

  TextColumn get documento => text().nullable().withLength(min: 0, max: 30)();

  TextColumn get email => text().nullable().withLength(min: 0, max: 120)();

  TextColumn get telefono => text().nullable().withLength(min: 0, max: 40)();

  TextColumn get fotoPath => text().nullable().withLength(min: 0, max: 500)();

  IntColumn get institucionId => integer().nullable().references(
    TablaInstituciones,
    #id,
    onDelete: KeyAction.setNull,
  )();

  IntColumn get carreraId => integer().nullable().references(
    TablaCarreras,
    #id,
    onDelete: KeyAction.setNull,
  )();

  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();
}
