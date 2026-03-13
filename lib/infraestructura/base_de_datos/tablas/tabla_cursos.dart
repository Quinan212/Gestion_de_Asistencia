import 'package:drift/drift.dart';
import 'tabla_instituciones.dart';
import 'tabla_carreras.dart';
import 'tabla_materias.dart';

class TablaCursos extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nombre => text().withLength(min: 1, max: 120)();

  TextColumn get division => text().nullable().withLength(min: 0, max: 40)();

  TextColumn get materia => text().nullable().withLength(min: 0, max: 120)();

  TextColumn get turno => text().nullable().withLength(min: 0, max: 40)();

  IntColumn get anio => integer().nullable()();

  IntColumn get institucionId => integer()
      .nullable()
      .references(TablaInstituciones, #id, onDelete: KeyAction.setNull)();

  IntColumn get carreraId => integer()
      .nullable()
      .references(TablaCarreras, #id, onDelete: KeyAction.setNull)();

  IntColumn get materiaId => integer()
      .nullable()
      .references(TablaMaterias, #id, onDelete: KeyAction.setNull)();

  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();
}
