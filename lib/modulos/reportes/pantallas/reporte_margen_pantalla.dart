import 'package:flutter/material.dart';

import 'package:gestion_de_stock/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_stock/infraestructura/servicios/exportacion_csv.dart';
import '/infraestructura/dep_inyeccion/proveedores.dart';
import '/modulos/inventario/modelos/producto.dart';

class ReporteMargenPantalla extends StatefulWidget {
  final bool embebido;

  const ReporteMargenPantalla({super.key, this.embebido = false});

  @override
  State<ReporteMargenPantalla> createState() => _ReporteMargenPantallaState();
}

class _ReporteMargenPantallaState extends State<ReporteMargenPantalla> {
  static const double _kTablet = 900;

  bool _cargando = true;
  String? _error;

  String _moneda = r'$';
  List<_FilaMargen> _filas = [];

  int? _selIndex; // tablet: selección

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
      _filas = [];
      _selIndex = null;
    });

    try {
      final m = await Formatos.leerMoneda();
      if (mounted) _moneda = m;

      final combos = await Proveedores.combosRepositorio.listarCombos(incluirInactivos: true);

      final productos = await Proveedores.inventarioRepositorio.listarProductos(
        incluirInactivos: true,
      );
      final porId = <int, Producto>{for (final p in productos) p.id: p};

      final List<_FilaMargen> filas = [];

      for (final c in combos) {
        final componentes = await Proveedores.combosRepositorio.listarComponentes(c.id);

        double costo = 0.0;
        bool faltanCostos = false;

        for (final comp in componentes) {
          final prod = porId[comp.productoId];
          final double costoProd = prod?.costoActual ?? 0.0;

          if (prod == null || costoProd <= 0.0) {
            faltanCostos = true;
          }

          costo += comp.cantidad * costoProd;
        }

        final double precio = c.precioVenta;
        final double ganancia = precio - costo;
        final double porcentaje = (costo <= 0.0) ? 0.0 : (ganancia / costo) * 100.0;

        filas.add(
          _FilaMargen(
            comboId: c.id,
            nombre: c.nombre,
            precio: precio,
            costo: costo,
            ganancia: ganancia,
            porcentaje: porcentaje,
            activo: c.activo,
            faltanCostos: faltanCostos,
          ),
        );
      }

      filas.sort((a, b) => b.ganancia.compareTo(a.ganancia));

      setState(() {
        _cargando = false;
        _filas = filas;
        _moneda = m;
        _selIndex = filas.isEmpty ? null : 0;
      });
    } catch (_) {
      setState(() {
        _cargando = false;
        _error = 'No se pudo calcular el margen';
      });
    }
  }

  Future<void> _exportar() async {
    try {
      if (_filas.isEmpty) return;

      final filas = _filas.map((f) {
        return [
          f.nombre,
          f.precio.toStringAsFixed(2),
          f.costo.toStringAsFixed(2),
          f.ganancia.toStringAsFixed(2),
          f.porcentaje.toStringAsFixed(1),
          f.activo ? 'si' : 'no',
          f.faltanCostos ? 'si' : 'no',
        ];
      }).toList();

      final path = await ExportacionCsv.guardarCsv(
        nombreBase: 'margen_por_combo',
        encabezados: [
          'combo',
          'precio',
          'costo',
          'ganancia',
          'ganancia_sobre_costo',
          'activo',
          'faltan_costos',
        ],
        filas: filas,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV guardado: $path')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo exportar')),
      );
    }
  }

  Widget _detalle(_FilaMargen f) {
    final theme = Theme.of(context);
    final gananciaColor = f.ganancia < 0 ? theme.colorScheme.error : theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              f.nombre,
              style: theme.textTheme.titleLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Text('Precio: ${Formatos.dinero(_moneda, f.precio)}'),
            const SizedBox(height: 6),
            Text('Costo: ${Formatos.dinero(_moneda, f.costo)}'),
            const SizedBox(height: 6),
            Text(
              'Ganancia: ${Formatos.dinero(_moneda, f.ganancia)}',
              style: TextStyle(color: gananciaColor),
            ),
            const SizedBox(height: 6),
            Text('${f.porcentaje.toStringAsFixed(1)}% sobre costo'),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: f.activo
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Text(
                    f.activo ? 'ACTIVO' : 'INACTIVO',
                    style: theme.textTheme.labelMedium,
                  ),
                ),
                const SizedBox(width: 10),
                if (f.faltanCostos)
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
                      const SizedBox(width: 6),
                      Text(
                        'Faltan costos',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Icon(Icons.check, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      const Text('OK'),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenido(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    if (_filas.isEmpty) return const Center(child: Text('Sin combos'));

    return LayoutBuilder(
      builder: (context, c) {
        final esTablet = c.maxWidth >= _kTablet;

        if (!esTablet) {
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _filas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final f = _filas[i];

              return Card(
                child: ListTile(
                  title: Text(f.nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    'Precio: ${Formatos.dinero(_moneda, f.precio)}  •  '
                        'Costo: ${Formatos.dinero(_moneda, f.costo)}\n'
                        'Ganancia: ${Formatos.dinero(_moneda, f.ganancia)}  •  '
                        '${f.porcentaje.toStringAsFixed(1)}% sobre costo',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(f.activo ? 'ACTIVO' : 'INACTIVO', style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 6),
                      Icon(
                        f.faltanCostos ? Icons.warning_amber_rounded : Icons.check,
                        color: f.faltanCostos
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        final sel = (_selIndex == null) ? 0 : (_selIndex!.clamp(0, _filas.length - 1));
        final fSel = _filas[sel];

        return Row(
          children: [
            SizedBox(
              width: 420,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _filas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final f = _filas[i];
                  return Card(
                    child: ListTile(
                      selected: i == sel,
                      title: Text(f.nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        'Ganancia: ${Formatos.dinero(_moneda, f.ganancia)} • ${f.porcentaje.toStringAsFixed(1)}%',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(
                        f.faltanCostos ? Icons.warning_amber_rounded : Icons.check,
                        color: f.faltanCostos
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () => setState(() => _selIndex = i),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Padding(padding: const EdgeInsets.all(12), child: _detalle(fSel))),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embebido) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Margen por combo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: _exportar,
                  icon: const Icon(Icons.download_outlined),
                  tooltip: 'Exportar CSV',
                ),
                IconButton(
                  onPressed: _cargar,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refrescar',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _contenido(context)),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Margen por combo'),
        actions: [
          IconButton(
            onPressed: _exportar,
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Exportar CSV',
          ),
          IconButton(
            onPressed: _cargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _contenido(context),
    );
  }
}

class _FilaMargen {
  final int comboId;
  final String nombre;
  final double precio;
  final double costo;
  final double ganancia;
  final double porcentaje;
  final bool activo;
  final bool faltanCostos;

  const _FilaMargen({
    required this.comboId,
    required this.nombre,
    required this.precio,
    required this.costo,
    required this.ganancia,
    required this.porcentaje,
    required this.activo,
    required this.faltanCostos,
  });
}