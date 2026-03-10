import 'package:gestion_de_asistencias/aplicacion/utiles/texto_normalizado.dart';

import '/infraestructura/base_de_datos/base_de_datos.dart';
import 'ventas_bd.dart';
import '../modelos/venta.dart';
import '../modelos/linea_venta.dart';

class VentasRepositorio {
  final VentasBd _bd;

  VentasRepositorio(BaseDeDatos baseDeDatos) : _bd = VentasBd(baseDeDatos);

  Future<void> actualizarNotaVenta({
    required int ventaId,
    required String? nota,
  }) {
    return _bd.actualizarNotaVenta(ventaId: ventaId, nota: nota);
  }

  Future<int> crearVenta({double total = 0, String? nota, DateTime? fecha}) {
    return _bd.crearVenta(total: total, nota: nota, fecha: fecha);
  }

  // Combo (compatibilidad con tu API anterior)
  Future<int> agregarLinea({
    required int ventaId,
    required int comboId,
    required double cantidad,
    required double precioUnitario,
  }) {
    return _bd.agregarLineaCombo(
      ventaId: ventaId,
      comboId: comboId,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
    );
  }

  // NUEVO: producto
  Future<int> agregarLineaProducto({
    required int ventaId,
    required int productoId,
    required double cantidad,
    required double precioUnitario,
  }) {
    return _bd.agregarLineaProducto(
      ventaId: ventaId,
      productoId: productoId,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
    );
  }

  Future<void> actualizarTotalVenta({
    required int ventaId,
    required double total,
  }) {
    return _bd.actualizarTotalVenta(ventaId: ventaId, total: total);
  }

  Future<List<Venta>> listarVentas() => _bd.listarVentas();

  Future<Venta?> obtenerVenta(int id) => _bd.obtenerVenta(id);

  Future<List<LineaVenta>> listarLineas(int ventaId) =>
      _bd.listarLineas(ventaId);

  Future<int> normalizarNotasVentasLegacy() async {
    final ventas = await _bd.listarVentas();
    int cambios = 0;

    for (final v in ventas) {
      final original = v.nota;
      final normalizada = _normalizarNotaLegacy(original);
      if (normalizada == original) continue;

      await _bd.actualizarNotaVenta(ventaId: v.id, nota: normalizada);
      cambios++;
    }

    return cambios;
  }

  String? _normalizarNotaLegacy(String? nota) {
    if (nota == null) return null;
    if (nota.trim().isEmpty) return nota;

    final base = _normalizarSeparadoresNota(nota);
    final lineas = base.split('\n');
    final out = <String>[];
    bool cambio = base != nota;

    final reCliente = RegExp(
      r'^\s*[\|;\-\u2022\u00B7\u00E2\u20AC\u00A2\u00C2]*\s*cliente\s*:?\s*(.*)$',
      caseSensitive: false,
    );
    final rePago = RegExp(
      r'^\s*[\|;\-\u2022\u00B7\u00E2\u20AC\u00A2\u00C2]*\s*(?:medio\s*de\s*pago|pago)\s*:?\s*(.*)$',
      caseSensitive: false,
    );

    for (final l in lineas) {
      final mc = reCliente.firstMatch(l);
      if (mc != null) {
        final v = _normalizarTexto(_limpiarValorCampo(mc.group(1) ?? ''));
        final nueva = v.isEmpty ? '' : 'Cliente: $v';
        out.add(nueva);
        if (nueva != l) cambio = true;
        continue;
      }

      final mp = rePago.firstMatch(l);
      if (mp != null) {
        final v = _normalizarTexto(_limpiarValorCampo(mp.group(1) ?? ''));
        final nueva = v.isEmpty ? '' : 'Pago: $v';
        out.add(nueva);
        if (nueva != l) cambio = true;
        continue;
      }

      out.add(l);
    }

    final normalizada = out.join('\n');
    if (!cambio && normalizada == nota) return nota;
    return normalizada;
  }

  String _normalizarSeparadoresNota(String texto) {
    return TextoNormalizado.normalizarNota(texto);
  }

  String _limpiarValorCampo(String valor) {
    var out = _normalizarSeparadoresNota(valor).trim();

    for (final sep in const ['|', ';', '\u2022', '\u00B7']) {
      final idx = out.indexOf(sep);
      if (idx >= 0) out = out.substring(0, idx).trim();
    }

    final lower = out.toLowerCase();
    for (final marker in const [
      'pago:',
      'medio de pago:',
      'estado pago:',
      'envio:',
      'envo:',
      'cargo por envio',
      'cargo por envo',
      'cargo envio',
      'cargo envo',
      'costo estimado',
      'margen estimado',
      'reintegro:',
    ]) {
      final idx = lower.indexOf(marker);
      if (idx > 0) {
        out = out.substring(0, idx).trim();
        break;
      }
    }

    return out;
  }

  String _normalizarTexto(String valor) {
    return TextoNormalizado.limpiarTextoSimple(valor);
  }
}
