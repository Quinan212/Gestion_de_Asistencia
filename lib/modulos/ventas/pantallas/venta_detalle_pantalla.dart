// lib/modulos/ventas/pantallas/venta_detalle_pantalla.dart
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:gestion_de_asistencias/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/layout_app.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/texto_normalizado.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/tablet_master_detail_layout.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/combos/modelos/combo.dart';
import 'package:gestion_de_asistencias/modulos/inventario/modelos/producto.dart';
import 'package:gestion_de_asistencias/modulos/ventas/modelos/venta.dart';
import 'package:gestion_de_asistencias/modulos/ventas/modelos/linea_venta.dart';

class VentaDetallePantalla extends StatefulWidget {
  final int ventaId;

  /// si true: no usa Scaffold/AppBar (para panel derecho en tablet)
  final bool embebido;

  /// callback opcional para avisar a la pantalla padre cuando cambia algo
  final VoidCallback? alCambiarAlgo;

  const VentaDetallePantalla({
    super.key,
    required this.ventaId,
    this.embebido = false,
    this.alCambiarAlgo,
  });

  @override
  State<VentaDetallePantalla> createState() => _VentaDetallePantallaState();
}

class _VentaDetallePantallaState extends State<VentaDetallePantalla> {
  static const double _kTablet = LayoutApp.kTablet;
  String _moneda = r'$';
  late Future<Venta?> _ventaF;
  late Future<bool> _canceladaF;
  late Future<List<LineaVenta>> _lineasF;
  late Future<List<Combo>> _combosF;
  late Future<List<Producto>> _productosF;
  late Future<Map<int, _ProductoVendido>> _vendidosF;

  @override
  void initState() {
    super.initState();
    _cargarMoneda();
    _refrescar();
  }

  @override
  void didUpdateWidget(covariant VentaDetallePantalla oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ventaId != widget.ventaId) {
      setState(_refrescar);
    }
  }

  Future<void> _cargarMoneda() async {
    final m = await Formatos.leerMoneda();
    if (!mounted) return;
    setState(() => _moneda = m);
  }

  Future<Venta?> _venta() =>
      Proveedores.ventasRepositorio.obtenerVenta(widget.ventaId);
  Future<List<LineaVenta>> _lineas() =>
      Proveedores.ventasRepositorio.listarLineas(widget.ventaId);
  Future<List<Combo>> _combos() =>
      Proveedores.combosRepositorio.listarCombos(incluirInactivos: true);
  Future<List<Producto>> _productos() =>
      Proveedores.inventarioRepositorio.listarProductos(incluirInactivos: true);

  void _refrescar() {
    _ventaF = _venta();
    _lineasF = _lineas();
    _combosF = _combos();
    _productosF = _productos();
    _canceladaF = _ventaF.then((v) => v == null ? false : _ventaCancelada(v));
    _vendidosF = _cargarVendidosAsync();
  }

  Future<Map<int, _ProductoVendido>> _cargarVendidosAsync() async {
    final lineas = await _lineasF;
    final combos = await _combosF;
    final productos = await _productosF;
    return _calcularProductosVendidos(
      lineas: lineas,
      combos: combos,
      productos: productos,
    );
  }

  Future<bool> _ventaCancelada(Venta v) async {
    final nota = (v.nota ?? '').toUpperCase();
    if (nota.contains('VENTA CANCELADA')) return true;

    // Si el pedido asociado esta cancelado, reflejarlo en la venta.
    return Proveedores.pedidosRepositorio.ventaEstaCancelada(v.id);
  }

  // -------- fecha estilo ML --------

  String _mesCortoEs(int m) {
    const meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    if (m < 1 || m > 12) return '';
    return meses[m - 1];
  }

  String _fechaML(DateTime f) {
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${f.day}/${_mesCortoEs(f.month)} - ${d2(f.hour)}:${d2(f.minute)} hs';
  }

  // -------- nota: campos (cliente/pago/envio) --------

  String _sinAcentos(String texto) {
    return TextoNormalizado.sinAcentos(texto);
  }

  String _normalizarNota(String? nota) {
    return TextoNormalizado.normalizarNota(nota, quitarAcentos: true);
  }

  String _normalizarClave(String texto) {
    return _sinAcentos(texto)
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Iterable<String> _bloquesNota(String? nota) sync* {
    final normalizada = _normalizarNota(nota);
    for (final linea in normalizada.split('\n')) {
      for (final parte in linea.split('|')) {
        final bloque = parte.trim();
        if (bloque.isNotEmpty) yield bloque;
      }
    }
  }

  String _limpiarValorCampo(String valor) {
    var out = valor.trim();
    for (final sep in const ['|', ';']) {
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

  String _normalizarNombreCliente(String valor) {
    return TextoNormalizado.limpiarTextoSimple(valor);
  }

  String _normalizarTextoSimple(String valor) {
    return TextoNormalizado.limpiarTextoSimple(valor);
  }

  String _extraerPrimerGrupo(String texto, List<RegExp> patrones) {
    for (final p in patrones) {
      final m = p.firstMatch(texto);
      final v = _limpiarValorCampo((m?.group(1) ?? '').trim());
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  String _clienteDesdeNota(String? nota) {
    final t = _normalizarNota(nota);
    final valor = _extraerPrimerGrupo(t, [
      RegExp(
        r'cliente\s*:?\s*(.+?)(?=(?:\n|\||;|pago\s*:|medio\s*de\s*pago\s*:|estado\s*pago\s*:|cargo\s*por\s*(?:envio|envo)|cargo\s*(?:envio|envo)|(?:envio|envo)\s*:|costo\s*estimado|margen\s*estimado|reintegro\s*:|$))',
        caseSensitive: false,
      ),
    ]);
    return _normalizarNombreCliente(valor);
  }

  String _pagoDesdeNota(String? nota) {
    final t = _normalizarNota(nota);
    final valor = _extraerPrimerGrupo(t, [
      RegExp(
        r'medio\s*de\s*pago\s*:?\s*(.+?)(?=(?:\n|\||;|estado\s*pago\s*:|cargo\s*por\s*(?:envio|envo)|cargo\s*(?:envio|envo)|(?:envio|envo)\s*:|costo\s*estimado|margen\s*estimado|reintegro\s*:|$))',
        caseSensitive: false,
      ),
      RegExp(
        r'pago\s*:?\s*(.+?)(?=(?:\n|\||;|estado\s*pago\s*:|cargo\s*por\s*(?:envio|envo)|cargo\s*(?:envio|envo)|(?:envio|envo)\s*:|costo\s*estimado|margen\s*estimado|reintegro\s*:|$))',
        caseSensitive: false,
      ),
    ]);
    return _normalizarTextoSimple(valor);
  }

  String _envioDesdeNota(String? nota) {
    final t = _normalizarNota(nota);

    final porRegex = _extraerPrimerGrupo(t, [
      RegExp(
        r'cargo\s*por\s*(?:envio|envo)\s*:?\s*(.+?)(?=(?:\n|\||;|costo\s*estimado|margen\s*estimado|reintegro\s*:|$))',
        caseSensitive: false,
      ),
      RegExp(
        r'cargo\s*(?:envio|envo)\s*:?\s*(.+?)(?=(?:\n|\||;|costo\s*estimado|margen\s*estimado|reintegro\s*:|$))',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:envio|envo)\s*:?\s*(.+?)(?=(?:\n|\||;|costo\s*estimado|margen\s*estimado|reintegro\s*:|$))',
        caseSensitive: false,
      ),
    ]);
    if (porRegex.isNotEmpty) return porRegex;

    // fallback robusto para notas viejas con texto mal codificado
    for (final bloque in _bloquesNota(nota)) {
      final k = _normalizarClave(bloque);
      final esEnvio =
          k.startsWith('cargo por env') ||
          k.startsWith('cargo env') ||
          k.startsWith('env');
      if (!esEnvio) continue;

      final idx = bloque.indexOf(':');
      if (idx >= 0 && idx + 1 < bloque.length) {
        final v = _limpiarValorCampo(bloque.substring(idx + 1));
        if (v.isNotEmpty) return v;
      }

      final m = RegExp(
        r'env\S*\s+(.+)',
        caseSensitive: false,
      ).firstMatch(bloque);
      final v = _limpiarValorCampo((m?.group(1) ?? '').trim());
      if (v.isNotEmpty) return v;
    }

    return '';
  }

  bool _esBloqueBasuraVisual(String bloque) {
    final t = bloque.trim();
    if (t.length < 8) return false;

    final totalRunes = t.runes.length;
    if (totalRunes == 0) return false;

    final reemplazos = t.runes.where((r) => r == 0xFFFD).length;
    final noAscii = t.runes.where((r) => r > 127).length;
    return reemplazos > 0 || noAscii > (totalRunes / 3);
  }

  bool _esBloqueMeta(String bloque) {
    final k = _normalizarClave(bloque);
    return k.startsWith('cliente') ||
        k.startsWith('pago') ||
        k.startsWith('medio de pago') ||
        k.startsWith('estado pago') ||
        k.startsWith('envio') ||
        k.startsWith('envo') ||
        k.startsWith('cargo por envio') ||
        k.startsWith('cargo por envo') ||
        k.startsWith('cargo envio') ||
        k.startsWith('cargo envo') ||
        k.startsWith('venta directa por productos');
  }

  bool _esBloqueResumen(String bloque) {
    final k = _normalizarClave(bloque);
    return k.startsWith('costo estimado') ||
        k.startsWith('margen estimado') ||
        k.startsWith('reintegro');
  }

  double _parseMonto(String t) {
    var s = t.trim();
    if (s.isEmpty) return 0.0;

    s = s.replaceAll(_moneda, '').replaceAll(' ', '');
    s = s.replaceAll(RegExp(r'[^0-9\.,\-]'), '');
    if (s.isEmpty) return 0.0;

    final hasDot = s.contains('.');
    final hasComma = s.contains(',');

    if (hasDot && hasComma) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if (hasComma && !hasDot) {
      s = s.replaceAll(',', '.');
    }

    return double.tryParse(s) ?? 0.0;
  }

  double _totalProductosDesdeLineas(List<LineaVenta> lineas) {
    double total = 0.0;
    for (final linea in lineas) {
      total += linea.subtotal;
    }
    return total;
  }
  // -------- vendidos (componentes del/los combos) --------

  Future<Map<int, _ProductoVendido>> _calcularProductosVendidos({
    required List<LineaVenta> lineas,
    required List<Combo> combos,
    required List<Producto> productos,
  }) async {
    final combosPorId = <int, Combo>{for (final c in combos) c.id: c};
    final prodPorId = <int, Producto>{for (final p in productos) p.id: p};

    final acumulado = <int, _ProductoVendido>{};

    for (final l in lineas) {
      final combo = combosPorId[l.comboId];
      if (combo == null) continue;

      final componentes = await Proveedores.combosRepositorio.listarComponentes(
        combo.id,
      );

      for (final comp in componentes) {
        final cantidadVendida = comp.cantidad * l.cantidad;
        final prod = prodPorId[comp.productoId];

        final nombre = prod?.nombreConVariante ?? 'Producto ${comp.productoId}';
        final unidad = prod?.unidad ?? '';

        final actual = acumulado[comp.productoId];
        if (actual == null) {
          acumulado[comp.productoId] = _ProductoVendido(
            productoId: comp.productoId,
            nombre: nombre,
            unidad: unidad,
            cantidadVendida: cantidadVendida,
          );
        } else {
          acumulado[comp.productoId] = actual.copiarCon(
            cantidadVendida: actual.cantidadVendida + cantidadVendida,
          );
        }
      }
    }

    return acumulado;
  }

  // -------- UI: avatares de productos --------

  Widget _avatarFotoProducto(Producto? p) {
    const double lado = 49.0;
    const double radius = lado / 2;

    final ruta = (p?.imagen ?? '').trim();
    final ok = ruta.isNotEmpty && File(ruta).existsSync();

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ok
          ? ClipOval(
              child: Image.file(
                File(ruta),
                width: lado,
                height: lado,
                fit: BoxFit.cover,
              ),
            )
          : Icon(
              Icons.image_outlined,
              size: 22,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
    );
  }

  Widget _avatarComboTilde() {
    const double lado = 49.0;
    const double radius = lado / 2;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.check,
        size: 22,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _stackAvatares(List<Widget> avs) {
    if (avs.isEmpty) return const SizedBox.shrink();

    const double bubble = 49.0;
    const double step = 35.0;

    final w = bubble + (avs.length - 1) * step;

    return SizedBox(
      width: w,
      height: bubble + 4,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < avs.length; i++)
            Positioned(
              left: i * step,
              top: 2,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: avs[i],
              ),
            ),
        ],
      ),
    );
  }

  Widget _thumbProducto(Producto? p) {
    final ruta = (p?.imagen ?? '').trim();
    final ok = ruta.isNotEmpty && File(ruta).existsSync();
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 34,
        height: 34,
        color: cs.surfaceContainerHighest,
        child: ok
            ? Image.file(File(ruta), fit: BoxFit.cover)
            : Icon(Icons.image_outlined, size: 18, color: cs.onSurfaceVariant),
      ),
    );
  }

  List<_ProductoVendido> _topVendidos(
    Map<int, _ProductoVendido> vendidos,
    int max,
  ) {
    final lista = vendidos.values.toList()
      ..sort((a, b) => b.cantidadVendida.compareTo(a.cantidadVendida));
    if (lista.length <= max) return lista;
    return lista.sublist(0, max);
  }

  // -------- pago: icono --------

  IconData _iconoPago(String medio) {
    final m = medio.trim().toLowerCase();
    if (m.contains('efect')) return Icons.payments_outlined;
    if (m.contains('tarj')) return Icons.credit_card_outlined;
    if (m.contains('transf')) return Icons.swap_horiz;
    return Icons.account_balance_wallet_outlined;
  }

  Widget _tituloSeccion(String t) {
    return Text(
      t,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _bannerCancelada() {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.block, color: cs.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'VENTA CANCELADA',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: cs.onErrorContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------- MOBILE: layout --------

  Widget _mobileBody({
    required Venta venta,
    required bool cancelada,
    required List<LineaVenta> lineas,
    required List<Combo> combos,
    required List<Producto> productos,
    required Map<int, _ProductoVendido> vendidos,
  }) {
    final prodPorId = <int, Producto>{for (final p in productos) p.id: p};

    final avs = <Widget>[];
    if (vendidos.isNotEmpty) {
      for (final v in _topVendidos(vendidos, 5)) {
        avs.add(_avatarFotoProducto(prodPorId[v.productoId]));
      }
    } else {
      final n = lineas.length.clamp(0, 5);
      for (int i = 0; i < n; i++) {
        avs.add(_avatarComboTilde());
      }
    }

    final envioTxt = _envioDesdeNota(venta.nota);
    final envioMonto = _parseMonto(envioTxt);
    final tieneEnvio = envioTxt.isNotEmpty && envioMonto.abs() > 0.0000001;

    final totalTxt = Formatos.dinero(
      _moneda,
      _totalProductosDesdeLineas(lineas),
    );
    final fechaTxt = _fechaML(venta.fecha);

    final pago = _pagoDesdeNota(venta.nota);
    final cliente = _clienteDesdeNota(venta.nota);

    final filasDesc = vendidos.values.toList()
      ..sort((a, b) => a.nombre.compareTo(b.nombre));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cancelada) ...[_bannerCancelada(), const SizedBox(height: 12)],
          Row(children: [_stackAvatares(avs)]),
          const SizedBox(height: 12),
          Text(
            totalTxt,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              decoration: cancelada ? TextDecoration.lineThrough : null,
              color: cancelada
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : null,
            ),
          ),
          if (tieneEnvio) ...[
            const SizedBox(height: 6),
            Text(
              'Cargo por envio  ${Formatos.dinero(_moneda, envioMonto)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            fechaTxt,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 18),
          _tituloSeccion('Medio de pago'),
          const SizedBox(height: 6),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                child: Icon(
                  _iconoPago(pago),
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pago,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _tituloSeccion('Cliente'),
          const SizedBox(height: 6),
          Text(
            cliente,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 18),
          _tituloSeccion('Descripcion de la venta'),
          const SizedBox(height: 8),
          if (filasDesc.isEmpty)
            Text('-', style: Theme.of(context).textTheme.bodyLarge)
          else
            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    for (int i = 0; i < filasDesc.length; i++) ...[
                      Row(
                        children: [
                          _thumbProducto(prodPorId[filasDesc[i].productoId]),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              filasDesc[i].nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${Formatos.cantidad(filasDesc[i].cantidadVendida, unidad: filasDesc[i].unidad)} ${filasDesc[i].unidad}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      if (i != filasDesc.length - 1) const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // -------- TABLET --------

  Widget _tabletBodyViejo({
    required Venta venta,
    required bool cancelada,
    required List<LineaVenta> lineas,
    required List<Combo> combos,
    required List<Producto> productos,
    required Map<int, _ProductoVendido> vendidos,
  }) {
    final partes = _separarNota(venta.nota);
    final envioTxt = _envioDesdeNota(venta.nota);
    final envioMonto = _parseMonto(envioTxt);
    final tieneEnvio = envioTxt.isNotEmpty && envioMonto.abs() > 0.0000001;
    final totalProductosTxt = Formatos.dinero(
      _moneda,
      _totalProductosDesdeLineas(lineas),
    );

    return Padding(
      padding: TabletMasterDetailLayout.kPagePadding,
      child: Column(
        children: [
          if (cancelada) ...[_bannerCancelada(), const SizedBox(height: 12)],
          Expanded(
            child: TabletMasterDetailLayout(
              master: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fecha: ${_fechaML(venta.fecha)}'),
                    const SizedBox(height: 8),
                    Text(
                      'Productos: $totalProductosTxt',
                      style: TextStyle(
                        decoration: cancelada
                            ? TextDecoration.lineThrough
                            : null,
                        color: cancelada
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    if (tieneEnvio) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Cargo por envio  ${Formatos.dinero(_moneda, envioMonto)}',
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (partes.resumen.isNotEmpty) ...[
                      Text(
                        'Resumen estimado',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(_resumenConMoneda(partes.resumen)),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      'Nota',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(partes.nota.isEmpty ? '-' : partes.nota),
                      ),
                    ),
                  ],
                ),
              ),
              detail: Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: lineas.isEmpty
                      ? const Center(child: Text('Sin lineas'))
                      : ListView.separated(
                          itemCount: lineas.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final l = lineas[i];
                            final combo = combos.firstWhere(
                              (c) => c.id == l.comboId,
                              orElse: () => Combo(
                                id: l.comboId,
                                nombre: 'Combo ${l.comboId}',
                                precioVenta: 0,
                                activo: true,
                                creadoEn: DateTime.now(),
                              ),
                            );

                            return ListTile(
                              title: Text(
                                combo.nombre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                'Cantidad: ${l.cantidad.toStringAsFixed(2)}\n'
                                'Precio: ${Formatos.dinero(_moneda, l.precioUnitario)}',
                              ),
                              trailing: Text(
                                Formatos.dinero(_moneda, l.subtotal),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------- util resumen --------

  ({String resumen, String nota}) _separarNota(String? nota) {
    final resumen = <String>[];
    final resto = <String>[];

    for (final bloque in _bloquesNota(nota)) {
      if (_esBloqueBasuraVisual(bloque)) {
        continue;
      }
      if (_esBloqueMeta(bloque)) {
        continue;
      }

      if (_esBloqueResumen(bloque)) {
        resumen.add(bloque);
      } else {
        resto.add(bloque);
      }
    }

    return (resumen: resumen.join('\n').trim(), nota: resto.join('\n').trim());
  }

  String _resumenConMoneda(String resumen) {
    String arreglarLinea(String linea) {
      String poner(String etiqueta, String linea) {
        final idx = linea.indexOf(etiqueta);
        if (idx < 0) return linea;

        final inicio = idx + etiqueta.length;
        final fin = linea.indexOf(';', inicio);

        final textoNumero =
            (fin < 0 ? linea.substring(inicio) : linea.substring(inicio, fin))
                .trim();

        final n = double.tryParse(textoNumero.replaceAll(',', '.'));
        if (n == null) return linea;

        final reemplazo = ' ${Formatos.dinero(_moneda, n)}';

        if (fin < 0) return linea.substring(0, inicio) + reemplazo;
        return linea.substring(0, inicio) + reemplazo + linea.substring(fin);
      }

      var x = linea;
      x = poner('Costo estimado combo:', x);
      x = poner('Costo estimado total:', x);
      x = poner('Margen estimado:', x);
      x = poner('Reintegro:', x);
      return x;
    }

    return resumen.split('\n').map(arreglarLinea).join('\n');
  }

  // -------- contenido --------

  Widget _contenido() {
    return FutureBuilder<Venta?>(
      future: _ventaF,
      builder: (context, snapV) {
        if (snapV.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final venta = snapV.data;
        if (venta == null) {
          return const Center(child: Text('Venta no encontrada'));
        }

        return FutureBuilder<bool>(
          future: _canceladaF,
          builder: (context, snapCancel) {
            final cancelada = snapCancel.data ?? false;

            return FutureBuilder<List<LineaVenta>>(
              future: _lineasF,
              builder: (context, snapL) {
                if (snapL.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final lineas = snapL.data ?? [];

                return FutureBuilder<List<Combo>>(
                  future: _combosF,
                  builder: (context, snapC) {
                    if (snapC.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final combos = snapC.data ?? [];

                    return FutureBuilder<List<Producto>>(
                      future: _productosF,
                      builder: (context, snapP) {
                        if (snapP.connectionState != ConnectionState.done) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final productos = snapP.data ?? [];

                        return FutureBuilder<Map<int, _ProductoVendido>>(
                          future: _vendidosF,
                          builder: (context, snapVendidos) {
                            final vendidos = snapVendidos.data ?? {};

                            return LayoutBuilder(
                              builder: (context, c) {
                                final esTablet = c.maxWidth >= _kTablet;

                                return esTablet
                                    ? _tabletBodyViejo(
                                        venta: venta,
                                        cancelada: cancelada,
                                        lineas: lineas,
                                        combos: combos,
                                        productos: productos,
                                        vendidos: vendidos,
                                      )
                                    : _mobileBody(
                                        venta: venta,
                                        cancelada: cancelada,
                                        lineas: lineas,
                                        combos: combos,
                                        productos: productos,
                                        vendidos: vendidos,
                                      );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embebido) return _contenido();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de venta')),
      body: _contenido(),
    );
  }
}

class _ProductoVendido {
  final int productoId;
  final String nombre;
  final String unidad;
  final double cantidadVendida;

  const _ProductoVendido({
    required this.productoId,
    required this.nombre,
    required this.unidad,
    required this.cantidadVendida,
  });

  _ProductoVendido copiarCon({double? cantidadVendida}) {
    return _ProductoVendido(
      productoId: productoId,
      nombre: nombre,
      unidad: unidad,
      cantidadVendida: cantidadVendida ?? this.cantidadVendida,
    );
  }
}
