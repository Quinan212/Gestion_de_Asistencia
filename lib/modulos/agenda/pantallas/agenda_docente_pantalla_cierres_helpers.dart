part of 'agenda_docente_pantalla.dart';

class _DialogCierreInstitucional extends StatefulWidget {
  final DateTime fechaReferencia;
  final String? institucionSugerida;

  const _DialogCierreInstitucional({
    required this.fechaReferencia,
    required this.institucionSugerida,
  });

  @override
  State<_DialogCierreInstitucional> createState() =>
      _DialogCierreInstitucionalState();
}

class _DialogCierreInstitucionalState
    extends State<_DialogCierreInstitucional> {
  bool _cargando = true;
  bool _exportando = false;
  List<String> _instituciones = const [];
  String? _institucion;
  List<CierreInstitucionCursoItem> _items = const [];
  late int _anio;
  late int _trimestre;

  @override
  void initState() {
    super.initState();
    _anio = widget.fechaReferencia.year;
    _trimestre = ((widget.fechaReferencia.month - 1) ~/ 3) + 1;
    _cargar();
  }

  (DateTime, DateTime) _rangoTrimestre(int anio, int trimestre) {
    final mesInicio = ((trimestre - 1) * 3) + 1;
    final desde = DateTime(anio, mesInicio, 1);
    final hasta = DateTime(anio, mesInicio + 3, 0);
    return (desde, hasta);
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final instituciones = await Proveedores.agendaDocenteRepositorio
        .listarInstitucionesConCursosActivos();

    String? institucion = _institucion;
    if (institucion == null || !instituciones.contains(institucion)) {
      final sugerida = (widget.institucionSugerida ?? '').trim();
      if (sugerida.isNotEmpty && instituciones.contains(sugerida)) {
        institucion = sugerida;
      } else {
        institucion = instituciones.isEmpty ? null : instituciones.first;
      }
    }

    List<CierreInstitucionCursoItem> items = const [];
    if (institucion != null) {
      final rango = _rangoTrimestre(_anio, _trimestre);
      items = await Proveedores.agendaDocenteRepositorio
          .generarCierreInstitucional(
            institucion: institucion,
            desde: rango.$1,
            hasta: rango.$2,
          );
    }

    if (!mounted) return;
    setState(() {
      _instituciones = instituciones;
      _institucion = institucion;
      _items = items;
      _cargando = false;
    });
  }

  Future<void> _recargarResumen() async {
    final institucion = _institucion;
    if (institucion == null) {
      setState(() => _items = const []);
      return;
    }
    setState(() => _cargando = true);
    final rango = _rangoTrimestre(_anio, _trimestre);
    final items = await Proveedores.agendaDocenteRepositorio
        .generarCierreInstitucional(
          institucion: institucion,
          desde: rango.$1,
          hasta: rango.$2,
        );
    if (!mounted) return;
    setState(() {
      _items = items;
      _cargando = false;
    });
  }

  _TotalesCierreInstitucion _totales() {
    var clases = 0;
    var registros = 0;
    var presentes = 0;
    var ausentes = 0;
    var tardes = 0;
    var justificadas = 0;
    var sinEntregar = 0;
    var sinCorregir = 0;
    var enRiesgo = 0;

    for (final i in _items) {
      final r = i.resumen;
      clases += r.clasesDictadas;
      registros += r.registrosAsistencia;
      presentes += r.presentes;
      ausentes += r.ausentes;
      tardes += r.tardes;
      justificadas += r.justificadas;
      sinEntregar += r.actividadesSinEntregar;
      sinCorregir += r.trabajosSinCorregir;
      enRiesgo += r.alumnosEnRiesgo;
    }
    return _TotalesCierreInstitucion(
      clases: clases,
      registros: registros,
      presentes: presentes,
      ausentes: ausentes,
      tardes: tardes,
      justificadas: justificadas,
      actividadesSinEntregar: sinEntregar,
      trabajosSinCorregir: sinCorregir,
      alumnosEnRiesgo: enRiesgo,
      cursos: _items.length,
    );
  }

  String _generarResumenTexto() {
    final inst = _institucion ?? 'Sin institucion';
    final rango = _rangoTrimestre(_anio, _trimestre);
    final t = _totales();
    final porcentaje = t.porcentajeAsistencia.toStringAsFixed(1);
    final d1 = _fechaCorta(rango.$1);
    final d2 = _fechaCorta(rango.$2);

    final buffer = StringBuffer();
    buffer.writeln('Cierre institucional - $inst');
    buffer.writeln('Rango: $d1 al $d2');
    buffer.writeln('Cursos: ${t.cursos}');
    buffer.writeln(
      'Asistencia: $porcentaje% (${t.presentes} presentes, ${t.tardes} tarde, ${t.justificadas} justificadas, ${t.ausentes} ausentes)',
    );
    buffer.writeln('Actividades sin entregar: ${t.actividadesSinEntregar}');
    buffer.writeln('Trabajos sin corregir: ${t.trabajosSinCorregir}');
    buffer.writeln('Alumnos en riesgo: ${t.alumnosEnRiesgo}');
    buffer.writeln('');
    buffer.writeln('Detalle por curso:');
    for (final i in _items) {
      final r = i.resumen;
      buffer.writeln(
        '- ${i.etiquetaCompleta}: clases ${r.clasesDictadas}, asistencia ${r.porcentajeAsistencia.toStringAsFixed(1)}%, riesgo ${r.alumnosEnRiesgo}',
      );
    }
    return buffer.toString().trim();
  }

  Future<void> _copiarResumen() async {
    if (_items.isEmpty) return;
    final texto = _generarResumenTexto();
    await Clipboard.setData(ClipboardData(text: texto));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resumen institucional copiado')),
    );
  }

  Future<void> _exportarCsv() async {
    if (_items.isEmpty || _exportando) return;
    final inst = (_institucion ?? 'institucion').trim();
    setState(() => _exportando = true);
    try {
      final rango = _rangoTrimestre(_anio, _trimestre);
      final filas = _items
          .map((i) {
            final r = i.resumen;
            return [
              i.institucion,
              i.carrera,
              i.materia,
              i.etiquetaCurso,
              _fechaCorta(rango.$1),
              _fechaCorta(rango.$2),
              r.clasesDictadas.toString(),
              r.registrosAsistencia.toString(),
              r.presentes.toString(),
              r.ausentes.toString(),
              r.tardes.toString(),
              r.justificadas.toString(),
              r.porcentajeAsistencia.toStringAsFixed(2),
              r.actividadesSinEntregar.toString(),
              r.trabajosSinCorregir.toString(),
              r.alumnosEnRiesgo.toString(),
            ];
          })
          .toList(growable: false);

      final path = await ExportacionCsv.guardarCsv(
        nombreBase: 'cierre_institucional_${inst}_${_anio}_t$_trimestre',
        encabezados: const [
          'institucion',
          'carrera',
          'materia',
          'curso',
          'desde',
          'hasta',
          'clases_dictadas',
          'registros_asistencia',
          'presentes',
          'ausentes',
          'tardes',
          'justificadas',
          'porcentaje_asistencia',
          'actividades_sin_entregar',
          'trabajos_sin_corregir',
          'alumnos_en_riesgo',
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
        const SnackBar(content: Text('No se pudo exportar CSV institucional')),
      );
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _totales();
    return AlertDialog(
      title: const Text('Panel de cierre institucional'),
      content: SizedBox(
        width: 980,
        height: 680,
        child: _cargando
            ? const EstadoListaCargando(mensaje: 'Generando cierre...')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bloqueDescripcionFuncion(context, 'cierre_institucional'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: 280,
                        child: DropdownButtonFormField<String>(
                          initialValue: _institucion,
                          decoration: const InputDecoration(
                            labelText: 'Institucion',
                          ),
                          items: _instituciones
                              .map(
                                (i) =>
                                    DropdownMenuItem(value: i, child: Text(i)),
                              )
                              .toList(growable: false),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _institucion = v);
                            _recargarResumen();
                          },
                        ),
                      ),
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
                            _recargarResumen();
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
                            _recargarResumen();
                          },
                        ),
                      ),
                      IconButton(
                        tooltip: 'Recargar',
                        onPressed: _recargarResumen,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('Cursos: ${t.cursos}')),
                      Chip(label: Text('Clases: ${t.clases}')),
                      Chip(
                        label: Text(
                          'Asistencia: ${t.porcentajeAsistencia.toStringAsFixed(1)}%',
                        ),
                      ),
                      Chip(
                        label: Text(
                          'Sin entregar: ${t.actividadesSinEntregar}',
                        ),
                      ),
                      Chip(
                        label: Text('Sin corregir: ${t.trabajosSinCorregir}'),
                      ),
                      Chip(label: Text('Riesgo: ${t.alumnosEnRiesgo}')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _items.isEmpty
                        ? const EstadoListaVacia(
                            titulo: 'No hay cursos para ese rango',
                            icono: Icons.summarize_outlined,
                          )
                        : ListView.separated(
                            itemCount: _items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, idx) {
                              final i = _items[idx];
                              final r = i.resumen;
                              return Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${i.carrera} | ${i.materia} (${i.etiquetaCurso})',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Clases: ${r.clasesDictadas} | Asistencia: ${r.porcentajeAsistencia.toStringAsFixed(1)}% | Sin entregar: ${r.actividadesSinEntregar} | Sin corregir: ${r.trabajosSinCorregir} | Riesgo: ${r.alumnosEnRiesgo}',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cerrar'),
        ),
        OutlinedButton.icon(
          onPressed: _items.isEmpty ? null : _copiarResumen,
          icon: const Icon(Icons.copy_all_outlined),
          label: const Text('Copiar resumen'),
        ),
        FilledButton.icon(
          onPressed: _items.isEmpty || _exportando ? null : _exportarCsv,
          icon: const Icon(Icons.download_outlined),
          label: Text(_exportando ? 'Exportando...' : 'Exportar CSV'),
        ),
      ],
    );
  }
}

Future<PlantillaDocente?> _mostrarSelectorPlantillaDocente({
  required BuildContext context,
  required int cursoId,
  required String institucion,
  String? tipoInicial,
  String titulo = 'Seleccionar plantilla',
}) {
  String filtroTipo = (tipoInicial ?? 'todas').trim().toLowerCase();
  if (filtroTipo.isEmpty) filtroTipo = 'todas';
  bool cargando = true;
  List<PlantillaDocente> plantillas = const [];

  Future<void> recargar(StateSetter setStateDialog) async {
    setStateDialog(() => cargando = true);
    final tipo = filtroTipo == 'todas' ? null : filtroTipo;
    final data = await Proveedores.agendaDocenteRepositorio
        .listarPlantillasParaCurso(
          institucion: institucion,
          cursoId: cursoId,
          tipo: tipo,
          limite: 120,
        );
    setStateDialog(() {
      plantillas = data;
      cargando = false;
    });
  }

  return showDialog<PlantillaDocente>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setStateDialog) {
        if (cargando && plantillas.isEmpty) {
          recargar(setStateDialog);
        }
        return AlertDialog(
          title: Text(titulo),
          content: SizedBox(
            width: 860,
            height: 560,
            child: Column(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: 280,
                      child: DropdownButtonFormField<String>(
                        initialValue: filtroTipo,
                        decoration: const InputDecoration(labelText: 'Tipo'),
                        items: [
                          const DropdownMenuItem(
                            value: 'todas',
                            child: Text('Todas'),
                          ),
                          ..._tiposPlantillaDocente.map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(_labelTipoPlantillaDocente(t)),
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setStateDialog(() => filtroTipo = v);
                          recargar(setStateDialog);
                        },
                      ),
                    ),
                    IconButton(
                      tooltip: 'Recargar',
                      onPressed: () => recargar(setStateDialog),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: cargando
                      ? const EstadoListaCargando(mensaje: 'Cargando...')
                      : plantillas.isEmpty
                      ? const EstadoListaVacia(
                          titulo: 'No hay plantillas para ese contexto',
                          icono: Icons.text_snippet_outlined,
                        )
                      : ListView.separated(
                          itemCount: plantillas.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (_, idx) {
                            final p = plantillas[idx];
                            return Card(
                              margin: EdgeInsets.zero,
                              child: ListTile(
                                title: Text(
                                  '[${_labelTipoPlantillaDocente(p.tipo)}] ${p.titulo}',
                                ),
                                subtitle: Text(
                                  '${p.contenido}\nAlcance: ${_labelAlcancePlantilla(p)} | Usos: ${p.usoCount}',
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                isThreeLine: true,
                                trailing: FilledButton(
                                  onPressed: () => Navigator.pop(context, p),
                                  child: const Text('Usar'),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    ),
  );
}

class _DialogCierreCurso extends StatefulWidget {
  final int cursoId;
  final String cursoEtiqueta;
  final DateTime fechaReferencia;

  const _DialogCierreCurso({
    required this.cursoId,
    required this.cursoEtiqueta,
    required this.fechaReferencia,
  });

  @override
  State<_DialogCierreCurso> createState() => _DialogCierreCursoState();
}

class _DialogCierreCursoState extends State<_DialogCierreCurso> {
  late int _anio;
  late int _trimestre;
  bool _cargando = true;
  ResumenCierreCurso? _resumen;

  @override
  void initState() {
    super.initState();
    _anio = widget.fechaReferencia.year;
    _trimestre = ((widget.fechaReferencia.month - 1) ~/ 3) + 1;
    _recargar();
  }

  Future<void> _recargar() async {
    setState(() => _cargando = true);
    final rango = _rangoTrimestre(_anio, _trimestre);
    final resumen = await Proveedores.agendaDocenteRepositorio
        .generarCierreCurso(
          cursoId: widget.cursoId,
          desde: rango.$1,
          hasta: rango.$2,
        );
    if (!mounted) return;
    setState(() {
      _resumen = resumen;
      _cargando = false;
    });
  }

  (DateTime, DateTime) _rangoTrimestre(int anio, int trimestre) {
    final mesInicio = ((trimestre - 1) * 3) + 1;
    final desde = DateTime(anio, mesInicio, 1);
    final hasta = DateTime(anio, mesInicio + 3, 0);
    return (desde, hasta);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cierre de periodo - ${widget.cursoEtiqueta}'),
      content: SizedBox(
        width: 620,
        child: _cargando || _resumen == null
            ? const EstadoListaCargando(mensaje: 'Generando cierre...')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bloqueDescripcionFuncion(context, 'cierre_curso'),
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
                  Text(
                    _resumen!.generarTexto(widget.cursoEtiqueta),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        FilledButton.icon(
          onPressed: _resumen == null
              ? null
              : () => Navigator.pop(context, _resumen),
          icon: const Icon(Icons.copy_all_outlined),
          label: const Text('Copiar resumen'),
        ),
      ],
    );
  }
}

class _EvaluacionEdicion {
  final DateTime fecha;
  final String tipo;
  final String titulo;
  final String descripcion;

  const _EvaluacionEdicion({
    required this.fecha,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
  });
}

class _ResultadoEvaluacionEdicion {
  final String estado;
  final String calificacion;
  final bool entregaComplementaria;
  final bool ausenteJustificado;
  final String observacion;

  const _ResultadoEvaluacionEdicion({
    required this.estado,
    required this.calificacion,
    required this.entregaComplementaria,
    required this.ausenteJustificado,
    required this.observacion,
  });
}

class _PlantillaEdicion {
  final String tipo;
  final String alcance;
  final String titulo;
  final String contenido;
  final String atajo;
  final int orden;

  const _PlantillaEdicion({
    required this.tipo,
    required this.alcance,
    required this.titulo,
    required this.contenido,
    required this.atajo,
    required this.orden,
  });
}

String _normalizarEstadoEvaluacion(String estado) {
  final s = estado.trim().toLowerCase();
  if (s == 'aprobado') return 'aprobado';
  if (s == 'en_proceso' || s == 'proceso') return 'en_proceso';
  if (s == 'recuperacion' || s == 'recupera' || s == 'recuperatorio') {
    return 'recuperacion';
  }
  if (s == 'no_aprobado' || s == 'desaprobado') return 'no_aprobado';
  if (s == 'ausente') return 'ausente';
  return 'pendiente';
}

String _labelEstadoEvaluacion(String estado) {
  switch (_normalizarEstadoEvaluacion(estado)) {
    case 'aprobado':
      return 'Aprobado';
    case 'en_proceso':
      return 'En proceso';
    case 'recuperacion':
      return 'Recuperacion';
    case 'no_aprobado':
      return 'No aprobado';
    case 'ausente':
      return 'Ausente';
    case 'pendiente':
    default:
      return 'Pendiente';
  }
}

String _labelInstanciaEvaluacion(EvaluacionInstancia instancia) {
  if (instancia.orden <= 0) return 'Evaluacion original';
  if (instancia.orden == 1) return 'Recuperatorio 1';
  if (instancia.orden == 2) return 'Recuperatorio 2';
  return 'Recuperatorio ${instancia.orden}';
}

const List<String> _tiposPlantillaDocente = [
  'comentario_boletin',
  'devolucion',
  'observacion_tipo',
  'criterio_seguimiento',
  'estado_actividad',
  'mensaje_base',
];

String _labelTipoPlantillaDocente(String tipo) {
  switch (tipo.trim().toLowerCase()) {
    case 'comentario_boletin':
      return 'Comentario boletin';
    case 'devolucion':
      return 'Devolucion';
    case 'observacion_tipo':
      return 'Observacion tipo';
    case 'criterio_seguimiento':
      return 'Criterio seguimiento';
    case 'estado_actividad':
      return 'Estado actividad';
    case 'mensaje_base':
    default:
      return 'Mensaje base';
  }
}

String _labelAlcancePlantilla(PlantillaDocente p) {
  if (p.cursoId != null) return 'Curso';
  if ((p.institucion ?? '').trim().isNotEmpty) return 'Institucion';
  return 'General';
}

class _TotalesCierreInstitucion {
  final int cursos;
  final int clases;
  final int registros;
  final int presentes;
  final int ausentes;
  final int tardes;
  final int justificadas;
  final int actividadesSinEntregar;
  final int trabajosSinCorregir;
  final int alumnosEnRiesgo;

  const _TotalesCierreInstitucion({
    required this.cursos,
    required this.clases,
    required this.registros,
    required this.presentes,
    required this.ausentes,
    required this.tardes,
    required this.justificadas,
    required this.actividadesSinEntregar,
    required this.trabajosSinCorregir,
    required this.alumnosEnRiesgo,
  });

  double get porcentajeAsistencia {
    if (registros <= 0) return 0;
    final computables = presentes + tardes + justificadas;
    return (computables / registros) * 100;
  }
}

class _HorarioFila {
  int diaSemana;
  String horaInicio;
  String horaFin;
  String aula;

  _HorarioFila({
    required this.diaSemana,
    this.horaInicio = '',
    this.horaFin = '',
    this.aula = '',
  });
}

bool _horaValida(String hora) {
  return RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$').hasMatch(hora);
}

DateTime _soloFecha(DateTime fecha) {
  return DateTime(fecha.year, fecha.month, fecha.day);
}

bool _esMismoDia(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _fechaCorta(DateTime fecha) {
  final d = fecha.day.toString().padLeft(2, '0');
  final m = fecha.month.toString().padLeft(2, '0');
  return '$d/$m/${fecha.year}';
}

String _fechaHora(DateTime fecha) {
  final d = _fechaCorta(fecha);
  final hh = fecha.hour.toString().padLeft(2, '0');
  final mm = fecha.minute.toString().padLeft(2, '0');
  return '$d $hh:$mm';
}

String _fechaLarga(DateTime fecha) {
  const dias = <int, String>{
    1: 'Lunes',
    2: 'Martes',
    3: 'Miercoles',
    4: 'Jueves',
    5: 'Viernes',
    6: 'Sabado',
    7: 'Domingo',
  };
  return '${dias[fecha.weekday]}, ${_fechaCorta(fecha)}';
}
