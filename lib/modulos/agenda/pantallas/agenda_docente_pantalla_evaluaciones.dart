part of 'agenda_docente_pantalla.dart';

class _DialogEvaluacionesCurso extends StatefulWidget {
  final int cursoId;
  final String institucion;
  final String tituloCurso;

  const _DialogEvaluacionesCurso({
    required this.cursoId,
    required this.institucion,
    required this.tituloCurso,
  });

  @override
  State<_DialogEvaluacionesCurso> createState() =>
      _DialogEvaluacionesCursoState();
}

class _DialogEvaluacionesCursoState extends State<_DialogEvaluacionesCurso> {
  bool _cargando = true;
  bool _huboCambios = false;
  String _filtroTipo = 'todos';
  String _filtroEstadoLista = 'todos';
  List<EvaluacionCurso> _evaluaciones = const [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final evaluaciones = await Proveedores.agendaDocenteRepositorio
        .listarEvaluacionesCurso(widget.cursoId);
    if (!mounted) return;
    setState(() {
      _evaluaciones = evaluaciones;
      _cargando = false;
    });
  }

  List<String> _tiposDisponibles() {
    final tipos = _evaluaciones.map((e) => e.tipo.trim()).toSet().toList();
    tipos.removeWhere((t) => t.isEmpty);
    tipos.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return tipos;
  }

  List<EvaluacionCurso> _filtradas() {
    return _evaluaciones
        .where((e) {
          if (_filtroTipo != 'todos' && e.tipo.trim() != _filtroTipo) {
            return false;
          }
          if (_filtroEstadoLista == 'abiertas' && e.cerrada) return false;
          if (_filtroEstadoLista == 'cerradas' && !e.cerrada) return false;
          return true;
        })
        .toList(growable: false);
  }

  Future<void> _crearOEditar({EvaluacionCurso? actual}) async {
    final edicion = await showDialog<_EvaluacionEdicion>(
      context: context,
      builder: (context) => _DialogEdicionEvaluacion(actual: actual),
    );
    if (edicion == null) return;

    if (actual == null) {
      await Proveedores.agendaDocenteRepositorio.crearEvaluacionCurso(
        cursoId: widget.cursoId,
        fecha: edicion.fecha,
        tipo: edicion.tipo,
        titulo: edicion.titulo,
        descripcion: edicion.descripcion,
      );
    } else {
      await Proveedores.agendaDocenteRepositorio.actualizarEvaluacionCurso(
        evaluacionId: actual.id,
        fecha: edicion.fecha,
        tipo: edicion.tipo,
        titulo: edicion.titulo,
        descripcion: edicion.descripcion,
      );
    }

    _huboCambios = true;
    await _cargar();
  }

  Future<void> _eliminar(EvaluacionCurso evaluacion) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar evaluacion'),
        content: Text(
          'Se eliminara "${evaluacion.titulo}". Tambien se borraran sus resultados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await Proveedores.agendaDocenteRepositorio.eliminarEvaluacionCurso(
      evaluacion.id,
    );
    _huboCambios = true;
    await _cargar();
  }

  Future<void> _alternarEstado(EvaluacionCurso evaluacion) async {
    final nuevo = evaluacion.cerrada ? 'abierta' : 'cerrada';
    await Proveedores.agendaDocenteRepositorio.actualizarEstadoEvaluacion(
      evaluacionId: evaluacion.id,
      estado: nuevo,
    );
    _huboCambios = true;
    await _cargar();
  }

  Future<void> _abrirResultados(EvaluacionCurso evaluacion) async {
    final huboCambios = await showDialog<bool>(
      context: context,
      builder: (context) => _DialogResultadosEvaluacion(
        evaluacion: evaluacion,
        institucion: widget.institucion,
        tituloCurso: widget.tituloCurso,
      ),
    );
    if (huboCambios == true) {
      _huboCambios = true;
      await _cargar();
    }
  }

  Future<void> _generarRecuperatorio(EvaluacionCurso evaluacion) async {
    try {
      await Proveedores.agendaDocenteRepositorio.generarRecuperatorioEvaluacion(
        evaluacionId: evaluacion.id,
      );
      _huboCambios = true;
      await _cargar();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Recuperatorio generado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Bad state: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _filtradas();
    final tipos = _tiposDisponibles();
    return AlertDialog(
      title: _tituloDialogoCurso('Evaluaciones', widget.tituloCurso),
      content: SizedBox(
        width: _anchoDialogo(context, 920),
        height: _altoDialogo(context, 620),
        child: _cargando
            ? const EstadoListaCargando(mensaje: 'Cargando evaluaciones...')
            : Column(
                children: [
                  _bloqueDescripcionFuncion(context, 'evaluaciones'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _crearOEditar(),
                        icon: const Icon(Icons.add),
                        label: const Text('Nueva evaluacion'),
                      ),
                      SizedBox(
                        width: 240,
                        child: DropdownButtonFormField<String>(
                          initialValue: _filtroTipo,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Tipo'),
                          items: [
                            _itemMenuElidido('todos', 'Todos'),
                            ...tipos.map((t) => _itemMenuElidido(t, t)),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _filtroTipo = v);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: DropdownButtonFormField<String>(
                          initialValue: _filtroEstadoLista,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                          ),
                          items: [
                            _itemMenuElidido('todos', 'Todos'),
                            _itemMenuElidido('abiertas', 'Abiertas'),
                            _itemMenuElidido('cerradas', 'Cerradas'),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _filtroEstadoLista = v);
                          },
                        ),
                      ),
                      Chip(
                        label: Text(
                          'Visibles: ${filtradas.length}/${_evaluaciones.length}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtradas.isEmpty
                        ? const EstadoListaVacia(
                            titulo: 'No hay evaluaciones para ese filtro',
                            icono: Icons.rule_folder_outlined,
                          )
                        : ListView.separated(
                            itemCount: filtradas.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final e = filtradas[i];
                              return Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${e.tipo} - ${e.titulo}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_fechaCorta(e.fecha)} | Estado: ${e.cerrada ? 'Cerrada' : 'Abierta'}',
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Instancias: ${e.instancias} | Carga: ${e.resultadosCargados} resultados',
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Primera instancia aprobados: ${e.aprobadosPrimeraInstancia} | Fueron a recuperatorio: ${e.fueronARecuperatorio} | Aprobaron luego: ${e.aprobaronLuegoRecuperatorio}',
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Final: Aprobados ${e.aprobados} | No aprobados ${e.noAprobadosFinales} | Pendientes ${e.pendientes} | Ausentes ${e.ausentesFinales}',
                                      ),
                                      if ((e.descripcion ?? '')
                                          .trim()
                                          .isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            'Obs: ${e.descripcion}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: () =>
                                                _abrirResultados(e),
                                            icon: const Icon(
                                              Icons
                                                  .assignment_turned_in_outlined,
                                            ),
                                            label: const Text('Resultados'),
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: () =>
                                                _crearOEditar(actual: e),
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                            ),
                                            label: const Text('Editar'),
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: () => _alternarEstado(e),
                                            icon: Icon(
                                              e.cerrada
                                                  ? Icons.lock_open_outlined
                                                  : Icons.lock_outline,
                                            ),
                                            label: Text(
                                              e.cerrada ? 'Reabrir' : 'Cerrar',
                                            ),
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: e.cerrada
                                                ? () => _generarRecuperatorio(e)
                                                : null,
                                            icon: const Icon(
                                              Icons.restart_alt_outlined,
                                            ),
                                            label: const Text(
                                              'Generar recuperatorio',
                                            ),
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: () => _eliminar(e),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                            label: const Text('Eliminar'),
                                          ),
                                        ],
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
          onPressed: () => Navigator.pop(context, _huboCambios),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class _DialogEdicionEvaluacion extends StatefulWidget {
  final EvaluacionCurso? actual;

  const _DialogEdicionEvaluacion({required this.actual});

  @override
  State<_DialogEdicionEvaluacion> createState() =>
      _DialogEdicionEvaluacionState();
}

class _DialogEdicionEvaluacionState extends State<_DialogEdicionEvaluacion> {
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descripcionCtrl;
  late DateTime _fecha;
  late String _tipo;
  String? _error;

  static const List<String> _tipos = [
    'Trabajo practico',
    'Oral',
    'Parcial',
    'Entrega complementaria',
    'Observacion de desempeno',
  ];

  @override
  void initState() {
    super.initState();
    final actual = widget.actual;
    _tituloCtrl = TextEditingController(text: actual?.titulo ?? '');
    _descripcionCtrl = TextEditingController(text: actual?.descripcion ?? '');
    _fecha = actual?.fecha ?? _soloFecha(DateTime.now());
    _tipo = actual?.tipo ?? _tipos.first;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (fecha == null) return;
    setState(() => _fecha = _soloFecha(fecha));
  }

  void _guardar() {
    final titulo = _tituloCtrl.text.trim();
    if (titulo.isEmpty) {
      setState(() => _error = 'El titulo es obligatorio');
      return;
    }
    Navigator.pop(
      context,
      _EvaluacionEdicion(
        fecha: _fecha,
        tipo: _tipo,
        titulo: titulo,
        descripcion: _descripcionCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.actual == null ? 'Nueva evaluacion' : 'Editar evaluacion',
      ),
      content: SizedBox(
        width: _anchoDialogo(context, 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            SizedBox(
              width: 260,
              child: DropdownButtonFormField<String>(
                initialValue: _tipo,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: _tipos
                    .map((t) => _itemMenuElidido(t, t))
                    .toList(growable: false),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _tipo = v);
                },
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _seleccionarFecha,
              icon: const Icon(Icons.event_outlined),
              label: Text('Fecha: ${_fechaCorta(_fecha)}'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(labelText: 'Titulo'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descripcionCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Observacion (opcional)',
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
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}

class _DialogResultadosEvaluacion extends StatefulWidget {
  final EvaluacionCurso evaluacion;
  final String institucion;
  final String tituloCurso;

  const _DialogResultadosEvaluacion({
    required this.evaluacion,
    required this.institucion,
    required this.tituloCurso,
  });

  @override
  State<_DialogResultadosEvaluacion> createState() =>
      _DialogResultadosEvaluacionState();
}

class _DialogResultadosEvaluacionState
    extends State<_DialogResultadosEvaluacion> {
  bool _cargando = true;
  bool _huboCambios = false;
  bool _generandoRecuperatorio = false;
  String _filtroEstado = 'todos';
  List<EvaluacionInstancia> _instancias = const [];
  int? _instanciaSeleccionadaId;
  List<ResultadoEvaluacionAlumno> _resultados = const [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  EvaluacionInstancia? get _instanciaActual {
    final id = _instanciaSeleccionadaId;
    if (id == null) return null;
    for (final i in _instancias) {
      if (i.id == id) return i;
    }
    return null;
  }

  Future<void> _cargar({int? mantenerInstanciaId}) async {
    setState(() => _cargando = true);
    final instancias = await Proveedores.agendaDocenteRepositorio
        .listarInstanciasEvaluacion(widget.evaluacion.id);
    int? instanciaId = mantenerInstanciaId ?? _instanciaSeleccionadaId;
    if (instancias.isEmpty) {
      instanciaId = null;
    } else {
      final existe =
          instanciaId != null && instancias.any((i) => i.id == instanciaId);
      if (!existe) {
        instanciaId = instancias.last.id;
      }
    }
    final resultados = instanciaId == null
        ? const <ResultadoEvaluacionAlumno>[]
        : await Proveedores.agendaDocenteRepositorio.listarResultadosEvaluacion(
            widget.evaluacion.id,
            evaluacionInstanciaId: instanciaId,
          );
    if (!mounted) return;
    setState(() {
      _instancias = instancias;
      _instanciaSeleccionadaId = instanciaId;
      _resultados = resultados;
      _cargando = false;
    });
  }

  List<ResultadoEvaluacionAlumno> _filtrados() {
    if (_filtroEstado == 'todos') return _resultados;
    return _resultados
        .where(
          (r) => _normalizarEstadoEvaluacion(r.condicionFinal) == _filtroEstado,
        )
        .toList(growable: false);
  }

  Future<void> _editarResultado(ResultadoEvaluacionAlumno resultado) async {
    final edicion = await showDialog<_ResultadoEvaluacionEdicion>(
      context: context,
      builder: (context) => _DialogEdicionResultado(
        cursoId: widget.evaluacion.cursoId,
        institucion: widget.institucion,
        alumnoNombre: resultado.alumnoNombre,
        actual: resultado,
      ),
    );
    if (edicion == null) return;
    try {
      await Proveedores.agendaDocenteRepositorio.guardarResultadoEvaluacion(
        evaluacionId: widget.evaluacion.id,
        evaluacionInstanciaId: _instanciaSeleccionadaId,
        alumnoId: resultado.alumnoId,
        estado: edicion.estado,
        calificacion: edicion.calificacion,
        entregaComplementaria: edicion.entregaComplementaria,
        ausenteJustificado: edicion.ausenteJustificado,
        observacion: edicion.observacion,
      );
      _huboCambios = true;
      await _cargar(mantenerInstanciaId: _instanciaSeleccionadaId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Bad state: ', ''))),
      );
    }
  }

  Future<void> _alternarEstadoInstancia() async {
    final instancia = _instanciaActual;
    if (instancia == null) return;
    final abierta = instancia.estado.trim().toLowerCase() != 'cerrada';
    final nuevo = abierta ? 'cerrada' : 'abierta';
    await Proveedores.agendaDocenteRepositorio
        .actualizarEstadoInstanciaEvaluacion(
          instanciaId: instancia.id,
          estado: nuevo,
        );
    _huboCambios = true;
    await _cargar(mantenerInstanciaId: instancia.id);
  }

  Future<void> _generarRecuperatorio() async {
    if (_generandoRecuperatorio) return;
    setState(() => _generandoRecuperatorio = true);
    try {
      final nuevaInstanciaId = await Proveedores.agendaDocenteRepositorio
          .generarRecuperatorioEvaluacion(evaluacionId: widget.evaluacion.id);
      _huboCambios = true;
      await _cargar(mantenerInstanciaId: nuevaInstanciaId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Recuperatorio generado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Bad state: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _generandoRecuperatorio = false);
    }
  }

  int _contarEstadoFinal(String estado) {
    return _resultados
        .where((r) => _normalizarEstadoEvaluacion(r.condicionFinal) == estado)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados();
    final aprobados = _contarEstadoFinal('aprobado');
    final noAprobados = _contarEstadoFinal('no_aprobado');
    final pendientes = _contarEstadoFinal('pendiente');
    final ausentes = _contarEstadoFinal('ausente');
    final instancia = _instanciaActual;
    final cerrada = (instancia?.estado ?? '').trim().toLowerCase() == 'cerrada';
    final esUltimaInstancia =
        instancia != null &&
        _instancias.isNotEmpty &&
        instancia.id == _instancias.last.id;

    return AlertDialog(
      title: Text('Resultados - ${widget.evaluacion.titulo}'),
      content: SizedBox(
        width: _anchoDialogo(context, 980),
        height: _altoDialogo(context, 620),
        child: _cargando
            ? const EstadoListaCargando(mensaje: 'Cargando resultados...')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textoElidido(
                    '${widget.evaluacion.tipo} | ${widget.tituloCurso} | ${_fechaCorta(widget.evaluacion.fecha)}',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  _bloqueDescripcionFuncion(context, 'resultados'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('Final aprobados: $aprobados')),
                      Chip(label: Text('Final no aprobados: $noAprobados')),
                      Chip(label: Text('Final pendientes: $pendientes')),
                      Chip(label: Text('Final ausentes: $ausentes')),
                      Chip(
                        label: Text(cerrada ? 'Cerrada' : 'Abierta'),
                        backgroundColor: cerrada
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                      ),
                      OutlinedButton.icon(
                        onPressed: instancia == null
                            ? null
                            : _alternarEstadoInstancia,
                        icon: Icon(
                          cerrada
                              ? Icons.lock_open_outlined
                              : Icons.lock_outline,
                        ),
                        label: Text(
                          cerrada ? 'Reabrir instancia' : 'Cerrar instancia',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: cerrada && esUltimaInstancia
                            ? _generarRecuperatorio
                            : null,
                        icon: const Icon(Icons.restart_alt_outlined),
                        label: Text(
                          _generandoRecuperatorio
                              ? 'Generando...'
                              : 'Generar recuperatorio',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_instancias.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _instancias
                            .map(
                              (i) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  selected: _instanciaSeleccionadaId == i.id,
                                  label: Text(
                                    '${_labelInstanciaEvaluacion(i)}${i.cerrada ? ' (cerrada)' : ''}',
                                  ),
                                  onSelected: (_) =>
                                      _cargar(mantenerInstanciaId: i.id),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      initialValue: _filtroEstado,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por condicion final',
                      ),
                      items: [
                        _itemMenuElidido('todos', 'Todos'),
                        _itemMenuElidido('pendiente', 'Pendiente'),
                        _itemMenuElidido('aprobado', 'Aprobado'),
                        _itemMenuElidido('no_aprobado', 'No aprobado'),
                        _itemMenuElidido('ausente', 'Ausente'),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _filtroEstado = v);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtrados.isEmpty
                        ? const EstadoListaVacia(
                            titulo: 'No hay alumnos para ese filtro',
                            icono: Icons.assignment_late_outlined,
                          )
                        : ListView.separated(
                            itemCount: filtrados.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final r = filtrados[i];
                              final estado = _labelEstadoEvaluacion(r.estado);
                              final condicionFinal = _labelEstadoEvaluacion(
                                r.condicionFinal,
                              );
                              final nota = (r.calificacion ?? '').trim();
                              final notaVigente = (r.calificacionVigente ?? '')
                                  .trim();
                              final obs = (r.observacion ?? '').trim();
                              return ListTile(
                                dense: true,
                                title: Text(r.alumnoNombre),
                                subtitle: Text(
                                  'Instancia: $estado | Condicion final: $condicionFinal | Nota instancia: ${nota.isEmpty ? '-' : nota} | Nota vigente: ${notaVigente.isEmpty ? '-' : notaVigente} | Complementaria: ${r.entregaComplementaria ? 'Si' : 'No'}${r.ausenteJustificado ? ' | Ausente justificado' : ''}${obs.isEmpty ? '' : '\nObs: $obs'}',
                                ),
                                isThreeLine: obs.isNotEmpty,
                                trailing: IconButton(
                                  tooltip: 'Editar resultado',
                                  onPressed: () => _editarResultado(r),
                                  icon: const Icon(Icons.edit_outlined),
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
          onPressed: () => Navigator.pop(context, _huboCambios),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class _DialogEdicionResultado extends StatefulWidget {
  final int cursoId;
  final String? institucion;
  final String alumnoNombre;
  final ResultadoEvaluacionAlumno actual;

  const _DialogEdicionResultado({
    required this.cursoId,
    required this.institucion,
    required this.alumnoNombre,
    required this.actual,
  });

  @override
  State<_DialogEdicionResultado> createState() =>
      _DialogEdicionResultadoState();
}

class _DialogEdicionResultadoState extends State<_DialogEdicionResultado> {
  late final TextEditingController _notaCtrl;
  late final TextEditingController _obsCtrl;
  late String _estado;
  late bool _entregaComplementaria;
  late bool _ausenteJustificado;
  List<String> _observacionesEstandar = const [];

  static const List<String> _estados = [
    'pendiente',
    'aprobado',
    'en_proceso',
    'recuperacion',
    'ausente',
  ];
  static const List<(String, String)> _devolucionesRapidas = [
    (
      'Bajo rendimiento',
      'Bajo rendimiento sostenido. Se sugiere reforzar contenidos clave y seguimiento semanal.',
    ),
    (
      'Mejora reciente',
      'Se observa mejora reciente en continuidad y desempeno. Mantener la estrategia actual.',
    ),
    (
      'Recuperacion sugerida',
      'Se propone instancia de recuperacion con trabajo guiado y foco en contenidos pendientes.',
    ),
    (
      'Entrega incompleta',
      'Entrega incompleta. Falta desarrollar consignas centrales y justificar procedimientos.',
    ),
    (
      'Buen avance',
      'Buen avance general. Cumple consignas y sostiene participacion adecuada.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _notaCtrl = TextEditingController(text: widget.actual.calificacion ?? '');
    _obsCtrl = TextEditingController(text: widget.actual.observacion ?? '');
    _estado = _normalizarEstadoEvaluacion(widget.actual.estado);
    if (!_estados.contains(_estado)) _estado = 'pendiente';
    _entregaComplementaria = widget.actual.entregaComplementaria;
    _ausenteJustificado = widget.actual.ausenteJustificado;
    _cargarObservacionesEstandar();
  }

  @override
  void dispose() {
    _notaCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    Navigator.pop(
      context,
      _ResultadoEvaluacionEdicion(
        estado: _estado,
        calificacion: _notaCtrl.text.trim(),
        entregaComplementaria: _entregaComplementaria,
        ausenteJustificado: _ausenteJustificado,
        observacion: _obsCtrl.text.trim(),
      ),
    );
  }

  Future<void> _cargarObservacionesEstandar() async {
    final institucion = (widget.institucion ?? '').trim();
    if (institucion.isEmpty) return;
    final regla = await Proveedores.agendaDocenteRepositorio
        .obtenerReglaInstitucion(institucion);
    final texto = (regla.observacionesEstandar ?? '').trim();
    if (texto.isEmpty || !mounted) return;
    final lineas = texto
        .split(RegExp(r'[\r\n]+'))
        .map((x) => x.trim())
        .where((x) => x.isNotEmpty)
        .toList(growable: false);
    if (!mounted) return;
    setState(() => _observacionesEstandar = lineas);
  }

  void _aplicarDevolucionRapida(String texto) {
    final actual = _obsCtrl.text.trim();
    final combinado = actual.isEmpty ? texto : '$actual\n$texto';
    setState(() => _obsCtrl.text = combinado);
    _obsCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _obsCtrl.text.length),
    );
  }

  Future<void> _aplicarRubrica() async {
    final rubrica = await _mostrarSelectorRubricaSimple(
      context: context,
      cursoId: widget.cursoId,
      institucion: widget.institucion,
      titulo: 'Seleccionar rubrica para observacion',
    );
    if (rubrica == null) return;
    await Proveedores.agendaDocenteRepositorio.registrarUsoRubricaSimple(
      rubrica.id,
    );
    final texto = '[Rubrica: ${rubrica.titulo}] ${rubrica.criterios}'.trim();
    final actual = _obsCtrl.text.trim();
    final combinado = actual.isEmpty ? texto : '$actual\n$texto';
    setState(() => _obsCtrl.text = combinado);
    _obsCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _obsCtrl.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _textoElidido('Resultado - ${widget.alumnoNombre}', maxLines: 2),
      content: SizedBox(
        width: _anchoDialogo(context, 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _estado,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: _estados
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: _textoElidido(_labelEstadoEvaluacion(e)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _estado = v;
                  if (_estado != 'ausente') {
                    _ausenteJustificado = false;
                  }
                });
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notaCtrl,
              decoration: const InputDecoration(
                labelText: 'Calificacion (opcional)',
                hintText: 'Ej: 8, 6/10, Aprobado',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Si dejas estado Pendiente/En proceso y cargas calificacion, se ajusta automaticamente segun reglas institucionales.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _entregaComplementaria,
              onChanged: (v) => setState(() => _entregaComplementaria = v),
              contentPadding: EdgeInsets.zero,
              title: const Text('Entrega complementaria'),
            ),
            SwitchListTile(
              value: _ausenteJustificado,
              onChanged: _estado == 'ausente'
                  ? (v) => setState(() => _ausenteJustificado = v)
                  : null,
              contentPadding: EdgeInsets.zero,
              title: const Text('Ausente justificado'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _obsCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Observacion (opcional)',
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Devoluciones reutilizables',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _devolucionesRapidas
                  .map(
                    (d) => ActionChip(
                      label: Text(d.$1),
                      onPressed: () => _aplicarDevolucionRapida(d.$2),
                    ),
                  )
                  .toList(growable: false),
            ),
            if (_observacionesEstandar.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Observaciones institucionales',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _observacionesEstandar
                    .map(
                      (texto) => ActionChip(
                        label: Text(texto),
                        onPressed: () => _aplicarDevolucionRapida(texto),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _aplicarRubrica,
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Aplicar rubrica'),
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
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}
