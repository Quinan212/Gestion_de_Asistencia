// lib/modulos/inventario/pantallas/inventario_pantalla.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gestion_de_asistencias/aplicacion/utiles/filtros_persistidos.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/estado_lista.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/tablet_master_detail_layout.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/infraestructura/servicios/fotos_producto.dart';
import 'package:gestion_de_asistencias/modulos/inventario/logica/inventario_controlador.dart';
import 'package:gestion_de_asistencias/modulos/inventario/logica/inventario_estado.dart';
import 'package:gestion_de_asistencias/modulos/inventario/modelos/movimiento.dart';
import 'package:gestion_de_asistencias/modulos/inventario/modelos/producto.dart';
import 'package:gestion_de_asistencias/modulos/inventario/widgets/filtro_inventario.dart';
import 'package:gestion_de_asistencias/modulos/inventario/widgets/producto_tarjeta.dart';
import 'producto_detalle_pantalla.dart';

// ---------- Helpers globales (plural + mayuscula) ----------
String _capPrimera(String s) {
  final t = s.trim();
  if (t.isEmpty) return t;
  if (t.length == 1) return t.toUpperCase();
  return '${t[0].toUpperCase()}${t.substring(1)}';
}

String _unidadConCantidad(
  String unidad,
  double cantidad, {
  bool capitalizar = true,
}) {
  final u0 = unidad.trim();
  if (u0.isEmpty) return '';

  final low = u0.toLowerCase();
  final esUno = (cantidad - 1).abs() < 0.0000001;

  final yaPlural = low.endsWith('s') || low.endsWith('es');
  if (esUno || yaPlural) return capitalizar ? _capPrimera(u0) : u0;

  String plural;
  if (low == 'unidad') {
    plural = 'unidades';
  } else if (low == 'pack') {
    plural = 'packs';
  } else if (low == 'caja') {
    plural = 'cajas';
  } else {
    final ultima = low.substring(low.length - 1);
    const vocales = {'a', 'e', 'i', 'o', 'u'};
    plural = vocales.contains(ultima) ? '${u0}s' : '${u0}es';
  }

  return capitalizar ? _capPrimera(plural) : plural;
}

class InventarioPantalla extends StatefulWidget {
  const InventarioPantalla({super.key});

  @override
  State<InventarioPantalla> createState() => _InventarioPantallaState();
}

class _InventarioPantallaState extends State<InventarioPantalla> {
  late final InventarioControlador _controlador;
  late final VoidCallback _datosVersionListener;

  int _vista = 0; // 0: lista, 1: cuadricula
  static const _prefVistaKey = 'inventario_vista'; // 0 o 1
  static const _prefFiltroKey = 'inventario_filtro_v1';
  static const _prefMostrarInactivosKey = 'inventario_mostrar_inactivos_v1';

  int? _seleccionadoId; // tablet master-detail
  bool _creandoNuevoProducto = false;

  @override
  void initState() {
    super.initState();
    _controlador = InventarioControlador();
    _controlador.cargar();
    _datosVersionListener = () => _controlador.cargar();
    Proveedores.datosVersion.addListener(_datosVersionListener);
    _restaurarPreferenciasUI();
  }

  Future<void> _restaurarPreferenciasUI() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_prefVistaKey) ?? 0;
    final filtro = await FiltrosPersistidos.leerTexto(_prefFiltroKey);
    final mostrarInactivos = await FiltrosPersistidos.leerBool(
      _prefMostrarInactivosKey,
    );
    if (!mounted) return;
    setState(() => _vista = (v == 1) ? 1 : 0);
    _controlador.cambiarFiltro(filtro);
    if (mostrarInactivos != _controlador.estado.mostrarInactivos) {
      _controlador.cambiarMostrarInactivos(mostrarInactivos);
    }
  }

  Future<void> _guardarVista(int v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefVistaKey, v);
  }

  void _onCambiarFiltro(String texto) {
    _controlador.cambiarFiltro(texto);
    FiltrosPersistidos.guardarTexto(_prefFiltroKey, texto);
  }

  void _onCambiarMostrarInactivos(bool value) {
    _controlador.cambiarMostrarInactivos(value);
    FiltrosPersistidos.guardarBool(_prefMostrarInactivosKey, value);
  }

  @override
  void dispose() {
    Proveedores.datosVersion.removeListener(_datosVersionListener);
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _nuevoProductoCompleto() async {
    final w = MediaQuery.of(context).size.width;
    if (w >= 900) {
      setState(() => _creandoNuevoProducto = true);
      return;
    }

    final id = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) {
        final h = MediaQuery.of(ctx).size.height;
        final maxH = (h * 0.68).clamp(320.0, 620.0);

        return Align(
          alignment: Alignment.bottomCenter,
          widthFactor: 1,
          heightFactor: 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 640, maxHeight: maxH),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Material(
                  color: Theme.of(ctx).colorScheme.surface,
                  child: const _ProductoNuevoSheet(),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    await _controlador.cargar();
    if (!mounted) return;

    if (id != null) {
      final w2 = MediaQuery.of(context).size.width;
      if (w2 >= 900) {
        setState(() => _seleccionadoId = id);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductoDetallePantalla(productoId: id),
          ),
        );
      }
    }
  }

  void _tocarProducto(int id) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 900) {
      setState(() {
        _creandoNuevoProducto = false;
        _seleccionadoId = id;
      });
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductoDetallePantalla(productoId: id),
      ),
    );
  }

  Widget _cabecera(InventarioEstado estado) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary.withValues(alpha: 0.08), Colors.transparent],
        ),
      ),
      child: Card(
        color: cs.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _nuevoProductoCompleto,
                  icon: const Icon(Icons.add),
                  label: Text(
                    _creandoNuevoProducto
                        ? 'Editando nuevo producto'
                        : 'Nuevo producto',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FiltroInventario(
                valor: estado.filtro,
                alCambiar: _onCambiarFiltro,
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mostrar inactivos'),
                value: estado.mostrarInactivos,
                onChanged: _onCambiarMostrarInactivos,
              ),
              const SizedBox(height: 10),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Lista')),
                  ButtonSegment(value: 1, label: Text('Cuadricula')),
                ],
                selected: {_vista},
                onSelectionChanged: (s) async {
                  final v = s.first;
                  setState(() => _vista = v);
                  await _guardarVista(v);
                },
              ),
              const SizedBox(height: 12),
              if (estado.error != null) ...[
                Text(estado.error!, style: TextStyle(color: cs.error)),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controlador,
      builder: (context, _) {
        final estado = _controlador.estado;

        if (estado.cargando) {
          return const Padding(
            padding: TabletMasterDetailLayout.kPagePadding,
            child: EstadoListaCargando(mensaje: 'Cargando inventario...'),
          );
        }

        if (estado.error != null && estado.productos.isEmpty) {
          return Padding(
            padding: TabletMasterDetailLayout.kPagePadding,
            child: EstadoListaError(
              mensaje: estado.error!,
              alReintentar: () {
                _controlador.cargar();
              },
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final esTabletDetalle = w >= 900;

            Widget lista({required bool conPadding}) {
              final contenido = CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _cabecera(estado)),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (_vista == 0)
                    _ListaProductosSliver(
                      controlador: _controlador,
                      alTocar: _tocarProducto,
                    )
                  else
                    _GridProductosSliver(
                      controlador: _controlador,
                      alTocar: _tocarProducto,
                    ),
                ],
              );
              if (!conPadding) return contenido;
              return Padding(
                padding: TabletMasterDetailLayout.kPagePadding,
                child: contenido,
              );
            }

            if (!esTabletDetalle) return lista(conPadding: true);

            return Padding(
              padding: TabletMasterDetailLayout.kPagePadding,
              child: TabletMasterDetailLayout(
                master: lista(conPadding: false),
                detail: Card(
                  clipBehavior: Clip.antiAlias,
                  child: _creandoNuevoProducto
                      ? _ProductoNuevoSheet(
                          embebido: true,
                          onCreado: (id) async {
                            await _controlador.cargar();
                            if (!mounted) return;
                            setState(() {
                              _creandoNuevoProducto = false;
                              _seleccionadoId = id;
                            });
                          },
                          onCancelar: () {
                            if (!mounted) return;
                            setState(() => _creandoNuevoProducto = false);
                          },
                        )
                      : SizedBox.expand(
                          child: _PanelDetalleProducto(
                            productoId: _seleccionadoId,
                            alAbrirDetalle: (id) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductoDetallePantalla(productoId: id),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ListaProductosSliver extends StatelessWidget {
  final InventarioControlador controlador;
  final void Function(int productoId) alTocar;

  const _ListaProductosSliver({
    required this.controlador,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    final productos = controlador.productosFiltrados();

    if (productos.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: EstadoListaVacia(
          titulo: 'Sin productos',
          icono: Icons.inventory_2_outlined,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final p = productos[index];
        final stock = controlador.stockDe(p.id);

        return ProductoTarjeta(
          producto: p,
          stock: stock,
          alTocar: () => alTocar(p.id),
        );
      }, childCount: productos.length),
    );
  }
}

class _GridProductosSliver extends StatelessWidget {
  final InventarioControlador controlador;
  final void Function(int productoId) alTocar;

  const _GridProductosSliver({
    required this.controlador,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    final productos = controlador.productosFiltrados();

    if (productos.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: EstadoListaVacia(
          titulo: 'Sin productos',
          icono: Icons.grid_view_rounded,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 12),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.crossAxisExtent;
          final crossAxisCount = w >= 900
              ? 5
              : w >= 700
              ? 4
              : w >= 520
              ? 3
              : 2;

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate((context, i) {
              final p = productos[i];
              final stock = controlador.stockDe(p.id);

              return _ProductoCuadro(
                producto: p,
                stock: stock,
                alTocar: () => alTocar(p.id),
              );
            }, childCount: productos.length),
          );
        },
      ),
    );
  }
}

class _ProductoCuadro extends StatelessWidget {
  final Producto producto;
  final double stock;
  final VoidCallback alTocar;

  const _ProductoCuadro({
    required this.producto,
    required this.stock,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final enFalta = stock < producto.stockMinimo;
    final colorEstado = !producto.activo
        ? theme.colorScheme.onSurfaceVariant
        : (enFalta ? theme.colorScheme.error : theme.colorScheme.primary);
    final textoEstado = !producto.activo
        ? 'Inactivo'
        : (enFalta ? 'Bajo minimo' : 'OK');

    final ruta = (producto.imagen ?? '').trim();
    final tieneImagen = ruta.isNotEmpty && File(ruta).existsSync();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: alTocar,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: tieneImagen
                            ? Image.file(File(ruta), fit: BoxFit.cover)
                            : Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 42,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: colorEstado.withValues(alpha: 0.14),
                          border: Border.all(
                            color: colorEstado.withValues(alpha: 0.26),
                          ),
                        ),
                        child: Text(
                          textoEstado,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorEstado,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombreConVariante,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${Formatos.cantidad(stock, unidad: producto.unidad)} ${_unidadConCantidad(producto.unidad, stock)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorEstado,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanelDetalleProducto extends StatelessWidget {
  final int? productoId;
  final void Function(int id) alAbrirDetalle;

  const _PanelDetalleProducto({
    required this.productoId,
    required this.alAbrirDetalle,
  });

  Future<double> _stockVisibleDe(Producto p) async {
    final stockPropio = await Proveedores.inventarioRepositorio
        .calcularStockActual(p.id);
    if (p.productoPadreId != null) return stockPropio;

    final productos = await Proveedores.inventarioRepositorio.listarProductos(
      incluirInactivos: true,
    );
    final idsVariantes = productos
        .where((x) => x.productoPadreId == p.id)
        .map((x) => x.id)
        .toList();
    if (idsVariantes.isEmpty) return stockPropio;

    final stockVariantes = await Proveedores.inventarioRepositorio
        .calcularStockActualPorProductos(idsVariantes);

    double total = stockPropio;
    for (final id in idsVariantes) {
      total += stockVariantes[id] ?? 0.0;
    }
    return total;
  }

  Future<List<_VarianteItem>> _variantesConStock(int baseId) async {
    final productos = await Proveedores.inventarioRepositorio.listarProductos(
      incluirInactivos: true,
    );
    final variantes = productos
        .where((p) => p.productoPadreId == baseId)
        .toList();
    if (variantes.isEmpty) return const [];

    final stocks = await Proveedores.inventarioRepositorio
        .calcularStockActualPorProductos(variantes.map((e) => e.id).toList());
    return variantes
        .map((p) => _VarianteItem(producto: p, stock: stocks[p.id] ?? 0.0))
        .toList();
  }

  String _d2(int n) => n.toString().padLeft(2, '0');

  String _fecha(DateTime f) =>
      '${_d2(f.day)}/${_d2(f.month)}/${f.year} ${_d2(f.hour)}:${_d2(f.minute)}';

  String _textoTipo(String tipo) {
    switch (tipo) {
      case 'ingreso':
        return 'Ingreso';
      case 'egreso':
        return 'Egreso';
      case 'ajuste':
        return 'Ajuste';
      case 'devolucion':
        return 'Devolucion';
      default:
        return tipo;
    }
  }

  double _cantidadConSigno(Movimiento m) {
    if (m.tipo == 'egreso') return -m.cantidad;
    if (m.tipo == 'ingreso' || m.tipo == 'devolucion') return m.cantidad;
    return m.cantidad;
  }

  IconData _iconoTipo(String tipo) {
    switch (tipo) {
      case 'ingreso':
        return Icons.south_west_rounded;
      case 'egreso':
        return Icons.north_east_rounded;
      case 'devolucion':
        return Icons.assignment_return_rounded;
      case 'ajuste':
      default:
        return Icons.tune_rounded;
    }
  }

  Color _colorTipo(BuildContext context, String tipo) {
    final cs = Theme.of(context).colorScheme;
    switch (tipo) {
      case 'ingreso':
      case 'devolucion':
        return cs.primary;
      case 'egreso':
        return cs.error;
      case 'ajuste':
      default:
        return cs.secondary;
    }
  }

  Widget _datoPill(
    BuildContext context, {
    required IconData icono,
    required String texto,
    Color? color,
  }) {
    final cs = Theme.of(context).colorScheme;
    final fg = color ?? cs.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 15, color: fg),
          const SizedBox(width: 6),
          Text(
            texto,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (productoId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Elegi un producto para ver el detalle aca.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return FutureBuilder<Producto?>(
      future: Proveedores.inventarioRepositorio.obtenerProducto(productoId!),
      builder: (context, snapP) {
        if (snapP.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final p = snapP.data;
        if (p == null) {
          return const Center(child: Text('Producto no encontrado'));
        }

        return FutureBuilder<double>(
          future: _stockVisibleDe(p),
          builder: (context, snapS) {
            if (snapS.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final stock = snapS.data ?? 0.0;
            final enFalta = stock < p.stockMinimo;
            final colorStock = enFalta
                ? Theme.of(context).colorScheme.error
                : null;

            final ruta = (p.imagen ?? '').trim();
            final tieneImagen = ruta.isNotEmpty && File(ruta).existsSync();

            return FutureBuilder<List<Movimiento>>(
              future: Proveedores.inventarioRepositorio
                  .listarMovimientosDeProducto(p.id),
              builder: (context, snapM) {
                if (snapM.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final movs = (snapM.data ?? [])
                  ..sort((a, b) => b.fecha.compareTo(a.fecha));

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 260,
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                      child: tieneImagen
                                          ? Image.file(
                                              File(ruta),
                                              fit: BoxFit.cover,
                                            )
                                          : const Center(
                                              child: Icon(
                                                Icons.image_outlined,
                                                size: 48,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              p.nombreConVariante,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.tonalIcon(
                                onPressed: () => alAbrirDetalle(p.id),
                                icon: const Icon(Icons.open_in_new_rounded),
                                label: const Text('Mas detalles'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _datoPill(
                                  context,
                                  icono: Icons.straighten_rounded,
                                  texto: _capPrimera(p.unidad),
                                ),
                                _datoPill(
                                  context,
                                  icono: Icons.inventory_2_outlined,
                                  texto:
                                      '${Formatos.cantidad(stock, unidad: p.unidad)} ${_unidadConCantidad(p.unidad, stock)}',
                                  color: colorStock,
                                ),
                                _datoPill(
                                  context,
                                  icono: Icons.flag_outlined,
                                  texto:
                                      'Minimo ${Formatos.cantidad(p.stockMinimo, unidad: p.unidad)}',
                                ),
                                _datoPill(
                                  context,
                                  icono: Icons.local_shipping_outlined,
                                  texto: p.proveedor ?? '-',
                                ),
                              ],
                            ),
                            if (p.productoPadreId == null) ...[
                              const SizedBox(height: 12),
                              FutureBuilder<List<_VarianteItem>>(
                                future: _variantesConStock(p.id),
                                builder: (context, snapV) {
                                  if (snapV.connectionState !=
                                      ConnectionState.done) {
                                    return const LinearProgressIndicator();
                                  }
                                  final variantes =
                                      snapV.data ?? const <_VarianteItem>[];
                                  if (variantes.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Variantes (${variantes.length})',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          for (final item in variantes) ...[
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item
                                                        .producto
                                                        .nombreConVariante,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${Formatos.cantidad(item.stock, unidad: item.producto.unidad)} ${_unidadConCantidad(item.producto.unidad, item.stock)}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Movimientos',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${movs.length})',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    if (movs.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text('Todavia no hay movimientos'),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((context, i) {
                            final m = movs[i];
                            final v = _cantidadConSigno(m);
                            final tipoColor = _colorTipo(context, m.tipo);
                            final txt =
                                '${v >= 0 ? '+' : '-'}${Formatos.cantidad(v.abs(), unidad: p.unidad)} ${_unidadConCantidad(p.unidad, v.abs())}';
                            final cancelado = (m.nota ?? '').contains(
                              'CANCELADO',
                            );
                            final nota = (m.nota ?? '').trim();
                            final referencia = (m.referencia ?? '').trim();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Card(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerLow,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    10,
                                    12,
                                    10,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: tipoColor.withValues(
                                          alpha: 0.14,
                                        ),
                                        child: Icon(
                                          _iconoTipo(m.tipo),
                                          size: 18,
                                          color: tipoColor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _textoTipo(m.tipo),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: cancelado
                                                        ? Theme.of(
                                                            context,
                                                          ).disabledColor
                                                        : null,
                                                  ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _fecha(m.fecha),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                            if (nota.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Text(
                                                nota,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                              ),
                                            ],
                                            if (referencia.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                'Ref: $referencia',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        txt,
                                        textAlign: TextAlign.right,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: cancelado
                                                  ? Theme.of(
                                                      context,
                                                    ).disabledColor
                                                  : (v >= 0
                                                        ? Theme.of(
                                                            context,
                                                          ).colorScheme.primary
                                                        : Theme.of(
                                                            context,
                                                          ).colorScheme.error),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }, childCount: movs.length),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ProductoNuevoSheet extends StatefulWidget {
  final bool embebido;
  final ValueChanged<int>? onCreado;
  final VoidCallback? onCancelar;

  const _ProductoNuevoSheet({
    this.embebido = false,
    this.onCreado,
    this.onCancelar,
  });

  @override
  State<_ProductoNuevoSheet> createState() => _ProductoNuevoSheetState();
}

class _ProductoNuevoSheetState extends State<_ProductoNuevoSheet> {
  final _nombreCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _varianteCtrl = TextEditingController();
  final _subvarianteCtrl = TextEditingController();
  final _unidadCtrl = TextEditingController(text: 'unidad');
  final _minimoCtrl = TextEditingController(text: '0');
  final _stockInicialCtrl = TextEditingController(text: '0');
  final _precioCtrl = TextEditingController(text: '0');
  final _proveedorCtrl = TextEditingController();
  bool _crearComoVarianteSku = false;
  int? _productoPadreId;
  List<Producto> _productosExistentes = const [];
  bool _cargandoProductos = true;

  static const _unidadesOpciones = <String>[
    'unidad',
    'pack',
    'caja',
    'kg',
    'Otro',
  ];
  String _unidadSeleccion = 'unidad';
  bool _usarOtro = false;
  String? _fotoRutaSeleccionada;
  bool _cargandoFoto = false;

  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarProductosExistentes();
    _varianteCtrl.addListener(_onCambiosParaSku);
    _subvarianteCtrl.addListener(_onCambiosParaSku);
  }

  @override
  void dispose() {
    _varianteCtrl.removeListener(_onCambiosParaSku);
    _subvarianteCtrl.removeListener(_onCambiosParaSku);
    _nombreCtrl.dispose();
    _skuCtrl.dispose();
    _varianteCtrl.dispose();
    _subvarianteCtrl.dispose();
    _unidadCtrl.dispose();
    _minimoCtrl.dispose();
    _stockInicialCtrl.dispose();
    _precioCtrl.dispose();
    _proveedorCtrl.dispose();
    super.dispose();
  }

  void _onCambiosParaSku() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _cargarProductosExistentes() async {
    try {
      final productos = await Proveedores.inventarioRepositorio.listarProductos(
        incluirInactivos: true,
      );
      if (!mounted) return;
      setState(() {
        _productosExistentes = productos;
        _cargandoProductos = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _productosExistentes = const [];
        _cargandoProductos = false;
      });
    }
  }

  double _num(String t) =>
      double.tryParse(t.trim().replaceAll(',', '.')) ?? 0.0;

  Producto? get _productoPadreSeleccionado {
    final id = _productoPadreId;
    if (id == null) return null;
    for (final p in _productosExistentes) {
      if (p.id == id) return p;
    }
    return null;
  }

  String _tokenSku(String texto) {
    final t = texto
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return t;
  }

  String _skuSugerido({
    required String nombreBase,
    required String variante,
    required String subvariante,
    String? skuBase,
  }) {
    final partes = <String>[
      _tokenSku((skuBase ?? '').trim().isEmpty ? nombreBase : skuBase!),
      _tokenSku(variante),
      if (subvariante.trim().isNotEmpty) _tokenSku(subvariante),
    ].where((p) => p.trim().isNotEmpty).toList();

    return partes.join('-');
  }

  Future<void> _seleccionarFoto({required bool usarCamara}) async {
    if (_guardando || _cargandoFoto) return;
    setState(() {
      _error = null;
      _cargandoFoto = true;
    });

    try {
      final rutaNueva = await FotosProducto.elegirYGuardar(
        productoId: 0,
        usarCamara: usarCamara,
      );
      if (!mounted) return;

      if (rutaNueva != null && rutaNueva.trim().isNotEmpty) {
        final rutaVieja = _fotoRutaSeleccionada;
        setState(() => _fotoRutaSeleccionada = rutaNueva.trim());
        if (rutaVieja != null &&
            rutaVieja.trim().isNotEmpty &&
            rutaVieja != rutaNueva) {
          await FotosProducto.borrarSiExiste(rutaVieja);
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo cargar la foto');
    } finally {
      if (mounted) {
        setState(() => _cargandoFoto = false);
      }
    }
  }

  Future<void> _quitarFotoSeleccionada() async {
    final ruta = _fotoRutaSeleccionada;
    if (ruta == null || ruta.trim().isEmpty) return;
    setState(() => _fotoRutaSeleccionada = null);
    await FotosProducto.borrarSiExiste(ruta);
  }

  Future<void> _guardar() async {
    setState(() => _error = null);

    final nombreIngresado = _nombreCtrl.text.trim();
    final varianteIngresada = _varianteCtrl.text.trim();
    final subvarianteIngresada = _subvarianteCtrl.text.trim();
    final unidad = _unidadCtrl.text.trim();
    final padre = _productoPadreSeleccionado;

    String nombre;
    int? productoPadreId;
    if (_crearComoVarianteSku) {
      if (padre == null) {
        setState(() => _error = 'Elegi el producto base para la variante');
        return;
      }
      if (varianteIngresada.isEmpty) {
        setState(
          () => _error = 'En una variante, el campo Variante es obligatorio',
        );
        return;
      }
      nombre = padre.nombre.trim();
      productoPadreId = padre.id;
    } else {
      nombre = nombreIngresado;
      productoPadreId = null;
    }

    if (nombre.isEmpty) {
      setState(() => _error = 'Falta el nombre');
      return;
    }
    if (unidad.isEmpty) {
      setState(() => _error = 'Falta la unidad');
      return;
    }
    final stockInicial = _num(_stockInicialCtrl.text);
    if (stockInicial < 0) {
      setState(() => _error = 'El stock inicial no puede ser negativo');
      return;
    }

    String varianteFinal = varianteIngresada;
    String subvarianteFinal = subvarianteIngresada;
    if (_crearComoVarianteSku && padre != null) {
      final pv = (padre.variante ?? '').trim();
      final ps = (padre.subvariante ?? '').trim();

      if (pv.isNotEmpty && ps.isEmpty) {
        varianteFinal = pv;
        if (subvarianteFinal.isEmpty) {
          subvarianteFinal = varianteIngresada;
        }
      } else if (pv.isNotEmpty && ps.isNotEmpty) {
        varianteFinal = pv;
        final nuevoNivel = subvarianteFinal.isEmpty
            ? varianteIngresada
            : subvarianteFinal;
        subvarianteFinal = '$ps / $nuevoNivel';
      }
    }

    setState(() => _guardando = true);

    try {
      final skuManual = _tokenSku(_skuCtrl.text);
      final skuAutomatico = _skuSugerido(
        nombreBase: nombre,
        variante: varianteFinal,
        subvariante: subvarianteFinal,
        skuBase: padre?.sku,
      );
      final skuFinal = skuManual.isNotEmpty
          ? skuManual
          : (_crearComoVarianteSku && skuAutomatico.isNotEmpty
                ? skuAutomatico
                : null);

      final id = await Proveedores.inventarioRepositorio.crearProducto(
        nombre: nombre,
        sku: skuFinal,
        productoPadreId: productoPadreId,
        variante: varianteFinal.isEmpty ? null : varianteFinal,
        subvariante: subvarianteFinal.isEmpty ? null : subvarianteFinal,
        unidad: unidad,
        stockMinimo: _num(_minimoCtrl.text),
        costoActual: 0,
        precioSugerido: _num(_precioCtrl.text),
        proveedor: _proveedorCtrl.text.trim().isEmpty
            ? null
            : _proveedorCtrl.text.trim(),
      );

      if (stockInicial > 0) {
        await Proveedores.inventarioRepositorio.crearMovimiento(
          productoId: id,
          tipo: 'ingreso',
          cantidad: stockInicial,
          nota: 'Stock inicial',
          referencia: 'alta_producto:$id',
        );
      }

      if (!mounted) return;
      final ruta = (_fotoRutaSeleccionada ?? '').trim();
      if (ruta.isNotEmpty) {
        await Proveedores.inventarioRepositorio.actualizarImagenProducto(
          id: id,
          imagen: ruta,
        );
      }

      if (!mounted) return;
      if (widget.embebido && widget.onCreado != null) {
        widget.onCreado!(id);
      } else {
        Navigator.pop(context, id);
      }
    } catch (_) {
      setState(() {
        _guardando = false;
        _error = 'No se pudo guardar';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        widget.embebido ? 16 : 16 + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Nuevo producto',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                onPressed: _guardando
                    ? null
                    : () {
                        if (widget.embebido) {
                          widget.onCancelar?.call();
                        } else {
                          Navigator.pop(context, null);
                        }
                      },
                icon: const Icon(Icons.close),
                tooltip: 'Cerrar',
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Crear como variante SKU'),
            subtitle: const Text(
              'Vincula este producto a un producto base existente',
            ),
            value: _crearComoVarianteSku,
            onChanged: _guardando
                ? null
                : (v) {
                    setState(() {
                      _crearComoVarianteSku = v;
                      _error = null;
                      if (!v) _productoPadreId = null;
                    });
                  },
          ),
          const SizedBox(height: 8),
          if (_crearComoVarianteSku) ...[
            if (_cargandoProductos)
              const LinearProgressIndicator()
            else
              DropdownButtonFormField<int>(
                initialValue: _productoPadreId,
                decoration: const InputDecoration(labelText: 'Producto base'),
                items: _productosExistentes
                    .where((p) => p.activo && p.productoPadreId == null)
                    .map(
                      (p) => DropdownMenuItem<int>(
                        value: p.id,
                        child: Text(
                          p.sku == null || p.sku!.trim().isEmpty
                              ? p.nombreConVariante
                              : '${p.nombreConVariante} (${p.sku})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _guardando
                    ? null
                    : (v) {
                        setState(() {
                          _productoPadreId = v;
                          _error = null;
                        });
                      },
              ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Nombre base'),
              child: Text(_productoPadreSeleccionado?.nombre ?? '-'),
            ),
          ] else ...[
            TextField(
              controller: _nombreCtrl,
              enabled: !_guardando,
              decoration: const InputDecoration(labelText: 'Nombre'),
              textInputAction: TextInputAction.next,
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _varianteCtrl,
            enabled: !_guardando,
            decoration: InputDecoration(
              labelText: _crearComoVarianteSku
                  ? 'Variante (obligatoria)'
                  : 'Variante (opcional)',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subvarianteCtrl,
            enabled: !_guardando,
            decoration: const InputDecoration(
              labelText: 'Subvariante (opcional)',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _skuCtrl,
            enabled: !_guardando,
            decoration: InputDecoration(
              labelText: 'SKU (opcional)',
              helperText: _crearComoVarianteSku
                  ? () {
                      final padre = _productoPadreSeleccionado;
                      final skuAuto = _skuSugerido(
                        nombreBase: (padre?.nombre ?? '').trim(),
                        variante: _varianteCtrl.text,
                        subvariante: _subvarianteCtrl.text,
                        skuBase: padre?.sku,
                      );
                      return skuAuto.isEmpty
                          ? 'Si queda vacio, se genera automaticamente'
                          : 'Si queda vacio: $skuAuto';
                    }()
                  : 'Dejalo vacio si no usas SKU',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _unidadSeleccion,
            items: _unidadesOpciones
                .map(
                  (u) => DropdownMenuItem<String>(
                    value: u,
                    child: Text(_capPrimera(u)),
                  ),
                )
                .toList(),
            onChanged: _guardando
                ? null
                : (v) {
                    final val = v ?? 'unidad';
                    setState(() {
                      _unidadSeleccion = val;
                      _usarOtro = val == 'Otro';
                      if (!_usarOtro) {
                        _unidadCtrl.text = val;
                      } else {
                        if (_unidadCtrl.text.trim().isEmpty ||
                            _unidadesOpciones.contains(
                              _unidadCtrl.text.trim(),
                            )) {
                          _unidadCtrl.text = '';
                        }
                      }
                    });
                  },
            decoration: const InputDecoration(labelText: 'Unidad'),
          ),
          if (_usarOtro) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _unidadCtrl,
              enabled: !_guardando,
              decoration: const InputDecoration(
                labelText: 'Unidad personalizada',
              ),
              textInputAction: TextInputAction.next,
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _minimoCtrl,
            enabled: !_guardando,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Stock minimo'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _stockInicialCtrl,
            enabled: !_guardando,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Stock inicial'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _precioCtrl,
            enabled: !_guardando,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Precio para la venta',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _proveedorCtrl,
            enabled: !_guardando,
            decoration: const InputDecoration(
              labelText: 'Proveedor (opcional)',
            ),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Foto del producto (opcional)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                        child:
                            (_fotoRutaSeleccionada ?? '').trim().isNotEmpty &&
                                File(_fotoRutaSeleccionada!).existsSync()
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(_fotoRutaSeleccionada!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.image_outlined,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: (_guardando || _cargandoFoto)
                                  ? null
                                  : () => _seleccionarFoto(usarCamara: false),
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('Galeria'),
                            ),
                            OutlinedButton.icon(
                              onPressed: (_guardando || _cargandoFoto)
                                  ? null
                                  : () => _seleccionarFoto(usarCamara: true),
                              icon: const Icon(Icons.photo_camera_outlined),
                              label: const Text('Camara'),
                            ),
                            if ((_fotoRutaSeleccionada ?? '').trim().isNotEmpty)
                              TextButton.icon(
                                onPressed: (_guardando || _cargandoFoto)
                                    ? null
                                    : _quitarFotoSeleccionada,
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Quitar'),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (_cargandoFoto) const LinearProgressIndicator(),
                ],
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: Text(_guardando ? 'Guardando...' : 'Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VarianteItem {
  final Producto producto;
  final double stock;

  const _VarianteItem({required this.producto, required this.stock});
}
