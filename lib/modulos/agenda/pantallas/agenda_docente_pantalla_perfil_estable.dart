part of 'agenda_docente_pantalla.dart';

class _DialogPerfilEstableCurso extends StatefulWidget {
  final int cursoId;
  final String tituloCurso;

  const _DialogPerfilEstableCurso({
    required this.cursoId,
    required this.tituloCurso,
  });

  @override
  State<_DialogPerfilEstableCurso> createState() =>
      _DialogPerfilEstableCursoState();
}

class _DialogPerfilEstableCursoState extends State<_DialogPerfilEstableCurso> {
  final _ritmoCtrl = TextEditingController();
  final _climaCtrl = TextEditingController();
  final _estrategiasCtrl = TextEditingController();
  final _dificultadesCtrl = TextEditingController();
  final _autonomiaCtrl = TextEditingController();

  bool _cargando = true;
  bool _guardando = false;
  bool _huboCambios = false;
  PerfilEstableCurso? _perfil;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _ritmoCtrl.dispose();
    _climaCtrl.dispose();
    _estrategiasCtrl.dispose();
    _dificultadesCtrl.dispose();
    _autonomiaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final perfil = await Proveedores.agendaDocenteRepositorio
        .obtenerPerfilEstableCurso(widget.cursoId);
    if (!mounted) return;
    setState(() {
      _perfil = perfil;
      _ritmoCtrl.text = perfil.ritmo;
      _climaCtrl.text = perfil.clima;
      _estrategiasCtrl.text = perfil.estrategiasFuncionan;
      _dificultadesCtrl.text = perfil.dificultadesFrecuentes;
      _autonomiaCtrl.text = perfil.autonomia;
      _cargando = false;
    });
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    setState(() => _guardando = true);
    await Proveedores.agendaDocenteRepositorio.guardarPerfilEstableCurso(
      cursoId: widget.cursoId,
      ritmo: _ritmoCtrl.text,
      clima: _climaCtrl.text,
      estrategiasFuncionan: _estrategiasCtrl.text,
      dificultadesFrecuentes: _dificultadesCtrl.text,
      autonomia: _autonomiaCtrl.text,
    );
    _huboCambios = true;
    await _cargar();
    if (mounted) {
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil estable actualizado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _perfil;
    return AlertDialog(
      title: _tituloDialogoCurso('Perfil estable', widget.tituloCurso),
      content: SizedBox(
        width: _anchoDialogo(context, 900),
        height: _altoDialogo(context, 680),
        child: _cargando || p == null
            ? const EstadoListaCargando(mensaje: 'Cargando perfil...')
            : Column(
                children: [
                  _bloqueDescripcionFuncion(context, 'perfil'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          'Asistencia historica: ${p.asistenciaHistorica.toStringAsFixed(1)}%',
                        ),
                      ),
                      Chip(
                        label: Text(
                          'Riesgo A/M/B: ${p.alumnosRiesgoAlto}/${p.alumnosRiesgoMedio}/${p.alumnosRiesgoBajo}',
                        ),
                      ),
                      Chip(
                        label: Text(
                          'Inasistencias reiteradas: ${p.inasistenciasReiteradas}',
                        ),
                      ),
                      if (p.actualizadoEn != null)
                        Chip(
                          label: Text(
                            'Actualizado: ${_fechaHora(p.actualizadoEn!)}',
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: _ritmoCtrl,
                            minLines: 1,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Ritmo del grupo',
                              hintText:
                                  'Ej: sostenido con necesidad de repaso en lectura',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _climaCtrl,
                            minLines: 1,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Clima de curso',
                              hintText:
                                  'Ej: participativo pero disperso al inicio',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _estrategiasCtrl,
                            minLines: 2,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Estrategias que mejor funcionan',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _dificultadesCtrl,
                            minLines: 2,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Dificultades frecuentes',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _autonomiaCtrl,
                            minLines: 1,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Nivel de autonomia',
                              hintText:
                                  'Ej: medio, con autonomia creciente en trabajos guiados',
                            ),
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
          onPressed: _guardando ? null : _guardar,
          icon: const Icon(Icons.save_outlined),
          label: Text(_guardando ? 'Guardando...' : 'Guardar perfil'),
        ),
      ],
    );
  }
}
