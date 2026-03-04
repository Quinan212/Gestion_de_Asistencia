import 'package:drift/drift.dart';

class TablaLineasVenta extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get ventaId => integer()();

  // EXISTENTE: lo dejamos como int requerido para no romper la tabla actual.
  // Para líneas de PRODUCTO vamos a guardar comboId = 0.
  IntColumn get comboId => integer()();

  // NUEVO: si no es null, esta línea representa un PRODUCTO suelto.
  IntColumn get productoId => integer().nullable()();

  RealColumn get cantidad => real()();

  RealColumn get precioUnitario => real()();

  RealColumn get subtotal => real()();

  @override
  Set<Column> get primaryKey => {id};
}