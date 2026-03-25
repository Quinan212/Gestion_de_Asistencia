part of 'asistencia_pantalla.dart';

extension _AsistenciaPantallaDetalles on _AsistenciaPantallaState {
  List<HorarioCurso> _horariosDelCursoParaFecha(
    List<HorarioCurso> horarios,
    DateTime fecha,
  ) {
    final filtrados = horarios
        .where((horario) => horario.diaSemana == fecha.weekday)
        .toList(growable: false);
    filtrados.sort((a, b) {
      final cmpInicio = a.horaInicio.compareTo(b.horaInicio);
      if (cmpInicio != 0) return cmpInicio;
      return a.id.compareTo(b.id);
    });
    return filtrados;
  }

  HorarioCurso? _resolverHorarioPredeterminado(
    List<HorarioCurso> horarios, {
    int? horarioIdPreferido,
  }) {
    if (horarios.isEmpty) return null;
    if (horarioIdPreferido != null) {
      for (final horario in horarios) {
        if (horario.id == horarioIdPreferido) return horario;
      }
    }
    return horarios.first;
  }

  String _labelDiaSemana(int diaSemana) {
    switch (diaSemana) {
      case DateTime.monday:
        return 'Lunes';
      case DateTime.tuesday:
        return 'Martes';
      case DateTime.wednesday:
        return 'Miercoles';
      case DateTime.thursday:
        return 'Jueves';
      case DateTime.friday:
        return 'Viernes';
      case DateTime.saturday:
        return 'Sabado';
      case DateTime.sunday:
      default:
        return 'Domingo';
    }
  }

  String _labelHorarioCurso(HorarioCurso horario) {
    final aula = (horario.aula ?? '').trim();
    final partes = <String>[_labelDiaSemana(horario.diaSemana), horario.franja];
    if (aula.isNotEmpty) {
      partes.add(aula);
    }
    return partes.join(' | ');
  }

  String? _resumenHorarioClase(ClaseAsistencia clase) {
    final franja = clase.franjaHoraria;
    final aula = (clase.aula ?? '').trim();
    if (franja == null && aula.isEmpty) return null;
    if (franja == null) return aula;
    if (aula.isEmpty) return franja;
    return '$franja | $aula';
  }

  String _subtituloClase(ClaseAsistencia clase) {
    final horario = _resumenHorarioClase(clase);
    final tema = (clase.tema ?? '').trim();
    final partes = <String>[];
    if (horario != null) {
      partes.add(horario);
    }
    if (tema.isNotEmpty) {
      partes.add(tema);
    }
    if (partes.isEmpty) return 'Sin tema cargado';
    return partes.join(' | ');
  }

  void _sincronizarFormularioClase(
    ClaseAsistencia? clase, {
    bool forzar = false,
  }) {
    if (clase == null) {
      _claseFormularioId = null;
      _editandoDetalleClase = false;
      _temaClaseCtrl.text = '';
      _descripcionClaseCtrl.text = '';
      _actividadClaseCtrl.text = '';
      _estadoContenidoClase = 'parcial';
      _resultadoActividadClase = 'regular';
      return;
    }
    if (_claseFormularioId == clase.id && !forzar) return;
    _claseFormularioId = clase.id;
    _editandoDetalleClase = false;
    _temaClaseCtrl.text = clase.tema ?? '';
    _descripcionClaseCtrl.text = clase.observacion ?? '';
    _actividadClaseCtrl.text = clase.actividadDia ?? '';
    _estadoContenidoClase = _normalizarEstadoContenidoClase(
      clase.estadoContenido,
    );
    _resultadoActividadClase = _normalizarResultadoActividadClase(
      clase.resultadoActividad,
    );
  }

  void _sincronizarFormularioAlumno(
    RegistroAsistenciaAlumno? registro, {
    bool forzar = false,
  }) {
    if (registro == null) {
      _alumnoFormularioId = null;
      _editandoDetalleAlumno = false;
      _justificadaFormulario = false;
      _actividadEntregadaFormulario = false;
      _detalleJustificacionCtrl.text = '';
      _notaActividadCtrl.text = '';
      _detalleActividadCtrl.text = '';
      return;
    }
    if (_alumnoFormularioId == registro.alumno.id && !forzar) return;
    _alumnoFormularioId = registro.alumno.id;
    _editandoDetalleAlumno = false;
    _justificadaFormulario = registro.estado == EstadoAsistencia.presente
        ? false
        : registro.justificada;
    _actividadEntregadaFormulario = registro.actividadEntregada;
    _detalleJustificacionCtrl.text = registro.detalleJustificacion ?? '';
    _notaActividadCtrl.text = registro.notaActividad ?? '';
    _detalleActividadCtrl.text = registro.detalleActividad ?? '';
  }

  Future<void> _guardarDetalleClase() async {
    final claseId = _claseDetalleId;
    final cursoId = _cursoId;
    if (claseId == null || cursoId == null || _guardandoDetalleClase) return;

    _actualizarEstado(() => _guardandoDetalleClase = true);
    try {
      await Proveedores.asistenciasRepositorio.actualizarDetalleClase(
        claseId: claseId,
        tema: _temaClaseCtrl.text,
        descripcionTema: _descripcionClaseCtrl.text,
        actividadDia: _actividadClaseCtrl.text,
        estadoContenido: _estadoContenidoClase,
        resultadoActividad: _resultadoActividadClase,
      );
      if (!mounted) return;
      await _cargarClases(cursoId, seleccionarClaseId: claseId);
      if (!mounted) return;
      _actualizarEstado(() => _editandoDetalleClase = false);
      Proveedores.notificarDatosActualizados(
        mensaje: 'Detalle de clase actualizado',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el detalle de clase')),
      );
    } finally {
      if (mounted) _actualizarEstado(() => _guardandoDetalleClase = false);
    }
  }

  String _normalizarEstadoContenidoClase(String? valor) {
    final v = (valor ?? '').trim().toLowerCase();
    if (v == 'completado' || v == 'parcial' || v == 'reprogramado') return v;
    return 'parcial';
  }

  String _normalizarResultadoActividadClase(String? valor) {
    final v = (valor ?? '').trim().toLowerCase();
    if (v == 'bien' || v == 'regular' || v == 'mal') return v;
    return 'regular';
  }

  Future<void> _guardarDetalleAlumno() async {
    final registro = _registroDetalleActual();
    final claseId = _claseId;
    final cursoId = _cursoId;
    if (registro == null ||
        claseId == null ||
        cursoId == null ||
        _guardandoDetalleAlumno) {
      return;
    }

    final principalEsPresente = registro.estado == EstadoAsistencia.presente;
    final justificadaFinal = principalEsPresente
        ? false
        : _justificadaFormulario;
    final detalleJustificacionFinal = justificadaFinal
        ? _detalleJustificacionCtrl.text
        : '';

    _actualizarEstado(() => _guardandoDetalleAlumno = true);
    try {
      await Proveedores.asistenciasRepositorio.guardarDetalleAlumnoClase(
        claseId: claseId,
        alumnoId: registro.alumno.id,
        estadoActual: registro.estado,
        justificada: justificadaFinal,
        detalleJustificacion: detalleJustificacionFinal,
        actividadEntregada: _actividadEntregadaFormulario,
        notaActividad: _notaActividadCtrl.text,
        detalleActividad: _detalleActividadCtrl.text,
      );
      if (!mounted) return;
      await _cargarPlanilla(cursoId: cursoId, claseId: claseId);
      if (!mounted) return;
      _actualizarEstado(() => _editandoDetalleAlumno = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Detalle del alumno actualizado')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar el detalle del alumno'),
        ),
      );
    } finally {
      if (mounted) _actualizarEstado(() => _guardandoDetalleAlumno = false);
    }
  }

  Future<void> _cargarFotoAlumno(RegistroAsistenciaAlumno registro) async {
    if (_guardandoDetalleAlumno || !_editandoDetalleAlumno) return;
    final xFile = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Imagenes',
          extensions: ['png', 'jpg', 'jpeg', 'webp'],
        ),
      ],
    );
    if (xFile == null) return;

    try {
      final dirDocs = await getApplicationDocumentsDirectory();
      final dirFotos = Directory(p.join(dirDocs.path, 'alumnos_fotos'));
      if (!await dirFotos.exists()) {
        await dirFotos.create(recursive: true);
      }

      final ext = p.extension(xFile.path).toLowerCase();
      final extension = ext.isEmpty ? '.jpg' : ext;
      final destino = p.join(
        dirFotos.path,
        'alumno_${registro.alumno.id}$extension',
      );
      await File(xFile.path).copy(destino);
      await Proveedores.alumnosRepositorio.actualizarFoto(
        alumnoId: registro.alumno.id,
        fotoPath: destino,
      );
      if (!mounted) return;
      final cursoId = _cursoId;
      final claseId = _claseId;
      if (cursoId != null && claseId != null) {
        await _cargarPlanilla(cursoId: cursoId, claseId: claseId);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar la foto del alumno')),
      );
    }
  }
}
