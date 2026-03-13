part of 'agenda_docente_repositorio.dart';

extension AgendaDocenteRepositorioHelpers on AgendaDocenteRepositorio {
  Future<List<_CursoAgendaBase>> _listarCursosActivos() async {
    final q =
        _db.select(_db.tablaCursos).join([
          leftOuterJoin(
            _db.tablaInstituciones,
            _db.tablaInstituciones.id.equalsExp(_db.tablaCursos.institucionId),
          ),
          leftOuterJoin(
            _db.tablaCarreras,
            _db.tablaCarreras.id.equalsExp(_db.tablaCursos.carreraId),
          ),
          leftOuterJoin(
            _db.tablaMaterias,
            _db.tablaMaterias.id.equalsExp(_db.tablaCursos.materiaId),
          ),
        ])..where(
          _db.tablaCursos.activo.equals(true) &
              _db.tablaInstituciones.id.isNotNull() &
              _db.tablaInstituciones.activo.equals(true) &
              _db.tablaCarreras.id.isNotNull() &
              _db.tablaCarreras.activo.equals(true) &
              _db.tablaMaterias.id.isNotNull() &
              _db.tablaMaterias.activo.equals(true),
        );

    q.orderBy([
      OrderingTerm.asc(_db.tablaInstituciones.nombre),
      OrderingTerm.asc(_db.tablaCarreras.nombre),
      OrderingTerm.asc(_db.tablaMaterias.nombre),
      OrderingTerm.asc(_db.tablaCursos.division),
      OrderingTerm.asc(_db.tablaCursos.anio),
    ]);

    final rows = await q.get();
    return rows
        .map((row) {
          final c = row.readTable(_db.tablaCursos);
          final i = row.readTableOrNull(_db.tablaInstituciones);
          final ca = row.readTableOrNull(_db.tablaCarreras);
          final m = row.readTableOrNull(_db.tablaMaterias);
          final division = (c.division ?? 'A').trim();
          final anioCursada =
              m?.anioCursada ?? int.tryParse(c.nombre.trim()) ?? 1;
          return _CursoAgendaBase(
            id: c.id,
            institucion: (i?.nombre ?? c.turno ?? 'Sin institucion').trim(),
            carrera: (ca?.nombre ?? 'Sin carrera').trim(),
            materia: (m?.nombre ?? c.materia ?? 'Sin materia').trim(),
            etiquetaCurso: '$anioCursada $division',
          );
        })
        .toList(growable: false);
  }

  Future<List<HorarioCurso>> _listarHorariosCursos(List<int> cursoIds) async {
    if (cursoIds.isEmpty) return const [];
    final params = List<String>.filled(cursoIds.length, '?').join(',');
    final rows = await _db.customSelect(
      '''
      SELECT id, curso_id, dia_semana, hora_inicio, hora_fin, aula
      FROM tabla_horarios_curso
      WHERE activo = 1 AND curso_id IN ($params)
      ORDER BY dia_semana ASC, hora_inicio ASC
      ''',
      variables: cursoIds
          .map((id) => Variable<int>(id))
          .toList(growable: false),
    ).get();
    return rows.map(_mapHorario).toList(growable: false);
  }

  HorarioCurso _mapHorario(QueryRow row) {
    return HorarioCurso(
      id: row.read<int>('id'),
      cursoId: row.read<int>('curso_id'),
      diaSemana: row.read<int>('dia_semana'),
      horaInicio: row.read<String>('hora_inicio'),
      horaFin: row.read<String?>('hora_fin'),
      aula: row.read<String?>('aula'),
    );
  }

  void _ordenarAgenda(List<AgendaDocenteItem> items) {
    items.sort((a, b) {
      final ah = a.horaReferenciaOrden;
      final bh = b.horaReferenciaOrden;
      if (ah != null && bh != null) {
        final cmpHora = ah.compareTo(bh);
        if (cmpHora != 0) return cmpHora;
      } else if (ah != null) {
        return -1;
      } else if (bh != null) {
        return 1;
      }

      final cmpInst = a.institucion.toLowerCase().compareTo(
        b.institucion.toLowerCase(),
      );
      if (cmpInst != 0) return cmpInst;

      final cmpMat = a.materia.toLowerCase().compareTo(b.materia.toLowerCase());
      if (cmpMat != 0) return cmpMat;

      return a.etiquetaCurso.toLowerCase().compareTo(
        b.etiquetaCurso.toLowerCase(),
      );
    });
  }

  Map<int, List<TablaClase>> _agruparClasesPorCurso(List<TablaClase> clases) {
    final out = <int, List<TablaClase>>{};
    for (final clase in clases) {
      out.putIfAbsent(clase.cursoId, () => <TablaClase>[]).add(clase);
    }
    return out;
  }

  Map<int, List<TablaAsistencia>> _agruparAsistenciasPorClase(
    List<TablaAsistencia> asistencias,
  ) {
    final out = <int, List<TablaAsistencia>>{};
    for (final fila in asistencias) {
      out.putIfAbsent(fila.claseId, () => <TablaAsistencia>[]).add(fila);
    }
    return out;
  }

  TablaClase? _buscarClaseDelDia(List<TablaClase> clases, DateTime d) {
    for (final clase in clases) {
      if (_esMismoDia(clase.fecha, d)) return clase;
    }
    return null;
  }

  TablaClase? _buscarUltimaAnterior(List<TablaClase> clases, DateTime dia) {
    for (final clase in clases) {
      if (clase.fecha.isBefore(dia)) return clase;
    }
    return null;
  }

  List<TablaClase> _tomarRecientes(
    List<TablaClase> clases,
    DateTime dia, {
    required int maximo,
  }) {
    final out = <TablaClase>[];
    for (final clase in clases) {
      if (clase.fecha.isAfter(dia)) continue;
      out.add(clase);
      if (out.length >= maximo) break;
    }
    return out;
  }

  _PendientesClase _contarPendientes(List<TablaAsistencia> asistencias) {
    var alumnosPendientes = 0;
    var actividadesSinEntregar = 0;

    for (final fila in asistencias) {
      final estado = fila.estado.trim().toLowerCase();
      if (estado == 'ausente' || estado == 'pendiente') {
        alumnosPendientes++;
      }
      if (!fila.actividadEntregada && estado != 'ausente') {
        actividadesSinEntregar++;
      }
    }

    return _PendientesClase(
      alumnosPendientes: alumnosPendientes,
      actividadesSinEntregar: actividadesSinEntregar,
    );
  }

  int _contarCorreccionesPendientes({
    required List<int> idsClases,
    required Map<int, List<TablaAsistencia>> asistenciasPorClase,
  }) {
    var pendientes = 0;
    for (final claseId in idsClases) {
      final asistencias = asistenciasPorClase[claseId] ?? const [];
      for (final fila in asistencias) {
        final nota = (fila.notaActividad ?? '').trim();
        if (fila.actividadEntregada && nota.isEmpty) {
          pendientes++;
        }
      }
    }
    return pendientes;
  }

  String _resolverContinuidad({
    required TablaClase? claseHoy,
    required TablaClase? claseAnterior,
  }) {
    final textoHoy = _textoPrincipalClase(claseHoy);
    if (textoHoy != null) return textoHoy;

    final textoAnterior = _textoPrincipalClase(claseAnterior);
    if (textoAnterior != null) return textoAnterior;

    return 'Sin tema previo registrado';
  }

  TablaClase? _buscarProximaEvaluacion(List<TablaClase> clases) {
    for (final clase in clases) {
      final texto = _textoBusqueda(clase).toLowerCase();
      if (texto.contains('eval') ||
          texto.contains('parcial') ||
          texto.contains('recuper') ||
          texto.contains('tp') ||
          texto.contains('oral')) {
        return clase;
      }
    }
    return null;
  }

  String _textoBusqueda(TablaClase clase) {
    final tema = (clase.tema ?? '').trim();
    final actividad = (clase.actividadDia ?? '').trim();
    final obs = (clase.observacion ?? '').trim();
    return '$tema $actividad $obs';
  }

  String? _textoPrincipalClase(TablaClase? clase) {
    if (clase == null) return null;
    final tema = (clase.tema ?? '').trim();
    if (tema.isNotEmpty) return tema;
    final actividad = (clase.actividadDia ?? '').trim();
    if (actividad.isNotEmpty) return actividad;
    final obs = (clase.observacion ?? '').trim();
    if (obs.isNotEmpty) return obs;
    return null;
  }

  bool _esMismoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _sumarMeses(DateTime base, int delta) {
    final totalMeses = base.year * 12 + (base.month - 1) + delta;
    final year = totalMeses ~/ 12;
    final month = (totalMeses % 12) + 1;
    return DateTime(year, month);
  }

  DateTime _fechaDesdeEpoch(int epochSegundos) {
    return DateTime.fromMillisecondsSinceEpoch(epochSegundos * 1000);
  }

  String? _normalizarHora(String? valor) {
    final t = (valor ?? '').trim();
    final regex = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$');
    if (!regex.hasMatch(t)) return null;
    return t;
  }

  String _construirClaveAlerta({
    required String tipo,
    required int? cursoId,
    required int? alumnoId,
    required String mensaje,
  }) {
    final base = mensaje.trim().toLowerCase();
    final compacta = base.replaceAll(RegExp(r'\s+'), ' ');
    final corta = compacta.length <= 80 ? compacta : compacta.substring(0, 80);
    return '$tipo|c:${cursoId ?? 0}|a:${alumnoId ?? 0}|$corta';
  }

  bool _detectarMejoraAsistencia(List<bool> serie) {
    if (serie.length < 6) return false;
    final recientes = serie.take(4).toList(growable: false);
    final previas = serie.skip(4).take(4).toList(growable: false);
    if (previas.length < 2) return false;
    final pctRecientes = recientes.where((x) => x).length / recientes.length;
    final pctPrevias = previas.where((x) => x).length / previas.length;
    return (pctRecientes - pctPrevias) >= 0.25;
  }

  String _calcularNivelRiesgoHistorial(_HistorialStats s) {
    var puntaje = 0;

    if (s.inasistenciasConsecutivas >= 3) {
      puntaje += 3;
    } else if (s.inasistenciasConsecutivas == 2) {
      puntaje += 2;
    } else if (s.inasistenciasConsecutivas == 1) {
      puntaje += 1;
    }

    if (s.faltas >= 8) {
      puntaje += 3;
    } else if (s.faltas >= 5) {
      puntaje += 2;
    } else if (s.faltas >= 3) {
      puntaje += 1;
    }

    if (s.actividadesSinEntregar >= 4) {
      puntaje += 2;
    } else if (s.actividadesSinEntregar >= 2) {
      puntaje += 1;
    }

    if (s.evaluacionesPendientes >= 3) {
      puntaje += 2;
    } else if (s.evaluacionesPendientes >= 1) {
      puntaje += 1;
    }
    if (s.evaluacionesRecuperacion >= 2) {
      puntaje += 2;
    } else if (s.evaluacionesRecuperacion == 1) {
      puntaje += 1;
    }

    if (s.intervencionesAbiertas >= 2) {
      puntaje += 2;
    } else if (s.intervencionesAbiertas == 1) {
      puntaje += 1;
    }

    if (s.mejoraReciente && puntaje > 0) puntaje -= 1;

    if (puntaje >= 7) return 'alto';
    if (puntaje >= 4) return 'medio';
    return 'bajo';
  }

  String _resumenHistorialAlumno(_HistorialStats s, String riesgo) {
    final partes = <String>[];
    if (s.inasistenciasConsecutivas >= 3) {
      partes.add('${s.inasistenciasConsecutivas} inasistencias seguidas');
    } else if (s.faltas >= 4) {
      partes.add('${s.faltas} faltas recientes');
    }
    if (s.actividadesSinEntregar >= 2) {
      partes.add('${s.actividadesSinEntregar} actividades sin entregar');
    }
    if (s.evaluacionesPendientes >= 2 || s.evaluacionesRecuperacion >= 1) {
      partes.add(
        '${s.evaluacionesPendientes} evaluaciones pendientes, ${s.evaluacionesRecuperacion} en recuperacion',
      );
    }
    if (s.intervencionesAbiertas > 0) {
      partes.add('${s.intervencionesAbiertas} intervenciones abiertas');
    }
    if (s.mejoraReciente) {
      partes.add('con mejora reciente en asistencia');
    }
    if (partes.isEmpty) {
      if (riesgo == 'bajo') return 'Seguimiento estable.';
      return 'Requiere seguimiento de proceso.';
    }
    return partes.join(' | ');
  }

  int _pesoRiesgo(String riesgo) {
    final valor = riesgo.trim().toLowerCase();
    if (valor == 'alto') return 3;
    if (valor == 'medio') return 2;
    return 1;
  }

  PlantillaDocente _mapPlantillaDocente(QueryRow row) {
    return PlantillaDocente(
      id: row.read<int>('id'),
      institucion: row.read<String?>('institucion'),
      cursoId: row.read<int?>('curso_id'),
      tipo: row.read<String>('tipo'),
      titulo: row.read<String>('titulo'),
      contenido: row.read<String>('contenido'),
      atajo: row.read<String?>('atajo'),
      orden: row.read<int>('orden'),
      usoCount: row.read<int>('uso_count'),
      actualizadoEn: _fechaDesdeEpoch(row.read<int>('actualizado_en')),
    );
  }

  String _determinarGrupoPedagogico(HistorialAlumnoInteligente h) {
    final riesgo = h.nivelRiesgo.trim().toLowerCase();
    final refuerzo =
        riesgo == 'alto' ||
        h.inasistenciasConsecutivas >= 2 ||
        h.actividadesSinEntregar >= 3 ||
        h.evaluacionesPendientes >= 3 ||
        h.evaluacionesRecuperacion >= 1;
    if (refuerzo) return 'refuerzo';

    final autonomo =
        riesgo == 'bajo' &&
        h.faltas <= 2 &&
        h.actividadesSinEntregar == 0 &&
        h.evaluacionesPendientes <= 1 &&
        h.evaluacionesRecuperacion == 0;
    if (autonomo) return 'autonomo';

    return 'media';
  }

  String _fundamentoGrupoPedagogico(
    HistorialAlumnoInteligente h,
    String grupo,
  ) {
    if (grupo == 'refuerzo') {
      final causas = <String>[];
      if (h.inasistenciasConsecutivas >= 2) {
        causas.add('${h.inasistenciasConsecutivas} inasistencias seguidas');
      }
      if (h.actividadesSinEntregar >= 2) {
        causas.add('${h.actividadesSinEntregar} actividades pendientes');
      }
      if (h.evaluacionesRecuperacion >= 1 || h.evaluacionesPendientes >= 2) {
        causas.add(
          '${h.evaluacionesPendientes} evaluaciones pendientes, ${h.evaluacionesRecuperacion} en recuperacion',
        );
      }
      if (causas.isEmpty) {
        causas.add('riesgo academico sostenido');
      }
      if (h.mejoraReciente) {
        causas.add('con mejora reciente');
      }
      return causas.join(' | ');
    }

    if (grupo == 'autonomo') {
      final base = 'seguimiento estable y buena continuidad';
      if (h.mejoraReciente) return '$base | mejora reciente';
      return base;
    }

    final partes = <String>[
      'requiere acompanamiento regular',
      '${h.evaluacionesPendientes} evaluaciones pendientes',
    ];
    if (h.mejoraReciente) {
      partes.add('con mejora reciente');
    }
    return partes.join(' | ');
  }

  int _prioridadGrupo(String grupo) {
    final g = grupo.trim().toLowerCase();
    if (g == 'refuerzo') return 0;
    if (g == 'media') return 1;
    return 2;
  }

  Future<String> _resolverEstadoEvaluacionSegunRegla({
    required int evaluacionId,
    required String estadoActual,
    required String? calificacion,
  }) async {
    final estado = _normalizarEstadoEvaluacionInterno(estadoActual);
    final calif = (calificacion ?? '').trim();
    if (calif.isEmpty) return estado;
    if (estado == 'ausente') return estado;
    if (estado == 'aprobado' || estado == 'recuperacion') return estado;

    final row = await _db
        .customSelect(
          '''
      SELECT
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
    if (row == null) return estado;
    final institucion = row.read<String>('institucion');
    final regla = await obtenerReglaInstitucion(institucion);
    final aprueba = _calificacionApruebaSegunRegla(calif, regla);
    return aprueba ? 'aprobado' : 'recuperacion';
  }

  String _normalizarEstadoEvaluacionInterno(String estado) {
    final s = estado.trim().toLowerCase();
    if (s == 'aprobado') return 'aprobado';
    if (s == 'ausente') return 'ausente';
    if (s == 'recuperacion' || s == 'recupera' || s == 'recuperatorio') {
      return 'recuperacion';
    }
    if (s == 'no_aprobado' || s == 'desaprobado') return 'recuperacion';
    if (s == 'en_proceso' || s == 'proceso') return 'en_proceso';
    return 'pendiente';
  }

  bool _calificacionApruebaSegunRegla(String calificacion, ReglaInstitucion r) {
    final t = calificacion.trim().toLowerCase();
    if (t.isEmpty) return false;

    if (r.escalaCalificacion.trim().toLowerCase() == 'conceptual') {
      if (t.contains('aprob') ||
          t.contains('muy bueno') ||
          t.contains('bueno') ||
          t.contains('sobresal')) {
        return true;
      }
      if (t.contains('desaprob') ||
          t.contains('insuf') ||
          t.contains('regular')) {
        return false;
      }
    }

    final m = RegExp(r'[-+]?[0-9]*[.,]?[0-9]+').firstMatch(t);
    if (m == null) {
      if (t == 'a' || t == 'ok' || t == 'apto') return true;
      return false;
    }

    final valor = double.tryParse(m.group(0)!.replaceAll(',', '.'));
    if (valor == null) return false;

    final umbralParse = double.tryParse(
      r.notaAprobacion.trim().replaceAll(',', '.'),
    );
    final umbralDefault =
        r.escalaCalificacion.trim().toLowerCase() == 'numerica_100'
        ? 60.0
        : 6.0;
    final umbral = umbralParse ?? umbralDefault;
    return valor >= umbral;
  }

  Future<void> _registrarAuditoriaCambio({
    required String entidad,
    int? entidadId,
    required String campo,
    String? valorAnterior,
    String? valorNuevo,
    String? contexto,
    int? cursoId,
    String? institucion,
    String usuario = 'docente',
  }) async {
    final anterior = _nullSiVacio(valorAnterior);
    final nuevo = _nullSiVacio(valorNuevo);
    if ((anterior ?? '') == (nuevo ?? '')) return;
    await _db.customInsert(
      '''
      INSERT INTO tabla_auditoria_docente (
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
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      ''',
      variables: [
        Variable.withString(entidad.trim()),
        Variable<int>(entidadId),
        Variable.withString(campo.trim()),
        Variable<String>(anterior),
        Variable<String>(nuevo),
        Variable<String>(_nullSiVacio(contexto)),
        Variable<int>(cursoId),
        Variable<String>(_nullSiVacio(institucion)),
        Variable.withString(
          usuario.trim().isEmpty ? 'docente' : usuario.trim(),
        ),
      ],
    );
  }

  String _calcularSemaforoDashboard({
    required int alertasAltas,
    required int alertasMedias,
    required int evaluacionesAbiertas,
    required int estudiantesRiesgo,
  }) {
    if (alertasAltas >= 3 ||
        estudiantesRiesgo >= 8 ||
        evaluacionesAbiertas >= 8) {
      return 'rojo';
    }
    if (alertasAltas >= 1 ||
        alertasMedias >= 4 ||
        estudiantesRiesgo >= 4 ||
        evaluacionesAbiertas >= 3) {
      return 'amarillo';
    }
    return 'verde';
  }

  int _prioridadSemaforoDashboard(String semaforo) {
    final s = semaforo.trim().toLowerCase();
    if (s == 'rojo') return 0;
    if (s == 'amarillo') return 1;
    return 2;
  }

  String? _nullSiVacio(String? value) {
    final t = (value ?? '').trim();
    return t.isEmpty ? null : t;
  }
}
