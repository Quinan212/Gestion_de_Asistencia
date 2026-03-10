import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gestion_de_asistencias/aplicacion/utiles/filtros_persistidos.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/layout_app.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/estado_lista.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/fila_lista_modulo.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/panel_controles_modulo.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/tablet_master_detail_layout.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/compras/modelos/compra.dart';
import 'package:gestion_de_asistencias/modulos/compras/pantallas/compra_detalle_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/compras/pantallas/compra_nueva_pantalla.dart';

class ComprasPantalla extends StatefulWidget {
  const ComprasPantalla({super.key});

  @override
  State<ComprasPantalla> createState() => _ComprasPantallaState();
}

class _ComprasPantallaState extends State<ComprasPantalla> {
  static const double _kTablet = LayoutApp.kTablet;
  static const String _kBusquedaKey = 'compras_busqueda_v1';

  String _moneda = r'$';
  int? _seleccionadaId;
  bool _creandoNuevaCompra = false;

  final _buscarCtrl = TextEditingController();
  String _q = '';

  final Map<int, _CompraItemInfo> _infoCache = {};
  late Future<List<Compra>> _datosFuture;
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

  Future<List<Compra>> _cargar() =>
      Proveedores.comprasRepositorio.listarCompras();

  Future<void> _nuevaCompra() async {
    final w = MediaQuery.of(context).size.width;
    if (w >= _kTablet) {
      setState(() => _creandoNuevaCompra = true);
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CompraNuevaPantalla()),
    );
    if (!mounted) return;
    setState(() {
      _cancelarHidratacion();
      _infoCache.clear();
      _datosFuture = _cargar();
    });
  }

  void _onCompraCreada(int id) {
    if (!mounted) return;
    setState(() {
      _creandoNuevaCompra = false;
      _seleccionadaId = id;
      _cancelarHidratacion();
      _infoCache.clear();
      _datosFuture = _cargar();
    });
  }

  void _cancelarNuevaCompra() {
    if (!mounted) return;
    setState(() => _creandoNuevaCompra = false);
  }

  bool _esAncha(BoxConstraints c) => c.maxWidth >= _kTablet;

  String _hora24(DateTime f) {
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${d2(f.hour)}:${d2(f.minute)} hs';
  }

  void _cancelarHidratacion() {
    _hidratacionToken++;
    _hidratandoInfo = false;
    _idsHidratando.clear();
  }

  _CompraItemInfo _infoFallback(Compra c) {
    return _CompraItemInfo(
      titulo: 'Compra',
      subtitulo: ((c.proveedor ?? '').trim().isEmpty
          ? '-'
          : (c.proveedor ?? '').trim()),
      cancelada: (c.nota ?? '').contains('COMPRA CANCELADA'),
      subtotal: c.total,
    );
  }

  void _programarHidratacionInfo(List<Compra> compras) {
    if (_hidratandoInfo) return;

    final pendientes = compras.where((c) {
      return !_infoCache.containsKey(c.id) && !_idsHidratando.contains(c.id);
    }).toList();
    if (pendientes.isEmpty) return;

    _hidratandoInfo = true;
    final token = ++_hidratacionToken;

    Future<void>(() async {
      const tamanioLote = 6;

      for (int i = 0; i < pendientes.length; i += tamanioLote) {
        if (!mounted || token != _hidratacionToken) break;

        final lote = pendientes.skip(i).take(tamanioLote).toList();
        for (final c in lote) {
          _idsHidratando.add(c.id);
        }

        final resultados = await Future.wait(
          lote.map((c) async {
            try {
              return MapEntry(c.id, await _calcularInfoCompra(c));
            } catch (_) {
              return MapEntry(c.id, _infoFallback(c));
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

  Future<_CompraItemInfo> _calcularInfoCompra(Compra c) async {
    String titulo = 'Compra';
    String subtitulo = (c.proveedor ?? '').trim();
    if (subtitulo.isEmpty) subtitulo = '-';
    double subtotal = 0.0;

    try {
      final lineas = await Proveedores.comprasRepositorio.listarLineas(c.id);
      for (final l in lineas) {
        subtotal += l.subtotal;
      }

      if (lineas.length == 1) {
        final l = lineas.first;
        final prod = await Proveedores.inventarioRepositorio.obtenerProducto(
          l.productoId,
        );
        final nombre = (prod?.nombreConVariante ?? '').trim();
        titulo = nombre.isEmpty ? 'Compra' : nombre;
      } else if (lineas.length > 1) {
        titulo = 'Paquete de productos';
      }
    } catch (_) {
      subtotal = c.total;
    }

    final cancelada = (c.nota ?? '').contains('COMPRA CANCELADA');
    return _CompraItemInfo(
      titulo: titulo,
      subtitulo: subtitulo,
      cancelada: cancelada,
      subtotal: subtotal,
    );
  }

  Widget _botonNuevaCompra() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _nuevaCompra,
        icon: const Icon(Icons.add),
        label: Text(
          _creandoNuevaCompra ? 'Editando nueva compra' : 'Nueva compra',
        ),
      ),
    );
  }

  Widget _buscador() {
    return TextField(
      controller: _buscarCtrl,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Buscar compra',
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

  List<Compra> _filtrarCompras(List<Compra> compras) {
    final q = _q.trim().toLowerCase();
    if (q.isEmpty) return compras;

    return compras.where((c) {
      final info = _infoCache[c.id];
      final titulo = (info?.titulo ?? '').toLowerCase();
      final subtitulo = (info?.subtitulo ?? '').toLowerCase();
      final proveedor = (c.proveedor ?? '').toLowerCase();
      final nota = (c.nota ?? '').toLowerCase();

      return titulo.contains(q) ||
          subtitulo.contains(q) ||
          proveedor.contains(q) ||
          nota.contains(q);
    }).toList();
  }

  Widget _badgeCancelada() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.error.withValues(alpha: 0.10),
        border: Border.all(color: cs.error.withValues(alpha: 0.22)),
      ),
      child: Text(
        'CANCELADA',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: cs.error,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _filaCompra({
    required bool ancha,
    required Compra c,
    required _CompraItemInfo info,
    required bool seleccionada,
  }) {
    final cs = Theme.of(context).colorScheme;

    final cancelada = info.cancelada;

    return FilaListaModulo(
      onTap: () {
        if (ancha) {
          setState(() {
            _creandoNuevaCompra = false;
            _seleccionadaId = c.id;
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CompraDetallePantalla(compraId: c.id),
            ),
          );
        }
      },
      selected: seleccionada,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: cs.surfaceContainerHighest,
        child: Icon(
          cancelada ? Icons.block : Icons.shopping_cart_checkout_outlined,
          color: cs.onSurfaceVariant,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              info.titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cancelada ? cs.onSurfaceVariant : null,
              ),
            ),
          ),
          if (cancelada) _badgeCancelada(),
        ],
      ),
      subtitle: Text(
        info.subtitulo.isEmpty ? '-' : info.subtitulo,
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
            Formatos.dinero(_moneda, info.subtotal),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cancelada ? cs.onSurfaceVariant : null,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _hora24(c.fecha),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _listaCompras({required bool ancha, required List<Compra> compras}) {
    final filtradas = _filtrarCompras(compras);

    if (filtradas.isEmpty) {
      return Expanded(
        child: EstadoListaVacia(
          titulo: _q.isEmpty ? 'Todavia no hay compras' : 'Sin resultados',
          icono: Icons.shopping_cart_checkout_outlined,
        ),
      );
    }

    final ordenadas = [...filtradas]
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    return Expanded(
      child: ListView.separated(
        itemCount: ordenadas.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final c = ordenadas[i];
          final info = _infoCache[c.id] ?? _infoFallback(c);
          final seleccionada = ancha && _seleccionadaId == c.id;

          return _filaCompra(
            ancha: ancha,
            c: c,
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
          child: FutureBuilder<List<Compra>>(
            future: _datosFuture,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return Column(
                  children: [
                    PanelControlesModulo(
                      child: Column(
                        children: [
                          _botonNuevaCompra(),
                          const SizedBox(height: 10),
                          _buscador(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Expanded(
                      child: EstadoListaCargando(
                        mensaje: 'Cargando compras...',
                      ),
                    ),
                  ],
                );
              }

              if (snap.hasError) {
                return Center(
                  child: EstadoListaError(
                    mensaje: 'No se pudieron cargar las compras',
                    alReintentar: () {
                      setState(() {
                        _cancelarHidratacion();
                        _datosFuture = _cargar();
                      });
                    },
                  ),
                );
              }

              final compras = snap.data ?? const <Compra>[];
              _programarHidratacionInfo(compras);
              final idValida =
                  _seleccionadaId != null &&
                  compras.any((c) => c.id == _seleccionadaId);
              final idActual = idValida ? _seleccionadaId : null;
              if (!idValida && _seleccionadaId != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (_seleccionadaId != null &&
                      !compras.any((c) => c.id == _seleccionadaId)) {
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
                          _botonNuevaCompra(),
                          const SizedBox(height: 10),
                          _buscador(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _listaCompras(ancha: ancha, compras: compras),
                  ],
                );
              }

              if (!ancha) return panelLista();

              final id = idActual;

              return TabletMasterDetailLayout(
                master: panelLista(),
                detail: Card(
                  clipBehavior: Clip.antiAlias,
                  child: _creandoNuevaCompra
                      ? CompraNuevaPantalla(
                          embebido: true,
                          onCreada: _onCompraCreada,
                          onCancelar: _cancelarNuevaCompra,
                        )
                      : Padding(
                          padding: const EdgeInsets.all(12),
                          child: id == null
                              ? const Center(
                                  child: Text(
                                    'Selecciona una compra para ver detalles',
                                  ),
                                )
                              : CompraDetallePantalla(
                                  compraId: id,
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

class _CompraItemInfo {
  final String titulo;
  final String subtitulo;
  final bool cancelada;
  final double subtotal;

  const _CompraItemInfo({
    required this.titulo,
    required this.subtitulo,
    required this.cancelada,
    required this.subtotal,
  });
}
