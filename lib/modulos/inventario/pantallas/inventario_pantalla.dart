// lib/modulos/inventario/pantallas/inventario_pantalla.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gestion_de_stock/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_stock/infraestructura/servicios/fotos_producto.dart';
import 'package:gestion_de_stock/modulos/inventario/logica/inventario_controlador.dart';
import 'package:gestion_de_stock/modulos/inventario/modelos/movimiento.dart';
import 'package:gestion_de_stock/modulos/inventario/modelos/producto.dart';
import 'package:gestion_de_stock/modulos/inventario/widgets/filtro_inventario.dart';
import 'package:gestion_de_stock/modulos/inventario/widgets/producto_tarjeta.dart';
import 'producto_detalle_pantalla.dart';

// ---------- Helpers globales (plural + mayúscula) ----------
String _capPrimera(String s) {
  final t = s.trim();
  if (t.isEmpty) return t;
  if (t.length == 1) return t.toUpperCase();
  return '${t[0].toUpperCase()}${t.substring(1)}';
}

String _unidadConCantidad(String unidad, double cantidad, {bool capitalizar = true}) {
  final u0 = unidad.trim();
  if (u0.isEmpty) return '';

  final low = u0.toLowerCase();
  final esUno = (cantidad - 1).abs() < 0.0000001;

  // si ya parece plural, no tocamos (solo capitalizamos si corresponde)
  final yaPlural = low.endsWith('s') || low.endsWith('es');
  if (esUno || yaPlural) return capitalizar ? _capPrimera(u0) : u0;

  // casos comunes
  String plural;
  if (low == 'unidad') {
    plural = 'unidades';
  } else if (low == 'pack') {
    plural = 'packs';
  } else if (low == 'caja') {
    plural = 'cajas';
  } else {
    // regla simple: vocal -> +s, consonante -> +es
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

  int _vista = 0; // 0: lista, 1: cuadrícula
  static const _prefVistaKey = 'inventario_vista'; // 0 o 1

  int? _seleccionadoId; // tablet master-detail

  @override
  void initState() {
    super.initState();
    _controlador = InventarioControlador();
    _controlador.cargar();
    _cargarVista();
  }

  Future<void> _cargarVista() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_prefVistaKey) ?? 0;
    if (!mounted) return;
    setState(() => _vista = (v == 1) ? 1 : 0);
  }

  Future<void> _guardarVista(int v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefVistaKey, v);
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _nuevoProductoCompleto() async {
    final id = await Navigator.push<int?>(
      context,
      MaterialPageRoute(builder: (_) => const _ProductoNuevoPantalla()),
    );

    if (!mounted) return;

    await _controlador.cargar();

    if (id != null) {
      final w = MediaQuery.of(context).size.width;
      if (w >= 900) {
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
      setState(() => _seleccionadoId = id);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductoDetallePantalla(productoId: id)),
    );
  }

  Widget _cabecera(estado) {
    return Column(
      children: [
        FiltroInventario(
          valor: estado.filtro,
          alCambiar: _controlador.cambiarFiltro,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Mostrar inactivos'),
          value: estado.mostrarInactivos,
          onChanged: _controlador.cambiarMostrarInactivos,
        ),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Lista')),
            ButtonSegment(value: 1, label: Text('Cuadrícula')),
          ],
          selected: {_vista},
          onSelectionChanged: (s) async {
            final v = s.first;
            setState(() => _vista = v);
            await _guardarVista(v);
          },
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _nuevoProductoCompleto,
            icon: const Icon(Icons.add),
            label: const Text('Nuevo producto'),
          ),
        ),
        const SizedBox(height: 12),
        if (estado.error != null) ...[
          Text(
            estado.error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 12),
        ],
      ],
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
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final esTabletDetalle = w >= 900;

            final lista = Padding(
              padding: const EdgeInsets.all(12),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _cabecera(estado)),
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
              ),
            );

            if (!esTabletDetalle) return lista;

            return Row(
              children: [
                Expanded(flex: 6, child: lista),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _PanelDetalleProducto(
                      productoId: _seleccionadoId,
                      alAbrirDetalle: (id) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductoDetallePantalla(productoId: id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
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
        child: Center(child: Text('Sin productos')),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final p = productos[index];

          return FutureBuilder<double>(
            future: Proveedores.inventarioRepositorio.calcularStockActual(p.id),
            builder: (context, snap) {
              final stock = snap.data ?? 0;
              return ProductoTarjeta(
                producto: p,
                stock: stock,
                alTocar: () => alTocar(p.id),
              );
            },
          );
        },
        childCount: productos.length,
      ),
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
        child: Center(child: Text('Sin productos')),
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
              childAspectRatio: 0.88,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, i) {
                final p = productos[i];

                return FutureBuilder<double>(
                  future: Proveedores.inventarioRepositorio.calcularStockActual(p.id),
                  builder: (context, snap) {
                    final stock = snap.data ?? 0;
                    return _ProductoCuadro(
                      producto: p,
                      stock: stock,
                      alTocar: () => alTocar(p.id),
                    );
                  },
                );
              },
              childCount: productos.length,
            ),
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
    final color = enFalta ? theme.colorScheme.error : theme.colorScheme.primary;

    final ruta = (producto.imagen ?? '').trim();
    final tieneImagen = ruta.isNotEmpty && File(ruta).existsSync();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: alTocar,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: tieneImagen
                        ? Image.file(File(ruta), fit: BoxFit.cover)
                        : Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 36,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                producto.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                '${stock.toStringAsFixed(2)} ${_unidadConCantidad(producto.unidad, stock)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(color: color),
              ),
              const SizedBox(height: 2),
              Text(
                enFalta ? 'Bajo mínimo' : 'OK',
                style: theme.textTheme.labelSmall?.copyWith(color: color),
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

  @override
  Widget build(BuildContext context) {
    if (productoId == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Elegí un producto para ver el detalle acá.',
            style: Theme.of(context).textTheme.titleMedium,
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
        if (p == null) return const Center(child: Text('Producto no encontrado'));

        return FutureBuilder<double>(
          future: Proveedores.inventarioRepositorio.calcularStockActual(p.id),
          builder: (context, snapS) {
            final stock = snapS.data ?? 0;
            final enFalta = stock < p.stockMinimo;
            final color = enFalta ? Theme.of(context).colorScheme.error : null;

            final ruta = (p.imagen ?? '').trim();
            final tieneImagen = ruta.isNotEmpty && File(ruta).existsSync();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            height: 170,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: tieneImagen
                                ? Image.file(File(ruta), fit: BoxFit.cover)
                                : const Center(child: Icon(Icons.image_outlined, size: 48)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                p.nombre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            FilledButton.tonal(
                              onPressed: () => alAbrirDetalle(p.id),
                              child: const Text('Abrir detalle'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Unidad: ${_capPrimera(p.unidad)}'),
                        const SizedBox(height: 6),
                        Text(
                          'Stock: ${stock.toStringAsFixed(2)} ${_unidadConCantidad(p.unidad, stock)}',
                          style: TextStyle(color: color),
                        ),
                        const SizedBox(height: 6),
                        Text('Mínimo: ${p.stockMinimo.toStringAsFixed(2)}'),
                        const SizedBox(height: 6),
                        Text('Proveedor: ${p.proveedor ?? '-'}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Movimientos', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Expanded(
                  child: FutureBuilder<List<Movimiento>>(
                    future: Proveedores.inventarioRepositorio.listarMovimientosDeProducto(p.id),
                    builder: (context, snapM) {
                      if (snapM.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final movs = snapM.data ?? [];
                      if (movs.isEmpty) {
                        return const Center(child: Text('Todavía no hay movimientos'));
                      }

                      String d2(int n) => n.toString().padLeft(2, '0');
                      String fecha(DateTime f) =>
                          '${d2(f.day)}/${d2(f.month)}/${f.year} ${d2(f.hour)}:${d2(f.minute)}';

                      String textoTipo(String tipo) {
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

                      double cantidadConSigno(Movimiento m) {
                        if (m.tipo == 'egreso') return -m.cantidad;
                        if (m.tipo == 'ingreso' || m.tipo == 'devolucion') return m.cantidad;
                        return m.cantidad;
                      }

                      return ListView.separated(
                        itemCount: movs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final m = movs[i];
                          final v = cantidadConSigno(m);
                          final txt =
                              '${v >= 0 ? '+' : '-'}${v.abs().toStringAsFixed(2)} ${_unidadConCantidad(p.unidad, v.abs())}';

                          final cancelado = (m.nota ?? '').contains('CANCELADO');

                          return Card(
                            child: ListTile(
                              title: Text(textoTipo(m.tipo)),
                              subtitle: Text(
                                '${fecha(m.fecha)}\n${m.nota ?? ''}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(
                                txt,
                                style: TextStyle(
                                  color: cancelado ? Theme.of(context).disabledColor : null,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ProductoNuevoPantalla extends StatefulWidget {
  const _ProductoNuevoPantalla();

  @override
  State<_ProductoNuevoPantalla> createState() => _ProductoNuevoPantallaState();
}

class _ProductoNuevoPantallaState extends State<_ProductoNuevoPantalla> {
  final _nombreCtrl = TextEditingController();

  // se mantiene para no romper el resto
  final _unidadCtrl = TextEditingController(text: 'unidad');

  final _minimoCtrl = TextEditingController(text: '0');
  final _costoCtrl = TextEditingController(text: '0');
  final _precioCtrl = TextEditingController(text: '0');
  final _proveedorCtrl = TextEditingController();

  static const _unidadesOpciones = <String>['unidad', 'pack', 'caja', 'kg', 'Otro'];
  String _unidadSeleccion = 'unidad';
  bool _usarOtro = false;

  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _unidadSeleccion = 'unidad';
    _usarOtro = false;
    _unidadCtrl.text = 'unidad';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _unidadCtrl.dispose();
    _minimoCtrl.dispose();
    _costoCtrl.dispose();
    _precioCtrl.dispose();
    _proveedorCtrl.dispose();
    super.dispose();
  }

  double _num(String t) => double.tryParse(t.trim().replaceAll(',', '.')) ?? 0.0;

  Future<int?> _preguntarFoto() async {
    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Foto del producto'),
          content: const Text('Querés agregar una foto ahora?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 0),
              child: const Text('Galería'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 1),
              child: const Text('Cámara'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _guardar() async {
    setState(() => _error = null);

    final nombre = _nombreCtrl.text.trim();
    final unidad = _unidadCtrl.text.trim();

    if (nombre.isEmpty) {
      setState(() => _error = 'Falta el nombre');
      return;
    }
    if (unidad.isEmpty) {
      setState(() => _error = 'Falta la unidad');
      return;
    }

    setState(() => _guardando = true);

    try {
      final id = await Proveedores.inventarioRepositorio.crearProducto(
        nombre: nombre,
        unidad: unidad,
        stockMinimo: _num(_minimoCtrl.text),
        costoActual: _num(_costoCtrl.text),
        precioSugerido: _num(_precioCtrl.text),
        proveedor: _proveedorCtrl.text.trim().isEmpty ? null : _proveedorCtrl.text.trim(),
      );

      if (!mounted) return;

      final opcion = await _preguntarFoto();
      if (opcion != null) {
        final ruta = await FotosProducto.elegirYGuardar(
          productoId: id,
          usarCamara: opcion == 1,
        );
        if (ruta != null) {
          await Proveedores.inventarioRepositorio.actualizarImagenProducto(
            id: id,
            imagen: ruta,
          );
        }
      }

      if (!mounted) return;
      Navigator.pop(context, id);
    } catch (_) {
      setState(() {
        _guardando = false;
        _error = 'No se pudo guardar';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo producto')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            12,
            12,
            12,
            12 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              TextField(
                controller: _nombreCtrl,
                enabled: !_guardando,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _unidadSeleccion,
                items: _unidadesOpciones
                    .map((u) => DropdownMenuItem<String>(
                  value: u,
                  child: Text(_capPrimera(u)),
                ))
                    .toList(),
                onChanged: _guardando
                    ? null
                    : (v) {
                  final val = v ?? 'unidad';
                  setState(() {
                    _unidadSeleccion = val;
                    _usarOtro = val == 'Otro';
                    if (!_usarOtro) {
                      _unidadCtrl.text = val; // se guarda en minúsculas
                    } else {
                      if (_unidadCtrl.text.trim().isEmpty ||
                          _unidadesOpciones.contains(_unidadCtrl.text.trim())) {
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
                  decoration: const InputDecoration(labelText: 'Unidad personalizada'),
                ),
              ],

              const SizedBox(height: 12),
              TextField(
                controller: _minimoCtrl,
                enabled: !_guardando,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Stock mínimo'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _costoCtrl,
                enabled: !_guardando,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Costo actual'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _precioCtrl,
                enabled: !_guardando,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Precio sugerido'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _proveedorCtrl,
                enabled: !_guardando,
                decoration: const InputDecoration(labelText: 'Proveedor (opcional)'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _guardando ? null : _guardar,
                  child: Text(_guardando ? 'Guardando...' : 'Guardar'),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}