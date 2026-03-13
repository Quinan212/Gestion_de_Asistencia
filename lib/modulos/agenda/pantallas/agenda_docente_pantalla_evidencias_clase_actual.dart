part of 'agenda_docente_pantalla.dart';

class _DialogEvidenciasCurso extends StatefulWidget {
  final int cursoId;
  final String institucion;
  final String tituloCurso;
  final DateTime fechaReferencia;

  const _DialogEvidenciasCurso({
    required this.cursoId,
    required this.institucion,
    required this.tituloCurso,
    required this.fechaReferencia,
  });

  @override
  State<_DialogEvidenciasCurso> createState() => _DialogEvidenciasCursoState();
}

class _DialogEvidenciasCursoState extends State<_DialogEvidenciasCurso> {
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  bool _cargando = true;
  bool _guardando = false;
  bool _huboCambios = false;
  DateTime _fecha = _soloFecha(DateTime.now());
  String _tipo = 'observacion';
  int? _claseId;
  int? _alumnoId;
  int? _evaluacionId;
  int? _evaluacionInstanciaId;
  String? _archivoPath;

  List<ClaseAsistencia> _clases = const [];
  List<Alumno> _alumnos = const [];
  List<EvaluacionCurso> _evaluaciones = const [];
  List<EvaluacionInstancia> _instanciasEvaluacion = const [];
  List<EvidenciaDocente> _evidencias = const [];

  static const List<String> _tipos = [
    'observacion',
    'foto',
    'rubrica',
    'archivo',
  ];

  @override
  void initState() {
    super.initState();
    _fecha = _soloFecha(widget.fechaReferencia);
    _cargar();
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final res = await Future.wait<dynamic>([
      Proveedores.agendaDocenteRepositorio.listarEvidenciasCurso(
        widget.cursoId,
        limite: 120,
      ),
      Proveedores.asistenciasRepositorio.listarClasesDeCurso(
        widget.cursoId,
        limite: 100,
      ),
      Proveedores.asistenciasRepositorio.listarAlumnosDeCurso(widget.cursoId),
      Proveedores.agendaDocenteRepositorio.listarEvaluacionesCurso(
        widget.cursoId,
        limite: 120,
      ),
    ]);
    final evaluaciones = res[3] as List<EvaluacionCurso>;
    int? evaluacionId = _evaluacionId;
    if (evaluacionId != null &&
        !evaluaciones.any((e) => e.id == evaluacionId)) {
      evaluacionId = null;
    }
    var instancias = const <EvaluacionInstancia>[];
    if (evaluacionId != null) {
      instancias = await Proveedores.agendaDocenteRepositorio
          .listarInstanciasEvaluacion(evaluacionId);
    }
    int? evaluacionInstanciaId = _evaluacionInstanciaId;
    if (evaluacionInstanciaId != null &&
        !instancias.any((i) => i.id == evaluacionInstanciaId)) {
      evaluacionInstanciaId = null;
    }
    if (!mounted) return;
    setState(() {
      _evidencias = res[0] as List<EvidenciaDocente>;
      _clases = res[1] as List<ClaseAsistencia>;
      _alumnos = res[2] as List<Alumno>;
      _evaluaciones = evaluaciones;
      _evaluacionId = evaluacionId;
      _instanciasEvaluacion = instancias;
      _evaluacionInstanciaId = evaluacionInstanciaId;
      _cargando = false;
    });
  }

  Future<void> _cargarInstanciasEvaluacion(int? evaluacionId) async {
    if (evaluacionId == null) {
      if (!mounted) return;
      setState(() {
        _evaluacionId = null;
        _evaluacionInstanciaId = null;
        _instanciasEvaluacion = const [];
      });
      return;
    }
    setState(() {
      _evaluacionId = evaluacionId;
      _evaluacionInstanciaId = null;
      _instanciasEvaluacion = const [];
    });
    final instancias = await Proveedores.agendaDocenteRepositorio
        .listarInstanciasEvaluacion(evaluacionId);
    if (!mounted || _evaluacionId != evaluacionId) return;
    setState(() => _instanciasEvaluacion = instancias);
  }

  Future<void> _seleccionarFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (elegida == null) return;
    setState(() => _fecha = _soloFecha(elegida));
  }

  Future<void> _adjuntarArchivo() async {
    final xFile = await openFile();
    if (xFile == null) return;
    try {
      final docs = await getApplicationDocumentsDirectory();
      final carpeta = Directory(p.join(docs.path, 'evidencias_docentes'));
      if (!await carpeta.exists()) {
        await carpeta.create(recursive: true);
      }
      final ext = p.extension(xFile.path);
      final nombre =
          'ev_${widget.cursoId}_${DateTime.now().millisecondsSinceEpoch}${ext.isEmpty ? '.dat' : ext}';
      final destino = p.join(carpeta.path, nombre);
      await File(xFile.path).copy(destino);
      if (!mounted) return;
      setState(() => _archivoPath = destino);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo adjuntar el archivo')),
      );
    }
  }

  Future<void> _quitarAdjunto() async {
    setState(() => _archivoPath = null);
  }

  Future<void> _guardarEvidencia() async {
    if (_guardando) return;
    final titulo = _tituloCtrl.text.trim();
    if (titulo.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('El titulo es obligatorio')));
      return;
    }
    setState(() => _guardando = true);
    try {
      await Proveedores.agendaDocenteRepositorio.registrarEvidencia(
        cursoId: widget.cursoId,
        claseId: _claseId,
        alumnoId: _alumnoId,
        evaluacionId: _evaluacionId,
        evaluacionInstanciaId: _evaluacionInstanciaId,
        fecha: _fecha,
        tipo: _tipo,
        titulo: titulo,
        descripcion: _descripcionCtrl.text,
        archivoPath: _archivoPath,
      );
      _huboCambios = true;
      _tituloCtrl.clear();
      _descripcionCtrl.clear();
      _archivoPath = null;
      _alumnoId = null;
      _claseId = null;
      _evaluacionId = null;
      _evaluacionInstanciaId = null;
      _fecha = _soloFecha(widget.fechaReferencia);
      await _cargar();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Evidencia registrada')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar evidencia: $e')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _aplicarPlantilla() async {
    final plantilla = await _mostrarSelectorPlantillaDocente(
      context: context,
      cursoId: widget.cursoId,
      institucion: widget.institucion,
      tipoInicial: 'observacion_tipo',
      titulo: 'Seleccionar plantilla para evidencia',
    );
    if (plantilla == null) return;
    await Proveedores.agendaDocenteRepositorio.registrarUsoPlantillaDocente(
      plantilla.id,
    );
    if (_tituloCtrl.text.trim().isEmpty) {
      _tituloCtrl.text = plantilla.titulo.trim();
    }
    final desc = _descripcionCtrl.text.trim();
    _descripcionCtrl.text = desc.isEmpty
        ? plantilla.contenido.trim()
        : '$desc\n${plantilla.contenido.trim()}';
    _huboCambios = true;
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Plantilla aplicada')));
    await _cargar();
  }

  Future<void> _aplicarRubrica() async {
    final rubrica = await _mostrarSelectorRubricaSimple(
      context: context,
      cursoId: widget.cursoId,
      institucion: widget.institucion,
      titulo: 'Seleccionar rubrica para evidencia',
    );
    if (rubrica == null) return;
    await Proveedores.agendaDocenteRepositorio.registrarUsoRubricaSimple(
      rubrica.id,
    );
    if (_tituloCtrl.text.trim().isEmpty) {
      _tituloCtrl.text = rubrica.titulo.trim();
    }
    final texto = rubrica.criterios.trim();
    if (texto.isNotEmpty) {
      final desc = _descripcionCtrl.text.trim();
      _descripcionCtrl.text = desc.isEmpty ? texto : '$desc\n$texto';
    }
    setState(() => _tipo = 'rubrica');
    _huboCambios = true;
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Rubrica aplicada')));
    await _cargar();
  }

  Future<void> _eliminarEvidencia(EvidenciaDocente evidencia) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar evidencia'),
        content: Text('Se eliminara "${evidencia.titulo}".'),
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

    await Proveedores.agendaDocenteRepositorio.eliminarEvidencia(evidencia.id);
    final path = (evidencia.archivoPath ?? '').trim();
    if (path.isNotEmpty) {
      final f = File(path);
      if (await f.exists()) {
        await f.delete();
      }
    }
    _huboCambios = true;
    await _cargar();
  }

  String _nombreClase(int? claseId) {
    if (claseId == null) return 'Sin clase';
    for (final c in _clases) {
      if (c.id == claseId) {
        final tema = (c.tema ?? '').trim();
        if (tema.isEmpty) return _fechaCorta(c.fecha);
        return '${_fechaCorta(c.fecha)} - $tema';
      }
    }
    return 'Clase #$claseId';
  }

  String _labelTipo(String tipo) {
    switch (tipo.trim().toLowerCase()) {
      case 'foto':
        return 'Foto';
      case 'rubrica':
        return 'Rubrica';
      case 'archivo':
        return 'Archivo';
      case 'observacion':
      default:
        return 'Observacion';
    }
  }

  String _labelEvaluacion(EvaluacionCurso e) {
    return '${_fechaCorta(e.fecha)} - ${e.tipo} - ${e.titulo}';
  }

  String _labelInstancia(EvaluacionInstancia i) {
    return _labelInstanciaEvaluacion(i);
  }

  String _descripcionVinculoEvaluacion(EvidenciaDocente e) {
    final titulo = (e.evaluacionTitulo ?? '').trim();
    if (titulo.isEmpty && e.evaluacionId == null) return '';
    final instancia = (e.evaluacionTipoInstancia ?? '').trim();
    final instanciaLabel = instancia.isEmpty ? 'original' : instancia;
    if (titulo.isNotEmpty) {
      return '\nEvaluacion: $titulo ($instanciaLabel)';
    }
    return '\nEvaluacion #${e.evaluacionId} ($instanciaLabel)';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _tituloDialogoCurso('Evidencias', widget.tituloCurso),
      content: SizedBox(
        width: _anchoDialogo(context, 920),
        height: _altoDialogo(context, 660),
        child: _cargando
            ? const EstadoListaCargando(mensaje: 'Cargando evidencias...')
            : Column(
                children: [
                  _bloqueDescripcionFuncion(context, 'evidencias'),
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
                          items: _tipos
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: _textoElidido(_labelTipo(t)),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _tipo = v);
                          },
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _seleccionarFecha,
                        icon: const Icon(Icons.event_outlined),
                        label: Text('Fecha: ${_fechaCorta(_fecha)}'),
                      ),
                      SizedBox(
                        width: 260,
                        child: DropdownButtonFormField<int?>(
                          initialValue: _claseId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Clase (opcional)',
                          ),
                          items: [
                            _itemMenuElidido<int?>(null, 'Sin clase puntual'),
                            ..._clases.map(
                              (c) => DropdownMenuItem<int?>(
                                value: c.id,
                                child: _textoElidido(_nombreClase(c.id)),
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => _claseId = v),
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
                      SizedBox(
                        width: 320,
                        child: DropdownButtonFormField<int?>(
                          initialValue: _evaluacionId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Evaluacion (opcional)',
                          ),
                          items: [
                            _itemMenuElidido<int?>(null, 'Sin evaluacion'),
                            ..._evaluaciones.map(
                              (e) => DropdownMenuItem<int?>(
                                value: e.id,
                                child: _textoElidido(_labelEvaluacion(e)),
                              ),
                            ),
                          ],
                          onChanged: (v) => _cargarInstanciasEvaluacion(v),
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: DropdownButtonFormField<int?>(
                          initialValue: _evaluacionInstanciaId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Instancia (opcional)',
                          ),
                          items: [
                            _itemMenuElidido<int?>(null, 'Instancia general'),
                            ..._instanciasEvaluacion.map(
                              (i) => DropdownMenuItem<int?>(
                                value: i.id,
                                child: _textoElidido(_labelInstancia(i)),
                              ),
                            ),
                          ],
                          onChanged: _evaluacionId == null
                              ? null
                              : (v) =>
                                    setState(() => _evaluacionInstanciaId = v),
                        ),
                      ),
                    ],
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
                      labelText: 'Descripcion (opcional)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _aplicarPlantilla,
                        icon: const Icon(Icons.text_snippet_outlined),
                        label: const Text('Usar plantilla'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _aplicarRubrica,
                        icon: const Icon(Icons.fact_check_outlined),
                        label: const Text('Usar rubrica'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _adjuntarArchivo,
                        icon: const Icon(Icons.attach_file_outlined),
                        label: const Text('Adjuntar archivo'),
                      ),
                      const SizedBox(width: 8),
                      if ((_archivoPath ?? '').trim().isNotEmpty)
                        SizedBox(
                          width: 220,
                          child: Text(
                            p.basename(_archivoPath!),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if ((_archivoPath ?? '').trim().isNotEmpty)
                        IconButton(
                          onPressed: _quitarAdjunto,
                          icon: const Icon(Icons.close_outlined),
                        ),
                      FilledButton.icon(
                        onPressed: _guardando ? null : _guardarEvidencia,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(
                          _guardando ? 'Guardando...' : 'Registrar evidencia',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _evidencias.isEmpty
                        ? const EstadoListaVacia(
                            titulo: 'No hay evidencias registradas',
                            icono: Icons.attach_file_outlined,
                          )
                        : ListView.separated(
                            itemCount: _evidencias.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final e = _evidencias[i];
                              final contextoAlumno = (e.alumnoNombre ?? '')
                                  .trim();
                              final contextoClase = _nombreClase(e.claseId);
                              final file = (e.archivoPath ?? '').trim();
                              final contextoEval =
                                  _descripcionVinculoEvaluacion(e);
                              return ListTile(
                                dense: true,
                                title: Text(
                                  '[${_labelTipo(e.tipo)}] ${e.titulo}',
                                ),
                                subtitle: Text(
                                  '${_fechaCorta(e.fecha)} | ${contextoAlumno.isEmpty ? 'Curso general' : contextoAlumno} | $contextoClase$contextoEval${file.isEmpty ? '' : '\nAdjunto: ${p.basename(file)}'}',
                                ),
                                isThreeLine:
                                    file.isNotEmpty || contextoEval.isNotEmpty,
                                trailing: IconButton(
                                  tooltip: 'Eliminar',
                                  onPressed: () => _eliminarEvidencia(e),
                                  icon: const Icon(Icons.delete_outline),
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

class _DialogClaseActualRapida extends StatefulWidget {
  final int cursoId;
  final String tituloCurso;
  final DateTime fecha;

  const _DialogClaseActualRapida({
    required this.cursoId,
    required this.tituloCurso,
    required this.fecha,
  });

  @override
  State<_DialogClaseActualRapida> createState() =>
      _DialogClaseActualRapidaState();
}

class _DialogClaseActualRapidaState extends State<_DialogClaseActualRapida> {
  final _temaCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  final _actividadCtrl = TextEditingController();
  String _estadoContenido = 'parcial';
  String _resultadoActividad = 'regular';

  bool _cargando = true;
  bool _guardando = false;
  bool _huboCambios = false;
  int? _claseId;
  List<ClaseAsistencia> _clases = const [];
  List<RegistroAsistenciaAlumno> _planilla = const [];

  static const List<String> _estadosContenido = [
    'completado',
    'parcial',
    'reprogramado',
  ];
  static const List<String> _resultadosActividad = ['bien', 'regular', 'mal'];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _temaCtrl.dispose();
    _obsCtrl.dispose();
    _actividadCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final clases = await Proveedores.asistenciasRepositorio.listarClasesDeCurso(
      widget.cursoId,
      limite: 120,
    );
    int? claseId = _claseId;
    claseId ??= _buscarClaseDelDia(clases);
    if (claseId != null && !clases.any((c) => c.id == claseId)) {
      claseId = _buscarClaseDelDia(clases);
    }

    List<RegistroAsistenciaAlumno> planilla = const [];
    if (claseId != null) {
      planilla = await Proveedores.asistenciasRepositorio.cargarPlanillaClase(
        cursoId: widget.cursoId,
        claseId: claseId,
      );
    }
    if (!mounted) return;
    setState(() {
      _clases = clases;
      _claseId = claseId;
      _planilla = planilla;
      _cargando = false;
    });
    _sincronizarDetalleClase();
  }

  int? _buscarClaseDelDia(List<ClaseAsistencia> clases) {
    for (final c in clases) {
      if (_esMismoDia(c.fecha, widget.fecha)) return c.id;
    }
    return null;
  }

  ClaseAsistencia? _claseActual() {
    final id = _claseId;
    if (id == null) return null;
    for (final c in _clases) {
      if (c.id == id) return c;
    }
    return null;
  }

  void _sincronizarDetalleClase() {
    final clase = _claseActual();
    final nuevoEstado = _normalizarEstadoContenido(clase?.estadoContenido);
    final nuevoResultado = _normalizarResultadoActividad(
      clase?.resultadoActividad,
    );
    if (clase == null) {
      _temaCtrl.text = '';
      _obsCtrl.text = '';
      _actividadCtrl.text = '';
      if (_estadoContenido != nuevoEstado ||
          _resultadoActividad != nuevoResultado) {
        setState(() {
          _estadoContenido = nuevoEstado;
          _resultadoActividad = nuevoResultado;
        });
      }
      return;
    }
    _temaCtrl.text = clase.tema ?? '';
    _obsCtrl.text = clase.observacion ?? '';
    _actividadCtrl.text = clase.actividadDia ?? '';
    if (_estadoContenido != nuevoEstado ||
        _resultadoActividad != nuevoResultado) {
      setState(() {
        _estadoContenido = nuevoEstado;
        _resultadoActividad = nuevoResultado;
      });
    }
  }

  Future<int?> _asegurarClase() async {
    if (_claseId != null) return _claseId;
    final inscriptos = await Proveedores.cursosRepositorio
        .contarInscritosActivos(widget.cursoId);
    if (inscriptos <= 0) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El curso no tiene alumnos inscriptos')),
      );
      return null;
    }

    final nuevaClaseId = await Proveedores.asistenciasRepositorio.crearClase(
      cursoId: widget.cursoId,
      fecha: _soloFecha(widget.fecha),
      tema: _temaCtrl.text,
      observacion: _obsCtrl.text,
      actividadDia: _actividadCtrl.text,
      estadoContenido: _estadoContenido,
      resultadoActividad: _resultadoActividad,
    );
    await Proveedores.asistenciasRepositorio.marcarEstadoParaTodos(
      claseId: nuevaClaseId,
      cursoId: widget.cursoId,
      estado: EstadoAsistencia.pendiente,
    );
    _huboCambios = true;
    return nuevaClaseId;
  }

  Future<void> _guardarDetalleClase() async {
    if (_guardando) return;
    setState(() => _guardando = true);
    try {
      final claseId = await _asegurarClase();
      if (claseId == null) return;

      await Proveedores.asistenciasRepositorio.actualizarDetalleClase(
        claseId: claseId,
        tema: _temaCtrl.text,
        descripcionTema: _obsCtrl.text,
        actividadDia: _actividadCtrl.text,
        estadoContenido: _estadoContenido,
        resultadoActividad: _resultadoActividad,
      );
      _huboCambios = true;
      await _cargar();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Clase actual guardada')));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _marcarTodos(EstadoAsistencia estado) async {
    if (_guardando) return;
    setState(() => _guardando = true);
    try {
      final claseId = await _asegurarClase();
      if (claseId == null) return;
      await Proveedores.asistenciasRepositorio.marcarEstadoParaTodos(
        claseId: claseId,
        cursoId: widget.cursoId,
        estado: estado,
      );
      _huboCambios = true;
      await _cargar();
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _cambiarEstadoAlumno(
    RegistroAsistenciaAlumno r,
    EstadoAsistencia estado,
  ) async {
    if (_guardando) return;
    final claseId = await _asegurarClase();
    if (claseId == null) return;

    final idx = _planilla.indexWhere((x) => x.alumno.id == r.alumno.id);
    if (idx >= 0) {
      setState(() {
        _planilla = List<RegistroAsistenciaAlumno>.from(_planilla)
          ..[idx] = _planilla[idx].copyWith(estado: estado);
      });
    }
    try {
      await Proveedores.asistenciasRepositorio.registrarEstadoAsistencia(
        claseId: claseId,
        alumnoId: r.alumno.id,
        estado: estado,
      );
      _huboCambios = true;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar asistencia')),
      );
      await _cargar();
    }
  }

  int _contar(EstadoAsistencia e) {
    return _planilla.where((r) => r.estado == e).length;
  }

  String _normalizarEstadoContenido(String? valor) {
    final v = (valor ?? '').trim().toLowerCase();
    if (_estadosContenido.contains(v)) return v;
    return 'parcial';
  }

  String _normalizarResultadoActividad(String? valor) {
    final v = (valor ?? '').trim().toLowerCase();
    if (_resultadosActividad.contains(v)) return v;
    return 'regular';
  }

  String _labelEstadoContenido(String estado) {
    switch (estado) {
      case 'completado':
        return 'Completado';
      case 'reprogramado':
        return 'Reprogramado';
      case 'parcial':
      default:
        return 'Parcial';
    }
  }

  String _labelResultadoActividad(String valor) {
    switch (valor) {
      case 'bien':
        return 'Bien';
      case 'mal':
        return 'Mal';
      case 'regular':
      default:
        return 'Regular';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _tituloDialogoCurso('Clase actual', widget.tituloCurso),
      content: SizedBox(
        width: _anchoDialogo(context, 960),
        height: _altoDialogo(context, 680),
        child: _cargando
            ? const EstadoListaCargando(mensaje: 'Cargando clase...')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bloqueDescripcionFuncion(context, 'clase_actual'),
                  const SizedBox(height: 8),
                  Text('Fecha: ${_fechaLarga(widget.fecha)}'),
                  const SizedBox(height: 8),
                  if (_claseId == null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: const Text(
                        'No hay clase cargada para este dia. Completa tema/actividad y guarda para crearla.',
                      ),
                    ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _temaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tema',
                      hintText: 'Ej: Lectura comprensiva',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _obsCtrl,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones de clase',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _actividadCtrl,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Actividad del dia',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<String>(
                          initialValue: _estadoContenido,
                          decoration: const InputDecoration(
                            labelText: 'Contenido de clase',
                          ),
                          items: _estadosContenido
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(_labelEstadoContenido(e)),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _estadoContenido = v);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<String>(
                          initialValue: _resultadoActividad,
                          decoration: const InputDecoration(
                            labelText: 'Resultado de actividad',
                          ),
                          items: _resultadosActividad
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(_labelResultadoActividad(e)),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _resultadoActividad = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _guardando ? null : _guardarDetalleClase,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(
                          _guardando ? 'Guardando...' : 'Guardar clase',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _guardando
                            ? null
                            : () => _marcarTodos(EstadoAsistencia.pendiente),
                        icon: const Icon(Icons.hourglass_empty_outlined),
                        label: const Text('Todos pendientes'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _guardando
                            ? null
                            : () => _marcarTodos(EstadoAsistencia.presente),
                        icon: const Icon(Icons.done_all_outlined),
                        label: const Text('Todos presentes'),
                      ),
                      IconButton(
                        tooltip: 'Recargar',
                        onPressed: _guardando ? null : _cargar,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          'Pendiente: ${_contar(EstadoAsistencia.pendiente)}',
                        ),
                      ),
                      Chip(
                        label: Text(
                          'Presente: ${_contar(EstadoAsistencia.presente)}',
                        ),
                      ),
                      Chip(
                        label: Text(
                          'Ausente: ${_contar(EstadoAsistencia.ausente)}',
                        ),
                      ),
                      Chip(
                        label: Text(
                          'Tarde: ${_contar(EstadoAsistencia.tarde)}',
                        ),
                      ),
                      Chip(
                        label: Text(
                          'Justificada: ${_contar(EstadoAsistencia.justificada)}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _planilla.isEmpty
                        ? const EstadoListaVacia(
                            titulo: 'Sin planilla de asistencia',
                            icono: Icons.fact_check_outlined,
                          )
                        : ListView.separated(
                            itemCount: _planilla.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final r = _planilla[i];
                              return ListTile(
                                dense: true,
                                title: Text(r.alumno.nombreCompleto),
                                trailing: SizedBox(
                                  width: 180,
                                  child:
                                      DropdownButtonFormField<EstadoAsistencia>(
                                        initialValue: r.estado,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 0,
                                          ),
                                        ),
                                        isDense: true,
                                        items: EstadoAsistenciaX.valuesOrdenadas
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e.label),
                                              ),
                                            )
                                            .toList(growable: false),
                                        onChanged: (v) {
                                          if (v == null) return;
                                          _cambiarEstadoAlumno(r, v);
                                        },
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
