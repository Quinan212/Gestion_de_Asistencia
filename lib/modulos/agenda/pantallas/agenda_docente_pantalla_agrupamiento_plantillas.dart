part of 'agenda_docente_pantalla.dart';

class _DialogAgrupamientoCurso extends StatefulWidget {
  final int cursoId;
  final String tituloCurso;

  const _DialogAgrupamientoCurso({
    required this.cursoId,
    required this.tituloCurso,
  });

  @override
  State<_DialogAgrupamientoCurso> createState() =>
      _DialogAgrupamientoCursoState();
}

class _DialogAgrupamientoCursoState extends State<_DialogAgrupamientoCurso> {
  bool _cargando = true;
  List<AgrupamientoPedagogicoItem> _items = const [];
  String _filtroGrupo = 'todos';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final items = await Proveedores.agendaDocenteRepositorio
        .generarAgrupamientoPedagogicoCurso(widget.cursoId);
    if (!mounted) return;
    setState(() {
      _items = items;
      _cargando = false;
    });
  }

  List<AgrupamientoPedagogicoItem> _filtrados() {
    if (_filtroGrupo == 'todos') return _items;
    return _items
        .where((x) => x.grupo.toLowerCase() == _filtroGrupo)
        .toList(growable: false);
  }

  int _contar(String grupo) {
    return _items.where((x) => x.grupo.toLowerCase() == grupo).length;
  }

  Color _colorGrupo(String grupo) {
    final g = grupo.trim().toLowerCase();
    if (g == 'refuerzo') return Colors.red.shade700;
    if (g == 'media') return Colors.orange.shade700;
    return Colors.green.shade700;
  }

  String _labelGrupo(String grupo) {
    final g = grupo.trim().toLowerCase();
    if (g == 'refuerzo') return 'Refuerzo';
    if (g == 'media') return 'Zona media';
    return 'Autonomo';
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados();
    return AlertDialog(
      title: _tituloDialogoCurso('Agrupamiento pedagogico', widget.tituloCurso),
      content: SizedBox(
        width: _anchoDialogo(context, 920),
        height: _altoDialogo(context, 620),
        child: _cargando
            ? const EstadoListaCargando(mensaje: 'Calculando agrupamiento...')
            : Column(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<String>(
                          initialValue: _filtroGrupo,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Filtrar grupo',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'todos',
                              child: Text('Todos'),
                            ),
                            DropdownMenuItem(
                              value: 'refuerzo',
                              child: Text('Refuerzo'),
                            ),
                            DropdownMenuItem(
                              value: 'media',
                              child: Text('Zona media'),
                            ),
                            DropdownMenuItem(
                              value: 'autonomo',
                              child: Text('Autonomo'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _filtroGrupo = v);
                          },
                        ),
                      ),
                      Chip(label: Text('Refuerzo: ${_contar('refuerzo')}')),
                      Chip(label: Text('Zona media: ${_contar('media')}')),
                      Chip(label: Text('Autonomos: ${_contar('autonomo')}')),
                      IconButton(
                        tooltip: 'Recalcular',
                        onPressed: _cargar,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtrados.isEmpty
                        ? const EstadoListaVacia(
                            titulo: 'No hay alumnos para el filtro',
                            icono: Icons.groups_outlined,
                          )
                        : ListView.separated(
                            itemCount: filtrados.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final x = filtrados[i];
                              final color = _colorGrupo(x.grupo);
                              return ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: color.withValues(
                                    alpha: 0.15,
                                  ),
                                  child: Text(
                                    _labelGrupo(
                                      x.grupo,
                                    ).substring(0, 1).toUpperCase(),
                                    style: TextStyle(color: color),
                                  ),
                                ),
                                title: Text(x.alumnoNombre),
                                subtitle: Text(
                                  '${_labelGrupo(x.grupo)} | ${x.fundamento}',
                                ),
                                trailing: x.mejoraReciente
                                    ? const Icon(
                                        Icons.trending_up_outlined,
                                        color: Colors.green,
                                      )
                                    : null,
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

class _DialogPlantillasCurso extends StatefulWidget {
  final int cursoId;
  final String institucion;
  final String tituloCurso;

  const _DialogPlantillasCurso({
    required this.cursoId,
    required this.institucion,
    required this.tituloCurso,
  });

  @override
  State<_DialogPlantillasCurso> createState() => _DialogPlantillasCursoState();
}

class _DialogPlantillasCursoState extends State<_DialogPlantillasCurso> {
  bool _cargando = true;
  bool _huboCambios = false;
  bool _guardando = false;
  String _filtroTipo = 'todas';
  List<PlantillaDocente> _plantillas = const [];

  static const List<String> _tipos = [
    'comentario_boletin',
    'devolucion',
    'observacion_tipo',
    'criterio_seguimiento',
    'estado_actividad',
    'mensaje_base',
  ];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final tipo = _filtroTipo == 'todas' ? null : _filtroTipo;
    final plantillas = await Proveedores.agendaDocenteRepositorio
        .listarPlantillasParaCurso(
          institucion: widget.institucion,
          cursoId: widget.cursoId,
          tipo: tipo,
          limite: 160,
        );
    if (!mounted) return;
    setState(() {
      _plantillas = plantillas;
      _cargando = false;
    });
  }

  String _labelTipo(String tipo) {
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

  String _labelAlcance(PlantillaDocente p) {
    if (p.cursoId != null) return 'Curso';
    if ((p.institucion ?? '').trim().isNotEmpty) return 'Institucion';
    return 'General';
  }

  Future<void> _usarPlantilla(PlantillaDocente plantilla) async {
    await Clipboard.setData(ClipboardData(text: plantilla.contenido));
    await Proveedores.agendaDocenteRepositorio.registrarUsoPlantillaDocente(
      plantilla.id,
    );
    _huboCambios = true;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plantilla copiada al portapapeles')),
    );
    await _cargar();
  }

  Future<void> _crearOEditar({PlantillaDocente? actual}) async {
    final edicion = await showDialog<_PlantillaEdicion>(
      context: context,
      builder: (context) => _DialogEdicionPlantilla(
        actual: actual,
        institucion: widget.institucion,
      ),
    );
    if (edicion == null) return;

    setState(() => _guardando = true);
    try {
      final contexto = _resolverContextoEdicion(edicion.alcance);
      if (actual == null) {
        await Proveedores.agendaDocenteRepositorio.crearPlantillaDocente(
          institucion: contexto.$1,
          cursoId: contexto.$2,
          tipo: edicion.tipo,
          titulo: edicion.titulo,
          contenido: edicion.contenido,
          atajo: edicion.atajo,
          orden: edicion.orden,
        );
      } else {
        await Proveedores.agendaDocenteRepositorio.actualizarPlantillaDocente(
          plantillaId: actual.id,
          institucion: contexto.$1,
          cursoId: contexto.$2,
          tipo: edicion.tipo,
          titulo: edicion.titulo,
          contenido: edicion.contenido,
          atajo: edicion.atajo,
          orden: edicion.orden,
        );
      }
      _huboCambios = true;
      await _cargar();
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  (String?, int?) _resolverContextoEdicion(String alcance) {
    final a = alcance.trim().toLowerCase();
    if (a == 'curso') return (widget.institucion, widget.cursoId);
    if (a == 'institucion') return (widget.institucion, null);
    return (null, null);
  }

  Future<void> _eliminar(PlantillaDocente p) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar plantilla'),
        content: Text('Se eliminara "${p.titulo}".'),
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
    await Proveedores.agendaDocenteRepositorio.eliminarPlantillaDocente(p.id);
    _huboCambios = true;
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _tituloDialogoCurso(
        'Plantillas reutilizables',
        widget.tituloCurso,
      ),
      content: SizedBox(
        width: _anchoDialogo(context, 980),
        height: _altoDialogo(context, 660),
        child: _cargando
            ? const EstadoListaCargando(mensaje: 'Cargando plantillas...')
            : Column(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: 260,
                        child: DropdownButtonFormField<String>(
                          initialValue: _filtroTipo,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Tipo'),
                          items: [
                            _itemMenuElidido('todas', 'Todas'),
                            ..._tipos.map(
                              (t) => _itemMenuElidido(t, _labelTipo(t)),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _filtroTipo = v);
                            _cargar();
                          },
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _guardando ? null : () => _crearOEditar(),
                        icon: const Icon(Icons.add),
                        label: const Text('Nueva plantilla'),
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
                    child: _plantillas.isEmpty
                        ? const EstadoListaVacia(
                            titulo: 'No hay plantillas cargadas',
                            icono: Icons.text_snippet_outlined,
                          )
                        : ListView.separated(
                            itemCount: _plantillas.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final p = _plantillas[i];
                              return Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '[${_labelTipo(p.tipo)}] ${p.titulo}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Alcance: ${_labelAlcance(p)} | Usos: ${p.usoCount}${(p.atajo ?? '').trim().isEmpty ? '' : ' | Atajo: ${p.atajo}'}',
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        p.contenido,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: () => _usarPlantilla(p),
                                            icon: const Icon(
                                              Icons.copy_all_outlined,
                                            ),
                                            label: const Text('Usar'),
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: () =>
                                                _crearOEditar(actual: p),
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                            ),
                                            label: const Text('Editar'),
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: () => _eliminar(p),
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

class _DialogEdicionPlantilla extends StatefulWidget {
  final PlantillaDocente? actual;
  final String institucion;

  const _DialogEdicionPlantilla({
    required this.actual,
    required this.institucion,
  });

  @override
  State<_DialogEdicionPlantilla> createState() =>
      _DialogEdicionPlantillaState();
}

class _DialogEdicionPlantillaState extends State<_DialogEdicionPlantilla> {
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _contenidoCtrl;
  late final TextEditingController _atajoCtrl;
  late final TextEditingController _ordenCtrl;
  late String _tipo;
  late String _alcance;
  String? _error;

  static const List<String> _tipos = [
    'comentario_boletin',
    'devolucion',
    'observacion_tipo',
    'criterio_seguimiento',
    'estado_actividad',
    'mensaje_base',
  ];

  static const List<String> _alcances = ['general', 'institucion', 'curso'];

  @override
  void initState() {
    super.initState();
    final a = widget.actual;
    _tituloCtrl = TextEditingController(text: a?.titulo ?? '');
    _contenidoCtrl = TextEditingController(text: a?.contenido ?? '');
    _atajoCtrl = TextEditingController(text: a?.atajo ?? '');
    _ordenCtrl = TextEditingController(text: '${a?.orden ?? 0}');
    _tipo = a?.tipo ?? 'mensaje_base';
    if (!_tipos.contains(_tipo)) _tipo = 'mensaje_base';
    _alcance = a?.alcance ?? 'curso';
    if (!_alcances.contains(_alcance)) _alcance = 'curso';
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _contenidoCtrl.dispose();
    _atajoCtrl.dispose();
    _ordenCtrl.dispose();
    super.dispose();
  }

  String _labelTipo(String tipo) {
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

  String _labelAlcance(String alcance) {
    if (alcance == 'curso') return 'Curso actual';
    if (alcance == 'institucion') return 'Institucion actual';
    return 'General';
  }

  void _guardar() {
    final titulo = _tituloCtrl.text.trim();
    final contenido = _contenidoCtrl.text.trim();
    if (titulo.isEmpty || contenido.isEmpty) {
      setState(() => _error = 'Titulo y contenido son obligatorios');
      return;
    }
    final orden = int.tryParse(_ordenCtrl.text.trim()) ?? 0;
    Navigator.pop(
      context,
      _PlantillaEdicion(
        tipo: _tipo,
        alcance: _alcance,
        titulo: titulo,
        contenido: contenido,
        atajo: _atajoCtrl.text.trim(),
        orden: orden,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.actual == null ? 'Nueva plantilla' : 'Editar plantilla',
      ),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: 260,
                    child: DropdownButtonFormField<String>(
                      initialValue: _tipo,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: _tipos
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(_labelTipo(t)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _tipo = v);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      initialValue: _alcance,
                      decoration: const InputDecoration(labelText: 'Alcance'),
                      items: _alcances
                          .map(
                            (a) => DropdownMenuItem(
                              value: a,
                              child: Text(_labelAlcance(a)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _alcance = v);
                      },
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
                controller: _contenidoCtrl,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(labelText: 'Contenido'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _atajoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Atajo (opcional)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _ordenCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Orden'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Institucion de contexto: ${widget.institucion}',
                style: Theme.of(context).textTheme.bodySmall,
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
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}
