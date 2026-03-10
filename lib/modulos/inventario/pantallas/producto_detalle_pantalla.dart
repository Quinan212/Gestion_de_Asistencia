// lib/modulos/inventario/pantallas/producto_detalle_pantalla.dart
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/layout_app.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/tablet_master_detail_layout.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/infraestructura/servicios/fotos_producto.dart';
import 'package:gestion_de_asistencias/modulos/inventario/modelos/producto.dart';
import 'package:gestion_de_asistencias/modulos/inventario/modelos/movimiento.dart';
import 'movimiento_nuevo_pantalla.dart';

class ProductoDetallePantalla extends StatefulWidget {
  final int productoId;

  const ProductoDetallePantalla({super.key, required this.productoId});

  @override
  State<ProductoDetallePantalla> createState() =>
      _ProductoDetallePantallaState();
}

class _ProductoDetallePantallaState extends State<ProductoDetallePantalla>
    with SingleTickerProviderStateMixin {
  static const double _kTablet = LayoutApp.kTablet;

  // ancho máximo cómodo para el detalle en tablet
  static const double _kMaxPageWidth = LayoutApp.kMaxPageWidth;

  // sheets: ancho/alto máximo (no gigantones)
  static const double _kMaxSheetWidth = 620;

  String _moneda = r'$';

  static const _unidadesOpciones = <String>[
    'unidad',
    'pack',
    'caja',
    'kg',
    'Otro',
  ];

  late final TabController _tabController;

  // cache para evitar “destello” al cambiar tabs
  late Future<List<Movimiento>> _movsFuture;
  late Future<double> _stockFuture;
  late Future<Producto?> _productoFuture;

  @override
  void initState() {
    super.initState();

    _productoFuture = _cargarProducto();
    _stockFuture = _cargarStock();
    _movsFuture = Proveedores.inventarioRepositorio.listarMovimientosDeProducto(
      widget.productoId,
    );

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!mounted) return;
      if (_tabController.indexIsChanging) return;
      setState(() {});
    });

    _cargarMoneda();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _esTabletUI(BuildContext context) =>
      MediaQuery.of(context).size.width >= _kTablet;

  void _refreshTodo() {
    setState(() {
      _productoFuture = _cargarProducto();
      _stockFuture = _cargarStock();
      _movsFuture = Proveedores.inventarioRepositorio
          .listarMovimientosDeProducto(widget.productoId);
    });
  }

  void _refreshStockYMovs() {
    setState(() {
      _stockFuture = _cargarStock();
      _movsFuture = Proveedores.inventarioRepositorio
          .listarMovimientosDeProducto(widget.productoId);
    });
  }

  Future<void> _cargarMoneda() async {
    final m = await Formatos.leerMoneda();
    if (!mounted) return;
    setState(() => _moneda = m);
  }

  Future<Producto?> _cargarProducto() {
    return Proveedores.inventarioRepositorio.obtenerProducto(widget.productoId);
  }

  Future<double> _cargarStock() async {
    final p = await Proveedores.inventarioRepositorio.obtenerProducto(
      widget.productoId,
    );
    if (p == null) return 0.0;

    final stockPropio = await Proveedores.inventarioRepositorio
        .calcularStockActual(widget.productoId);
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

  Future<void> _nuevoMovimiento() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovimientoNuevoPantalla(productoId: widget.productoId),
      ),
    );
    if (!mounted) return;
    _refreshStockYMovs();
  }

  // sheet “normal” y acotado (tablet: centrado, más bajo; móvil: bottom-sheet normal)
  Future<T?> _showAdaptiveSheet<T>({
    required WidgetBuilder builder,
    bool showHandle = true,
  }) {
    final media = MediaQuery.of(context);
    final esTablet = _esTabletUI(context);

    final maxH = (media.size.height * (esTablet ? 0.72 : 0.92)).clamp(
      260.0,
      720.0,
    );

    return showModalBottomSheet<T>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: showHandle,
      constraints: BoxConstraints(
        maxWidth: esTablet ? _kMaxSheetWidth : double.infinity,
        maxHeight: maxH,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.viewInsetsOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: builder(ctx),
        );
      },
    );
  }

  // wrapper para el contenido en tablet (no ancho infinito)
  Widget _pageWrapTablet(Widget child) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kMaxPageWidth),
        child: child,
      ),
    );
  }

  String _capPrimera(String s) {
    final t = s.trim();
    if (t.isEmpty) return t;
    if (t.length == 1) return t.toUpperCase();
    return '${t[0].toUpperCase()}${t.substring(1)}';
  }

  String _unidadConCantidad(String unidad, double cantidad) {
    final u0 = unidad.trim();
    if (u0.isEmpty) return '';

    final low = u0.toLowerCase();
    final esUno = (cantidad - 1).abs() < 0.0000001;

    final yaPlural = low.endsWith('s') || low.endsWith('es');
    if (esUno || yaPlural) return _capPrimera(u0);

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

    return _capPrimera(plural);
  }

  // -------------------- EDITAR (sheet) --------------------

  Future<void> _editarProducto(Producto p) async {
    final nombreCtrl = TextEditingController(text: p.nombre);
    final skuCtrl = TextEditingController(text: p.sku ?? '');
    final varianteCtrl = TextEditingController(text: p.variante ?? '');
    final subvarianteCtrl = TextEditingController(text: p.subvariante ?? '');
    final unidadCtrl = TextEditingController(text: p.unidad);
    final minimoCtrl = TextEditingController(
      text: p.stockMinimo.toStringAsFixed(2),
    );
    final costoCtrl = TextEditingController(
      text: p.costoActual.toStringAsFixed(2),
    );
    final precioCtrl = TextEditingController(
      text: p.precioSugerido.toStringAsFixed(2),
    );
    final proveedorCtrl = TextEditingController(text: p.proveedor ?? '');
    bool activo = p.activo;

    final unidadBase = p.unidad.trim().toLowerCase();
    final esOpcion =
        _unidadesOpciones.contains(unidadBase) && unidadBase != 'otro';
    String unidadSel = esOpcion ? unidadBase : 'Otro';
    bool usarOtro = !esOpcion;

    if (esOpcion) {
      unidadCtrl.text = unidadBase;
    } else {
      unidadCtrl.text = p.unidad;
    }

    double parseNum(String t) =>
        double.tryParse(t.trim().replaceAll(',', '.')) ?? 0.0;

    final ok = await _showAdaptiveSheet<bool>(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateLocal) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 10, 6),
                  child: Row(
                    children: [
                      Text(
                        'Editar producto',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context, false),
                        icon: const Icon(Icons.close),
                        tooltip: 'Cerrar',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      children: [
                        TextField(
                          controller: nombreCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: skuCtrl,
                          decoration: const InputDecoration(
                            labelText: 'SKU (opcional)',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: varianteCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Variante (opcional)',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: subvarianteCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Subvariante (opcional)',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        DropdownMenu<String>(
                          initialSelection: unidadSel,
                          expandedInsets: EdgeInsets.zero,
                          label: const Text('Unidad'),
                          dropdownMenuEntries: _unidadesOpciones
                              .map(
                                (u) => DropdownMenuEntry<String>(
                                  value: u,
                                  label: _capPrimera(u),
                                ),
                              )
                              .toList(),
                          onSelected: (v) {
                            final val = v ?? 'unidad';
                            setStateLocal(() {
                              unidadSel = val;
                              usarOtro = val == 'Otro';
                              if (!usarOtro) {
                                unidadCtrl.text = val;
                              } else {
                                if (unidadCtrl.text.trim().isEmpty ||
                                    _unidadesOpciones.contains(
                                      unidadCtrl.text.trim().toLowerCase(),
                                    )) {
                                  unidadCtrl.text = '';
                                }
                              }
                            });
                          },
                        ),
                        if (usarOtro) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: unidadCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Unidad personalizada',
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                        ],
                        const SizedBox(height: 12),
                        TextField(
                          controller: minimoCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Stock mínimo',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: costoCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Costo promedio actual ($_moneda)',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: precioCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Precio para la venta ($_moneda)',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: proveedorCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Proveedor (opcional)',
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Activo'),
                          value: activo,
                          onChanged: (v) => setStateLocal(() => activo = v),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final nombre = nombreCtrl.text.trim();
                            final unidad = unidadCtrl.text.trim();
                            if (nombre.isEmpty || unidad.isEmpty) return;
                            Navigator.pop(context, true);
                          },
                          child: const Text('Guardar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;

    final nombre = nombreCtrl.text.trim();
    final sku = skuCtrl.text.trim();
    final variante = varianteCtrl.text.trim();
    final subvariante = subvarianteCtrl.text.trim();
    final unidad = unidadCtrl.text.trim();
    if (nombre.isEmpty || unidad.isEmpty) return;

    final stockMinimo = parseNum(minimoCtrl.text);
    final costoActual = parseNum(costoCtrl.text);
    final precioSugerido = parseNum(precioCtrl.text);
    final proveedor = proveedorCtrl.text.trim().isEmpty
        ? null
        : proveedorCtrl.text.trim();

    await Proveedores.inventarioRepositorio.actualizarProducto(
      id: p.id,
      nombre: nombre,
      sku: Value(sku.isEmpty ? null : sku),
      variante: Value(variante.isEmpty ? null : variante),
      subvariante: Value(subvariante.isEmpty ? null : subvariante),
      unidad: unidad,
      costoActual: costoActual,
      precioSugerido: precioSugerido,
      stockMinimo: stockMinimo,
      proveedor: proveedor,
      activo: activo,
    );

    if (!mounted) return;
    _refreshTodo();
  }

  // -------------------- FOTO --------------------

  bool _tieneFoto(Producto p) {
    final ruta = (p.imagen ?? '').trim();
    return ruta.isNotEmpty && File(ruta).existsSync();
  }

  Widget _heroFoto(Producto p) {
    final cs = Theme.of(context).colorScheme;
    final ruta = (p.imagen ?? '').trim();
    final ok = _tieneFoto(p);

    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Container(
                  color: cs.surfaceContainerHighest,
                  child: ok
                      ? Image.file(File(ruta), fit: BoxFit.cover)
                      : Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 56,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.10),
                          Colors.black.withValues(alpha: 0.00),
                          Colors.black.withValues(alpha: 0.30),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => _cambiarFoto(p),
                        icon: const Icon(Icons.photo_camera_back_outlined),
                        tooltip: 'Foto',
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () => _editarProducto(p),
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Editar',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _cambiarFoto(Producto p) async {
    final opcion = await _showAdaptiveSheet<int>(
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            Text(
              'Foto del producto',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, 0),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(context, 1),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Quitar foto'),
              textColor: Theme.of(context).colorScheme.error,
              iconColor: Theme.of(context).colorScheme.error,
              onTap: () => Navigator.pop(context, 2),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
      showHandle: true,
    );

    if (opcion == null) return;

    if (opcion == 2) {
      await FotosProducto.borrarSiExiste(p.imagen);
      await Proveedores.inventarioRepositorio.actualizarImagenProducto(
        id: p.id,
        imagen: null,
      );
      if (!mounted) return;
      _refreshTodo();
      return;
    }

    final ruta = await FotosProducto.elegirYGuardar(
      productoId: p.id,
      usarCamara: opcion == 1,
    );
    if (ruta == null) return;

    await FotosProducto.borrarSiExiste(p.imagen);
    await Proveedores.inventarioRepositorio.actualizarImagenProducto(
      id: p.id,
      imagen: ruta,
    );

    if (!mounted) return;
    _refreshTodo();
  }

  // -------------------- MOVIMIENTOS --------------------

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

  IconData _iconoTipoMov(String tipo) {
    switch (tipo) {
      case 'ingreso':
        return Icons.south_west_rounded;
      case 'egreso':
        return Icons.north_east_rounded;
      case 'ajuste':
        return Icons.tune_rounded;
      case 'devolucion':
        return Icons.assignment_return_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  Color _colorTipoMov(BuildContext context, String tipo) {
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

  double _cantidadConSigno(Movimiento m) {
    if (m.tipo == 'egreso') return -m.cantidad;
    if (m.tipo == 'ingreso' || m.tipo == 'devolucion') return m.cantidad;
    return m.cantidad;
  }

  String _fecha(DateTime f) {
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${d2(f.day)}/${d2(f.month)}/${f.year} ${d2(f.hour)}:${d2(f.minute)}';
  }

  Future<void> _cancelarMovimiento(Movimiento m) async {
    final nota = (m.nota ?? '');
    final ref = (m.referencia ?? '');

    final esCancelado = nota.contains('CANCELADO');
    final esReversion = ref.startsWith('reversion_de:');

    if (esCancelado || esReversion) return;

    String tipoInverso(String tipo) {
      if (tipo == 'ingreso') return 'egreso';
      if (tipo == 'egreso') return 'ingreso';
      if (tipo == 'devolucion') return 'egreso';
      if (tipo == 'ajuste') return 'ajuste';
      return 'ajuste';
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar movimiento'),
          content: const Text(
            'Lo deja sin efecto (crea el inverso) y lo marca como cancelado.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sí, cancelar'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    final tipoNuevo = tipoInverso(m.tipo);
    final cantidadNueva = (m.tipo == 'ajuste') ? -m.cantidad : m.cantidad;

    await Proveedores.inventarioRepositorio.crearMovimiento(
      productoId: m.productoId,
      tipo: tipoNuevo,
      cantidad: cantidadNueva,
      nota: 'REVERSIÓN (AUTO) de movimiento ${m.id}',
      referencia: 'reversion_de:${m.id}',
    );

    final notaAnterior = (m.nota ?? '').trim();
    const marca = 'CANCELADO';
    final notaNueva = notaAnterior.isEmpty ? marca : '$notaAnterior\n$marca';

    await Proveedores.inventarioRepositorio.actualizarNotaMovimiento(
      movimientoId: m.id,
      nota: notaNueva,
    );

    if (!mounted) return;
    _refreshStockYMovs();
  }

  Future<void> _verDetalleMovimiento(Movimiento m, String unidad) async {
    final v = _cantidadConSigno(m);
    final txt =
        '${v >= 0 ? '+' : '-'}${Formatos.cantidad(v.abs(), unidad: unidad)} ${_unidadConCantidad(unidad, v.abs())}';

    final ref = (m.referencia ?? '').trim();
    final nota = (m.nota ?? '').trim();

    final esCancelado = nota.contains('CANCELADO');
    final esReversion = ref.startsWith('reversion_de:');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: Text(_textoTipo(m.tipo)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fecha: ${_fecha(m.fecha)}'),
              const SizedBox(height: 8),
              Text('Cantidad: $txt'),
              const SizedBox(height: 8),
              Text('Referencia: ${ref.isEmpty ? '-' : ref}'),
              const SizedBox(height: 8),
              Text('Nota: ${nota.isEmpty ? '-' : nota}'),
              const SizedBox(height: 8),
              Text('Estado: ${esCancelado ? 'Cancelado' : 'Activo'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            if (!esCancelado && !esReversion)
              FilledButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _cancelarMovimiento(m);
                },
                child: const Text('Cancelar movimiento'),
              ),
          ],
        );
      },
    );
  }

  Widget _listaMovimientos({
    required String unidad,
    required EdgeInsets padding,
  }) {
    return FutureBuilder<List<Movimiento>>(
      future: _movsFuture,
      builder: (context, snapM) {
        if (snapM.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final movs = snapM.data ?? [];
        if (movs.isEmpty) {
          return const Center(child: Text('Todavia no hay movimientos'));
        }

        return ListView.separated(
          padding: padding,
          itemCount: movs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final m = movs[i];
            final v = _cantidadConSigno(m);
            final cancelado = (m.nota ?? '').contains('CANCELADO');

            final cantTxt =
                '${v >= 0 ? '+' : '-'}${Formatos.cantidad(v.abs(), unidad: unidad)}';

            final tipoColor = _colorTipoMov(context, m.tipo);
            final nota = (m.nota ?? '').trim();
            final referencia = (m.referencia ?? '').trim();

            return Card(
              clipBehavior: Clip.antiAlias,
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: InkWell(
                onTap: () => _verDetalleMovimiento(m, unidad),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: tipoColor.withValues(alpha: 0.14),
                        child: Icon(
                          _iconoTipoMov(m.tipo),
                          size: 18,
                          color: tipoColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _textoTipo(m.tipo),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _fecha(m.fecha),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            if (nota.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                nota,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                            if (referencia.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Ref: $referencia',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            cantTxt,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cancelado
                                      ? Theme.of(context).disabledColor
                                      : (v < 0
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.error
                                            : Theme.of(
                                                context,
                                              ).colorScheme.primary),
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _unidadConCantidad(unidad, v.abs()),
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // -------------------- UI “PRO” --------------------

  Widget _chip(String text, IconData icon, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsCard({required Producto p, required double stock}) {
    final cs = Theme.of(context).colorScheme;
    final enFalta = stock < p.stockMinimo;
    final stockColor = enFalta ? cs.error : cs.primary;

    Widget stat(String titulo, String valor, {Color? color, bool big = false}) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            Text(
              valor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: big
                  ? Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: color)
                  : Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: color),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary.withValues(alpha: 0.07), Colors.transparent],
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: cs.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              stat(
                'Stock',
                '${Formatos.cantidad(stock, unidad: p.unidad)} ${_unidadConCantidad(p.unidad, stock)}',
                color: stockColor,
                big: true,
              ),
              const SizedBox(width: 10),
              stat(
                'Minimo',
                '${Formatos.cantidad(p.stockMinimo, unidad: p.unidad)} ${_unidadConCantidad(p.unidad, p.stockMinimo)}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filaDetalle(
    IconData icon,
    String label,
    String value, {
    bool strong = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: cs.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: strong
                  ? t.titleMedium?.copyWith(fontWeight: FontWeight.w800)
                  : t.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _separarCon(List<Widget> items, Widget sep) {
    if (items.isEmpty) return [];
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) out.add(sep);
    }
    return out;
  }

  Widget _bloque(String titulo, List<Widget> filas) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ..._separarCon(filas, const SizedBox(height: 12)),
          ],
        ),
      ),
    );
  }

  Future<List<_VarianteConStock>> _cargarVariantesConStock(int baseId) async {
    final productos = await Proveedores.inventarioRepositorio.listarProductos(
      incluirInactivos: true,
    );
    final variantes = productos
        .where((p) => p.productoPadreId == baseId)
        .toList();
    if (variantes.isEmpty) return const [];

    final stock = await Proveedores.inventarioRepositorio
        .calcularStockActualPorProductos(variantes.map((v) => v.id).toList());

    return variantes
        .map((v) => _VarianteConStock(producto: v, stock: stock[v.id] ?? 0.0))
        .toList();
  }

  Widget _bloqueVariantes(Producto p) {
    if (p.productoPadreId != null) {
      return FutureBuilder<Producto?>(
        future: Proveedores.inventarioRepositorio.obtenerProducto(
          p.productoPadreId!,
        ),
        builder: (context, snap) {
          final base = snap.data;
          final texto = base == null
              ? 'Esta variante pertenece a un producto base'
              : 'Producto base: ${base.nombreConVariante}';
          return _bloque('Variantes SKU', [
            Text(texto, style: Theme.of(context).textTheme.bodyMedium),
          ]);
        },
      );
    }

    return FutureBuilder<List<_VarianteConStock>>(
      future: _cargarVariantesConStock(p.id),
      builder: (context, snap) {
        final variantes = snap.data ?? const <_VarianteConStock>[];
        if (snap.connectionState != ConnectionState.done) {
          return _bloque('Variantes SKU', const [LinearProgressIndicator()]);
        }
        if (variantes.isEmpty) {
          return _bloque('Variantes SKU', const [
            Text('No hay variantes creadas para este producto base.'),
          ]);
        }

        final filas = <Widget>[];
        for (final item in variantes) {
          filas.add(
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductoDetallePantalla(productoId: item.producto.id),
                  ),
                );
                if (!mounted) return;
                _refreshTodo();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.producto.nombreConVariante,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${Formatos.cantidad(item.stock, unidad: item.producto.unidad)} ${_unidadConCantidad(item.producto.unidad, item.stock)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return _bloque('Variantes SKU', filas);
      },
    );
  }

  Widget _detallesCard({required Producto p}) {
    final skuTxt = (p.sku ?? '').trim();
    final esVariante = p.productoPadreId != null;

    final filasInventario = <Widget>[
      _filaDetalle(
        Icons.qr_code_2_rounded,
        'SKU',
        skuTxt.isEmpty ? '-' : skuTxt,
      ),
      _filaDetalle(Icons.straighten_outlined, 'Unidad', _capPrimera(p.unidad)),
      _filaDetalle(
        Icons.local_shipping_outlined,
        'Proveedor',
        p.proveedor ?? '-',
      ),
      _filaDetalle(
        Icons.toggle_on_outlined,
        'Estado',
        p.activo ? 'Activo' : 'Inactivo',
      ),
    ];

    if (esVariante) {
      filasInventario.insertAll(1, [
        _filaDetalle(
          Icons.category_outlined,
          'Variante',
          (p.variante ?? '').trim().isEmpty ? '-' : p.variante!.trim(),
        ),
        _filaDetalle(
          Icons.layers_outlined,
          'Subvariante',
          (p.subvariante ?? '').trim().isEmpty ? '-' : p.subvariante!.trim(),
        ),
      ]);
    }

    return Column(
      children: [
        _bloque('Inventario', filasInventario),
        const SizedBox(height: 12),
        _bloque('Precios', [
          _filaDetalle(
            Icons.payments_outlined,
            'Costo promedio actual',
            Formatos.dinero(_moneda, p.costoActual),
            strong: true,
          ),
          _filaDetalle(
            Icons.sell_outlined,
            'Precio para la venta',
            Formatos.dinero(_moneda, p.precioSugerido),
          ),
        ]),
        const SizedBox(height: 12),
        _bloqueVariantes(p),
      ],
    );
  }

  // -------------------- LAYOUTS --------------------

  Widget _mobileBody({required Producto p, required double stock}) {
    final enFalta = stock < p.stockMinimo;

    return NestedScrollView(
      headerSliverBuilder: (context, inner) {
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: _heroFoto(p),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.nombreConVariante,
                    style: Theme.of(context).textTheme.headlineSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(
                        p.activo ? 'Activo' : 'Inactivo',
                        p.activo
                            ? Icons.check_circle_outline
                            : Icons.pause_circle_outline,
                        color: p.activo
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      if (enFalta)
                        _chip(
                          'Bajo minimo',
                          Icons.warning_amber_outlined,
                          color: Theme.of(context).colorScheme.error,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _statsCard(p: p, stock: stock),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabsHeaderDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Detalles'),
                  Tab(text: 'Movimientos'),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 92),
            child: _detallesCard(p: p),
          ),
          Stack(
            children: [
              _listaMovimientos(
                unidad: p.unidad,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 92),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: FilledButton.icon(
                  onPressed: _nuevoMovimiento,
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo movimiento'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabletBody({required Producto p, required double stock}) {
    final enFalta = stock < p.stockMinimo;

    return _pageWrapTablet(
      Padding(
        padding: TabletMasterDetailLayout.kPagePadding,
        child: TabletMasterDetailLayout(
          master: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _heroFoto(p),
                const SizedBox(height: 12),
                Text(
                  p.nombreConVariante,
                  style: Theme.of(context).textTheme.headlineSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip(
                      p.activo ? 'Activo' : 'Inactivo',
                      p.activo
                          ? Icons.check_circle_outline
                          : Icons.pause_circle_outline,
                      color: p.activo
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    if (enFalta)
                      _chip(
                        'Bajo minimo',
                        Icons.warning_amber_outlined,
                        color: Theme.of(context).colorScheme.error,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _statsCard(p: p, stock: stock),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _nuevoMovimiento,
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo movimiento'),
                ),
                const SizedBox(height: 12),
                _detallesCard(p: p),
              ],
            ),
          ),
          detail: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Material(
                  color: Theme.of(context).colorScheme.surface,
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Detalles'),
                      Tab(text: 'Movimientos'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        child: _detallesCard(p: p),
                      ),
                      _listaMovimientos(
                        unidad: p.unidad,
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------- BUILD --------------------

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Producto?>(
      future: _productoFuture,
      builder: (context, snapP) {
        final p = snapP.data;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Producto'),
            actions: [
              IconButton(
                onPressed: _refreshTodo,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: snapP.connectionState != ConnectionState.done
              ? const Center(child: CircularProgressIndicator())
              : p == null
              ? const Center(child: Text('Producto no encontrado'))
              : FutureBuilder<double>(
                  future: _stockFuture,
                  builder: (context, snapS) {
                    final stock = snapS.data ?? 0;

                    return LayoutBuilder(
                      builder: (context, c) {
                        final esTablet = c.maxWidth >= _kTablet;
                        return esTablet
                            ? _tabletBody(p: p, stock: stock)
                            : _mobileBody(p: p, stock: stock);
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}

class _VarianteConStock {
  final Producto producto;
  final double stock;

  const _VarianteConStock({required this.producto, required this.stock});
}

// Header fijo para TabBar en NestedScrollView (móvil)
class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabsHeaderDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabsHeaderDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar;
  }
}
