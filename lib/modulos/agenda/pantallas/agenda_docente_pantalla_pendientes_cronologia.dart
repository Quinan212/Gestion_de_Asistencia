part of 'agenda_docente_pantalla.dart';

class _DialogPendientesAccionables extends StatefulWidget {
  final DateTime fechaReferencia;

  const _DialogPendientesAccionables({required this.fechaReferencia});

  @override
  State<_DialogPendientesAccionables> createState() =>
      _DialogPendientesAccionablesState();
}

class _DialogPendientesAccionablesState
    extends State<_DialogPendientesAccionables> {
  bool _cargando = true;
  String _filtroInstitucion = 'todas';
  String _filtroTipo = 'todos';
  List<String> _instituciones = const [];
  PanelPendientesAccionables? _panel;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final instituciones = await Proveedores.agendaDocenteRepositorio
        .listarInstitucionesConCursosActivos();
    var institucion = _filtroInstitucion;
    if (institucion != 'todas' && !instituciones.contains(institucion)) {
      institucion = 'todas';
    }
    final panel = await Proveedores.agendaDocenteRepositorio
        .generarPanelPendientesAccionables(
          widget.fechaReferencia,
          institucion: institucion == 'todas' ? null : institucion,
        );
    if (!mounted) return;
    setState(() {
      _instituciones = instituciones;
      _filtroInstitucion = institucion;
      _panel = panel;
      _cargando = false;
    });
  }

  List<PendienteAccionableDocente> _filtrados() {
    final panel = _panel;
    if (panel == null) return const [];
    if (_filtroTipo == 'todos') return panel.pendientes;
    return panel.pendientes
        .where((p) => p.tipo == _filtroTipo)
        .toList(growable: false);
  }

  String _labelTipo(String tipo) {
    switch (tipo) {
      case 'evaluacion_por_cerrar':
        return 'Evaluaciones';
      case 'entrega_por_corregir':
        return 'Entregas';
      case 'alumno_en_riesgo':
        return 'Riesgo';
      case 'clase_incompleta':
        return 'Clases incompletas';
      case 'acuerdo_abierto':
        return 'Acuerdos';
      case 'alerta_no_revisada':
        return 'Alertas';
      default:
        return 'Otros';
    }
  }

  IconData _iconoTipo(String tipo) {
    switch (tipo) {
      case 'evaluacion_por_cerrar':
        return Icons.rule_folder_outlined;
      case 'entrega_por_corregir':
        return Icons.assignment_late_outlined;
      case 'alumno_en_riesgo':
        return Icons.warning_amber_rounded;
      case 'clase_incompleta':
        return Icons.event_note_outlined;
      case 'acuerdo_abierto':
        return Icons.handshake_outlined;
      case 'alerta_no_revisada':
        return Icons.notifications_active_outlined;
      default:
        return Icons.pending_actions_outlined;
    }
  }

  Color _colorPrioridad(BuildContext context, String prioridad) {
    final p = prioridad.trim().toLowerCase();
    if (p == 'alta') return Colors.red.shade700;
    if (p == 'media') return Colors.orange.shade700;
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final panel = _panel;
    final items = _filtrados();
    return AlertDialog(
      title: const Text('Panel de pendientes accionables'),
      content: SizedBox(
        width: _anchoDialogo(context, 980),
        height: _altoDialogo(context, 700),
        child: _cargando
            ? const EstadoListaCargando(mensaje: 'Cargando pendientes...')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bloqueDescripcionFuncion(context, 'pendientes'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: 260,
                        child: DropdownButtonFormField<String>(
                          initialValue: _filtroInstitucion,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Institucion',
                          ),
                          items: [
                            _itemMenuElidido('todas', 'Todas'),
                            ..._instituciones.map(
                              (i) => _itemMenuElidido(i, i),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _filtroInstitucion = v);
                            _cargar();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<String>(
                          initialValue: _filtroTipo,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de pendiente',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'todos',
                              child: Text('Todos'),
                            ),
                            DropdownMenuItem(
                              value: 'evaluacion_por_cerrar',
                              child: Text('Evaluaciones'),
                            ),
                            DropdownMenuItem(
                              value: 'entrega_por_corregir',
                              child: Text('Entregas'),
                            ),
                            DropdownMenuItem(
                              value: 'alumno_en_riesgo',
                              child: Text('Riesgo'),
                            ),
                            DropdownMenuItem(
                              value: 'clase_incompleta',
                              child: Text('Clases incompletas'),
                            ),
                            DropdownMenuItem(
                              value: 'acuerdo_abierto',
                              child: Text('Acuerdos'),
                            ),
                            DropdownMenuItem(
                              value: 'alerta_no_revisada',
                              child: Text('Alertas'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _filtroTipo = v);
                          },
                        ),
                      ),
                      IconButton(
                        tooltip: 'Recargar',
                        onPressed: _cargar,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (panel != null)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('Total: ${panel.total}')),
                        Chip(
                          label: Text(
                            'Evaluaciones: ${panel.evaluacionesPorCerrar}',
                          ),
                        ),
                        Chip(
                          label: Text('Entregas: ${panel.entregasPorCorregir}'),
                        ),
                        Chip(label: Text('Riesgo: ${panel.alumnosEnRiesgo}')),
                        Chip(
                          label: Text(
                            'Clases incompletas: ${panel.clasesIncompletas}',
                          ),
                        ),
                        Chip(
                          label: Text(
                            'Acuerdos abiertos: ${panel.acuerdosAbiertos}',
                          ),
                        ),
                        Chip(
                          label: Text(
                            'Alertas sin revisar: ${panel.alertasSinRevisar}',
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: items.isEmpty
                        ? const EstadoListaVacia(
                            titulo: 'No hay pendientes para los filtros',
                            icono: Icons.task_alt_outlined,
                          )
                        : ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final p = items[i];
                              final color = _colorPrioridad(
                                context,
                                p.prioridad,
                              );
                              return ListTile(
                                dense: true,
                                leading: Icon(_iconoTipo(p.tipo), color: color),
                                title: Text(p.titulo),
                                subtitle: Text(
                                  '${_labelTipo(p.tipo)} | ${p.institucion} | ${p.materia} (${p.etiquetaCurso})\n${p.detalle}\nAccion: ${p.accionSugerida}',
                                ),
                                isThreeLine: true,
                                trailing: Chip(
                                  label: Text(p.prioridad.toUpperCase()),
                                  backgroundColor: color.withValues(alpha: 0.1),
                                  side: BorderSide(
                                    color: color.withValues(alpha: 0.3),
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
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class _DialogCronologiaAlumno extends StatefulWidget {
  final int cursoId;
  final int alumnoId;
  final String alumnoNombre;
  final String tituloCurso;

  const _DialogCronologiaAlumno({
    required this.cursoId,
    required this.alumnoId,
    required this.alumnoNombre,
    required this.tituloCurso,
  });

  @override
  State<_DialogCronologiaAlumno> createState() =>
      _DialogCronologiaAlumnoState();
}

class _DialogCronologiaAlumnoState extends State<_DialogCronologiaAlumno> {
  bool _cargando = true;
  String _filtroTipo = 'todos';
  List<EventoCronologicoAlumno> _eventos = const [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final eventos = await Proveedores.agendaDocenteRepositorio
        .listarCronologiaAlumnoCurso(
          cursoId: widget.cursoId,
          alumnoId: widget.alumnoId,
        );
    if (!mounted) return;
    setState(() {
      _eventos = eventos;
      _cargando = false;
    });
  }

  List<EventoCronologicoAlumno> _filtrados() {
    if (_filtroTipo == 'todos') return _eventos;
    return _eventos.where((e) => e.tipo == _filtroTipo).toList(growable: false);
  }

  String _labelTipo(String tipo) {
    switch (tipo) {
      case 'asistencia':
        return 'Asistencia';
      case 'entrega':
        return 'Entregas';
      case 'intervencion':
        return 'Intervenciones';
      case 'evaluacion':
        return 'Evaluaciones';
      case 'evidencia':
        return 'Evidencias';
      case 'mejora':
        return 'Mejoras';
      case 'observacion':
        return 'Observaciones';
      default:
        return 'Otros';
    }
  }

  IconData _iconoTipo(String tipo) {
    switch (tipo) {
      case 'asistencia':
        return Icons.fact_check_outlined;
      case 'entrega':
        return Icons.assignment_turned_in_outlined;
      case 'intervencion':
        return Icons.record_voice_over_outlined;
      case 'evaluacion':
        return Icons.rule_folder_outlined;
      case 'evidencia':
        return Icons.attach_file_outlined;
      case 'mejora':
        return Icons.trending_up_outlined;
      case 'observacion':
        return Icons.note_alt_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Color _colorPrioridad(BuildContext context, String prioridad) {
    final p = prioridad.trim().toLowerCase();
    if (p == 'alta') return Colors.red.shade700;
    if (p == 'media') return Colors.orange.shade700;
    return Theme.of(context).colorScheme.primary;
  }

  int _conteoTipo(String tipo) {
    return _eventos.where((e) => e.tipo == tipo).length;
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtrados();
    return AlertDialog(
      title: _textoElidido('Cronologia - ${widget.alumnoNombre}', maxLines: 2),
      content: SizedBox(
        width: _anchoDialogo(context, 980),
        height: _altoDialogo(context, 700),
        child: _cargando
            ? const EstadoListaCargando(mensaje: 'Cargando cronologia...')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textoElidido(widget.tituloCurso, maxLines: 2),
                  const SizedBox(height: 8),
                  _bloqueDescripcionFuncion(context, 'cronologia'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<String>(
                          initialValue: _filtroTipo,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de evento',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'todos',
                              child: Text('Todos'),
                            ),
                            DropdownMenuItem(
                              value: 'asistencia',
                              child: Text('Asistencia'),
                            ),
                            DropdownMenuItem(
                              value: 'entrega',
                              child: Text('Entregas'),
                            ),
                            DropdownMenuItem(
                              value: 'intervencion',
                              child: Text('Intervenciones'),
                            ),
                            DropdownMenuItem(
                              value: 'evaluacion',
                              child: Text('Evaluaciones'),
                            ),
                            DropdownMenuItem(
                              value: 'evidencia',
                              child: Text('Evidencias'),
                            ),
                            DropdownMenuItem(
                              value: 'observacion',
                              child: Text('Observaciones'),
                            ),
                            DropdownMenuItem(
                              value: 'mejora',
                              child: Text('Mejoras'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _filtroTipo = v);
                          },
                        ),
                      ),
                      IconButton(
                        tooltip: 'Recargar',
                        onPressed: _cargar,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('Eventos: ${_eventos.length}')),
                      Chip(
                        label: Text('Asistencia: ${_conteoTipo('asistencia')}'),
                      ),
                      Chip(label: Text('Entregas: ${_conteoTipo('entrega')}')),
                      Chip(
                        label: Text(
                          'Evaluaciones: ${_conteoTipo('evaluacion')}',
                        ),
                      ),
                      Chip(
                        label: Text(
                          'Intervenciones: ${_conteoTipo('intervencion')}',
                        ),
                      ),
                      Chip(
                        label: Text('Evidencias: ${_conteoTipo('evidencia')}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: items.isEmpty
                        ? const EstadoListaVacia(
                            titulo: 'No hay eventos para mostrar',
                            icono: Icons.timeline_outlined,
                          )
                        : ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final e = items[i];
                              final color = _colorPrioridad(
                                context,
                                e.prioridad,
                              );
                              return ListTile(
                                dense: true,
                                leading: Icon(_iconoTipo(e.tipo), color: color),
                                title: Text(e.titulo),
                                subtitle: Text(
                                  '${_fechaHora(e.fecha)} | ${_labelTipo(e.tipo)}\n${e.detalle}',
                                ),
                                isThreeLine: true,
                                trailing: Chip(
                                  label: Text(e.prioridad.toUpperCase()),
                                  backgroundColor: color.withValues(alpha: 0.1),
                                  side: BorderSide(
                                    color: color.withValues(alpha: 0.3),
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
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
