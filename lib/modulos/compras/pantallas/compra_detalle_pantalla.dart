import 'dart:io';

import 'package:flutter/material.dart';

import 'package:gestion_de_stock/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_stock/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_stock/modulos/compras/modelos/compra.dart';
import 'package:gestion_de_stock/modulos/compras/modelos/linea_compra.dart';
import 'package:gestion_de_stock/modulos/inventario/modelos/producto.dart';

class CompraDetallePantalla extends StatefulWidget {
  final int compraId;

  /// si true: no usa Scaffold/AppBar (para panel derecho en tablet)
  final bool embebido;

  /// callback opcional para avisar a la pantalla padre que cambió algo (ej: cancelación)
  final VoidCallback? alCambiarAlgo;

  const CompraDetallePantalla({
    super.key,
    required this.compraId,
    this.embebido = false,
    this.alCambiarAlgo,
  });

  @override
  State<CompraDetallePantalla> createState() => _CompraDetallePantallaState();
}

class _CompraDetallePantallaState extends State<CompraDetallePantalla> {
  String _moneda = r'$';

  @override
  void initState() {
    super.initState();
    _cargarMoneda();
  }

  @override
  void didUpdateWidget(covariant CompraDetallePantalla oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.compraId != widget.compraId) {
      setState(() {});
    }
  }

  Future<void> _cargarMoneda() async {
    final m = await Formatos.leerMoneda();
    if (!mounted) return;
    setState(() => _moneda = m);
  }

  Future<Compra?> _compra() => Proveedores.comprasRepositorio.obtenerCompra(widget.compraId);
  Future<List<LineaCompra>> _lineas() => Proveedores.comprasRepositorio.listarLineas(widget.compraId);
  Future<List<Producto>> _productos() =>
      Proveedores.inventarioRepositorio.listarProductos(incluirInactivos: true);

  String _fecha(DateTime f) {
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${d2(f.day)}/${d2(f.month)}/${f.year} ${d2(f.hour)}:${d2(f.minute)}';
  }

  Widget _miniaturaProducto(Producto? p) {
    final ruta = (p?.imagen ?? '').trim();
    final ok = ruta.isNotEmpty && File(ruta).existsSync();

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 44,
        height: 44,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: ok
            ? Image.file(File(ruta), fit: BoxFit.cover)
            : Icon(Icons.image_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }

  Future<void> _cancelarCompra(
      BuildContext context, {
        required Compra compra,
        required List<LineaCompra> lineas,
        required Map<int, Producto> prodPorId,
      }) async {
    final yaCancelada = (compra.nota ?? '').contains('COMPRA CANCELADA');
    if (yaCancelada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta compra ya está cancelada.')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar compra'),
          content: const Text('Esto revierte el stock (crea egresos) y deja el total en 0.'),
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

    for (final l in lineas) {
      final prod = prodPorId[l.productoId];
      final nombre = prod?.nombre ?? 'Producto ${l.productoId}';

      await Proveedores.inventarioRepositorio.crearMovimiento(
        productoId: l.productoId,
        tipo: 'egreso',
        cantidad: l.cantidad,
        nota: 'Cancelación de compra ${widget.compraId} ($nombre)',
        referencia: 'compra:${widget.compraId}',
      );
    }

    await Proveedores.comprasRepositorio.actualizarTotalCompra(
      compraId: widget.compraId,
      total: 0,
    );

    final notaAnterior = (compra.nota ?? '').trim();
    final marca = 'COMPRA CANCELADA: reversión de stock aplicada.';
    final notaNueva = notaAnterior.isEmpty ? marca : '$notaAnterior\n$marca';

    await Proveedores.comprasRepositorio.actualizarNotaCompra(
      compraId: widget.compraId,
      nota: notaNueva,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compra cancelada')),
    );

    widget.alCambiarAlgo?.call();

    if (!widget.embebido) {
      Navigator.pop(context);
    } else {
      setState(() {});
    }
  }

  Widget _contenido() {
    return FutureBuilder<Compra?>(
      future: _compra(),
      builder: (context, snapC) {
        if (snapC.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final compra = snapC.data;
        if (compra == null) return const Center(child: Text('Compra no encontrada'));

        return FutureBuilder<List<LineaCompra>>(
          future: _lineas(),
          builder: (context, snapL) {
            if (snapL.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final lineas = snapL.data ?? [];

            return FutureBuilder<List<Producto>>(
              future: _productos(),
              builder: (context, snapP) {
                if (snapP.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final productos = snapP.data ?? [];
                final porId = <int, Producto>{for (final p in productos) p.id: p};

                final cancelada = (compra.nota ?? '').contains('COMPRA CANCELADA');

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.embebido) ...[
                      Text(
                        'Detalle de compra',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Expanded(child: Text('Fecha: ${_fecha(compra.fecha)}')),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: cancelada
                              ? null
                              : () => _cancelarCompra(
                            context,
                            compra: compra,
                            lineas: lineas,
                            prodPorId: porId,
                          ),
                          child: const Text('Cancelar compra'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Total: ${Formatos.dinero(_moneda, compra.total)}'),
                    const SizedBox(height: 6),
                    Text('Proveedor: ${compra.proveedor ?? '-'}'),
                    const SizedBox(height: 12),
                    Text('Nota', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text((compra.nota ?? '').trim().isEmpty ? '-' : compra.nota!),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Líneas', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Expanded(
                      child: lineas.isEmpty
                          ? const Center(child: Text('Sin líneas'))
                          : ListView.separated(
                        itemCount: lineas.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final l = lineas[i];
                          final prod = porId[l.productoId];

                          final nombre = prod?.nombre ?? 'Producto ${l.productoId}';
                          final unidad = prod?.unidad ?? '';

                          return Card(
                            child: ListTile(
                              leading: _miniaturaProducto(prod),
                              title: Text(
                                nombre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                'Cantidad: ${l.cantidad.toStringAsFixed(2)} $unidad\n'
                                    'Costo: ${Formatos.dinero(_moneda, l.costoUnitario)}',
                              ),
                              trailing: Text(Formatos.dinero(_moneda, l.subtotal)),
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
      appBar: AppBar(title: const Text('Detalle de compra')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _contenido(),
      ),
    );
  }
}