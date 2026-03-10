// lib/modulos/reportes/pantallas/reporte_ventas_pantalla.dart
import 'package:flutter/material.dart';

import 'package:gestion_de_asistencias/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/layout_app.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/tablet_master_detail_layout.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/inventario/modelos/movimiento.dart';
import 'package:gestion_de_asistencias/modulos/ventas/modelos/venta.dart';
import 'package:gestion_de_asistencias/modulos/ventas/pantallas/venta_detalle_pantalla.dart';
import '../logica/reportes_controlador.dart';

class ReporteVentasPantalla extends StatefulWidget {
  final bool embebido;

  const ReporteVentasPantalla({super.key, this.embebido = false});

  @override
  State<ReporteVentasPantalla> createState() => _ReporteVentasPantallaState();
}

class _ReporteVentasPantallaState extends State<ReporteVentasPantalla> {
  static const double _kTablet = LayoutApp.kTablet;

  // ancho mÃ¡ximo cÃ³modo (como venÃ­s usando en otras pantallas)
  static const double _kMaxPageWidth = 1120;

  late final ReportesControlador _c;
  int _modo = 0; // 0: ventas por dÃ­a, 1: consumo neto
  String _moneda = r'$';

  // tablet: dÃ­a seleccionado (ISO yyyy-mm-dd)
  String? _isoSeleccionado;

  @override
  void initState() {
    super.initState();
    _c = ReportesControlador();
    _c.cargarTodo();
    _cargarMoneda();
  }

  Future<void> _cargarMoneda() async {
    final m = await Formatos.leerMoneda();
    if (!mounted) return;
    setState(() => _moneda = m);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String _bonitoFecha(String iso) {
    final p = iso.split('-');
    if (p.length != 3) return iso;
    return '${p[2]}/${p[1]}/${p[0]}';
  }

  DateTime? _isoAFecha(String iso) {
    final p = iso.split('-');
    if (p.length != 3) return null;
    final y = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    final d = int.tryParse(p[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  Widget _contenido(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        if (_c.cargando) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_c.error != null) return Center(child: Text(_c.error!));

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxPageWidth),
            child: Padding(
              padding: TabletMasterDetailLayout.kPagePadding,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(
                              value: 0,
                              label: Text('Ventas por dÃ­a'),
                            ),
                            ButtonSegment(
                              value: 1,
                              label: Text('Consumo neto'),
                            ),
                          ],
                          selected: {_modo},
                          onSelectionChanged: (s) {
                            setState(() {
                              _modo = s.first;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final esTablet = c.maxWidth >= _kTablet;

                        if (_modo == 0) {
                          if (!esTablet) return _vistaVentasMovil();
                          return _vistaVentasTablet();
                        }

                        return _vistaConsumo();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embebido) {
      return _contenido(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reporte')),
      body: _contenido(context),
    );
  }

  // -------------------
  // Ventas por dÃ­a: mÃ³vil (push a pantalla del dÃ­a)
  // -------------------
  Widget _vistaVentasMovil() {
    final datos = _c.ventasDia;
    if (datos.isEmpty) return const Center(child: Text('Sin datos'));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: datos.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final fila = datos[i];
          final iso = fila['fecha'] as String;
          final fecha = _bonitoFecha(iso);
          final subtotal = (fila['subtotal'] as double);

          return ListTile(
            title: Text(fecha),
            subtitle: const Text('TocÃ¡ para ver ventas del dÃ­a'),
            trailing: Text(Formatos.dinero(_moneda, subtotal)),
            onTap: () {
              final f = _isoAFecha(iso);
              if (f == null) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      _VentasDelDiaPantalla(fecha: f, moneda: _moneda),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // -------------------
  // Ventas por dÃ­a: tablet (master-detail en la misma pantalla)
  // -------------------
  Widget _vistaVentasTablet() {
    final datos = _c.ventasDia;
    if (datos.isEmpty) return const Center(child: Text('Sin datos'));

    final idValido =
        _isoSeleccionado != null &&
        datos.any((f) => (f['fecha'] as String) == _isoSeleccionado);
    final isoSel = idValido ? _isoSeleccionado : null;
    if (!idValido && _isoSeleccionado != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_isoSeleccionado != null &&
            !datos.any((f) => (f['fecha'] as String) == _isoSeleccionado)) {
          setState(() => _isoSeleccionado = null);
        }
      });
    }
    final fechaSel = isoSel == null ? null : _isoAFecha(isoSel);

    return TabletMasterDetailLayout(
      master: Card(
        clipBehavior: Clip.antiAlias,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: datos.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final fila = datos[i];
            final iso = fila['fecha'] as String;
            final subtotal = (fila['subtotal'] as double);
            final seleccionado = iso == isoSel;

            return InkWell(
              onTap: () => setState(() => _isoSeleccionado = iso),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                color: seleccionado
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.08)
                    : null,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _bonitoFecha(iso),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      Formatos.dinero(_moneda, subtotal),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      detail: fechaSel == null
          ? const Card(
              clipBehavior: Clip.antiAlias,
              child: Center(
                child: Text('Selecciona un dia para ver el detalle'),
              ),
            )
          : _VentasDelDiaPanel(fecha: fechaSel, moneda: _moneda),
    );
  }

  // -------------------
  // Consumo neto (sirve igual en mÃ³vil y tablet)
  // -------------------
  Widget _vistaConsumo() {
    final datos = _c.consumo;
    if (datos.isEmpty) {
      return const Center(child: Text('Sin consumo registrado'));
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: datos.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final fila = datos[i];
          final productoId = fila['productoId'] as int;
          final nombre = fila['nombre'] as String;
          final unidad = fila['unidad'] as String;
          final cantidad = fila['cantidad'] as double;

          final txt =
              '${cantidad >= 0 ? '+' : '-'}${Formatos.cantidad(cantidad.abs(), unidad: unidad)} $unidad';

          return ListTile(
            title: Text(nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: const Text('TocÃ¡ para ver movimientos'),
            trailing: Text(txt),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _MovimientosProductoDesdeReportePantalla(
                    productoId: productoId,
                    nombre: nombre,
                    unidad: unidad,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -------------------
// Pantalla del dÃ­a (mÃ³vil/tablet)
// - mÃ³vil: lista y navega al detalle al tocar
// - tablet: lista izq + detalle der (sin navegar)
// -------------------
class _VentasDelDiaPantalla extends StatelessWidget {
  final DateTime fecha;
  final String moneda;

  const _VentasDelDiaPantalla({required this.fecha, required this.moneda});

  static const double _kMaxPageWidth = 1120;

  String _fechaCorta(DateTime f) {
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${d2(f.day)}/${d2(f.month)}/${f.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ventas ${_fechaCorta(fecha)}')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kMaxPageWidth),
          child: Padding(
            padding: TabletMasterDetailLayout.kPagePadding,
            child: _VentasDelDiaPanel(fecha: fecha, moneda: moneda),
          ),
        ),
      ),
    );
  }
}

class _VentasDelDiaPanel extends StatefulWidget {
  final DateTime fecha;
  final String moneda;

  const _VentasDelDiaPanel({required this.fecha, required this.moneda});

  @override
  State<_VentasDelDiaPanel> createState() => _VentasDelDiaPanelState();
}

class _VentasDelDiaPanelState extends State<_VentasDelDiaPanel> {
  static const double _kTablet = LayoutApp.kTablet;

  int? _ventaSel;
  late Future<_VentasDiaData> _datosDiaFuture;

  @override
  void initState() {
    super.initState();
    _datosDiaFuture = _cargarDatosDia(widget.fecha);
  }

  @override
  void didUpdateWidget(covariant _VentasDelDiaPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_esMismoDia(oldWidget.fecha, widget.fecha)) {
      _ventaSel = null;
      _datosDiaFuture = _cargarDatosDia(widget.fecha);
    }
  }

  String _fechaCorta(DateTime f) {
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${d2(f.day)}/${d2(f.month)}/${f.year}';
  }

  String _fechaHora(DateTime f) {
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${d2(f.day)}/${d2(f.month)}/${f.year} ${d2(f.hour)}:${d2(f.minute)}';
  }

  bool _esMismoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<Map<int, double>> _subtotalesPorVenta(List<Venta> ventas) async {
    final out = <int, double>{};

    for (final v in ventas) {
      try {
        final lineas = await Proveedores.ventasRepositorio.listarLineas(v.id);
        double subtotal = 0;
        for (final l in lineas) {
          subtotal += l.subtotal;
        }
        out[v.id] = subtotal;
      } catch (_) {
        out[v.id] = v.total;
      }
    }

    return out;
  }

  Future<_VentasDiaData> _cargarDatosDia(DateTime fecha) async {
    final todas = await Proveedores.ventasRepositorio.listarVentas();
    final delDia = todas.where((v) => _esMismoDia(v.fecha, fecha)).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    final subtotales = await _subtotalesPorVenta(delDia);

    double totalDia = 0;
    for (final v in delDia) {
      totalDia += subtotales[v.id] ?? 0;
    }

    return _VentasDiaData(
      delDia: delDia,
      subtotales: subtotales,
      totalDia: totalDia,
    );
  }

  void _recargarDatosDia() {
    setState(() {
      _datosDiaFuture = _cargarDatosDia(widget.fecha);
    });
  }

  Widget _filaVenta({
    required bool esTablet,
    required Venta v,
    required double subtotal,
    required bool seleccionada,
  }) {
    final cs = Theme.of(context).colorScheme;
    final cancelada = (v.nota ?? '').contains('VENTA CANCELADA');

    return InkWell(
      onTap: () {
        if (esTablet) {
          setState(() => _ventaSel = v.id);
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VentaDetallePantalla(ventaId: v.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        color: seleccionada ? cs.primary.withValues(alpha: 0.08) : null,
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: cs.surfaceContainerHighest,
              child: Icon(
                cancelada ? Icons.block : Icons.receipt_long_outlined,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Formatos.dinero(widget.moneda, subtotal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cancelada ? cs.onSurfaceVariant : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _fechaHora(v.fecha),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_VentasDiaData>(
      future: _datosDiaFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final datos = snap.data;
        if (datos == null) {
          return const Center(child: Text('Sin datos'));
        }

        final delDia = datos.delDia;
        final subtotales = datos.subtotales;
        final totalDia = datos.totalDia;

        if (delDia.isEmpty) {
          return Center(
            child: Text('No hay ventas el ${_fechaCorta(widget.fecha)}'),
          );
        }

        final ventaValida =
            _ventaSel != null && delDia.any((x) => x.id == _ventaSel);
        if (!ventaValida && _ventaSel != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (_ventaSel != null && !delDia.any((x) => x.id == _ventaSel)) {
              setState(() => _ventaSel = null);
            }
          });
        }

        return LayoutBuilder(
          builder: (context, c) {
            final esTablet = c.maxWidth >= _kTablet;

            Widget header() {
              return Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: Text(
                    'Subtotal del dia (${_fechaCorta(widget.fecha)})',
                  ),
                  trailing: Text(Formatos.dinero(widget.moneda, totalDia)),
                ),
              );
            }

            if (!esTablet) {
              return Column(
                children: [
                  header(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        itemCount: delDia.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final v = delDia[i];
                          final subtotal = subtotales[v.id] ?? 0;
                          return _filaVenta(
                            esTablet: false,
                            v: v,
                            subtotal: subtotal,
                            seleccionada: false,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                header(),
                const SizedBox(height: 8),
                Expanded(
                  child: TabletMasterDetailLayout(
                    master: Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        itemCount: delDia.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final v = delDia[i];
                          final sel = v.id == _ventaSel;
                          final subtotal = subtotales[v.id] ?? 0;

                          return _filaVenta(
                            esTablet: true,
                            v: v,
                            subtotal: subtotal,
                            seleccionada: sel,
                          );
                        },
                      ),
                    ),
                    detail: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: _ventaSel == null
                            ? const Center(
                                child: Text(
                                  'Selecciona una venta para ver detalles',
                                ),
                              )
                            : VentaDetallePantalla(
                                ventaId: _ventaSel!,
                                embebido: true,
                                alCambiarAlgo: _recargarDatosDia,
                              ),
                      ),
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

class _VentasDiaData {
  final List<Venta> delDia;
  final Map<int, double> subtotales;
  final double totalDia;

  const _VentasDiaData({
    required this.delDia,
    required this.subtotales,
    required this.totalDia,
  });
}

class _MovimientosProductoDesdeReportePantalla extends StatelessWidget {
  final int productoId;
  final String nombre;
  final String unidad;

  const _MovimientosProductoDesdeReportePantalla({
    required this.productoId,
    required this.nombre,
    required this.unidad,
  });

  String _fecha(DateTime f) {
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${d2(f.day)}/${d2(f.month)}/${f.year} ${d2(f.hour)}:${d2(f.minute)}';
  }

  String _origen(Movimiento m) {
    final ref = (m.referencia ?? '').trim();
    final nota = (m.nota ?? '');

    if (nota.contains('CANCELADO')) return 'Cancelado';
    final esReversionAuto = RegExp(
      r'reversi[oÃ³]n \(auto\)',
      caseSensitive: false,
    ).hasMatch(nota);
    if (ref.startsWith('reversion_de:') || esReversionAuto) {
      return 'Cancelacion';
    }
    if (ref.startsWith('venta:')) return 'Venta';
    if (ref.startsWith('compra:')) return 'Compra';
    return 'Manual';
  }

  String _detalleOrigen(Movimiento m) {
    final ref = (m.referencia ?? '').trim();
    if (ref.isEmpty) return '-';
    return ref;
  }

  double _cantidadConSigno(Movimiento m) {
    if (m.tipo == 'egreso') return -m.cantidad;
    if (m.tipo == 'ingreso' || m.tipo == 'devolucion') return m.cantidad;
    return m.cantidad;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Padding(
            padding: TabletMasterDetailLayout.kPagePadding,
            child: FutureBuilder<List<Movimiento>>(
              future: Proveedores.inventarioRepositorio
                  .listarMovimientosDeProducto(productoId),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final movs = snap.data ?? [];
                if (movs.isEmpty) {
                  return const Center(child: Text('No hay movimientos'));
                }

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: movs.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final m = movs[i];

                      final origen = _origen(m);
                      final detalle = _detalleOrigen(m);

                      final v = _cantidadConSigno(m);
                      final txt =
                          '${v >= 0 ? '+' : '-'}${Formatos.cantidad(v.abs(), unidad: unidad)} $unidad';

                      final cancelado = (m.nota ?? '').contains('CANCELADO');

                      return ListTile(
                        title: Text(
                          origen,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${_fecha(m.fecha)}\n'
                          'Tipo: ${m.tipo}  -  Ref: $detalle\n'
                          '${m.nota ?? ''}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          txt,
                          style: TextStyle(
                            color: cancelado
                                ? Theme.of(context).disabledColor
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
