part of 'agenda_docente_repositorio.dart';

extension AgendaDocenteRepositorioPerfilComparacion
    on AgendaDocenteRepositorio {
  Future<PerfilEstableCurso> obtenerPerfilEstableCurso(int cursoId) async {
    final row = await _db
        .customSelect(
          '''
      SELECT
        curso_id,
        ritmo,
        clima,
        estrategias_funcionan,
        dificultades_frecuentes,
        autonomia,
        actualizado_en
      FROM tabla_perfil_estable_curso
      WHERE curso_id = ?
      LIMIT 1
      ''',
          variables: [Variable<int>(cursoId)],
        )
        .getSingleOrNull();

    final historial = await listarHistorialInteligenteCurso(cursoId);
    var alto = 0;
    var medio = 0;
    var bajo = 0;
    for (final h in historial) {
      final r = h.nivelRiesgo.trim().toLowerCase();
      if (r == 'alto') {
        alto++;
      } else if (r == 'medio') {
        medio++;
      } else {
        bajo++;
      }
    }

    final desde = DateTime.now().subtract(const Duration(days: 150));
    final asistenciaRow = await _db
        .customSelect(
          '''
      SELECT
        COUNT(*) AS total,
        COALESCE(
          SUM(
            CASE
              WHEN lower(trim(COALESCE(a.estado, ''))) IN ('presente', 'tarde', 'justificada')
              THEN 1 ELSE 0
            END
          ),
          0
        ) AS computables
      FROM tabla_asistencias a
      INNER JOIN tabla_clases c
        ON c.id = a.clase_id
      WHERE c.curso_id = ?
        AND c.fecha >= ?
      ''',
          variables: [Variable<int>(cursoId), Variable<DateTime>(desde)],
        )
        .getSingle();
    final totalAsis = asistenciaRow.read<int>('total');
    final computables = asistenciaRow.read<int>('computables');
    final asistenciaPct = totalAsis <= 0
        ? 0.0
        : (computables / totalAsis) * 100;

    final reiteradasRow = await _db
        .customSelect(
          '''
      SELECT COUNT(*) AS total
      FROM (
        SELECT
          a.alumno_id AS alumno_id,
          COALESCE(
            SUM(CASE WHEN lower(trim(COALESCE(a.estado, ''))) IN ('ausente', 'pendiente') THEN 1 ELSE 0 END),
            0
          ) AS faltas
        FROM tabla_asistencias a
        INNER JOIN tabla_clases c
          ON c.id = a.clase_id
        WHERE c.curso_id = ?
          AND c.fecha >= ?
        GROUP BY a.alumno_id
        HAVING faltas >= 3
      ) x
      ''',
          variables: [Variable<int>(cursoId), Variable<DateTime>(desde)],
        )
        .getSingle();

    return PerfilEstableCurso(
      cursoId: cursoId,
      ritmo: row?.read<String>('ritmo') ?? '',
      clima: row?.read<String>('clima') ?? '',
      estrategiasFuncionan: row?.read<String>('estrategias_funcionan') ?? '',
      dificultadesFrecuentes:
          row?.read<String>('dificultades_frecuentes') ?? '',
      autonomia: row?.read<String>('autonomia') ?? '',
      asistenciaHistorica: asistenciaPct,
      alumnosRiesgoAlto: alto,
      alumnosRiesgoMedio: medio,
      alumnosRiesgoBajo: bajo,
      inasistenciasReiteradas: reiteradasRow.read<int>('total'),
      actualizadoEn: row == null
          ? null
          : _fechaDesdeEpoch(row.read<int>('actualizado_en')),
    );
  }

  Future<void> guardarPerfilEstableCurso({
    required int cursoId,
    required String ritmo,
    required String clima,
    required String estrategiasFuncionan,
    required String dificultadesFrecuentes,
    required String autonomia,
  }) async {
    await _db.customStatement(
      '''
      INSERT INTO tabla_perfil_estable_curso (
        curso_id,
        ritmo,
        clima,
        estrategias_funcionan,
        dificultades_frecuentes,
        autonomia,
        actualizado_en
      ) VALUES (?, ?, ?, ?, ?, ?, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      ON CONFLICT(curso_id)
      DO UPDATE SET
        ritmo = excluded.ritmo,
        clima = excluded.clima,
        estrategias_funcionan = excluded.estrategias_funcionan,
        dificultades_frecuentes = excluded.dificultades_frecuentes,
        autonomia = excluded.autonomia,
        actualizado_en = excluded.actualizado_en
      ''',
      [
        cursoId,
        ritmo.trim(),
        clima.trim(),
        estrategiasFuncionan.trim(),
        dificultadesFrecuentes.trim(),
        autonomia.trim(),
      ],
    );
  }

  Future<ComparacionTemporalCurso> compararTemporalCurso({
    required int cursoId,
    required DateTime actualDesde,
    required DateTime actualHasta,
  }) async {
    final actual = await generarSintesisPeriodoCurso(
      cursoId: cursoId,
      desde: actualDesde,
      hasta: actualHasta,
    );
    final anteriorRango = _periodoAnterior(actualDesde, actualHasta);
    final anterior = await generarSintesisPeriodoCurso(
      cursoId: cursoId,
      desde: anteriorRango.$1,
      hasta: anteriorRango.$2,
    );
    return ComparacionTemporalCurso(actual: actual, anterior: anterior);
  }

  Future<ComparacionTemporalAlumno> compararTemporalAlumno({
    required int cursoId,
    required int alumnoId,
    required DateTime actualDesde,
    required DateTime actualHasta,
  }) async {
    final actual = await generarSintesisPeriodoAlumno(
      cursoId: cursoId,
      alumnoId: alumnoId,
      desde: actualDesde,
      hasta: actualHasta,
    );
    final anteriorRango = _periodoAnterior(actualDesde, actualHasta);
    final anterior = await generarSintesisPeriodoAlumno(
      cursoId: cursoId,
      alumnoId: alumnoId,
      desde: anteriorRango.$1,
      hasta: anteriorRango.$2,
    );
    return ComparacionTemporalAlumno(actual: actual, anterior: anterior);
  }

  (DateTime, DateTime) _periodoAnterior(DateTime desde, DateTime hasta) {
    final d = DateTime(desde.year, desde.month, desde.day);
    final h = DateTime(hasta.year, hasta.month, hasta.day);
    final dias = h.difference(d).inDays + 1;
    final anteriorHasta = d.subtract(const Duration(days: 1));
    final anteriorDesde = anteriorHasta.subtract(Duration(days: dias - 1));
    return (anteriorDesde, anteriorHasta);
  }
}
