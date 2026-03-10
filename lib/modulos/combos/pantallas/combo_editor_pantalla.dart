// lib/modulos/combos/pantallas/combo_editor_pantalla.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/inventario/modelos/producto.dart';
import 'package:gestion_de_asistencias/modulos/combos/modelos/combo.dart';
import 'package:gestion_de_asistencias/modulos/combos/modelos/componente_combo.dart';

class ComboEditorPantalla extends StatefulWidget {
  final int? comboId;
  final bool embebido;
  final VoidCallback? onChanged;
  final ValueChanged<int>? onCreado;
  final VoidCallback? onCancelarCreacion;

  const ComboEditorPantalla({
    super.key,
    required this.comboId,
    this.embebido = false,
    this.onChanged,
  }) : onCreado = null,
       onCancelarCreacion = null,
       assert(comboId != null);

  const ComboEditorPantalla.nuevo({
    super.key,
    this.embebido = false,
    this.onCreado,
    this.onCancelarCreacion,
  }) : comboId = null,
       onChanged = null;

  @override
  State<ComboEditorPantalla> createState() => _ComboEditorPantallaState();
}

class _ComboEditorPantallaState extends State<ComboEditorPantalla> {
  String _moneda = r'$';

  bool _cargando = true;
  bool _guardando = false;

  Combo? _combo;
  List<ComponenteCombo> _componentes = [];
  List<Producto> _productos = [];

  final _nombreCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  bool _activo = true;

  bool _dirty = false;

  bool get _esNuevo => widget.comboId == null;

  @override
  void initState() {
    super.initState();
    _cargarMoneda();
    _cargarTodo();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ComboEditorPantalla oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comboId != widget.comboId) {
      _dirty = false;
      final reusarSinParpadeo = _esNuevo && _productos.isNotEmpty;
      _cargarTodo(mostrarCarga: !reusarSinParpadeo);
    }
  }

  Future<void> _cargarMoneda() async {
    final m = await Formatos.leerMoneda();
    if (!mounted) return;
    setState(() => _moneda = m);
  }

  Future<void> _cargarTodo({bool mostrarCarga = true}) async {
    if (mostrarCarga) {
      setState(() => _cargando = true);
    } else if (_esNuevo) {
      setState(() {
        _combo = null;
        _componentes = [];
        _nombreCtrl.text = '';
        _precioCtrl.text = '0.00';
        _activo = true;
        _dirty = true;
      });
    }

    try {
      final combo = _esNuevo
          ? null
          : await Proveedores.combosRepositorio.obtenerCombo(widget.comboId!);
      final comps = _esNuevo
          ? const <ComponenteCombo>[]
          : await Proveedores.combosRepositorio.listarComponentes(
              widget.comboId!,
            );
      final prods = await Proveedores.inventarioRepositorio.listarProductos(
        incluirInactivos: true,
      );

      if (!mounted) return;

      _combo = combo;
      _componentes = List.of(comps);
      _productos = List.of(prods);

      _nombreCtrl.text = combo?.nombre ?? '';
      _precioCtrl.text = ((combo?.precioVenta ?? 0.0)).toStringAsFixed(2);
      _activo = combo?.activo ?? true;

      _dirty = _esNuevo;

      setState(() => _cargando = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  double _parseNum(String t) {
    var s = t.trim();
    if (s.isEmpty) return 0.0;

    s = s.replaceAll(' ', '');
    if (s.contains('.') && s.contains(',')) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if (s.contains(',') && !s.contains('.')) {
      s = s.replaceAll(',', '.');
    }

    // sin escape redundante
    s = s.replaceAll(RegExp(r'[^0-9.\-]'), '');
    return double.tryParse(s) ?? 0.0;
  }

  void _marcarDirty() {
    if (_dirty) return;
    setState(() => _dirty = true);
  }

  Widget _miniaturaProducto(Producto? p) {
    if (p == null) return const Icon(Icons.inventory_2_outlined);

    final ruta = (p.imagen ?? '').trim();
    final ok = ruta.isNotEmpty && File(ruta).existsSync();

    if (ok) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(File(ruta), width: 34, height: 34, fit: BoxFit.cover),
      );
    }

    return const Icon(Icons.image_outlined);
  }

  List<Producto> _basesProducto(List<Producto> productos) {
    return productos.where((p) => p.productoPadreId == null).toList();
  }

  List<Producto> _variantesDeBase(List<Producto> productos, int? baseId) {
    if (baseId == null) return const [];
    return productos.where((p) => p.productoPadreId == baseId).toList();
  }

  Producto? _resolverProductoSeleccionado({
    required List<Producto> productos,
    required int? baseId,
    required int? varianteId,
  }) {
    if (baseId == null) return null;
    if (varianteId != null) {
      for (final p in productos) {
        if (p.id == varianteId) return p;
      }
    }
    for (final p in productos) {
      if (p.id == baseId) return p;
    }
    return null;
  }

  Future<void> _agregarComponente() async {
    if (_guardando) return;

    final activos = _productos.where((p) => p.activo).toList();
    if (activos.isEmpty) return;

    final bases = _basesProducto(activos);
    int? baseId;
    int? varianteId;
    List<Producto> variantes = const [];
    Producto? seleccionado;
    final cantidadCtrl = TextEditingController(text: '1');

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateLocal) {
            return AlertDialog(
              scrollable: true,
              title: const Text('Agregar producto al combo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Producto>(
                    initialValue: () {
                      if (baseId == null) return null;
                      for (final b in bases) {
                        if (b.id == baseId) return b;
                      }
                      return null;
                    }(),
                    isExpanded: true,
                    items: bases
                        .map(
                          (p) => DropdownMenuItem<Producto>(
                            value: p,
                            child: Row(
                              children: [
                                _miniaturaProducto(p),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    p.nombreConVariante,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (p) => setStateLocal(() {
                      baseId = p?.id;
                      variantes = _variantesDeBase(activos, baseId);
                      varianteId = null;
                      seleccionado = _resolverProductoSeleccionado(
                        productos: activos,
                        baseId: baseId,
                        varianteId: varianteId,
                      );
                    }),
                    decoration: const InputDecoration(
                      labelText: 'Producto base',
                    ),
                  ),
                  if (baseId != null && variantes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      initialValue: varianteId,
                      items: variantes
                          .map(
                            (p) => DropdownMenuItem<int>(
                              value: p.id,
                              child: Row(
                                children: [
                                  _miniaturaProducto(p),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      p.nombreConVariante,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (id) => setStateLocal(() {
                        varianteId = id;
                        seleccionado = _resolverProductoSeleccionado(
                          productos: activos,
                          baseId: baseId,
                          varianteId: varianteId,
                        );
                      }),
                      decoration: const InputDecoration(
                        labelText: 'Variante (opcional)',
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: cantidadCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;
    if (seleccionado == null) return;

    final cantidad = _parseNum(cantidadCtrl.text);
    if (cantidad == 0) return;

    setState(() {
      final pid = seleccionado!.id;
      final idx = _componentes.indexWhere((c) => c.productoId == pid);

      if (idx >= 0) {
        final actual = _componentes[idx];
        _componentes[idx] = ComponenteCombo(
          id: actual.id,
          comboId: actual.comboId,
          productoId: actual.productoId,
          cantidad: actual.cantidad + cantidad,
        );
      } else {
        _componentes.add(
          ComponenteCombo(
            id: 0,
            comboId: widget.comboId ?? 0,
            productoId: pid,
            cantidad: cantidad,
          ),
        );
      }

      _dirty = true;
    });
  }

  Future<void> _editarComponenteRapido(
    ComponenteCombo comp, {
    required Producto? producto,
  }) async {
    if (_guardando) return;

    final unidad = (producto?.unidad ?? '').trim();
    final cantidadCtrl = TextEditingController(
      text: comp.cantidad.toStringAsFixed(2),
    );

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                producto?.nombreConVariante ?? 'Editar componente',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cantidadCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: unidad.isEmpty ? 'Cantidad' : 'Cantidad ($unidad)',
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
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

    if (ok != true) return;
    final cantidad = _parseNum(cantidadCtrl.text);
    if (cantidad <= 0) return;

    setState(() {
      final idx = _componentes.indexWhere(
        (c) => c.productoId == comp.productoId,
      );
      if (idx < 0) return;
      final actual = _componentes[idx];
      _componentes[idx] = ComponenteCombo(
        id: actual.id,
        comboId: actual.comboId,
        productoId: actual.productoId,
        cantidad: cantidad,
      );
      _dirty = true;
    });
  }

  Future<void> _limpiarReceta() async {
    if (_guardando) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Limpiar receta'),
          content: const Text(
            'Esto borra todos los productos del combo (queda pendiente hasta guardar).',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Limpiar'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    setState(() {
      _componentes.clear();
      _dirty = true;
    });
  }

  Future<double> _calcularCapacidad(List<ComponenteCombo> componentes) async {
    if (componentes.isEmpty) return 0;

    double? capacidad;
    for (final c in componentes) {
      if (c.cantidad == 0) continue;
      final stock = await Proveedores.inventarioRepositorio.calcularStockActual(
        c.productoId,
      );
      final posible = stock / c.cantidad;
      capacidad = (capacidad == null)
          ? posible
          : (posible < capacidad ? posible : capacidad);
    }

    if (capacidad == null || capacidad.isInfinite || capacidad.isNaN) return 0;
    return capacidad.floorToDouble();
  }

  Future<void> _guardarCambios() async {
    if (_guardando) return;
    if (!_esNuevo && _combo == null) return;
    if (!_dirty) return;
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) return;
    final precio = _parseNum(_precioCtrl.text);
    if (precio < 0) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_esNuevo ? 'Crear combo' : 'Guardar cambios'),
          content: Text(
            _esNuevo
                ? 'Se va a crear el combo con esta receta. Seguro?'
                : 'Vas a actualizar el combo y su receta. Seguro?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
    if (ok != true) return;
    setState(() => _guardando = true);
    try {
      final comboId = _esNuevo
          ? await Proveedores.combosRepositorio.crearCombo(
              nombre: nombre,
              precioVenta: precio,
            )
          : widget.comboId!;
      await Proveedores.combosRepositorio.actualizarCombo(
        id: comboId,
        nombre: nombre,
        precioVenta: precio,
        activo: _activo,
      );
      await Proveedores.combosRepositorio.borrarComponentesDeCombo(comboId);
      for (final c in _componentes) {
        await Proveedores.combosRepositorio.agregarComponente(
          comboId: comboId,
          productoId: c.productoId,
          cantidad: c.cantidad,
        );
      }
      widget.onChanged?.call();
      if (!mounted) return;
      if (_esNuevo) {
        setState(() {
          _guardando = false;
          _dirty = false;
        });
        if (widget.embebido && widget.onCreado != null) {
          widget.onCreado!(comboId);
        } else {
          Navigator.pop(context, comboId);
        }
        return;
      }
      setState(() {
        _guardando = false;
        _dirty = false;
      });
      await _cargarTodo();
    } catch (_) {
      if (!mounted) return;
      setState(() => _guardando = false);
    }
  }

  Widget _headerEmbebido() {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _nombreCtrl.text.trim().isEmpty
                    ? (_esNuevo ? 'Nuevo combo' : 'Combo')
                    : _nombreCtrl.text.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (_esNuevo && widget.onCancelarCreacion != null)
              IconButton(
                onPressed: _guardando ? null : widget.onCancelarCreacion,
                icon: const Icon(Icons.close),
                tooltip: 'Cerrar',
              ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: _guardando ? null : _limpiarReceta,
              icon: Icon(Icons.delete_sweep_outlined, color: cs.error),
              label: Text('Limpiar', style: TextStyle(color: cs.error)),
            ),
            FilledButton.icon(
              onPressed: (_guardando || !_dirty) ? null : _guardarCambios,
              icon: const Icon(Icons.save),
              label: Text(
                _guardando
                    ? 'Guardando...'
                    : (_esNuevo ? 'Crear combo' : 'Guardar'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _body() {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (!_esNuevo && _combo == null) {
      return const Center(child: Text('Combo no encontrado'));
    }

    final porId = <int, Producto>{for (final p in _productos) p.id: p};
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (widget.embebido) _headerEmbebido(),

        Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _nombreCtrl,
                  enabled: !_guardando,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  onChanged: (_) => _marcarDirty(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _precioCtrl,
                  enabled: !_guardando,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Precio de venta ($_moneda)',
                  ),
                  onChanged: (_) => _marcarDirty(),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Activo'),
                  subtitle: Text(
                    'Si está apagado, no se puede vender',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  value: _activo,
                  onChanged: _guardando
                      ? null
                      : (v) {
                          setState(() {
                            _activo = v;
                            _dirty = true;
                          });
                        },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FutureBuilder<double>(
              future: _calcularCapacidad(_componentes),
              builder: (context, snapCap) {
                final cap = snapCap.data ?? 0;
                return Text('Podés armar: ${cap.toStringAsFixed(0)} combos');
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Productos', style: Theme.of(context).textTheme.titleMedium),
            FilledButton.icon(
              onPressed: _guardando ? null : _agregarComponente,
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_componentes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(child: Text('Agregá productos al combo')),
          )
        else
          for (final comp in _componentes) ...[
            Builder(
              builder: (context) {
                final pid = comp.productoId;
                final prod = porId[pid];
                final nombre = prod?.nombreConVariante ?? 'Producto $pid';
                final unidad = (prod?.unidad ?? '').trim();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Dismissible(
                    key: ValueKey('comp_$pid'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: Theme.of(context).colorScheme.error,
                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.onError,
                      ),
                    ),
                    confirmDismiss: (_) async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Borrar componente'),
                            content: Text(
                              'Borrar "$nombre" del combo? (queda pendiente)',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Borrar'),
                              ),
                            ],
                          );
                        },
                      );
                      return ok == true;
                    },
                    onDismissed: (_) {
                      setState(() {
                        _componentes.removeWhere((x) => x.productoId == pid);
                        _dirty = true;
                      });
                    },
                    child: Card(
                      child: ListTile(
                        leading: _miniaturaProducto(prod),
                        title: Text(
                          nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Cantidad: ${comp.cantidad.toStringAsFixed(2)} $unidad',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onTap: _guardando
                            ? null
                            : () =>
                                  _editarComponenteRapido(comp, producto: prod),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],

        const SizedBox(height: 10),

        if (!widget.embebido)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (_guardando || !_dirty) ? null : _guardarCambios,
              icon: const Icon(Icons.save),
              label: Text(
                _guardando
                    ? 'Guardando...'
                    : (_esNuevo ? 'Crear combo' : 'Guardar cambios'),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embebido) return _body();

    return Scaffold(
      appBar: AppBar(
        title: Text(_esNuevo ? 'Nuevo combo' : 'Editar combo'),
        actions: [
          IconButton(
            onPressed: _guardando ? null : _limpiarReceta,
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Limpiar receta',
          ),
        ],
      ),
      body: _body(),
    );
  }
}
