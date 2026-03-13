part of 'agenda_docente_repositorio.dart';

extension AgendaDocenteRepositorioEvaluacionesHistorial
    on AgendaDocenteRepositorio {
  Future<List<EvaluacionCurso>> listarEvaluacionesCurso(
    int cursoId, {
    int limite = 40,
  }) async {
    final rows = await _db
        .customSelect(
          '''
      SELECT
        e.id,
        e.curso_id,
        e.fecha,
        e.tipo,
        e.titulo,
        e.descripcion,
        e.estado
      FROM tabla_evaluaciones_curso e
      WHERE e.curso_id = ?
      ORDER BY e.fecha DESC, e.id DESC
      LIMIT ?
      ''',
          variables: [Variable<int>(cursoId), Variable<int>(limite)],
        )
        .get();

    final salida = <EvaluacionCurso>[];
    for (final r in rows) {
      final evaluacionId = r.read<int>('id');
      final resumen = await _resumenProcesoEvaluacion(evaluacionId);
      final recuperatorios = resumen.totalInstancias <= 1
          ? 0
          : resumen.totalInstancias - 1;
      salida.add(
        EvaluacionCurso(
          id: evaluacionId,
          cursoId: r.read<int>('curso_id'),
          fecha: _fechaDesdeEpoch(r.read<int>('fecha')),
          tipo: r.read<String>('tipo'),
          titulo: r.read<String>('titulo'),
          descripcion: r.read<String?>('descripcion'),
          estado: r.read<String>('estado'),
          totalAlumnos: resumen.totalAlumnos,
          resultadosCargados: resumen.resultadosCargados,
          aprobados: resumen.aprobadosFinales,
          enProceso: resumen.pendientesFinales,
          recuperacion: resumen.noAprobadosFinales,
          pendientes: resumen.pendientesFinales,
          instancias: resumen.totalInstancias,
          recuperatoriosGenerados: recuperatorios,
          aprobadosPrimeraInstancia: resumen.aprobadosPrimeraInstancia,
          fueronARecuperatorio: resumen.fueronARecuperatorio,
          aprobaronLuegoRecuperatorio: resumen.aprobaronLuegoRecuperatorio,
          ausentesFinales: resumen.ausentesFinales,
          noAprobadosFinales: resumen.noAprobadosFinales,
        ),
      );
    }
    return salida;
  }

  Future<int> crearEvaluacionCurso({
    required int cursoId,
    required DateTime fecha,
    required String tipo,
    required String titulo,
    String? descripcion,
  }) async {
    final fechaEpoch =
        DateTime(fecha.year, fecha.month, fecha.day).millisecondsSinceEpoch ~/
        1000;
    await _db.customStatement(
      '''
      INSERT INTO tabla_evaluaciones_curso (
        curso_id,
        fecha,
        tipo,
        titulo,
        descripcion,
        estado,
        creado_en,
        actualizado_en
      ) VALUES (?, ?, ?, ?, ?, 'abierta', CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER), CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      ''',
      [
        cursoId,
        fechaEpoch,
        tipo.trim(),
        titulo.trim(),
        _nullSiVacio(descripcion),
      ],
    );
    final row = await _db
        .customSelect('SELECT last_insert_rowid() AS id')
        .getSingle();
    final evaluacionId = row.read<int>('id');
    final contextoCurso = await _contextoCurso(cursoId);
    await _registrarAuditoriaCambio(
      entidad: 'evaluacion',
      entidadId: evaluacionId,
      campo: 'creacion',
      valorAnterior: null,
      valorNuevo:
          'fecha=$fechaEpoch | tipo=${tipo.trim()} | titulo=${titulo.trim()} | estado=abierta',
      contexto: 'Evaluacion creada',
      cursoId: cursoId,
      institucion: contextoCurso?.institucion,
    );
    await _crearInstanciaOriginalSiFalta(evaluacionId);
    return evaluacionId;
  }

  Future<void> actualizarEvaluacionCurso({
    required int evaluacionId,
    required DateTime fecha,
    required String tipo,
    required String titulo,
    String? descripcion,
  }) async {
    final previo = await _db
        .customSelect(
          '''
      SELECT curso_id, fecha, tipo, titulo, descripcion
      FROM tabla_evaluaciones_curso
      WHERE id = ?
      LIMIT 1
      ''',
          variables: [Variable<int>(evaluacionId)],
        )
        .getSingleOrNull();
    final contexto = await _contextoEvaluacion(evaluacionId);
    final fechaEpoch =
        DateTime(fecha.year, fecha.month, fecha.day).millisecondsSinceEpoch ~/
        1000;
    await _db.customStatement(
      '''
      UPDATE tabla_evaluaciones_curso
      SET
        fecha = ?,
        tipo = ?,
        titulo = ?,
        descripcion = ?,
        actualizado_en = CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)
      WHERE id = ?
      ''',
      [
        fechaEpoch,
        tipo.trim(),
        titulo.trim(),
        _nullSiVacio(descripcion),
        evaluacionId,
      ],
    );
    final original = await _instanciaOriginal(evaluacionId);
    if (original != null) {
      await _db.customStatement(
        '''
        UPDATE tabla_evaluaciones_instancia
        SET
          fecha = ?,
          observacion = ?,
          actualizado_en = CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)
        WHERE id = ?
        ''',
        [fechaEpoch, _nullSiVacio(descripcion), original.id],
      );
    } else {
      await _crearInstanciaOriginalSiFalta(evaluacionId);
    }
    final previoResumen = previo == null
        ? null
        : 'fecha=${previo.read<int>('fecha')} | tipo=${previo.read<String>('tipo')} | titulo=${previo.read<String>('titulo')} | desc=${previo.read<String?>('descripcion') ?? ''}';
    final nuevoResumen =
        'fecha=$fechaEpoch | tipo=${tipo.trim()} | titulo=${titulo.trim()} | desc=${_nullSiVacio(descripcion) ?? ''}';
    await _registrarAuditoriaCambio(
      entidad: 'evaluacion',
      entidadId: evaluacionId,
      campo: 'edicion',
      valorAnterior: previoResumen,
      valorNuevo: nuevoResumen,
      contexto: 'Actualizacion de evaluacion',
      cursoId: contexto?.cursoId ?? previo?.read<int>('curso_id'),
      institucion: contexto?.institucion,
    );
  }

  Future<void> actualizarEstadoEvaluacion({
    required int evaluacionId,
    required String estado,
  }) async {
    final previo = await _db
        .customSelect(
          '''
      SELECT estado
      FROM tabla_evaluaciones_curso
      WHERE id = ?
      LIMIT 1
      ''',
          variables: [Variable<int>(evaluacionId)],
        )
        .getSingleOrNull();
    final estadoPrevio = previo?.read<String>('estado');
    final estadoNormalizado = estado.trim().toLowerCase() == 'cerrada'
        ? 'cerrada'
        : 'abierta';
    final contexto = await _contextoEvaluacion(evaluacionId);
    await _db.customStatement(
      '''
      UPDATE tabla_evaluaciones_curso
      SET
        estado = ?,
        actualizado_en = CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)
      WHERE id = ?
      ''',
      [estadoNormalizado, evaluacionId],
    );

    final ultima = await _ultimaInstanciaEvaluacion(evaluacionId);
    if (ultima != null) {
      await _db.customStatement(
        '''
        UPDATE tabla_evaluaciones_instancia
        SET
          estado = ?,
          actualizado_en = CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)
        WHERE id = ?
        ''',
        [estadoNormalizado, ultima.id],
      );
    }
    await _registrarAuditoriaCambio(
      entidad: 'evaluacion',
      entidadId: evaluacionId,
      campo: 'estado',
      valorAnterior: estadoPrevio,
      valorNuevo: estadoNormalizado,
      contexto: 'Estado de evaluacion',
      cursoId: contexto?.cursoId,
      institucion: contexto?.institucion,
    );
  }

  Future<void> actualizarEstadoInstanciaEvaluacion({
    required int instanciaId,
    required String estado,
  }) async {
    final estadoNormalizado = estado.trim().toLowerCase() == 'cerrada'
        ? 'cerrada'
        : 'abierta';
    final estadoPrevioRow = await _db
        .customSelect(
          '''
      SELECT evaluacion_id, estado
      FROM tabla_evaluaciones_instancia
      WHERE id = ?
      LIMIT 1
      ''',
          variables: [Variable<int>(instanciaId)],
        )
        .getSingleOrNull();
    final evaluacionIdPrevio = estadoPrevioRow?.read<int>('evaluacion_id');
    final estadoPrevio = estadoPrevioRow?.read<String>('estado');
    if (estadoNormalizado == 'cerrada') {
      final countRow = await _db
          .customSelect(
            '''
        SELECT COUNT(*) AS total
        FROM tabla_evaluaciones_alumno
        WHERE evaluacion_instancia_id = ?
        ''',
            variables: [Variable<int>(instanciaId)],
          )
          .getSingle();
      if (countRow.read<int>('total') <= 0) {
        throw StateError('No se puede cerrar una instancia sin resultados');
      }
    }

    await _db.customStatement(
      '''
      UPDATE tabla_evaluaciones_instancia
      SET
        estado = ?,
        actualizado_en = CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)
      WHERE id = ?
      ''',
      [estadoNormalizado, instanciaId],
    );

    final row = await _db
        .customSelect(
          '''
      SELECT evaluacion_id
      FROM tabla_evaluaciones_instancia
      WHERE id = ?
      LIMIT 1
      ''',
          variables: [Variable<int>(instanciaId)],
        )
        .getSingleOrNull();
    if (row == null) return;
    final evaluacionId = row.read<int>('evaluacion_id');
    final contexto = await _contextoEvaluacion(evaluacionId);
    final ultima = await _ultimaInstanciaEvaluacion(evaluacionId);
    if (ultima == null) return;
    await _db.customStatement(
      '''
      UPDATE tabla_evaluaciones_curso
      SET
        estado = ?,
        actualizado_en = CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)
      WHERE id = ?
      ''',
      [ultima.estado, evaluacionId],
    );
    if (evaluacionIdPrevio != null) {
      await _registrarAuditoriaCambio(
        entidad: 'evaluacion_instancia',
        entidadId: instanciaId,
        campo: 'estado',
        valorAnterior: estadoPrevio,
        valorNuevo: estadoNormalizado,
        contexto: 'Instancia de evaluacion $evaluacionIdPrevio',
        cursoId: contexto?.cursoId,
        institucion: contexto?.institucion,
      );
    }
  }

  Future<void> eliminarEvaluacionCurso(int evaluacionId) async {
    final previo = await _db
        .customSelect(
          '''
      SELECT fecha, tipo, titulo, descripcion
      FROM tabla_evaluaciones_curso
      WHERE id = ?
      LIMIT 1
      ''',
          variables: [Variable<int>(evaluacionId)],
        )
        .getSingleOrNull();
    final contexto = await _contextoEvaluacion(evaluacionId);
    await _db.customStatement(
      'DELETE FROM tabla_evaluaciones_curso WHERE id = ?',
      [evaluacionId],
    );
    final previoResumen = previo == null
        ? null
        : 'fecha=${previo.read<int>('fecha')} | tipo=${previo.read<String>('tipo')} | titulo=${previo.read<String>('titulo')} | desc=${previo.read<String?>('descripcion') ?? ''}';
    await _registrarAuditoriaCambio(
      entidad: 'evaluacion',
      entidadId: evaluacionId,
      campo: 'eliminacion',
      valorAnterior: previoResumen,
      valorNuevo: null,
      contexto: 'Evaluacion eliminada',
      cursoId: contexto?.cursoId,
      institucion: contexto?.institucion,
    );
  }

  Future<List<EvaluacionInstancia>> listarInstanciasEvaluacion(
    int evaluacionId,
  ) async {
    await _crearInstanciaOriginalSiFalta(evaluacionId);
    final rows = await _db
        .customSelect(
          '''
      SELECT
        i.id,
        i.evaluacion_id,
        i.tipo_instancia,
        i.orden,
        i.fecha,
        i.observacion,
        i.estado,
        COUNT(r.id) AS resultados_cargados,
        COALESCE(
          SUM(CASE WHEN lower(trim(COALESCE(r.estado, ''))) = 'aprobado' THEN 1 ELSE 0 END),
          0
        ) AS aprobados,
        COALESCE(
          SUM(CASE WHEN lower(trim(COALESCE(r.estado, ''))) IN ('recuperacion', 'recupera', 'recuperatorio') THEN 1 ELSE 0 END),
          0
        ) AS no_aprobados,
        COALESCE(
          SUM(CASE WHEN lower(trim(COALESCE(r.estado, ''))) IN ('pendiente', 'en_proceso', 'proceso') THEN 1 ELSE 0 END),
          0
        ) AS pendientes,
        COALESCE(
          SUM(CASE WHEN lower(trim(COALESCE(r.estado, ''))) = 'ausente' THEN 1 ELSE 0 END),
          0
        ) AS ausentes
      FROM tabla_evaluaciones_instancia i
      LEFT JOIN tabla_evaluaciones_alumno r
        ON r.evaluacion_instancia_id = i.id
      WHERE i.evaluacion_id = ?
      GROUP BY
        i.id,
        i.evaluacion_id,
        i.tipo_instancia,
        i.orden,
        i.fecha,
        i.observacion,
        i.estado
      ORDER BY i.orden ASC, i.id ASC
      ''',
          variables: [Variable<int>(evaluacionId)],
        )
        .get();

    return rows
        .map(
          (r) => EvaluacionInstancia(
            id: r.read<int>('id'),
            evaluacionId: r.read<int>('evaluacion_id'),
            tipoInstancia: r.read<String>('tipo_instancia'),
            orden: r.read<int>('orden'),
            fecha: _fechaDesdeEpoch(r.read<int>('fecha')),
            observacion: r.read<String?>('observacion'),
            estado: r.read<String>('estado'),
            resultadosCargados: r.read<int>('resultados_cargados'),
            aprobados: r.read<int>('aprobados'),
            noAprobados: r.read<int>('no_aprobados'),
            pendientes: r.read<int>('pendientes'),
            ausentes: r.read<int>('ausentes'),
          ),
        )
        .toList(growable: false);
  }

  Future<int> generarRecuperatorioEvaluacion({
    required int evaluacionId,
    DateTime? fecha,
    String? observacion,
  }) async {
    await _crearInstanciaOriginalSiFalta(evaluacionId);
    final contexto = await _contextoEvaluacion(evaluacionId);
    if (contexto == null) {
      throw StateError('Evaluacion inexistente');
    }
    final regla = await obtenerReglaInstitucion(contexto.institucion);
    final instancias = await listarInstanciasEvaluacion(evaluacionId);
    final ultima = instancias.isEmpty ? null : instancias.last;
    if (ultima == null) {
      throw StateError('No se encontro una instancia base para la evaluacion');
    }
    if (!ultima.cerrada) {
      throw StateError('La instancia actual debe estar cerrada');
    }

    final recuperatoriosGenerados = instancias.where((i) => i.orden > 0).length;
    if (recuperatoriosGenerados >= regla.maxRecuperatorios) {
      throw StateError('La institucion no permite mas recuperatorios');
    }

    final consolidado = await _consolidadoPorAlumnoEvaluacion(
      evaluacionId: evaluacionId,
      institucion: contexto.institucion,
    );
    final elegibles = <int>[];
    for (final entry in consolidado.entries) {
      if (entry.value.condicionFinal != 'aprobado') {
        elegibles.add(entry.key);
      }
    }
    if (elegibles.isEmpty) {
      throw StateError('No hay alumnos elegibles para recuperatorio');
    }

    final fechaInstancia = DateTime(
      (fecha ?? DateTime.now()).year,
      (fecha ?? DateTime.now()).month,
      (fecha ?? DateTime.now()).day,
    );
    final fechaEpoch = fechaInstancia.millisecondsSinceEpoch ~/ 1000;
    final orden = ultima.orden + 1;
    final tipo = 'recuperatorio_$orden';

    await _db.customStatement(
      '''
      INSERT INTO tabla_evaluaciones_instancia (
        evaluacion_id,
        tipo_instancia,
        orden,
        fecha,
        observacion,
        estado,
        creado_en,
        actualizado_en
      ) VALUES (?, ?, ?, ?, ?, 'abierta', CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER), CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      ''',
      [evaluacionId, tipo, orden, fechaEpoch, _nullSiVacio(observacion)],
    );
    final row = await _db
        .customSelect('SELECT last_insert_rowid() AS id')
        .getSingle();
    final instanciaId = row.read<int>('id');

    for (final alumnoId in elegibles) {
      await _db.customStatement(
        '''
        INSERT INTO tabla_evaluaciones_alumno (
          evaluacion_id,
          evaluacion_instancia_id,
          alumno_id,
          estado,
          calificacion,
          entrega_complementaria,
          ausente_justificado,
          observacion,
          actualizado_en
        ) VALUES (?, ?, ?, 'pendiente', NULL, 0, 0, NULL, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
        ON CONFLICT(evaluacion_instancia_id, alumno_id)
        DO NOTHING
        ''',
        [evaluacionId, instanciaId, alumnoId],
      );
    }

    await _db.customStatement(
      '''
      UPDATE tabla_evaluaciones_curso
      SET
        estado = 'abierta',
        actualizado_en = CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)
      WHERE id = ?
      ''',
      [evaluacionId],
    );
    return instanciaId;
  }

  Future<List<ResultadoEvaluacionAlumno>> listarResultadosEvaluacion(
    int evaluacionId, {
    int? evaluacionInstanciaId,
  }) async {
    await _crearInstanciaOriginalSiFalta(evaluacionId);
    final contexto = await _contextoEvaluacion(evaluacionId);
    if (contexto == null) return const [];

    final instancias = await listarInstanciasEvaluacion(evaluacionId);
    if (instancias.isEmpty) return const [];

    var instancia = instancias.last;
    if (evaluacionInstanciaId != null) {
      for (final i in instancias) {
        if (i.id == evaluacionInstanciaId) {
          instancia = i;
          break;
        }
      }
    }

    final consolidado = await _consolidadoPorAlumnoEvaluacion(
      evaluacionId: evaluacionId,
      institucion: contexto.institucion,
    );

    if (instancia.esOriginal) {
      final rows = await _db
          .customSelect(
            '''
        SELECT
          a.id AS alumno_id,
          a.apellido AS apellido,
          a.nombre AS nombre,
          r.id AS resultado_id,
          r.estado AS estado,
          r.calificacion AS calificacion,
          r.entrega_complementaria AS entrega_complementaria,
          r.ausente_justificado AS ausente_justificado,
          r.observacion AS observacion
        FROM tabla_alumnos a
        INNER JOIN tabla_inscripciones i
          ON i.alumno_id = a.id
         AND i.curso_id = ?
         AND i.activo = 1
        LEFT JOIN tabla_evaluaciones_alumno r
          ON r.evaluacion_instancia_id = ?
         AND r.alumno_id = a.id
        WHERE a.activo = 1
        ORDER BY a.apellido ASC, a.nombre ASC
        ''',
            variables: [
              Variable<int>(contexto.cursoId),
              Variable<int>(instancia.id),
            ],
          )
          .get();

      return rows
          .map((row) {
            final alumnoId = row.read<int>('alumno_id');
            final apellido = row.read<String>('apellido').trim();
            final nombre = row.read<String>('nombre').trim();
            final alumnoNombre = apellido.isEmpty
                ? nombre
                : '$apellido, $nombre';
            final estadoRaw = (row.read<String?>('estado') ?? '').trim();
            final estado = estadoRaw.isEmpty ? 'pendiente' : estadoRaw;
            final finalAlumno =
                consolidado[alumnoId] ?? const _FinalAlumnoEvaluacion();
            return ResultadoEvaluacionAlumno(
              id: row.read<int?>('resultado_id'),
              evaluacionId: evaluacionId,
              evaluacionInstanciaId: instancia.id,
              instanciaTipo: instancia.tipoInstancia,
              instanciaOrden: instancia.orden,
              instanciaFecha: instancia.fecha,
              alumnoId: alumnoId,
              alumnoNombre: alumnoNombre,
              estado: estado,
              calificacion: row.read<String?>('calificacion'),
              entregaComplementaria:
                  (row.read<int?>('entrega_complementaria') ?? 0) == 1,
              ausenteJustificado:
                  (row.read<int?>('ausente_justificado') ?? 0) == 1,
              observacion: row.read<String?>('observacion'),
              condicionFinal: finalAlumno.condicionFinal,
              calificacionVigente: finalAlumno.calificacionVigente,
              elegibleRecuperatorio: finalAlumno.condicionFinal != 'aprobado',
            );
          })
          .toList(growable: false);
    }

    final rows = await _db
        .customSelect(
          '''
      SELECT
        r.id AS resultado_id,
        r.alumno_id AS alumno_id,
        a.apellido AS apellido,
        a.nombre AS nombre,
        r.estado AS estado,
        r.calificacion AS calificacion,
        r.entrega_complementaria AS entrega_complementaria,
        r.ausente_justificado AS ausente_justificado,
        r.observacion AS observacion
      FROM tabla_evaluaciones_alumno r
      INNER JOIN tabla_alumnos a ON a.id = r.alumno_id
      INNER JOIN tabla_inscripciones i
        ON i.alumno_id = a.id
       AND i.curso_id = ?
       AND i.activo = 1
      WHERE r.evaluacion_instancia_id = ?
        AND a.activo = 1
      ORDER BY a.apellido ASC, a.nombre ASC
      ''',
          variables: [
            Variable<int>(contexto.cursoId),
            Variable<int>(instancia.id),
          ],
        )
        .get();

    return rows
        .map((row) {
          final alumnoId = row.read<int>('alumno_id');
          final apellido = row.read<String>('apellido').trim();
          final nombre = row.read<String>('nombre').trim();
          final alumnoNombre = apellido.isEmpty ? nombre : '$apellido, $nombre';
          final finalAlumno =
              consolidado[alumnoId] ?? const _FinalAlumnoEvaluacion();
          return ResultadoEvaluacionAlumno(
            id: row.read<int?>('resultado_id'),
            evaluacionId: evaluacionId,
            evaluacionInstanciaId: instancia.id,
            instanciaTipo: instancia.tipoInstancia,
            instanciaOrden: instancia.orden,
            instanciaFecha: instancia.fecha,
            alumnoId: alumnoId,
            alumnoNombre: alumnoNombre,
            estado: row.read<String>('estado'),
            calificacion: row.read<String?>('calificacion'),
            entregaComplementaria:
                (row.read<int?>('entrega_complementaria') ?? 0) == 1,
            ausenteJustificado:
                (row.read<int?>('ausente_justificado') ?? 0) == 1,
            observacion: row.read<String?>('observacion'),
            condicionFinal: finalAlumno.condicionFinal,
            calificacionVigente: finalAlumno.calificacionVigente,
            elegibleRecuperatorio: finalAlumno.condicionFinal != 'aprobado',
          );
        })
        .toList(growable: false);
  }

  Future<void> guardarResultadoEvaluacion({
    required int evaluacionId,
    int? evaluacionInstanciaId,
    required int alumnoId,
    required String estado,
    String? calificacion,
    required bool entregaComplementaria,
    bool ausenteJustificado = false,
    String? observacion,
  }) async {
    await _crearInstanciaOriginalSiFalta(evaluacionId);
    final contexto = await _contextoEvaluacion(evaluacionId);
    final instancias = await listarInstanciasEvaluacion(evaluacionId);
    if (instancias.isEmpty) {
      throw StateError('No se encontro instancia para la evaluacion');
    }
    var instancia = instancias.last;
    if (evaluacionInstanciaId != null) {
      for (final item in instancias) {
        if (item.id == evaluacionInstanciaId) {
          instancia = item;
          break;
        }
      }
    }

    if (instancia.orden > 0) {
      final consolidadoPrevio = await _consolidadoPorAlumnoEvaluacion(
        evaluacionId: evaluacionId,
        institucion:
            (await _contextoEvaluacion(evaluacionId))?.institucion ?? '',
        hastaOrden: instancia.orden - 1,
      );
      final previo = consolidadoPrevio[alumnoId];
      if (previo != null && previo.condicionFinal == 'aprobado') {
        throw StateError(
          'No se puede cargar recuperatorio para un alumno ya aprobado',
        );
      }
    }

    final estadoNormalizado = _normalizarEstadoEvaluacionInterno(estado);
    final estadoFinal = await _resolverEstadoEvaluacionSegunRegla(
      evaluacionId: evaluacionId,
      estadoActual: estadoNormalizado,
      calificacion: calificacion,
    );
    final calificacionNormalizada = _nullSiVacio(calificacion);
    if (estadoFinal == 'ausente' && calificacionNormalizada != null) {
      throw StateError(
        'Estado incompatible: un ausente no puede tener calificacion',
      );
    }
    if (estadoFinal != 'ausente' && ausenteJustificado) {
      throw StateError(
        'Estado incompatible: solo se puede justificar ausencia si el estado es Ausente',
      );
    }
    final calificacionFinal = estadoFinal == 'ausente'
        ? null
        : calificacionNormalizada;
    final previoRow = await _db
        .customSelect(
          '''
      SELECT estado, calificacion, entrega_complementaria, ausente_justificado, observacion
      FROM tabla_evaluaciones_alumno
      WHERE evaluacion_instancia_id = ? AND alumno_id = ?
      LIMIT 1
      ''',
          variables: [Variable<int>(instancia.id), Variable<int>(alumnoId)],
        )
        .getSingleOrNull();
    final previoResumen = previoRow == null
        ? null
        : 'estado=${previoRow.read<String>('estado')} | nota=${previoRow.read<String?>('calificacion') ?? ''} | comp=${(previoRow.read<int?>('entrega_complementaria') ?? 0) == 1 ? 'si' : 'no'} | aus_just=${(previoRow.read<int?>('ausente_justificado') ?? 0) == 1 ? 'si' : 'no'} | obs=${previoRow.read<String?>('observacion') ?? ''}';
    final nuevoResumen =
        'estado=$estadoFinal | nota=${calificacionFinal ?? ''} | comp=${entregaComplementaria ? 'si' : 'no'} | aus_just=${ausenteJustificado ? 'si' : 'no'} | obs=${_nullSiVacio(observacion) ?? ''}';

    await _db.customStatement(
      '''
      INSERT INTO tabla_evaluaciones_alumno (
        evaluacion_id,
        evaluacion_instancia_id,
        alumno_id,
        estado,
        calificacion,
        entrega_complementaria,
        ausente_justificado,
        observacion,
        actualizado_en
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      ON CONFLICT(evaluacion_instancia_id, alumno_id)
      DO UPDATE SET
        estado = excluded.estado,
        calificacion = excluded.calificacion,
        entrega_complementaria = excluded.entrega_complementaria,
        ausente_justificado = excluded.ausente_justificado,
        observacion = excluded.observacion,
        actualizado_en = excluded.actualizado_en
      ''',
      [
        evaluacionId,
        instancia.id,
        alumnoId,
        estadoFinal,
        calificacionFinal,
        entregaComplementaria ? 1 : 0,
        ausenteJustificado ? 1 : 0,
        _nullSiVacio(observacion),
      ],
    );
    await _registrarAuditoriaCambio(
      entidad: 'evaluacion_resultado',
      entidadId: evaluacionId,
      campo: 'resultado_alumno',
      valorAnterior: previoResumen,
      valorNuevo: nuevoResumen,
      contexto:
          'Evaluacion $evaluacionId | instancia ${instancia.id} | alumno $alumnoId',
      cursoId: contexto?.cursoId,
      institucion: contexto?.institucion,
    );
  }

  Future<_EvaluacionContexto?> _contextoEvaluacion(int evaluacionId) async {
    final row = await _db
        .customSelect(
          '''
      SELECT
        e.id AS evaluacion_id,
        e.curso_id AS curso_id,
        COALESCE(NULLIF(TRIM(i.nombre), ''), NULLIF(TRIM(c.turno), ''), 'Sin institucion') AS institucion
      FROM tabla_evaluaciones_curso e
      INNER JOIN tabla_cursos c ON c.id = e.curso_id
      LEFT JOIN tabla_instituciones i ON i.id = c.institucion_id
      WHERE e.id = ?
      LIMIT 1
      ''',
          variables: [Variable<int>(evaluacionId)],
        )
        .getSingleOrNull();
    if (row == null) return null;
    return _EvaluacionContexto(
      evaluacionId: row.read<int>('evaluacion_id'),
      cursoId: row.read<int>('curso_id'),
      institucion: row.read<String>('institucion'),
    );
  }

  Future<_CursoContexto?> _contextoCurso(int cursoId) async {
    final row = await _db
        .customSelect(
          '''
      SELECT
        c.id AS curso_id,
        COALESCE(NULLIF(TRIM(i.nombre), ''), NULLIF(TRIM(c.turno), ''), 'Sin institucion') AS institucion
      FROM tabla_cursos c
      LEFT JOIN tabla_instituciones i ON i.id = c.institucion_id
      WHERE c.id = ?
      LIMIT 1
      ''',
          variables: [Variable<int>(cursoId)],
        )
        .getSingleOrNull();
    if (row == null) return null;
    return _CursoContexto(
      cursoId: row.read<int>('curso_id'),
      institucion: row.read<String>('institucion'),
    );
  }

  Future<_EvaluacionInstanciaMeta?> _instanciaOriginal(int evaluacionId) async {
    final row = await _db
        .customSelect(
          '''
      SELECT id, evaluacion_id, tipo_instancia, orden, fecha, estado
      FROM tabla_evaluaciones_instancia
      WHERE evaluacion_id = ?
      ORDER BY orden ASC, id ASC
      LIMIT 1
      ''',
          variables: [Variable<int>(evaluacionId)],
        )
        .getSingleOrNull();
    if (row == null) return null;
    return _EvaluacionInstanciaMeta(
      id: row.read<int>('id'),
      evaluacionId: row.read<int>('evaluacion_id'),
      tipoInstancia: row.read<String>('tipo_instancia'),
      orden: row.read<int>('orden'),
      fecha: _fechaDesdeEpoch(row.read<int>('fecha')),
      estado: row.read<String>('estado'),
    );
  }

  Future<_EvaluacionInstanciaMeta?> _ultimaInstanciaEvaluacion(
    int evaluacionId,
  ) async {
    final row = await _db
        .customSelect(
          '''
      SELECT id, evaluacion_id, tipo_instancia, orden, fecha, estado
      FROM tabla_evaluaciones_instancia
      WHERE evaluacion_id = ?
      ORDER BY orden DESC, id DESC
      LIMIT 1
      ''',
          variables: [Variable<int>(evaluacionId)],
        )
        .getSingleOrNull();
    if (row == null) return null;
    return _EvaluacionInstanciaMeta(
      id: row.read<int>('id'),
      evaluacionId: row.read<int>('evaluacion_id'),
      tipoInstancia: row.read<String>('tipo_instancia'),
      orden: row.read<int>('orden'),
      fecha: _fechaDesdeEpoch(row.read<int>('fecha')),
      estado: row.read<String>('estado'),
    );
  }

  Future<void> _crearInstanciaOriginalSiFalta(int evaluacionId) async {
    final existente = await _instanciaOriginal(evaluacionId);
    if (existente != null) return;
    await _db.customStatement(
      '''
      INSERT INTO tabla_evaluaciones_instancia (
        evaluacion_id,
        tipo_instancia,
        orden,
        fecha,
        observacion,
        estado,
        creado_en,
        actualizado_en
      )
      SELECT
        e.id,
        'original',
        0,
        e.fecha,
        e.descripcion,
        COALESCE(NULLIF(TRIM(e.estado), ''), 'abierta'),
        e.creado_en,
        e.actualizado_en
      FROM tabla_evaluaciones_curso e
      WHERE e.id = ?
      LIMIT 1
      ''',
      [evaluacionId],
    );
  }

  Future<List<int>> _alumnosActivosCurso(int cursoId) async {
    final rows = await _db
        .customSelect(
          '''
      SELECT a.id AS alumno_id
      FROM tabla_alumnos a
      INNER JOIN tabla_inscripciones i
        ON i.alumno_id = a.id
       AND i.curso_id = ?
       AND i.activo = 1
      WHERE a.activo = 1
      ORDER BY a.apellido ASC, a.nombre ASC
      ''',
          variables: [Variable<int>(cursoId)],
        )
        .get();
    return rows.map((r) => r.read<int>('alumno_id')).toList(growable: false);
  }

  Future<_ResumenProcesoEvaluacion> _resumenProcesoEvaluacion(
    int evaluacionId,
  ) async {
    final contexto = await _contextoEvaluacion(evaluacionId);
    if (contexto == null) return const _ResumenProcesoEvaluacion();
    final alumnos = await _alumnosActivosCurso(contexto.cursoId);
    final consolidado = await _consolidadoPorAlumnoEvaluacion(
      evaluacionId: evaluacionId,
      institucion: contexto.institucion,
    );
    final instancias = await listarInstanciasEvaluacion(evaluacionId);

    var aprobados = 0;
    var noAprobados = 0;
    var pendientes = 0;
    var ausentes = 0;
    var aprobadosPrimera = 0;
    var fueronRecup = 0;
    var aprobaronDespues = 0;

    for (final alumnoId in alumnos) {
      final c = consolidado[alumnoId] ?? _FinalAlumnoEvaluacion();
      switch (c.condicionFinal) {
        case 'aprobado':
          aprobados++;
          if (c.ordenPrimerAprobado == 0) {
            aprobadosPrimera++;
          } else if ((c.ordenPrimerAprobado ?? 0) > 0) {
            aprobaronDespues++;
          }
          break;
        case 'no_aprobado':
          noAprobados++;
          break;
        case 'ausente':
          ausentes++;
          break;
        case 'pendiente':
        default:
          pendientes++;
      }
      if (c.participoRecuperatorio) {
        fueronRecup++;
      }
    }

    final resultadosCargados = await _db
        .customSelect(
          '''
      SELECT COUNT(*) AS total
      FROM tabla_evaluaciones_alumno
      WHERE evaluacion_id = ?
      ''',
          variables: [Variable<int>(evaluacionId)],
        )
        .getSingle();

    return _ResumenProcesoEvaluacion(
      totalAlumnos: alumnos.length,
      resultadosCargados: resultadosCargados.read<int>('total'),
      aprobadosFinales: aprobados,
      noAprobadosFinales: noAprobados,
      pendientesFinales: pendientes,
      ausentesFinales: ausentes,
      aprobadosPrimeraInstancia: aprobadosPrimera,
      fueronARecuperatorio: fueronRecup,
      aprobaronLuegoRecuperatorio: aprobaronDespues,
      totalInstancias: instancias.length,
    );
  }

  Future<Map<int, _FinalAlumnoEvaluacion>> _consolidadoPorAlumnoEvaluacion({
    required int evaluacionId,
    required String institucion,
    int? hastaOrden,
  }) async {
    final regla = await obtenerReglaInstitucion(institucion);
    final query = hastaOrden == null
        ? '''
      SELECT
        r.alumno_id AS alumno_id,
        i.orden AS orden,
        i.tipo_instancia AS tipo_instancia,
        r.estado AS estado,
        r.calificacion AS calificacion,
        r.ausente_justificado AS ausente_justificado
      FROM tabla_evaluaciones_alumno r
      INNER JOIN tabla_evaluaciones_instancia i
        ON i.id = r.evaluacion_instancia_id
      WHERE i.evaluacion_id = ?
      ORDER BY r.alumno_id ASC, i.orden ASC, i.id ASC
      '''
        : '''
      SELECT
        r.alumno_id AS alumno_id,
        i.orden AS orden,
        i.tipo_instancia AS tipo_instancia,
        r.estado AS estado,
        r.calificacion AS calificacion,
        r.ausente_justificado AS ausente_justificado
      FROM tabla_evaluaciones_alumno r
      INNER JOIN tabla_evaluaciones_instancia i
        ON i.id = r.evaluacion_instancia_id
      WHERE i.evaluacion_id = ?
        AND i.orden <= ?
      ORDER BY r.alumno_id ASC, i.orden ASC, i.id ASC
      ''';

    final variables = <Variable<Object>>[Variable<int>(evaluacionId)];
    if (hastaOrden != null) {
      variables.add(Variable<int>(hastaOrden));
    }

    final rows = await _db.customSelect(query, variables: variables).get();

    final porAlumno = <int, List<_ResultadoOrdenado>>{};
    for (final row in rows) {
      final alumnoId = row.read<int>('alumno_id');
      porAlumno
          .putIfAbsent(alumnoId, () => <_ResultadoOrdenado>[])
          .add(
            _ResultadoOrdenado(
              orden: row.read<int>('orden'),
              tipoInstancia: row.read<String>('tipo_instancia'),
              estado: row.read<String>('estado'),
              calificacion: row.read<String?>('calificacion'),
              ausenteJustificado:
                  (row.read<int?>('ausente_justificado') ?? 0) == 1,
            ),
          );
    }

    final out = <int, _FinalAlumnoEvaluacion>{};
    for (final entry in porAlumno.entries) {
      out[entry.key] = _consolidarResultadosAlumno(entry.value, regla);
    }
    return out;
  }

  _FinalAlumnoEvaluacion _consolidarResultadosAlumno(
    List<_ResultadoOrdenado> intentos,
    ReglaInstitucion regla,
  ) {
    if (intentos.isEmpty) return const _FinalAlumnoEvaluacion();

    var condicion = 'pendiente';
    var notaVigente = _nullSiVacio(intentos.first.calificacion);
    int? ordenPrimerAprobado;
    var participoRecuperatorio = false;
    var huboIntentoComputable = false;

    for (final intento in intentos) {
      if (intento.orden > 0) participoRecuperatorio = true;
      final estado = _normalizarEstadoEvaluacionInterno(intento.estado);
      final notaIntento = _nullSiVacio(intento.calificacion);

      if (estado == 'ausente' &&
          intento.ausenteJustificado &&
          regla.ausenteJustificadoNoPenaliza) {
        notaVigente ??= notaIntento;
        continue;
      }

      huboIntentoComputable = true;
      final condicionIntento = _condicionDesdeEstadoEvaluacion(estado);
      condicion = condicionIntento;

      if (condicionIntento == 'aprobado' && ordenPrimerAprobado == null) {
        ordenPrimerAprobado = intento.orden;
      }

      if (intento.orden == 0) {
        notaVigente = notaIntento ?? notaVigente;
        continue;
      }
      if (regla.recuperatorioSoloCambiaCondicion) {
        notaVigente ??= notaIntento;
      } else if (regla.recuperatorioReemplazaNota) {
        notaVigente = notaIntento ?? notaVigente;
      } else {
        notaVigente ??= notaIntento;
      }
    }

    if (!huboIntentoComputable) {
      return _FinalAlumnoEvaluacion(
        condicionFinal: 'pendiente',
        calificacionVigente: notaVigente,
        ordenPrimerAprobado: null,
        participoRecuperatorio: participoRecuperatorio,
      );
    }

    if (condicion == 'no_aprobado' &&
        !participoRecuperatorio &&
        regla.recuperatorioObligatorio &&
        regla.maxRecuperatorios > 0) {
      condicion = 'pendiente';
    }

    return _FinalAlumnoEvaluacion(
      condicionFinal: condicion,
      calificacionVigente: notaVigente,
      ordenPrimerAprobado: ordenPrimerAprobado,
      participoRecuperatorio: participoRecuperatorio,
    );
  }

  String _condicionDesdeEstadoEvaluacion(String estado) {
    final s = _normalizarEstadoEvaluacionInterno(estado);
    if (s == 'aprobado') return 'aprobado';
    if (s == 'ausente') return 'ausente';
    if (s == 'recuperacion') return 'no_aprobado';
    return 'pendiente';
  }

  Future<List<HistorialAlumnoInteligente>> listarHistorialInteligenteCurso(
    int cursoId, {
    int diasAnalisis = 120,
  }) async {
    final alumnosRows = await _db
        .customSelect(
          '''
      SELECT a.id AS alumno_id, a.apellido AS apellido, a.nombre AS nombre
      FROM tabla_alumnos a
      INNER JOIN tabla_inscripciones i
        ON i.alumno_id = a.id
       AND i.curso_id = ?
       AND i.activo = 1
      WHERE a.activo = 1
      ORDER BY a.apellido ASC, a.nombre ASC
      ''',
          variables: [Variable<int>(cursoId)],
        )
        .get();
    if (alumnosRows.isEmpty) return const [];

    final statsPorAlumno = <int, _HistorialStats>{};
    for (final r in alumnosRows) {
      final alumnoId = r.read<int>('alumno_id');
      final apellido = r.read<String>('apellido').trim();
      final nombre = r.read<String>('nombre').trim();
      statsPorAlumno[alumnoId] = _HistorialStats(
        alumnoId: alumnoId,
        alumnoNombre: apellido.isEmpty ? nombre : '$apellido, $nombre',
      );
    }

    final desde = DateTime.now().subtract(Duration(days: diasAnalisis));
    final clases =
        await (_db.select(_db.tablaClases)
              ..where(
                (t) =>
                    t.cursoId.equals(cursoId) &
                    t.fecha.isBiggerOrEqualValue(desde),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
              ..limit(140))
            .get();
    final claseIds = clases.map((c) => c.id).toList(growable: false);
    final asistencias = claseIds.isEmpty
        ? const <TablaAsistencia>[]
        : await (_db.select(
            _db.tablaAsistencias,
          )..where((t) => t.claseId.isIn(claseIds))).get();

    final porClaseAlumno = <int, Map<int, TablaAsistencia>>{};
    for (final fila in asistencias) {
      porClaseAlumno.putIfAbsent(
        fila.claseId,
        () => <int, TablaAsistencia>{},
      )[fila.alumnoId] = fila;
    }

    for (final stats in statsPorAlumno.values) {
      final seriePresencia = <bool>[];
      var consec = 0;
      var registroConsecIniciado = false;

      for (final clase in clases) {
        final fila = porClaseAlumno[clase.id]?[stats.alumnoId];
        if (fila == null) continue;

        final estado = fila.estado.trim().toLowerCase();
        final ausente = estado == 'ausente' || estado == 'pendiente';
        if (ausente) stats.faltas++;
        if (!fila.actividadEntregada && estado != 'ausente') {
          stats.actividadesSinEntregar++;
        }

        if (estado != 'pendiente') {
          final presente =
              estado == 'presente' ||
              estado == 'tarde' ||
              estado == 'justificada';
          seriePresencia.add(presente);
        }

        if (!registroConsecIniciado) {
          registroConsecIniciado = true;
          consec = ausente ? 1 : 0;
          continue;
        }
        if (consec > 0) {
          if (ausente) {
            consec++;
          } else {
            break;
          }
        }
      }
      stats.inasistenciasConsecutivas = consec;
      stats.mejoraReciente = _detectarMejoraAsistencia(seriePresencia);
    }

    final intervenciones = await _db
        .customSelect(
          '''
      SELECT
        alumno_id,
        COUNT(*) AS total,
        COALESCE(SUM(CASE WHEN resuelta = 0 THEN 1 ELSE 0 END), 0) AS abiertas
      FROM tabla_intervenciones_docentes
      WHERE curso_id = ?
        AND alumno_id IS NOT NULL
      GROUP BY alumno_id
      ''',
          variables: [Variable<int>(cursoId)],
        )
        .get();
    for (final row in intervenciones) {
      final alumnoId = row.read<int>('alumno_id');
      final stats = statsPorAlumno[alumnoId];
      if (stats == null) continue;
      stats.intervencionesTotales = row.read<int>('total');
      stats.intervencionesAbiertas = row.read<int>('abiertas');
    }

    final totalEvaluacionesRow = await _db
        .customSelect(
          'SELECT COUNT(*) AS total FROM tabla_evaluaciones_curso WHERE curso_id = ?',
          variables: [Variable<int>(cursoId)],
        )
        .getSingle();
    final totalEvaluaciones = totalEvaluacionesRow.read<int>('total');

    final evaluaciones = await _db
        .customSelect(
          '''
      SELECT
        x.alumno_id AS alumno_id,
        COALESCE(
          SUM(CASE WHEN lower(trim(COALESCE(x.estado, ''))) = 'aprobado' THEN 1 ELSE 0 END),
          0
        ) AS aprobadas,
        COALESCE(
          SUM(CASE WHEN lower(trim(COALESCE(x.estado, ''))) IN ('en_proceso', 'proceso') THEN 1 ELSE 0 END),
          0
        ) AS en_proceso,
        COALESCE(
          SUM(CASE WHEN lower(trim(COALESCE(x.estado, ''))) IN ('recuperacion', 'recupera', 'recuperatorio') THEN 1 ELSE 0 END),
          0
        ) AS recuperacion
      FROM (
        SELECT
          r.alumno_id AS alumno_id,
          r.estado AS estado,
          i.evaluacion_id AS evaluacion_id
        FROM tabla_evaluaciones_alumno r
        INNER JOIN tabla_evaluaciones_instancia i
          ON i.id = r.evaluacion_instancia_id
        INNER JOIN tabla_evaluaciones_curso e
          ON e.id = i.evaluacion_id
        WHERE e.curso_id = ?
          AND NOT EXISTS (
            SELECT 1
            FROM tabla_evaluaciones_alumno r2
            INNER JOIN tabla_evaluaciones_instancia i2
              ON i2.id = r2.evaluacion_instancia_id
            WHERE r2.alumno_id = r.alumno_id
              AND i2.evaluacion_id = i.evaluacion_id
              AND i2.orden > i.orden
          )
      ) x
      GROUP BY x.alumno_id
      ''',
          variables: [Variable<int>(cursoId)],
        )
        .get();
    for (final row in evaluaciones) {
      final alumnoId = row.read<int>('alumno_id');
      final stats = statsPorAlumno[alumnoId];
      if (stats == null) continue;
      stats.evaluacionesAprobadas = row.read<int>('aprobadas');
      stats.evaluacionesEnProceso = row.read<int>('en_proceso');
      stats.evaluacionesRecuperacion = row.read<int>('recuperacion');
      final pendientesCalc =
          totalEvaluaciones -
          (stats.evaluacionesAprobadas +
              stats.evaluacionesEnProceso +
              stats.evaluacionesRecuperacion);
      stats.evaluacionesPendientes = pendientesCalc < 0 ? 0 : pendientesCalc;
    }
    if (totalEvaluaciones > 0) {
      for (final stats in statsPorAlumno.values) {
        if (stats.evaluacionesAprobadas == 0 &&
            stats.evaluacionesEnProceso == 0 &&
            stats.evaluacionesRecuperacion == 0 &&
            stats.evaluacionesPendientes == 0) {
          stats.evaluacionesPendientes = totalEvaluaciones;
        }
      }
    }

    final salida = statsPorAlumno.values
        .map((s) {
          final riesgo = _calcularNivelRiesgoHistorial(s);
          return HistorialAlumnoInteligente(
            alumnoId: s.alumnoId,
            alumnoNombre: s.alumnoNombre,
            faltas: s.faltas,
            inasistenciasConsecutivas: s.inasistenciasConsecutivas,
            actividadesSinEntregar: s.actividadesSinEntregar,
            intervencionesAbiertas: s.intervencionesAbiertas,
            intervencionesTotales: s.intervencionesTotales,
            evaluacionesPendientes: s.evaluacionesPendientes,
            evaluacionesEnProceso: s.evaluacionesEnProceso,
            evaluacionesAprobadas: s.evaluacionesAprobadas,
            evaluacionesRecuperacion: s.evaluacionesRecuperacion,
            mejoraReciente: s.mejoraReciente,
            nivelRiesgo: riesgo,
            resumen: _resumenHistorialAlumno(s, riesgo),
          );
        })
        .toList(growable: false);

    salida.sort((a, b) {
      final cmpRiesgo = _pesoRiesgo(
        b.nivelRiesgo,
      ).compareTo(_pesoRiesgo(a.nivelRiesgo));
      if (cmpRiesgo != 0) return cmpRiesgo;
      return a.alumnoNombre.toLowerCase().compareTo(
        b.alumnoNombre.toLowerCase(),
      );
    });
    return salida;
  }
}

class _EvaluacionContexto {
  final int evaluacionId;
  final int cursoId;
  final String institucion;

  const _EvaluacionContexto({
    required this.evaluacionId,
    required this.cursoId,
    required this.institucion,
  });
}

class _CursoContexto {
  final int cursoId;
  final String institucion;

  const _CursoContexto({required this.cursoId, required this.institucion});
}

class _EvaluacionInstanciaMeta {
  final int id;
  final int evaluacionId;
  final String tipoInstancia;
  final int orden;
  final DateTime fecha;
  final String estado;

  const _EvaluacionInstanciaMeta({
    required this.id,
    required this.evaluacionId,
    required this.tipoInstancia,
    required this.orden,
    required this.fecha,
    required this.estado,
  });
}

class _ResultadoOrdenado {
  final int orden;
  final String tipoInstancia;
  final String estado;
  final String? calificacion;
  final bool ausenteJustificado;

  const _ResultadoOrdenado({
    required this.orden,
    required this.tipoInstancia,
    required this.estado,
    required this.calificacion,
    required this.ausenteJustificado,
  });
}

class _FinalAlumnoEvaluacion {
  final String condicionFinal;
  final String? calificacionVigente;
  final int? ordenPrimerAprobado;
  final bool participoRecuperatorio;

  const _FinalAlumnoEvaluacion({
    this.condicionFinal = 'pendiente',
    this.calificacionVigente,
    this.ordenPrimerAprobado,
    this.participoRecuperatorio = false,
  });
}

class _ResumenProcesoEvaluacion {
  final int totalAlumnos;
  final int resultadosCargados;
  final int aprobadosFinales;
  final int noAprobadosFinales;
  final int pendientesFinales;
  final int ausentesFinales;
  final int aprobadosPrimeraInstancia;
  final int fueronARecuperatorio;
  final int aprobaronLuegoRecuperatorio;
  final int totalInstancias;

  const _ResumenProcesoEvaluacion({
    this.totalAlumnos = 0,
    this.resultadosCargados = 0,
    this.aprobadosFinales = 0,
    this.noAprobadosFinales = 0,
    this.pendientesFinales = 0,
    this.ausentesFinales = 0,
    this.aprobadosPrimeraInstancia = 0,
    this.fueronARecuperatorio = 0,
    this.aprobaronLuegoRecuperatorio = 0,
    this.totalInstancias = 1,
  });
}
