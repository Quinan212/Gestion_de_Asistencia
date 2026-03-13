part of 'agenda_docente_repositorio.dart';

extension AgendaDocenteRepositorioPendientesCronologia
    on AgendaDocenteRepositorio {
  Future<PanelPendientesAccionables> generarPanelPendientesAccionables(
    DateTime fechaReferencia, {
    String? institucion,
    int limitePendientes = 240,
  }) async {
    final cursos = await _listarCursosActivos();
    final filtroInstitucion = (institucion ?? '').trim().toLowerCase();
    final cursosFiltrados = cursos
        .where((c) {
          if (filtroInstitucion.isEmpty) return true;
          return c.institucion.trim().toLowerCase() == filtroInstitucion;
        })
        .toList(growable: false);
    final cursosPorId = <int, _CursoAgendaBase>{
      for (final c in cursosFiltrados) c.id: c,
    };
    final cursoIds = cursosPorId.keys.toList(growable: false);

    if (cursoIds.isEmpty) {
      return PanelPendientesAccionables(
        fechaReferencia: fechaReferencia,
        evaluacionesPorCerrar: 0,
        entregasPorCorregir: 0,
        alumnosEnRiesgo: 0,
        clasesIncompletas: 0,
        acuerdosAbiertos: 0,
        alertasSinRevisar: 0,
        pendientes: const [],
      );
    }

    final placeholders = List<String>.filled(cursoIds.length, '?').join(',');
    final varsCursoIds = cursoIds
        .map((id) => Variable<Object>(id))
        .toList(growable: false);

    final pendientes = <PendienteAccionableDocente>[];
    final fechaRefEpoch = fechaReferencia.millisecondsSinceEpoch ~/ 1000;
    final fechaClaseDesdeEpoch =
        fechaReferencia
            .subtract(const Duration(days: 45))
            .millisecondsSinceEpoch ~/
        1000;

    final evalRows = await _db.customSelect('''
      SELECT
        e.curso_id AS curso_id,
        e.id AS evaluacion_id,
        i.id AS evaluacion_instancia_id,
        i.fecha AS fecha,
        i.tipo_instancia AS tipo_instancia,
        i.orden AS orden,
        e.tipo AS tipo,
        e.titulo AS titulo
      FROM tabla_evaluaciones_instancia i
      INNER JOIN tabla_evaluaciones_curso e
        ON e.id = i.evaluacion_id
      WHERE e.curso_id IN ($placeholders)
        AND lower(trim(COALESCE(i.estado, 'abierta'))) <> 'cerrada'
      ORDER BY i.fecha ASC, i.id ASC
      ''', variables: varsCursoIds).get();
    final evaluacionesPorCerrar = evalRows.length;
    for (final row in evalRows) {
      final cursoId = row.read<int>('curso_id');
      final curso = cursosPorId[cursoId];
      if (curso == null) continue;
      final fecha = _fechaDesdeEpoch(row.read<int>('fecha'));
      final atrasada = fecha.isBefore(
        fechaReferencia.subtract(const Duration(days: 7)),
      );
      final tipoInstancia = _labelInstanciaInterna(
        row.read<int>('orden'),
        row.read<String>('tipo_instancia'),
      );
      pendientes.add(
        PendienteAccionableDocente(
          tipo: 'evaluacion_por_cerrar',
          prioridad: atrasada ? 'alta' : 'media',
          fecha: fecha,
          cursoId: cursoId,
          alumnoId: null,
          institucion: curso.institucion,
          materia: curso.materia,
          etiquetaCurso: curso.etiquetaCurso,
          titulo:
              'Cerrar evaluacion: ${row.read<String>('titulo')} (${row.read<String>('tipo')})',
          detalle: 'Instancia: $tipoInstancia',
          accionSugerida: 'Revisar resultados y cerrar instancia',
        ),
      );
    }

    final correccionRows = await _db.customSelect('''
      SELECT
        c.curso_id AS curso_id,
        c.id AS clase_id,
        c.fecha AS fecha,
        c.tema AS tema,
        a.alumno_id AS alumno_id,
        al.apellido AS apellido,
        al.nombre AS nombre
      FROM tabla_asistencias a
      INNER JOIN tabla_clases c
        ON c.id = a.clase_id
      INNER JOIN tabla_alumnos al
        ON al.id = a.alumno_id
      WHERE c.curso_id IN ($placeholders)
        AND a.actividad_entregada = 1
        AND trim(COALESCE(a.nota_actividad, '')) = ''
      ORDER BY c.fecha ASC, c.id ASC
      ''', variables: varsCursoIds).get();
    final entregasPorCorregir = correccionRows.length;
    for (final row in correccionRows) {
      final cursoId = row.read<int>('curso_id');
      final curso = cursosPorId[cursoId];
      if (curso == null) continue;
      final fecha = _fechaDesdeEpoch(row.read<int>('fecha'));
      final atrasada = fecha.isBefore(
        fechaReferencia.subtract(const Duration(days: 5)),
      );
      final apellido = row.read<String>('apellido').trim();
      final nombre = row.read<String>('nombre').trim();
      final alumnoNombre = apellido.isEmpty ? nombre : '$apellido, $nombre';
      final tema = (row.read<String?>('tema') ?? '').trim();
      pendientes.add(
        PendienteAccionableDocente(
          tipo: 'entrega_por_corregir',
          prioridad: atrasada ? 'alta' : 'media',
          fecha: fecha,
          cursoId: cursoId,
          alumnoId: row.read<int>('alumno_id'),
          institucion: curso.institucion,
          materia: curso.materia,
          etiquetaCurso: curso.etiquetaCurso,
          titulo: 'Corregir entrega: $alumnoNombre',
          detalle: tema.isEmpty ? 'Clase sin tema cargado' : 'Clase: $tema',
          accionSugerida: 'Cargar nota o devolucion de actividad',
        ),
      );
    }

    final claseRows = await _db
        .customSelect(
          '''
      SELECT
        c.id AS clase_id,
        c.curso_id AS curso_id,
        c.fecha AS fecha,
        c.tema AS tema,
        c.actividad_dia AS actividad_dia,
        (
          SELECT COUNT(*)
          FROM tabla_asistencias a
          WHERE a.clase_id = c.id
        ) AS registros
      FROM tabla_clases c
      WHERE c.curso_id IN ($placeholders)
        AND c.fecha BETWEEN ? AND ?
        AND (
          trim(COALESCE(c.tema, '')) = ''
          OR trim(COALESCE(c.actividad_dia, '')) = ''
          OR (
            SELECT COUNT(*)
            FROM tabla_asistencias a2
            WHERE a2.clase_id = c.id
          ) = 0
        )
      ORDER BY c.fecha DESC, c.id DESC
      ''',
          variables: [
            ...varsCursoIds,
            Variable<Object>(fechaClaseDesdeEpoch),
            Variable<Object>(fechaRefEpoch),
          ],
        )
        .get();
    final clasesIncompletas = claseRows.length;
    for (final row in claseRows) {
      final cursoId = row.read<int>('curso_id');
      final curso = cursosPorId[cursoId];
      if (curso == null) continue;
      final fecha = _fechaDesdeEpoch(row.read<int>('fecha'));
      final faltantes = <String>[];
      if ((row.read<String?>('tema') ?? '').trim().isEmpty) {
        faltantes.add('tema');
      }
      if ((row.read<String?>('actividad_dia') ?? '').trim().isEmpty) {
        faltantes.add('actividad');
      }
      if (row.read<int>('registros') == 0) {
        faltantes.add('asistencia');
      }
      final detalle = faltantes.isEmpty
          ? 'Clase con carga parcial'
          : 'Falta: ${faltantes.join(', ')}';
      pendientes.add(
        PendienteAccionableDocente(
          tipo: 'clase_incompleta',
          prioridad: faltantes.contains('asistencia') ? 'alta' : 'media',
          fecha: fecha,
          cursoId: cursoId,
          alumnoId: null,
          institucion: curso.institucion,
          materia: curso.materia,
          etiquetaCurso: curso.etiquetaCurso,
          titulo: 'Clase incompleta del ${_fechaSimpleInterna(fecha)}',
          detalle: detalle,
          accionSugerida: 'Completar bitacora y asistencia de clase',
        ),
      );
    }

    final acuerdosRows = await _db.customSelect('''
      SELECT
        curso_id,
        fecha,
        tipo,
        descripcion,
        reiterada
      FROM tabla_acuerdos_convivencia
      WHERE curso_id IN ($placeholders)
        AND resuelta = 0
      ORDER BY fecha DESC, id DESC
      ''', variables: varsCursoIds).get();
    final acuerdosAbiertos = acuerdosRows.length;
    for (final row in acuerdosRows) {
      final cursoId = row.read<int>('curso_id');
      final curso = cursosPorId[cursoId];
      if (curso == null) continue;
      final reiterada = row.read<bool>('reiterada');
      pendientes.add(
        PendienteAccionableDocente(
          tipo: 'acuerdo_abierto',
          prioridad: reiterada ? 'alta' : 'media',
          fecha: _fechaDesdeEpoch(row.read<int>('fecha')),
          cursoId: cursoId,
          alumnoId: null,
          institucion: curso.institucion,
          materia: curso.materia,
          etiquetaCurso: curso.etiquetaCurso,
          titulo: 'Acuerdo abierto: ${row.read<String>('tipo')}',
          detalle: row.read<String>('descripcion'),
          accionSugerida: 'Registrar seguimiento o marcar como resuelto',
        ),
      );
    }

    var alumnosEnRiesgo = 0;
    for (final curso in cursosFiltrados) {
      final historial = await listarHistorialInteligenteCurso(curso.id);
      for (final h in historial) {
        final riesgo = h.nivelRiesgo.trim().toLowerCase();
        if (riesgo == 'bajo') continue;
        alumnosEnRiesgo++;
        pendientes.add(
          PendienteAccionableDocente(
            tipo: 'alumno_en_riesgo',
            prioridad: riesgo == 'alto' ? 'alta' : 'media',
            fecha: fechaReferencia,
            cursoId: curso.id,
            alumnoId: h.alumnoId,
            institucion: curso.institucion,
            materia: curso.materia,
            etiquetaCurso: curso.etiquetaCurso,
            titulo: 'Seguimiento: ${h.alumnoNombre}',
            detalle: h.resumen,
            accionSugerida: 'Revisar cronologia y definir intervencion',
          ),
        );
      }
    }

    final alertas = await listarAlertasAutomaticas(
      fechaReferencia,
      limite: 600,
    );
    final cursoIdsSet = cursoIds.toSet();
    final alertasFiltradas = alertas
        .where((a) {
          if (a.cursoId == null) return filtroInstitucion.isEmpty;
          return cursoIdsSet.contains(a.cursoId);
        })
        .toList(growable: false);
    final alertasSinRevisar = alertasFiltradas.length;
    for (final a in alertasFiltradas) {
      final curso = cursosPorId[a.cursoId];
      final inst = curso?.institucion ?? (a.institucion ?? 'Sin institucion');
      final materia = curso?.materia ?? (a.materia ?? 'Sin materia');
      final etiqueta =
          curso?.etiquetaCurso ?? (a.etiquetaCurso ?? 'Curso general');
      pendientes.add(
        PendienteAccionableDocente(
          tipo: 'alerta_no_revisada',
          prioridad: _normalizarPrioridad(a.severidad),
          fecha: fechaReferencia,
          cursoId: a.cursoId,
          alumnoId: a.alumnoId,
          institucion: inst,
          materia: materia,
          etiquetaCurso: etiqueta,
          titulo: 'Alerta ${a.severidad.toUpperCase()}: ${a.tipo}',
          detalle: a.mensaje,
          accionSugerida: 'Revisar alerta y definir accion',
        ),
      );
    }

    pendientes.sort((a, b) {
      final cmpPrioridad = _pesoPrioridadPendiente(
        b.prioridad,
      ).compareTo(_pesoPrioridadPendiente(a.prioridad));
      if (cmpPrioridad != 0) return cmpPrioridad;
      final cmpFecha = b.fecha.compareTo(a.fecha);
      if (cmpFecha != 0) return cmpFecha;
      return a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
    });
    final pendientesTop = pendientes
        .take(limitePendientes)
        .toList(growable: false);

    return PanelPendientesAccionables(
      fechaReferencia: fechaReferencia,
      evaluacionesPorCerrar: evaluacionesPorCerrar,
      entregasPorCorregir: entregasPorCorregir,
      alumnosEnRiesgo: alumnosEnRiesgo,
      clasesIncompletas: clasesIncompletas,
      acuerdosAbiertos: acuerdosAbiertos,
      alertasSinRevisar: alertasSinRevisar,
      pendientes: pendientesTop,
    );
  }

  Future<List<EventoCronologicoAlumno>> listarCronologiaAlumnoCurso({
    required int cursoId,
    required int alumnoId,
    int diasAnalisis = 365,
    int limite = 320,
  }) async {
    final desdeEpoch =
        DateTime.now()
            .subtract(Duration(days: diasAnalisis))
            .millisecondsSinceEpoch ~/
        1000;
    final eventos = <EventoCronologicoAlumno>[];

    final asistenciaRows = await _db
        .customSelect(
          '''
      SELECT
        c.id AS clase_id,
        c.fecha AS fecha,
        c.tema AS tema,
        c.actividad_dia AS actividad_dia,
        c.observacion AS clase_observacion,
        a.estado AS estado,
        a.actividad_entregada AS actividad_entregada,
        a.nota_actividad AS nota_actividad,
        a.observacion AS asistencia_observacion
      FROM tabla_clases c
      LEFT JOIN tabla_asistencias a
        ON a.clase_id = c.id
       AND a.alumno_id = ?
      WHERE c.curso_id = ?
        AND c.fecha >= ?
      ORDER BY c.fecha ASC, c.id ASC
      LIMIT ?
      ''',
          variables: [
            Variable<int>(alumnoId),
            Variable<int>(cursoId),
            Variable<int>(desdeEpoch),
            Variable<int>(limite),
          ],
        )
        .get();

    final puntosAsistencia = <_PuntoAsistenciaCronologia>[];
    for (final row in asistenciaRows) {
      final estadoRaw = row.read<String?>('estado');
      if (estadoRaw == null) continue;
      final claseId = row.read<int>('clase_id');
      final fecha = _fechaDesdeEpoch(row.read<int>('fecha'));
      final estado = estadoRaw.trim().toLowerCase();
      final tema = (row.read<String?>('tema') ?? '').trim();
      final actividad = (row.read<String?>('actividad_dia') ?? '').trim();

      final ausente = estado == 'ausente' || estado == 'pendiente';
      final presente =
          estado == 'presente' || estado == 'tarde' || estado == 'justificada';
      puntosAsistencia.add(
        _PuntoAsistenciaCronologia(
          claseId: claseId,
          fecha: fecha,
          presente: presente,
          ausente: ausente,
        ),
      );

      eventos.add(
        EventoCronologicoAlumno(
          fecha: fecha,
          tipo: 'asistencia',
          titulo: ausente ? 'Inasistencia registrada' : 'Asistencia registrada',
          detalle:
              'Estado: ${_labelEstadoAsistenciaCronologia(estado)}${tema.isEmpty ? '' : ' | Tema: $tema'}${actividad.isEmpty ? '' : ' | Actividad: $actividad'}',
          prioridad: ausente ? 'alta' : 'baja',
          cursoId: cursoId,
          alumnoId: alumnoId,
          claseId: claseId,
          evaluacionId: null,
          evaluacionInstanciaId: null,
        ),
      );

      final entregada = row.read<bool>('actividad_entregada');
      final nota = (row.read<String?>('nota_actividad') ?? '').trim();
      if (entregada) {
        eventos.add(
          EventoCronologicoAlumno(
            fecha: fecha,
            tipo: 'entrega',
            titulo: 'Entrega de actividad',
            detalle: nota.isEmpty
                ? 'Entrega pendiente de correccion'
                : 'Entrega corregida con nota: $nota',
            prioridad: nota.isEmpty ? 'media' : 'baja',
            cursoId: cursoId,
            alumnoId: alumnoId,
            claseId: claseId,
            evaluacionId: null,
            evaluacionInstanciaId: null,
          ),
        );
      }

      final obsAsistencia = (row.read<String?>('asistencia_observacion') ?? '')
          .trim();
      final obsClase = (row.read<String?>('clase_observacion') ?? '').trim();
      final obs = obsAsistencia.isNotEmpty ? obsAsistencia : obsClase;
      if (obs.isNotEmpty) {
        eventos.add(
          EventoCronologicoAlumno(
            fecha: fecha,
            tipo: 'observacion',
            titulo: 'Observacion de clase',
            detalle: obs,
            prioridad: 'media',
            cursoId: cursoId,
            alumnoId: alumnoId,
            claseId: claseId,
            evaluacionId: null,
            evaluacionInstanciaId: null,
          ),
        );
      }
    }

    final mejoras = _detectarMejorasAsistenciaCronologia(puntosAsistencia);
    for (final m in mejoras) {
      eventos.add(
        EventoCronologicoAlumno(
          fecha: m.fecha,
          tipo: 'mejora',
          titulo: 'Mejora reciente de continuidad',
          detalle: 'Tres clases seguidas con asistencia positiva',
          prioridad: 'baja',
          cursoId: cursoId,
          alumnoId: alumnoId,
          claseId: m.claseId,
          evaluacionId: null,
          evaluacionInstanciaId: null,
        ),
      );
    }

    final intervencionesRows = await _db
        .customSelect(
          '''
      SELECT
        fecha,
        tipo,
        descripcion,
        seguimiento,
        resuelta
      FROM tabla_intervenciones_docentes
      WHERE alumno_id = ?
        AND (curso_id = ? OR curso_id IS NULL)
        AND fecha >= ?
      ORDER BY fecha ASC, id ASC
      LIMIT ?
      ''',
          variables: [
            Variable<int>(alumnoId),
            Variable<int>(cursoId),
            Variable<int>(desdeEpoch),
            Variable<int>(limite),
          ],
        )
        .get();
    for (final row in intervencionesRows) {
      final seguimiento = (row.read<String?>('seguimiento') ?? '').trim();
      eventos.add(
        EventoCronologicoAlumno(
          fecha: _fechaDesdeEpoch(row.read<int>('fecha')),
          tipo: 'intervencion',
          titulo: 'Intervencion: ${row.read<String>('tipo')}',
          detalle:
              '${row.read<String>('descripcion')}${seguimiento.isEmpty ? '' : ' | Seguimiento: $seguimiento'}',
          prioridad: row.read<bool>('resuelta') ? 'baja' : 'alta',
          cursoId: cursoId,
          alumnoId: alumnoId,
          claseId: null,
          evaluacionId: null,
          evaluacionInstanciaId: null,
        ),
      );
    }

    final evaluacionesRows = await _db
        .customSelect(
          '''
      SELECT
        e.id AS evaluacion_id,
        i.id AS evaluacion_instancia_id,
        i.fecha AS fecha,
        i.tipo_instancia AS tipo_instancia,
        i.orden AS orden,
        e.tipo AS tipo,
        e.titulo AS titulo,
        r.estado AS estado,
        r.calificacion AS calificacion,
        r.observacion AS observacion,
        r.ausente_justificado AS ausente_justificado
      FROM tabla_evaluaciones_alumno r
      INNER JOIN tabla_evaluaciones_instancia i
        ON i.id = r.evaluacion_instancia_id
      INNER JOIN tabla_evaluaciones_curso e
        ON e.id = i.evaluacion_id
      WHERE e.curso_id = ?
        AND r.alumno_id = ?
        AND i.fecha >= ?
      ORDER BY i.fecha ASC, i.orden ASC, i.id ASC
      LIMIT ?
      ''',
          variables: [
            Variable<int>(cursoId),
            Variable<int>(alumnoId),
            Variable<int>(desdeEpoch),
            Variable<int>(limite),
          ],
        )
        .get();
    for (final row in evaluacionesRows) {
      final estado = _normalizarEstadoEvaluacionInterno(
        row.read<String>('estado'),
      );
      final nota = (row.read<String?>('calificacion') ?? '').trim();
      final obs = (row.read<String?>('observacion') ?? '').trim();
      final ausenteJustificado = row.read<bool>('ausente_justificado');
      final instancia = _labelInstanciaInterna(
        row.read<int>('orden'),
        row.read<String>('tipo_instancia'),
      );
      final detalle = StringBuffer()
        ..write('Estado: ${_labelEstadoEvaluacionCronologia(estado)}');
      if (nota.isNotEmpty) detalle.write(' | Nota: $nota');
      if (ausenteJustificado) detalle.write(' | Ausente justificado');
      if (obs.isNotEmpty) detalle.write(' | Obs: $obs');

      eventos.add(
        EventoCronologicoAlumno(
          fecha: _fechaDesdeEpoch(row.read<int>('fecha')),
          tipo: 'evaluacion',
          titulo:
              '${row.read<String>('tipo')}: ${row.read<String>('titulo')} - $instancia',
          detalle: detalle.toString(),
          prioridad: _prioridadDesdeEstadoEvaluacion(estado),
          cursoId: cursoId,
          alumnoId: alumnoId,
          claseId: null,
          evaluacionId: row.read<int>('evaluacion_id'),
          evaluacionInstanciaId: row.read<int>('evaluacion_instancia_id'),
        ),
      );
    }

    final evidenciasRows = await _db
        .customSelect(
          '''
      SELECT
        fecha,
        tipo,
        titulo,
        descripcion,
        evaluacion_id,
        evaluacion_instancia_id
      FROM tabla_evidencias_docentes
      WHERE curso_id = ?
        AND alumno_id = ?
        AND fecha >= ?
      ORDER BY fecha ASC, id ASC
      LIMIT ?
      ''',
          variables: [
            Variable<int>(cursoId),
            Variable<int>(alumnoId),
            Variable<int>(desdeEpoch),
            Variable<int>(limite),
          ],
        )
        .get();
    for (final row in evidenciasRows) {
      final descripcion = (row.read<String?>('descripcion') ?? '').trim();
      eventos.add(
        EventoCronologicoAlumno(
          fecha: _fechaDesdeEpoch(row.read<int>('fecha')),
          tipo: 'evidencia',
          titulo:
              'Evidencia: ${_labelTipoEvidenciaInterna(row.read<String>('tipo'))} - ${row.read<String>('titulo')}',
          detalle: descripcion.isEmpty
              ? 'Sin descripcion adicional'
              : descripcion,
          prioridad: 'baja',
          cursoId: cursoId,
          alumnoId: alumnoId,
          claseId: null,
          evaluacionId: row.read<int?>('evaluacion_id'),
          evaluacionInstanciaId: row.read<int?>('evaluacion_instancia_id'),
        ),
      );
    }

    eventos.sort((a, b) {
      final cmpFecha = b.fecha.compareTo(a.fecha);
      if (cmpFecha != 0) return cmpFecha;
      final cmpPrioridad = _pesoPrioridadPendiente(
        b.prioridad,
      ).compareTo(_pesoPrioridadPendiente(a.prioridad));
      if (cmpPrioridad != 0) return cmpPrioridad;
      return a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
    });
    if (eventos.length <= limite) {
      return eventos;
    }
    return eventos.take(limite).toList(growable: false);
  }

  List<_PuntoAsistenciaCronologia> _detectarMejorasAsistenciaCronologia(
    List<_PuntoAsistenciaCronologia> puntos,
  ) {
    if (puntos.length < 6) return const [];
    final out = <_PuntoAsistenciaCronologia>[];
    var ultimoIndiceMarcado = -10;
    for (var i = 2; i < puntos.length; i++) {
      if (!puntos[i].presente ||
          !puntos[i - 1].presente ||
          !puntos[i - 2].presente) {
        continue;
      }
      final inicioPrevio = math.max(0, i - 8);
      var ausenciasPrevias = 0;
      for (var j = inicioPrevio; j <= i - 3; j++) {
        if (puntos[j].ausente) {
          ausenciasPrevias++;
        }
      }
      if (ausenciasPrevias < 2) continue;
      if (i - ultimoIndiceMarcado < 3) continue;
      ultimoIndiceMarcado = i;
      out.add(puntos[i]);
    }
    return out;
  }

  String _labelEstadoAsistenciaCronologia(String estado) {
    final e = estado.trim().toLowerCase();
    if (e == 'presente') return 'Presente';
    if (e == 'ausente') return 'Ausente';
    if (e == 'tarde') return 'Tarde';
    if (e == 'justificada') return 'Justificada';
    return 'Pendiente';
  }

  String _labelEstadoEvaluacionCronologia(String estado) {
    if (estado == 'aprobado') return 'Aprobado';
    if (estado == 'recuperacion') return 'No aprobado';
    if (estado == 'ausente') return 'Ausente';
    if (estado == 'en_proceso') return 'En proceso';
    return 'Pendiente';
  }

  String _prioridadDesdeEstadoEvaluacion(String estado) {
    if (estado == 'recuperacion' || estado == 'ausente') return 'alta';
    if (estado == 'en_proceso' || estado == 'pendiente') return 'media';
    return 'baja';
  }

  String _labelInstanciaInterna(int orden, String tipoInstancia) {
    if (orden <= 0) return 'Original';
    final tipo = tipoInstancia.trim().toLowerCase();
    if (tipo == 'recuperatorio') return 'Recuperatorio $orden';
    return '${tipoInstancia.trim().isEmpty ? 'Instancia' : tipoInstancia.trim()} $orden';
  }

  String _labelTipoEvidenciaInterna(String tipo) {
    final t = tipo.trim().toLowerCase();
    if (t == 'foto') return 'Foto';
    if (t == 'rubrica') return 'Rubrica';
    if (t == 'archivo') return 'Archivo';
    return 'Observacion';
  }

  String _normalizarPrioridad(String valor) {
    final v = valor.trim().toLowerCase();
    if (v == 'alta') return 'alta';
    if (v == 'media') return 'media';
    if (v == 'baja') return 'baja';
    return 'media';
  }

  int _pesoPrioridadPendiente(String prioridad) {
    final p = prioridad.trim().toLowerCase();
    if (p == 'alta') return 3;
    if (p == 'media') return 2;
    return 1;
  }

  String _fechaSimpleInterna(DateTime fecha) {
    final d = fecha.day.toString().padLeft(2, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    return '$d/$m/${fecha.year}';
  }
}

class _PuntoAsistenciaCronologia {
  final int claseId;
  final DateTime fecha;
  final bool presente;
  final bool ausente;

  const _PuntoAsistenciaCronologia({
    required this.claseId,
    required this.fecha,
    required this.presente,
    required this.ausente,
  });
}
