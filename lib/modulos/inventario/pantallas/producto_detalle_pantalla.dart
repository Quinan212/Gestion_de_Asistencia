// lib/modulos/inventario/pantallas/producto_detalle_pantalla.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gestion_de_stock/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_stock/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_stock/infraestructura/servicios/fotos_producto.dart';
import 'package:gestion_de_stock/modulos/inventario/modelos/producto.dart';
import 'package:gestion_de_stock/modulos/inventario/modelos/movimiento.dart';
import 'movimiento_nuevo_pantalla.dart';

class ProductoDetallePantalla extends StatefulWidget {
  final int productoId;

  const ProductoDetallePantalla({super.key, required this.productoId});

  @override
  State<ProductoDetallePantalla> createState() => _ProductoDetallePantallaState();
}

class _ProductoDetallePantallaState extends State<ProductoDetallePantalla>
    with SingleTickerProviderStateMixin {
  static const double _kTablet = 900;

  String _moneda = r'$';

  static const _unidadesOpciones = <String>['unidad', 'pack', 'caja', 'kg', 'Otro'];

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
    _movsFuture = Proveedores.inventarioRepositorio
        .listarMovimientosDeProducto(widget.productoId);

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!mounted) return;
      if (_tabController.indexIsChanging) return;
      // solo para anim/estado del botón, NO recarga futures
      setState(() {});
    });

    _cargarMoneda();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

  Future<double> _cargarStock() {
    return Proveedores.inventarioRepositorio.calcularStockActual(widget.productoId);
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
    final unidadCtrl = TextEditingController(text: p.unidad);
    final minimoCtrl = TextEditingController(text: p.stockMinimo.toStringAsFixed(2));
    final costoCtrl = TextEditingController(text: p.costoActual.toStringAsFixed(2));
    final precioCtrl = TextEditingController(text: p.precioSugerido.toStringAsFixed(2));
    final proveedorCtrl = TextEditingController(text: p.proveedor ?? '');
    bool activo = p.activo;

    final unidadBase = p.unidad.trim().toLowerCase();
    final esOpcion = _unidadesOpciones.contains(unidadBase) && unidadBase != 'otro';
    String unidadSel = esOpcion ? unidadBase : 'Otro';
    bool usarOtro = !esOpcion;

    if (esOpcion) {
      unidadCtrl.text = unidadBase;
    } else {
      unidadCtrl.text = p.unidad;
    }

    double parseNum(String t) => double.tryParse(t.trim().replaceAll(',', '.')) ?? 0.0;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateLocal) {
            final bottom = MediaQuery.of(context).viewInsets.bottom;

            return Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text('Editar producto', style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context, false),
                        icon: const Icon(Icons.close),
                        tooltip: 'Cerrar',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: nombreCtrl,
                            decoration: const InputDecoration(labelText: 'Nombre'),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          DropdownMenu<String>(
                            initialSelection: unidadSel,
                            expandedInsets: EdgeInsets.zero,
                            label: const Text('Unidad'),
                            dropdownMenuEntries: _unidadesOpciones
                                .map((u) => DropdownMenuEntry<String>(
                              value: u,
                              label: _capPrimera(u),
                            ))
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
                              decoration: const InputDecoration(labelText: 'Unidad personalizada'),
                              textInputAction: TextInputAction.next,
                            ),
                          ],
                          const SizedBox(height: 12),
                          TextField(
                            controller: minimoCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Stock mínimo'),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: costoCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: 'Costo actual ($_moneda)'),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: precioCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: 'Precio sugerido ($_moneda)'),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: proveedorCtrl,
                            decoration: const InputDecoration(labelText: 'Proveedor (opcional)'),
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
                  const SizedBox(height: 12),
                  Row(
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
                ],
              ),
            );
          },
        );
      },
    );

    if (ok != true) return;

    final nombre = nombreCtrl.text.trim();
    final unidad = unidadCtrl.text.trim();
    if (nombre.isEmpty || unidad.isEmpty) return;

    final stockMinimo = parseNum(minimoCtrl.text);
    final costoActual = parseNum(costoCtrl.text);
    final precioSugerido = parseNum(precioCtrl.text);
    final proveedor = proveedorCtrl.text.trim().isEmpty ? null : proveedorCtrl.text.trim();

    await Proveedores.inventarioRepositorio.actualizarProducto(
      id: p.id,
      nombre: nombre,
      unidad: unidad,
      costoActual: costoActual,
      precioSugerido: precioSugerido,
      stockMinimo: stockMinimo,
      proveedor: proveedor,
      activo: activo,
    );

    if (!mounted) return;

    // producto cambió: refrescamos todo (incluye nombre/unidad/etc)
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          Container(
            height: 210,
            width: double.infinity,
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
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.00),
                    Colors.black.withValues(alpha: 0.45),
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
    );
  }

  Future<void> _cambiarFoto(Producto p) async {
    final opcion = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            const Text(
              'Foto del producto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 8),
          ],
        );
      },
    );

    if (opcion == null) return;

    if (opcion == 2) {
      await FotosProducto.borrarSiExiste(p.imagen);
      await Proveedores.inventarioRepositorio.actualizarImagenProducto(id: p.id, imagen: null);
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
    await Proveedores.inventarioRepositorio.actualizarImagenProducto(id: p.id, imagen: ruta);

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
        return 'Devolución';
      default:
        return tipo;
    }
  }

  IconData _iconoTipoMov(String tipo) {
    switch (tipo) {
      case 'ingreso':
        return Icons.add_circle_outline;
      case 'egreso':
        return Icons.remove_circle_outline;
      case 'ajuste':
        return Icons.tune;
      case 'devolucion':
        return Icons.assignment_return_outlined;
      default:
        return Icons.swap_horiz;
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
          content: const Text('Lo deja sin efecto (crea el inverso) y lo marca como cancelado.'),
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
        '${v >= 0 ? '+' : '-'}${v.abs().toStringAsFixed(2)} ${_unidadConCantidad(unidad, v.abs())}';

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
      future: _movsFuture, // cacheado
      builder: (context, snapM) {
        if (snapM.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final movs = snapM.data ?? [];
        if (movs.isEmpty) {
          return const Center(child: Text('Todavía no hay movimientos'));
        }

        final cs = Theme.of(context).colorScheme;

        return ListView.separated(
          padding: padding,
          itemCount: movs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final m = movs[i];
            final v = _cantidadConSigno(m);
            final cancelado = (m.nota ?? '').contains('CANCELADO');

            final cantTxt = '${v >= 0 ? '+' : '-'}${v.abs().toStringAsFixed(2)}';

            return Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                onTap: () => _verDetalleMovimiento(m, unidad),
                leading: Icon(_iconoTipoMov(m.tipo)),
                title: Text(_textoTipo(m.tipo)),
                subtitle: Text(
                  '${_fecha(m.fecha)}${(m.nota ?? '').trim().isEmpty ? '' : '\n${m.nota ?? ''}'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      cantTxt,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: cancelado
                            ? Theme.of(context).disabledColor
                            : (v < 0 ? cs.error : cs.primary),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _unidadConCantidad(unidad, v.abs()),
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // -------------------- UI “PRO” --------------------

  Widget _chip(String text, IconData icon) {
    return Chip(
      label: Text(text),
      avatar: Icon(icon, size: 18),
    );
  }

  Widget _statsCard({
    required Producto p,
    required double stock,
  }) {
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
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            Text(
              valor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: big
                  ? Theme.of(context).textTheme.headlineSmall?.copyWith(color: color)
                  : Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
            ),
          ],
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            stat(
              'Stock',
              '${stock.toStringAsFixed(2)} ${_unidadConCantidad(p.unidad, stock)}',
              color: stockColor,
              big: true,
            ),
            const SizedBox(width: 10),
            stat(
              'Mínimo',
              '${p.stockMinimo.toStringAsFixed(2)} ${_unidadConCantidad(p.unidad, p.stockMinimo)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaDetalle(IconData icon, String label, String value, {bool strong = false}) {
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
              style: strong ? t.titleMedium : t.bodyMedium,
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

  Widget _detallesCard({required Producto p}) {
    return Column(
      children: [
        _bloque(
          'Inventario',
          [
            _filaDetalle(Icons.straighten_outlined, 'Unidad', _capPrimera(p.unidad)),
            _filaDetalle(Icons.local_shipping_outlined, 'Proveedor', p.proveedor ?? '-'),
            _filaDetalle(Icons.toggle_on_outlined, 'Estado', p.activo ? 'Activo' : 'Inactivo'),
          ],
        ),
        const SizedBox(height: 12),
        _bloque(
          'Precios',
          [
            _filaDetalle(Icons.payments_outlined, 'Costo actual', Formatos.dinero(_moneda, p.costoActual),
                strong: true),
            _filaDetalle(Icons.sell_outlined, 'Precio sugerido', Formatos.dinero(_moneda, p.precioSugerido)),
          ],
        ),
      ],
    );
  }

  // -------------------- LAYOUTS --------------------

  Widget _mobileBody({
    required Producto p,
    required double stock,
  }) {
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
                    p.nombre,
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
                        p.activo ? Icons.check_circle_outline : Icons.pause_circle_outline,
                      ),
                      if (enFalta) _chip('Bajo mínimo', Icons.warning_amber_outlined),
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

  Widget _tabletBody({
    required Producto p,
    required double stock,
  }) {
    final enFalta = stock < p.stockMinimo;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _heroFoto(p),
                  const SizedBox(height: 12),
                  Text(
                    p.nombre,
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
                        p.activo ? Icons.check_circle_outline : Icons.pause_circle_outline,
                      ),
                      if (enFalta) _chip('Bajo mínimo', Icons.warning_amber_outlined),
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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Card(
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
        ],
      ),
    );
  }

  // -------------------- BUILD --------------------

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Producto?>(
      future: _productoFuture, // cacheado
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
            future: _stockFuture, // cacheado
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

// Header fijo para TabBar en NestedScrollView (móvil)
class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabsHeaderDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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