import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gestion_de_asistencias/aplicacion/utiles/filtros_persistidos.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/layout_app.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/texto_normalizado.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/estado_lista.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/fila_lista_modulo.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/panel_controles_modulo.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/tablet_master_detail_layout.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/ventas/modelos/venta.dart';
import 'package:gestion_de_asistencias/modulos/ventas/pantallas/venta_detalle_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/ventas/pantallas/venta_nueva_pantalla.dart';

class VentasPantalla extends StatefulWidget {
  const VentasPantalla({super.key});

  @override
  State<VentasPantalla> createState() => _VentasPantallaState();
}

class _VentasPantallaState extends State<VentasPantalla> {
  static const double _kTablet = LayoutApp.kTablet;
  static const bool _mostrarBotonNuevaVenta = false;
  static const String _kBusquedaKey = 'ventas_busqueda_v1';

  String _moneda = r'$';
  int? _seleccionadaId;

  final _buscarCtrl = TextEditingController();
  String _q = '';

  // cache: evita recalculos y saltos visuales de total->subtotal
  final Map<int, _VentaItemInfo> _infoCache = {};
  late Future<List<Venta>> _datosFuture;
  late final VoidCallback _datosVersionListener;
  bool _hidratandoInfo = false;
  int _hidratacionToken = 0;
  final Set<int> _idsHidratando = <int>{};

  @override
  void initState() {
    super.initState();
    _cargarMoneda();
    _restaurarBusqueda();
    _datosFuture = _cargar();
    _datosVersionListener = _onDatosVersionChanged;
    Proveedores.datosVersion.addListener(_datosVersionListener);
    _buscarCtrl.addListener(() {
      final t = _buscarCtrl.text.trim();
      if (t == _q) return;
      setState(() => _q = t);
      _guardarBusqueda(t);
    });
  }

  Future<void> _restaurarBusqueda() async {
    final q = await FiltrosPersistidos.leerTexto(_kBusquedaKey);
    if (!mounted) return;
    _buscarCtrl.text = q;
    setState(() => _q = q.trim());
  }

  void _guardarBusqueda(String texto) {
    FiltrosPersistidos.guardarTexto(_kBusquedaKey, texto);
  }

  void _onDatosVersionChanged() {
    if (!mounted) return;
    setState(() {
      _cancelarHidratacion();
      _infoCache.clear();
      _datosFuture = _cargar();
    });
  }

  @override
  void dispose() {
    _cancelarHidratacion();
    Proveedores.datosVersion.removeListener(_datosVersionListener);
    _buscarCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarMoneda() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _moneda = prefs.getString('config_moneda') ?? r'$');
  }

  Future<List<Venta>> _cargar() async {
    try {
      return await Proveedores.ventasRepositorio.listarVentas();
    } catch (e, st) {
      debugPrint('VentasPantalla._cargar error: ${e.toString()}');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  Future<void> _nuevaVenta() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VentaNuevaPantalla()),
    );
    if (!mounted) return;
    setState(() {
      _cancelarHidratacion();
      _infoCache.clear();
      _datosFuture = _cargar();
    });
  }

  bool _esAncha(BoxConstraints c) => c.maxWidth >= _kTablet;

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

  void _cancelarHidratacion() {
    _hidratacionToken++;
    _hidratandoInfo = false;
    _idsHidratando.clear();
  }

  _VentaItemInfo _infoFallback(Venta v) {
    return _VentaItemInfo(
      titulo: 'Venta',
      imagenRuta: null,
      subtotal: v.total,
      notaPedidoFallback: null,
    );
  }

  void _programarHidratacionInfo(List<Venta> ventas) {
    if (_hidratandoInfo) return;

    final pendientes = ventas.where((v) {
      final enCache = _infoCache[v.id];
      if (enCache == null) {
        return !_idsHidratando.contains(v.id);
      }
      final notaEnVenta = _notaPedidoDesdeNota(v.nota).trim();
      final notaEnCache = (enCache.notaPedidoFallback ?? '').trim();
      final cacheIncompleto = notaEnVenta.isEmpty && notaEnCache.isEmpty;
      return cacheIncompleto && !_idsHidratando.contains(v.id);
    }).toList();
    if (pendientes.isEmpty) return;

    _hidratandoInfo = true;
    final token = ++_hidratacionToken;

    Future<void>(() async {
      const tamanioLote = 6;

      for (int i = 0; i < pendientes.length; i += tamanioLote) {
        if (!mounted || token != _hidratacionToken) break;

        final lote = pendientes.skip(i).take(tamanioLote).toList();
        for (final v in lote) {
          _idsHidratando.add(v.id);
        }

        final resultados = await Future.wait(
          lote.map((v) async {
            try {
              return MapEntry(v.id, await _infoVenta(v));
            } catch (_) {
              return MapEntry(v.id, _infoFallback(v));
            }
          }),
        );

        if (!mounted || token != _hidratacionToken) break;

        for (final r in resultados) {
          _idsHidratando.remove(r.key);
          _infoCache[r.key] = r.value;
        }

        if (mounted) setState(() {});
      }

      if (token == _hidratacionToken) {
        _hidratandoInfo = false;
      }
    });
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

    final mes = (f.month >= 1 && f.month <= 12)
        ? _mesesLargos[f.month - 1]
        : '';
    return '${f.day} de $mes';
  }

  String _textoNota(String? nota) {
    return TextoNormalizado.normalizarNota(nota);
  }

  String _limpiarValorCampo(String valor) {
    var out = valor.trim();

    for (final sep in const ['|', ';', '\u2022', '\u00B7']) {
      final idx = out.indexOf(sep);
      if (idx >= 0) out = out.substring(0, idx).trim();
    }

    final lower = out.toLowerCase();
    for (final marker in const [
      'nota:',
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

  String _clienteDesdeNota(String? nota) {
    final t = _textoNota(nota);
    final m = RegExp(
      r'cliente\s*:?\s*(.+?)(?=(?:\n|\||;|nota\s*:|pago\s*:|medio\s*de\s*pago\s*:|estado\s*pago\s*:|cargo\s*por\s*(?:envio|envo)|cargo\s*(?:envio|envo)|(?:envio|envo)\s*:|costo\s*estimado|margen\s*estimado|reintegro\s*:|$))',
      caseSensitive: false,
    ).firstMatch(t);
    final v = (m?.group(1) ?? '').trim();
    return _normalizarNombreCliente(_limpiarValorCampo(v));
  }

  String _notaPedidoDesdeNota(String? nota) {
    final t = _textoNota(nota);
    final m = RegExp(
      r'nota\s*:?\s*(.+?)(?=(?:\n|\||;|pago\s*:|medio\s*de\s*pago\s*:|estado\s*pago\s*:|cargo\s*por\s*(?:envio|envo)|cargo\s*(?:envio|envo)|(?:envio|envo)\s*:|costo\s*estimado|margen\s*estimado|reintegro\s*:|$))',
      caseSensitive: false,
    ).firstMatch(t);
    final v = (m?.group(1) ?? '').trim();
    return _normalizarNombreCliente(_limpiarValorCampo(v));
  }

  int? _pedidoIdDesdeNotaVenta(String? nota) {
    final t = _textoNota(nota);
    final m = RegExp(
      r'pedido\s*#?\s*:?\s*(\d+)',
      caseSensitive: false,
    ).firstMatch(t);
    final raw = m?.group(1);
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  Future<_VentaItemInfo> _infoVenta(Venta v) async {
    String titulo = 'Venta';
    String? imagen;
    double subtotal = 0.0;
    String? notaPedidoFallback;

    try {
      final lineas = await Proveedores.ventasRepositorio.listarLineas(v.id);
      for (final l in lineas) {
        subtotal += l.subtotal;
      }
      if (lineas.isNotEmpty) {
        final primera = lineas.first;
        final combo = await Proveedores.combosRepositorio.obtenerCombo(
          primera.comboId,
        );
        if (combo != null) {
          final n = combo.nombre.trim();
          titulo = n.isEmpty ? 'Venta' : n;

          final comps = await Proveedores.combosRepositorio.listarComponentes(
            combo.id,
          );
          if (comps.isNotEmpty) {
            final prod = await Proveedores.inventarioRepositorio
                .obtenerProducto(comps.first.productoId);
            final ruta = (prod?.imagen ?? '').trim();
            if (ruta.isNotEmpty && File(ruta).existsSync()) {
              imagen = ruta;
            }
          }
        } else if (primera.productoId != null) {
          final prod = await Proveedores.inventarioRepositorio.obtenerProducto(
            primera.productoId!,
          );
          final n = (prod?.nombreConVariante ?? '').trim();
          if (n.isNotEmpty) titulo = n;

          final ruta = (prod?.imagen ?? '').trim();
          if (ruta.isNotEmpty && File(ruta).existsSync()) {
            imagen = ruta;
          }
        }
      }

      if (_notaPedidoDesdeNota(v.nota).trim().isEmpty) {
        final pedido = await Proveedores.pedidosRepositorio
            .obtenerPedidoPorVentaId(v.id);
        var notaPedido = (pedido?.nota ?? '').trim();
        if (notaPedido.isEmpty) {
          final pedidoId = _pedidoIdDesdeNotaVenta(v.nota);
          if (pedidoId != null) {
            final pedidoPorId = await Proveedores.pedidosRepositorio
                .obtenerPedido(pedidoId);
            notaPedido = (pedidoPorId?.nota ?? '').trim();
          }
        }
        if (notaPedido.isNotEmpty) notaPedidoFallback = notaPedido;
      }
    } catch (_) {
      subtotal = v.total;
    }

    return _VentaItemInfo(
      titulo: titulo,
      imagenRuta: imagen,
      subtotal: subtotal,
      notaPedidoFallback: notaPedidoFallback,
    );
  }

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

  Widget _filaVenta({
    required bool ancha,
    required Venta v,
    required _VentaItemInfo info,
    required bool seleccionada,
  }) {
    final cancelada = (v.nota ?? '').contains('VENTA CANCELADA');
    final cliente = _clienteDesdeNota(v.nota);
    final notaExtraida = _notaPedidoDesdeNota(v.nota);
    final notaFallback = _normalizarNombreCliente(
      _limpiarValorCampo((info.notaPedidoFallback ?? '').trim()),
    );
    final notaPedido = notaExtraida.trim().isNotEmpty
        ? notaExtraida
        : notaFallback;
    final clienteYNota = () {
      final c = cliente.trim();
      final n = notaPedido.trim();
      if (c.isNotEmpty && n.isNotEmpty) return '$c - $n';
      if (c.isNotEmpty) return c;
      if (n.isNotEmpty) return n;
      return '';
    }();
    final titulo = info.titulo;
    final ruta = info.imagenRuta;
    final subtotal = info.subtotal;

    final cs = Theme.of(context).colorScheme;

    return FilaListaModulo(
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
      selected: seleccionada,
      leading: _avatarVenta(ruta, cancelada: cancelada),
      title: Text(
        titulo,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: cancelada ? cs.onSurfaceVariant : null,
        ),
      ),
      subtitle: Text(
        clienteYNota.isEmpty ? '-' : clienteYNota,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$_moneda ${subtotal.toStringAsFixed(2)}',
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
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

  Widget _listaVentas({required bool ancha, required List<Venta> ventas}) {
    final filtradas = _filtrarVentas(ventas);

    if (filtradas.isEmpty) {
      return Expanded(
        child: EstadoListaVacia(
          titulo: _q.isEmpty ? 'Todavia no hay ventas' : 'Sin resultados',
          icono: Icons.receipt_long_outlined,
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
          final info = _infoCache[v.id] ?? _infoFallback(v);

          return _filaVenta(
            ancha: ancha,
            v: v,
            info: info,
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
          padding: TabletMasterDetailLayout.kPagePadding,
          child: FutureBuilder<List<Venta>>(
            future: _datosFuture,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return Column(
                  children: [
                    PanelControlesModulo(
                      child: Column(
                        children: [
                          if (_mostrarBotonNuevaVenta) _botonNuevaVenta(),
                          if (_mostrarBotonNuevaVenta)
                            const SizedBox(height: 10),
                          _buscador(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Expanded(
                      child: EstadoListaCargando(mensaje: 'Cargando ventas...'),
                    ),
                  ],
                );
              }

              if (snap.hasError) {
                return Center(
                  child: EstadoListaError(
                    mensaje: 'No se pudieron cargar las ventas',
                    alReintentar: () {
                      setState(() {
                        _cancelarHidratacion();
                        _datosFuture = _cargar();
                      });
                    },
                  ),
                );
              }

              final ventas = snap.data ?? const <Venta>[];
              _programarHidratacionInfo(ventas);
              final idValida =
                  _seleccionadaId != null &&
                  ventas.any((v) => v.id == _seleccionadaId);
              final idActual = idValida ? _seleccionadaId : null;
              if (!idValida && _seleccionadaId != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (_seleccionadaId != null &&
                      !ventas.any((v) => v.id == _seleccionadaId)) {
                    setState(() => _seleccionadaId = null);
                  }
                });
              }

              Widget panelLista() {
                return Column(
                  children: [
                    PanelControlesModulo(
                      child: Column(
                        children: [
                          if (_mostrarBotonNuevaVenta) _botonNuevaVenta(),
                          if (_mostrarBotonNuevaVenta)
                            const SizedBox(height: 10),
                          _buscador(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _listaVentas(ancha: ancha, ventas: ventas),
                  ],
                );
              }

              if (!ancha) return panelLista();

              final id = idActual;

              return TabletMasterDetailLayout(
                master: panelLista(),
                detail: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: id == null
                        ? const Center(
                            child: Text(
                              'Selecciona una venta para ver detalles',
                            ),
                          )
                        : VentaDetallePantalla(
                            ventaId: id,
                            embebido: true,
                            alCambiarAlgo: () {
                              setState(() {
                                _cancelarHidratacion();
                                _infoCache.clear();
                                _datosFuture = _cargar();
                              });
                            },
                          ),
                  ),
                ),
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
  final double subtotal;
  final String? notaPedidoFallback;

  const _VentaItemInfo({
    required this.titulo,
    required this.imagenRuta,
    required this.subtotal,
    required this.notaPedidoFallback,
  });
}

enum _RowKind { header, venta }

class _RowItem {
  final _RowKind kind;
  final String? headerText;
  final Venta? venta;

  _RowItem.header(this.headerText) : kind = _RowKind.header, venta = null;

  _RowItem.venta(this.venta) : kind = _RowKind.venta, headerText = null;
}
