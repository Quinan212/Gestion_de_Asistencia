part of 'agenda_docente_repositorio.dart';

extension AgendaDocenteRepositorioIntervencionesAcuerdosReglas
    on AgendaDocenteRepositorio {
  Future<List<AuditoriaDocenteItem>> listarAuditoriaDocente({
    String? institucion,
    int? cursoId,
    String? entidad,
    String? campo,
    int limite = 200,
  }) async {
    final entidadNorm = _nullSiVacio(entidad);
    final campoNorm = _nullSiVacio(campo);
    final institucionNorm = _nullSiVacio(institucion);
    final condiciones = <String>[];
    final variables = <Variable<Object>>[];

    if (entidadNorm != null) {
      condiciones.add('lower(trim(entidad)) = lower(trim(?))');
      variables.add(Variable<String>(entidadNorm));
    }
    if (campoNorm != null) {
      condiciones.add('lower(trim(campo)) = lower(trim(?))');
      variables.add(Variable<String>(campoNorm));
    }
    if (institucionNorm != null) {
      condiciones.add(
        'lower(trim(COALESCE(institucion, \'\'))) = lower(trim(?))',
      );
      variables.add(Variable<String>(institucionNorm));
    }
    if (cursoId != null) {
      condiciones.add('curso_id = ?');
      variables.add(Variable<int>(cursoId));
    }
    variables.add(Variable<int>(limite));

    final where = condiciones.isEmpty
        ? ''
        : 'WHERE ${condiciones.join(' AND ')}';
    final rows = await _db.customSelect('''
      SELECT
        id,
        entidad,
        entidad_id,
        campo,
        valor_anterior,
        valor_nuevo,
        contexto,
        curso_id,
        institucion,
        usuario,
        creado_en
      FROM tabla_auditoria_docente
      $where
      ORDER BY creado_en DESC, id DESC
      LIMIT ?
      ''', variables: variables).get();

    return rows
        .map(
          (r) => AuditoriaDocenteItem(
            id: r.read<int>('id'),
            entidad: r.read<String>('entidad'),
            entidadId: r.read<int?>('entidad_id'),
            campo: r.read<String>('campo'),
            valorAnterior: r.read<String?>('valor_anterior'),
            valorNuevo: r.read<String?>('valor_nuevo'),
            contexto: r.read<String?>('contexto'),
            cursoId: r.read<int?>('curso_id'),
            institucion: r.read<String?>('institucion'),
            usuario: r.read<String>('usuario'),
            creadoEn: _fechaDesdeEpoch(r.read<int>('creado_en')),
          ),
        )
        .toList(growable: false);
  }

  Future<List<IntervencionDocente>> listarIntervencionesCurso(
    int cursoId, {
    int limite = 40,
  }) async {
    final rows = await _db
        .customSelect(
          '''
      SELECT
        i.id,
        i.curso_id,
        i.alumno_id,
        i.fecha,
        i.tipo,
        i.descripcion,
        i.seguimiento,
        i.resuelta,
        a.apellido AS alumno_apellido,
        a.nombre AS alumno_nombre
      FROM tabla_intervenciones_docentes i
      LEFT JOIN tabla_alumnos a ON a.id = i.alumno_id
      WHERE i.curso_id = ?
      ORDER BY i.fecha DESC, i.id DESC
      LIMIT ?
      ''',
          variables: [Variable<int>(cursoId), Variable<int>(limite)],
        )
        .get();

    return rows
        .map((r) {
          final apellido = (r.read<String?>('alumno_apellido') ?? '').trim();
          final nombre = (r.read<String?>('alumno_nombre') ?? '').trim();
          final alumnoNombre = (apellido.isEmpty && nombre.isEmpty)
              ? null
              : '$apellido, $nombre';

          return IntervencionDocente(
            id: r.read<int>('id'),
            cursoId: r.read<int?>('curso_id'),
            alumnoId: r.read<int?>('alumno_id'),
            fecha: _fechaDesdeEpoch(r.read<int>('fecha')),
            tipo: r.read<String>('tipo'),
            descripcion: r.read<String>('descripcion'),
            seguimiento: r.read<String?>('seguimiento'),
            resuelta: (r.read<int>('resuelta')) == 1,
            alumnoNombre: alumnoNombre,
          );
        })
        .toList(growable: false);
  }

  Future<void> registrarIntervencion({
    required int cursoId,
    int? alumnoId,
    DateTime? fecha,
    required String tipo,
    required String descripcion,
    String? seguimiento,
  }) async {
    final fechaEpoch = (fecha ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;

    await _db.customStatement(
      '''
      INSERT INTO tabla_intervenciones_docentes (
        curso_id,
        alumno_id,
        fecha,
        tipo,
        descripcion,
        seguimiento,
        resuelta,
        creado_en
      ) VALUES (?, ?, ?, ?, ?, ?, 0, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      ''',
      [
        cursoId,
        alumnoId,
        fechaEpoch,
        tipo.trim(),
        descripcion.trim(),
        _nullSiVacio(seguimiento),
      ],
    );
    final row = await _db
        .customSelect('SELECT last_insert_rowid() AS id')
        .getSingle();
    final intervencionId = row.read<int>('id');
    final contexto = await _contextoCurso(cursoId);
    await _registrarAuditoriaCambio(
      entidad: 'intervencion_docente',
      entidadId: intervencionId,
      campo: 'creacion',
      valorAnterior: null,
      valorNuevo:
          'tipo=${tipo.trim()} | descripcion=${descripcion.trim()} | seguimiento=${_nullSiVacio(seguimiento) ?? ''} | alumno=${alumnoId ?? '-'}',
      contexto: 'Intervencion registrada',
      cursoId: cursoId,
      institucion: contexto?.institucion,
    );
  }

  Future<void> actualizarEstadoIntervencion({
    required int intervencionId,
    required bool resuelta,
  }) async {
    final previo = await _db
        .customSelect(
          '''
      SELECT curso_id, resuelta
      FROM tabla_intervenciones_docentes
      WHERE id = ?
      LIMIT 1
      ''',
          variables: [Variable<int>(intervencionId)],
        )
        .getSingleOrNull();
    final cursoId = previo?.read<int>('curso_id');
    final estadoPrevio = (previo?.read<int>('resuelta') ?? 0) == 1
        ? 'resuelta'
        : 'abierta';
    await _db.customStatement(
      'UPDATE tabla_intervenciones_docentes SET resuelta = ? WHERE id = ?',
      [resuelta ? 1 : 0, intervencionId],
    );
    if (cursoId != null) {
      final contexto = await _contextoCurso(cursoId);
      await _registrarAuditoriaCambio(
        entidad: 'intervencion_docente',
        entidadId: intervencionId,
        campo: 'estado',
        valorAnterior: estadoPrevio,
        valorNuevo: resuelta ? 'resuelta' : 'abierta',
        contexto: 'Estado de intervencion',
        cursoId: cursoId,
        institucion: contexto?.institucion,
      );
    }
  }

  Future<List<AcuerdoConvivencia>> listarAcuerdosCurso(
    int cursoId, {
    int limite = 80,
  }) async {
    final rows = await _db
        .customSelect(
          '''
      SELECT
        id,
        curso_id,
        fecha,
        tipo,
        descripcion,
        estrategia,
        reiterada,
        resuelta
      FROM tabla_acuerdos_convivencia
      WHERE curso_id = ?
      ORDER BY fecha DESC, id DESC
      LIMIT ?
      ''',
          variables: [Variable<int>(cursoId), Variable<int>(limite)],
        )
        .get();

    return rows
        .map(
          (r) => AcuerdoConvivencia(
            id: r.read<int>('id'),
            cursoId: r.read<int>('curso_id'),
            fecha: _fechaDesdeEpoch(r.read<int>('fecha')),
            tipo: r.read<String>('tipo'),
            descripcion: r.read<String>('descripcion'),
            estrategia: r.read<String?>('estrategia'),
            reiterada: (r.read<int>('reiterada')) == 1,
            resuelta: (r.read<int>('resuelta')) == 1,
          ),
        )
        .toList(growable: false);
  }

  Future<int> registrarAcuerdoConvivencia({
    required int cursoId,
    DateTime? fecha,
    required String tipo,
    required String descripcion,
    String? estrategia,
    bool reiterada = false,
  }) async {
    final fechaEpoch = (fecha ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
    await _db.customStatement(
      '''
      INSERT INTO tabla_acuerdos_convivencia (
        curso_id,
        fecha,
        tipo,
        descripcion,
        estrategia,
        reiterada,
        resuelta,
        creado_en
      ) VALUES (?, ?, ?, ?, ?, ?, 0, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      ''',
      [
        cursoId,
        fechaEpoch,
        tipo.trim(),
        descripcion.trim(),
        _nullSiVacio(estrategia),
        reiterada ? 1 : 0,
      ],
    );
    final row = await _db
        .customSelect('SELECT last_insert_rowid() AS id')
        .getSingle();
    return row.read<int>('id');
  }

  Future<void> actualizarEstadoAcuerdoConvivencia({
    required int acuerdoId,
    required bool resuelta,
  }) async {
    await _db.customStatement(
      'UPDATE tabla_acuerdos_convivencia SET resuelta = ? WHERE id = ?',
      [resuelta ? 1 : 0, acuerdoId],
    );
  }

  Future<void> eliminarAcuerdoConvivencia(int acuerdoId) async {
    await _db.customStatement(
      'DELETE FROM tabla_acuerdos_convivencia WHERE id = ?',
      [acuerdoId],
    );
  }

  Future<ReglaInstitucion> obtenerReglaInstitucion(String institucion) async {
    final nombre = institucion.trim();
    if (nombre.isEmpty) return ReglaInstitucion.porDefecto(institucion);
    try {
      final row = await _db
          .customSelect(
            '''
        SELECT
          institucion,
          escala_calificacion,
          nota_aprobacion,
          asistencia_minima,
          max_recuperatorios,
          recuperatorio_reemplaza_nota,
          recuperatorio_solo_cambia_condicion,
          recuperatorio_obligatorio,
          ausente_justificado_no_penaliza,
          regimen_asistencia,
          criterios_generales,
          observaciones_estandar,
          actualizado_en
        FROM tabla_reglas_institucion
        WHERE lower(trim(institucion)) = lower(trim(?))
        LIMIT 1
        ''',
            variables: [Variable<String>(nombre)],
          )
          .getSingleOrNull();

      if (row == null) return ReglaInstitucion.porDefecto(nombre);
      final asistenciaMinima =
          row.readNullableWithType(DriftSqlType.double, 'asistencia_minima') ??
          75.0;
      final actualizadoEnEpoch = row.read<int?>('actualizado_en');
      final escala = (row.read<String?>('escala_calificacion') ?? 'numerica_10')
          .trim()
          .toLowerCase();
      final escalaNormalizada = switch (escala) {
        'numerica_10' => 'numerica_10',
        'numerica_100' => 'numerica_100',
        'conceptual' => 'conceptual',
        _ => 'numerica_10',
      };
      final maxRecuperatorios = math
          .max(0, math.min(row.read<int?>('max_recuperatorios') ?? 1, 2))
          .toInt();

      return ReglaInstitucion(
        institucion: row.read<String?>('institucion') ?? nombre,
        escalaCalificacion: escalaNormalizada,
        notaAprobacion: row.read<String?>('nota_aprobacion') ?? '6',
        asistenciaMinima: asistenciaMinima,
        maxRecuperatorios: maxRecuperatorios,
        recuperatorioReemplazaNota:
            (row.read<int?>('recuperatorio_reemplaza_nota') ?? 1) == 1,
        recuperatorioSoloCambiaCondicion:
            (row.read<int?>('recuperatorio_solo_cambia_condicion') ?? 0) == 1,
        recuperatorioObligatorio:
            (row.read<int?>('recuperatorio_obligatorio') ?? 0) == 1,
        ausenteJustificadoNoPenaliza:
            (row.read<int?>('ausente_justificado_no_penaliza') ?? 1) == 1,
        regimenAsistencia: row.read<String?>('regimen_asistencia'),
        criteriosGenerales: row.read<String?>('criterios_generales'),
        observacionesEstandar: row.read<String?>('observaciones_estandar'),
        actualizadoEn: actualizadoEnEpoch == null
            ? null
            : _fechaDesdeEpoch(actualizadoEnEpoch),
      );
    } catch (e, st) {
      developer.log(
        'Error leyendo reglas institucionales para "$nombre": $e',
        stackTrace: st,
        name: 'AgendaDocenteRepositorio',
      );
      return ReglaInstitucion.porDefecto(nombre);
    }
  }

  Future<void> guardarReglaInstitucion({
    required String institucion,
    required String escalaCalificacion,
    required String notaAprobacion,
    required double asistenciaMinima,
    required int maxRecuperatorios,
    required bool recuperatorioReemplazaNota,
    required bool recuperatorioSoloCambiaCondicion,
    required bool recuperatorioObligatorio,
    required bool ausenteJustificadoNoPenaliza,
    String? regimenAsistencia,
    String? criteriosGenerales,
    String? observacionesEstandar,
  }) async {
    final nombre = institucion.trim();
    if (nombre.isEmpty) return;
    final previoRow = await _db
        .customSelect(
          '''
      SELECT
        escala_calificacion,
        nota_aprobacion,
        asistencia_minima,
        max_recuperatorios,
        recuperatorio_reemplaza_nota,
        recuperatorio_solo_cambia_condicion,
        recuperatorio_obligatorio,
        ausente_justificado_no_penaliza,
        regimen_asistencia,
        criterios_generales,
        observaciones_estandar
      FROM tabla_reglas_institucion
      WHERE lower(trim(institucion)) = lower(trim(?))
      LIMIT 1
      ''',
          variables: [Variable<String>(nombre)],
        )
        .getSingleOrNull();
    final previoResumen = previoRow == null
        ? null
        : 'escala=${previoRow.read<String?>('escala_calificacion') ?? ''} | nota=${previoRow.read<String?>('nota_aprobacion') ?? ''} | asis=${(previoRow.readNullableWithType(DriftSqlType.double, 'asistencia_minima') ?? 75.0).toStringAsFixed(2)} | recups=${previoRow.read<int?>('max_recuperatorios') ?? 1} | reemplaza=${previoRow.read<int?>('recuperatorio_reemplaza_nota') ?? 1} | solo_cond=${previoRow.read<int?>('recuperatorio_solo_cambia_condicion') ?? 0} | recup_obl=${previoRow.read<int?>('recuperatorio_obligatorio') ?? 0} | aus_just=${previoRow.read<int?>('ausente_justificado_no_penaliza') ?? 1} | regimen=${previoRow.read<String?>('regimen_asistencia') ?? ''} | criterios=${previoRow.read<String?>('criterios_generales') ?? ''} | obs_est=${previoRow.read<String?>('observaciones_estandar') ?? ''}';
    final asistencia = (math.max(
      0.0,
      math.min(asistenciaMinima, 100.0),
    )).toDouble();
    final maxRecups = math.max(0, math.min(maxRecuperatorios, 2)).toInt();
    final recupObligatorio = maxRecups > 0 && recuperatorioObligatorio;
    final escalaNormalizada = switch (escalaCalificacion.trim().toLowerCase()) {
      'numerica_10' => 'numerica_10',
      'numerica_100' => 'numerica_100',
      'conceptual' => 'conceptual',
      _ => 'numerica_10',
    };
    final notaNormalizada = notaAprobacion.trim().isEmpty
        ? '6'
        : notaAprobacion.trim();
    final regimenNormalizado = _nullSiVacio(regimenAsistencia);
    final criteriosNormalizados = _nullSiVacio(criteriosGenerales);
    final observacionesNormalizadas = _nullSiVacio(observacionesEstandar);
    try {
      await _db.customInsert(
        '''
        INSERT INTO tabla_reglas_institucion (
          institucion,
          escala_calificacion,
          nota_aprobacion,
          asistencia_minima,
          max_recuperatorios,
          recuperatorio_reemplaza_nota,
          recuperatorio_solo_cambia_condicion,
          recuperatorio_obligatorio,
          ausente_justificado_no_penaliza,
          regimen_asistencia,
          criterios_generales,
          observaciones_estandar,
          actualizado_en
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
        ON CONFLICT(institucion)
        DO UPDATE SET
          escala_calificacion = excluded.escala_calificacion,
          nota_aprobacion = excluded.nota_aprobacion,
          asistencia_minima = excluded.asistencia_minima,
          max_recuperatorios = excluded.max_recuperatorios,
          recuperatorio_reemplaza_nota = excluded.recuperatorio_reemplaza_nota,
          recuperatorio_solo_cambia_condicion = excluded.recuperatorio_solo_cambia_condicion,
          recuperatorio_obligatorio = excluded.recuperatorio_obligatorio,
          ausente_justificado_no_penaliza = excluded.ausente_justificado_no_penaliza,
          regimen_asistencia = excluded.regimen_asistencia,
          criterios_generales = excluded.criterios_generales,
          observaciones_estandar = excluded.observaciones_estandar,
          actualizado_en = excluded.actualizado_en
        ''',
        variables: [
          Variable.withString(nombre),
          Variable.withString(escalaNormalizada),
          Variable.withString(notaNormalizada),
          Variable.withReal(asistencia),
          Variable.withInt(maxRecups),
          Variable.withInt(recuperatorioReemplazaNota ? 1 : 0),
          Variable.withInt(recuperatorioSoloCambiaCondicion ? 1 : 0),
          Variable.withInt(recupObligatorio ? 1 : 0),
          Variable.withInt(ausenteJustificadoNoPenaliza ? 1 : 0),
          Variable<String>(regimenNormalizado),
          Variable<String>(criteriosNormalizados),
          Variable<String>(observacionesNormalizadas),
        ],
      );
    } catch (e) {
      throw StateError(
        'SQL reglas institucion fallo: $e\n'
        'tipos => asistencia=${asistencia.runtimeType}, '
        'maxRecups=${maxRecups.runtimeType}, '
        'regimen=${regimenNormalizado.runtimeType}, '
        'criterios=${criteriosNormalizados.runtimeType}, '
        'observaciones=${observacionesNormalizadas.runtimeType}\n'
        'valores => institucion=$nombre, escala=$escalaNormalizada, '
        'nota=$notaNormalizada, asistencia=$asistencia, maxRecups=$maxRecups',
      );
    }
    final nuevoResumen =
        'escala=$escalaNormalizada | nota=$notaNormalizada | asis=${asistencia.toStringAsFixed(2)} | recups=$maxRecups | reemplaza=${recuperatorioReemplazaNota ? 1 : 0} | solo_cond=${recuperatorioSoloCambiaCondicion ? 1 : 0} | recup_obl=${recupObligatorio ? 1 : 0} | aus_just=${ausenteJustificadoNoPenaliza ? 1 : 0} | regimen=${regimenNormalizado ?? ''} | criterios=${criteriosNormalizados ?? ''} | obs_est=${observacionesNormalizadas ?? ''}';
    try {
      await _registrarAuditoriaCambio(
        entidad: 'regla_institucion',
        entidadId: null,
        campo: 'configuracion',
        valorAnterior: previoResumen,
        valorNuevo: nuevoResumen,
        contexto: 'Reglas institucionales',
        cursoId: null,
        institucion: nombre,
      );
    } catch (e, st) {
      developer.log(
        'Error registrando auditoria de reglas institucionales para "$nombre": $e',
        stackTrace: st,
        name: 'AgendaDocenteRepositorio',
      );
    }
  }
}
