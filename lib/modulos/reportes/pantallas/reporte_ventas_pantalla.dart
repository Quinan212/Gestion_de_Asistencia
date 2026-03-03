import 'package:flutter/material.dart';

import 'package:gestion_de_stock/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_stock/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_stock/infraestructura/servicios/exportacion_csv.dart';
import 'package:gestion_de_stock/modulos/inventario/modelos/movimiento.dart';
import 'package:gestion_de_stock/modulos/ventas/modelos/venta.dart';
import 'package:gestion_de_stock/modulos/ventas/pantallas/venta_detalle_pantalla.dart';
import '../logica/reportes_controlador.dart';

class ReporteVentasPantalla extends StatefulWidget {
  final bool embebido;

  const ReporteVentasPantalla({super.key, this.embebido = false});

  @override
  State<ReporteVentasPantalla> createState() => _ReporteVentasPantallaState();
}

class _ReporteVentasPantallaState extends State<ReporteVentasPantalla> {
  static const double _kTablet = 900;

  late final ReportesControlador _c;
  int _modo = 0; // 0: ventas por día, 1: consumo neto
  String _moneda = r'$';

  // tablet: día seleccionado
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

  Future<void> _exportar() async {
    try {
      if (_modo == 0) {
        final datos = _c.ventasDia;
        if (datos.isEmpty) return;

        final filas = datos.map((fila) {
          return [
            (fila['fecha'] as String),
            (fila['total'] as double).toStringAsFixed(2),
          ];
        }).toList();

        final path = await ExportacionCsv.guardarCsv(
          nombreBase: 'ventas_por_dia',
          encabezados: ['fecha', 'total'],
          filas: filas,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV guardado: $path')),
        );
      } else {
        final datos = _c.consumo;
        if (datos.isEmpty) return;

        final filas = datos.map((fila) {
          final cantidad = fila['cantidad'] as double;
          return [
            (fila['nombre'] as String),
            (fila['unidad'] as String),
            cantidad.toStringAsFixed(2),
          ];
        }).toList();

        final path = await ExportacionCsv.guardarCsv(
          nombreBase: 'consumo_neto_30_dias',
          encabezados: ['producto', 'unidad', 'consumo_neto_30_dias'],
          filas: filas,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV guardado: $path')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo exportar')),
      );
    }
  }

  Widget _contenido(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        if (_c.cargando) return const Center(child: CircularProgressIndicator());
        if (_c.error != null) return Center(child: Text(_c.error!));

        // auto-select en tablet (si no hay seleccionado todavía)
        if (_modo == 0) {
          final datos = _c.ventasDia;
          if (datos.isNotEmpty && _isoSeleccionado == null) {
            _isoSeleccionado = datos.first['fecha'] as String;
          }
        }

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 0, label: Text('Ventas por día')),
                        ButtonSegment(value: 1, label: Text('Consumo neto')),
                      ],
                      selected: {_modo},
                      onSelectionChanged: (s) {
                        setState(() {
                          _modo = s.first;
                          // si volvemos a ventas por día, aseguramos selección
                          if (_modo == 0 && _isoSeleccionado == null && _c.ventasDia.isNotEmpty) {
                            _isoSeleccionado = _c.ventasDia.first['fecha'] as String;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _exportar,
                    icon: const Icon(Icons.download_outlined),
                    tooltip: 'Exportar CSV',
                  ),
                  IconButton(
                    onPressed: _c.cargarTodo,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refrescar',
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
      appBar: AppBar(
        title: const Text('Reporte'),
        actions: [
          IconButton(
            onPressed: _exportar,
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Exportar CSV',
          ),
          IconButton(
            onPressed: _c.cargarTodo,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _contenido(context),
    );
  }

  // -------------------
  // Ventas por día: móvil (push a pantalla del día)
  // -------------------
  Widget _vistaVentasMovil() {
    final datos = _c.ventasDia;
    if (datos.isEmpty) return const Center(child: Text('Sin datos'));

    return ListView.separated(
      itemCount: datos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final fila = datos[i];
        final iso = fila['fecha'] as String;
        final fecha = _bonitoFecha(iso);
        final total = (fila['total'] as double);

        return Card(
          child: ListTile(
            title: Text(fecha),
            subtitle: const Text('Tocá para ver ventas del día'),
            trailing: Text(Formatos.dinero(_moneda, total)),
            onTap: () {
              final f = _isoAFecha(iso);
              if (f == null) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _VentasDelDiaPantalla(
                    fecha: f,
                    moneda: _moneda,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // -------------------
  // Ventas por día: tablet (master-detail en la misma pantalla)
  // -------------------
  Widget _vistaVentasTablet() {
    final datos = _c.ventasDia;
    if (datos.isEmpty) return const Center(child: Text('Sin datos'));

    final isoSel = _isoSeleccionado ?? (datos.first['fecha'] as String);
    final fechaSel = _isoAFecha(isoSel) ?? DateTime.now();

    return Row(
      children: [
        SizedBox(
          width: 360,
          child: ListView.separated(
            itemCount: datos.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final fila = datos[i];
              final iso = fila['fecha'] as String;
              final total = (fila['total'] as double);
              final seleccionado = iso == isoSel;

              return Card(
                child: ListTile(
                  selected: seleccionado,
                  title: Text(_bonitoFecha(iso)),
                  trailing: Text(Formatos.dinero(_moneda, total)),
                  subtitle: const Text('Ver detalle'),
                  onTap: () => setState(() => _isoSeleccionado = iso),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _VentasDelDiaPanel(
            fecha: fechaSel,
            moneda: _moneda,
          ),
        ),
      ],
    );
  }

  // -------------------
  // Consumo neto (sirve igual en móvil y tablet)
  // -------------------
  Widget _vistaConsumo() {
    final datos = _c.consumo;
    if (datos.isEmpty) return const Center(child: Text('Sin consumo registrado'));

    return ListView.separated(
      itemCount: datos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final fila = datos[i];
        final productoId = fila['productoId'] as int;
        final nombre = fila['nombre'] as String;
        final unidad = fila['unidad'] as String;
        final cantidad = fila['cantidad'] as double;

        final txt = '${cantidad >= 0 ? '+' : '-'}${cantidad.abs().toStringAsFixed(2)} $unidad';

        return Card(
          child: ListTile(
            title: Text(
              nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: const Text('Tocá para ver movimientos'),
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
          ),
        );
      },
    );
  }
}

// -------------------
// Pantalla del día (móvil)
// -------------------
class _VentasDelDiaPantalla extends StatelessWidget {
  final DateTime fecha;
  final String moneda;

  const _VentasDelDiaPantalla({
    required this.fecha,
    required this.moneda,
  });

  String _fechaCorta(DateTime f) {
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${d2(f.day)}/${d2(f.month)}/${f.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ventas ${_fechaCorta(fecha)}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _VentasDelDiaPanel(
          fecha: fecha,
          moneda: moneda,
        ),
      ),
    );
  }
}

// -------------------
// Panel reutilizable del día (tablet y móvil)
// -------------------
class _VentasDelDiaPanel extends StatelessWidget {
  final DateTime fecha;
  final String moneda;

  const _VentasDelDiaPanel({
    required this.fecha,
    required this.moneda,
  });

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Venta>>(
      future: Proveedores.ventasRepositorio.listarVentas(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final todas = snap.data ?? [];
        final delDia = todas.where((v) => _esMismoDia(v.fecha, fecha)).toList()
          ..sort((a, b) => b.fecha.compareTo(a.fecha));

        if (delDia.isEmpty) {
          return Center(child: Text('No hay ventas el ${_fechaCorta(fecha)}'));
        }

        double totalDia = 0;
        for (final v in delDia) {
          totalDia += v.total;
        }

        return Column(
          children: [
            Card(
              child: ListTile(
                title: Text('Total del día (${_fechaCorta(fecha)})'),
                trailing: Text(Formatos.dinero(moneda, totalDia)),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: delDia.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final v = delDia[i];
                  final cancelada = (v.nota ?? '').contains('VENTA CANCELADA');

                  return Card(
                    child: ListTile(
                      title: Text(
                        'Total: ${Formatos.dinero(moneda, v.total)}${cancelada ? ' (CANCELADA)' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(_fechaHora(v.fecha)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VentaDetallePantalla(ventaId: v.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
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
    if (ref.startsWith('reversion_de:') || nota.contains('REVERSIÓN (AUTO)')) {
      return 'Cancelación';
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
        title: Text(
          nombre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder<List<Movimiento>>(
          future: Proveedores.inventarioRepositorio.listarMovimientosDeProducto(productoId),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final movs = snap.data ?? [];
            if (movs.isEmpty) {
              return const Center(child: Text('No hay movimientos'));
            }

            return ListView.separated(
              itemCount: movs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final m = movs[i];

                final origen = _origen(m);
                final detalle = _detalleOrigen(m);

                final v = _cantidadConSigno(m);
                final txt = '${v >= 0 ? '+' : '-'}${v.abs().toStringAsFixed(2)} $unidad';

                final cancelado = (m.nota ?? '').contains('CANCELADO');

                return Card(
                  child: ListTile(
                    title: Text(
                      origen,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${_fecha(m.fecha)}\n'
                          'Tipo: ${m.tipo}  •  Ref: $detalle\n'
                          '${m.nota ?? ''}',
                      maxLines: 3,
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
    );
  }
}