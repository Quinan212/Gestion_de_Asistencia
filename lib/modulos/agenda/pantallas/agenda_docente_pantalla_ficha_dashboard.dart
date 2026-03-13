part of 'agenda_docente_pantalla.dart';

class _DialogFichaPedagogica extends StatefulWidget {
  final int cursoId;
  final String tituloCurso;

  const _DialogFichaPedagogica({
    required this.cursoId,
    required this.tituloCurso,
  });

  @override
  State<_DialogFichaPedagogica> createState() => _DialogFichaPedagogicaState();
}

class _DialogFichaPedagogicaState extends State<_DialogFichaPedagogica> {
  final _dadosCtrl = TextEditingController();
  final _pendientesCtrl = TextEditingController();
  final _ritmoCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  final _alertasCtrl = TextEditingController();

  bool _cargando = true;
  bool _guardando = false;
  bool _huboCambios = false;
  List<ContenidoCurso> _contenidos = const [];

  static const List<String> _estados = [
    'pendiente',
    'iniciado',
    'en_desarrollo',
    'trabajado',
    'evaluado',
  ];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _dadosCtrl.dispose();
    _pendientesCtrl.dispose();
    _ritmoCtrl.dispose();
    _obsCtrl.dispose();
    _alertasCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final res = await Future.wait<dynamic>([
      Proveedores.agendaDocenteRepositorio.obtenerFichaCurso(widget.cursoId),
      Proveedores.agendaDocenteRepositorio.listarContenidosCurso(
        widget.cursoId,
      ),
    ]);
    if (!mounted) return;
    final ficha = res[0] as FichaPedagogicaCurso;
    setState(() {
      _dadosCtrl.text = ficha.contenidosDados;
      _pendientesCtrl.text = ficha.contenidosPendientes;
      _ritmoCtrl.text = ficha.ritmoGrupo;
      _obsCtrl.text = ficha.observacionesGenerales;
      _alertasCtrl.text = ficha.alertasDidacticas;
      _contenidos = res[1] as List<ContenidoCurso>;
      _cargando = false;
    });
  }

  Future<void> _guardarFicha() async {
    if (_guardando) return;
    setState(() => _guardando = true);
    await Proveedores.agendaDocenteRepositorio.guardarFichaCurso(
      cursoId: widget.cursoId,
      contenidosDados: _dadosCtrl.text,
      contenidosPendientes: _pendientesCtrl.text,
      ritmoGrupo: _ritmoCtrl.text,
      observacionesGenerales: _obsCtrl.text,
      alertasDidacticas: _alertasCtrl.text,
    );
    _huboCambios = true;
    if (mounted) setState(() => _guardando = false);
  }

  Future<void> _agregarContenido() async {
    final ctrl = TextEditingController();
    final texto = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo contenido'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Contenido',
            hintText: 'Ej: Lectura comprensiva de textos expositivos',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    if (texto == null || texto.trim().isEmpty) return;
    await Proveedores.agendaDocenteRepositorio.agregarContenidoCurso(
      cursoId: widget.cursoId,
      contenido: texto,
    );
    _huboCambios = true;
    await _cargar();
  }

  Future<void> _cambiarEstado(ContenidoCurso c, String estado) async {
    await Proveedores.agendaDocenteRepositorio.actualizarEstadoContenidoCurso(
      contenidoId: c.id,
      estado: estado,
    );
    _huboCambios = true;
    await _cargar();
  }

  Future<void> _eliminarContenido(int id) async {
    await Proveedores.agendaDocenteRepositorio.eliminarContenidoCurso(id);
    _huboCambios = true;
    await _cargar();
  }

  String _labelEstado(String estado) {
    switch (estado) {
      case 'iniciado':
        return 'Iniciado';
      case 'en_desarrollo':
        return 'En desarrollo';
      case 'trabajado':
        return 'Trabajado';
      case 'evaluado':
        return 'Evaluado';
      case 'pendiente':
      default:
        return 'Pendiente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _tituloDialogoCurso('Ficha pedagogica', widget.tituloCurso),
      content: SizedBox(
        width: _anchoDialogo(context, 900),
        height: _altoDialogo(context, 620),
        child: _cargando
            ? const EstadoListaCargando(mensaje: 'Cargando ficha...')
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _bloqueDescripcionFuncion(context, 'ficha'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _dadosCtrl,
                            minLines: 2,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Contenidos dados',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _pendientesCtrl,
                            minLines: 2,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Contenidos pendientes',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _ritmoCtrl,
                            minLines: 1,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Ritmo real del grupo',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _obsCtrl,
                            minLines: 2,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Observaciones generales',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _alertasCtrl,
                            minLines: 1,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Alertas didacticas',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Progreso de contenidos',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: _agregarContenido,
                                icon: const Icon(Icons.add),
                                label: const Text('Agregar contenido'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_contenidos.isEmpty)
                            const EstadoListaVacia(
                              titulo: 'No hay contenidos cargados',
                              icono: Icons.menu_book_outlined,
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _contenidos.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (_, i) {
                                final c = _contenidos[i];
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(c.contenido),
                                  subtitle: Text(
                                    'Estado: ${_labelEstado(c.estado)}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DropdownButton<String>(
                                        value: _estados.contains(c.estado)
                                            ? c.estado
                                            : 'pendiente',
                                        items: _estados
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(_labelEstado(e)),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (v) {
                                          if (v == null) return;
                                          _cambiarEstado(c, v);
                                        },
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _eliminarContenido(c.id),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
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
        FilledButton.icon(
          onPressed: _guardando
              ? null
              : () async {
                  await _guardarFicha();
                  if (!context.mounted) return;
                  Navigator.pop(context, true);
                },
          icon: const Icon(Icons.save_outlined),
          label: Text(_guardando ? 'Guardando...' : 'Guardar ficha'),
        ),
      ],
    );
  }
}

class _DialogDashboardEjecutivo extends StatefulWidget {
  final DateTime fechaReferencia;

  const _DialogDashboardEjecutivo({required this.fechaReferencia});

  @override
  State<_DialogDashboardEjecutivo> createState() =>
      _DialogDashboardEjecutivoState();
}

class _DialogDashboardEjecutivoState extends State<_DialogDashboardEjecutivo> {
  bool _cargando = true;
  String _filtroSemaforo = 'todos';
  List<DashboardInstitucionItem> _items = const [];
  Map<String, DashboardInstitucionItem> _itemsPreviosPorInstitucion = const {};

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final fechaPrevia = _soloFecha(
      widget.fechaReferencia.subtract(const Duration(days: 30)),
    );
    final resultado = await Future.wait<dynamic>([
      Proveedores.agendaDocenteRepositorio.generarDashboardInstitucional(
        widget.fechaReferencia,
      ),
      Proveedores.agendaDocenteRepositorio.generarDashboardInstitucional(
        fechaPrevia,
      ),
    ]);
    final items = resultado[0] as List<DashboardInstitucionItem>;
    final previos = resultado[1] as List<DashboardInstitucionItem>;
    final mapaPrevios = <String, DashboardInstitucionItem>{
      for (final i in previos) i.institucion.trim().toLowerCase(): i,
    };
    if (!mounted) return;
    setState(() {
      _items = items;
      _itemsPreviosPorInstitucion = mapaPrevios;
      _cargando = false;
    });
  }

  List<DashboardInstitucionItem> _filtrados() {
    if (_filtroSemaforo == 'todos') return _items;
    return _items
        .where((i) => i.semaforo.toLowerCase() == _filtroSemaforo)
        .toList(growable: false);
  }

  int _contar(String semaforo) {
    return _items.where((x) => x.semaforo.toLowerCase() == semaforo).length;
  }

  Color _colorSemaforo(String semaforo) {
    final s = semaforo.trim().toLowerCase();
    if (s == 'rojo') return Colors.red.shade700;
    if (s == 'amarillo') return Colors.orange.shade700;
    return Colors.green.shade700;
  }

  String _labelSemaforo(String semaforo) {
    final s = semaforo.trim().toLowerCase();
    if (s == 'rojo') return 'Rojo';
    if (s == 'amarillo') return 'Amarillo';
    return 'Verde';
  }

  DashboardInstitucionItem? _previo(DashboardInstitucionItem item) {
    return _itemsPreviosPorInstitucion[item.institucion.trim().toLowerCase()];
  }

  String _delta(int valor) {
    if (valor > 0) return '+$valor';
    return '$valor';
  }

  String _resumenTendencia(DashboardInstitucionItem item) {
    final previo = _previo(item);
    if (previo == null) return 'Sin base para comparar 30 dias.';
    final dAlertas = item.alertasAltas - previo.alertasAltas;
    final dRiesgo = item.estudiantesEnRiesgo - previo.estudiantesEnRiesgo;
    final dEvalAbiertas =
        item.evaluacionesAbiertas - previo.evaluacionesAbiertas;
    final dPendientes = item.contenidosPendientes - previo.contenidosPendientes;
    return 'Vs 30 dias: alertas altas ${_delta(dAlertas)} | riesgo ${_delta(dRiesgo)} | eval abiertas ${_delta(dEvalAbiertas)} | contenidos pendientes ${_delta(dPendientes)}';
  }

  Future<void> _copiarResumen() async {
    if (_items.isEmpty) return;
    final buffer = StringBuffer();
    buffer.writeln(
      'Dashboard ejecutivo - ${_fechaLarga(widget.fechaReferencia)}',
    );
    for (final i in _items) {
      buffer.writeln(
        '- ${i.institucion}: ${_labelSemaforo(i.semaforo)} | ${i.resumen}',
      );
      buffer.writeln('  ${_resumenTendencia(i)}');
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString().trim()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resumen del dashboard copiado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados();
    return AlertDialog(
      title: const Text('Dashboard ejecutivo'),
      content: SizedBox(
        width: _anchoDialogo(context, 980),
        height: _altoDialogo(context, 660),
        child: _cargando
            ? const EstadoListaCargando(mensaje: 'Calculando dashboard...')
            : Column(
                children: [
                  _bloqueDescripcionFuncion(context, 'dashboard'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('Fecha: ${_fechaLarga(widget.fechaReferencia)}'),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<String>(
                          initialValue: _filtroSemaforo,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Semaforo',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'todos',
                              child: Text('Todos'),
                            ),
                            DropdownMenuItem(
                              value: 'rojo',
                              child: Text('Rojo'),
                            ),
                            DropdownMenuItem(
                              value: 'amarillo',
                              child: Text('Amarillo'),
                            ),
                            DropdownMenuItem(
                              value: 'verde',
                              child: Text('Verde'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _filtroSemaforo = v);
                          },
                        ),
                      ),
                      Chip(label: Text('Rojo: ${_contar('rojo')}')),
                      Chip(label: Text('Amarillo: ${_contar('amarillo')}')),
                      Chip(label: Text('Verde: ${_contar('verde')}')),
                      IconButton(
                        tooltip: 'Recargar',
                        onPressed: _cargar,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: filtrados.isEmpty
                        ? const EstadoListaVacia(
                            titulo: 'No hay instituciones para mostrar',
                            icono: Icons.dashboard_outlined,
                          )
                        : ListView.separated(
                            itemCount: filtrados.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, idx) {
                              final i = filtrados[idx];
                              final color = _colorSemaforo(i.semaforo);
                              return Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor: color.withValues(
                                              alpha: 0.2,
                                            ),
                                            child: Text(
                                              _labelSemaforo(
                                                i.semaforo,
                                              ).substring(0, 1),
                                              style: TextStyle(color: color),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              i.institucion,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleSmall,
                                            ),
                                          ),
                                          Text(
                                            _labelSemaforo(i.semaforo),
                                            style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(i.resumen),
                                      const SizedBox(height: 4),
                                      Text(
                                        _resumenTendencia(i),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
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
        OutlinedButton.icon(
          onPressed: _items.isEmpty ? null : _copiarResumen,
          icon: const Icon(Icons.copy_all_outlined),
          label: const Text('Copiar resumen'),
        ),
      ],
    );
  }
}
