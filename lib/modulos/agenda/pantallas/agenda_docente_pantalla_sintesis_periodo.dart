part of 'agenda_docente_pantalla.dart';

class _DialogSintesisPeriodoCurso extends StatefulWidget {
  final int cursoId;
  final String cursoEtiqueta;
  final DateTime fechaReferencia;

  const _DialogSintesisPeriodoCurso({
    required this.cursoId,
    required this.cursoEtiqueta,
    required this.fechaReferencia,
  });

  @override
  State<_DialogSintesisPeriodoCurso> createState() =>
      _DialogSintesisPeriodoCursoState();
}

class _DialogSintesisPeriodoCursoState
    extends State<_DialogSintesisPeriodoCurso> {
  late int _anio;
  late int _trimestre;
  bool _cargando = true;
  bool _exportando = false;
  SintesisPeriodoCurso? _sintesis;
  ComparacionTemporalCurso? _comparacion;
  final _resumenCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _anio = widget.fechaReferencia.year;
    _trimestre = ((widget.fechaReferencia.month - 1) ~/ 3) + 1;
    _recargar();
  }

  @override
  void dispose() {
    _resumenCtrl.dispose();
    super.dispose();
  }

  (DateTime, DateTime) _rangoTrimestre(int anio, int trimestre) {
    final mesInicio = ((trimestre - 1) * 3) + 1;
    final desde = DateTime(anio, mesInicio, 1);
    final hasta = DateTime(anio, mesInicio + 3, 0);
    return (desde, hasta);
  }

  Future<void> _recargar() async {
    setState(() => _cargando = true);
    final rango = _rangoTrimestre(_anio, _trimestre);
    final comparacion = await Proveedores.agendaDocenteRepositorio
        .compararTemporalCurso(
          cursoId: widget.cursoId,
          actualDesde: rango.$1,
          actualHasta: rango.$2,
        );
    if (!mounted) return;
    setState(() {
      _comparacion = comparacion;
      _sintesis = comparacion.actual;
      _resumenCtrl.text = _textoSintesisCurso(comparacion.actual);
      _cargando = false;
    });
  }

  String _deltaNumero(int valor) {
    if (valor > 0) return '+$valor';
    return '$valor';
  }

  String _deltaPorcentaje(double valor) {
    if (valor > 0) return '+${valor.toStringAsFixed(1)}';
    return valor.toStringAsFixed(1);
  }

  String _textoSintesisCurso(SintesisPeriodoCurso s) {
    return '''
Curso: ${s.materia} (${s.etiquetaCurso})
Institucion: ${s.institucion}
Rango: ${_fechaCorta(s.desde)} al ${_fechaCorta(s.hasta)}

Clases dictadas: ${s.clasesDictadas}
Asistencia: ${s.asistenciaPorcentaje.toStringAsFixed(1)}%
Entregas pendientes: ${s.entregasPendientes}
Trabajos sin corregir: ${s.trabajosSinCorregir}

Evaluaciones abiertas: ${s.evaluacionesAbiertas}
Resultados rendidos: ${s.evaluacionesRendidas}
Recuperatorios tomados: ${s.recuperatoriosTomados}

Riesgo (A/M/B): ${s.alumnosRiesgoAlto}/${s.alumnosRiesgoMedio}/${s.alumnosRiesgoBajo}
Alertas activas: ${s.alertasActivas}

Contenidos trabajados: ${s.contenidosTrabajados}
Contenidos pendientes: ${s.contenidosPendientes}

Bitacora de clase:
- Completado: ${s.bitacoraCompletada}
- Parcial: ${s.bitacoraParcial}
- Reprogramado: ${s.bitacoraReprogramada}
'''
        .trim();
  }

  Future<void> _copiar() async {
    final texto = _resumenCtrl.text.trim();
    if (texto.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: texto));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sintesis de curso copiada')));
  }

  Future<void> _exportarResumenCursoCsv() async {
    final s = _sintesis;
    if (s == null || _exportando) return;
    setState(() => _exportando = true);
    try {
      final path = await ExportacionCsv.guardarCsv(
        nombreBase: 'resumen_curso_${s.materia}_${_anio}_t$_trimestre',
        encabezados: const [
          'institucion',
          'materia',
          'curso',
          'desde',
          'hasta',
          'clases_dictadas',
          'asistencia_porcentaje',
          'entregas_pendientes',
          'trabajos_sin_corregir',
          'evaluaciones_abiertas',
          'evaluaciones_rendidas',
          'recuperatorios_tomados',
          'alumnos_riesgo_alto',
          'alumnos_riesgo_medio',
          'alumnos_riesgo_bajo',
          'alertas_activas',
          'contenidos_trabajados',
          'contenidos_pendientes',
          'bitacora_completada',
          'bitacora_parcial',
          'bitacora_reprogramada',
        ],
        filas: [
          [
            s.institucion,
            s.materia,
            s.etiquetaCurso,
            _fechaCorta(s.desde),
            _fechaCorta(s.hasta),
            s.clasesDictadas.toString(),
            s.asistenciaPorcentaje.toStringAsFixed(2),
            s.entregasPendientes.toString(),
            s.trabajosSinCorregir.toString(),
            s.evaluacionesAbiertas.toString(),
            s.evaluacionesRendidas.toString(),
            s.recuperatoriosTomados.toString(),
            s.alumnosRiesgoAlto.toString(),
            s.alumnosRiesgoMedio.toString(),
            s.alumnosRiesgoBajo.toString(),
            s.alertasActivas.toString(),
            s.contenidosTrabajados.toString(),
            s.contenidosPendientes.toString(),
            s.bitacoraCompletada.toString(),
            s.bitacoraParcial.toString(),
            s.bitacoraReprogramada.toString(),
          ],
        ],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('CSV resumen curso: $path')));
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  Future<void> _exportarListadoRiesgoCsv() async {
    if (_exportando) return;
    setState(() => _exportando = true);
    try {
      final historial = await Proveedores.agendaDocenteRepositorio
          .listarHistorialInteligenteCurso(widget.cursoId);
      final filtrados = historial
          .where((h) => h.nivelRiesgo.trim().toLowerCase() != 'bajo')
          .toList(growable: false);
      final s = _sintesis;
      if (s == null) return;

      final path = await ExportacionCsv.guardarCsv(
        nombreBase: 'listado_riesgo_${s.materia}_${_anio}_t$_trimestre',
        encabezados: const [
          'institucion',
          'materia',
          'curso',
          'alumno',
          'riesgo',
          'faltas',
          'inasistencias_consecutivas',
          'actividades_sin_entregar',
          'evaluaciones_pendientes',
          'evaluaciones_recuperacion',
          'resumen',
        ],
        filas: filtrados
            .map(
              (h) => [
                s.institucion,
                s.materia,
                s.etiquetaCurso,
                h.alumnoNombre,
                h.nivelRiesgo,
                h.faltas.toString(),
                h.inasistenciasConsecutivas.toString(),
                h.actividadesSinEntregar.toString(),
                h.evaluacionesPendientes.toString(),
                h.evaluacionesRecuperacion.toString(),
                h.resumen,
              ],
            )
            .toList(growable: false),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('CSV riesgo: $path')));
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  Future<void> _exportarResumenAlumnosCsv() async {
    final s = _sintesis;
    if (s == null || _exportando) return;
    setState(() => _exportando = true);
    try {
      final rango = _rangoTrimestre(_anio, _trimestre);
      final alumnos = await Proveedores.asistenciasRepositorio
          .listarAlumnosDeCurso(widget.cursoId);
      final filas = <List<String>>[];
      for (final a in alumnos) {
        final st = await Proveedores.agendaDocenteRepositorio
            .generarSintesisPeriodoAlumno(
              cursoId: widget.cursoId,
              alumnoId: a.id,
              desde: rango.$1,
              hasta: rango.$2,
            );
        filas.add([
          s.institucion,
          s.materia,
          s.etiquetaCurso,
          st.alumnoNombre,
          _fechaCorta(st.desde),
          _fechaCorta(st.hasta),
          st.condicionCierre,
          st.nivelRiesgo,
          st.asistenciaPorcentaje.toStringAsFixed(2),
          st.faltas.toString(),
          st.trabajosPendientes.toString(),
          st.trabajosSinCorregir.toString(),
          st.evaluacionesRendidas.toString(),
          st.recuperatoriosRendidos.toString(),
          st.aprobadas.toString(),
          st.noAprobadas.toString(),
          st.pendientes.toString(),
          st.ausentes.toString(),
          st.promedioNumerico?.toStringAsFixed(2) ?? '',
          st.alertasActivas.toString(),
        ]);
      }
      final path = await ExportacionCsv.guardarCsv(
        nombreBase: 'resumen_alumnos_${s.materia}_${_anio}_t$_trimestre',
        encabezados: const [
          'institucion',
          'materia',
          'curso',
          'alumno',
          'desde',
          'hasta',
          'condicion_cierre',
          'riesgo',
          'asistencia_porcentaje',
          'faltas',
          'trabajos_pendientes',
          'trabajos_sin_corregir',
          'evaluaciones_rendidas',
          'recuperatorios_rendidos',
          'aprobadas',
          'no_aprobadas',
          'pendientes',
          'ausentes',
          'promedio_numerico',
          'alertas_activas',
        ],
        filas: filas,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('CSV resumen alumnos: $path')));
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _sintesis;
    final c = _comparacion;
    return AlertDialog(
      title: _tituloDialogoCurso('Sintesis de periodo', widget.cursoEtiqueta),
      content: SizedBox(
        width: _anchoDialogo(context, 760),
        child: _cargando || s == null
            ? const EstadoListaCargando(mensaje: 'Generando sintesis...')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bloqueDescripcionFuncion(context, 'sintesis_curso'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: 140,
                        child: DropdownButtonFormField<int>(
                          initialValue: _trimestre,
                          decoration: const InputDecoration(
                            labelText: 'Trimestre',
                          ),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('1er')),
                            DropdownMenuItem(value: 2, child: Text('2do')),
                            DropdownMenuItem(value: 3, child: Text('3er')),
                            DropdownMenuItem(value: 4, child: Text('4to')),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _trimestre = v);
                            _recargar();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: DropdownButtonFormField<int>(
                          initialValue: _anio,
                          decoration: const InputDecoration(labelText: 'Anio'),
                          items: [
                            DropdownMenuItem(
                              value: _anio - 1,
                              child: Text('${_anio - 1}'),
                            ),
                            DropdownMenuItem(
                              value: _anio,
                              child: Text('$_anio'),
                            ),
                            DropdownMenuItem(
                              value: _anio + 1,
                              child: Text('${_anio + 1}'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _anio = v);
                            _recargar();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          'Asistencia ${s.asistenciaPorcentaje.toStringAsFixed(1)}%',
                        ),
                      ),
                      Chip(
                        label: Text('Eval abiertas ${s.evaluacionesAbiertas}'),
                      ),
                      Chip(label: Text('Alertas ${s.alertasActivas}')),
                      Chip(label: Text('Riesgo alto ${s.alumnosRiesgoAlto}')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (c != null)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          label: Text(
                            'Delta asistencia ${_deltaPorcentaje(c.deltaAsistencia)} pp',
                          ),
                        ),
                        Chip(
                          label: Text(
                            'Delta entregas ${_deltaNumero(c.deltaEntregasPendientes)}',
                          ),
                        ),
                        Chip(
                          label: Text(
                            'Delta alertas ${_deltaNumero(c.deltaAlertas)}',
                          ),
                        ),
                        Chip(
                          label: Text(
                            'Delta riesgo alto ${_deltaNumero(c.deltaRiesgoAlto)}',
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _resumenCtrl,
                    minLines: 7,
                    maxLines: 12,
                    decoration: const InputDecoration(
                      labelText: 'Resumen automatico editable para informe',
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        OutlinedButton.icon(
          onPressed: s == null || _exportando ? null : _exportarResumenCursoCsv,
          icon: const Icon(Icons.file_download_outlined),
          label: const Text('CSV curso'),
        ),
        OutlinedButton.icon(
          onPressed: s == null || _exportando
              ? null
              : _exportarResumenAlumnosCsv,
          icon: const Icon(Icons.groups_outlined),
          label: const Text('CSV alumnos'),
        ),
        OutlinedButton.icon(
          onPressed: s == null || _exportando
              ? null
              : _exportarListadoRiesgoCsv,
          icon: const Icon(Icons.warning_amber_rounded),
          label: const Text('CSV riesgo'),
        ),
        FilledButton.icon(
          onPressed: s == null ? null : _copiar,
          icon: const Icon(Icons.copy_all_outlined),
          label: const Text('Copiar'),
        ),
      ],
    );
  }
}

class _DialogSintesisPeriodoAlumno extends StatefulWidget {
  final int cursoId;
  final int alumnoId;
  final String alumnoNombre;
  final String cursoEtiqueta;
  final DateTime fechaReferencia;

  const _DialogSintesisPeriodoAlumno({
    required this.cursoId,
    required this.alumnoId,
    required this.alumnoNombre,
    required this.cursoEtiqueta,
    required this.fechaReferencia,
  });

  @override
  State<_DialogSintesisPeriodoAlumno> createState() =>
      _DialogSintesisPeriodoAlumnoState();
}

class _DialogSintesisPeriodoAlumnoState
    extends State<_DialogSintesisPeriodoAlumno> {
  late int _anio;
  late int _trimestre;
  bool _cargando = true;
  bool _exportando = false;
  SintesisPeriodoAlumno? _sintesis;
  ComparacionTemporalAlumno? _comparacion;
  final _resumenCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _anio = widget.fechaReferencia.year;
    _trimestre = ((widget.fechaReferencia.month - 1) ~/ 3) + 1;
    _recargar();
  }

  @override
  void dispose() {
    _resumenCtrl.dispose();
    super.dispose();
  }

  (DateTime, DateTime) _rangoTrimestre(int anio, int trimestre) {
    final mesInicio = ((trimestre - 1) * 3) + 1;
    final desde = DateTime(anio, mesInicio, 1);
    final hasta = DateTime(anio, mesInicio + 3, 0);
    return (desde, hasta);
  }

  Future<void> _recargar() async {
    setState(() => _cargando = true);
    final rango = _rangoTrimestre(_anio, _trimestre);
    final c = await Proveedores.agendaDocenteRepositorio.compararTemporalAlumno(
      cursoId: widget.cursoId,
      alumnoId: widget.alumnoId,
      actualDesde: rango.$1,
      actualHasta: rango.$2,
    );
    if (!mounted) return;
    setState(() {
      _comparacion = c;
      _sintesis = c.actual;
      _resumenCtrl.text = _textoSintesisAlumno(c.actual);
      _cargando = false;
    });
  }

  String _deltaNumero(int valor) {
    if (valor > 0) return '+$valor';
    return '$valor';
  }

  String _deltaPorcentaje(double valor) {
    if (valor > 0) return '+${valor.toStringAsFixed(1)}';
    return valor.toStringAsFixed(1);
  }

  String _textoSintesisAlumno(SintesisPeriodoAlumno s) {
    final prom = s.promedioNumerico == null
        ? 'Sin promedio numerico'
        : s.promedioNumerico!.toStringAsFixed(2);
    return '''
Alumno: ${s.alumnoNombre}
Curso: ${widget.cursoEtiqueta}
Rango: ${_fechaCorta(s.desde)} al ${_fechaCorta(s.hasta)}

Condicion de cierre: ${s.condicionCierre}
Riesgo: ${s.nivelRiesgo.toUpperCase()}
Alertas activas: ${s.alertasActivas}

Asistencia: ${s.asistenciaPorcentaje.toStringAsFixed(1)}% (${s.clasesConRegistro} registros)
Faltas: ${s.faltas}
Trabajos pendientes: ${s.trabajosPendientes}
Trabajos sin corregir: ${s.trabajosSinCorregir}

Evaluaciones rendidas: ${s.evaluacionesRendidas}
Recuperatorios rendidos: ${s.recuperatoriosRendidos}
Aprobadas: ${s.aprobadas}
No aprobadas: ${s.noAprobadas}
Pendientes: ${s.pendientes}
Ausentes: ${s.ausentes}
Promedio: $prom
'''
        .trim();
  }

  Future<void> _copiar() async {
    final texto = _resumenCtrl.text.trim();
    if (texto.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: texto));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sintesis de alumno copiada')));
  }

  Future<void> _exportarResumenAlumnoCsv() async {
    final s = _sintesis;
    if (s == null || _exportando) return;
    setState(() => _exportando = true);
    try {
      final path = await ExportacionCsv.guardarCsv(
        nombreBase: 'resumen_alumno_${s.alumnoNombre}_${_anio}_t$_trimestre',
        encabezados: const [
          'alumno',
          'curso',
          'desde',
          'hasta',
          'condicion_cierre',
          'riesgo',
          'alertas_activas',
          'asistencia_porcentaje',
          'faltas',
          'trabajos_pendientes',
          'trabajos_sin_corregir',
          'evaluaciones_rendidas',
          'recuperatorios_rendidos',
          'aprobadas',
          'no_aprobadas',
          'pendientes',
          'ausentes',
          'promedio_numerico',
        ],
        filas: [
          [
            s.alumnoNombre,
            widget.cursoEtiqueta,
            _fechaCorta(s.desde),
            _fechaCorta(s.hasta),
            s.condicionCierre,
            s.nivelRiesgo,
            s.alertasActivas.toString(),
            s.asistenciaPorcentaje.toStringAsFixed(2),
            s.faltas.toString(),
            s.trabajosPendientes.toString(),
            s.trabajosSinCorregir.toString(),
            s.evaluacionesRendidas.toString(),
            s.recuperatoriosRendidos.toString(),
            s.aprobadas.toString(),
            s.noAprobadas.toString(),
            s.pendientes.toString(),
            s.ausentes.toString(),
            s.promedioNumerico?.toStringAsFixed(2) ?? '',
          ],
        ],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('CSV alumno: $path')));
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _sintesis;
    final c = _comparacion;
    return AlertDialog(
      title: _textoElidido(
        'Sintesis de alumno - ${widget.alumnoNombre}',
        maxLines: 2,
      ),
      content: SizedBox(
        width: _anchoDialogo(context, 720),
        child: _cargando || s == null
            ? const EstadoListaCargando(mensaje: 'Generando sintesis...')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bloqueDescripcionFuncion(context, 'sintesis_alumno'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: 140,
                        child: DropdownButtonFormField<int>(
                          initialValue: _trimestre,
                          decoration: const InputDecoration(
                            labelText: 'Trimestre',
                          ),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('1er')),
                            DropdownMenuItem(value: 2, child: Text('2do')),
                            DropdownMenuItem(value: 3, child: Text('3er')),
                            DropdownMenuItem(value: 4, child: Text('4to')),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _trimestre = v);
                            _recargar();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: DropdownButtonFormField<int>(
                          initialValue: _anio,
                          decoration: const InputDecoration(labelText: 'Anio'),
                          items: [
                            DropdownMenuItem(
                              value: _anio - 1,
                              child: Text('${_anio - 1}'),
                            ),
                            DropdownMenuItem(
                              value: _anio,
                              child: Text('$_anio'),
                            ),
                            DropdownMenuItem(
                              value: _anio + 1,
                              child: Text('${_anio + 1}'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _anio = v);
                            _recargar();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          'Asistencia ${s.asistenciaPorcentaje.toStringAsFixed(1)}%',
                        ),
                      ),
                      Chip(
                        label: Text('Riesgo ${s.nivelRiesgo.toUpperCase()}'),
                      ),
                      Chip(label: Text('Alertas ${s.alertasActivas}')),
                      Chip(label: Text('No aprobadas ${s.noAprobadas}')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (c != null)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          label: Text(
                            'Delta asistencia ${_deltaPorcentaje(c.deltaAsistencia)} pp',
                          ),
                        ),
                        Chip(
                          label: Text(
                            'Delta faltas ${_deltaNumero(c.deltaFaltas)}',
                          ),
                        ),
                        Chip(
                          label: Text(
                            'Delta pendientes ${_deltaNumero(c.deltaTrabajosPendientes)}',
                          ),
                        ),
                        Chip(
                          label: Text(
                            'Delta no aprobadas ${_deltaNumero(c.deltaNoAprobadas)}',
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _resumenCtrl,
                    minLines: 7,
                    maxLines: 12,
                    decoration: const InputDecoration(
                      labelText: 'Resumen automatico editable para informe',
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        OutlinedButton.icon(
          onPressed: s == null || _exportando
              ? null
              : _exportarResumenAlumnoCsv,
          icon: const Icon(Icons.file_download_outlined),
          label: const Text('CSV alumno'),
        ),
        FilledButton.icon(
          onPressed: s == null ? null : _copiar,
          icon: const Icon(Icons.copy_all_outlined),
          label: const Text('Copiar'),
        ),
      ],
    );
  }
}
