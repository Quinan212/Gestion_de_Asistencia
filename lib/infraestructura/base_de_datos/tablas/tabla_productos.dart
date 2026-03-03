import 'package:drift/drift.dart';

class TablaProductos extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nombre => text().withLength(min: 1, max: 120)();

  TextColumn get unidad => text().withLength(min: 1, max: 30)();

  RealColumn get costoActual => real().withDefault(const Constant(0))();

  RealColumn get precioSugerido => real().withDefault(const Constant(0))();

  RealColumn get stockMinimo => real().withDefault(const Constant(0))();

  TextColumn get proveedor => text().nullable().withLength(min: 0, max: 120)();

  // NUEVO: ruta local a la foto (archivo guardado por la app)
  TextColumn get imagen => text().nullable()();

  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();
}