part of 'asistencia_pantalla.dart';

extension _AsistenciaPantallaClasesAcciones on _AsistenciaPantallaState {
  Future<void> _crearClase() async {
    final cursoId = _cursoId;
    if (cursoId == null || _guardando) return;
    final inscriptos = await Proveedores.cursosRepositorio
        .contarInscritosActivos(cursoId);
    final horariosCurso = await Proveedores.agendaDocenteRepositorio
        .listarHorariosCurso(cursoId);
    if (!mounted) return;
    if (inscriptos <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este curso no tiene alumnos inscriptos. Ve a Cursos para inscribir.',
          ),
        ),
      );
      return;
    }

    final temaCtrl = TextEditingController();
    DateTime fechaSeleccionada = _soloFecha(DateTime.now());
    bool inicializarPendientes = true;
    HorarioCurso? horarioSeleccionado = _resolverHorarioPredeterminado(
      _horariosDelCursoParaFecha(horariosCurso, fechaSeleccionada),
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final horariosDelDia = _horariosDelCursoParaFecha(
              horariosCurso,
              fechaSeleccionada,
            );
            final horarioSeleccionadoActual = _resolverHorarioPredeterminado(
              horariosDelDia,
              horarioIdPreferido: horarioSeleccionado?.id,
            );
            horarioSeleccionado = horarioSeleccionadoActual;

            return AlertDialog(
              title: const Text('Nueva clase'),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today_outlined),
                        title: const Text('Fecha de clase'),
                        subtitle: Text(_fechaClase(fechaSeleccionada)),
                        trailing: TextButton(
                          onPressed: () async {
                            final hoy = _soloFecha(DateTime.now());
                            final elegida = await showDatePicker(
                              context: context,
                              initialDate: fechaSeleccionada,
                              firstDate: DateTime(hoy.year - 3, 1, 1),
                              lastDate: DateTime(hoy.year + 5, 12, 31),
                            );
                            if (elegida == null) return;
                            setStateDialog(() {
                              fechaSeleccionada = _soloFecha(elegida);
                              horarioSeleccionado =
                                  _resolverHorarioPredeterminado(
                                    _horariosDelCursoParaFecha(
                                      horariosCurso,
                                      fechaSeleccionada,
                                    ),
                                    horarioIdPreferido: horarioSeleccionado?.id,
                                  );
                            });
                          },
                          child: const Text('Cambiar'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (horariosCurso.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                          ),
                          child: const Text(
                            'Este curso no tiene horarios cargados. La clase se creara solo con fecha.',
                          ),
                        )
                      else if (horariosDelDia.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                          ),
                          child: Text(
                            'No hay horario cargado para ${_labelDiaSemana(fechaSeleccionada.weekday)}. La clase se creara sin bloque horario.',
                          ),
                        )
                      else if (horariosDelDia.length == 1)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.schedule_outlined),
                          title: const Text('Horario vinculado'),
                          subtitle: Text(
                            _labelHorarioCurso(horariosDelDia.first),
                          ),
                        )
                      else
                        DropdownButtonFormField<int>(
                          initialValue: horarioSeleccionadoActual?.id,
                          decoration: const InputDecoration(
                            labelText: 'Bloque horario del dia',
                            prefixIcon: Icon(Icons.schedule_outlined),
                          ),
                          items: horariosDelDia
                              .map(
                                (horario) => DropdownMenuItem<int>(
                                  value: horario.id,
                                  child: Text(_labelHorarioCurso(horario)),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            setStateDialog(() {
                              horarioSeleccionado =
                                  _resolverHorarioPredeterminado(
                                    horariosDelDia,
                                    horarioIdPreferido: value,
                                  );
                            });
                          },
                        ),
                      if (horariosCurso.isNotEmpty) const SizedBox(height: 8),
                      TextField(
                        controller: temaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Tema (opcional)',
                          hintText: 'Ej: Repaso de fracciones',
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Inicializar en "Pendiente"'),
                        subtitle: const Text(
                          'Crea asistencia para todos sin marcarlos como presentes.',
                        ),
                        value: inicializarPendientes,
                        onChanged: (v) =>
                            setStateDialog(() => inicializarPendientes = v),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true || !mounted) {
      temaCtrl.dispose();
      return;
    }

    _actualizarEstado(() => _guardando = true);
    try {
      final claseId = await Proveedores.asistenciasRepositorio.crearClase(
        cursoId: cursoId,
        fecha: fechaSeleccionada,
        tema: temaCtrl.text,
        horario: horarioSeleccionado,
      );

      if (inicializarPendientes) {
        await Proveedores.asistenciasRepositorio.marcarEstadoParaTodos(
          claseId: claseId,
          cursoId: cursoId,
          estado: EstadoAsistencia.pendiente,
        );
      }

      if (!mounted) return;

      await _cargarClases(cursoId, seleccionarClaseId: claseId);
      Proveedores.notificarDatosActualizados(
        mensaje: inicializarPendientes
            ? 'Clase del ${_fechaClase(fechaSeleccionada)} creada en pendiente'
            : 'Clase del ${_fechaClase(fechaSeleccionada)} creada',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo crear la clase')),
      );
    } finally {
      temaCtrl.dispose();
      if (mounted) _actualizarEstado(() => _guardando = false);
    }
  }

  Future<void> _cambiarEstadoAlumno({
    required int alumnoId,
    required EstadoAsistencia estado,
  }) async {
    final claseId = _claseId;
    if (claseId == null || _guardando) return;

    final index = _planilla.indexWhere((x) => x.alumno.id == alumnoId);
    if (index < 0) return;

    final previo = _planilla[index];
    if (previo.estado == estado) return;
    final siguiente = previo.copyWith(
      estado: estado,
      justificada: estado == EstadoAsistencia.presente
          ? false
          : previo.justificada,
      detalleJustificacion: estado == EstadoAsistencia.presente
          ? ''
          : (previo.detalleJustificacion ?? ''),
    );

    _actualizarEstado(() {
      _planilla = List<RegistroAsistenciaAlumno>.from(_planilla)
        ..[index] = siguiente;
      if (_alumnoDetalleId == alumnoId && estado == EstadoAsistencia.presente) {
        _justificadaFormulario = false;
        _detalleJustificacionCtrl.text = '';
      }
    });

    try {
      await Proveedores.asistenciasRepositorio.registrarEstadoAsistencia(
        claseId: claseId,
        alumnoId: alumnoId,
        estado: estado,
      );
      if (estado == EstadoAsistencia.presente) {
        await Proveedores.asistenciasRepositorio.guardarDetalleAlumnoClase(
          claseId: claseId,
          alumnoId: alumnoId,
          estadoActual: estado,
          justificada: false,
          detalleJustificacion: '',
          actividadEntregada: previo.actividadEntregada,
          notaActividad: previo.notaActividad,
          detalleActividad: previo.detalleActividad,
        );
      }
    } catch (_) {
      if (!mounted) return;
      _actualizarEstado(() {
        _planilla = List<RegistroAsistenciaAlumno>.from(_planilla)
          ..[index] = previo;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar asistencia')),
      );
    }
  }

  Future<void> _marcarTodos(EstadoAsistencia estado) async {
    final cursoId = _cursoId;
    final claseId = _claseId;
    if (cursoId == null || claseId == null || _guardando) return;

    _actualizarEstado(() => _guardando = true);
    try {
      await Proveedores.asistenciasRepositorio.marcarEstadoParaTodos(
        claseId: claseId,
        cursoId: cursoId,
        estado: estado,
      );

      if (!mounted) return;
      _actualizarEstado(() {
        _planilla = _planilla
            .map((r) => r.copyWith(estado: estado))
            .toList(growable: false);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo aplicar la actualizacion general'),
        ),
      );
    } finally {
      if (mounted) _actualizarEstado(() => _guardando = false);
    }
  }

  Future<void> _aplicarSelectorMasivo(EstadoAsistencia? estado) async {
    if (estado == null) return;
    await _marcarTodos(estado);
    if (!mounted) return;
    _actualizarEstado(() {
      _selectorMasivoVersion++;
    });
  }

  Future<void> _eliminarClase(int claseId) async {
    ClaseAsistencia? clase;
    for (final item in _clases) {
      if (item.id == claseId) {
        clase = item;
        break;
      }
    }
    if (clase == null || _guardando) return;
    final claseActual = clase;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Eliminar clase'),
        content: Text(
          'Se eliminara la clase del ${_fechaClase(claseActual.fecha)}'
          '${(claseActual.tema ?? '').trim().isEmpty ? '' : ' (${claseActual.tema})'}'
          '. Tambien se borrara toda su asistencia asociada.',
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

    final cursoId = _cursoId;
    if (cursoId == null) return;

    _actualizarEstado(() => _guardando = true);
    try {
      await Proveedores.asistenciasRepositorio.eliminarClase(claseId);
      if (!mounted) return;
      _actualizarEstado(() {
        if (_claseId == claseId) {
          _claseId = null;
          _claseDetalleId = null;
          _alumnoDetalleId = null;
          _planilla = const [];
        }
      });
      await _cargarClases(cursoId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Clase eliminada')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar la clase')),
      );
    } finally {
      if (mounted) _actualizarEstado(() => _guardando = false);
    }
  }

  String _d2(int n) => n.toString().padLeft(2, '0');

  DateTime _soloFecha(DateTime f) => DateTime(f.year, f.month, f.day);

  String _fechaClase(DateTime f) {
    return '${_d2(f.day)}/${_d2(f.month)}/${f.year}';
  }
}
