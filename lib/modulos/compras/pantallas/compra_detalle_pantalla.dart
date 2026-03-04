// lib/modulos/compras/pantallas/compra_detalle_pantalla.dart
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
  static const double _kTablet = 900;
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

  // -------- fecha estilo “venta detalle” --------

  String _mesCortoEs(int m) {
    const meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    if (m < 1 || m > 12) return '';
    return meses[m - 1];
  }

  String _fechaML(DateTime f) {
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${f.day}/${_mesCortoEs(f.month)} - ${d2(f.hour)}:${d2(f.minute)} hs';
  }

  // -------- UI: burbujas --------

  Widget _avatarFotoProducto(Producto? p) {
    const double lado = 49.0;
    const double radius = lado / 2;

    final ruta = (p?.imagen ?? '').trim();
    final ok = ruta.isNotEmpty && File(ruta).existsSync();

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ok
          ? ClipOval(
        child: Image.file(
          File(ruta),
          width: lado,
          height: lado,
          fit: BoxFit.cover,
        ),
      )
          : Icon(
        Icons.image_outlined,
        size: 22,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _stackAvatares(List<Widget> avs) {
    if (avs.isEmpty) return const SizedBox.shrink();

    const double bubble = 49.0;
    const double step = 35.0;

    final w = bubble + (avs.length - 1) * step;

    return SizedBox(
      width: w,
      height: bubble + 4,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < avs.length; i++)
            Positioned(
              left: i * step,
              top: 2,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: avs[i],
              ),
            ),
        ],
      ),
    );
  }

  List<int> _productoIdsUnicos(List<LineaCompra> lineas, {int max = 5}) {
    final out = <int>[];
    for (final l in lineas) {
      if (!out.contains(l.productoId)) out.add(l.productoId);
      if (out.length >= max) break;
    }
    return out;
  }

  Widget _tituloSeccion(String t) {
    return Text(
      t,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _miniaturaProducto(Producto? p) {
    final ruta = (p?.imagen ?? '').trim();
    final ok = ruta.isNotEmpty && File(ruta).existsSync();
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 34,
        height: 34,
        color: cs.surfaceContainerHighest,
        child: ok
            ? Image.file(File(ruta), fit: BoxFit.cover)
            : Icon(Icons.image_outlined, size: 18, color: cs.onSurfaceVariant),
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

  Widget _mobileBody({
    required Compra compra,
    required List<LineaCompra> lineas,
    required Map<int, Producto> prodPorId,
  }) {
    final cancelada = (compra.nota ?? '').contains('COMPRA CANCELADA');

    final avs = <Widget>[];
    for (final id in _productoIdsUnicos(lineas, max: 5)) {
      avs.add(_avatarFotoProducto(prodPorId[id]));
    }

    final totalTxt = Formatos.dinero(_moneda, compra.total);
    final fechaTxt = _fechaML(compra.fecha);
    final proveedor = (compra.proveedor ?? '').trim();
    final nota = (compra.nota ?? '').trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _stackAvatares(avs),
              const Spacer(),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: FilledButton(
                  onPressed: cancelada
                      ? null
                      : () => _cancelarCompra(
                    context,
                    compra: compra,
                    lineas: lineas,
                    prodPorId: prodPorId,
                  ),
                  child: const Text('Cancelar compra'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            totalTxt,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fechaTxt,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 18),

          _tituloSeccion('Proveedor'),
          const SizedBox(height: 6),
          Text(
            proveedor.isEmpty ? '-' : proveedor,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 18),
          _tituloSeccion('Nota'),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(nota.isEmpty ? '-' : nota),
            ),
          ),

          const SizedBox(height: 18),
          _tituloSeccion('Líneas'),
          const SizedBox(height: 8),

          if (lineas.isEmpty)
            Text('-', style: Theme.of(context).textTheme.bodyLarge)
          else
            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    for (int i = 0; i < lineas.length; i++) ...[
                      Builder(
                        builder: (_) {
                          final l = lineas[i];
                          final prod = prodPorId[l.productoId];
                          final nombre = (prod?.nombre ?? 'Producto ${l.productoId}').trim();
                          final unidad = (prod?.unidad ?? '').trim();

                          return Row(
                            children: [
                              _miniaturaProducto(prod),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  nombre.isEmpty ? '-' : nombre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${l.cantidad.toStringAsFixed(2)}${unidad.isEmpty ? '' : ' $unidad'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Costo: ${Formatos.dinero(_moneda, lineas[i].costoUnitario)}  •  Subtotal: ${Formatos.dinero(_moneda, lineas[i].subtotal)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (i != lineas.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tabletBody({
    required Compra compra,
    required List<LineaCompra> lineas,
    required Map<int, Producto> prodPorId,
  }) {
    final cancelada = (compra.nota ?? '').contains('COMPRA CANCELADA');
    final proveedor = (compra.proveedor ?? '').trim();
    final nota = (compra.nota ?? '').trim();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Formatos.dinero(_moneda, compra.total),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _fechaML(compra.fecha),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: cancelada
                          ? null
                          : () => _cancelarCompra(
                        context,
                        compra: compra,
                        lineas: lineas,
                        prodPorId: prodPorId,
                      ),
                      child: const Text('Cancelar compra'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _tituloSeccion('Proveedor'),
                  const SizedBox(height: 6),
                  Text(
                    proveedor.isEmpty ? '-' : proveedor,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 18),
                  _tituloSeccion('Nota'),
                  const SizedBox(height: 8),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(nota.isEmpty ? '-' : nota),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: lineas.isEmpty
                  ? const Center(child: Text('Sin líneas'))
                  : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: lineas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final l = lineas[i];
                  final prod = prodPorId[l.productoId];

                  final nombre = (prod?.nombre ?? 'Producto ${l.productoId}').trim();
                  final unidad = (prod?.unidad ?? '').trim();

                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      leading: _miniaturaProducto(prod),
                      title: Text(
                        nombre.isEmpty ? '-' : nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Cantidad: ${l.cantidad.toStringAsFixed(2)}${unidad.isEmpty ? '' : ' $unidad'}\n'
                            'Costo: ${Formatos.dinero(_moneda, l.costoUnitario)}',
                      ),
                      trailing: Text(
                        Formatos.dinero(_moneda, l.subtotal),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
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

                return LayoutBuilder(
                  builder: (context, c) {
                    final esTablet = c.maxWidth >= _kTablet;

                    return esTablet
                        ? _tabletBody(compra: compra, lineas: lineas, prodPorId: porId)
                        : _mobileBody(compra: compra, lineas: lineas, prodPorId: porId);
                  },
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
    if (widget.embebido) return _contenido();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de compra')),
      body: _contenido(),
    );
  }
}