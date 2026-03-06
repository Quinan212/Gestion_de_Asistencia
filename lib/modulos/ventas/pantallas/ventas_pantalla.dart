import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gestion_de_stock/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_stock/modulos/ventas/modelos/venta.dart';
import 'package:gestion_de_stock/modulos/ventas/pantallas/venta_nueva_pantalla.dart';
import 'package:gestion_de_stock/modulos/ventas/pantallas/venta_detalle_pantalla.dart';

class VentasPantalla extends StatefulWidget {
  const VentasPantalla({super.key});

  @override
  State<VentasPantalla> createState() => _VentasPantallaState();
}

class _VentasPantallaState extends State<VentasPantalla> {
  static const double _kTablet = 900;
  static const bool _mostrarBotonNuevaVenta = false;
  String _moneda = r'$';
  int? _seleccionadaId;
  int _refreshTick = 0;

  final _buscarCtrl = TextEditingController();
  String _q = '';

  // cache: evita saltos/parpadeos por FutureBuilder por fila
  final Map<int, Future<_VentaItemInfo>> _infoCache = {};

  @override
  void initState() {
    super.initState();
    _cargarMoneda();
    _buscarCtrl.addListener(() {
      final t = _buscarCtrl.text.trim();
      if (t == _q) return;
      setState(() => _q = t);
    });
  }

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarMoneda() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _moneda = prefs.getString('config_moneda') ?? r'$');
  }

  Future<List<Venta>> _cargar() => Proveedores.ventasRepositorio.listarVentas();

  Future<void> _nuevaVenta() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VentaNuevaPantalla()),
    );
    if (!mounted) return;
    setState(() {
      _refreshTick++;
      _infoCache.clear(); // refrescar títulos/miniaturas
    });
  }

  bool _esAncha(BoxConstraints c) => c.maxWidth >= _kTablet;

  // -------------------- helpers fecha --------------------

  static const _mesesLargos = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  String _hora24(DateTime f) {
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${d2(f.hour)}:${d2(f.minute)} hs';
  }

  bool _mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _tituloDia(DateTime f) {
    final hoy = DateTime.now();
    final dHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final dF = DateTime(f.year, f.month, f.day);

    final diff = dHoy.difference(dF).inDays;
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';

    final mes = (f.month >= 1 && f.month <= 12) ? _mesesLargos[f.month - 1] : '';
    return '${f.day} de $mes';
  }

  // -------------------- helpers nota: cliente/envio --------------------

  String _extraerCampoNota(String? nota, List<String> etiquetas) {
    final t = (nota ?? '').trim();
    if (t.isEmpty) return '';
    for (final et in etiquetas) {
      final re = RegExp('${RegExp.escape(et)}\\s*([^•\\n]+)', caseSensitive: false);
      final m = re.firstMatch(t);
      final v = (m?.group(1) ?? '').trim();
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  String _clienteDesdeNota(String? nota) =>
      _extraerCampoNota(nota, const ['Cliente:', 'cliente:']);

  String _envioDesdeNota(String? nota) => _extraerCampoNota(
    nota,
    const ['Envío:', 'Envio:', 'Cargo por envío:', 'Cargo envio:'],
  );

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

  // -------------------- info por item (solo titulo + imagen) --------------------

  Future<_VentaItemInfo> _infoVenta(Venta v) async {
    String titulo = 'Venta';
    String? imagen;

    try {
      final lineas = await Proveedores.ventasRepositorio.listarLineas(v.id);
      if (lineas.isNotEmpty) {
        final primera = lineas.first;
        final combo = await Proveedores.combosRepositorio.obtenerCombo(primera.comboId);
        if (combo != null) {
          final n = combo.nombre.trim();
          titulo = n.isEmpty ? 'Venta' : n;

          final comps = await Proveedores.combosRepositorio.listarComponentes(combo.id);
          if (comps.isNotEmpty) {
            final prod = await Proveedores.inventarioRepositorio.obtenerProducto(
              comps.first.productoId,
            );
            final ruta = (prod?.imagen ?? '').trim();
            if (ruta.isNotEmpty && File(ruta).existsSync()) {
              imagen = ruta;
            }
          }
        }
      }
    } catch (_) {}

    return _VentaItemInfo(titulo: titulo, imagenRuta: imagen);
  }

  Future<_VentaItemInfo> _infoVentaCached(Venta v) {
    return _infoCache.putIfAbsent(v.id, () => _infoVenta(v));
  }

  // -------------------- UI --------------------

  Widget _botonNuevaVenta() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _nuevaVenta,
        icon: const Icon(Icons.add),
        label: const Text('Nueva venta'),
      ),
    );
  }

  Widget _buscador() {
    return TextField(
      controller: _buscarCtrl,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Buscar venta',
        suffixIcon: _q.isEmpty
            ? null
            : IconButton(
          onPressed: () {
            _buscarCtrl.clear();
            FocusScope.of(context).unfocus();
          },
          icon: const Icon(Icons.close),
          tooltip: 'Limpiar',
        ),
      ),
    );
  }

  Widget _avatarVenta(String? ruta, {required bool cancelada}) {
    final cs = Theme.of(context).colorScheme;

    if (ruta != null && ruta.trim().isNotEmpty && File(ruta).existsSync()) {
      return CircleAvatar(
        radius: 30,
        backgroundColor: cs.surfaceContainerHighest,
        backgroundImage: FileImage(File(ruta)),
      );
    }

    return CircleAvatar(
      radius: 30,
      backgroundColor: cs.surfaceContainerHighest,
      child: Icon(
        cancelada ? Icons.block : Icons.receipt_long_outlined,
        size: 26,
        color: cs.onSurfaceVariant,
      ),
    );
  }

  double _totalSoloProductos(Venta v) {
    final envioTxt = _envioDesdeNota(v.nota);
    final envio = _parseMonto(envioTxt);

    final total = v.total;
    final x = total - envio;

    if (!x.isFinite) return total;
    if (x < 0) return 0.0;
    return x;
  }

  Widget _filaVenta({
    required bool ancha,
    required Venta v,
    required bool seleccionada,
  }) {
    final cancelada = (v.nota ?? '').contains('VENTA CANCELADA');
    final cliente = _clienteDesdeNota(v.nota);

    // monto fijo (sin Future) => sin salto
    final totalProductos = _totalSoloProductos(v);

    final cs = Theme.of(context).colorScheme;
    final bgSel = cs.primary.withValues(alpha: 0.08);

    return FutureBuilder<_VentaItemInfo>(
      future: _infoVentaCached(v),
      builder: (context, snap) {
        final info = snap.data;
        final titulo = info?.titulo ?? 'Venta';
        final ruta = info?.imagenRuta;

        return InkWell(
          onTap: () {
            if (ancha) {
              setState(() => _seleccionadaId = v.id);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VentaDetallePantalla(ventaId: v.id),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            color: seleccionada ? bgSel : null,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _avatarVenta(ruta, cancelada: cancelada),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cancelada ? cs.onSurfaceVariant : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cliente.isEmpty ? '-' : cliente,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$_moneda ${totalProductos.toStringAsFixed(2)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cancelada ? cs.onSurfaceVariant : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _hora24(v.fecha),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Venta> _filtrarVentas(List<Venta> ventas) {
    final q = _q.trim().toLowerCase();
    if (q.isEmpty) return ventas;

    return ventas.where((v) {
      final cliente = _clienteDesdeNota(v.nota).toLowerCase();
      final nota = (v.nota ?? '').toLowerCase();
      return cliente.contains(q) || nota.contains(q);
    }).toList();
  }

  Widget _listaVentas({
    required bool ancha,
    required List<Venta> ventas,
  }) {
    final filtradas = _filtrarVentas(ventas);

    if (filtradas.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(_q.isEmpty ? 'Todavía no hay ventas' : 'Sin resultados'),
        ),
      );
    }

    filtradas.sort((a, b) => b.fecha.compareTo(a.fecha));

    final rows = <_RowItem>[];
    DateTime? ultimoDia;
    for (final v in filtradas) {
      final d = DateTime(v.fecha.year, v.fecha.month, v.fecha.day);
      if (ultimoDia == null || !_mismoDia(d, ultimoDia)) {
        rows.add(_RowItem.header(_tituloDia(v.fecha)));
        ultimoDia = d;
      }
      rows.add(_RowItem.venta(v));
    }

    return Expanded(
      child: ListView.separated(
        itemCount: rows.length,
        separatorBuilder: (context, i) {
          if (i + 1 >= rows.length) return const SizedBox(height: 0);

          final a = rows[i];
          final b = rows[i + 1];

          if (a.kind == _RowKind.venta && b.kind == _RowKind.header) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, thickness: 1),
            );
          }

          return const SizedBox(height: 0);
        },
        itemBuilder: (context, i) {
          final r = rows[i];

          if (r.kind == _RowKind.header) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
              child: Text(
                r.headerText!,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final v = r.venta!;
          final seleccionada = ancha && _seleccionadaId == v.id;

          return _filaVenta(
            ancha: ancha,
            v: v,
            seleccionada: seleccionada,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final ancha = _esAncha(c);

        return Padding(
          padding: const EdgeInsets.all(12),
          child: FutureBuilder<List<Venta>>(
            future: _cargar(),
            key: ValueKey('ventas_future_$_refreshTick'),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              final ventas = snap.data ?? [];

              if (ancha && _seleccionadaId == null && ventas.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (_seleccionadaId == null) setState(() => _seleccionadaId = ventas.first.id);
                });
              }

              Widget panelLista() {
                return Column(
                  children: [
                    if (_mostrarBotonNuevaVenta)
                    _botonNuevaVenta(),
                    const SizedBox(height: 10),
                    _buscador(),
                    const SizedBox(height: 10),
                    _listaVentas(ancha: ancha, ventas: ventas),
                  ],
                );
              }

              if (!ancha) return panelLista();

              final id = _seleccionadaId;

              return Row(
                children: [
                  Expanded(flex: 4, child: panelLista()),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 6,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: id == null
                            ? const Center(child: Text('Elegí una venta'))
                            : VentaDetallePantalla(
                          ventaId: id,
                          embebido: true,
                          alCambiarAlgo: () {
                            setState(() {
                              _refreshTick++;
                              _infoCache.clear();
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _VentaItemInfo {
  final String titulo;
  final String? imagenRuta;

  const _VentaItemInfo({
    required this.titulo,
    required this.imagenRuta,
  });
}

enum _RowKind { header, venta }

class _RowItem {
  final _RowKind kind;
  final String? headerText;
  final Venta? venta;

  _RowItem.header(this.headerText)
      : kind = _RowKind.header,
        venta = null;

  _RowItem.venta(this.venta)
      : kind = _RowKind.venta,
        headerText = null;
}