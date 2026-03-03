import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gestion_de_stock/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_stock/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_stock/modulos/inventario/modelos/producto.dart';
import 'package:gestion_de_stock/modulos/combos/modelos/combo.dart';
import 'package:gestion_de_stock/modulos/combos/modelos/componente_combo.dart';

class ComboEditorPantalla extends StatefulWidget {
  final int comboId;

  /// si true: se usa embebido en tablet (panel derecho) sin Scaffold/AppBar
  final bool embebido;

  /// avisar al padre (lista) que cambió algo
  final VoidCallback? onChanged;

  const ComboEditorPantalla({
    super.key,
    required this.comboId,
    this.embebido = false,
    this.onChanged,
  });

  @override
  State<ComboEditorPantalla> createState() => _ComboEditorPantallaState();
}

class _ComboEditorPantallaState extends State<ComboEditorPantalla> {
  String _moneda = r'$';

  @override
  void initState() {
    super.initState();
    _cargarMoneda();
  }

  @override
  void didUpdateWidget(covariant ComboEditorPantalla oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comboId != widget.comboId) {
      setState(() {});
    }
  }

  Future<void> _cargarMoneda() async {
    final m = await Formatos.leerMoneda();
    if (!mounted) return;
    setState(() => _moneda = m);
  }

  Future<Combo?> _cargarCombo() => Proveedores.combosRepositorio.obtenerCombo(widget.comboId);

  Future<List<ComponenteCombo>> _cargarComponentes() =>
      Proveedores.combosRepositorio.listarComponentes(widget.comboId);

  Future<List<Producto>> _cargarProductos() =>
      Proveedores.inventarioRepositorio.listarProductos(incluirInactivos: true);

  Widget _miniaturaProducto(Producto? p) {
    if (p == null) return const Icon(Icons.inventory_2_outlined);

    final ruta = (p.imagen ?? '').trim();
    final ok = ruta.isNotEmpty && File(ruta).existsSync();

    if (ok) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(ruta),
          width: 34,
          height: 34,
          fit: BoxFit.cover,
        ),
      );
    }

    return const Icon(Icons.image_outlined);
  }

  Future<void> _editarCombo(Combo combo) async {
    final nombreCtrl = TextEditingController(text: combo.nombre);
    final precioCtrl = TextEditingController(text: combo.precioVenta.toStringAsFixed(2));
    bool activo = combo.activo;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateLocal) {
            return AlertDialog(
              scrollable: true,
              title: const Text('Editar combo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: precioCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: 'Precio de venta ($_moneda)'),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Activo'),
                    subtitle: const Text('Si está apagado, no se puede vender'),
                    value: activo,
                    onChanged: (v) => setStateLocal(() => activo = v),
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
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;

    final nombre = nombreCtrl.text.trim();
    if (nombre.isEmpty) return;

    final precio = double.tryParse(precioCtrl.text.trim().replaceAll(',', '.')) ?? 0.0;

    await Proveedores.combosRepositorio.actualizarCombo(
      id: combo.id,
      nombre: nombre,
      precioVenta: precio,
      activo: activo,
    );

    widget.onChanged?.call();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _agregarComponente() async {
    final productos = await _cargarProductos();
    if (!mounted) return;

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
                    initialValue: seleccionado,
                    isExpanded: true,
                    items: productos
                        .where((p) => p.activo)
                        .map(
                          (p) => DropdownMenuItem<Producto>(
                        value: p,
                        child: Row(
                          children: [
                            _miniaturaProducto(p),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                p.nombre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .toList(),
                    selectedItemBuilder: (context) {
                      final activos = productos.where((p) => p.activo).toList();
                      return activos.map((p) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              _miniaturaProducto(p),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  p.nombre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    onChanged: (p) => setStateLocal(() => seleccionado = p),
                    decoration: const InputDecoration(labelText: 'Producto'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cantidadCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

    final cantTxt = cantidadCtrl.text.trim().replaceAll(',', '.');
    final cantidad = double.tryParse(cantTxt);
    if (cantidad == null || cantidad == 0) return;

    await Proveedores.combosRepositorio.agregarComponente(
      comboId: widget.comboId,
      productoId: seleccionado!.id,
      cantidad: cantidad,
    );

    widget.onChanged?.call();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _borrarComponente(int componenteId) async {
    await Proveedores.combosRepositorio.borrarComponentePorId(componenteId);
    widget.onChanged?.call();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _limpiarReceta() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Limpiar receta'),
          content: const Text('Esto borra todos los productos del combo.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Borrar todo'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    await Proveedores.combosRepositorio.borrarComponentesDeCombo(widget.comboId);
    widget.onChanged?.call();
    if (!mounted) return;
    setState(() {});
  }

  Future<double> _calcularCapacidad(List<ComponenteCombo> componentes) async {
    if (componentes.isEmpty) return 0;

    double? capacidad;

    for (final c in componentes) {
      final stock = await Proveedores.inventarioRepositorio.calcularStockActual(c.productoId);
      final posible = stock / c.cantidad;
      capacidad = (capacidad == null) ? posible : (posible < capacidad ? posible : capacidad);
    }

    if (capacidad == null || capacidad.isInfinite || capacidad.isNaN) return 0;
    return capacidad.floorToDouble();
  }

  Widget _contenido() {
    return FutureBuilder<Combo?>(
      future: _cargarCombo(),
      builder: (context, snapC) {
        final combo = snapC.data;

        if (snapC.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (combo == null) return const Center(child: Text('Combo no encontrado'));

        return Padding(
          padding: widget.embebido ? EdgeInsets.zero : const EdgeInsets.all(12),
          child: FutureBuilder<List<ComponenteCombo>>(
            future: _cargarComponentes(),
            builder: (context, snapComp) {
              if (snapComp.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              final componentes = snapComp.data ?? [];

              return FutureBuilder<List<Producto>>(
                future: _cargarProductos(),
                builder: (context, snapProd) {
                  if (snapProd.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final productos = snapProd.data ?? [];
                  final porId = <int, Producto>{for (final p in productos) p.id: p};

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.embebido) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                combo.nombre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _editarCombo(combo),
                              icon: const Icon(Icons.edit),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              onPressed: _limpiarReceta,
                              icon: const Icon(Icons.delete_sweep_outlined),
                              tooltip: 'Limpiar receta',
                            ),
                            IconButton(
                              onPressed: () => setState(() {}),
                              icon: const Icon(Icons.refresh),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],

                      Text('Precio: ${Formatos.dinero(_moneda, combo.precioVenta)}'),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Activo'),
                        subtitle: const Text('Si está apagado, no se puede vender'),
                        value: combo.activo,
                        onChanged: (v) async {
                          await Proveedores.combosRepositorio.actualizarCombo(
                            id: combo.id,
                            nombre: combo.nombre,
                            precioVenta: combo.precioVenta,
                            activo: v,
                          );
                          widget.onChanged?.call();
                          if (!context.mounted) return;
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<double>(
                        future: _calcularCapacidad(componentes),
                        builder: (context, snapCap) {
                          final cap = snapCap.data ?? 0;
                          return Text('Podés armar: ${cap.toStringAsFixed(0)} combos');
                        },
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Componentes',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (widget.embebido)
                            FilledButton.icon(
                              onPressed: _agregarComponente,
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: componentes.isEmpty
                            ? const Center(child: Text('Agregá productos al combo'))
                            : ListView.separated(
                          itemCount: componentes.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final comp = componentes[i];
                            final prod = porId[comp.productoId];

                            final nombre = prod?.nombre ?? 'Producto ${comp.productoId}';
                            final unidad = prod?.unidad ?? '';

                            return Dismissible(
                              key: ValueKey('componente_${comp.id}'),
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
                                      content: Text('Borrar "$nombre" del combo?'),
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
                              onDismissed: (_) => _borrarComponente(comp.id),
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
                                  trailing: const Icon(Icons.swipe_left),
                                ),
                              ),
                            );
                          },
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

  @override
  Widget build(BuildContext context) {
    if (widget.embebido) {
      return _contenido();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar combo'),
        actions: [
          // el título real lo muestra el FutureBuilder en body, pero dejamos acciones acá
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregarComponente,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: _contenido(),
    );
  }
}