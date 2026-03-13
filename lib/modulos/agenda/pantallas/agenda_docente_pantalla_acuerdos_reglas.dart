part of 'agenda_docente_pantalla.dart';

class _DialogAcuerdosConvivencia extends StatefulWidget {
  final int cursoId;
  final String tituloCurso;
  final String institucion;

  const _DialogAcuerdosConvivencia({
    required this.cursoId,
    required this.tituloCurso,
    required this.institucion,
  });

  @override
  State<_DialogAcuerdosConvivencia> createState() =>
      _DialogAcuerdosConvivenciaState();
}

class _DialogAcuerdosConvivenciaState
    extends State<_DialogAcuerdosConvivencia> {
  final TextEditingController _descripcionCtrl = TextEditingController();
  final TextEditingController _estrategiaCtrl = TextEditingController();

  bool _cargando = true;
  bool _guardando = false;
  bool _huboCambios = false;
  bool _reiterada = false;
  String _tipo = 'acuerdo';
  List<AcuerdoConvivencia> _acuerdos = const [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    _estrategiaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final acuerdos = await Proveedores.agendaDocenteRepositorio
        .listarAcuerdosCurso(widget.cursoId);
    if (!mounted) return;
    setState(() {
      _acuerdos = acuerdos;
      _cargando = false;
    });
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    final descripcion = _descripcionCtrl.text.trim();
    if (descripcion.isEmpty) return;

    setState(() => _guardando = true);
    await Proveedores.agendaDocenteRepositorio.registrarAcuerdoConvivencia(
      cursoId: widget.cursoId,
      tipo: _tipo,
      descripcion: descripcion,
      estrategia: _estrategiaCtrl.text,
      reiterada: _reiterada,
    );
    _huboCambios = true;
    _descripcionCtrl.clear();
    _estrategiaCtrl.clear();
    _reiterada = false;
    await _cargar();
    if (mounted) setState(() => _guardando = false);
  }

  Future<void> _cambiarEstado(AcuerdoConvivencia a, bool valor) async {
    await Proveedores.agendaDocenteRepositorio
        .actualizarEstadoAcuerdoConvivencia(acuerdoId: a.id, resuelta: valor);
    _huboCambios = true;
    await _cargar();
  }

  Future<void> _eliminar(AcuerdoConvivencia a) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: Text('Se eliminara el registro "${a.descripcion}".'),
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
    await Proveedores.agendaDocenteRepositorio.eliminarAcuerdoConvivencia(a.id);
    _huboCambios = true;
    await _cargar();
  }

  Future<void> _aplicarPlantilla() async {
    final plantilla = await _mostrarSelectorPlantillaDocente(
      context: context,
      cursoId: widget.cursoId,
      institucion: widget.institucion,
      tipoInicial: 'criterio_seguimiento',
      titulo: 'Seleccionar plantilla para acuerdo',
    );
    if (plantilla == null) return;
    await Proveedores.agendaDocenteRepositorio.registrarUsoPlantillaDocente(
      plantilla.id,
    );
    final desc = _descripcionCtrl.text.trim();
    if (desc.isEmpty) {
      _descripcionCtrl.text = plantilla.contenido.trim();
    } else {
      final estrategia = _estrategiaCtrl.text.trim();
      _estrategiaCtrl.text = estrategia.isEmpty
          ? plantilla.contenido.trim()
          : '$estrategia\n${plantilla.contenido.trim()}';
    }
    _huboCambios = true;
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Plantilla aplicada')));
    await _cargar();
  }

  String _labelTipo(String tipo) {
    switch (tipo.trim().toLowerCase()) {
      case 'convivencia':
        return 'Convivencia';
      case 'situacion':
        return 'Situacion';
      case 'acuerdo':
      default:
        return 'Acuerdo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _tituloDialogoCurso('Acuerdos y convivencia', widget.tituloCurso),
      content: SizedBox(
        width: _anchoDialogo(context, 900),
        height: _altoDialogo(context, 620),
        child: _cargando
            ? const EstadoListaCargando(mensaje: 'Cargando...')
            : Column(
                children: [
                  _bloqueDescripcionFuncion(context, 'acuerdos'),
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
                              value: 'acuerdo',
                              child: Text('Acuerdo'),
                            ),
                            DropdownMenuItem(
                              value: 'convivencia',
                              child: Text('Convivencia'),
                            ),
                            DropdownMenuItem(
                              value: 'situacion',
                              child: Text('Situacion reiterada'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _tipo = v);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 170,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Expanded(
                              child: Text(
                                'Reiterada',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Switch(
                              value: _reiterada,
                              onChanged: (v) => setState(() => _reiterada = v),
                            ),
                          ],
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
                    decoration: const InputDecoration(
                      labelText: 'Descripcion',
                      hintText:
                          'Ej: Se acuerda iniciar lectura en 10 minutos y respetar turnos',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _estrategiaCtrl,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Estrategia o seguimiento (opcional)',
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
                    child: _acuerdos.isEmpty
                        ? const EstadoListaVacia(
                            titulo: 'No hay registros cargados',
                            icono: Icons.handshake_outlined,
                          )
                        : ListView.builder(
                            itemCount: _acuerdos.length,
                            itemBuilder: (_, idx) {
                              final a = _acuerdos[idx];
                              final estrategia = (a.estrategia ?? '').trim();
                              return CheckboxListTile(
                                value: a.resuelta,
                                onChanged: (v) {
                                  if (v == null) return;
                                  _cambiarEstado(a, v);
                                },
                                title: Text(
                                  '[${_labelTipo(a.tipo)}${a.reiterada ? ' | Reiterada' : ''}] ${_fechaHora(a.fecha)}',
                                ),
                                subtitle: Text(
                                  '${a.descripcion}${estrategia.isEmpty ? '' : '\nSeguimiento: $estrategia'}',
                                ),
                                secondary: IconButton(
                                  tooltip: 'Eliminar',
                                  onPressed: () => _eliminar(a),
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

class _DialogReglasInstitucion extends StatefulWidget {
  final String institucion;

  const _DialogReglasInstitucion({required this.institucion});

  @override
  State<_DialogReglasInstitucion> createState() =>
      _DialogReglasInstitucionState();
}

class _DialogReglasInstitucionState extends State<_DialogReglasInstitucion> {
  final TextEditingController _notaAprobacionCtrl = TextEditingController();
  final TextEditingController _asistenciaMinimaCtrl = TextEditingController();
  final TextEditingController _regimenCtrl = TextEditingController();
  final TextEditingController _criteriosCtrl = TextEditingController();
  final TextEditingController _observacionesEstandarCtrl =
      TextEditingController();

  bool _cargando = true;
  bool _guardando = false;
  bool _huboCambios = false;
  String? _errorCarga;
  String _escala = 'numerica_10';
  int _maxRecuperatorios = 1;
  bool _recuperatorioReemplazaNota = true;
  bool _recuperatorioSoloCambiaCondicion = false;
  bool _recuperatorioObligatorio = false;
  bool _ausenteJustificadoNoPenaliza = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _notaAprobacionCtrl.dispose();
    _asistenciaMinimaCtrl.dispose();
    _regimenCtrl.dispose();
    _criteriosCtrl.dispose();
    _observacionesEstandarCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });
    try {
      final regla = await Proveedores.agendaDocenteRepositorio
          .obtenerReglaInstitucion(widget.institucion);
      if (!mounted) return;
      setState(() {
        _escala = regla.escalaCalificacion;
        _notaAprobacionCtrl.text = regla.notaAprobacion;
        _asistenciaMinimaCtrl.text = regla.asistenciaMinima.toStringAsFixed(1);
        _maxRecuperatorios = regla.maxRecuperatorios;
        _recuperatorioReemplazaNota = regla.recuperatorioReemplazaNota;
        _recuperatorioSoloCambiaCondicion =
            regla.recuperatorioSoloCambiaCondicion;
        _recuperatorioObligatorio = regla.recuperatorioObligatorio;
        _ausenteJustificadoNoPenaliza = regla.ausenteJustificadoNoPenaliza;
        _regimenCtrl.text = regla.regimenAsistencia ?? '';
        _criteriosCtrl.text = regla.criteriosGenerales ?? '';
        _observacionesEstandarCtrl.text = regla.observacionesEstandar ?? '';
        _cargando = false;
      });
    } catch (e, st) {
      debugPrint('Error cargando reglas institucionales: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _errorCarga = 'No se pudieron cargar las reglas institucionales';
      });
    }
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    final asistencia = double.tryParse(
      _asistenciaMinimaCtrl.text.trim().replaceAll(',', '.'),
    );
    if (asistencia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asistencia minima invalida (usa numero)'),
        ),
      );
      return;
    }
    setState(() => _guardando = true);
    try {
      await Proveedores.agendaDocenteRepositorio.guardarReglaInstitucion(
        institucion: widget.institucion,
        escalaCalificacion: _escala,
        notaAprobacion: _notaAprobacionCtrl.text,
        asistenciaMinima: asistencia,
        maxRecuperatorios: _maxRecuperatorios,
        recuperatorioReemplazaNota: _recuperatorioReemplazaNota,
        recuperatorioSoloCambiaCondicion: _recuperatorioSoloCambiaCondicion,
        recuperatorioObligatorio: _recuperatorioObligatorio,
        ausenteJustificadoNoPenaliza: _ausenteJustificadoNoPenaliza,
        regimenAsistencia: _regimenCtrl.text,
        criteriosGenerales: _criteriosCtrl.text,
        observacionesEstandar: _observacionesEstandarCtrl.text,
      );
      _huboCambios = true;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reglas institucionales guardadas')),
      );
    } catch (e, st) {
      debugPrint('Error guardando reglas institucionales: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error al guardar reglas institucionales'),
          content: SingleChildScrollView(
            child: SelectableText(_mensajeErrorVisible(e)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
      if (mounted) setState(() => _guardando = false);
      return;
    }

    try {
      await _cargar();
    } catch (e, st) {
      debugPrint('Error recargando reglas institucionales: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Se guardaron, pero no se pudieron refrescar en pantalla',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  String _mensajeErrorVisible(Object error) {
    final mensaje = error.toString().trim();
    if (mensaje.isEmpty) return 'Error desconocido';
    return mensaje
        .replaceFirst('Exception: ', '')
        .replaceFirst('Bad state: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _tituloDialogoCurso('Reglas institucionales', widget.institucion),
      content: SizedBox(
        width: _anchoDialogo(context, 760),
        height: _altoDialogo(context, 560),
        child: _cargando
            ? const EstadoListaCargando(mensaje: 'Cargando reglas...')
            : _errorCarga != null
            ? EstadoListaError(mensaje: _errorCarga!, alReintentar: _cargar)
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _bloqueDescripcionFuncion(context, 'reglas'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _escala,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Escala de calificacion',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'numerica_10',
                          child: Text('Numerica 1-10'),
                        ),
                        DropdownMenuItem(
                          value: 'numerica_100',
                          child: Text('Numerica 1-100'),
                        ),
                        DropdownMenuItem(
                          value: 'conceptual',
                          child: Text('Conceptual'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _escala = v);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notaAprobacionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nota minima de aprobacion',
                        hintText: 'Ej: 6',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _asistenciaMinimaCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Asistencia minima (%)',
                        hintText: 'Ej: 75',
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: _maxRecuperatorios,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad maxima de recuperatorios',
                      ),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('No permite')),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Un recuperatorio'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('Hasta dos recuperatorios'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _maxRecuperatorios = v;
                          if (_maxRecuperatorios <= 0) {
                            _recuperatorioObligatorio = false;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 4),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Recuperatorio reemplaza nota previa'),
                      subtitle: const Text(
                        'Si no, mantiene nota previa salvo que no exista.',
                      ),
                      value: _recuperatorioReemplazaNota,
                      onChanged: (v) =>
                          setState(() => _recuperatorioReemplazaNota = v),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Recuperatorio solo cambia condicion'),
                      subtitle: const Text(
                        'No modifica nota vigente del proceso evaluativo.',
                      ),
                      value: _recuperatorioSoloCambiaCondicion,
                      onChanged: (v) =>
                          setState(() => _recuperatorioSoloCambiaCondicion = v),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Recuperatorio obligatorio'),
                      subtitle: const Text(
                        'Si un alumno no aprueba en original, queda pendiente hasta rendir recuperatorio.',
                      ),
                      value: _recuperatorioObligatorio,
                      onChanged: _maxRecuperatorios <= 0
                          ? null
                          : (v) =>
                                setState(() => _recuperatorioObligatorio = v),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Ausente justificado no penaliza'),
                      subtitle: const Text(
                        'Mantiene condicion previa y habilita nueva instancia.',
                      ),
                      value: _ausenteJustificadoNoPenaliza,
                      onChanged: (v) =>
                          setState(() => _ausenteJustificadoNoPenaliza = v),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _regimenCtrl,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Regimen de asistencia',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _criteriosCtrl,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Criterios pedagógicos generales',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _observacionesEstandarCtrl,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Observaciones estandar (una por linea)',
                        hintText:
                            'Ej: Bajo rendimiento sostenido\nEntrega incompleta\nBuen avance reciente',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _guardando ? null : _guardar,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(_guardando ? 'Guardando...' : 'Guardar'),
                      ),
                    ),
                  ],
                ),
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
