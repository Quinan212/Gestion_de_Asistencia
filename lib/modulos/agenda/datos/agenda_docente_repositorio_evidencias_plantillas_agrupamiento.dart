part of 'agenda_docente_repositorio.dart';

extension AgendaDocenteRepositorioEvidenciasPlantillasAgrupamiento
    on AgendaDocenteRepositorio {
  Future<List<EvidenciaDocente>> listarEvidenciasCurso(
    int cursoId, {
    int? claseId,
    int? alumnoId,
    int? evaluacionId,
    int? evaluacionInstanciaId,
    int limite = 80,
  }) async {
    final filtros = <String>['e.curso_id = ?'];
    final vars = <Variable<Object>>[Variable<int>(cursoId)];
    if (claseId != null) {
      filtros.add('e.clase_id = ?');
      vars.add(Variable<int>(claseId));
    }
    if (alumnoId != null) {
      filtros.add('e.alumno_id = ?');
      vars.add(Variable<int>(alumnoId));
    }
    if (evaluacionId != null) {
      filtros.add('e.evaluacion_id = ?');
      vars.add(Variable<int>(evaluacionId));
    }
    if (evaluacionInstanciaId != null) {
      filtros.add('e.evaluacion_instancia_id = ?');
      vars.add(Variable<int>(evaluacionInstanciaId));
    }
    vars.add(Variable<int>(limite));

    final rows = await _db.customSelect('''
      SELECT
        e.id,
        e.curso_id,
        e.clase_id,
        e.alumno_id,
        e.evaluacion_id,
        e.evaluacion_instancia_id,
        e.fecha,
        e.tipo,
        e.titulo,
        e.descripcion,
        e.archivo_path,
        a.apellido AS alumno_apellido,
        a.nombre AS alumno_nombre,
        c.tema AS clase_tema,
        ev.titulo AS evaluacion_titulo,
        ei.tipo_instancia AS evaluacion_tipo_instancia,
        ei.orden AS evaluacion_orden
      FROM tabla_evidencias_docentes e
      LEFT JOIN tabla_alumnos a ON a.id = e.alumno_id
      LEFT JOIN tabla_clases c ON c.id = e.clase_id
      LEFT JOIN tabla_evaluaciones_curso ev ON ev.id = e.evaluacion_id
      LEFT JOIN tabla_evaluaciones_instancia ei ON ei.id = e.evaluacion_instancia_id
      WHERE ${filtros.join(' AND ')}
      ORDER BY e.fecha DESC, e.id DESC
      LIMIT ?
      ''', variables: vars).get();

    return rows
        .map((r) {
          final apellido = (r.read<String?>('alumno_apellido') ?? '').trim();
          final nombre = (r.read<String?>('alumno_nombre') ?? '').trim();
          final alumnoNombre = (apellido.isEmpty && nombre.isEmpty)
              ? null
              : '$apellido, $nombre';
          final instanciaOrden = r.read<int?>('evaluacion_orden');
          final instanciaTipo =
              (r.read<String?>('evaluacion_tipo_instancia') ?? '').trim();
          final instanciaLabel = instanciaOrden == null
              ? null
              : instanciaOrden <= 0
              ? 'original'
              : '${instanciaTipo.isEmpty ? 'recuperatorio' : instanciaTipo} $instanciaOrden';
          return EvidenciaDocente(
            id: r.read<int>('id'),
            cursoId: r.read<int>('curso_id'),
            claseId: r.read<int?>('clase_id'),
            alumnoId: r.read<int?>('alumno_id'),
            evaluacionId: r.read<int?>('evaluacion_id'),
            evaluacionInstanciaId: r.read<int?>('evaluacion_instancia_id'),
            fecha: _fechaDesdeEpoch(r.read<int>('fecha')),
            tipo: r.read<String>('tipo'),
            titulo: r.read<String>('titulo'),
            descripcion: r.read<String?>('descripcion'),
            archivoPath: r.read<String?>('archivo_path'),
            alumnoNombre: alumnoNombre,
            temaClase: r.read<String?>('clase_tema'),
            evaluacionTitulo: r.read<String?>('evaluacion_titulo'),
            evaluacionTipoInstancia: instanciaLabel,
          );
        })
        .toList(growable: false);
  }

  Future<int> registrarEvidencia({
    required int cursoId,
    int? claseId,
    int? alumnoId,
    int? evaluacionId,
    int? evaluacionInstanciaId,
    DateTime? fecha,
    required String tipo,
    required String titulo,
    String? descripcion,
    String? archivoPath,
  }) async {
    int? evaluacionIdFinal = evaluacionId;
    int? evaluacionInstanciaIdFinal = evaluacionInstanciaId;

    if (evaluacionInstanciaIdFinal != null) {
      final instancia = await _db
          .customSelect(
            '''
        SELECT evaluacion_id
        FROM tabla_evaluaciones_instancia
        WHERE id = ?
        LIMIT 1
        ''',
            variables: [Variable<int>(evaluacionInstanciaIdFinal)],
          )
          .getSingleOrNull();
      if (instancia == null) {
        throw ArgumentError('La instancia de evaluacion no existe');
      }
      final evaluacionDesdeInstancia = instancia.read<int>('evaluacion_id');
      evaluacionIdFinal ??= evaluacionDesdeInstancia;
      if (evaluacionIdFinal != evaluacionDesdeInstancia) {
        throw ArgumentError('La instancia no corresponde a la evaluacion');
      }
    }

    if (evaluacionIdFinal != null) {
      final evalValida = await _db
          .customSelect(
            '''
        SELECT id
        FROM tabla_evaluaciones_curso
        WHERE id = ?
          AND curso_id = ?
        LIMIT 1
        ''',
            variables: [
              Variable<int>(evaluacionIdFinal),
              Variable<int>(cursoId),
            ],
          )
          .getSingleOrNull();
      if (evalValida == null) {
        throw ArgumentError('La evaluacion seleccionada no pertenece al curso');
      }
    }

    if (evaluacionInstanciaIdFinal != null) {
      final instanciaValida = await _db
          .customSelect(
            '''
        SELECT i.id
        FROM tabla_evaluaciones_instancia i
        INNER JOIN tabla_evaluaciones_curso e
          ON e.id = i.evaluacion_id
        WHERE i.id = ?
          AND e.curso_id = ?
        LIMIT 1
        ''',
            variables: [
              Variable<int>(evaluacionInstanciaIdFinal),
              Variable<int>(cursoId),
            ],
          )
          .getSingleOrNull();
      if (instanciaValida == null) {
        throw ArgumentError(
          'La instancia seleccionada no corresponde al curso',
        );
      }
    }

    final fechaEpoch = (fecha ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
    await _db.customStatement(
      '''
      INSERT INTO tabla_evidencias_docentes (
        curso_id,
        clase_id,
        alumno_id,
        evaluacion_id,
        evaluacion_instancia_id,
        fecha,
        tipo,
        titulo,
        descripcion,
        archivo_path,
        creado_en
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      ''',
      [
        cursoId,
        claseId,
        alumnoId,
        evaluacionIdFinal,
        evaluacionInstanciaIdFinal,
        fechaEpoch,
        tipo.trim(),
        titulo.trim(),
        _nullSiVacio(descripcion),
        _nullSiVacio(archivoPath),
      ],
    );
    final row = await _db
        .customSelect('SELECT last_insert_rowid() AS id')
        .getSingle();
    return row.read<int>('id');
  }

  Future<void> eliminarEvidencia(int evidenciaId) async {
    await _db.customStatement(
      'DELETE FROM tabla_evidencias_docentes WHERE id = ?',
      [evidenciaId],
    );
  }

  Future<List<PlantillaDocente>> listarPlantillasParaCurso({
    required String institucion,
    required int cursoId,
    String? tipo,
    int limite = 120,
  }) async {
    final filtroTipo = _nullSiVacio(tipo);
    final filtros = <String>[
      '(curso_id IS NULL OR curso_id = ?)',
      '(institucion IS NULL OR lower(trim(institucion)) = lower(trim(?)))',
    ];
    final variables = <Variable<Object>>[
      Variable<int>(cursoId),
      Variable<String>(institucion),
    ];
    if (filtroTipo != null) {
      filtros.add('lower(trim(tipo)) = lower(trim(?))');
      variables.add(Variable<String>(filtroTipo));
    }
    variables.add(Variable<int>(cursoId));
    variables.add(Variable<int>(limite));

    final rows = await _db.customSelect('''
      SELECT
        id,
        institucion,
        curso_id,
        tipo,
        titulo,
        contenido,
        atajo,
        orden,
        uso_count,
        actualizado_en
      FROM tabla_plantillas_docentes
      WHERE ${filtros.join(' AND ')}
      ORDER BY
        CASE
          WHEN curso_id = ? THEN 2
          WHEN institucion IS NOT NULL THEN 1
          ELSE 0
        END DESC,
        uso_count DESC,
        orden ASC,
        id ASC
      LIMIT ?
      ''', variables: variables).get();

    return rows.map(_mapPlantillaDocente).toList(growable: false);
  }

  Future<int> crearPlantillaDocente({
    String? institucion,
    int? cursoId,
    required String tipo,
    required String titulo,
    required String contenido,
    String? atajo,
    int orden = 0,
  }) async {
    await _db.customStatement(
      '''
      INSERT INTO tabla_plantillas_docentes (
        institucion,
        curso_id,
        tipo,
        titulo,
        contenido,
        atajo,
        orden,
        uso_count,
        creado_en,
        actualizado_en
      ) VALUES (?, ?, ?, ?, ?, ?, ?, 0, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER), CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      ''',
      [
        _nullSiVacio(institucion),
        cursoId,
        tipo.trim(),
        titulo.trim(),
        contenido.trim(),
        _nullSiVacio(atajo),
        orden,
      ],
    );
    final row = await _db
        .customSelect('SELECT last_insert_rowid() AS id')
        .getSingle();
    return row.read<int>('id');
  }

  Future<void> actualizarPlantillaDocente({
    required int plantillaId,
    String? institucion,
    int? cursoId,
    required String tipo,
    required String titulo,
    required String contenido,
    String? atajo,
    int orden = 0,
  }) async {
    await _db.customStatement(
      '''
      UPDATE tabla_plantillas_docentes
      SET
        institucion = ?,
        curso_id = ?,
        tipo = ?,
        titulo = ?,
        contenido = ?,
        atajo = ?,
        orden = ?,
        actualizado_en = CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)
      WHERE id = ?
      ''',
      [
        _nullSiVacio(institucion),
        cursoId,
        tipo.trim(),
        titulo.trim(),
        contenido.trim(),
        _nullSiVacio(atajo),
        orden,
        plantillaId,
      ],
    );
  }

  Future<void> eliminarPlantillaDocente(int plantillaId) async {
    await _db.customStatement(
      'DELETE FROM tabla_plantillas_docentes WHERE id = ?',
      [plantillaId],
    );
  }

  Future<void> registrarUsoPlantillaDocente(int plantillaId) async {
    await _db.customStatement(
      '''
      UPDATE tabla_plantillas_docentes
      SET
        uso_count = uso_count + 1,
        actualizado_en = CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)
      WHERE id = ?
      ''',
      [plantillaId],
    );
  }

  Future<List<RubricaSimple>> listarRubricasParaCurso({
    String? institucion,
    required int cursoId,
    String? tipo,
    int limite = 120,
  }) async {
    final institucionNorm = _nullSiVacio(institucion);
    final tipoNorm = _nullSiVacio(tipo);
    final filtros = <String>['(curso_id IS NULL OR curso_id = ?)'];
    final vars = <Variable<Object>>[Variable<int>(cursoId)];
    if (institucionNorm != null) {
      filtros.add(
        '(institucion IS NULL OR lower(trim(institucion)) = lower(trim(?)))',
      );
      vars.add(Variable<String>(institucionNorm));
    }
    if (tipoNorm != null) {
      filtros.add('lower(trim(tipo)) = lower(trim(?))');
      vars.add(Variable<String>(tipoNorm));
    }
    vars.add(Variable<int>(cursoId));
    vars.add(Variable<int>(limite));

    final rows = await _db.customSelect('''
      SELECT
        id,
        institucion,
        curso_id,
        tipo,
        titulo,
        criterios,
        orden,
        uso_count,
        actualizado_en
      FROM tabla_rubricas_simples
      WHERE ${filtros.join(' AND ')}
      ORDER BY
        CASE WHEN curso_id = ? THEN 2
             WHEN institucion IS NOT NULL THEN 1
             ELSE 0 END DESC,
        uso_count DESC,
        orden ASC,
        id ASC
      LIMIT ?
      ''', variables: vars).get();

    return rows
        .map(
          (r) => RubricaSimple(
            id: r.read<int>('id'),
            institucion: r.read<String?>('institucion'),
            cursoId: r.read<int?>('curso_id'),
            tipo: r.read<String>('tipo'),
            titulo: r.read<String>('titulo'),
            criterios: r.read<String>('criterios'),
            orden: r.read<int>('orden'),
            usoCount: r.read<int>('uso_count'),
            actualizadoEn: _fechaDesdeEpoch(r.read<int>('actualizado_en')),
          ),
        )
        .toList(growable: false);
  }

  Future<int> crearRubricaSimple({
    String? institucion,
    int? cursoId,
    required String tipo,
    required String titulo,
    required String criterios,
    int orden = 0,
  }) async {
    await _db.customStatement(
      '''
      INSERT INTO tabla_rubricas_simples (
        institucion,
        curso_id,
        tipo,
        titulo,
        criterios,
        orden,
        uso_count,
        actualizado_en
      ) VALUES (?, ?, ?, ?, ?, ?, 0, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      ''',
      [
        _nullSiVacio(institucion),
        cursoId,
        tipo.trim(),
        titulo.trim(),
        criterios.trim(),
        orden,
      ],
    );
    final row = await _db
        .customSelect('SELECT last_insert_rowid() AS id')
        .getSingle();
    return row.read<int>('id');
  }

  Future<void> actualizarRubricaSimple({
    required int rubricaId,
    String? institucion,
    int? cursoId,
    required String tipo,
    required String titulo,
    required String criterios,
    int orden = 0,
  }) async {
    await _db.customStatement(
      '''
      UPDATE tabla_rubricas_simples
      SET
        institucion = ?,
        curso_id = ?,
        tipo = ?,
        titulo = ?,
        criterios = ?,
        orden = ?,
        actualizado_en = CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)
      WHERE id = ?
      ''',
      [
        _nullSiVacio(institucion),
        cursoId,
        tipo.trim(),
        titulo.trim(),
        criterios.trim(),
        orden,
        rubricaId,
      ],
    );
  }

  Future<void> eliminarRubricaSimple(int rubricaId) async {
    await _db.customStatement(
      'DELETE FROM tabla_rubricas_simples WHERE id = ?',
      [rubricaId],
    );
  }

  Future<void> registrarUsoRubricaSimple(int rubricaId) async {
    await _db.customStatement(
      '''
      UPDATE tabla_rubricas_simples
      SET
        uso_count = uso_count + 1,
        actualizado_en = CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)
      WHERE id = ?
      ''',
      [rubricaId],
    );
  }

  Future<List<AgrupamientoPedagogicoItem>> generarAgrupamientoPedagogicoCurso(
    int cursoId,
  ) async {
    final historial = await listarHistorialInteligenteCurso(cursoId);
    if (historial.isEmpty) return const [];

    final out = historial
        .map((h) {
          final grupo = _determinarGrupoPedagogico(h);
          final fundamento = _fundamentoGrupoPedagogico(h, grupo);
          return AgrupamientoPedagogicoItem(
            alumnoId: h.alumnoId,
            alumnoNombre: h.alumnoNombre,
            grupo: grupo,
            fundamento: fundamento,
            mejoraReciente: h.mejoraReciente,
          );
        })
        .toList(growable: false);

    out.sort((a, b) {
      final cmpGrupo = _prioridadGrupo(
        a.grupo,
      ).compareTo(_prioridadGrupo(b.grupo));
      if (cmpGrupo != 0) return cmpGrupo;
      return a.alumnoNombre.toLowerCase().compareTo(
        b.alumnoNombre.toLowerCase(),
      );
    });
    return out;
  }
}
