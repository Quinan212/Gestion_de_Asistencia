part of 'agenda_docente_pantalla.dart';

Future<List<HorarioCursoEdicion>?> _mostrarDialogoHorarios(
  BuildContext context,
  String titulo,
  List<HorarioCurso> actuales,
) {
  final filas = actuales
      .map(
        (h) => _HorarioFila(
          diaSemana: h.diaSemana,
          horaInicio: h.horaInicio,
          horaFin: h.horaFin ?? '',
          aula: h.aula ?? '',
        ),
      )
      .toList();
  if (filas.isEmpty) {
    filas.add(_HorarioFila(diaSemana: DateTime.now().weekday));
  }

  String? error;

  return showDialog<List<HorarioCursoEdicion>>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setStateDialog) => AlertDialog(
        title: _tituloDialogoCurso('Horarios', titulo),
        content: SizedBox(
          width: _anchoDialogo(context, 760),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _bloqueDescripcionFuncion(context, 'horarios'),
                const SizedBox(height: 8),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ...filas.asMap().entries.map((entry) {
                  final i = entry.key;
                  final f = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 130,
                          child: DropdownButtonFormField<int>(
                            initialValue: f.diaSemana,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Dia'),
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('Lunes')),
                              DropdownMenuItem(value: 2, child: Text('Martes')),
                              DropdownMenuItem(
                                value: 3,
                                child: Text('Miercoles'),
                              ),
                              DropdownMenuItem(value: 4, child: Text('Jueves')),
                              DropdownMenuItem(
                                value: 5,
                                child: Text('Viernes'),
                              ),
                              DropdownMenuItem(value: 6, child: Text('Sabado')),
                              DropdownMenuItem(
                                value: 7,
                                child: Text('Domingo'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              f.diaSemana = v;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            initialValue: f.horaInicio,
                            decoration: const InputDecoration(
                              labelText: 'Inicio',
                            ),
                            onChanged: (v) => f.horaInicio = v,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            initialValue: f.horaFin,
                            decoration: const InputDecoration(labelText: 'Fin'),
                            onChanged: (v) => f.horaFin = v,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: f.aula,
                            decoration: const InputDecoration(
                              labelText: 'Aula',
                            ),
                            onChanged: (v) => f.aula = v,
                          ),
                        ),
                        IconButton(
                          onPressed: filas.length <= 1
                              ? null
                              : () => setStateDialog(() => filas.removeAt(i)),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => setStateDialog(
                      () => filas.add(_HorarioFila(diaSemana: 1)),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar bloque'),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final out = <HorarioCursoEdicion>[];
              for (final f in filas) {
                final inicio = f.horaInicio.trim();
                final fin = f.horaFin.trim();
                if (!_horaValida(inicio) ||
                    (fin.isNotEmpty && !_horaValida(fin))) {
                  setStateDialog(
                    () => error = 'Usa formato HH:mm para inicio y fin',
                  );
                  return;
                }
                out.add(
                  HorarioCursoEdicion(
                    diaSemana: f.diaSemana,
                    horaInicio: inicio,
                    horaFin: fin.isEmpty ? null : fin,
                    aula: f.aula.trim().isEmpty ? null : f.aula.trim(),
                  ),
                );
              }
              Navigator.pop(context, out);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    ),
  );
}

Future<bool?> _mostrarDialogoIntervenciones(
  BuildContext context,
  int cursoId,
  String titulo,
  String institucion,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) => _DialogIntervenciones(
      cursoId: cursoId,
      titulo: titulo,
      institucion: institucion,
    ),
  );
}

class _DialogIntervenciones extends StatefulWidget {
  final int cursoId;
  final String titulo;
  final String institucion;

  const _DialogIntervenciones({
    required this.cursoId,
    required this.titulo,
    required this.institucion,
  });

  @override
  State<_DialogIntervenciones> createState() => _DialogIntervencionesState();
}

class _DialogIntervencionesState extends State<_DialogIntervenciones> {
  final TextEditingController _descripcionCtrl = TextEditingController();
  final TextEditingController _seguimientoCtrl = TextEditingController();
  final TextEditingController _busquedaCtrl = TextEditingController();

  bool _cargando = true;
  bool _guardando = false;
  bool _huboCambios = false;
  String _tipo = 'Seguimiento';
  String _filtroTipoLista = 'todos';
  String _filtroEstadoLista = 'todos';
  int? _filtroAlumnoListaId;
  int? _alumnoId;
  List<Alumno> _alumnos = const [];
  List<IntervencionDocente> _intervenciones = const [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    _seguimientoCtrl.dispose();
    _busquedaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final res = await Future.wait<dynamic>([
      Proveedores.asistenciasRepositorio.listarAlumnosDeCurso(widget.cursoId),
      Proveedores.agendaDocenteRepositorio.listarIntervencionesCurso(
        widget.cursoId,
      ),
    ]);
    if (!mounted) return;
    setState(() {
      _alumnos = res[0] as List<Alumno>;
      _intervenciones = res[1] as List<IntervencionDocente>;
      _cargando = false;
    });
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    final descripcion = _descripcionCtrl.text.trim();
    if (descripcion.isEmpty) return;

    setState(() => _guardando = true);
    await Proveedores.agendaDocenteRepositorio.registrarIntervencion(
      cursoId: widget.cursoId,
      alumnoId: _alumnoId,
      tipo: _tipo,
      descripcion: descripcion,
      seguimiento: _seguimientoCtrl.text,
    );
    _huboCambios = true;
    _descripcionCtrl.clear();
    _seguimientoCtrl.clear();
    await _cargar();
    if (mounted) setState(() => _guardando = false);
  }

  Future<void> _cambiarEstado(IntervencionDocente i, bool valor) async {
    await Proveedores.agendaDocenteRepositorio.actualizarEstadoIntervencion(
      intervencionId: i.id,
      resuelta: valor,
    );
    _huboCambios = true;
    await _cargar();
  }

  Future<void> _aplicarPlantilla() async {
    final plantilla = await _mostrarSelectorPlantillaDocente(
      context: context,
      cursoId: widget.cursoId,
      institucion: widget.institucion,
      tipoInicial: 'mensaje_base',
      titulo: 'Seleccionar plantilla para intervencion',
    );
    if (plantilla == null) return;

    await Proveedores.agendaDocenteRepositorio.registrarUsoPlantillaDocente(
      plantilla.id,
    );
    final descripcionActual = _descripcionCtrl.text.trim();
    if (descripcionActual.isEmpty) {
      _descripcionCtrl.text = plantilla.contenido.trim();
    } else {
      final seg = _seguimientoCtrl.text.trim();
      _seguimientoCtrl.text = seg.isEmpty
          ? plantilla.contenido.trim()
          : '$seg\n${plantilla.contenido.trim()}';
    }
    _huboCambios = true;
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Plantilla aplicada')));
    await _cargar();
  }

  List<String> _tiposDisponibles() {
    final out = _intervenciones.map((i) => i.tipo.trim()).toSet().toList();
    out.removeWhere((x) => x.isEmpty);
    out.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return out;
  }

  List<IntervencionDocente> _filtradas() {
    final q = _busquedaCtrl.text.trim().toLowerCase();
    return _intervenciones
        .where((i) {
          if (_filtroTipoLista != 'todos' &&
              i.tipo.trim() != _filtroTipoLista) {
            return false;
          }
          if (_filtroEstadoLista == 'abiertas' && i.resuelta) return false;
          if (_filtroEstadoLista == 'resueltas' && !i.resuelta) return false;
          if (_filtroAlumnoListaId != null &&
              i.alumnoId != _filtroAlumnoListaId) {
            return false;
          }
          if (q.isNotEmpty) {
            final texto = [
              i.tipo,
              i.alumnoNombre ?? '',
              i.descripcion,
              i.seguimiento ?? '',
            ].join(' ').toLowerCase();
            if (!texto.contains(q)) return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final tipos = _tiposDisponibles();
    final filtradas = _filtradas();
    return AlertDialog(
      title: _tituloDialogoCurso('Intervenciones', widget.titulo),
      content: SizedBox(
        width: _anchoDialogo(context, 820),
        height: _altoDialogo(context, 560),
        child: _cargando
            ? const EstadoListaCargando(mensaje: 'Cargando...')
            : Column(
                children: [
                  _bloqueDescripcionFuncion(context, 'intervenciones'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: 180,
                        child: DropdownButtonFormField<String>(
                          initialValue: _tipo,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Tipo'),
                          items: const [
                            DropdownMenuItem(
                              value: 'Seguimiento',
                              child: Text('Seguimiento'),
                            ),
                            DropdownMenuItem(
                              value: 'Llamada a familia',
                              child: Text('Llamada a familia'),
                            ),
                            DropdownMenuItem(
                              value: 'Aviso institucional',
                              child: Text('Aviso institucional'),
                            ),
                            DropdownMenuItem(
                              value: 'Recomendacion pedagogica',
                              child: Text('Recomendacion pedagogica'),
                            ),
                            DropdownMenuItem(
                              value: 'Recuperacion propuesta',
                              child: Text('Recuperacion propuesta'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _tipo = v);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: DropdownButtonFormField<int?>(
                          initialValue: _alumnoId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Alumno (opcional)',
                          ),
                          items: [
                            _itemMenuElidido<int?>(null, 'General del curso'),
                            ..._alumnos.map(
                              (a) => DropdownMenuItem<int?>(
                                value: a.id,
                                child: _textoElidido(a.nombreCompleto),
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => _alumnoId = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: 190,
                        child: DropdownButtonFormField<String>(
                          initialValue: _filtroTipoLista,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Filtro tipo',
                          ),
                          items: [
                            _itemMenuElidido('todos', 'Todos'),
                            ...tipos.map((t) => _itemMenuElidido(t, t)),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _filtroTipoLista = v);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 170,
                        child: DropdownButtonFormField<String>(
                          initialValue: _filtroEstadoLista,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Filtro estado',
                          ),
                          items: [
                            _itemMenuElidido('todos', 'Todos'),
                            _itemMenuElidido('abiertas', 'Abiertas'),
                            _itemMenuElidido('resueltas', 'Resueltas'),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _filtroEstadoLista = v);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: DropdownButtonFormField<int?>(
                          initialValue: _filtroAlumnoListaId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Filtro alumno',
                          ),
                          items: [
                            _itemMenuElidido<int?>(null, 'Todos'),
                            ..._alumnos.map(
                              (a) => DropdownMenuItem<int?>(
                                value: a.id,
                                child: _textoElidido(a.nombreCompleto),
                              ),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _filtroAlumnoListaId = v),
                        ),
                      ),
                      SizedBox(
                        width: 170,
                        child: TextField(
                          controller: _busquedaCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Buscar',
                            hintText: 'Texto...',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: _aplicarPlantilla,
                      icon: const Icon(Icons.text_snippet_outlined),
                      label: const Text('Usar plantilla'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descripcionCtrl,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Descripcion'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _seguimientoCtrl,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Seguimiento (opcional)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _guardando ? null : _guardar,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(_guardando ? 'Guardando...' : 'Registrar'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: filtradas.isEmpty
                        ? const EstadoListaVacia(
                            titulo: 'No hay intervenciones para ese filtro',
                            icono: Icons.note_alt_outlined,
                          )
                        : ListView.builder(
                            itemCount: filtradas.length,
                            itemBuilder: (_, idx) {
                              final i = filtradas[idx];
                              return CheckboxListTile(
                                value: i.resuelta,
                                onChanged: (v) {
                                  if (v == null) return;
                                  _cambiarEstado(i, v);
                                },
                                title: Text(
                                  '${i.tipo} - ${_fechaHora(i.fecha)}',
                                ),
                                subtitle: Text(
                                  '${i.alumnoNombre ?? 'Curso general'}\n${i.descripcion}${(i.seguimiento ?? '').trim().isEmpty ? '' : '\nSeguimiento: ${i.seguimiento}'}',
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

class _DialogHistorialAlumnos extends StatefulWidget {
  final int cursoId;
  final String tituloCurso;
  final DateTime fechaReferencia;

  const _DialogHistorialAlumnos({
    required this.cursoId,
    required this.tituloCurso,
    required this.fechaReferencia,
  });

  @override
  State<_DialogHistorialAlumnos> createState() =>
      _DialogHistorialAlumnosState();
}

class _DialogHistorialAlumnosState extends State<_DialogHistorialAlumnos> {
  bool _cargando = true;
  List<HistorialAlumnoInteligente> _historial = const [];
  String _filtroRiesgo = 'todos';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final historial = await Proveedores.agendaDocenteRepositorio
        .listarHistorialInteligenteCurso(widget.cursoId);
    if (!mounted) return;
    setState(() {
      _historial = historial;
      _cargando = false;
    });
  }

  List<HistorialAlumnoInteligente> _filtrados() {
    if (_filtroRiesgo == 'todos') return _historial;
    return _historial
        .where((h) => h.nivelRiesgo.toLowerCase() == _filtroRiesgo)
        .toList(growable: false);
  }

  int _totalConRiesgo(String riesgo) {
    return _historial
        .where((h) => h.nivelRiesgo.toLowerCase() == riesgo.toLowerCase())
        .length;
  }

  Color _colorRiesgo(BuildContext context, String riesgo) {
    final normal = riesgo.trim().toLowerCase();
    if (normal == 'alto') return Colors.red.shade700;
    if (normal == 'medio') return Colors.orange.shade700;
    return Theme.of(context).colorScheme.primary;
  }

  Future<void> _abrirCronologia(HistorialAlumnoInteligente h) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _DialogCronologiaAlumno(
        cursoId: widget.cursoId,
        alumnoId: h.alumnoId,
        alumnoNombre: h.alumnoNombre,
        tituloCurso: widget.tituloCurso,
      ),
    );
  }

  Future<void> _abrirSintesisAlumno(HistorialAlumnoInteligente h) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _DialogSintesisPeriodoAlumno(
        cursoId: widget.cursoId,
        alumnoId: h.alumnoId,
        alumnoNombre: h.alumnoNombre,
        cursoEtiqueta: widget.tituloCurso,
        fechaReferencia: widget.fechaReferencia,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados();
    return AlertDialog(
      title: _tituloDialogoCurso('Historial inteligente', widget.tituloCurso),
      content: SizedBox(
        width: _anchoDialogo(context, 920),
        height: _altoDialogo(context, 620),
        child: _cargando
            ? const EstadoListaCargando(mensaje: 'Cargando historial...')
            : Column(
                children: [
                  _bloqueDescripcionFuncion(context, 'historial'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        child: DropdownButtonFormField<String>(
                          initialValue: _filtroRiesgo,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Filtro de riesgo',
                          ),
                          items: [
                            _itemMenuElidido('todos', 'Todos'),
                            _itemMenuElidido('alto', 'Alto'),
                            _itemMenuElidido('medio', 'Medio'),
                            _itemMenuElidido('bajo', 'Bajo'),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _filtroRiesgo = v);
                          },
                        ),
                      ),
                      Chip(
                        label: Text('Alto: ${_totalConRiesgo('alto')}'),
                        backgroundColor: Colors.red.shade50,
                      ),
                      Chip(
                        label: Text('Medio: ${_totalConRiesgo('medio')}'),
                        backgroundColor: Colors.orange.shade50,
                      ),
                      Chip(
                        label: Text('Bajo: ${_totalConRiesgo('bajo')}'),
                        backgroundColor: Colors.blue.shade50,
                      ),
                      IconButton(
                        tooltip: 'Recargar',
                        onPressed: _cargar,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtrados.isEmpty
                        ? const EstadoListaVacia(
                            titulo: 'No hay alumnos para mostrar',
                            icono: Icons.person_off_outlined,
                          )
                        : ListView.separated(
                            itemCount: filtrados.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final h = filtrados[i];
                              final color = _colorRiesgo(
                                context,
                                h.nivelRiesgo,
                              );
                              return ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: color.withValues(
                                    alpha: 0.15,
                                  ),
                                  child: Text(
                                    h.nivelRiesgo.substring(0, 1).toUpperCase(),
                                    style: TextStyle(color: color),
                                  ),
                                ),
                                title: Text(h.alumnoNombre),
                                subtitle: Text(
                                  '${h.resumen}\nFaltas: ${h.faltas} | Inasistencias seguidas: ${h.inasistenciasConsecutivas} | Sin entregar: ${h.actividadesSinEntregar} | Eval pendientes: ${h.evaluacionesPendientes}',
                                ),
                                isThreeLine: true,
                                onTap: () => _abrirCronologia(h),
                                trailing: SizedBox(
                                  width: 92,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        h.nivelRiesgo.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            tooltip: 'Sintesis de periodo',
                                            constraints: const BoxConstraints(
                                              minWidth: 28,
                                              minHeight: 28,
                                            ),
                                            padding: EdgeInsets.zero,
                                            visualDensity:
                                                VisualDensity.compact,
                                            icon: const Icon(
                                              Icons.summarize_outlined,
                                              size: 18,
                                            ),
                                            onPressed: () =>
                                                _abrirSintesisAlumno(h),
                                          ),
                                          IconButton(
                                            tooltip: 'Ver cronologia',
                                            constraints: const BoxConstraints(
                                              minWidth: 28,
                                              minHeight: 28,
                                            ),
                                            padding: EdgeInsets.zero,
                                            visualDensity:
                                                VisualDensity.compact,
                                            icon: const Icon(
                                              Icons.timeline_outlined,
                                              size: 18,
                                            ),
                                            onPressed: () =>
                                                _abrirCronologia(h),
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
