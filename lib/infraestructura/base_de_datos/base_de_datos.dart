import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tablas/tabla_productos.dart';
import 'tablas/tabla_movimientos.dart';
import 'tablas/tabla_combos.dart';
import 'tablas/tabla_componentes.dart';
import 'tablas/tabla_ventas.dart';
import 'tablas/tabla_lineas_venta.dart';
import 'tablas/tabla_compras.dart';
import 'tablas/tabla_lineas_compra.dart';

part 'base_de_datos.g.dart';

@DriftDatabase(
  tables: [
    TablaProductos,
    TablaMovimientos,
    TablaCombos,
    TablaComponentes,
    TablaVentas,
    TablaLineasVenta,
    TablaCompras,
    TablaLineasCompra,
  ],
)
class BaseDeDatos extends _$BaseDeDatos {
  BaseDeDatos() : super(_abrirConexion());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(tablaProductos, tablaProductos.imagen);
      }
    },
  );

  Future<void> cerrar() async => close();
}

LazyDatabase _abrirConexion() {
  return LazyDatabase(() async {
    final carpeta = await getApplicationDocumentsDirectory();
    final archivo = File(p.join(carpeta.path, 'control_de_mercaderia.sqlite'));
    return NativeDatabase(archivo);
  });
}