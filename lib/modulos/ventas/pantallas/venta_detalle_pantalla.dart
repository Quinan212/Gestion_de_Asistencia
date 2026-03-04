// lib/modulos/ventas/pantallas/venta_detalle_pantalla.dart
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
  static const double _kTablet = 900;
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
  Future<List<Combo>> _combos() => Proveedores.combosRepositorio.listarCombos(incluirInactivos: true);
  Future<List<Producto>> _productos() =>
      Proveedores.inventarioRepositorio.listarProductos(incluirInactivos: true);

  Future<bool> _ventaCancelada(Venta v) async {
    final nota = (v.nota ?? '').toUpperCase();
    if (nota.contains('VENTA CANCELADA')) return true;

    // si el pedido está cancelado y apunta a esta venta => mostrar cancelada igual
    return Proveedores.pedidosRepositorio.ventaEstaCancelada(v.id);
  }

  // -------- fecha estilo ML --------

  String _mesCortoEs(int m) {
    const meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    if (m < 1 || m > 12) return '';
    return meses[m - 1];
  }

  String _fechaML(DateTime f) {
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${f.day}/${_mesCortoEs(f.month)} - ${d2(f.hour)}:${d2(f.minute)} hs';
  }

  // -------- nota: campos (cliente/pago/envio) --------

  String _extraerCampoNota(String? nota, List<String> etiquetas) {
    final t = (nota ?? '').trim();
    if (t.isEmpty) return '';
    for (final et in etiquetas) {
      final re = RegExp('${RegExp.escape(et)}\\s*([^•\\n]+)', caseSensitive: false);
      final m = re.firstMatch(t);
      final v = (m?.group(1) ?? '').trim();
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  String _clienteDesdeNota(String? nota) => _extraerCampoNota(nota, const ['Cliente:', 'cliente:']);

  String _pagoDesdeNota(String? nota) =>
      _extraerCampoNota(nota, const ['Pago:', 'Medio de pago:', 'medio de pago:']);

  String _envioDesdeNota(String? nota) =>
      _extraerCampoNota(nota, const ['Envío:', 'Envio:', 'Cargo por envío:', 'Cargo envio:']);

  double _parseMonto(String t) {
    var s = t.trim();
    if (s.isEmpty) return 0.0;

    s = s.replaceAll(_moneda, '').replaceAll(' ', '');
    s = s.replaceAll(RegExp(r'[^0-9\.,\-]'), '');
    if (s.isEmpty) return 0.0;

    final hasDot = s.contains('.');
    final hasComma = s.contains(',');

    if (hasDot && hasComma) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if (hasComma && !hasDot) {
      s = s.replaceAll(',', '.');
    }

    return double.tryParse(s) ?? 0.0;
  }

  // -------- vendidos (componentes del/los combos) --------

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

  // -------- UI: avatar grande + “burbujas” de fotos --------

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

  Widget _avatarComboTilde() {
    const double lado = 49.0;
    const double radius = lado / 2;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.check,
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

  Widget _thumbProducto(Producto? p) {
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

  List<_ProductoVendido> _topVendidos(Map<int, _ProductoVendido> vendidos, int max) {
    final lista = vendidos.values.toList()..sort((a, b) => b.cantidadVendida.compareTo(a.cantidadVendida));
    if (lista.length <= max) return lista;
    return lista.sublist(0, max);
  }

  // -------- pago: icono --------

  IconData _iconoPago(String medio) {
    final m = medio.trim().toLowerCase();
    if (m.contains('efect')) return Icons.payments_outlined;
    if (m.contains('tarj')) return Icons.credit_card_outlined;
    if (m.contains('transf')) return Icons.swap_horiz;
    return Icons.account_balance_wallet_outlined;
  }

  Widget _tituloSeccion(String t) {
    return Text(
      t,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _bannerCancelada() {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.block, color: cs.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'VENTA CANCELADA',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: cs.onErrorContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------- MOBILE: layout --------

  Widget _mobileBody({
    required Venta venta,
    required bool cancelada,
    required List<LineaVenta> lineas,
    required List<Combo> combos,
    required List<Producto> productos,
    required Map<int, _ProductoVendido> vendidos,
  }) {
    final prodPorId = <int, Producto>{for (final p in productos) p.id: p};

    final avs = <Widget>[];
    if (vendidos.isNotEmpty) {
      for (final v in _topVendidos(vendidos, 5)) {
        avs.add(_avatarFotoProducto(prodPorId[v.productoId]));
      }
    } else {
      final n = lineas.length.clamp(0, 5);
      for (int i = 0; i < n; i++) {
        avs.add(_avatarComboTilde());
      }
    }

    final envioTxt = _envioDesdeNota(venta.nota);
    final envioMonto = _parseMonto(envioTxt);
    final tieneEnvio = envioTxt.isNotEmpty && envioMonto.abs() > 0.0000001;

    final totalTxt = Formatos.dinero(_moneda, venta.total);
    final fechaTxt = _fechaML(venta.fecha);

    final pago = _pagoDesdeNota(venta.nota);
    final cliente = _clienteDesdeNota(venta.nota);

    final filasDesc = vendidos.values.toList()..sort((a, b) => a.nombre.compareTo(b.nombre));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cancelada) ...[
            _bannerCancelada(),
            const SizedBox(height: 12),
          ],
          Row(children: [_stackAvatares(avs)]),
          const SizedBox(height: 12),
          Text(
            totalTxt,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              decoration: cancelada ? TextDecoration.lineThrough : null,
              color: cancelada ? Theme.of(context).colorScheme.onSurfaceVariant : null,
            ),
          ),
          if (tieneEnvio) ...[
            const SizedBox(height: 6),
            Text(
              'Cargo por envío  ${Formatos.dinero(_moneda, envioMonto)}',
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
          _tituloSeccion('Medio de pago'),
          const SizedBox(height: 6),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  _iconoPago(pago.isEmpty ? '-' : pago),
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pago.isEmpty ? '-' : pago,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _tituloSeccion('Cliente'),
          const SizedBox(height: 6),
          Text(
            cliente.isEmpty ? '-' : cliente,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 18),
          _tituloSeccion('Descripción de la venta'),
          const SizedBox(height: 8),
          if (filasDesc.isEmpty)
            Text('-', style: Theme.of(context).textTheme.bodyLarge)
          else
            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    for (int i = 0; i < filasDesc.length; i++) ...[
                      Row(
                        children: [
                          _thumbProducto(prodPorId[filasDesc[i].productoId]),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              filasDesc[i].nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${filasDesc[i].cantidadVendida.toStringAsFixed(2)} ${filasDesc[i].unidad}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (i != filasDesc.length - 1) const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // -------- TABLET --------

  Widget _tabletBodyViejo({
    required Venta venta,
    required bool cancelada,
    required List<LineaVenta> lineas,
    required List<Combo> combos,
    required List<Producto> productos,
    required Map<int, _ProductoVendido> vendidos,
  }) {
    final partes = _separarNota(venta.nota);

    final envioTxt = _envioDesdeNota(venta.nota);
    final envioMonto = _parseMonto(envioTxt);
    final tieneEnvio = envioTxt.isNotEmpty && envioMonto.abs() > 0.0000001;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (cancelada) ...[
            _bannerCancelada(),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha: ${_fechaML(venta.fecha)}'),
                        const SizedBox(height: 8),
                        Text(
                          'Total: ${Formatos.dinero(_moneda, venta.total)}',
                          style: TextStyle(
                            decoration: cancelada ? TextDecoration.lineThrough : null,
                            color: cancelada ? Theme.of(context).colorScheme.onSurfaceVariant : null,
                          ),
                        ),
                        if (tieneEnvio) ...[
                          const SizedBox(height: 6),
                          Text('Envío: ${Formatos.dinero(_moneda, envioMonto)}'),
                        ],
                        const SizedBox(height: 12),
                        if (partes.resumen.isNotEmpty) ...[
                          Text('Resumen estimado', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(_resumenConMoneda(partes.resumen)),
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 6,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: lineas.isEmpty
                          ? const Center(child: Text('Sin líneas'))
                          : ListView.separated(
                        itemCount: lineas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
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

                          return ListTile(
                            title: Text(combo.nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                              'Cantidad: ${l.cantidad.toStringAsFixed(2)}\n'
                                  'Precio: ${Formatos.dinero(_moneda, l.precioUnitario)}',
                            ),
                            trailing: Text(
                              Formatos.dinero(_moneda, l.subtotal),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------- util resumen --------

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

  String _resumenConMoneda(String resumen) {
    String arreglarLinea(String linea) {
      String poner(String etiqueta, String linea) {
        final idx = linea.indexOf(etiqueta);
        if (idx < 0) return linea;

        final inicio = idx + etiqueta.length;
        final fin = linea.indexOf(';', inicio);

        final textoNumero = (fin < 0 ? linea.substring(inicio) : linea.substring(inicio, fin)).trim();

        final n = double.tryParse(textoNumero.replaceAll(',', '.'));
        if (n == null) return linea;

        final reemplazo = ' ${Formatos.dinero(_moneda, n)}';

        if (fin < 0) return linea.substring(0, inicio) + reemplazo;
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

  // -------- contenido --------

  Widget _contenido() {
    return FutureBuilder<Venta?>(
      future: _venta(),
      builder: (context, snapV) {
        if (snapV.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final venta = snapV.data;
        if (venta == null) return const Center(child: Text('Venta no encontrada'));

        return FutureBuilder<bool>(
          future: _ventaCancelada(venta),
          builder: (context, snapCancel) {
            final cancelada = snapCancel.data ?? false;

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

                        return FutureBuilder<Map<int, _ProductoVendido>>(
                          future: _calcularProductosVendidos(
                            lineas: lineas,
                            combos: combos,
                            productos: productos,
                          ),
                          builder: (context, snapVendidos) {
                            final vendidos = snapVendidos.data ?? {};

                            return LayoutBuilder(
                              builder: (context, c) {
                                final esTablet = c.maxWidth >= _kTablet;

                                return esTablet
                                    ? _tabletBodyViejo(
                                  venta: venta,
                                  cancelada: cancelada,
                                  lineas: lineas,
                                  combos: combos,
                                  productos: productos,
                                  vendidos: vendidos,
                                )
                                    : _mobileBody(
                                  venta: venta,
                                  cancelada: cancelada,
                                  lineas: lineas,
                                  combos: combos,
                                  productos: productos,
                                  vendidos: vendidos,
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embebido) return _contenido();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de venta')),
      body: _contenido(),
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