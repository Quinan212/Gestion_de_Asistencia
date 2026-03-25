part of 'asistencia_pantalla.dart';

extension _AsistenciaPantallaAgenda on _AsistenciaPantallaState {
  Future<void> _cargarAgendaIntegrada() async {
    _actualizarEstado(() => _cargandoAgenda = true);
    try {
      final resultado = await Future.wait<dynamic>([
        Proveedores.agendaDocenteRepositorio.listarAgendaDia(_fechaAgenda),
        Proveedores.agendaDocenteRepositorio.listarAlertasAutomaticas(
          _fechaAgenda,
        ),
      ]);
      if (!mounted) return;
      _actualizarEstado(() {
        _agendaDia = resultado[0] as List<AgendaDocenteItem>;
        _alertasAgenda = resultado[1] as List<AlertaAutomaticaDocente>;
        _cargandoAgenda = false;
      });
    } catch (_) {
      if (!mounted) return;
      _actualizarEstado(() {
        _agendaDia = const [];
        _alertasAgenda = const [];
        _cargandoAgenda = false;
      });
    }
  }

  AgendaDocenteItem? _agendaCursoSeleccionado() {
    final cursoId = _cursoId;
    if (cursoId == null) return null;
    for (final item in _agendaDia) {
      if (item.cursoId == cursoId) return item;
    }
    return null;
  }

  int _puntajeRiesgoAgendaCurso(AgendaDocenteItem item) {
    var puntaje = 0;
    if (item.alumnosPendientes >= 6) {
      puntaje += 2;
    } else if (item.alumnosPendientes >= 3) {
      puntaje += 1;
    }
    if (item.actividadesSinEntregar >= 8) {
      puntaje += 2;
    } else if (item.actividadesSinEntregar >= 4) {
      puntaje += 1;
    }
    if (item.trabajosSinCorregir >= 10) {
      puntaje += 2;
    } else if (item.trabajosSinCorregir >= 5) {
      puntaje += 1;
    }
    final alertasAltas = _alertasAgenda
        .where((a) => a.cursoId == item.cursoId && a.severidad == 'alta')
        .length;
    final alertasMedias = _alertasAgenda
        .where((a) => a.cursoId == item.cursoId && a.severidad == 'media')
        .length;
    puntaje += (alertasAltas * 2) + alertasMedias;
    return puntaje;
  }

  String _nivelRiesgoAgendaCurso(AgendaDocenteItem item) {
    final puntaje = _puntajeRiesgoAgendaCurso(item);
    if (puntaje >= 6) return 'alto';
    if (puntaje >= 3) return 'medio';
    return 'bajo';
  }

  Color _colorRiesgoAgenda(BuildContext context, String nivel) {
    switch (nivel.trim().toLowerCase()) {
      case 'alto':
        return Colors.red.shade700;
      case 'medio':
        return Colors.orange.shade700;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _etiquetaCursoAlertaAgenda(int? cursoId) {
    if (cursoId == null) return 'Curso general';
    for (final item in _agendaDia) {
      if (item.cursoId == cursoId) {
        return '${item.materia} (${item.etiquetaCurso})';
      }
    }
    return 'Curso #$cursoId';
  }

  Future<void> _posponerAlertaAgenda(
    AlertaAutomaticaDocente alerta,
    Duration duracion,
  ) async {
    if (_alertasAgendaPosponiendo.contains(alerta.clave)) return;
    _actualizarEstado(() => _alertasAgendaPosponiendo.add(alerta.clave));
    try {
      await Proveedores.agendaDocenteRepositorio.posponerAlerta(
        clave: alerta.clave,
        duracion: duracion,
      );
      await _cargarAgendaIntegrada();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Alerta pospuesta por ${duracion.inDays == 0 ? '24 horas' : '${duracion.inDays} dias'}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        _actualizarEstado(() => _alertasAgendaPosponiendo.remove(alerta.clave));
      }
    }
  }

  Widget _panelAlertasAgendaAsistencias({bool expandidoCompleto = false}) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Notificaciones',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Recargar',
                  onPressed: _cargandoAgenda ? null : _cargarAgendaIntegrada,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            Text(
              'Alertas del dia para seguimiento rapido.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            if (_cargandoAgenda)
              const EstadoListaCargando(mensaje: 'Cargando alertas...')
            else if (_alertasAgenda.isEmpty)
              const EstadoListaVacia(
                titulo: 'No hay alertas activas',
                icono: Icons.task_alt_outlined,
              )
            else
              ListView.separated(
                shrinkWrap: expandidoCompleto,
                physics: expandidoCompleto
                    ? const NeverScrollableScrollPhysics()
                    : null,
                itemCount: _alertasAgenda.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final alerta = _alertasAgenda[index];
                  final posponiendo = _alertasAgendaPosponiendo.contains(
                    alerta.clave,
                  );
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '[${alerta.severidad}] ${alerta.mensaje}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${alerta.institucion ?? 'Sin institucion'} | ${_etiquetaCursoAlertaAgenda(alerta.cursoId)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: PopupMenuButton<int>(
                      enabled: !posponiendo,
                      tooltip: 'Posponer alerta',
                      onSelected: (value) {
                        if (value == 1) {
                          _posponerAlertaAgenda(
                            alerta,
                            const Duration(hours: 24),
                          );
                        } else if (value == 3) {
                          _posponerAlertaAgenda(
                            alerta,
                            const Duration(days: 3),
                          );
                        } else if (value == 7) {
                          _posponerAlertaAgenda(
                            alerta,
                            const Duration(days: 7),
                          );
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 1, child: Text('Posponer 24h')),
                        PopupMenuItem(value: 3, child: Text('Posponer 3 dias')),
                        PopupMenuItem(value: 7, child: Text('Posponer 7 dias')),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: posponiendo
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.snooze_outlined),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _panelContextoAgendaCursoActual() {
    final item = _agendaCursoSeleccionado();
    if (item == null) return const SizedBox.shrink();

    final nivel = _nivelRiesgoAgendaCurso(item);
    final color = _colorRiesgoAgenda(context, nivel);
    final ultimaClase = item.ultimaClaseFecha == null
        ? 'Sin clase previa registrada'
        : _fechaClase(item.ultimaClaseFecha!);
    final proximaEvaluacion = item.proximaEvaluacionFecha == null
        ? 'Sin evaluacion proxima'
        : '${_fechaClase(item.proximaEvaluacionFecha!)}${(item.proximaEvaluacion ?? '').trim().isEmpty ? '' : ' · ${item.proximaEvaluacion}'}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories_outlined, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Contexto docente del curso seleccionado',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ultima clase: $ultimaClase'
            '${(item.temaClasePasada ?? '').trim().isEmpty ? '' : ' · ${item.temaClasePasada}'}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Continuar hoy: ${item.continuarHoy.trim().isEmpty ? 'Sin indicacion cargada' : item.continuarHoy.trim()}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Pendientes: ${item.alumnosPendientes} alumnos | Entregas: ${item.actividadesSinEntregar} | Sin corregir: ${item.trabajosSinCorregir}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Proxima evaluacion: $proximaEvaluacion',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
