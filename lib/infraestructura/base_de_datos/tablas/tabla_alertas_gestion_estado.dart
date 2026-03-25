import 'package:drift/drift.dart';

class TablaAlertasGestionEstado extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get clave => text().withLength(min: 1, max: 180)();

  TextColumn get estado => text().withLength(min: 1, max: 30)();

  DateTimeColumn get pospuestaHasta => dateTime().nullable()();

  TextColumn get derivadaA => text().nullable().withLength(min: 0, max: 120)();

  TextColumn get comentario => text().nullable().withLength(min: 0, max: 300)();

  DateTimeColumn get actualizadoEn =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {clave},
  ];
}
