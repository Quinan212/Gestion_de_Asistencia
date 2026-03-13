part of 'agenda_docente_repositorio.dart';

extension AgendaDocenteRepositorioAgendaHorarios on AgendaDocenteRepositorio {
  Future<List<AgendaDocenteItem>> listarAgendaDia(DateTime fecha) async {
    final dia = DateTime(fecha.year, fecha.month, fecha.day);
    final finDia = dia.add(const Duration(days: 1));
    final desdeHistorial = dia.subtract(const Duration(days: 84));
    final hastaFuturo = dia.add(const Duration(days: 160));

    final cursos = await _listarCursosActivos();
    if (cursos.isEmpty) return const [];

    final cursoIds = cursos.map((c) => c.id).toList(growable: false);

    final horariosTodos = await _listarHorariosCursos(cursoIds);
    final horariosPorCursoDia = <int, List<HorarioCurso>>{};
    final cursosConHorario = <int>{};
    for (final h in horariosTodos) {
      cursosConHorario.add(h.cursoId);
      if (h.diaSemana != dia.weekday) continue;
      horariosPorCursoDia.putIfAbsent(h.cursoId, () => <HorarioCurso>[]).add(h);
    }
    for (final entry in horariosPorCursoDia.entries) {
      entry.value.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
    }

    final clasesHistorial =
        await (_db.select(_db.tablaClases)
              ..where(
                (t) =>
                    t.cursoId.isIn(cursoIds) &
                    t.fecha.isBiggerOrEqualValue(desdeHistorial) &
                    t.fecha.isSmallerThanValue(finDia),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
            .get();

    final clasesFuturas =
        await (_db.select(_db.tablaClases)
              ..where(
                (t) =>
                    t.cursoId.isIn(cursoIds) &
                    t.fecha.isBiggerThanValue(dia) &
                    t.fecha.isSmallerOrEqualValue(hastaFuturo),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.fecha)]))
            .get();

    final historialPorCurso = _agruparClasesPorCurso(clasesHistorial);
    final futurasPorCurso = _agruparClasesPorCurso(clasesFuturas);

    final clasesRelevantes = <int>{};
    final recientesPorCurso = <int, List<int>>{};
    final claseHoyPorCurso = <int, TablaClase>{};
    final claseAnteriorPorCurso = <int, TablaClase>{};
    final coincideDiaPorCurso = <int, bool>{};

    for (final curso in cursos) {
      final historial = historialPorCurso[curso.id] ?? const <TablaClase>[];
      final claseHoy = _buscarClaseDelDia(historial, dia);
      final claseAnterior = _buscarUltimaAnterior(historial, dia);
      final tieneHorarioConfig = cursosConHorario.contains(curso.id);
      final coincideHorario =
          (horariosPorCursoDia[curso.id] ?? const []).isNotEmpty;
      final coincideHistorico =
          claseHoy != null ||
          historial.any((c) => c.fecha.weekday == dia.weekday);
      final coincide = tieneHorarioConfig ? coincideHorario : coincideHistorico;

      coincideDiaPorCurso[curso.id] = coincide;
      if (claseHoy != null) {
        claseHoyPorCurso[curso.id] = claseHoy;
        clasesRelevantes.add(claseHoy.id);
      }
      if (claseAnterior != null) {
        claseAnteriorPorCurso[curso.id] = claseAnterior;
        clasesRelevantes.add(claseAnterior.id);
      }

      final recientes = _tomarRecientes(
        historial,
        dia,
        maximo: 3,
      ).map((x) => x.id).toList(growable: false);
      recientesPorCurso[curso.id] = recientes;
      clasesRelevantes.addAll(recientes);
    }

    final asistencias = clasesRelevantes.isEmpty
        ? const <TablaAsistencia>[]
        : await (_db.select(
            _db.tablaAsistencias,
          )..where((t) => t.claseId.isIn(clasesRelevantes.toList()))).get();
    final asistenciasPorClase = _agruparAsistenciasPorClase(asistencias);

    List<AgendaDocenteItem> armarItems({required bool soloCursosDelDia}) {
      final out = <AgendaDocenteItem>[];

      for (final curso in cursos) {
        if (soloCursosDelDia && !(coincideDiaPorCurso[curso.id] ?? false)) {
          continue;
        }

        final claseHoy = claseHoyPorCurso[curso.id];
        final claseAnterior = claseAnteriorPorCurso[curso.id];
        final claseBase = claseHoy ?? claseAnterior;

        final temaClasePasada = _textoPrincipalClase(claseAnterior);
        final continuarHoy = _resolverContinuidad(
          claseHoy: claseHoy,
          claseAnterior: claseAnterior,
        );

        final pendientes = _contarPendientes(
          asistenciasPorClase[claseBase?.id] ?? const <TablaAsistencia>[],
        );

        final correcciones = _contarCorreccionesPendientes(
          idsClases: recientesPorCurso[curso.id] ?? const <int>[],
          asistenciasPorClase: asistenciasPorClase,
        );

        final proximaEvaluacion = _buscarProximaEvaluacion(
          futurasPorCurso[curso.id] ?? const <TablaClase>[],
        );

        final horariosHoy =
            (horariosPorCursoDia[curso.id] ?? const <HorarioCurso>[])
                .map((h) {
                  final aula = (h.aula ?? '').trim();
                  if (aula.isEmpty) return h.franja;
                  return '${h.franja} ($aula)';
                })
                .toList(growable: false);
        final horariosDelCurso =
            horariosPorCursoDia[curso.id] ?? const <HorarioCurso>[];

        out.add(
          AgendaDocenteItem(
            cursoId: curso.id,
            institucion: curso.institucion,
            carrera: curso.carrera,
            materia: curso.materia,
            etiquetaCurso: curso.etiquetaCurso,
            bloquesHorarios: horariosHoy,
            horaReferenciaOrden: horariosDelCurso.isEmpty
                ? null
                : horariosDelCurso.first.horaInicio,
            tieneClaseHoy: claseHoy != null,
            claseHoyId: claseHoy?.id,
            registrosHoy: asistenciasPorClase[claseHoy?.id]?.length ?? 0,
            ultimaClaseFecha: claseAnterior?.fecha,
            temaClasePasada: temaClasePasada,
            continuarHoy: continuarHoy,
            alumnosPendientes: pendientes.alumnosPendientes,
            actividadesSinEntregar: pendientes.actividadesSinEntregar,
            trabajosSinCorregir: correcciones,
            proximaEvaluacionFecha: proximaEvaluacion?.fecha,
            proximaEvaluacion: _textoPrincipalClase(proximaEvaluacion),
          ),
        );
      }

      _ordenarAgenda(out);
      return out;
    }

    final agendaDelDia = armarItems(soloCursosDelDia: true);
    if (agendaDelDia.isNotEmpty) return agendaDelDia;
    return armarItems(soloCursosDelDia: false);
  }

  Future<List<HorarioCurso>> listarHorariosCurso(int cursoId) async {
    final rows = await _db
        .customSelect(
          '''
      SELECT id, curso_id, dia_semana, hora_inicio, hora_fin, aula
      FROM tabla_horarios_curso
      WHERE curso_id = ? AND activo = 1
      ORDER BY dia_semana ASC, hora_inicio ASC
      ''',
          variables: [Variable<int>(cursoId)],
        )
        .get();

    return rows.map(_mapHorario).toList(growable: false);
  }

  Future<void> guardarHorariosCurso({
    required int cursoId,
    required List<HorarioCursoEdicion> horarios,
  }) async {
    await _db.transaction(() async {
      await _db.customStatement(
        'DELETE FROM tabla_horarios_curso WHERE curso_id = ?',
        [cursoId],
      );

      for (final horario in horarios) {
        final inicio = _normalizarHora(horario.horaInicio);
        if (inicio == null) continue;
        final fin = _normalizarHora(horario.horaFin);
        final aula = _nullSiVacio(horario.aula);

        await _db.customStatement(
          '''
          INSERT INTO tabla_horarios_curso (
            curso_id,
            dia_semana,
            hora_inicio,
            hora_fin,
            aula,
            activo,
            creado_en
          ) VALUES (?, ?, ?, ?, ?, 1, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
          ''',
          [cursoId, horario.diaSemana, inicio, fin, aula],
        );
      }
    });
  }
}
