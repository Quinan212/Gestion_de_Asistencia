import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gestion_de_stock/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_stock/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_stock/modulos/compras/modelos/compra.dart';
import 'package:gestion_de_stock/modulos/compras/pantallas/compra_detalle_pantalla.dart';
import 'package:gestion_de_stock/modulos/compras/pantallas/compra_nueva_pantalla.dart';

class ComprasPantalla extends StatefulWidget {
  const ComprasPantalla({super.key});

  @override
  State<ComprasPantalla> createState() => _ComprasPantallaState();
}

class _ComprasPantallaState extends State<ComprasPantalla> {
  static const double _kTablet = 900;

  String _moneda = r'$';
  int? _seleccionadaId;
  int _refreshTick = 0;

  @override
  void initState() {
    super.initState();
    _cargarMoneda();
  }

  Future<void> _cargarMoneda() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _moneda = prefs.getString('config_moneda') ?? r'$');
  }

  Future<List<Compra>> _cargar() => Proveedores.comprasRepositorio.listarCompras();

  Future<void> _nuevaCompra() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CompraNuevaPantalla()),
    );
    if (!mounted) return;
    setState(() => _refreshTick++);
  }

  bool _esAncha(BoxConstraints c) => c.maxWidth >= _kTablet;

  // -------- fecha --------

  String _hora24(DateTime f) {
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${d2(f.hour)}:${d2(f.minute)} hs';
  }

  // -------- info (sin FutureBuilder por fila: evita saltos) --------

  Future<Map<int, _CompraItemInfo>> _armarInfoMap(List<Compra> compras) async {
    final out = <int, _CompraItemInfo>{};

    for (final c in compras) {
      String titulo = 'Compra';
      String subtitulo = (c.proveedor ?? '').trim();
      if (subtitulo.isEmpty) subtitulo = '-';

      try {
        final lineas = await Proveedores.comprasRepositorio.listarLineas(c.id);

        if (lineas.length == 1) {
          final l = lineas.first;
          final prod = await Proveedores.inventarioRepositorio.obtenerProducto(l.productoId);
          final nombre = (prod?.nombre ?? '').trim();
          titulo = nombre.isEmpty ? 'Compra' : nombre;
        } else if (lineas.length > 1) {
          titulo = 'Paquete de productos';
        } else {
          titulo = 'Compra';
        }
      } catch (_) {
        // deja defaults
      }

      final cancelada = (c.nota ?? '').contains('COMPRA CANCELADA');

      out[c.id] = _CompraItemInfo(
        titulo: titulo,
        subtitulo: subtitulo,
        cancelada: cancelada,
      );
    }

    return out;
  }

  Widget _botonNuevaCompra() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _nuevaCompra,
        icon: const Icon(Icons.add),
        label: const Text('Nueva compra'),
      ),
    );
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
    final bgSel = cs.primary.withValues(alpha: 0.08);

    final cancelada = info.cancelada;

    return InkWell(
      onTap: () {
        if (ancha) {
          setState(() => _seleccionadaId = c.id);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CompraDetallePantalla(compraId: c.id)),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        color: seleccionada ? bgSel : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: cs.surfaceContainerHighest,
              child: Icon(
                cancelada ? Icons.block : Icons.shopping_cart_checkout_outlined,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                  const SizedBox(height: 2),
                  Text(
                    info.subtitulo.isEmpty ? '-' : info.subtitulo,
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
                  Formatos.dinero(_moneda, c.total),
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
  }

  Widget _listaCompras({
    required bool ancha,
    required List<Compra> compras,
    required Map<int, _CompraItemInfo> infoPorCompraId,
  }) {
    if (compras.isEmpty) {
      return Expanded(
        child: Center(
          child: Text('Todavía no hay compras', style: Theme.of(context).textTheme.bodyLarge),
        ),
      );
    }

    final ordenadas = [...compras]..sort((a, b) => b.fecha.compareTo(a.fecha));

    return Expanded(
      child: ListView.separated(
        itemCount: ordenadas.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final c = ordenadas[i];
          final info = infoPorCompraId[c.id] ??
              _CompraItemInfo(
                titulo: 'Compra',
                subtitulo: ((c.proveedor ?? '').trim().isEmpty ? '-' : (c.proveedor ?? '').trim()),
                cancelada: (c.nota ?? '').contains('COMPRA CANCELADA'),
              );
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
          padding: const EdgeInsets.all(12),
          child: FutureBuilder<List<Compra>>(
            future: _cargar(),
            key: ValueKey('compras_future_$_refreshTick'),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              final compras = snap.data ?? [];

              if (ancha && _seleccionadaId == null && compras.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (_seleccionadaId == null && compras.isNotEmpty) {
                    setState(() => _seleccionadaId = compras.first.id);
                  }
                });
              }

              return FutureBuilder<Map<int, _CompraItemInfo>>(
                future: _armarInfoMap(compras),
                key: ValueKey('compras_info_$_refreshTick${compras.length}'),
                builder: (context, snapInfo) {
                  // clave: no pintamos filas “a medias”; esperamos el map y listo (sin saltos)
                  if (snapInfo.connectionState != ConnectionState.done) {
                    return Column(
                      children: [
                        _botonNuevaCompra(),
                        const SizedBox(height: 10),
                        const Expanded(child: Center(child: CircularProgressIndicator())),
                      ],
                    );
                  }

                  final infoPorId = snapInfo.data ?? const <int, _CompraItemInfo>{};

                  Widget panelLista() {
                    return Column(
                      children: [
                        _botonNuevaCompra(),
                        const SizedBox(height: 10),
                        _listaCompras(ancha: ancha, compras: compras, infoPorCompraId: infoPorId),
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
                                ? const Center(child: Text('Elegí una compra'))
                                : CompraDetallePantalla(
                              compraId: id,
                              embebido: true,
                              alCambiarAlgo: () => setState(() => _refreshTick++),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
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

  const _CompraItemInfo({
    required this.titulo,
    required this.subtitulo,
    required this.cancelada,
  });
}