part of 'agenda_docente_repositorio.dart';

extension AgendaDocenteRepositorioSintesisPeriodo on AgendaDocenteRepositorio {
  Future<SintesisPeriodoCurso> generarSintesisPeriodoCurso({
    required int cursoId,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final desdeDia = DateTime(desde.year, desde.month, desde.day);
    final hastaDia = DateTime(hasta.year, hasta.month, hasta.day);
    final hastaExclusivo = hastaDia.add(const Duration(days: 1));
    final desdeEpoch = desdeDia.millisecondsSinceEpoch ~/ 1000;
    final hastaEpoch = hastaExclusivo.millisecondsSinceEpoch ~/ 1000;

    final cursos = await _listarCursosActivos();
    final base = cursos.where((c) => c.id == cursoId).toList();
    final curso = base.isEmpty
        ? const _CursoAgendaBase(
            id: 0,
            institucion: 'Sin institucion',
            carrera: '',
            materia: 'Sin materia',
            etiquetaCurso: 'Sin curso',
          )
        : base.first;

    final cierre = await generarCierreCurso(
      cursoId: cursoId,
      desde: desdeDia,
      hasta: hastaDia,
    );

    final evalRow = await _db
        .customSelect(
          '''
      SELECT
        COUNT(DISTINCT i.id) AS instancias_abiertas,
        COALESCE(SUM(CASE WHEN lower(trim(COALESCE(r.estado, ''))) <> 'pendiente' THEN 1 ELSE 0 END), 0) AS resultados_rendidos,
        COALESCE(SUM(CASE WHEN i.orden > 0 AND lower(trim(COALESCE(r.estado, ''))) <> 'pendiente' THEN 1 ELSE 0 END), 0) AS recuperatorios_tomados
      FROM tabla_evaluaciones_instancia i
      INNER JOIN tabla_evaluaciones_curso e ON e.id = i.evaluacion_id
      LEFT JOIN tabla_evaluaciones_alumno r
        ON r.evaluacion_instancia_id = i.id
      WHERE e.curso_id = ?
        AND i.fecha >= ?
        AND i.fecha < ?
        AND lower(trim(COALESCE(i.estado, 'abierta'))) <> 'cerrada'
      ''',
          variables: [
            Variable<int>(cursoId),
            Variable<int>(desdeEpoch),
            Variable<int>(hastaEpoch),
          ],
        )
        .getSingle();

    final bitacoraRow = await _db
        .customSelect(
          '''
      SELECT
        COALESCE(SUM(CASE WHEN lower(trim(COALESCE(estado_contenido, ''))) = 'completado' THEN 1 ELSE 0 END), 0) AS completos,
        COALESCE(SUM(CASE WHEN lower(trim(COALESCE(estado_contenido, ''))) IN ('parcial', 'en_proceso') THEN 1 ELSE 0 END), 0) AS parciales,
        COALESCE(SUM(CASE WHEN lower(trim(COALESCE(estado_contenido, ''))) = 'reprogramado' THEN 1 ELSE 0 END), 0) AS reprogramados
      FROM tabla_clases
      WHERE curso_id = ?
        AND fecha >= ?
        AND fecha < ?
      ''',
          variables: [
            Variable<int>(cursoId),
            Variable<int>(desdeEpoch),
            Variable<int>(hastaEpoch),
          ],
        )
        .getSingle();

    final historial = await listarHistorialInteligenteCurso(cursoId);
    var alto = 0;
    var medio = 0;
    var bajo = 0;
    for (final h in historial) {
      final riesgo = h.nivelRiesgo.trim().toLowerCase();
      if (riesgo == 'alto') {
        alto++;
      } else if (riesgo == 'medio') {
        medio++;
      } else {
        bajo++;
      }
    }

    final alertas = await listarAlertasAutomaticas(hastaDia, limite: 600);
    final alertasActivas = alertas.where((a) => a.cursoId == cursoId).length;

    return SintesisPeriodoCurso(
      cursoId: cursoId,
      institucion: curso.institucion,
      materia: curso.materia,
      etiquetaCurso: curso.etiquetaCurso,
      desde: desdeDia,
      hasta: hastaDia,
      clasesDictadas: cierre.clasesDictadas,
      asistenciaPorcentaje: cierre.porcentajeAsistencia,
      entregasPendientes: cierre.actividadesSinEntregar,
      trabajosSinCorregir: cierre.trabajosSinCorregir,
      evaluacionesAbiertas: evalRow.read<int>('instancias_abiertas'),
      evaluacionesRendidas: evalRow.read<int>('resultados_rendidos'),
      recuperatoriosTomados: evalRow.read<int>('recuperatorios_tomados'),
      alumnosRiesgoAlto: alto,
      alumnosRiesgoMedio: medio,
      alumnosRiesgoBajo: bajo,
      alertasActivas: alertasActivas,
      contenidosPendientes: cierre.contenidosPendientes,
      contenidosTrabajados:
          cierre.contenidosTrabajados + cierre.contenidosEvaluados,
      bitacoraCompletada: bitacoraRow.read<int>('completos'),
      bitacoraParcial: bitacoraRow.read<int>('parciales'),
      bitacoraReprogramada: bitacoraRow.read<int>('reprogramados'),
    );
  }

  Future<SintesisPeriodoAlumno> generarSintesisPeriodoAlumno({
    required int cursoId,
    required int alumnoId,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final desdeDia = DateTime(desde.year, desde.month, desde.day);
    final hastaDia = DateTime(hasta.year, hasta.month, hasta.day);
    final hastaExclusivo = hastaDia.add(const Duration(days: 1));
    final desdeEpoch = desdeDia.millisecondsSinceEpoch ~/ 1000;
    final hastaEpoch = hastaExclusivo.millisecondsSinceEpoch ~/ 1000;

    final alumnoRow = await _db
        .customSelect(
          '''
      SELECT apellido, nombre
      FROM tabla_alumnos
      WHERE id = ?
      LIMIT 1
      ''',
          variables: [Variable<int>(alumnoId)],
        )
        .getSingleOrNull();
    final alumnoNombre = alumnoRow == null
        ? 'Alumno #$alumnoId'
        : '${(alumnoRow.read<String>('apellido')).trim()}, ${(alumnoRow.read<String>('nombre')).trim()}';

    final asistenciaRow = await _db
        .customSelect(
          '''
      SELECT
        COALESCE(SUM(CASE WHEN lower(trim(COALESCE(a.estado, ''))) = 'presente' THEN 1 ELSE 0 END), 0) AS presentes,
        COALESCE(SUM(CASE WHEN lower(trim(COALESCE(a.estado, ''))) = 'ausente' THEN 1 ELSE 0 END), 0) AS ausentes,
        COALESCE(SUM(CASE WHEN lower(trim(COALESCE(a.estado, ''))) = 'tarde' THEN 1 ELSE 0 END), 0) AS tardes,
        COALESCE(SUM(CASE WHEN lower(trim(COALESCE(a.estado, ''))) = 'justificada' THEN 1 ELSE 0 END), 0) AS justificadas,
        COALESCE(SUM(CASE WHEN a.actividad_entregada = 0 AND lower(trim(COALESCE(a.estado, ''))) <> 'ausente' THEN 1 ELSE 0 END), 0) AS trabajos_pendientes,
        COALESCE(SUM(CASE WHEN a.actividad_entregada = 1 AND trim(COALESCE(a.nota_actividad, '')) = '' THEN 1 ELSE 0 END), 0) AS trabajos_sin_corregir,
        COUNT(*) AS registros
      FROM tabla_asistencias a
      INNER JOIN tabla_clases c ON c.id = a.clase_id
      WHERE c.curso_id = ?
        AND a.alumno_id = ?
        AND c.fecha >= ?
        AND c.fecha < ?
      ''',
          variables: [
            Variable<int>(cursoId),
            Variable<int>(alumnoId),
            Variable<int>(desdeEpoch),
            Variable<int>(hastaEpoch),
          ],
        )
        .getSingle();
    final presentes = asistenciaRow.read<int>('presentes');
    final ausentes = asistenciaRow.read<int>('ausentes');
    final tardes = asistenciaRow.read<int>('tardes');
    final justificadas = asistenciaRow.read<int>('justificadas');
    final registros = asistenciaRow.read<int>('registros');
    final asistenciaPct = registros <= 0
        ? 0.0
        : ((presentes + tardes + justificadas) / registros) * 100;

    final evalRows = await _db
        .customSelect(
          '''
      SELECT
        i.evaluacion_id AS evaluacion_id,
        i.orden AS orden,
        r.estado AS estado,
        r.calificacion AS calificacion
      FROM tabla_evaluaciones_alumno r
      INNER JOIN tabla_evaluaciones_instancia i
        ON i.id = r.evaluacion_instancia_id
      INNER JOIN tabla_evaluaciones_curso e
        ON e.id = i.evaluacion_id
      WHERE e.curso_id = ?
        AND r.alumno_id = ?
        AND i.fecha >= ?
        AND i.fecha < ?
      ORDER BY i.evaluacion_id ASC, i.orden DESC, i.id DESC
      ''',
          variables: [
            Variable<int>(cursoId),
            Variable<int>(alumnoId),
            Variable<int>(desdeEpoch),
            Variable<int>(hastaEpoch),
          ],
        )
        .get();

    final mejorPorEvaluacion = <int, QueryRow>{};
    final notasNumericas = <double>[];
    var recuperatoriosRendidos = 0;
    for (final row in evalRows) {
      if (row.read<int>('orden') > 0 &&
          _normalizarEstadoEvaluacionInterno(row.read<String>('estado')) !=
              'pendiente') {
        recuperatoriosRendidos++;
      }
      final evalId = row.read<int>('evaluacion_id');
      mejorPorEvaluacion.putIfAbsent(evalId, () => row);
      final n = _parsearNumeroCalificacion(row.read<String?>('calificacion'));
      if (n != null) notasNumericas.add(n);
    }

    var aprobadas = 0;
    var noAprobadas = 0;
    var pendientes = 0;
    var ausentesEval = 0;
    for (final row in mejorPorEvaluacion.values) {
      final estado = _normalizarEstadoEvaluacionInterno(
        row.read<String>('estado'),
      );
      if (estado == 'aprobado') {
        aprobadas++;
      } else if (estado == 'recuperacion') {
        noAprobadas++;
      } else if (estado == 'ausente') {
        ausentesEval++;
      } else {
        pendientes++;
      }
    }

    final promedio = notasNumericas.isEmpty
        ? null
        : notasNumericas.reduce((a, b) => a + b) / notasNumericas.length;

    final historial = await listarHistorialInteligenteCurso(cursoId);
    final h = historial.where((x) => x.alumnoId == alumnoId).toList();
    final nivelRiesgo = h.isEmpty ? 'bajo' : h.first.nivelRiesgo;

    final alertas = await listarAlertasAutomaticas(hastaDia, limite: 600);
    final alertasActivas = alertas
        .where((a) => a.cursoId == cursoId && a.alumnoId == alumnoId)
        .length;

    final condicion = _condicionCierreAlumno(
      nivelRiesgo: nivelRiesgo,
      noAprobadas: noAprobadas,
      pendientes: pendientes,
      ausentes: ausentesEval,
      trabajosPendientes: asistenciaRow.read<int>('trabajos_pendientes'),
    );

    return SintesisPeriodoAlumno(
      cursoId: cursoId,
      alumnoId: alumnoId,
      alumnoNombre: alumnoNombre.trim().replaceAll(RegExp(r'^,+\s*'), ''),
      desde: desdeDia,
      hasta: hastaDia,
      asistenciaPorcentaje: asistenciaPct,
      clasesConRegistro: registros,
      faltas: ausentes,
      trabajosPendientes: asistenciaRow.read<int>('trabajos_pendientes'),
      trabajosSinCorregir: asistenciaRow.read<int>('trabajos_sin_corregir'),
      evaluacionesRendidas: mejorPorEvaluacion.length,
      recuperatoriosRendidos: recuperatoriosRendidos,
      aprobadas: aprobadas,
      noAprobadas: noAprobadas,
      pendientes: pendientes,
      ausentes: ausentesEval,
      promedioNumerico: promedio,
      alertasActivas: alertasActivas,
      nivelRiesgo: nivelRiesgo,
      condicionCierre: condicion,
    );
  }

  String _condicionCierreAlumno({
    required String nivelRiesgo,
    required int noAprobadas,
    required int pendientes,
    required int ausentes,
    required int trabajosPendientes,
  }) {
    final riesgo = nivelRiesgo.trim().toLowerCase();
    final critico =
        riesgo == 'alto' ||
        noAprobadas >= 2 ||
        pendientes >= 2 ||
        ausentes >= 2 ||
        trabajosPendientes >= 3;
    if (critico) return 'requiere acompanamiento intensivo';

    final seguimiento =
        riesgo == 'medio' ||
        noAprobadas >= 1 ||
        pendientes >= 1 ||
        ausentes >= 1 ||
        trabajosPendientes >= 1;
    if (seguimiento) return 'en seguimiento';

    return 'trayectoria estable';
  }

  double? _parsearNumeroCalificacion(String? calificacion) {
    final t = (calificacion ?? '').trim();
    if (t.isEmpty) return null;
    final m = RegExp(r'[-+]?[0-9]*[.,]?[0-9]+').firstMatch(t);
    if (m == null) return null;
    return double.tryParse(m.group(0)!.replaceAll(',', '.'));
  }
}
