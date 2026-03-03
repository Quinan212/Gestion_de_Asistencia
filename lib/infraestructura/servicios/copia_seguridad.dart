import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '/infraestructura/dep_inyeccion/proveedores.dart';

class CopiaSeguridad {
  static Future<String> crearCopiaCompleta() async {
    final carpetaDocs = await getApplicationDocumentsDirectory();

    final ahora = DateTime.now();
    final sello =
        '${ahora.year}${ahora.month.toString().padLeft(2, '0')}${ahora.day.toString().padLeft(2, '0')}_'
        '${ahora.hour.toString().padLeft(2, '0')}${ahora.minute.toString().padLeft(2, '0')}';

    final carpeta = Directory(p.join(carpetaDocs.path, 'copia_$sello'));
    await carpeta.create(recursive: true);

    final bd = Proveedores.baseDeDatos;

    final productos = await bd.select(bd.tablaProductos).get();
    await _guardarCsv(
      carpeta: carpeta,
      nombreArchivo: 'productos.csv',
      encabezados: [
        'id',
        'nombre',
        'unidad',
        'costoActual',
        'precioSugerido',
        'stockMinimo',
        'proveedor',
        'activo',
        'creadoEn',
      ],
      filas: productos.map((x) {
        return [
          x.id.toString(),
          x.nombre,
          x.unidad,
          x.costoActual.toString(),
          x.precioSugerido.toString(),
          x.stockMinimo.toString(),
          x.proveedor ?? '',
          x.activo ? 'si' : 'no',
          x.creadoEn.toIso8601String(),
        ];
      }).toList(),
    );

    final movimientos = await bd.select(bd.tablaMovimientos).get();
    await _guardarCsv(
      carpeta: carpeta,
      nombreArchivo: 'movimientos.csv',
      encabezados: [
        'id',
        'productoId',
        'tipo',
        'cantidad',
        'fecha',
        'nota',
        'referencia',
      ],
      filas: movimientos.map((x) {
        return [
          x.id.toString(),
          x.productoId.toString(),
          x.tipo,
          x.cantidad.toString(),
          x.fecha.toIso8601String(),
          x.nota ?? '',
          x.referencia ?? '',
        ];
      }).toList(),
    );

    final combos = await bd.select(bd.tablaCombos).get();
    await _guardarCsv(
      carpeta: carpeta,
      nombreArchivo: 'combos.csv',
      encabezados: ['id', 'nombre', 'precioVenta', 'activo', 'creadoEn'],
      filas: combos.map((x) {
        return [
          x.id.toString(),
          x.nombre,
          x.precioVenta.toString(),
          x.activo ? 'si' : 'no',
          x.creadoEn.toIso8601String(),
        ];
      }).toList(),
    );

    final componentes = await bd.select(bd.tablaComponentes).get();
    await _guardarCsv(
      carpeta: carpeta,
      nombreArchivo: 'componentes_combo.csv',
      encabezados: ['id', 'comboId', 'productoId', 'cantidad'],
      filas: componentes.map((x) {
        return [
          x.id.toString(),
          x.comboId.toString(),
          x.productoId.toString(),
          x.cantidad.toString(),
        ];
      }).toList(),
    );

    final ventas = await bd.select(bd.tablaVentas).get();
    await _guardarCsv(
      carpeta: carpeta,
      nombreArchivo: 'ventas.csv',
      encabezados: ['id', 'fecha', 'total', 'nota'],
      filas: ventas.map((x) {
        return [
          x.id.toString(),
          x.fecha.toIso8601String(),
          x.total.toString(),
          x.nota ?? '',
        ];
      }).toList(),
    );

    final lineasVenta = await bd.select(bd.tablaLineasVenta).get();
    await _guardarCsv(
      carpeta: carpeta,
      nombreArchivo: 'lineas_venta.csv',
      encabezados: [
        'id',
        'ventaId',
        'comboId',
        'cantidad',
        'precioUnitario',
        'subtotal',
      ],
      filas: lineasVenta.map((x) {
        return [
          x.id.toString(),
          x.ventaId.toString(),
          x.comboId.toString(),
          x.cantidad.toString(),
          x.precioUnitario.toString(),
          x.subtotal.toString(),
        ];
      }).toList(),
    );

    final compras = await bd.select(bd.tablaCompras).get();
    await _guardarCsv(
      carpeta: carpeta,
      nombreArchivo: 'compras.csv',
      encabezados: ['id', 'fecha', 'proveedor', 'total', 'nota'],
      filas: compras.map((x) {
        return [
          x.id.toString(),
          x.fecha.toIso8601String(),
          x.proveedor ?? '',
          x.total.toString(),
          x.nota ?? '',
        ];
      }).toList(),
    );

    final lineasCompra = await bd.select(bd.tablaLineasCompra).get();
    await _guardarCsv(
      carpeta: carpeta,
      nombreArchivo: 'lineas_compra.csv',
      encabezados: [
        'id',
        'compraId',
        'productoId',
        'cantidad',
        'costoUnitario',
        'subtotal',
      ],
      filas: lineasCompra.map((x) {
        return [
          x.id.toString(),
          x.compraId.toString(),
          x.productoId.toString(),
          x.cantidad.toString(),
          x.costoUnitario.toString(),
          x.subtotal.toString(),
        ];
      }).toList(),
    );

    return carpeta.path;
  }

  static Future<String> crearZipDeCopiaCompleta() async {
    final carpetaPath = await crearCopiaCompleta();
    final carpeta = Directory(carpetaPath);

    final zipPath = '${carpeta.path}.zip';
    final encoder = ZipFileEncoder();
    encoder.create(zipPath);

    final archivos = carpeta
        .listSync(recursive: true)
        .whereType<File>()
        .toList();

    for (final f in archivos) {
      encoder.addFile(f);
    }

    encoder.close();
    return zipPath;
  }

  static Future<void> _guardarCsv({
    required Directory carpeta,
    required String nombreArchivo,
    required List<String> encabezados,
    required List<List<String>> filas,
  }) async {
    final archivo = File(p.join(carpeta.path, nombreArchivo));

    final buffer = StringBuffer();
    buffer.writeln(_fila(encabezados));
    for (final f in filas) {
      buffer.writeln(_fila(f));
    }

    await archivo.writeAsString(buffer.toString(), flush: true);
  }

  static String _fila(List<String> celdas) {
    return celdas.map(_escapar).join(',');
  }

  static String _escapar(String valor) {
    final v = valor.replaceAll('"', '""');
    if (v.contains(',') || v.contains('\n') || v.contains('"')) {
      return '"$v"';
    }
    return v;
  }
}