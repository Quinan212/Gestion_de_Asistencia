part of 'agenda_docente_repositorio.dart';

extension AgendaDocenteRepositorioDashboardFichaContenidos
    on AgendaDocenteRepositorio {
  Future<List<DashboardInstitucionItem>> generarDashboardInstitucional(
    DateTime fecha,
  ) async {
    final dia = DateTime(fecha.year, fecha.month, fecha.day);
    final cursos = await _listarCursosActivos();
    if (cursos.isEmpty) return const [];

    final alertas = await listarAlertasAutomaticas(dia, limite: 400);
    final cursosPorInstitucion = <String, int>{};
    final evalAbiertasPorInstitucion = <String, int>{};
    final contenidosPendPorInstitucion = <String, int>{};
    final alumnosRiesgoPorInstitucion = <String, Set<int>>{};
    final alertasAltas = <String, int>{};
    final alertasMedias = <String, int>{};
    final alertasBajas = <String, int>{};

    final institucionPorCurso = <int, String>{};
    for (final c in cursos) {
      final inst = c.institucion.trim();
      institucionPorCurso[c.id] = inst;
      cursosPorInstitucion[inst] = (cursosPorInstitucion[inst] ?? 0) + 1;
    }

    for (final a in alertas) {
      final inst = (a.institucion ?? '').trim().isEmpty
          ? (institucionPorCurso[a.cursoId ?? -1] ?? 'Sin institucion')
          : (a.institucion ?? '').trim();
      final sev = a.severidad.trim().toLowerCase();
      if (sev == 'alta') {
        alertasAltas[inst] = (alertasAltas[inst] ?? 0) + 1;
      } else if (sev == 'media') {
        alertasMedias[inst] = (alertasMedias[inst] ?? 0) + 1;
      } else {
        alertasBajas[inst] = (alertasBajas[inst] ?? 0) + 1;
      }
      if (a.alumnoId != null &&
          (a.tipo == 'inasistencias_consecutivas' ||
              a.tipo == 'actividades_sin_entregar')) {
        alumnosRiesgoPorInstitucion
            .putIfAbsent(inst, () => <int>{})
            .add(a.alumnoId!);
      }
    }

    final evalRows = await _db.customSelect('''
      SELECT
        e.curso_id AS curso_id,
        COUNT(*) AS total
      FROM tabla_evaluaciones_curso e
      WHERE lower(trim(COALESCE(e.estado, 'abierta'))) <> 'cerrada'
      GROUP BY e.curso_id
      ''').get();
    for (final r in evalRows) {
      final cursoId = r.read<int>('curso_id');
      final inst = institucionPorCurso[cursoId];
      if (inst == null) continue;
      evalAbiertasPorInstitucion[inst] =
          (evalAbiertasPorInstitucion[inst] ?? 0) + r.read<int>('total');
    }

    final contRows = await _db.customSelect('''
      SELECT
        curso_id,
        COUNT(*) AS total
      FROM tabla_contenidos_curso
      WHERE lower(trim(COALESCE(estado, 'pendiente'))) IN ('pendiente', 'iniciado', 'en_desarrollo', 'desarrollo')
      GROUP BY curso_id
      ''').get();
    for (final r in contRows) {
      final cursoId = r.read<int>('curso_id');
      final inst = institucionPorCurso[cursoId];
      if (inst == null) continue;
      contenidosPendPorInstitucion[inst] =
          (contenidosPendPorInstitucion[inst] ?? 0) + r.read<int>('total');
    }

    final instituciones = cursosPorInstitucion.keys.toList(growable: false)
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final out = <DashboardInstitucionItem>[];
    for (final inst in instituciones) {
      final altas = alertasAltas[inst] ?? 0;
      final medias = alertasMedias[inst] ?? 0;
      final bajas = alertasBajas[inst] ?? 0;
      final abiertas = evalAbiertasPorInstitucion[inst] ?? 0;
      final contenidosPend = contenidosPendPorInstitucion[inst] ?? 0;
      final riesgo = alumnosRiesgoPorInstitucion[inst]?.length ?? 0;
      final cursosActivos = cursosPorInstitucion[inst] ?? 0;
      final semaforo = _calcularSemaforoDashboard(
        alertasAltas: altas,
        alertasMedias: medias,
        evaluacionesAbiertas: abiertas,
        estudiantesRiesgo: riesgo,
      );

      out.add(
        DashboardInstitucionItem(
          institucion: inst,
          cursosActivos: cursosActivos,
          alertasAltas: altas,
          alertasMedias: medias,
          alertasBajas: bajas,
          estudiantesEnRiesgo: riesgo,
          evaluacionesAbiertas: abiertas,
          contenidosPendientes: contenidosPend,
          semaforo: semaforo,
          resumen:
              '$cursosActivos cursos | alertas A/M/B: $altas/$medias/$bajas | riesgo: $riesgo | eval abiertas: $abiertas | contenidos pendientes: $contenidosPend',
        ),
      );
    }

    out.sort((a, b) {
      final cmpSem = _prioridadSemaforoDashboard(
        a.semaforo,
      ).compareTo(_prioridadSemaforoDashboard(b.semaforo));
      if (cmpSem != 0) return cmpSem;
      final aCrit = a.alertasAltas + a.estudiantesEnRiesgo;
      final bCrit = b.alertasAltas + b.estudiantesEnRiesgo;
      final cmpCrit = bCrit.compareTo(aCrit);
      if (cmpCrit != 0) return cmpCrit;
      return a.institucion.toLowerCase().compareTo(b.institucion.toLowerCase());
    });
    return out;
  }

  Future<FichaPedagogicaCurso> obtenerFichaCurso(int cursoId) async {
    final row = await _db
        .customSelect(
          '''
      SELECT
        curso_id,
        contenidos_dados,
        contenidos_pendientes,
        ritmo_grupo,
        observaciones_generales,
        alertas_didacticas
      FROM tabla_ficha_pedagogica_curso
      WHERE curso_id = ?
      LIMIT 1
      ''',
          variables: [Variable<int>(cursoId)],
        )
        .getSingleOrNull();

    if (row == null) return FichaPedagogicaCurso.vacia(cursoId);
    return FichaPedagogicaCurso(
      cursoId: row.read<int>('curso_id'),
      contenidosDados: row.read<String>('contenidos_dados'),
      contenidosPendientes: row.read<String>('contenidos_pendientes'),
      ritmoGrupo: row.read<String>('ritmo_grupo'),
      observacionesGenerales: row.read<String>('observaciones_generales'),
      alertasDidacticas: row.read<String>('alertas_didacticas'),
    );
  }

  Future<void> guardarFichaCurso({
    required int cursoId,
    required String contenidosDados,
    required String contenidosPendientes,
    required String ritmoGrupo,
    required String observacionesGenerales,
    required String alertasDidacticas,
  }) async {
    await _db.customStatement(
      '''
      INSERT INTO tabla_ficha_pedagogica_curso (
        curso_id,
        contenidos_dados,
        contenidos_pendientes,
        ritmo_grupo,
        observaciones_generales,
        alertas_didacticas,
        actualizado_en
      ) VALUES (?, ?, ?, ?, ?, ?, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      ON CONFLICT(curso_id)
      DO UPDATE SET
        contenidos_dados = excluded.contenidos_dados,
        contenidos_pendientes = excluded.contenidos_pendientes,
        ritmo_grupo = excluded.ritmo_grupo,
        observaciones_generales = excluded.observaciones_generales,
        alertas_didacticas = excluded.alertas_didacticas,
        actualizado_en = excluded.actualizado_en
      ''',
      [
        cursoId,
        contenidosDados.trim(),
        contenidosPendientes.trim(),
        ritmoGrupo.trim(),
        observacionesGenerales.trim(),
        alertasDidacticas.trim(),
      ],
    );
  }

  Future<List<ContenidoCurso>> listarContenidosCurso(int cursoId) async {
    final rows = await _db
        .customSelect(
          '''
      SELECT id, curso_id, contenido, estado, orden
      FROM tabla_contenidos_curso
      WHERE curso_id = ?
      ORDER BY orden ASC, id ASC
      ''',
          variables: [Variable<int>(cursoId)],
        )
        .get();

    return rows
        .map(
          (r) => ContenidoCurso(
            id: r.read<int>('id'),
            cursoId: r.read<int>('curso_id'),
            contenido: r.read<String>('contenido'),
            estado: r.read<String>('estado'),
            orden: r.read<int>('orden'),
          ),
        )
        .toList(growable: false);
  }

  Future<int> agregarContenidoCurso({
    required int cursoId,
    required String contenido,
    String estado = 'pendiente',
  }) async {
    final ultimo = await _db
        .customSelect(
          '''
      SELECT COALESCE(MAX(orden), 0) AS max_orden
      FROM tabla_contenidos_curso
      WHERE curso_id = ?
      ''',
          variables: [Variable<int>(cursoId)],
        )
        .getSingle();
    final orden = (ultimo.read<int>('max_orden')) + 1;

    await _db.customStatement(
      '''
      INSERT INTO tabla_contenidos_curso (
        curso_id,
        contenido,
        estado,
        orden,
        actualizado_en
      ) VALUES (?, ?, ?, ?, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      ''',
      [cursoId, contenido.trim(), estado.trim(), orden],
    );

    final row = await _db
        .customSelect('SELECT last_insert_rowid() AS id')
        .getSingle();
    return row.read<int>('id');
  }

  Future<void> actualizarContenidoCurso({
    required int contenidoId,
    required String contenido,
    required String estado,
  }) async {
    await _db.customStatement(
      '''
      UPDATE tabla_contenidos_curso
      SET
        contenido = ?,
        estado = ?,
        actualizado_en = CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)
      WHERE id = ?
      ''',
      [contenido.trim(), estado.trim(), contenidoId],
    );
  }

  Future<void> actualizarEstadoContenidoCurso({
    required int contenidoId,
    required String estado,
  }) async {
    await _db.customStatement(
      '''
      UPDATE tabla_contenidos_curso
      SET
        estado = ?,
        actualizado_en = CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)
      WHERE id = ?
      ''',
      [estado.trim(), contenidoId],
    );
  }

  Future<void> eliminarContenidoCurso(int contenidoId) async {
    await _db.customStatement(
      'DELETE FROM tabla_contenidos_curso WHERE id = ?',
      [contenidoId],
    );
  }
}
