import 'dart:io';

import 'package:flutter/material.dart';

import 'package:gestion_de_stock/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_stock/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_stock/modulos/combos/modelos/combo.dart';
import 'package:gestion_de_stock/modulos/inventario/modelos/producto.dart';
import 'package:gestion_de_stock/modulos/ventas/modelos/venta.dart';
import 'package:gestion_de_stock/modulos/ventas/modelos/linea_venta.dart';

class VentaDetallePantalla extends StatefulWidget {
  final int ventaId;

  /// si true: no usa Scaffold/AppBar (para panel derecho en tablet)
  final bool embebido;

  /// callback opcional para avisar a la pantalla padre que cambió algo (ej: devolución)
  final VoidCallback? alCambiarAlgo;

  const VentaDetallePantalla({
    super.key,
    required this.ventaId,
    this.embebido = false,
    this.alCambiarAlgo,
  });

  @override
  State<VentaDetallePantalla> createState() => _VentaDetallePantallaState();
}

class _VentaDetallePantallaState extends State<VentaDetallePantalla> {
  String _moneda = r'$';

  @override
  void initState() {
    super.initState();
    _cargarMoneda();
  }

  @override
  void didUpdateWidget(covariant VentaDetallePantalla oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ventaId != widget.ventaId) {
      // fuerza rebuild “limpio” si cambió la venta seleccionada
      setState(() {});
    }
  }

  Future<void> _cargarMoneda() async {
    final m = await Formatos.leerMoneda();
    if (!mounted) return;
    setState(() => _moneda = m);
  }

  Future<Venta?> _venta() => Proveedores.ventasRepositorio.obtenerVenta(widget.ventaId);
  Future<List<LineaVenta>> _lineas() => Proveedores.ventasRepositorio.listarLineas(widget.ventaId);
  Future<List<Combo>> _combos() =>
      Proveedores.combosRepositorio.listarCombos(incluirInactivos: true);
  Future<List<Producto>> _productos() =>
      Proveedores.inventarioRepositorio.listarProductos(incluirInactivos: true);

  String _fecha(DateTime f) {
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${d2(f.day)}/${d2(f.month)}/${f.year} ${d2(f.hour)}:${d2(f.minute)}';
  }

  ({String resumen, String nota}) _separarNota(String? nota) {
    final t = (nota ?? '').trim();
    if (t.isEmpty) return (resumen: '', nota: '');

    final lineas = t.split('\n');
    final resumen = <String>[];
    final resto = <String>[];

    for (final l in lineas) {
      final x = l.trim();
      if (x.startsWith('Costo estimado') || x.startsWith('Margen estimado')) {
        resumen.add(x);
      } else {
        resto.add(l);
      }
    }

    return (resumen: resumen.join('\n').trim(), nota: resto.join('\n').trim());
  }

  Future<Map<int, _ProductoVendido>> _calcularProductosVendidos({
    required List<LineaVenta> lineas,
    required List<Combo> combos,
    required List<Producto> productos,
  }) async {
    final combosPorId = <int, Combo>{for (final c in combos) c.id: c};
    final prodPorId = <int, Producto>{for (final p in productos) p.id: p};

    final acumulado = <int, _ProductoVendido>{};

    for (final l in lineas) {
      final combo = combosPorId[l.comboId];
      if (combo == null) continue;

      final componentes = await Proveedores.combosRepositorio.listarComponentes(combo.id);

      for (final comp in componentes) {
        final cantidadVendida = comp.cantidad * l.cantidad;
        final prod = prodPorId[comp.productoId];

        final nombre = prod?.nombre ?? 'Producto ${comp.productoId}';
        final unidad = prod?.unidad ?? '';

        final actual = acumulado[comp.productoId];
        if (actual == null) {
          acumulado[comp.productoId] = _ProductoVendido(
            productoId: comp.productoId,
            nombre: nombre,
            unidad: unidad,
            cantidadVendida: cantidadVendida,
          );
        } else {
          acumulado[comp.productoId] = actual.copiarCon(
            cantidadVendida: actual.cantidadVendida + cantidadVendida,
          );
        }
      }
    }

    return acumulado;
  }

  Future<void> _procesarReclamo(
      BuildContext context, {
        required Venta venta,
        required Map<int, _ProductoVendido> vendidos,
      }) async {
    final esCancelada = (venta.nota ?? '').contains('VENTA CANCELADA');
    if (esCancelada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta venta ya está cancelada.')),
      );
      return;
    }

    final tipo = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Procesar reclamo'),
          content: const Text('Elegí el tipo de operación.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cerrar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 1),
              child: const Text('Devolución parcial'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 2),
              child: const Text('Devolución total'),
            ),
          ],
        );
      },
    );

    if (tipo == null) return;

    if (tipo == 2) {
      await _devolucionTotal(context, venta: venta, vendidos: vendidos);
      return;
    }

    await _devolucionParcial(context, venta: venta, vendidos: vendidos);
  }

  Future<void> _devolucionTotal(
      BuildContext context, {
        required Venta venta,
        required Map<int, _ProductoVendido> vendidos,
      }) async {
    bool reingresar = true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateLocal) {
            return AlertDialog(
              title: const Text('Devolución total'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Esto deja la venta en total 0 y revierte stock si corresponde.'),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Reingresar mercadería al inventario'),
                    value: reingresar,
                    onChanged: (v) => setStateLocal(() => reingresar = v),
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
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;

    if (reingresar) {
      for (final v in vendidos.values) {
        await Proveedores.inventarioRepositorio.crearMovimiento(
          productoId: v.productoId,
          tipo: 'devolucion',
          cantidad: v.cantidadVendida,
          nota: 'Devolución total venta ${widget.ventaId}',
          referencia: 'venta:${widget.ventaId}',
        );
      }
    }

    await Proveedores.ventasRepositorio.actualizarTotalVenta(
      ventaId: widget.ventaId,
      total: 0,
    );

    final notaAnterior = (venta.nota ?? '').trim();
    final marca = 'VENTA CANCELADA: devolución total. Reingreso: ${reingresar ? 'sí' : 'no'}.';
    final nuevaNota = notaAnterior.isEmpty ? marca : '$notaAnterior\n$marca';
    await Proveedores.ventasRepositorio.actualizarNotaVenta(
      ventaId: widget.ventaId,
      nota: nuevaNota,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Devolución total procesada')),
    );

    widget.alCambiarAlgo?.call();

    if (!widget.embebido) {
      Navigator.pop(context);
    } else {
      setState(() {});
    }
  }

  Future<void> _devolucionParcial(
      BuildContext context, {
        required Venta venta,
        required Map<int, _ProductoVendido> vendidos,
      }) async {
    final filas = vendidos.values.toList()..sort((a, b) => a.nombre.compareTo(b.nombre));

    final devolucion = <int, double>{};
    final reposicion = <int, double>{};
    final reingreso = <int, double>{};

    bool reingresarDevuelto = true;
    bool reponerAlCliente = true;

    final reintegroCtrl = TextEditingController(text: '0');

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateLocal) {
            Widget filaProducto(_ProductoVendido p) {
              final dev = devolucion[p.productoId] ?? 0;
              final rein = reingreso[p.productoId] ?? 0;
              final rep = reposicion[p.productoId] ?? 0;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('Vendido: ${p.cantidadVendida.toStringAsFixed(2)} ${p.unidad}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Devuelve'),
                              onChanged: (t) {
                                final v = double.tryParse(t.trim().replaceAll(',', '.')) ?? 0;
                                final val = v.clamp(0, p.cantidadVendida).toDouble();
                                setStateLocal(() {
                                  devolucion[p.productoId] = val;
                                  final r = (reingreso[p.productoId] ?? 0);
                                  if (r > val) reingreso[p.productoId] = val;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Reingresa'),
                              onChanged: (t) {
                                final devLocal = devolucion[p.productoId] ?? 0;
                                final v = double.tryParse(t.trim().replaceAll(',', '.')) ?? 0;
                                setStateLocal(() {
                                  reingreso[p.productoId] = v.clamp(0, devLocal).toDouble();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Reponés'),
                              onChanged: (t) {
                                final v = double.tryParse(t.trim().replaceAll(',', '.')) ?? 0;
                                setStateLocal(() {
                                  reposicion[p.productoId] =
                                      v.clamp(0, p.cantidadVendida).toDouble();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Actual: devuelve ${dev.toStringAsFixed(2)} • reingresa ${rein.toStringAsFixed(2)} • repone ${rep.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              );
            }

            return AlertDialog(
              title: const Text('Devolución parcial'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Reingresar al inventario lo devuelto en buen estado'),
                        subtitle: const Text('Si vuelve dañado, dejalo apagado'),
                        value: reingresarDevuelto,
                        onChanged: (v) => setStateLocal(() => reingresarDevuelto = v),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Reponer al cliente'),
                        subtitle: const Text('Si entregás reemplazo, dejalo encendido'),
                        value: reponerAlCliente,
                        onChanged: (v) => setStateLocal(() => reponerAlCliente = v),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: reintegroCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Monto a reintegrar (se descuenta del total) ($_moneda)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final p in filas) filaProducto(p),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Procesar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;

    for (final p in filas) {
      final rein = (reingreso[p.productoId] ?? 0);
      final rep = (reposicion[p.productoId] ?? 0);

      if (rein > 0) {
        await Proveedores.inventarioRepositorio.crearMovimiento(
          productoId: p.productoId,
          tipo: 'devolucion',
          cantidad: rein,
          nota: 'Devolución parcial (reingreso) venta ${widget.ventaId}',
          referencia: 'venta:${widget.ventaId}',
        );
      }

      if (rep > 0 && reponerAlCliente) {
        await Proveedores.inventarioRepositorio.crearMovimiento(
          productoId: p.productoId,
          tipo: 'egreso',
          cantidad: rep,
          nota: 'Reposición por reclamo venta ${widget.ventaId}',
          referencia: 'venta:${widget.ventaId}',
        );
      }
    }

    final reintegro = double.tryParse(reintegroCtrl.text.trim().replaceAll(',', '.')) ?? 0.0;
    final nuevoTotal = (venta.total - reintegro);
    await Proveedores.ventasRepositorio.actualizarTotalVenta(
      ventaId: widget.ventaId,
      total: nuevoTotal < 0 ? 0 : nuevoTotal,
    );

    final huboReposicionSinDevolucion = filas.any((p) {
      final dev = (devolucion[p.productoId] ?? 0);
      final rep = (reposicion[p.productoId] ?? 0);
      return rep > 0 && dev <= 0;
    });

    final notaAnterior = (venta.nota ?? '').trim();
    final marca =
        'RECLAMO: devolución parcial. Reingreso: ${reingresarDevuelto ? 'sí' : 'no'}. '
        'Reposición: ${reponerAlCliente ? 'sí' : 'no'}. '
        'Reintegro: ${Formatos.dinero(_moneda, reintegro)}.'
        '${huboReposicionSinDevolucion ? ' (Hubo reposición sin devolución)' : ''}';

    final nuevaNota = notaAnterior.isEmpty ? marca : '$notaAnterior\n$marca';
    await Proveedores.ventasRepositorio.actualizarNotaVenta(
      ventaId: widget.ventaId,
      nota: nuevaNota,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Devolución parcial procesada')),
    );

    widget.alCambiarAlgo?.call();

    if (!widget.embebido) {
      Navigator.pop(context);
    } else {
      setState(() {});
    }
  }

  String _resumenConMoneda(String resumen) {
    String arreglarLinea(String linea) {
      String poner(String etiqueta, String linea) {
        final idx = linea.indexOf(etiqueta);
        if (idx < 0) return linea;

        final inicio = idx + etiqueta.length;
        final fin = linea.indexOf(';', inicio);

        final textoNumero =
        (fin < 0 ? linea.substring(inicio) : linea.substring(inicio, fin)).trim();

        final n = double.tryParse(textoNumero.replaceAll(',', '.'));
        if (n == null) return linea;

        final reemplazo = ' ${Formatos.dinero(_moneda, n)}';

        if (fin < 0) {
          return linea.substring(0, inicio) + reemplazo;
        }
        return linea.substring(0, inicio) + reemplazo + linea.substring(fin);
      }

      var x = linea;
      x = poner('Costo estimado combo:', x);
      x = poner('Costo estimado total:', x);
      x = poner('Margen estimado:', x);
      x = poner('Reintegro:', x);
      return x;
    }

    return resumen.split('\n').map(arreglarLinea).join('\n');
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

  Widget _contenido() {
    return FutureBuilder<Venta?>(
      future: _venta(),
      builder: (context, snapV) {
        if (snapV.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final venta = snapV.data;
        if (venta == null) return const Center(child: Text('Venta no encontrada'));

        final partes = _separarNota(venta.nota);

        return FutureBuilder<List<LineaVenta>>(
          future: _lineas(),
          builder: (context, snapL) {
            if (snapL.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final lineas = snapL.data ?? [];

            return FutureBuilder<List<Combo>>(
              future: _combos(),
              builder: (context, snapC) {
                if (snapC.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final combos = snapC.data ?? [];

                return FutureBuilder<List<Producto>>(
                  future: _productos(),
                  builder: (context, snapP) {
                    if (snapP.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final productos = snapP.data ?? [];
                    final prodPorId = <int, Producto>{for (final p in productos) p.id: p};

                    return FutureBuilder<Map<int, _ProductoVendido>>(
                      future: _calcularProductosVendidos(
                        lineas: lineas,
                        combos: combos,
                        productos: productos,
                      ),
                      builder: (context, snapVendidos) {
                        final vendidos = snapVendidos.data ?? {};

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.embebido) ...[
                              Text(
                                'Detalle de venta',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                            ],
                            Row(
                              children: [
                                Expanded(child: Text('Fecha: ${_fecha(venta.fecha)}')),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: vendidos.isEmpty
                                      ? null
                                      : () => _procesarReclamo(
                                    context,
                                    venta: venta,
                                    vendidos: vendidos,
                                  ),
                                  child: const Text('Procesar reclamo'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Total: ${Formatos.dinero(_moneda, venta.total)}'),
                            const SizedBox(height: 12),

                            if (partes.resumen.isNotEmpty) ...[
                              Text(
                                'Resumen estimado',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(_resumenConMoneda(partes.resumen)),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            if (vendidos.isNotEmpty) ...[
                              Text(
                                'Productos vendidos',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: vendidos.values.map((v) {
                                      final prod = prodPorId[v.productoId];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        child: Row(
                                          children: [
                                            _miniaturaProducto(prod),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                '${v.nombre}: ${v.cantidadVendida.toStringAsFixed(2)} ${v.unidad}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            Text('Nota', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 6),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(partes.nota.isEmpty ? '-' : partes.nota),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text('Ítems', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),

                            Expanded(
                              child: lineas.isEmpty
                                  ? const Center(child: Text('Sin líneas'))
                                  : ListView.separated(
                                itemCount: lineas.length,
                                separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                                itemBuilder: (context, i) {
                                  final l = lineas[i];
                                  final combo = combos.firstWhere(
                                        (c) => c.id == l.comboId,
                                    orElse: () => Combo(
                                      id: l.comboId,
                                      nombre: 'Combo ${l.comboId}',
                                      precioVenta: 0,
                                      activo: true,
                                      creadoEn: DateTime.now(),
                                    ),
                                  );

                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                        combo.nombre,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        'Cantidad: ${l.cantidad.toStringAsFixed(2)}\n'
                                            'Precio: ${Formatos.dinero(_moneda, l.precioUnitario)}',
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
                          ],
                        );
                      },
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
    if (widget.embebido) {
      // en panel derecho: NO Scaffold
      return _contenido();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de venta')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _contenido(),
      ),
    );
  }
}

class _ProductoVendido {
  final int productoId;
  final String nombre;
  final String unidad;
  final double cantidadVendida;

  const _ProductoVendido({
    required this.productoId,
    required this.nombre,
    required this.unidad,
    required this.cantidadVendida,
  });

  _ProductoVendido copiarCon({double? cantidadVendida}) {
    return _ProductoVendido(
      productoId: productoId,
      nombre: nombre,
      unidad: unidad,
      cantidadVendida: cantidadVendida ?? this.cantidadVendida,
    );
  }
}