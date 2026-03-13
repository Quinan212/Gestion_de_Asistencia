part of 'agenda_docente_repositorio.dart';

extension AgendaDocenteRepositorioCierresAlertas on AgendaDocenteRepositorio {
  Future<List<String>> listarInstitucionesConCursosActivos() async {
    final cursos = await _listarCursosActivos();
    final instituciones =
        cursos
            .map((c) => c.institucion.trim())
            .where((x) => x.isNotEmpty)
            .toSet()
            .toList(growable: false)
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return instituciones;
  }

  Future<List<CierreInstitucionCursoItem>> generarCierreInstitucional({
    required String institucion,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final filtro = institucion.trim().toLowerCase();
    if (filtro.isEmpty) return const [];

    final cursos = await _listarCursosActivos();
    final cursosInstitucion = cursos
        .where((c) => c.institucion.trim().toLowerCase() == filtro)
        .toList(growable: false);
    if (cursosInstitucion.isEmpty) return const [];

    final out = <CierreInstitucionCursoItem>[];
    for (final curso in cursosInstitucion) {
      final resumen = await generarCierreCurso(
        cursoId: curso.id,
        desde: desde,
        hasta: hasta,
      );
      out.add(
        CierreInstitucionCursoItem(
          cursoId: curso.id,
          institucion: curso.institucion,
          carrera: curso.carrera,
          materia: curso.materia,
          etiquetaCurso: curso.etiquetaCurso,
          resumen: resumen,
        ),
      );
    }

    out.sort((a, b) {
      final cmpCarrera = a.carrera.toLowerCase().compareTo(
        b.carrera.toLowerCase(),
      );
      if (cmpCarrera != 0) return cmpCarrera;
      final cmpMateria = a.materia.toLowerCase().compareTo(
        b.materia.toLowerCase(),
      );
      if (cmpMateria != 0) return cmpMateria;
      return a.etiquetaCurso.toLowerCase().compareTo(
        b.etiquetaCurso.toLowerCase(),
      );
    });

    return out;
  }

  Future<ResumenCierreCurso> generarCierreCurso({
    required int cursoId,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final desdeDia = DateTime(desde.year, desde.month, desde.day);
    final hastaDia = DateTime(hasta.year, hasta.month, hasta.day);
    final hastaExclusivo = hastaDia.add(const Duration(days: 1));

    final clases =
        await (_db.select(_db.tablaClases)..where(
              (t) =>
                  t.cursoId.equals(cursoId) &
                  t.fecha.isBiggerOrEqualValue(desdeDia) &
                  t.fecha.isSmallerThanValue(hastaExclusivo),
            ))
            .get();

    final claseIds = clases.map((c) => c.id).toList(growable: false);
    final asistencias = claseIds.isEmpty
        ? const <TablaAsistencia>[]
        : await (_db.select(
            _db.tablaAsistencias,
          )..where((t) => t.claseId.isIn(claseIds))).get();

    var presentes = 0;
    var ausentes = 0;
    var tardes = 0;
    var justificadas = 0;
    var actividadesSinEntregar = 0;
    var trabajosSinCorregir = 0;

    final riesgoPorAlumno = <int, int>{};
    for (final a in asistencias) {
      final estado = a.estado.trim().toLowerCase();
      if (estado == 'presente') {
        presentes++;
      } else if (estado == 'ausente') {
        ausentes++;
      } else if (estado == 'tarde') {
        tardes++;
      } else if (estado == 'justificada') {
        justificadas++;
      }

      if (!a.actividadEntregada && estado != 'ausente') {
        actividadesSinEntregar++;
      }
      if (a.actividadEntregada && (a.notaActividad ?? '').trim().isEmpty) {
        trabajosSinCorregir++;
      }
      if (estado == 'ausente' || estado == 'pendiente') {
        riesgoPorAlumno[a.alumnoId] = (riesgoPorAlumno[a.alumnoId] ?? 0) + 1;
      }
    }
    final alumnosEnRiesgo = riesgoPorAlumno.values.where((v) => v >= 3).length;

    final contenidos = await listarContenidosCurso(cursoId);
    var contenidosIniciados = 0;
    var contenidosEnDesarrollo = 0;
    var contenidosTrabajados = 0;
    var contenidosEvaluados = 0;
    var contenidosPendientes = 0;
    for (final c in contenidos) {
      final estado = c.estado.trim().toLowerCase();
      if (estado == 'iniciado') {
        contenidosIniciados++;
      } else if (estado == 'en_desarrollo' || estado == 'desarrollo') {
        contenidosEnDesarrollo++;
      } else if (estado == 'trabajado') {
        contenidosTrabajados++;
      } else if (estado == 'evaluado') {
        contenidosEvaluados++;
      } else {
        contenidosPendientes++;
      }
    }

    return ResumenCierreCurso(
      desde: desdeDia,
      hasta: hastaDia,
      clasesDictadas: clases.length,
      registrosAsistencia: asistencias.length,
      presentes: presentes,
      ausentes: ausentes,
      tardes: tardes,
      justificadas: justificadas,
      actividadesSinEntregar: actividadesSinEntregar,
      trabajosSinCorregir: trabajosSinCorregir,
      alumnosEnRiesgo: alumnosEnRiesgo,
      contenidosIniciados: contenidosIniciados,
      contenidosEnDesarrollo: contenidosEnDesarrollo,
      contenidosTrabajados: contenidosTrabajados,
      contenidosEvaluados: contenidosEvaluados,
      contenidosPendientes: contenidosPendientes,
    );
  }

  Future<List<AlertaAutomaticaDocente>> listarAlertasAutomaticas(
    DateTime fecha, {
    int limite = 80,
  }) async {
    final dia = DateTime(fecha.year, fecha.month, fecha.day);
    final cursos = await _listarCursosActivos();
    if (cursos.isEmpty) return const [];
    final minimaAsistenciaPorInstitucion =
        await _asistenciaMinimaPorInstitucion();

    final alertas = <AlertaAutomaticaDocente>[];
    alertas.addAll(await _alertasAusenciasConsecutivas(dia, cursos));
    alertas.addAll(await _alertasActividadesSinEntregar(dia, cursos));
    alertas.addAll(
      await _alertasCaidaAsistencia(
        dia,
        cursos,
        minimaAsistenciaPorInstitucion: minimaAsistenciaPorInstitucion,
      ),
    );
    alertas.addAll(await _alertasEvaluacionesSinCerrar(dia, cursos));

    final visibles = await _filtrarAlertasPospuestas(alertas);
    if (visibles.length <= limite) return visibles;
    return visibles.take(limite).toList(growable: false);
  }

  Future<void> posponerAlerta({
    required String clave,
    required Duration duracion,
  }) async {
    final ahora = DateTime.now();
    final hasta = ahora.add(duracion);

    await _db.customStatement(
      '''
      INSERT INTO tabla_alertas_docentes_snooze (
        clave,
        pospuesta_hasta,
        creado_en
      ) VALUES (?, ?, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      ON CONFLICT(clave)
      DO UPDATE SET
        pospuesta_hasta = excluded.pospuesta_hasta
      ''',
      [clave, hasta.millisecondsSinceEpoch ~/ 1000],
    );
  }

  Future<List<AlertaAutomaticaDocente>> _filtrarAlertasPospuestas(
    List<AlertaAutomaticaDocente> alertas,
  ) async {
    if (alertas.isEmpty) return const [];
    final ahoraSeg = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final rows = await _db
        .customSelect(
          '''
      SELECT clave
      FROM tabla_alertas_docentes_snooze
      WHERE pospuesta_hasta > ?
      ''',
          variables: [Variable<int>(ahoraSeg)],
        )
        .get();

    final clavesPospuestas = rows.map((r) => r.read<String>('clave')).toSet();
    if (clavesPospuestas.isEmpty) return alertas;

    return alertas
        .where((a) => !clavesPospuestas.contains(a.clave))
        .toList(growable: false);
  }

  Future<Map<String, double>> _asistenciaMinimaPorInstitucion() async {
    final rows = await _db.customSelect('''
      SELECT institucion, asistencia_minima
      FROM tabla_reglas_institucion
      ''').get();

    final out = <String, double>{};
    for (final row in rows) {
      final institucion = row.read<String>('institucion').trim().toLowerCase();
      if (institucion.isEmpty) continue;
      final minimo = row.readWithType(DriftSqlType.double, 'asistencia_minima');
      out[institucion] = math.max(0.0, math.min(minimo, 100.0)).toDouble();
    }
    return out;
  }

  Future<List<AlertaAutomaticaDocente>> _alertasAusenciasConsecutivas(
    DateTime dia,
    List<_CursoAgendaBase> cursos,
  ) async {
    final alertas = <AlertaAutomaticaDocente>[];
    final cursoPorId = {for (final c in cursos) c.id: c};

    for (final curso in cursos) {
      final clases =
          await (_db.select(_db.tablaClases)
                ..where(
                  (t) =>
                      t.cursoId.equals(curso.id) &
                      t.fecha.isSmallerOrEqualValue(dia),
                )
                ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
                ..limit(8))
              .get();

      if (clases.length < 3) continue;
      final claseIds = clases.map((x) => x.id).toList(growable: false);
      final asistencias = await (_db.select(
        _db.tablaAsistencias,
      )..where((t) => t.claseId.isIn(claseIds))).get();

      final estadoPorClaseAlumno = <int, Map<int, String>>{};
      final alumnoIds = <int>{};
      for (final fila in asistencias) {
        estadoPorClaseAlumno.putIfAbsent(
          fila.claseId,
          () => <int, String>{},
        )[fila.alumnoId] = fila.estado
            .trim()
            .toLowerCase();
        alumnoIds.add(fila.alumnoId);
      }

      if (alumnoIds.isEmpty) continue;
      final nombres = await _nombresAlumnos(alumnoIds);

      for (final alumnoId in alumnoIds) {
        var consecutivas = 0;
        for (final clase in clases) {
          final estado = estadoPorClaseAlumno[clase.id]?[alumnoId];
          if (estado == null) break;
          if (estado == 'ausente' || estado == 'pendiente') {
            consecutivas++;
          } else {
            break;
          }
        }

        if (consecutivas >= 3) {
          final nombreAlumno = nombres[alumnoId] ?? 'Alumno #$alumnoId';
          final infoCurso = cursoPorId[curso.id];
          final mensaje =
              '$nombreAlumno acumula $consecutivas inasistencias consecutivas en ${infoCurso?.materia ?? 'el curso'} (${infoCurso?.etiquetaCurso ?? ''}).';
          alertas.add(
            AlertaAutomaticaDocente(
              clave: _construirClaveAlerta(
                tipo: 'inasistencias_consecutivas',
                cursoId: curso.id,
                alumnoId: alumnoId,
                mensaje: mensaje,
              ),
              tipo: 'inasistencias_consecutivas',
              severidad: 'alta',
              mensaje: mensaje,
              cursoId: curso.id,
              alumnoId: alumnoId,
              institucion: infoCurso?.institucion,
              materia: infoCurso?.materia,
              etiquetaCurso: infoCurso?.etiquetaCurso,
            ),
          );
        }
      }
    }

    return alertas;
  }

  Future<List<AlertaAutomaticaDocente>> _alertasActividadesSinEntregar(
    DateTime dia,
    List<_CursoAgendaBase> cursos,
  ) async {
    final desde = dia.subtract(const Duration(days: 45));
    final cursoPorId = {for (final c in cursos) c.id: c};

    final rows = await _db
        .customSelect(
          '''
      SELECT
        c.curso_id AS curso_id,
        a.alumno_id AS alumno_id,
        COUNT(*) AS total
      FROM tabla_asistencias a
      INNER JOIN tabla_clases c ON c.id = a.clase_id
      WHERE c.fecha >= ?
        AND c.fecha <= ?
        AND lower(trim(a.estado)) <> 'ausente'
        AND a.actividad_entregada = 0
      GROUP BY c.curso_id, a.alumno_id
      HAVING COUNT(*) >= 2
      ORDER BY total DESC
      ''',
          variables: [
            Variable<DateTime>(desde),
            Variable<DateTime>(dia.add(const Duration(days: 1))),
          ],
        )
        .get();

    if (rows.isEmpty) return const [];

    final alumnoIds = rows.map((r) => r.read<int>('alumno_id')).toSet();
    final nombres = await _nombresAlumnos(alumnoIds);

    return rows
        .map((r) {
          final cursoId = r.read<int>('curso_id');
          final alumnoId = r.read<int>('alumno_id');
          final total = r.read<int>('total');
          final nombreAlumno = nombres[alumnoId] ?? 'Alumno #$alumnoId';
          final curso = cursoPorId[cursoId];
          final mensaje =
              '$nombreAlumno tiene $total actividades sin entregar en ${curso?.materia ?? 'el curso'} (${curso?.etiquetaCurso ?? ''}).';

          return AlertaAutomaticaDocente(
            clave: _construirClaveAlerta(
              tipo: 'actividades_sin_entregar',
              cursoId: cursoId,
              alumnoId: alumnoId,
              mensaje: mensaje,
            ),
            tipo: 'actividades_sin_entregar',
            severidad: total >= 4 ? 'alta' : 'media',
            mensaje: mensaje,
            cursoId: cursoId,
            alumnoId: alumnoId,
            institucion: curso?.institucion,
            materia: curso?.materia,
            etiquetaCurso: curso?.etiquetaCurso,
          );
        })
        .toList(growable: false);
  }

  Future<List<AlertaAutomaticaDocente>> _alertasCaidaAsistencia(
    DateTime dia,
    List<_CursoAgendaBase> cursos, {
    required Map<String, double> minimaAsistenciaPorInstitucion,
  }) async {
    final inicioMesActual = DateTime(dia.year, dia.month, 1);
    final inicioMesSiguiente = _sumarMeses(inicioMesActual, 1);
    final inicioMesAnterior = _sumarMeses(inicioMesActual, -1);

    final cursoIds = cursos.map((x) => x.id).toList(growable: false);
    final clases =
        await (_db.select(_db.tablaClases)..where(
              (t) =>
                  t.cursoId.isIn(cursoIds) &
                  t.fecha.isBiggerOrEqualValue(inicioMesAnterior) &
                  t.fecha.isSmallerThanValue(inicioMesSiguiente),
            ))
            .get();

    if (clases.isEmpty) return const [];

    final fechaPorClase = {for (final c in clases) c.id: c.fecha};
    final cursoPorClase = {for (final c in clases) c.id: c.cursoId};

    final asistencias = await (_db.select(
      _db.tablaAsistencias,
    )..where((t) => t.claseId.isIn(fechaPorClase.keys.toList()))).get();

    final stats = <int, _AsistenciaComparada>{};
    for (final fila in asistencias) {
      final fechaClase = fechaPorClase[fila.claseId];
      final cursoId = cursoPorClase[fila.claseId];
      if (fechaClase == null || cursoId == null) continue;

      final estado = fila.estado.trim().toLowerCase();
      if (estado == 'pendiente') continue;

      final esPresenteComputable =
          estado == 'presente' || estado == 'tarde' || estado == 'justificada';
      final esMesActual =
          !fechaClase.isBefore(inicioMesActual) &&
          fechaClase.isBefore(inicioMesSiguiente);

      final s = stats.putIfAbsent(cursoId, _AsistenciaComparada.new);
      if (esMesActual) {
        s.totalActual++;
        if (esPresenteComputable) s.presentesActual++;
      } else {
        s.totalAnterior++;
        if (esPresenteComputable) s.presentesAnterior++;
      }
    }

    final cursoPorId = {for (final c in cursos) c.id: c};
    final alertas = <AlertaAutomaticaDocente>[];

    for (final entry in stats.entries) {
      final cursoId = entry.key;
      final s = entry.value;
      if (s.totalAnterior < 10 || s.totalActual < 10) continue;

      final pctAnterior = (s.presentesAnterior / s.totalAnterior) * 100;
      final pctActual = (s.presentesActual / s.totalActual) * 100;
      final caida = pctAnterior - pctActual;
      final curso = cursoPorId[cursoId];
      final institucion = (curso?.institucion ?? '').trim().toLowerCase();
      final minimoAsistencia =
          minimaAsistenciaPorInstitucion[institucion] ?? 75.0;

      if (caida >= 20 && pctActual < minimoAsistencia) {
        final mensaje =
            'El curso ${curso?.materia ?? ''} (${curso?.etiquetaCurso ?? ''}) bajo de ${pctAnterior.toStringAsFixed(0)}% a ${pctActual.toStringAsFixed(0)}% de asistencia en el mes actual (minimo institucional: ${minimoAsistencia.toStringAsFixed(0)}%).';
        alertas.add(
          AlertaAutomaticaDocente(
            clave: _construirClaveAlerta(
              tipo: 'caida_asistencia_curso',
              cursoId: cursoId,
              alumnoId: null,
              mensaje: mensaje,
            ),
            tipo: 'caida_asistencia_curso',
            severidad: 'media',
            mensaje: mensaje,
            cursoId: cursoId,
            alumnoId: null,
            institucion: curso?.institucion,
            materia: curso?.materia,
            etiquetaCurso: curso?.etiquetaCurso,
          ),
        );
      }
    }

    return alertas;
  }

  Future<List<AlertaAutomaticaDocente>> _alertasEvaluacionesSinCerrar(
    DateTime dia,
    List<_CursoAgendaBase> cursos,
  ) async {
    if (cursos.isEmpty) return const [];
    final cursoPorId = {for (final c in cursos) c.id: c};
    final cursoIds = cursos.map((c) => c.id).toList(growable: false);
    final placeholders = List<String>.filled(cursoIds.length, '?').join(',');

    final rows = await _db
        .customSelect(
          '''
      SELECT
        e.id AS evaluacion_id,
        e.curso_id AS curso_id,
        e.fecha AS fecha,
        e.tipo AS tipo,
        e.titulo AS titulo,
        (
          SELECT COUNT(*)
          FROM tabla_inscripciones ins
          INNER JOIN tabla_alumnos a ON a.id = ins.alumno_id
          WHERE ins.curso_id = e.curso_id
            AND ins.activo = 1
            AND a.activo = 1
        ) AS total_alumnos,
        COUNT(DISTINCT r.alumno_id) AS con_resultado
      FROM tabla_evaluaciones_curso e
      LEFT JOIN tabla_evaluaciones_alumno r
        ON r.evaluacion_id = e.id
      WHERE e.curso_id IN ($placeholders)
        AND e.fecha <= ?
        AND lower(trim(COALESCE(e.estado, 'abierta'))) <> 'cerrada'
      GROUP BY e.id, e.curso_id, e.fecha, e.tipo, e.titulo
      ORDER BY e.fecha DESC, e.id DESC
      ''',
          variables: [
            ...cursoIds.map((id) => Variable<int>(id)),
            Variable<int>(dia.millisecondsSinceEpoch ~/ 1000),
          ],
        )
        .get();

    final alertas = <AlertaAutomaticaDocente>[];
    for (final row in rows) {
      final cursoId = row.read<int>('curso_id');
      final totalAlumnos = row.read<int>('total_alumnos');
      if (totalAlumnos <= 0) continue;

      final conResultado = row.read<int>('con_resultado');
      final faltan = totalAlumnos - conResultado;
      if (faltan < 2) continue;

      final fecha = _fechaDesdeEpoch(row.read<int>('fecha'));
      final diasAbierta = dia.difference(fecha).inDays;
      if (diasAbierta < 3) continue;

      final curso = cursoPorId[cursoId];
      final titulo = row.read<String>('titulo').trim();
      final tipo = row.read<String>('tipo').trim();
      final texto = titulo.isEmpty ? tipo : '$tipo - $titulo';
      final mensaje =
          '$texto en ${curso?.materia ?? 'el curso'} (${curso?.etiquetaCurso ?? ''}) sigue sin cerrar: faltan $faltan resultados.';

      alertas.add(
        AlertaAutomaticaDocente(
          clave: _construirClaveAlerta(
            tipo: 'evaluacion_sin_cerrar',
            cursoId: cursoId,
            alumnoId: null,
            mensaje: mensaje,
          ),
          tipo: 'evaluacion_sin_cerrar',
          severidad: faltan >= 5 ? 'alta' : 'media',
          mensaje: mensaje,
          cursoId: cursoId,
          alumnoId: null,
          institucion: curso?.institucion,
          materia: curso?.materia,
          etiquetaCurso: curso?.etiquetaCurso,
        ),
      );
    }

    return alertas;
  }

  Future<Map<int, String>> _nombresAlumnos(Set<int> alumnoIds) async {
    if (alumnoIds.isEmpty) return const {};
    final alumnos = await (_db.select(
      _db.tablaAlumnos,
    )..where((t) => t.id.isIn(alumnoIds.toList()))).get();

    return {
      for (final a in alumnos)
        a.id: '${a.apellido.trim()}, ${a.nombre.trim()}'.trim(),
    };
  }
}
