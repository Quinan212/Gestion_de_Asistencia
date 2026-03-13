import 'package:flutter/material.dart';

import '/aplicacion/utiles/layout_app.dart';
import '/aplicacion/widgets/estado_lista.dart';
import '/aplicacion/widgets/panel_controles_modulo.dart';
import '/infraestructura/servicios/exportacion_csv.dart';
import '/infraestructura/dep_inyeccion/proveedores.dart';
import '/modulos/cursos/modelos/curso.dart';

import '../datos/reportes_asistencia_repositorio.dart';
import '../modelos/resumen_asistencia.dart';

class ReportesAsistenciaPantalla extends StatefulWidget {
  const ReportesAsistenciaPantalla({super.key});

  @override
  State<ReportesAsistenciaPantalla> createState() =>
      _ReportesAsistenciaPantallaState();
}

class _ReportesAsistenciaPantallaState
    extends State<ReportesAsistenciaPantalla> {
  static const _mesesOpciones = <int>[3, 6, 12, 24];

  static const _mesesNombre = <String>[
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  bool _cargando = true;
  bool _exportando = false;
  String? _error;

  List<Curso> _cursos = const [];
  int? _cursoId;
  int _meses = 6;
  String _filtro = '';

  List<ResumenAsistenciaAlumno> _porAlumno = const [];
  List<ResumenAsistenciaMensual> _mensual = const [];

  ReportesAsistenciaRepositorio get _repo =>
      ReportesAsistenciaRepositorio(Proveedores.baseDeDatos);

  @override
  void initState() {
    super.initState();
    _cargarInicial();
  }

  Future<void> _cargarInicial() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final cursos = await Proveedores.cursosRepositorio.listar();
      int? cursoId = _cursoId;
      if (cursoId == null || !cursos.any((c) => c.id == cursoId)) {
        cursoId = cursos.isEmpty ? null : cursos.first.id;
      }

      if (!mounted) return;
      setState(() {
        _cursos = cursos;
        _cursoId = cursoId;
      });

      if (cursoId != null) {
        await _cargarReportes(cursoId: cursoId, meses: _meses);
      } else if (mounted) {
        setState(() {
          _porAlumno = const [];
          _mensual = const [];
          _cargando = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los reportes';
        _cargando = false;
      });
    }
  }

  Future<void> _cargarReportes({
    required int cursoId,
    required int meses,
  }) async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final porAlumnoFuture = _repo.porcentajePorAlumno(
        cursoId: cursoId,
        meses: meses,
      );
      final mensualFuture = _repo.resumenMensual(
        cursoId: cursoId,
        meses: meses,
      );

      final porAlumno = await porAlumnoFuture;
      final mensual = await mensualFuture;

      if (!mounted) return;
      setState(() {
        _porAlumno = porAlumno;
        _mensual = mensual;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron calcular los reportes';
        _cargando = false;
      });
    }
  }

  Future<void> _onCambiarCurso(int? cursoId) async {
    if (cursoId == null || cursoId == _cursoId) return;
    setState(() => _cursoId = cursoId);
    await _cargarReportes(cursoId: cursoId, meses: _meses);
  }

  Future<void> _onCambiarMeses(int? meses) async {
    if (meses == null || meses == _meses) return;

    final cursoId = _cursoId;
    setState(() => _meses = meses);

    if (cursoId != null) {
      await _cargarReportes(cursoId: cursoId, meses: meses);
    }
  }

  Curso? _cursoSeleccionado() {
    final id = _cursoId;
    if (id == null) return null;
    for (final c in _cursos) {
      if (c.id == id) return c;
    }
    return null;
  }

  String _etiquetaMes(DateTime mes) {
    final nombre = _mesesNombre[mes.month - 1];
    return '$nombre ${mes.year}';
  }

  Color _colorPorcentaje(double porcentaje, ColorScheme cs) {
    if (porcentaje >= 90) return Colors.green;
    if (porcentaje >= 75) return cs.primary;
    if (porcentaje >= 60) return cs.tertiary;
    return cs.error;
  }

  String _fmtPct(double v) => '${v.toStringAsFixed(1)}%';

  List<ResumenAsistenciaAlumno> _porAlumnoFiltrado() {
    final q = _filtro.trim().toLowerCase();
    if (q.isEmpty) return _porAlumno;
    return _porAlumno
        .where((r) {
          final texto = '${r.nombreCompleto} ${r.apellido} ${r.nombre}'
              .toLowerCase();
          return texto.contains(q);
        })
        .toList(growable: false);
  }

  List<ResumenAsistenciaMensual> _mensualFiltrado() {
    final q = _filtro.trim().toLowerCase();
    if (q.isEmpty) return _mensual;
    return _mensual
        .where((m) {
          final texto = _etiquetaMes(m.mes).toLowerCase();
          return texto.contains(q);
        })
        .toList(growable: false);
  }

  ({int presentes, int ausentes, int tardes, int justif, int total})
  _totales() {
    int presentes = 0;
    int ausentes = 0;
    int tardes = 0;
    int justif = 0;

    for (final r in _porAlumno) {
      presentes += r.presentes;
      ausentes += r.ausentes;
      tardes += r.tardes;
      justif += r.justificadas;
    }

    final total = presentes + ausentes + tardes + justif;
    return (
      presentes: presentes,
      ausentes: ausentes,
      tardes: tardes,
      justif: justif,
      total: total,
    );
  }

  Future<void> _exportarPorAlumno() async {
    if (_porAlumno.isEmpty || _exportando) return;

    final curso = _cursoSeleccionado();
    final cursoNombre = curso?.etiqueta ?? 'curso';

    setState(() => _exportando = true);
    try {
      final filas = _porAlumno
          .map(
            (r) => [
              r.alumnoId.toString(),
              r.apellido,
              r.nombre,
              r.presentes.toString(),
              r.ausentes.toString(),
              r.tardes.toString(),
              r.justificadas.toString(),
              r.totalRegistros.toString(),
              r.porcentajeAsistencia.toStringAsFixed(2),
            ],
          )
          .toList();

      final path = await ExportacionCsv.guardarCsv(
        nombreBase: 'asistencia_alumnos_${cursoNombre}_$_meses',
        encabezados: const [
          'alumno_id',
          'apellido',
          'nombre',
          'presentes',
          'ausentes',
          'tardes',
          'justificadas',
          'total_registros',
          'porcentaje_asistencia',
        ],
        filas: filas,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('CSV guardado: $path')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo exportar CSV de alumnos')),
      );
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  Future<void> _exportarMensual() async {
    if (_mensual.isEmpty || _exportando) return;

    final curso = _cursoSeleccionado();
    final cursoNombre = curso?.etiqueta ?? 'curso';

    setState(() => _exportando = true);
    try {
      final filas = _mensual
          .map(
            (m) => [
              '${m.mes.year}-${m.mes.month.toString().padLeft(2, '0')}',
              m.clases.toString(),
              m.presentes.toString(),
              m.ausentes.toString(),
              m.tardes.toString(),
              m.justificadas.toString(),
              m.totalRegistros.toString(),
              m.porcentajeAsistencia.toStringAsFixed(2),
            ],
          )
          .toList();

      final path = await ExportacionCsv.guardarCsv(
        nombreBase: 'asistencia_mensual_${cursoNombre}_$_meses',
        encabezados: const [
          'periodo',
          'clases',
          'presentes',
          'ausentes',
          'tardes',
          'justificadas',
          'total_registros',
          'porcentaje_asistencia',
        ],
        filas: filas,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('CSV guardado: $path')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo exportar CSV mensual')),
      );
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  Widget _resumenGeneral() {
    final cs = Theme.of(context).colorScheme;
    final t = _totales();
    final efectivos = t.presentes + t.tardes + t.justif;
    final porcentaje = t.total <= 0 ? 0.0 : (efectivos / t.total) * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen global (ultimos $_meses meses)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Presentes: ${t.presentes}')),
                Chip(label: Text('Ausentes: ${t.ausentes}')),
                Chip(label: Text('Tarde: ${t.tardes}')),
                Chip(label: Text('Justificadas: ${t.justif}')),
                Chip(label: Text('Registros: ${t.total}')),
                Chip(
                  backgroundColor: _colorPorcentaje(
                    porcentaje,
                    cs,
                  ).withValues(alpha: 0.12),
                  label: Text('Asistencia: ${_fmtPct(porcentaje)}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabAlumno() {
    final datos = _porAlumnoFiltrado();
    if (datos.isEmpty) {
      return const EstadoListaVacia(
        titulo: 'No hay datos por alumno para el filtro actual',
        icono: Icons.people_outline,
      );
    }

    final cs = Theme.of(context).colorScheme;

    return ListView.separated(
      itemCount: datos.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final r = datos[index];
        final color = _colorPorcentaje(r.porcentajeAsistencia, cs);
        final resumen =
            'P:${r.presentes} A:${r.ausentes} T:${r.tardes} J:${r.justificadas} - Registros: ${r.totalRegistros}';
        final porcentajeTxt = _fmtPct(r.porcentajeAsistencia);

        return LayoutBuilder(
          builder: (context, c) {
            final compacto = c.maxWidth < 430;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Text('${index + 1}'),
              ),
              title: Text(
                r.nombreCompleto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                compacto ? '$resumen - Asistencia: $porcentajeTxt' : resumen,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: compacto
                  ? null
                  : Text(
                      porcentajeTxt,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  Widget _tabMensual() {
    final datos = _mensualFiltrado();
    if (datos.isEmpty) {
      return const EstadoListaVacia(
        titulo: 'No hay datos mensuales para el filtro actual',
        icono: Icons.calendar_month_outlined,
      );
    }

    final cs = Theme.of(context).colorScheme;

    return ListView.separated(
      itemCount: datos.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final m = datos[index];
        final color = _colorPorcentaje(m.porcentajeAsistencia, cs);
        final resumen =
            'Clases: ${m.clases} - P:${m.presentes} A:${m.ausentes} T:${m.tardes} J:${m.justificadas}';
        final porcentajeTxt = _fmtPct(m.porcentajeAsistencia);

        return LayoutBuilder(
          builder: (context, c) {
            final compacto = c.maxWidth < 430;
            return ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.calendar_month_outlined),
              ),
              title: Text(
                _etiquetaMes(m.mes),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                compacto ? '$resumen - Asistencia: $porcentajeTxt' : resumen,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: compacto
                  ? null
                  : Text(
                      porcentajeTxt,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const EstadoListaCargando(mensaje: 'Cargando reportes...');
    }

    if (_error != null) {
      return EstadoListaError(mensaje: _error!, alReintentar: _cargarInicial);
    }

    if (_cursos.isEmpty) {
      return const EstadoListaVacia(
        titulo: 'No hay cursos cargados para generar reportes',
        icono: Icons.class_outlined,
      );
    }

    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: LayoutApp.kPagePadding,
        child: LayoutBuilder(
          builder: (context, c) {
            final esDesktop = LayoutApp.esDesktop(c.maxWidth);
            final textScale = MediaQuery.textScalerOf(context).scale(1.0);
            final compacto = c.maxWidth < 760 || textScale > 1.05;

            final cursoSelector = SizedBox(
              width: compacto ? double.infinity : 300,
              child: DropdownButtonFormField<int>(
                key: ValueKey('curso_$_cursoId'),
                initialValue: _cursoId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Curso'),
                items: _cursos
                    .map(
                      (c) => DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(
                          c.etiqueta,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _exportando ? null : _onCambiarCurso,
              ),
            );
            final periodoSelector = SizedBox(
              width: compacto ? double.infinity : 170,
              child: DropdownButtonFormField<int>(
                key: ValueKey('meses_$_meses'),
                initialValue: _meses,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Periodo'),
                items: _mesesOpciones
                    .map(
                      (m) => DropdownMenuItem<int>(
                        value: m,
                        child: Text('$m meses'),
                      ),
                    )
                    .toList(),
                onChanged: _exportando ? null : _onCambiarMeses,
              ),
            );
            final filtro = TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar alumno o mes',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _filtro = v),
            );
            final acciones = Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: _exportando ? null : _exportarPorAlumno,
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('CSV alumnos'),
                ),
                OutlinedButton.icon(
                  onPressed: _exportando ? null : _exportarMensual,
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('CSV mensual'),
                ),
              ],
            );

            final panelControles = PanelControlesModulo(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (compacto) ...[
                    cursoSelector,
                    const SizedBox(height: 10),
                    periodoSelector,
                  ] else ...[
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [cursoSelector, periodoSelector],
                    ),
                  ],
                  const SizedBox(height: 10),
                  filtro,
                  const SizedBox(height: 10),
                  acciones,
                ],
              ),
            );

            final panelTabs = Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Por alumno'),
                    Tab(text: 'Mensual'),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Card(
                    child: TabBarView(children: [_tabAlumno(), _tabMensual()]),
                  ),
                ),
              ],
            );

            if (!esDesktop) {
              return Column(
                children: [
                  panelControles,
                  const SizedBox(height: 10),
                  _resumenGeneral(),
                  const SizedBox(height: 10),
                  Expanded(child: panelTabs),
                ],
              );
            }

            return Row(
              children: [
                SizedBox(
                  width: 390,
                  child: Column(
                    children: [
                      panelControles,
                      const SizedBox(height: 10),
                      _resumenGeneral(),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: panelTabs),
              ],
            );
          },
        ),
      ),
    );
  }
}
