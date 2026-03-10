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

import 'tablas/tabla_pedidos.dart';
import 'tablas/tabla_lineas_pedido.dart';

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
    TablaPedidos,
    TablaLineasPedido,
  ],
)
class BaseDeDatos extends _$BaseDeDatos {
  BaseDeDatos() : super(_abrirConexion());

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(tablaProductos, tablaProductos.imagen);
      }
      if (from < 3) {
        await m.createTable(tablaPedidos);
        await m.createTable(tablaLineasPedido);
      }
      if (from < 4) {
        final yaExiste = await _existeColumna(
          'tabla_lineas_venta',
          'producto_id',
        );
        if (!yaExiste) {
          await m.addColumn(
            tablaLineasVenta,
            tablaLineasVenta.productoId as GeneratedColumn<Object>,
          );
        }
      }
      if (from < 5) {
        final yaExiste = await _existeColumna(
          'tabla_pedidos',
          'stock_descontado',
        );
        if (!yaExiste) {
          await m.addColumn(tablaPedidos, tablaPedidos.stockDescontado);
        }
      }
      if (from < 6) {
        final yaExiste = await _existeColumna('tabla_compras', 'envio_monto');
        if (!yaExiste) {
          await m.addColumn(
            tablaCompras,
            tablaCompras.envioMonto as GeneratedColumn<Object>,
          );
        }
      }
      if (from < 7) {
        final existeVariante = await _existeColumna(
          'tabla_productos',
          'variante',
        );
        if (!existeVariante) {
          await m.addColumn(tablaProductos, tablaProductos.variante);
        }
        final existeSubvariante = await _existeColumna(
          'tabla_productos',
          'subvariante',
        );
        if (!existeSubvariante) {
          await m.addColumn(tablaProductos, tablaProductos.subvariante);
        }
      }
      if (from < 8) {
        final existeSku = await _existeColumna('tabla_productos', 'sku');
        if (!existeSku) {
          await m.addColumn(tablaProductos, tablaProductos.sku);
        }
        final existePadre = await _existeColumna(
          'tabla_productos',
          'producto_padre_id',
        );
        if (!existePadre) {
          await m.addColumn(tablaProductos, tablaProductos.productoPadreId);
        }
      }
    },
    beforeOpen: (details) async {
      await _aplicarCompatibilidadLegacy();
    },
  );
  Future<void> cerrar() async => close();

  Future<void> _aplicarCompatibilidadLegacy() async {
    // Backups viejos pueden venir sin estas tablas/columnas aunque el resto exista.
    if (!await _existeTabla('tabla_pedidos')) {
      await customStatement('''
        CREATE TABLE IF NOT EXISTS tabla_pedidos (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          fecha INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
          cliente TEXT NULL,
          nota TEXT NULL,
          envio_monto REAL NOT NULL DEFAULT 0.0,
          medio_pago TEXT NOT NULL DEFAULT 'Efectivo',
          estado_pago TEXT NOT NULL DEFAULT 'pendiente',
          estado TEXT NOT NULL DEFAULT 'borrador',
          subtotal REAL NOT NULL DEFAULT 0.0,
          total REAL NOT NULL DEFAULT 0.0,
          stock_descontado INTEGER NOT NULL DEFAULT 0,
          venta_id INTEGER NULL REFERENCES tabla_ventas (id)
        );
        ''');
    }

    if (!await _existeTabla('tabla_lineas_pedido')) {
      await customStatement('''
        CREATE TABLE IF NOT EXISTS tabla_lineas_pedido (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          pedido_id INTEGER NOT NULL REFERENCES tabla_pedidos (id) ON DELETE CASCADE,
          combo_id INTEGER NULL REFERENCES tabla_combos (id) ON DELETE RESTRICT,
          producto_id INTEGER NULL REFERENCES tabla_productos (id) ON DELETE RESTRICT,
          nombre TEXT NOT NULL,
          unidad TEXT NOT NULL,
          cantidad REAL NOT NULL,
          precio_unitario REAL NOT NULL DEFAULT 0.0,
          subtotal REAL NOT NULL DEFAULT 0.0
        );
        ''');
    }

    if (!await _existeTabla('tabla_compras')) {
      await customStatement('''
        CREATE TABLE IF NOT EXISTS tabla_compras (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          fecha INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
          proveedor TEXT NULL,
          envio_monto REAL NOT NULL DEFAULT 0.0,
          total REAL NOT NULL DEFAULT 0.0,
          nota TEXT NULL
        );
        ''');
    }

    if (!await _existeTabla('tabla_lineas_compra')) {
      await customStatement('''
        CREATE TABLE IF NOT EXISTS tabla_lineas_compra (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          compra_id INTEGER NOT NULL REFERENCES tabla_compras (id) ON DELETE CASCADE,
          producto_id INTEGER NOT NULL REFERENCES tabla_productos (id) ON DELETE RESTRICT,
          cantidad REAL NOT NULL,
          costo_unitario REAL NOT NULL DEFAULT 0.0,
          subtotal REAL NOT NULL DEFAULT 0.0
        );
        ''');
    }

    if (!await _existeColumna('tabla_pedidos', 'stock_descontado')) {
      await customStatement(
        'ALTER TABLE tabla_pedidos ADD COLUMN stock_descontado INTEGER NOT NULL DEFAULT 0',
      );
    }

    if (!await _existeColumna('tabla_lineas_venta', 'producto_id')) {
      await customStatement(
        'ALTER TABLE tabla_lineas_venta ADD COLUMN producto_id INTEGER NULL',
      );
    }

    if (!await _existeColumna('tabla_compras', 'envio_monto')) {
      await customStatement(
        'ALTER TABLE tabla_compras ADD COLUMN envio_monto REAL NOT NULL DEFAULT 0.0',
      );
    }

    if (!await _existeColumna('tabla_productos', 'imagen')) {
      await customStatement(
        'ALTER TABLE tabla_productos ADD COLUMN imagen TEXT NULL',
      );
    }

    if (!await _existeColumna('tabla_productos', 'variante')) {
      await customStatement(
        'ALTER TABLE tabla_productos ADD COLUMN variante TEXT NULL',
      );
    }

    if (!await _existeColumna('tabla_productos', 'subvariante')) {
      await customStatement(
        'ALTER TABLE tabla_productos ADD COLUMN subvariante TEXT NULL',
      );
    }

    if (!await _existeColumna('tabla_productos', 'sku')) {
      await customStatement(
        'ALTER TABLE tabla_productos ADD COLUMN sku TEXT NULL',
      );
    }

    if (!await _existeColumna('tabla_productos', 'producto_padre_id')) {
      await customStatement(
        'ALTER TABLE tabla_productos ADD COLUMN producto_padre_id INTEGER NULL',
      );
    }
  }

  Future<bool> _existeTabla(String tabla) async {
    final rows = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: [Variable.withString(tabla)],
    ).get();
    return rows.isNotEmpty;
  }

  Future<bool> _existeColumna(String tabla, String columna) async {
    final rows = await customSelect('PRAGMA table_info($tabla)').get();
    for (final row in rows) {
      final nombre = row.read<String>('name');
      if (nombre == columna) return true;
    }
    return false;
  }
}

LazyDatabase _abrirConexion() {
  return LazyDatabase(() async {
    final carpeta = await getApplicationDocumentsDirectory();
    final archivo = File(p.join(carpeta.path, 'control_de_mercaderia.sqlite'));
    return NativeDatabase(archivo);
  });
}
