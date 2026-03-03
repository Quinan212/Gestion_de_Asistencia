import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ExportacionCsv {
  static Future<String> guardarCsv({
    required String nombreBase,
    required List<String> encabezados,
    required List<List<String>> filas,
  }) async {
    final carpeta = await getApplicationDocumentsDirectory();

    final ahora = DateTime.now();
    final sello =
        '${ahora.year}${ahora.month.toString().padLeft(2, '0')}${ahora.day.toString().padLeft(2, '0')}_'
        '${ahora.hour.toString().padLeft(2, '0')}${ahora.minute.toString().padLeft(2, '0')}';

    final nombreArchivo = '${_limpiar(nombreBase)}_$sello.csv';
    final archivo = File(p.join(carpeta.path, nombreArchivo));

    final buffer = StringBuffer();
    buffer.writeln(_fila(encabezados));
    for (final f in filas) {
      buffer.writeln(_fila(f));
    }

    await archivo.writeAsString(buffer.toString(), flush: true);
    return archivo.path;
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

  static String _limpiar(String t) {
    return t
        .trim()
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '');
  }
}