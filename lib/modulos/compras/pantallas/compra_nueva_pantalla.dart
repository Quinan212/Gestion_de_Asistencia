// lib/modulos/compras/pantallas/compra_nueva_pantalla.dart
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:gestion_de_asistencias/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/layout_app.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/validaciones.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/inventario/modelos/producto.dart';

class CompraNuevaPantalla extends StatefulWidget {
  final bool embebido;
  final ValueChanged<int>? onCreada;
  final VoidCallback? onCancelar;

  const CompraNuevaPantalla({
    super.key,
    this.embebido = false,
    this.onCreada,
    this.onCancelar,
  });

  @override
  State<CompraNuevaPantalla> createState() => _CompraNuevaPantallaState();
}

class _CompraNuevaPantallaState extends State<CompraNuevaPantalla> {
  static const double _kTablet = LayoutApp.kTablet;
  static const double _kMaxAnchoTablet = 620;

  String _moneda = r'$';

  final _proveedorCtrl = TextEditingController();
  final _envioCtrl = TextEditingController(text: '0');
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
    _envioCtrl.dispose();
    _notaCtrl.dispose();
    super.dispose();
  }

  void _mostrarErrorValidacion(String mensaje) {
    if (!mounted) return;
    setState(() => _error = mensaje);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<List<Producto>> _cargarProductos() => Proveedores.inventarioRepositorio
      .listarProductos(incluirInactivos: false);

  double get _subtotal {
    double t = 0;
    for (final l in _lineas) {
      t += l.subtotal;
    }
    return t;
  }

  double get _envioMonto {
    final raw = _envioCtrl.text.trim().replaceAll(',', '.');
    final v = double.tryParse(raw);
    if (v == null || v < 0) return 0.0;
    return v;
  }

  double get _total => _subtotal + _envioMonto;

  Widget _miniaturaProducto(Producto p) {
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

  Future<void> _agregarLinea() async {
    final productos = await _cargarProductos();
    if (!mounted) return;

    final activos = productos.where((p) => p.activo).toList();
    final bases = _basesProducto(activos);

    Producto? seleccionado;
    int? baseId;
    int? varianteId;
    List<Producto> variantes = const [];
    final cantidadCtrl = TextEditingController(text: '1');
    final costoCtrl = TextEditingController(text: '0');

    double? stockActual;
    double? costoActual;
    bool cargandoInfo = false;

    Future<void> cargarInfo(
      Producto p,
      void Function(void Function()) setStateLocal,
    ) async {
      setStateLocal(() {
        cargandoInfo = true;
        stockActual = null;
        costoActual = p.costoActual;
      });

      try {
        final stock = await Proveedores.inventarioRepositorio
            .calcularStockActual(p.id);
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
                    onChanged: _guardando
                        ? null
                        : (p) {
                            setStateLocal(() {
                              baseId = p?.id;
                              variantes = _variantesDeBase(activos, baseId);
                              varianteId = null;
                              seleccionado = _resolverProductoSeleccionado(
                                productos: activos,
                                baseId: baseId,
                                varianteId: varianteId,
                              );
                            });
                            if (seleccionado != null) {
                              costoCtrl.text = seleccionado!.costoActual
                                  .toStringAsFixed(2);
                              cargarInfo(seleccionado!, setStateLocal);
                            }
                          },
                    decoration: const InputDecoration(
                      labelText: 'Producto base',
                    ),
                  ),
                  if (baseId != null && variantes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: varianteId,
                      isExpanded: true,
                      items: variantes
                          .map(
                            (v) => DropdownMenuItem<int>(
                              value: v.id,
                              child: Row(
                                children: [
                                  _miniaturaProducto(v),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      v.nombreConVariante,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _guardando
                          ? null
                          : (id) {
                              setStateLocal(() {
                                varianteId = id;
                                seleccionado = _resolverProductoSeleccionado(
                                  productos: activos,
                                  baseId: baseId,
                                  varianteId: varianteId,
                                );
                              });
                              if (seleccionado != null) {
                                costoCtrl.text = seleccionado!.costoActual
                                    .toStringAsFixed(2);
                                cargarInfo(seleccionado!, setStateLocal);
                              }
                            },
                      decoration: const InputDecoration(
                        labelText: 'Variante (opcional)',
                      ),
                    ),
                  ],
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
                          'Stock actual: ${Formatos.cantidad((stockActual ?? 0), unidad: seleccionado!.unidad)} ${seleccionado!.unidad}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Costo promedio actual: ${Formatos.dinero(_moneda, costoActual ?? 0)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: cantidadCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: costoCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Costo unitario ($_moneda)',
                    ),
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

    final errProducto = AppValidaciones.validarSeleccion(
      seleccionado,
      campo: 'Producto',
    );
    if (errProducto != null) {
      _mostrarErrorValidacion(errProducto);
      return;
    }

    final errCant = AppValidaciones.validarNumeroMayorQueCero(
      cantidadCtrl.text,
      campo: 'Cantidad',
    );
    if (errCant != null) {
      _mostrarErrorValidacion(errCant);
      return;
    }

    final errCosto = AppValidaciones.validarNumeroNoNegativo(
      costoCtrl.text,
      campo: 'Costo unitario',
    );
    if (errCosto != null) {
      _mostrarErrorValidacion(errCosto);
      return;
    }

    final cant = AppValidaciones.parseNumero(cantidadCtrl.text)!;
    final costo = AppValidaciones.parseNumero(costoCtrl.text)!;

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
            nombre: seleccionado!.nombreConVariante,
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

  Future<void> _editarLineaRapida(int index) async {
    if (_guardando || index < 0 || index >= _lineas.length) return;

    final linea = _lineas[index];
    final cantidadCtrl = TextEditingController(
      text: linea.cantidad.toStringAsFixed(2),
    );
    final costoCtrl = TextEditingController(
      text: linea.costoUnitario.toStringAsFixed(2),
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
                linea.nombre,
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
                  labelText: 'Cantidad (${linea.unidad})',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: costoCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Costo unitario ($_moneda)',
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

    final errCant = AppValidaciones.validarNumeroMayorQueCero(
      cantidadCtrl.text,
      campo: 'Cantidad',
    );
    if (errCant != null) {
      _mostrarErrorValidacion(errCant);
      return;
    }

    final errCosto = AppValidaciones.validarNumeroNoNegativo(
      costoCtrl.text,
      campo: 'Costo unitario',
    );
    if (errCosto != null) {
      _mostrarErrorValidacion(errCosto);
      return;
    }

    final cant = AppValidaciones.parseNumero(cantidadCtrl.text)!;
    final costo = AppValidaciones.parseNumero(costoCtrl.text)!;

    setState(() {
      if (index < 0 || index >= _lineas.length) return;
      final actual = _lineas[index];
      _lineas[index] = _LineaTmp(
        productoId: actual.productoId,
        nombre: actual.nombre,
        unidad: actual.unidad,
        cantidad: cant,
        costoUnitario: costo,
        imagen: actual.imagen,
      );
    });
  }

  Future<void> _confirmarCompra() async {
    setState(() => _error = null);

    if (_lineas.isEmpty) {
      setState(() => _error = 'Agrega al menos un producto');
      return;
    }

    final errEnvio = AppValidaciones.validarNumeroNoNegativo(
      _envioCtrl.text,
      campo: 'Envio o cargo adicional',
    );
    if (errEnvio != null) {
      setState(() => _error = errEnvio);
      return;
    }

    final envioMonto = _envioMonto;

    setState(() => _guardando = true);

    try {
      final compraId = await Proveedores.comprasRepositorio.crearCompra(
        proveedor: _proveedorCtrl.text.trim().isEmpty
            ? null
            : _proveedorCtrl.text.trim(),
        envioMonto: envioMonto,
        total: 0,
        nota: _notaCtrl.text.trim().isEmpty ? null : _notaCtrl.text.trim(),
      );

      double total = 0;

      for (final l in _lineas) {
        total += l.subtotal;

        final prod = await Proveedores.inventarioRepositorio.obtenerProducto(
          l.productoId,
        );
        final stockAnterior = (prod == null)
            ? 0.0
            : await Proveedores.inventarioRepositorio.calcularStockActual(
                prod.id,
              );

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

        if (prod != null) {
          final double costoAnterior = prod.costoActual;
          final double comprado = l.cantidad;
          final double costoCompra = l.costoUnitario;
          final double stockNuevo = stockAnterior + comprado;

          double costoNuevo;
          if (stockAnterior <= 0 || costoAnterior <= 0 || stockNuevo <= 0) {
            costoNuevo = costoCompra;
          } else {
            costoNuevo =
                ((stockAnterior * costoAnterior) + (comprado * costoCompra)) /
                stockNuevo;
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
        total: total + envioMonto,
      );

      if (!mounted) return;
      Proveedores.notificarDatosActualizados();
      if (widget.embebido && widget.onCreada != null) {
        widget.onCreada!(compraId);
      } else {
        Navigator.pop(context, compraId);
      }
    } catch (_) {
      if (!mounted) return;
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
            decoration: const InputDecoration(
              labelText: 'Proveedor (opcional)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notaCtrl,
            enabled: !_guardando,
            decoration: const InputDecoration(labelText: 'Nota (opcional)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _envioCtrl,
            enabled: !_guardando,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Envio o cargo adicional ($_moneda)',
            ),
          ),
          const SizedBox(height: 12),

          // BOTON ARRIBA (no flotante)
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
              child: Center(child: Text('Agrega productos a la compra')),
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
                        'Cantidad: ${Formatos.cantidad(l.cantidad, unidad: l.unidad)} ${l.unidad}\n'
                        'Costo: ${Formatos.dinero(_moneda, l.costoUnitario)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        Formatos.dinero(_moneda, l.subtotal),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      onTap: _guardando ? null : () => _editarLineaRapida(i),
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(child: Text('Subtotal productos')),
              Text(
                Formatos.dinero(_moneda, _subtotal),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(child: Text('Envio / cargo adicional')),
              Text(
                Formatos.dinero(_moneda, _envioMonto),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(child: Text('Total final')),
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
        final body = SafeArea(child: _contenido(context, esTablet: esTablet));
        if (widget.embebido) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
                    child: Row(
                      children: [
                        Text(
                          'Nueva compra',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _guardando ? null : widget.onCancelar,
                          icon: const Icon(Icons.close),
                          tooltip: 'Cerrar',
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(child: body),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Nueva compra')),
          body: body,
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
