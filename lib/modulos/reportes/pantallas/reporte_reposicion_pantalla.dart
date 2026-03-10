import 'package:flutter/material.dart';

import 'package:gestion_de_asistencias/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/layout_app.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/tablet_master_detail_layout.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/infraestructura/servicios/exportacion_csv.dart';
import 'package:gestion_de_asistencias/modulos/combos/modelos/combo.dart';
import 'package:gestion_de_asistencias/modulos/inventario/modelos/producto.dart';
import '../logica/reportes_controlador.dart';

class ReporteReposicionPantalla extends StatefulWidget {
  final bool embebido;

  const ReporteReposicionPantalla({super.key, this.embebido = false});

  @override
  State<ReporteReposicionPantalla> createState() =>
      _ReporteReposicionPantallaState();
}

class _ReporteReposicionPantallaState extends State<ReporteReposicionPantalla> {
  static const double _kTablet = LayoutApp.kTablet;

  late final ReportesControlador _c;

  int _modo = 0; // 0: por minimo, 1: por combo objetivo
  int? _comboId;
  String _comboNombre = '';
  final _objetivoCtrl = TextEditingController(text: '10');

  bool _calculando = false;
  String? _errorCombo;
  List<Map<String, dynamic>> _faltantesCombo = [];

  @override
  void initState() {
    super.initState();
    _c = ReportesControlador();
    _c.cargarTodo();
  }

  @override
  void dispose() {
    _objetivoCtrl.dispose();
    _c.dispose();
    super.dispose();
  }

  Future<List<Combo>> _cargarCombos() =>
      Proveedores.combosRepositorio.listarCombos();

  Future<void> _calcularFaltantesCombo() async {
    setState(() {
      _errorCombo = null;
      _faltantesCombo = [];
    });

    final comboId = _comboId;
    if (comboId == null) {
      setState(() => _errorCombo = 'Elegi un combo');
      return;
    }

    final objTxt = _objetivoCtrl.text.trim().replaceAll(',', '.');
    final objetivo = double.tryParse(objTxt);
    if (objetivo == null || objetivo <= 0) {
      setState(() => _errorCombo = 'Objetivo invalido');
      return;
    }

    setState(() => _calculando = true);

    try {
      final componentes = await Proveedores.combosRepositorio.listarComponentes(
        comboId,
      );
      if (componentes.isEmpty) {
        setState(() {
          _calculando = false;
          _errorCombo = 'Ese combo no tiene productos cargados';
        });
        return;
      }

      final productos = await Proveedores.inventarioRepositorio.listarProductos(
        incluirInactivos: true,
      );
      final porId = <int, Producto>{for (final p in productos) p.id: p};

      final List<Map<String, dynamic>> faltantes = [];

      for (final c in componentes) {
        final requerido = c.cantidad * objetivo;
        final stock = await Proveedores.inventarioRepositorio
            .calcularStockActual(c.productoId);
        final falta = requerido - stock;

        if (falta > 1e-9) {
          final p = porId[c.productoId];
          faltantes.add({
            'productoId': c.productoId,
            'nombre': p?.nombre ?? 'Producto ${c.productoId}',
            'unidad': p?.unidad ?? '',
            'requerido': requerido,
            'stock': stock,
            'faltante': falta,
          });
        }
      }

      faltantes.sort(
        (a, b) => (b['faltante'] as double).compareTo(a['faltante'] as double),
      );

      setState(() {
        _calculando = false;
        _faltantesCombo = faltantes;
      });
    } catch (_) {
      setState(() {
        _calculando = false;
        _errorCombo = 'No se pudo calcular';
      });
    }
  }

  Future<void> _exportar() async {
    try {
      if (_modo == 0) {
        final datos = _c.reposicion;
        if (datos.isEmpty) return;

        final filas = datos.map((fila) {
          return [
            (fila['nombre'] as String),
            (fila['unidad'] as String),
            Formatos.cantidad(
              (fila['stock'] as double),
              unidad: (fila['unidad'] as String),
            ),
            Formatos.cantidad(
              (fila['minimo'] as double),
              unidad: (fila['unidad'] as String),
            ),
            Formatos.cantidad(
              (fila['faltante'] as double),
              unidad: (fila['unidad'] as String),
            ),
          ];
        }).toList();

        final path = await ExportacionCsv.guardarCsv(
          nombreBase: 'reposicion_por_minimo',
          encabezados: ['producto', 'unidad', 'stock', 'minimo', 'faltante'],
          filas: filas,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('CSV guardado: $path')));
      } else {
        final comboId = _comboId;
        if (comboId == null) return;

        final datos = _faltantesCombo;
        if (datos.isEmpty) return;

        final filas = datos.map((fila) {
          return [
            (fila['nombre'] as String),
            (fila['unidad'] as String),
            Formatos.cantidad(
              (fila['stock'] as double),
              unidad: (fila['unidad'] as String),
            ),
            Formatos.cantidad(
              (fila['requerido'] as double),
              unidad: (fila['unidad'] as String),
            ),
            Formatos.cantidad(
              (fila['faltante'] as double),
              unidad: (fila['unidad'] as String),
            ),
          ];
        }).toList();

        final path = await ExportacionCsv.guardarCsv(
          nombreBase: 'faltantes_combo_$comboId',
          encabezados: ['producto', 'unidad', 'stock', 'requerido', 'faltante'],
          filas: filas,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('CSV guardado: $path')));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No se pudo exportar')));
    }
  }

  Widget _modoMinimo() {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        if (_c.cargando) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_c.error != null) return Center(child: Text(_c.error!));

        final datos = _c.reposicion;
        if (datos.isEmpty) {
          return const Center(child: Text('Todo esta por encima del minimo'));
        }

        return ListView.separated(
          padding: const EdgeInsets.only(top: 12),
          itemCount: datos.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final fila = datos[i];
            final nombre = fila['nombre'] as String;
            final unidad = fila['unidad'] as String;
            final stock = fila['stock'] as double;
            final minimo = fila['minimo'] as double;
            final faltante = fila['faltante'] as double;

            return Card(
              child: ListTile(
                title: Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Stock: ${Formatos.cantidad(stock, unidad: unidad)} $unidad  -  Minimo: ${Formatos.cantidad(minimo, unidad: unidad)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '-${Formatos.cantidad(faltante, unidad: unidad)}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _configCombo() {
    return FutureBuilder<List<Combo>>(
      future: _cargarCombos(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const LinearProgressIndicator();
        }
        final combos = snap.data ?? [];
        if (combos.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('Primero crea un combo'),
          );
        }

        return Column(
          children: [
            DropdownButtonFormField<int>(
              initialValue: _comboId,
              isExpanded: true,
              items: combos
                  .map(
                    (c) => DropdownMenuItem<int>(
                      value: c.id,
                      child: Text(
                        c.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (id) {
                final c = combos.firstWhere(
                  (x) => x.id == id,
                  orElse: () => combos.first,
                );
                setState(() {
                  _comboId = id;
                  _comboNombre = (id == null) ? '' : c.nombre;
                });
              },
              decoration: const InputDecoration(labelText: 'Combo'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _objetivoCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Objetivo de combos',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _calculando ? null : _calcularFaltantesCombo,
                child: Text(
                  _calculando ? 'Calculando...' : 'Calcular faltantes',
                ),
              ),
            ),
            if (_errorCombo != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorCombo!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _listaFaltantes() {
    if (_faltantesCombo.isEmpty) {
      return const Center(
        child: Text('Sin faltantes (o todavia no calculaste)'),
      );
    }

    return ListView.separated(
      itemCount: _faltantesCombo.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final f = _faltantesCombo[i];
        final nombre = f['nombre'] as String;
        final unidad = f['unidad'] as String;
        final requerido = f['requerido'] as double;
        final stock = f['stock'] as double;
        final faltante = f['faltante'] as double;

        return Card(
          child: ListTile(
            title: Text(nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              'Req: ${Formatos.cantidad(requerido, unidad: unidad)} $unidad  -  Stock: ${Formatos.cantidad(stock, unidad: unidad)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              '-${Formatos.cantidad(faltante, unidad: unidad)}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        );
      },
    );
  }

  Widget _modoCombo() {
    return LayoutBuilder(
      builder: (context, c) {
        final esTablet = c.maxWidth >= _kTablet;

        if (!esTablet) {
          return Column(
            children: [
              _configCombo(),
              const SizedBox(height: 12),
              Expanded(child: _listaFaltantes()),
            ],
          );
        }

        return TabletMasterDetailLayout(
          master: Column(
            children: [
              _configCombo(),
              const SizedBox(height: 12),
              if (_comboNombre.trim().isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _comboNombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
            ],
          ),
          detail: _listaFaltantes(),
        );
      },
    );
  }

  Widget _contenido(BuildContext context) {
    return Padding(
      padding: TabletMasterDetailLayout.kPagePadding,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Por minimo')),
                    ButtonSegment(value: 1, label: Text('Por combo')),
                  ],
                  selected: {_modo},
                  onSelectionChanged: (s) {
                    setState(() => _modo = s.first);
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
                onPressed: () {
                  _c.cargarTodo();
                  if (_modo == 1) {
                    setState(() {
                      _errorCombo = null;
                      _faltantesCombo = [];
                    });
                  }
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Refrescar',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: _modo == 0 ? _modoMinimo() : _modoCombo()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embebido) return _contenido(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reposicion')),
      body: _contenido(context),
    );
  }
}
