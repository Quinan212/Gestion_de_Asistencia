// lib/modulos/reportes/datos/reportes_repositorio.dart
import '/infraestructura/base_de_datos/base_de_datos.dart';

class ReportesRepositorio {
  final BaseDeDatos _bd;

  ReportesRepositorio(this._bd);

  Future<List<Map<String, dynamic>>> ventasPorDia({int dias = 14}) async {
    final filas = await _bd.select(_bd.tablaVentas).get();

    final hoy = DateTime.now();
    final desde =
    DateTime(hoy.year, hoy.month, hoy.day).subtract(Duration(days: dias - 1));

    final mapa = <String, double>{};

    for (final v in filas) {
      final f = v.fecha;
      final soloDia = DateTime(f.year, f.month, f.day);

      if (soloDia.isBefore(desde)) continue;

      final clave =
          '${soloDia.year}-${soloDia.month.toString().padLeft(2, '0')}-${soloDia.day.toString().padLeft(2, '0')}';
      mapa[clave] = (mapa[clave] ?? 0) + v.total;
    }

    final claves = mapa.keys.toList()..sort();
    return claves.map((k) => {'fecha': k, 'total': mapa[k] ?? 0}).toList();
  }

  Future<List<Map<String, dynamic>>> consumoPorProducto({int dias = 30}) async {
    final productos = await _bd.select(_bd.tablaProductos).get();
    final movimientos = await _bd.select(_bd.tablaMovimientos).get();

    final hoy = DateTime.now();
    final desde =
    DateTime(hoy.year, hoy.month, hoy.day).subtract(Duration(days: dias - 1));

    final porId = <int, String>{for (final p in productos) p.id: p.nombre};
    final unidades = <int, String>{for (final p in productos) p.id: p.unidad};

    // para poder resolver reversion_de:<id>
    final porMovId = {for (final m in movimientos) m.id: m};

    double deltaConsumo(dynamic m) {
      if (m.tipo == 'egreso') return m.cantidad;
      if (m.tipo == 'devolucion') return -m.cantidad;
      return 0.0; // ingreso/ajuste no cuentan como consumo
    }

    final neto = <int, double>{};

    for (final m in movimientos) {
      final f = m.fecha;
      final soloDia = DateTime(f.year, f.month, f.day);
      if (soloDia.isBefore(desde)) continue;

      final ref = (m.referencia ?? '');

      // si es reversión, usamos el original para calcular el efecto REAL
      if (ref.startsWith('reversion_de:')) {
        final idTxt = ref.substring('reversion_de:'.length);
        final id = int.tryParse(idTxt);
        final original = (id == null) ? null : porMovId[id];
        if (original == null) continue;

        // efecto de reversión = - efecto del original
        final d = -deltaConsumo(original);
        if (d.abs() < 1e-9) continue;

        neto[m.productoId] = (neto[m.productoId] ?? 0) + d;
        continue;
      }

      // movimiento normal
      final d = deltaConsumo(m);
      if (d.abs() < 1e-9) continue;

      neto[m.productoId] = (neto[m.productoId] ?? 0) + d;
    }

    final lista = neto.entries
        .map((e) => {
      'productoId': e.key,
      'nombre': porId[e.key] ?? 'Producto ${e.key}',
      'unidad': unidades[e.key] ?? '',
      'cantidad': e.value,
    })
        .toList();

    lista.removeWhere((x) => ((x['cantidad'] as double).abs() < 1e-9));

    lista.sort((a, b) => (b['cantidad'] as double).compareTo(a['cantidad'] as double));
    return lista;
  }

  Future<List<Map<String, dynamic>>> reposicionPorMinimo() async {
    final productos = await _bd.select(_bd.tablaProductos).get();
    final movimientos = await _bd.select(_bd.tablaMovimientos).get();

    final stockPorProducto = <int, double>{};

    for (final m in movimientos) {
      final id = m.productoId;
      final cant = m.cantidad;
      final tipo = m.tipo;

      if (tipo == 'ingreso' || tipo == 'devolucion') {
        stockPorProducto[id] = (stockPorProducto[id] ?? 0) + cant;
      } else if (tipo == 'egreso') {
        stockPorProducto[id] = (stockPorProducto[id] ?? 0) - cant;
      } else if (tipo == 'ajuste') {
        stockPorProducto[id] = (stockPorProducto[id] ?? 0) + cant;
      }
    }

    final List<Map<String, dynamic>> lista = [];

    for (final p in productos) {
      if (!p.activo) continue;
      final stock = stockPorProducto[p.id] ?? 0;
      if (stock + 1e-9 < p.stockMinimo) {
        lista.add({
          'productoId': p.id,
          'nombre': p.nombre,
          'unidad': p.unidad,
          'stock': stock,
          'minimo': p.stockMinimo,
          'faltante': (p.stockMinimo - stock),
        });
      }
    }

    lista.sort((a, b) => (b['faltante'] as double).compareTo(a['faltante'] as double));
    return lista;
  }
}