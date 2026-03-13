part of 'agenda_docente_pantalla.dart';

class _DialogRubricasCurso extends StatefulWidget {
  final int cursoId;
  final String institucion;
  final String tituloCurso;

  const _DialogRubricasCurso({
    required this.cursoId,
    required this.institucion,
    required this.tituloCurso,
  });

  @override
  State<_DialogRubricasCurso> createState() => _DialogRubricasCursoState();
}

class _DialogRubricasCursoState extends State<_DialogRubricasCurso> {
  bool _cargando = true;
  bool _huboCambios = false;
  String _filtroTipo = 'todas';
  List<RubricaSimple> _rubricas = const [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final tipo = _filtroTipo == 'todas' ? null : _filtroTipo;
    final rubricas = await Proveedores.agendaDocenteRepositorio
        .listarRubricasParaCurso(
          institucion: widget.institucion,
          cursoId: widget.cursoId,
          tipo: tipo,
          limite: 200,
        );
    if (!mounted) return;
    setState(() {
      _rubricas = rubricas;
      _cargando = false;
    });
  }

  Future<void> _crearEditar({RubricaSimple? rubrica}) async {
    final ed = await showDialog<_RubricaEdicion>(
      context: context,
      builder: (context) => _DialogEdicionRubricaSimple(actual: rubrica),
    );
    if (ed == null) return;
    if (rubrica == null) {
      await Proveedores.agendaDocenteRepositorio.crearRubricaSimple(
        institucion: ed.alcance == 'institucion' ? widget.institucion : null,
        cursoId: ed.alcance == 'curso' ? widget.cursoId : null,
        tipo: ed.tipo,
        titulo: ed.titulo,
        criterios: ed.criterios,
        orden: ed.orden,
      );
    } else {
      await Proveedores.agendaDocenteRepositorio.actualizarRubricaSimple(
        rubricaId: rubrica.id,
        institucion: ed.alcance == 'institucion' ? widget.institucion : null,
        cursoId: ed.alcance == 'curso' ? widget.cursoId : null,
        tipo: ed.tipo,
        titulo: ed.titulo,
        criterios: ed.criterios,
        orden: ed.orden,
      );
    }
    _huboCambios = true;
    await _cargar();
  }

  Future<void> _eliminar(RubricaSimple r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar rubrica'),
        content: Text('Se eliminara "${r.titulo}".'),
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
    if (ok != true) return;
    await Proveedores.agendaDocenteRepositorio.eliminarRubricaSimple(r.id);
    _huboCambios = true;
    await _cargar();
  }

  Future<void> _copiarRubrica(RubricaSimple r) async {
    await Clipboard.setData(ClipboardData(text: r.criterios));
    await Proveedores.agendaDocenteRepositorio.registrarUsoRubricaSimple(r.id);
    _huboCambios = true;
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Rubrica copiada')));
    await _cargar();
  }

  String _labelAlcance(RubricaSimple r) {
    if (r.cursoId != null) return 'Curso';
    if ((r.institucion ?? '').trim().isNotEmpty) return 'Institucion';
    return 'General';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _tituloDialogoCurso('Rubricas', widget.tituloCurso),
      content: SizedBox(
        width: _anchoDialogo(context, 920),
        height: _altoDialogo(context, 620),
        child: Column(
          children: [
            _bloqueDescripcionFuncion(context, 'rubricas'),
            const SizedBox(height: 8),
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
                    items: const [
                      DropdownMenuItem(value: 'todas', child: Text('Todas')),
                      ..._tiposRubricaSimpleItems,
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _filtroTipo = v);
                      _cargar();
                    },
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _crearEditar(),
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva rubrica'),
                ),
                IconButton(
                  onPressed: _cargar,
                  tooltip: 'Recargar',
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _cargando
                  ? const EstadoListaCargando(mensaje: 'Cargando rubricas...')
                  : _rubricas.isEmpty
                  ? const EstadoListaVacia(
                      titulo: 'No hay rubricas en este contexto',
                      icono: Icons.fact_check_outlined,
                    )
                  : ListView.separated(
                      itemCount: _rubricas.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final r = _rubricas[i];
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            title: Text(
                              '[${_labelTipoRubricaSimple(r.tipo)}] ${r.titulo}',
                            ),
                            subtitle: Text(
                              '${r.criterios}\nAlcance: ${_labelAlcance(r)} | Usos: ${r.usoCount}',
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Copiar',
                                  onPressed: () => _copiarRubrica(r),
                                  icon: const Icon(Icons.copy_all_outlined),
                                ),
                                IconButton(
                                  tooltip: 'Editar',
                                  onPressed: () => _crearEditar(rubrica: r),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: 'Eliminar',
                                  onPressed: () => _eliminar(r),
                                  icon: const Icon(Icons.delete_outline),
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

Future<RubricaSimple?> _mostrarSelectorRubricaSimple({
  required BuildContext context,
  required int cursoId,
  String? institucion,
  String? tipoInicial,
  String titulo = 'Seleccionar rubrica',
}) {
  String filtroTipo = (tipoInicial ?? 'todas').trim().toLowerCase();
  if (filtroTipo.isEmpty) filtroTipo = 'todas';
  bool cargando = true;
  List<RubricaSimple> rubricas = const [];

  Future<void> recargar(StateSetter setStateDialog) async {
    setStateDialog(() => cargando = true);
    final tipo = filtroTipo == 'todas' ? null : filtroTipo;
    final data = await Proveedores.agendaDocenteRepositorio
        .listarRubricasParaCurso(
          institucion: institucion,
          cursoId: cursoId,
          tipo: tipo,
          limite: 160,
        );
    setStateDialog(() {
      rubricas = data;
      cargando = false;
    });
  }

  return showDialog<RubricaSimple>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setStateDialog) {
        if (cargando && rubricas.isEmpty) {
          recargar(setStateDialog);
        }
        return AlertDialog(
          title: Text(titulo),
          content: SizedBox(
            width: _anchoDialogo(context, 860),
            height: _altoDialogo(context, 560),
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
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Tipo'),
                        items: const [
                          DropdownMenuItem(
                            value: 'todas',
                            child: Text('Todas'),
                          ),
                          ..._tiposRubricaSimpleItems,
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
                      : rubricas.isEmpty
                      ? const EstadoListaVacia(
                          titulo: 'No hay rubricas para ese contexto',
                          icono: Icons.fact_check_outlined,
                        )
                      : ListView.separated(
                          itemCount: rubricas.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (_, idx) {
                            final r = rubricas[idx];
                            return Card(
                              margin: EdgeInsets.zero,
                              child: ListTile(
                                title: Text(
                                  '[${_labelTipoRubricaSimple(r.tipo)}] ${r.titulo}',
                                ),
                                subtitle: Text(
                                  r.criterios,
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: FilledButton(
                                  onPressed: () => Navigator.pop(context, r),
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

class _DialogEdicionRubricaSimple extends StatefulWidget {
  final RubricaSimple? actual;

  const _DialogEdicionRubricaSimple({required this.actual});

  @override
  State<_DialogEdicionRubricaSimple> createState() =>
      _DialogEdicionRubricaSimpleState();
}

class _DialogEdicionRubricaSimpleState
    extends State<_DialogEdicionRubricaSimple> {
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _criteriosCtrl;
  late final TextEditingController _ordenCtrl;
  late String _tipo;
  late String _alcance;

  @override
  void initState() {
    super.initState();
    final a = widget.actual;
    _tituloCtrl = TextEditingController(text: a?.titulo ?? '');
    _criteriosCtrl = TextEditingController(text: a?.criterios ?? '');
    _ordenCtrl = TextEditingController(text: (a?.orden ?? 0).toString());
    _tipo = a?.tipo ?? 'trabajo_practico';
    _alcance = a == null
        ? 'curso'
        : (a.cursoId != null
              ? 'curso'
              : (a.institucion != null ? 'institucion' : 'general'));
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _criteriosCtrl.dispose();
    _ordenCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    final titulo = _tituloCtrl.text.trim();
    final criterios = _criteriosCtrl.text.trim();
    if (titulo.isEmpty || criterios.isEmpty) return;
    final orden = int.tryParse(_ordenCtrl.text.trim()) ?? 0;
    Navigator.pop(
      context,
      _RubricaEdicion(
        tipo: _tipo,
        alcance: _alcance,
        titulo: titulo,
        criterios: criterios,
        orden: orden,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.actual == null ? 'Nueva rubrica' : 'Editar rubrica'),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _tipo,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: _tiposRubricaSimpleItems,
              onChanged: (v) {
                if (v == null) return;
                setState(() => _tipo = v);
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _alcance,
              decoration: const InputDecoration(labelText: 'Alcance'),
              items: const [
                DropdownMenuItem(value: 'curso', child: Text('Solo curso')),
                DropdownMenuItem(
                  value: 'institucion',
                  child: Text('Toda institucion'),
                ),
                DropdownMenuItem(value: 'general', child: Text('General')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _alcance = v);
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(labelText: 'Titulo'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _criteriosCtrl,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Criterios',
                hintText:
                    'Ej: Comprension (0-3), Argumentacion (0-3), Presentacion (0-2), Participacion (0-2)',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ordenCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Orden'),
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

class _RubricaEdicion {
  final String tipo;
  final String alcance;
  final String titulo;
  final String criterios;
  final int orden;

  const _RubricaEdicion({
    required this.tipo,
    required this.alcance,
    required this.titulo,
    required this.criterios,
    required this.orden,
  });
}

const List<DropdownMenuItem<String>> _tiposRubricaSimpleItems = [
  DropdownMenuItem(value: 'oral', child: Text('Oral')),
  DropdownMenuItem(value: 'escrito', child: Text('Escrito')),
  DropdownMenuItem(value: 'trabajo_practico', child: Text('Trabajo practico')),
  DropdownMenuItem(value: 'participacion', child: Text('Participacion')),
  DropdownMenuItem(value: 'analisis', child: Text('Analisis')),
  DropdownMenuItem(value: 'comprension', child: Text('Comprension')),
];

String _labelTipoRubricaSimple(String tipo) {
  switch (tipo.trim().toLowerCase()) {
    case 'oral':
      return 'Oral';
    case 'escrito':
      return 'Escrito';
    case 'trabajo_practico':
      return 'Trabajo practico';
    case 'participacion':
      return 'Participacion';
    case 'analisis':
      return 'Analisis';
    case 'comprension':
      return 'Comprension';
    default:
      return 'Rubrica';
  }
}
