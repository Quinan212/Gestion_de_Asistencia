// lib/modulos/compras/pantallas/compra_detalle_pantalla.dart
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:gestion_de_asistencias/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/layout_app.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/tablet_master_detail_layout.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/compras/modelos/compra.dart';
import 'package:gestion_de_asistencias/modulos/compras/modelos/linea_compra.dart';
import 'package:gestion_de_asistencias/modulos/inventario/modelos/producto.dart';

class CompraDetallePantalla extends StatefulWidget {
  final int compraId;

  /// si true: no usa Scaffold/AppBar (para panel derecho en tablet)
  final bool embebido;

  /// callback opcional para avisar a la pantalla padre que cambio algo (ej: cancelacion)
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
  static const double _kTablet = LayoutApp.kTablet;
  String _moneda = r'$';
  late Future<Compra?> _compraF;
  late Future<List<LineaCompra>> _lineasF;
  late Future<List<Producto>> _productosF;

  @override
  void initState() {
    super.initState();
    _cargarMoneda();
    _refrescar();
  }

  @override
  void didUpdateWidget(covariant CompraDetallePantalla oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.compraId != widget.compraId) {
      setState(_refrescar);
    }
  }

  Future<void> _cargarMoneda() async {
    final m = await Formatos.leerMoneda();
    if (!mounted) return;
    setState(() => _moneda = m);
  }

  Future<Compra?> _compra() =>
      Proveedores.comprasRepositorio.obtenerCompra(widget.compraId);
  Future<List<LineaCompra>> _lineas() =>
      Proveedores.comprasRepositorio.listarLineas(widget.compraId);
  Future<List<Producto>> _productos() =>
      Proveedores.inventarioRepositorio.listarProductos(incluirInactivos: true);

  void _refrescar() {
    _compraF = _compra();
    _lineasF = _lineas();
    _productosF = _productos();
  }

  // -------- fecha estilo "venta detalle" --------

  String _mesCortoEs(int m) {
    const meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
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

  double _subtotalProductos(List<LineaCompra> lineas) {
    double total = 0.0;
    for (final linea in lineas) {
      total += linea.subtotal;
    }
    return total;
  }

  double _extraHistoricoNoIdentificado(
    Compra compra,
    List<LineaCompra> lineas,
  ) {
    final diferencia = compra.total - _subtotalProductos(lineas);
    if (!diferencia.isFinite) return 0.0;
    if (diferencia.abs() < 0.0000001) return 0.0;
    if (compra.envioMonto.abs() > 0.0000001) return 0.0;
    return diferencia;
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
        const SnackBar(content: Text('Esta compra ya esta cancelada.')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar compra'),
          content: const Text(
            'Esto revierte el stock (crea egresos) y deja el total en 0.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Si, cancelar'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    final totalAnterior = compra.total;
    final notaAnteriorOriginal = compra.nota;

    for (final l in lineas) {
      final prod = prodPorId[l.productoId];
      final nombre = prod?.nombreConVariante ?? 'Producto ${l.productoId}';

      await Proveedores.inventarioRepositorio.crearMovimiento(
        productoId: l.productoId,
        tipo: 'egreso',
        cantidad: l.cantidad,
        nota: 'Cancelacion de compra ${widget.compraId} ($nombre)',
        referencia: 'compra:${widget.compraId}',
      );
    }

    await Proveedores.comprasRepositorio.actualizarTotalCompra(
      compraId: widget.compraId,
      total: 0,
    );

    final notaAnterior = (compra.nota ?? '').trim();
    final marca = 'COMPRA CANCELADA: reversion de stock aplicada.';
    final notaNueva = notaAnterior.isEmpty ? marca : '$notaAnterior\n$marca';

    await Proveedores.comprasRepositorio.actualizarNotaCompra(
      compraId: widget.compraId,
      nota: notaNueva,
    );

    if (!context.mounted) return;
    Proveedores.notificarDatosActualizados();
    widget.alCambiarAlgo?.call();
    setState(_refrescar);

    final messenger = ScaffoldMessenger.of(context);
    bool deshacer = false;
    messenger.hideCurrentSnackBar();
    await messenger
        .showSnackBar(
          SnackBar(
            content: const Text('Compra cancelada'),
            action: SnackBarAction(
              label: 'Deshacer',
              onPressed: () => deshacer = true,
            ),
            duration: const Duration(seconds: 7),
          ),
        )
        .closed;

    if (!context.mounted) return;

    if (!deshacer) {
      if (!widget.embebido) Navigator.pop(context);
      return;
    }

    try {
      for (final l in lineas) {
        final prod = prodPorId[l.productoId];
        final nombre = prod?.nombreConVariante ?? 'Producto ${l.productoId}';

        await Proveedores.inventarioRepositorio.crearMovimiento(
          productoId: l.productoId,
          tipo: 'ingreso',
          cantidad: l.cantidad,
          nota: 'Deshacer cancelacion de compra ${widget.compraId} ($nombre)',
          referencia: 'compra:${widget.compraId}',
        );
      }

      await Proveedores.comprasRepositorio.actualizarTotalCompra(
        compraId: widget.compraId,
        total: totalAnterior,
      );
      await Proveedores.comprasRepositorio.actualizarNotaCompra(
        compraId: widget.compraId,
        nota: notaAnteriorOriginal,
      );

      if (!context.mounted) return;
      Proveedores.notificarDatosActualizados();
      widget.alCambiarAlgo?.call();
      setState(_refrescar);
      messenger.showSnackBar(
        const SnackBar(content: Text('Cancelacion deshecha')),
      );
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo deshacer la cancelacion')),
      );
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

    final subtotalProductos = cancelada ? 0.0 : _subtotalProductos(lineas);
    final envioMonto = cancelada ? 0.0 : compra.envioMonto;
    final extraHistorico = cancelada
        ? 0.0
        : _extraHistoricoNoIdentificado(compra, lineas);
    final tieneEnvio = envioMonto.abs() > 0.0000001;
    final tieneExtraHistorico = extraHistorico.abs() > 0.0000001;
    final totalTxt = Formatos.dinero(_moneda, subtotalProductos);
    final fechaTxt = _fechaML(compra.fecha);
    final proveedor = (compra.proveedor ?? '').trim();
    final nota = (compra.nota ?? '').trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, c) {
              final angosto = c.maxWidth < 430;

              final botonCancelar = Tooltip(
                message: 'Cancelar compra',
                child: FilledButton(
                  onPressed: cancelada
                      ? null
                      : () => _cancelarCompra(
                          context,
                          compra: compra,
                          lineas: lineas,
                          prodPorId: prodPorId,
                        ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(140, 44),
                  ),
                  child: const Text('Cancelar compra'),
                ),
              );

              if (angosto) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _stackAvatares(avs),
                    const SizedBox(height: 10),
                    SizedBox(width: double.infinity, child: botonCancelar),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _stackAvatares(avs),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: botonCancelar,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          Text(
            totalTxt,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (tieneEnvio) ...[
            const SizedBox(height: 6),
            Text(
              'Envio ${Formatos.dinero(_moneda, envioMonto)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (tieneExtraHistorico) ...[
            const SizedBox(height: 6),
            Text(
              'Cargo historico no identificado ${Formatos.dinero(_moneda, extraHistorico)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
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
          _tituloSeccion('Descripcion de la compra '),
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
                          final nombre =
                              (prod?.nombreConVariante ??
                                      'Producto ${l.productoId}')
                                  .trim();
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
                                '${Formatos.cantidad(l.cantidad, unidad: unidad)}${unidad.isEmpty ? '' : ' $unidad'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Costo: ${Formatos.dinero(_moneda, lineas[i].costoUnitario)}  -  Subtotal: ${Formatos.dinero(_moneda, lineas[i].subtotal)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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
    final subtotalProductos = cancelada ? 0.0 : _subtotalProductos(lineas);
    final envioMonto = cancelada ? 0.0 : compra.envioMonto;
    final extraHistorico = cancelada
        ? 0.0
        : _extraHistoricoNoIdentificado(compra, lineas);
    final tieneEnvio = envioMonto.abs() > 0.0000001;
    final tieneExtraHistorico = extraHistorico.abs() > 0.0000001;

    return Padding(
      padding: TabletMasterDetailLayout.kPagePadding,
      child: TabletMasterDetailLayout(
        master: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Formatos.dinero(_moneda, subtotalProductos),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (tieneEnvio) ...[
                const SizedBox(height: 6),
                Text(
                  'Envio: ${Formatos.dinero(_moneda, envioMonto)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (tieneExtraHistorico) ...[
                const SizedBox(height: 6),
                Text(
                  'Cargo historico no identificado: ${Formatos.dinero(_moneda, extraHistorico)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
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
                child: Tooltip(
                  message: 'Cancelar compra',
                  child: FilledButton(
                    onPressed: cancelada
                        ? null
                        : () => _cancelarCompra(
                            context,
                            compra: compra,
                            lineas: lineas,
                            prodPorId: prodPorId,
                          ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(140, 44),
                    ),
                    child: const Text('Cancelar compra'),
                  ),
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
        detail: Card(
          clipBehavior: Clip.antiAlias,
          child: lineas.isEmpty
              ? const Center(child: Text('Sin lineas'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: lineas.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final l = lineas[i];
                    final prod = prodPorId[l.productoId];

                    final nombre = (prod?.nombreConVariante ?? 'Producto ')
                        .trim();
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
                          'Cantidad: ${Formatos.cantidad(l.cantidad, unidad: unidad)}${unidad.isEmpty ? '' : ' $unidad'}\n'
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
    );
  }

  Widget _contenido() {
    return FutureBuilder<Compra?>(
      future: _compraF,
      builder: (context, snapC) {
        if (snapC.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final compra = snapC.data;
        if (compra == null) {
          return const Center(child: Text('Compra no encontrada'));
        }

        return FutureBuilder<List<LineaCompra>>(
          future: _lineasF,
          builder: (context, snapL) {
            if (snapL.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final lineas = snapL.data ?? [];

            return FutureBuilder<List<Producto>>(
              future: _productosF,
              builder: (context, snapP) {
                if (snapP.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final productos = snapP.data ?? [];
                final porId = <int, Producto>{
                  for (final p in productos) p.id: p,
                };

                return LayoutBuilder(
                  builder: (context, c) {
                    final esTablet = c.maxWidth >= _kTablet;

                    return esTablet
                        ? _tabletBody(
                            compra: compra,
                            lineas: lineas,
                            prodPorId: porId,
                          )
                        : _mobileBody(
                            compra: compra,
                            lineas: lineas,
                            prodPorId: porId,
                          );
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
