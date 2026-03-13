part of 'agenda_docente_pantalla.dart';

class _DialogAuditoriaDocente extends StatefulWidget {
  final DateTime fechaReferencia;
  final List<AgendaDocenteItem> agenda;

  const _DialogAuditoriaDocente({
    required this.fechaReferencia,
    required this.agenda,
  });

  @override
  State<_DialogAuditoriaDocente> createState() =>
      _DialogAuditoriaDocenteState();
}

class _DialogAuditoriaDocenteState extends State<_DialogAuditoriaDocente> {
  bool _cargando = true;
  String _filtroEntidad = 'todas';
  String _filtroInstitucion = 'todas';
  int? _filtroCursoId;
  List<AuditoriaDocenteItem> _items = const [];

  static const List<String> _entidades = [
    'todas',
    'evaluacion',
    'evaluacion_instancia',
    'evaluacion_resultado',
    'intervencion_docente',
    'regla_institucion',
  ];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  List<String> _institucionesDisponibles() {
    final out = <String>{};
    for (final item in widget.agenda) {
      final i = item.institucion.trim();
      if (i.isNotEmpty) out.add(i);
    }
    for (final item in _items) {
      final i = (item.institucion ?? '').trim();
      if (i.isNotEmpty) out.add(i);
    }
    final lista = out.toList();
    lista.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return lista;
  }

  List<AgendaDocenteItem> _cursosDisponibles() {
    final lista = [...widget.agenda];
    lista.sort((a, b) {
      final inst = a.institucion.toLowerCase().compareTo(
        b.institucion.toLowerCase(),
      );
      if (inst != 0) return inst;
      return a.materia.toLowerCase().compareTo(b.materia.toLowerCase());
    });
    return lista;
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final entidad = _filtroEntidad == 'todas' ? null : _filtroEntidad;
    final institucion = _filtroInstitucion == 'todas'
        ? null
        : _filtroInstitucion;
    final data = await Proveedores.agendaDocenteRepositorio
        .listarAuditoriaDocente(
          entidad: entidad,
          institucion: institucion,
          cursoId: _filtroCursoId,
          limite: 300,
        );
    if (!mounted) return;
    setState(() {
      _items = data;
      _cargando = false;
    });
  }

  String _labelEntidad(String entidad) {
    switch (entidad.trim().toLowerCase()) {
      case 'evaluacion':
        return 'Evaluacion';
      case 'evaluacion_instancia':
        return 'Instancia evaluacion';
      case 'evaluacion_resultado':
        return 'Resultado evaluacion';
      case 'intervencion_docente':
        return 'Intervencion docente';
      case 'regla_institucion':
        return 'Regla institucion';
      default:
        return entidad;
    }
  }

  String _labelCurso(int? cursoId) {
    if (cursoId == null) return 'Sin curso';
    for (final item in widget.agenda) {
      if (item.cursoId == cursoId) {
        return '${item.materia} (${item.etiquetaCurso})';
      }
    }
    return 'Curso #$cursoId';
  }

  String _valor(String? text) {
    final t = (text ?? '').trim();
    return t.isEmpty ? '-' : t;
  }

  @override
  Widget build(BuildContext context) {
    final instituciones = _institucionesDisponibles();
    final cursos = _cursosDisponibles();
    return AlertDialog(
      title: Text('Auditoria docente - ${_fechaLarga(widget.fechaReferencia)}'),
      content: SizedBox(
        width: _anchoDialogo(context, 980),
        height: _altoDialogo(context, 660),
        child: Column(
          children: [
            _bloqueDescripcionFuncion(context, 'auditoria'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 230,
                  child: DropdownButtonFormField<String>(
                    initialValue: _filtroEntidad,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Entidad'),
                    items: _entidades
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(
                              e == 'todas' ? 'Todas' : _labelEntidad(e),
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _filtroEntidad = v);
                      _cargar();
                    },
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: DropdownButtonFormField<String>(
                    initialValue: _filtroInstitucion,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Institucion'),
                    items: [
                      _itemMenuElidido('todas', 'Todas'),
                      ...instituciones.map((i) => _itemMenuElidido(i, i)),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _filtroInstitucion = v);
                      _cargar();
                    },
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: DropdownButtonFormField<int?>(
                    initialValue: _filtroCursoId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Curso'),
                    items: [
                      _itemMenuElidido<int?>(null, 'Todos'),
                      ...cursos.map(
                        (c) => DropdownMenuItem<int?>(
                          value: c.cursoId,
                          child: _textoElidido(
                            '${c.materia} (${c.etiquetaCurso})',
                          ),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() => _filtroCursoId = v);
                      _cargar();
                    },
                  ),
                ),
                IconButton(
                  onPressed: _cargar,
                  tooltip: 'Recargar',
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _cargando
                  ? const EstadoListaCargando(mensaje: 'Cargando auditoria...')
                  : _items.isEmpty
                  ? const EstadoListaVacia(
                      titulo: 'No hay cambios sensibles para esos filtros',
                      icono: Icons.history_toggle_off_outlined,
                    )
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final item = _items[i];
                        final institucion = (item.institucion ?? '').trim();
                        final contexto = (item.contexto ?? '').trim();
                        return ListTile(
                          dense: true,
                          title: Text(
                            '${_fechaHora(item.creadoEn)} | ${_labelEntidad(item.entidad)} | ${item.campo}',
                          ),
                          subtitle: Text(
                            'Inst.: ${institucion.isEmpty ? '-' : institucion} | ${_labelCurso(item.cursoId)}\nAnterior: ${_valor(item.valorAnterior)}\nNuevo: ${_valor(item.valorNuevo)}${contexto.isEmpty ? '' : '\nContexto: $contexto'}',
                          ),
                          isThreeLine: true,
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
