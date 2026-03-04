// lib/modulos/compras/pantallas/compra_nueva_pantalla.dart
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:gestion_de_stock/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_stock/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_stock/modulos/inventario/modelos/producto.dart';

class CompraNuevaPantalla extends StatefulWidget {
  const CompraNuevaPantalla({super.key});

  @override
  State<CompraNuevaPantalla> createState() => _CompraNuevaPantallaState();
}

class _CompraNuevaPantallaState extends State<CompraNuevaPantalla> {
  static const double _kTablet = 900;
  static const double _kMaxAnchoTablet = 620;

  String _moneda = r'$';

  final _proveedorCtrl = TextEditingController();
  final _notaCtrl = TextEditingController();

  final List<_LineaTmp> _lineas = [];

  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarMoneda();
  }

  Future<void> _cargarMoneda() async {
    final m = await Formatos.leerMoneda();
    if (!mounted) return;
    setState(() => _moneda = m);
  }

  @override
  void dispose() {
    _proveedorCtrl.dispose();
    _notaCtrl.dispose();
    super.dispose();
  }

  Future<List<Producto>> _cargarProductos() =>
      Proveedores.inventarioRepositorio.listarProductos(incluirInactivos: false);

  double get _total {
    double t = 0;
    for (final l in _lineas) {
      t += l.subtotal;
    }
    return t;
  }

  Widget _miniaturaProducto(Producto p) {
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

  Future<void> _agregarLinea() async {
    final productos = await _cargarProductos();
    if (!mounted) return;

    Producto? seleccionado;
    final cantidadCtrl = TextEditingController(text: '1');
    final costoCtrl = TextEditingController(text: '0');

    double? stockActual;
    double? costoActual;
    bool cargandoInfo = false;

    Future<void> cargarInfo(Producto p, void Function(void Function()) setStateLocal) async {
      setStateLocal(() {
        cargandoInfo = true;
        stockActual = null;
        costoActual = p.costoActual;
      });

      try {
        final stock = await Proveedores.inventarioRepositorio.calcularStockActual(p.id);
        setStateLocal(() {
          stockActual = stock;
          cargandoInfo = false;
        });
      } catch (_) {
        setStateLocal(() {
          stockActual = null;
          cargandoInfo = false;
        });
      }
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateLocal) {
            return AlertDialog(
              scrollable: true,
              title: const Text('Agregar producto'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Producto>(
                    initialValue: seleccionado,
                    isExpanded: true,
                    items: productos
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
                      return productos.map((p) {
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
                    onChanged: _guardando
                        ? null
                        : (p) {
                      setStateLocal(() => seleccionado = p);
                      if (p != null) {
                        costoCtrl.text = p.costoActual.toStringAsFixed(2);
                        cargarInfo(p, setStateLocal);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Producto'),
                  ),
                  const SizedBox(height: 12),
                  if (seleccionado != null) ...[
                    if (cargandoInfo)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Calculando stock...'),
                      )
                    else
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Stock actual: ${(stockActual ?? 0).toStringAsFixed(2)} ${seleccionado!.unidad}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Costo actual guardado: ${Formatos.dinero(_moneda, costoActual ?? 0)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: cantidadCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: costoCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: 'Costo unitario ($_moneda)'),
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

    final cant = double.tryParse(cantidadCtrl.text.trim().replaceAll(',', '.'));
    final costo = double.tryParse(costoCtrl.text.trim().replaceAll(',', '.'));

    if (cant == null || cant <= 0) return;
    if (costo == null || costo < 0) return;

    setState(() {
      final idx = _lineas.indexWhere((x) => x.productoId == seleccionado!.id);

      if (idx >= 0) {
        final actual = _lineas[idx];
        _lineas[idx] = _LineaTmp(
          productoId: actual.productoId,
          nombre: actual.nombre,
          unidad: actual.unidad,
          cantidad: actual.cantidad + cant,
          costoUnitario: costo,
          imagen: actual.imagen ?? seleccionado!.imagen,
        );
      } else {
        _lineas.add(
          _LineaTmp(
            productoId: seleccionado!.id,
            nombre: seleccionado!.nombre,
            unidad: seleccionado!.unidad,
            cantidad: cant,
            costoUnitario: costo,
            imagen: seleccionado!.imagen,
          ),
        );
      }
    });
  }

  void _borrarLinea(int index) {
    setState(() => _lineas.removeAt(index));
  }

  Future<void> _confirmarCompra() async {
    setState(() => _error = null);

    if (_lineas.isEmpty) {
      setState(() => _error = 'Agregá al menos un producto');
      return;
    }

    setState(() => _guardando = true);

    try {
      final compraId = await Proveedores.comprasRepositorio.crearCompra(
        proveedor: _proveedorCtrl.text.trim().isEmpty ? null : _proveedorCtrl.text.trim(),
        total: 0,
        nota: _notaCtrl.text.trim().isEmpty ? null : _notaCtrl.text.trim(),
      );

      double total = 0;

      for (final l in _lineas) {
        total += l.subtotal;

        await Proveedores.comprasRepositorio.agregarLinea(
          compraId: compraId,
          productoId: l.productoId,
          cantidad: l.cantidad,
          costoUnitario: l.costoUnitario,
        );

        await Proveedores.inventarioRepositorio.crearMovimiento(
          productoId: l.productoId,
          tipo: 'ingreso',
          cantidad: l.cantidad,
          nota: 'Compra',
          referencia: 'compra:$compraId',
        );

        final prod = await Proveedores.inventarioRepositorio.obtenerProducto(l.productoId);
        if (prod != null) {
          final stockAnterior = await Proveedores.inventarioRepositorio.calcularStockActual(prod.id);

          final double costoAnterior = prod.costoActual;
          final double comprado = l.cantidad;
          final double costoCompra = l.costoUnitario;

          final double stockNuevo = stockAnterior + comprado;

          double costoNuevo;
          if (stockAnterior <= 0 || costoAnterior <= 0) {
            costoNuevo = costoCompra;
          } else {
            costoNuevo = ((stockAnterior * costoAnterior) + (comprado * costoCompra)) / stockNuevo;
          }

          await Proveedores.inventarioRepositorio.actualizarProducto(
            id: prod.id,
            nombre: prod.nombre,
            unidad: prod.unidad,
            costoActual: costoNuevo,
            precioSugerido: prod.precioSugerido,
            stockMinimo: prod.stockMinimo,
            proveedor: prod.proveedor,
            activo: prod.activo,
          );
        }
      }

      await Proveedores.comprasRepositorio.actualizarTotalCompra(
        compraId: compraId,
        total: total,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      setState(() {
        _guardando = false;
        _error = 'No se pudo guardar la compra';
      });
    }
  }

  Widget _contenido(BuildContext context, {required bool esTablet}) {
    final inner = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        12,
        12,
        12,
        12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          TextField(
            controller: _proveedorCtrl,
            enabled: !_guardando,
            decoration: const InputDecoration(labelText: 'Proveedor (opcional)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notaCtrl,
            enabled: !_guardando,
            decoration: const InputDecoration(labelText: 'Nota (opcional)'),
          ),
          const SizedBox(height: 12),

          // BOTÓN ARRIBA (no flotante)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _guardando ? null : _agregarLinea,
              icon: const Icon(Icons.add),
              label: const Text('Agregar producto'),
            ),
          ),

          const SizedBox(height: 12),

          // LISTA dentro del scroll (no Expanded)
          if (_lineas.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 18),
              child: Center(child: Text('Agregá productos a la compra')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _lineas.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final l = _lineas[i];
                final ruta = (l.imagen ?? '').trim();
                final okImg = ruta.isNotEmpty && File(ruta).existsSync();

                return Dismissible(
                  key: ValueKey('linea_$i-${l.productoId}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: Theme.of(context).colorScheme.error,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _borrarLinea(i),
                  child: Card(
                    child: ListTile(
                      leading: okImg
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(ruta),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      )
                          : const Icon(Icons.image_outlined),
                      title: Text(
                        l.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Cantidad: ${l.cantidad.toStringAsFixed(2)} ${l.unidad}\n'
                            'Costo: ${Formatos.dinero(_moneda, l.costoUnitario)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        Formatos.dinero(_moneda, l.subtotal),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(child: Text('Total')),
              Text(
                Formatos.dinero(_moneda, _total),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _guardando ? null : _confirmarCompra,
              child: Text(_guardando ? 'Guardando...' : 'Confirmar compra'),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );

    if (!esTablet) return inner;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kMaxAnchoTablet),
        child: inner,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final esTablet = c.maxWidth >= _kTablet;

        return Scaffold(
          appBar: AppBar(title: const Text('Nueva compra')),
          body: SafeArea(
            child: _contenido(context, esTablet: esTablet),
          ),
        );
      },
    );
  }
}

class _LineaTmp {
  final int productoId;
  final String nombre;
  final String unidad;
  final double cantidad;
  final double costoUnitario;
  final String? imagen;

  const _LineaTmp({
    required this.productoId,
    required this.nombre,
    required this.unidad,
    required this.cantidad,
    required this.costoUnitario,
    required this.imagen,
  });

  double get subtotal => cantidad * costoUnitario;
}