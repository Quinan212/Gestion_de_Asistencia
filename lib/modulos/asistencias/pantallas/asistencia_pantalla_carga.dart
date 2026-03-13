part of 'asistencia_pantalla.dart';

extension _AsistenciaPantallaCarga on _AsistenciaPantallaState {
  Future<void> _cargarInicial({bool silencioso = false}) async {
    _fechaAgenda = _soloFecha(DateTime.now());
    final conservarVista =
        silencioso &&
        (_cursos.isNotEmpty || _clases.isNotEmpty || _planilla.isNotEmpty);
    _actualizarEstado(() {
      _cargandoInicial = !conservarVista;
      _sincronizando = conservarVista;
      if (!conservarVista) {
        _error = null;
      }
    });

    try {
      final cursos = await Proveedores.cursosRepositorio.listar();
      int? cursoId;

      if (cursos.isNotEmpty) {
        final sp = await SharedPreferences.getInstance();
        final guardado = sp.getInt(_AsistenciaPantallaState._prefCursoKey);

        if (guardado != null && cursos.any((c) => c.id == guardado)) {
          cursoId = guardado;
        } else {
          cursoId = cursos.first.id;
        }
      }

      if (!mounted) return;
      _actualizarEstado(() {
        _cursos = cursos;
        _cursoId = cursoId;
        _cargandoInicial = false;
        _sincronizando = false;
      });

      await _cargarAgendaIntegrada();

      if (cursoId != null) {
        await _cargarClases(cursoId, seleccionarClaseId: _claseId);
      }
    } catch (_) {
      if (!mounted) return;
      _actualizarEstado(() {
        if (!conservarVista) {
          _error = 'No se pudieron cargar los datos de asistencia';
        }
        _cargandoInicial = false;
        _sincronizando = false;
      });
    }
  }

  Future<void> _guardarCursoSeleccionado(int cursoId) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_AsistenciaPantallaState._prefCursoKey, cursoId);
  }

  Future<void> _cambiarCurso(int? cursoId) async {
    if (cursoId == null || cursoId == _cursoId) return;

    _actualizarEstado(() {
      _cursoId = cursoId;
      _claseId = null;
      _claseDetalleId = null;
      _alumnoDetalleId = null;
      _clases = const [];
      _planilla = const [];
      _error = null;
    });
    _sincronizarFormularioClase(null);
    _sincronizarFormularioAlumno(null);

    await _guardarCursoSeleccionado(cursoId);
    await _cargarClases(cursoId);
  }

  Future<void> _cargarClases(int cursoId, {int? seleccionarClaseId}) async {
    _actualizarEstado(() {
      _cargandoClases = true;
      _error = null;
    });

    try {
      final clases = await Proveedores.asistenciasRepositorio
          .listarClasesDeCurso(cursoId);

      int? claseId = seleccionarClaseId;
      if (claseId == null || !clases.any((c) => c.id == claseId)) {
        claseId = clases.isEmpty ? null : clases.first.id;
      }

      if (!mounted) return;
      _actualizarEstado(() {
        _clases = clases;
        _claseId = claseId;
        if (_claseDetalleId == null ||
            !clases.any((c) => c.id == _claseDetalleId)) {
          _claseDetalleId = claseId;
        }
        _cargandoClases = false;
      });
      _sincronizarFormularioClase(_claseSeleccionadaActual());

      if (claseId != null) {
        await _cargarPlanilla(cursoId: cursoId, claseId: claseId);
      } else {
        _actualizarEstado(() => _planilla = const []);
      }
    } catch (_) {
      if (!mounted) return;
      _actualizarEstado(() {
        _error = 'No se pudieron cargar las clases';
        _cargandoClases = false;
      });
    }
  }

  Future<void> _cargarPlanilla({
    required int cursoId,
    required int claseId,
  }) async {
    _actualizarEstado(() {
      _cargandoPlanilla = true;
      _error = null;
    });

    try {
      final planilla = await Proveedores.asistenciasRepositorio
          .cargarPlanillaClase(cursoId: cursoId, claseId: claseId);

      if (!mounted) return;
      _actualizarEstado(() {
        _planilla = planilla;
        _cargandoPlanilla = false;
        if (_alumnoDetalleId != null &&
            !planilla.any((r) => r.alumno.id == _alumnoDetalleId)) {
          _alumnoDetalleId = null;
        }
      });
      _sincronizarFormularioAlumno(_registroDetalleActual());
    } catch (_) {
      if (!mounted) return;
      _actualizarEstado(() {
        _error = 'No se pudo cargar la planilla de asistencia';
        _cargandoPlanilla = false;
      });
    }
  }

  Future<void> _seleccionarClase(int claseId) async {
    final cursoId = _cursoId;
    if (cursoId == null) return;
    if (claseId == _claseId) {
      _actualizarEstado(() {
        _claseDetalleId = claseId;
        _alumnoDetalleId = null;
      });
      _sincronizarFormularioClase(_claseSeleccionadaActual());
      _sincronizarFormularioAlumno(null);
      return;
    }

    _actualizarEstado(() {
      _claseId = claseId;
      _claseDetalleId = claseId;
      _planilla = const [];
      _alumnoDetalleId = null;
    });
    _sincronizarFormularioClase(_claseSeleccionadaActual());
    _sincronizarFormularioAlumno(null);
    await _cargarPlanilla(cursoId: cursoId, claseId: claseId);
  }

  void _seleccionarAlumnoDetalle(int alumnoId) {
    _actualizarEstado(() {
      _claseDetalleId = _claseId;
      _alumnoDetalleId = alumnoId;
    });
    _sincronizarFormularioClase(_claseSeleccionadaActual());
    _sincronizarFormularioAlumno(_registroDetalleActual());
  }
}
