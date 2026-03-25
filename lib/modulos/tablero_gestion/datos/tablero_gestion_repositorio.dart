import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show IconData, Icons;

import 'package:gestion_de_asistencias/infraestructura/base_de_datos/base_de_datos.dart';
import 'package:gestion_de_asistencias/modulos/panel_institucional/modelos/perfil_institucional.dart';
import 'package:gestion_de_asistencias/modulos/tablero_gestion/modelos/tablero_gestion_item.dart';

class TableroGestionRepositorio {
  final BaseDeDatos _db;

  TableroGestionRepositorio(this._db);

  Future<TableroGestionItem> cargar(
    ContextoInstitucional contexto, {
    PeriodoProductividadGestion periodoProductividad =
        PeriodoProductividadGestion.mensual,
  }) async {
    final institucionesActivas = await _contarInstitucionesActivas();
    final carrerasActivas = await _contarCarrerasActivas();
    final cursosActivos = await _contarCursosActivos();
    final alumnosActivos = await _contarAlumnosActivos();

    final desde30 = DateTime.now().subtract(const Duration(days: 30));
    final clasesUltimos30 =
        await (_db.select(_db.tablaClases)
              ..where((t) => t.fecha.isBiggerOrEqualValue(desde30)))
            .get();
    final claseIds = clasesUltimos30.map((e) => e.id).toList(growable: false);

    int registrosAsistencia = 0;
    int registrosComputables = 0;
    if (claseIds.isNotEmpty) {
      final asistencias =
          await (_db.select(
            _db.tablaAsistencias,
          )..where((t) => t.claseId.isIn(claseIds))).get();
      registrosAsistencia = asistencias.length;
      registrosComputables = asistencias.where((item) {
        final estado = item.estado.trim().toLowerCase();
        return estado == 'presente' ||
            estado == 'tarde' ||
            estado == 'justificada';
      }).length;
    }

    final promedioAsistencia = registrosAsistencia == 0
        ? 0.0
        : (registrosComputables / registrosAsistencia) * 100;

    final cursosSinClaseReciente = await _cursosSinClaseReciente();
    final alumnosSinDocumento = await _alumnosSinDocumento();
    final legajosCriticos = await _legajosCriticos(contexto);

    final indicadores = [
      IndicadorGestion(
        titulo: 'Instituciones activas',
        valor: '$institucionesActivas',
        descripcion: 'Sedes o unidades academicas operativas.',
        icono: Icons.apartment_outlined,
      ),
      IndicadorGestion(
        titulo: 'Cursos activos',
        valor: '$cursosActivos',
        descripcion: 'Oferta academica disponible actualmente.',
        icono: Icons.class_outlined,
      ),
      IndicadorGestion(
        titulo: 'Alumnos activos',
        valor: '$alumnosActivos',
        descripcion: 'Trayectorias estudiantiles con seguimiento vigente.',
        icono: Icons.school_outlined,
      ),
      IndicadorGestion(
        titulo: 'Asistencia 30 dias',
        valor: '${promedioAsistencia.toStringAsFixed(1)}%',
        descripcion: 'Promedio institucional de asistencia computable.',
        icono: Icons.fact_check_outlined,
      ),
    ];

    final alertasCrudas = <AlertaGestion>[
      if (legajosCriticos > 0)
        AlertaGestion(
          clave: _claveAlerta(contexto, 'legajos_criticos'),
          titulo: 'Legajos criticos activos',
          descripcion:
              '$legajosCriticos registros documentales requieren intervencion prioritaria.',
          severidad: 'Alta',
          icono: Icons.folder_open_outlined,
        ),
      if (cursosSinClaseReciente > 0)
        AlertaGestion(
          clave: _claveAlerta(contexto, 'cursos_sin_clase'),
          titulo: 'Cursos sin clase reciente',
          descripcion:
              '$cursosSinClaseReciente cursos no registran actividad en los ultimos 14 dias.',
          severidad: 'Alta',
          icono: Icons.event_busy_outlined,
        ),
      if (alumnosSinDocumento > 0)
        AlertaGestion(
          clave: _claveAlerta(contexto, 'alumnos_sin_documento'),
          titulo: 'Alumnos sin documento cargado',
          descripcion:
              '$alumnosSinDocumento legajos estudiantiles estan incompletos a nivel documental.',
          severidad: 'Media',
          icono: Icons.badge_outlined,
        ),
      if (promedioAsistencia > 0 && promedioAsistencia < 75)
        AlertaGestion(
          clave: _claveAlerta(contexto, 'asistencia_en_riesgo'),
          titulo: 'Asistencia institucional en riesgo',
          descripcion:
              'El promedio de asistencia esta por debajo del umbral operativo esperado.',
          severidad: 'Alta',
          icono: Icons.warning_amber_outlined,
        ),
      if (institucionesActivas == 0)
        AlertaGestion(
          clave: _claveAlerta(contexto, 'sin_estructura'),
          titulo: 'Sin estructura institucional cargada',
          descripcion:
              'Conviene completar instituciones, carreras y cursos para habilitar el tablero completo.',
          severidad: 'Media',
          icono: Icons.info_outline,
        ),
    ];

    final seguimientos = await _listarSeguimientos(contexto);
    final vencidosActivos = seguimientos
        .where((item) => item.estado != 'resuelta' && item.estaVencido)
        .length;
    final reabiertos = seguimientos
        .where((item) => item.estado == 'reabierta')
        .length;
    final altaPrioridad = seguimientos
        .where((item) => item.urgencia == 'Vencida' || item.urgencia == 'Alta')
        .length;
    final resueltos = seguimientos
        .where((item) => item.estado == 'resuelta')
        .length;
    final escalamientos = seguimientos
        .where(
          (item) =>
              item.estado != 'resuelta' &&
              (item.estaVencido || item.estado == 'reabierta'),
        )
        .toList(growable: false);
    final productividad = await _construirProductividad(
      contexto: contexto,
      periodo: periodoProductividad,
      seguimientos: seguimientos,
    );
    alertasCrudas.addAll(
      _construirAlertasProductividad(
        contexto: contexto,
        productividad: productividad,
      ),
    );
    alertasCrudas.addAll(
      _construirAlertasCalidadCierre(
        contexto: contexto,
        productividad: productividad,
      ),
    );
    alertasCrudas.addAll(
      _construirAlertasEfectividadCorrectiva(
        contexto: contexto,
        productividad: productividad,
      ),
    );
    alertasCrudas.addAll(
      _construirAlertasRevisionCorrectiva(
        contexto: contexto,
        productividad: productividad,
      ),
    );
    alertasCrudas.addAll(
      _construirAlertasCumplimientoPlanMejora(
        contexto: contexto,
        seguimientos: seguimientos,
      ),
    );
    alertasCrudas.addAll(
      _construirAlertasCronificacionPlanMejora(
        contexto: contexto,
        productividad: productividad,
      ),
    );
    alertasCrudas.addAll(
      _construirAlertasPostReplanificacion(
        contexto: contexto,
        productividad: productividad,
      ),
    );
    alertasCrudas.addAll(
      _construirAlertasFocoRiesgoReplanificacion(
        contexto: contexto,
        productividad: productividad,
      ),
    );
    alertasCrudas.addAll(
      _construirAlertasEstrategiaCorrectivaEnRiesgo(
        contexto: contexto,
        productividad: productividad,
      ),
    );
    alertasCrudas.addAll(
      _construirAlertasEstrategiaCorrectivaEnDeterioro(
        contexto: contexto,
        productividad: productividad,
      ),
    );
    alertasCrudas.addAll(
      _construirAlertasRecomendacionEstrategicaInestable(
        contexto: contexto,
        productividad: productividad,
      ),
    );

    if (vencidosActivos > 0) {
      alertasCrudas.insert(
        0,
        AlertaGestion(
          clave: _claveAlerta(contexto, 'seguimientos_vencidos'),
          titulo: 'Seguimientos vencidos',
          descripcion:
              '$vencidosActivos seguimientos superaron su ventana operativa y necesitan escalamiento directivo.',
          severidad: 'Alta',
          icono: Icons.pending_actions_outlined,
        ),
      );
    }
    if (reabiertos > 0) {
      alertasCrudas.insert(
        vencidosActivos > 0 ? 1 : 0,
        AlertaGestion(
          clave: _claveAlerta(contexto, 'seguimientos_reabiertos'),
          titulo: 'Seguimientos reabiertos',
          descripcion:
              '$reabiertos casos volvieron a abrirse y conviene revisar el circuito de resolucion.',
          severidad: 'Alta',
          icono: Icons.restart_alt_outlined,
        ),
      );
    }

    final alertas = await _filtrarAlertasPorEstado(alertasCrudas);
    final semaforos = [
      _construirSemaforoProductividad(productividad),
      SemaforoGestion(
        titulo: 'Escaladas',
        valor: '$vencidosActivos',
        descripcion: 'Seguimientos fuera de ventana operativa.',
        estado: vencidosActivos > 0 ? 'Rojo' : 'Verde',
        icono: Icons.notifications_active_outlined,
      ),
      SemaforoGestion(
        titulo: 'Reabiertas',
        valor: '$reabiertos',
        descripcion: 'Casos que volvieron a entrar en gestion.',
        estado: reabiertos > 0 ? 'Amarillo' : 'Verde',
        icono: Icons.restart_alt_outlined,
      ),
      SemaforoGestion(
        titulo: 'Alta prioridad',
        valor: '$altaPrioridad',
        descripcion: 'Bandeja inmediata para direccion o rectorado.',
        estado: altaPrioridad > 0 ? 'Amarillo' : 'Verde',
        icono: Icons.priority_high_outlined,
      ),
      SemaforoGestion(
        titulo: 'Resueltas',
        valor: '$resueltos',
        descripcion: 'Seguimientos cerrados con trazabilidad disponible.',
        estado: resueltos > 0 ? 'Verde' : 'Gris',
        icono: Icons.task_alt_outlined,
      ),
    ];

    final hitos = [
      HitoGestion(
        etiqueta: 'Carreras',
        valor: '$carrerasActivas',
        ayuda: 'Oferta formativa vigente en la estructura.',
      ),
      HitoGestion(
        etiqueta: 'Clases 30 dias',
        valor: '${clasesUltimos30.length}',
        ayuda: 'Actividad pedagógica registrada recientemente.',
      ),
      HitoGestion(
        etiqueta: 'Registros asistencia',
        valor: '$registrosAsistencia',
        ayuda: 'Volumen de trazabilidad operativa en el periodo.',
      ),
    ];

    return TableroGestionItem(
      indicadores: indicadores,
      semaforos: semaforos,
      productividad: productividad,
      escalamientos: escalamientos,
      alertas: alertas,
      hitos: hitos,
      seguimientos: seguimientos,
    );
  }

  Future<DetalleAlertaGestion> obtenerDetalleAlerta(
    String clave,
    ContextoInstitucional contexto,
  ) async {
    final tipo = clave.split(':').last;
    final periodoCalidadCierre = _periodoDesdeTipoCalidadCierre(tipo);
    if (periodoCalidadCierre != null) {
      if (tipo.startsWith('calidad_cierre_general_')) {
        return _detalleCalidadCierreGeneral(contexto, periodoCalidadCierre);
      }
      if (tipo.startsWith('calidad_cierre_critico_concentrado_')) {
        return _detalleCalidadCierreCritico(
          contexto,
          periodoCalidadCierre,
        );
      }
    }
    final periodoEfectividadCorrectiva = _periodoDesdeTipoEfectividadCorrectiva(
      tipo,
    );
    if (periodoEfectividadCorrectiva != null) {
      return _detalleEfectividadCorrectiva(
        contexto,
        periodoEfectividadCorrectiva,
      );
    }
    final periodoRevisionCorrectiva = _periodoDesdeTipoRevisionCorrectiva(tipo);
    if (periodoRevisionCorrectiva != null) {
      return _detalleBloqueosCorrectivosRecurrentes(
        contexto,
        periodoRevisionCorrectiva,
      );
    }
    final periodoCronificacionPlan = _periodoDesdeTipoCronificacionPlanMejora(
      tipo,
    );
    if (periodoCronificacionPlan != null) {
      return _detalleCronificacionPlanMejora(
        contexto,
        periodoCronificacionPlan,
      );
    }
    final periodoPostReplanificacion = _periodoDesdeTipoPostReplanificacion(
      tipo,
    );
    if (periodoPostReplanificacion != null) {
      return _detallePostReplanificacion(
        contexto,
        periodoPostReplanificacion,
      );
    }
    final periodoFocoReplanificacion = _periodoDesdeTipoFocoReplanificacion(
      tipo,
    );
    if (periodoFocoReplanificacion != null) {
      return _detalleFocoRiesgoReplanificacion(
        contexto,
        periodoFocoReplanificacion,
      );
    }
    final periodoEstrategiaCorrectiva = _periodoDesdeTipoEstrategiaCorrectiva(
      tipo,
    );
    if (periodoEstrategiaCorrectiva != null) {
      return _detalleEstrategiaCorrectivaEnRiesgo(
        contexto,
        periodoEstrategiaCorrectiva,
        tipo,
      );
    }
    final periodoEstrategiaDeterioro =
        _periodoDesdeTipoEstrategiaCorrectivaDeterioro(tipo);
    if (periodoEstrategiaDeterioro != null) {
      return _detalleEstrategiaCorrectivaEnDeterioro(
        contexto,
        periodoEstrategiaDeterioro,
        tipo,
      );
    }
    final periodoRecomendacionInestable =
        _periodoDesdeTipoRecomendacionEstrategica(tipo);
    if (periodoRecomendacionInestable != null) {
      return _detalleRecomendacionEstrategicaInestable(
        contexto,
        periodoRecomendacionInestable,
      );
    }
    switch (tipo) {
      case 'planes_mejora_vencidos':
        return _detallePlanesMejora(
          contexto,
          soloVencidos: true,
        );
      case 'planes_mejora_por_vencer':
        return _detallePlanesMejora(
          contexto,
          soloVencidos: false,
        );
    }
    final periodoProductividad = _periodoDesdeTipoAlerta(tipo);
    final tendenciaProductividad = _tendenciaDesdeTipoAlerta(tipo);
    if (periodoProductividad != null && tendenciaProductividad != null) {
      return obtenerDetalleTendenciaProductividad(
        tendenciaProductividad,
        contexto,
        periodoProductividad,
      );
    }
    switch (tipo) {
      case 'legajos_criticos':
        return _detalleLegajosCriticos(contexto);
      case 'cursos_sin_clase':
        return _detalleCursosSinClase();
      case 'alumnos_sin_documento':
        return _detalleAlumnosSinDocumento();
      case 'asistencia_en_riesgo':
        return _detalleAsistenciaEnRiesgo();
      case 'sin_estructura':
        return _detalleSinEstructura();
      case 'seguimientos_vencidos':
        return _detalleSeguimientosVencidos(contexto);
      case 'seguimientos_reabiertos':
        return _detalleSeguimientosReabiertos(contexto);
      default:
        return const DetalleAlertaGestion(
          titulo: 'Detalle no disponible',
          descripcion: 'Todavia no hay una vista de detalle para esta alerta.',
          filas: [],
        );
    }
  }

  Future<List<HistorialAlertaGestion>> obtenerHistorialAlerta(
    String clave,
  ) async {
    final rows =
        await (_db.select(_db.tablaAlertasGestionHistorial)
              ..where((t) => t.clave.equals(clave))
              ..orderBy([
                (t) => OrderingTerm.desc(t.creadoEn),
                (t) => OrderingTerm.desc(t.id),
              ]))
            .get();

    return rows
        .map(
          (row) => HistorialAlertaGestion(
            accion: row.accion,
            estadoAnterior: row.estadoAnterior,
            estadoNuevo: row.estadoNuevo,
            derivadaA: row.derivadaA,
            comentario: row.comentario ?? '',
            creadoEn: row.creadoEn,
          ),
        )
        .toList(growable: false);
  }

  Future<DetalleAlertaGestion> obtenerDetalleTendenciaProductividad(
    String clave,
    ContextoInstitucional contexto,
    PeriodoProductividadGestion periodo,
  ) async {
    final prefijo = [
      contexto.rol.name,
      contexto.nivel.name,
      contexto.dependencia.name,
    ].join(':');
    final desdeAnterior = DateTime.now().subtract(Duration(days: periodo.dias * 2));

    final rows = await _db.customSelect(
      '''
      SELECT
        clave,
        accion,
        COALESCE(derivada_a, '') AS derivada_a,
        COALESCE(comentario, '') AS comentario,
        creado_en
      FROM tabla_alertas_gestion_historial
      WHERE clave LIKE ?
        AND creado_en >= ?
      ORDER BY clave ASC, creado_en ASC, id ASC
      ''',
      variables: [
        Variable<String>('$prefijo:%'),
        Variable<DateTime>(desdeAnterior),
      ],
    ).get();

    final filas = switch (clave) {
      'cierres_ejecutivos' => _detalleTendenciaConteo(
        rows: rows,
        periodo: periodo,
        accionValida: (accion) => accion == 'cierre_ejecutivo',
        unidad: 'cierres',
      ),
      'resoluciones' => _detalleTendenciaConteo(
        rows: rows,
        periodo: periodo,
        accionValida: (accion) =>
            accion == 'resuelta' || accion == 'cierre_ejecutivo',
        unidad: 'resoluciones',
      ),
      'reaperturas' => _detalleTendenciaConteo(
        rows: rows,
        periodo: periodo,
        accionValida: (accion) => accion == 'reabierta',
        unidad: 'reaperturas',
      ),
      'tiempo_resolucion' => _detalleTendenciaTiempo(
        rows: rows,
        periodo: periodo,
      ),
      _ => const <DetalleAlertaGestionFila>[],
    };

    return DetalleAlertaGestion(
      titulo: _tituloDetalleTendencia(clave),
      descripcion:
          'Desglose causal para ${periodo.etiqueta}, comparado contra los ${periodo.comparacionEtiqueta}.',
      filas: filas,
    );
  }

  Future<void> atenderAlerta(String clave, {String? comentario}) async {
    await _guardarEstadoAlerta(
      clave: clave,
      estado: 'atendida',
      comentario: comentario,
      pospuestaHasta: null,
      derivadaA: null,
    );
  }

  Future<void> posponerAlerta(
    String clave, {
    required Duration duracion,
    String? comentario,
  }) async {
    await _guardarEstadoAlerta(
      clave: clave,
      estado: 'pospuesta',
      comentario: comentario,
      pospuestaHasta: DateTime.now().add(duracion),
      derivadaA: null,
    );
  }

  Future<void> derivarAlerta(
    String clave, {
    required String derivadaA,
    String? comentario,
  }) async {
    await _guardarEstadoAlerta(
      clave: clave,
      estado: 'derivada',
      comentario: comentario,
      pospuestaHasta: null,
      derivadaA: derivadaA,
    );
  }

  Future<void> resolverAlerta(
    String clave, {
    required String? derivadaA,
    String? comentario,
  }) async {
    await _guardarEstadoAlerta(
      clave: clave,
      estado: 'resuelta',
      comentario: comentario,
      pospuestaHasta: null,
      derivadaA: derivadaA,
    );
  }

  Future<void> cerrarSeguimientoEjecutivo(
    String clave, {
    required String? derivadaA,
    required String conclusion,
    required String decision,
    String? proximoPaso,
  }) async {
    final previo =
        await (_db.select(_db.tablaAlertasGestionEstado)
              ..where((t) => t.clave.equals(clave)))
            .getSingleOrNull();
    final derivadaNormalizada = _nullSiVacio(derivadaA);
    final comentarioNormalizado = _armarCierreEjecutivo(
      conclusion: conclusion,
      decision: decision,
      proximoPaso: proximoPaso,
    );
    final ahora = DateTime.now();

    await _db
        .into(_db.tablaAlertasGestionEstado)
        .insert(
          TablaAlertasGestionEstadoCompanion.insert(
            clave: clave,
            estado: 'resuelta',
            pospuestaHasta: const Value(null),
            derivadaA: Value(derivadaNormalizada),
            comentario: Value(comentarioNormalizado),
            actualizadoEn: Value(ahora),
          ),
          onConflict: DoUpdate(
            (_) => TablaAlertasGestionEstadoCompanion(
              estado: const Value('resuelta'),
              pospuestaHasta: const Value(null),
              derivadaA: Value(derivadaNormalizada),
              comentario: Value(comentarioNormalizado),
              actualizadoEn: Value(ahora),
            ),
            target: [_db.tablaAlertasGestionEstado.clave],
          ),
        );

    await _registrarHistorial(
      clave: clave,
      accion: 'cierre_ejecutivo',
      estadoAnterior: previo?.estado,
      estadoNuevo: 'resuelta',
      derivadaA: derivadaNormalizada,
      comentario: comentarioNormalizado,
      creadoEn: ahora,
    );
  }

  Future<void> reabrirAlerta(
    String clave, {
    required String? derivadaA,
    String? comentario,
  }) async {
    await _guardarEstadoAlerta(
      clave: clave,
      estado: 'reabierta',
      comentario: comentario,
      pospuestaHasta: null,
      derivadaA: derivadaA,
    );
  }

  Future<void> reasignarSeguimiento(
    String clave, {
    required String derivadaA,
    String? comentario,
  }) async {
    final previo =
        await (_db.select(_db.tablaAlertasGestionEstado)
              ..where((t) => t.clave.equals(clave)))
            .getSingleOrNull();
    final estadoActual = previo?.estado ?? 'derivada';
    final comentarioNormalizado = _nullSiVacio(comentario);
    final derivadaNormalizada = _nullSiVacio(derivadaA);
    final ahora = DateTime.now();

    await _db
        .into(_db.tablaAlertasGestionEstado)
        .insert(
          TablaAlertasGestionEstadoCompanion.insert(
            clave: clave,
            estado: estadoActual,
            pospuestaHasta: Value(previo?.pospuestaHasta),
            derivadaA: Value(derivadaNormalizada),
            comentario: Value(comentarioNormalizado),
            actualizadoEn: Value(ahora),
          ),
          onConflict: DoUpdate(
            (_) => TablaAlertasGestionEstadoCompanion(
              derivadaA: Value(derivadaNormalizada),
              comentario: Value(comentarioNormalizado),
              actualizadoEn: Value(ahora),
            ),
            target: [_db.tablaAlertasGestionEstado.clave],
          ),
        );

    await _registrarHistorial(
      clave: clave,
      accion: 'reasignada',
      estadoAnterior: previo?.estado,
      estadoNuevo: estadoActual,
      derivadaA: derivadaNormalizada,
      comentario: comentarioNormalizado,
      creadoEn: ahora,
    );
  }

  Future<void> registrarAccionSeguimiento(
    String clave, {
    required String accion,
    required String comentario,
    String? derivadaA,
  }) async {
    final previo =
        await (_db.select(_db.tablaAlertasGestionEstado)
              ..where((t) => t.clave.equals(clave)))
            .getSingleOrNull();
    final comentarioNormalizado = _nullSiVacio(comentario);
    final derivadaNormalizada = _nullSiVacio(derivadaA) ?? previo?.derivadaA;
    final estadoActual = previo?.estado ?? 'derivada';
    final ahora = DateTime.now();

    await _db
        .into(_db.tablaAlertasGestionEstado)
        .insert(
          TablaAlertasGestionEstadoCompanion.insert(
            clave: clave,
            estado: estadoActual,
            pospuestaHasta: Value(previo?.pospuestaHasta),
            derivadaA: Value(derivadaNormalizada),
            comentario: Value(comentarioNormalizado),
            actualizadoEn: Value(ahora),
          ),
          onConflict: DoUpdate(
            (_) => TablaAlertasGestionEstadoCompanion(
              comentario: Value(comentarioNormalizado),
              derivadaA: Value(derivadaNormalizada),
              actualizadoEn: Value(ahora),
            ),
            target: [_db.tablaAlertasGestionEstado.clave],
          ),
        );

    await _registrarHistorial(
      clave: clave,
      accion: accion,
      estadoAnterior: previo?.estado,
      estadoNuevo: estadoActual,
      derivadaA: derivadaNormalizada,
      comentario: comentarioNormalizado,
      creadoEn: ahora,
    );
  }

  Future<List<AlertaGestion>> _filtrarAlertasPorEstado(
    List<AlertaGestion> alertas,
  ) async {
    if (alertas.isEmpty) return const [];
    final claves = alertas.map((e) => e.clave).toList(growable: false);
    final rows =
        await (_db.select(_db.tablaAlertasGestionEstado)
              ..where((t) => t.clave.isIn(claves)))
            .get();
    final porClave = {
      for (final row in rows) row.clave: row,
    };
    final ahora = DateTime.now();
    final filtradas = <AlertaGestion>[];
    for (final alerta in alertas) {
      final estado = porClave[alerta.clave];
      if (estado == null) {
        filtradas.add(alerta);
        continue;
      }
      if (estado.estado == 'atendida') continue;
      if (estado.estado == 'pospuesta' &&
          estado.pospuestaHasta != null &&
          estado.pospuestaHasta!.isAfter(ahora)) {
        continue;
      }
      filtradas.add(
        alerta.copyWith(
          estadoSeguimiento: estado.estado,
          derivadaA: estado.derivadaA,
          comentario: estado.comentario,
        ),
      );
    }
    return filtradas;
  }

  Future<void> _guardarEstadoAlerta({
    required String clave,
    required String estado,
    required String? comentario,
    required DateTime? pospuestaHasta,
    required String? derivadaA,
  }) async {
    final previo =
        await (_db.select(_db.tablaAlertasGestionEstado)
              ..where((t) => t.clave.equals(clave)))
            .getSingleOrNull();
    final comentarioNormalizado = _nullSiVacio(comentario);
    final derivadaNormalizada = _nullSiVacio(derivadaA);
    final ahora = DateTime.now();

    await _db
        .into(_db.tablaAlertasGestionEstado)
        .insert(
          TablaAlertasGestionEstadoCompanion.insert(
            clave: clave,
            estado: estado,
            pospuestaHasta: Value(pospuestaHasta),
            derivadaA: Value(derivadaNormalizada),
            comentario: Value(comentarioNormalizado),
            actualizadoEn: Value(ahora),
          ),
          onConflict: DoUpdate(
            (_) => TablaAlertasGestionEstadoCompanion(
              estado: Value(estado),
              pospuestaHasta: Value(pospuestaHasta),
              derivadaA: Value(derivadaNormalizada),
              comentario: Value(comentarioNormalizado),
              actualizadoEn: Value(ahora),
            ),
            target: [_db.tablaAlertasGestionEstado.clave],
          ),
        );

    await _registrarHistorial(
      clave: clave,
      accion: estado,
      estadoAnterior: previo?.estado,
      estadoNuevo: estado,
      derivadaA: derivadaNormalizada,
      comentario: comentarioNormalizado,
      creadoEn: ahora,
    );
  }

  Future<void> _registrarHistorial({
    required String clave,
    required String accion,
    required String? estadoAnterior,
    required String estadoNuevo,
    required String? derivadaA,
    required String? comentario,
    required DateTime creadoEn,
  }) async {
    await _db.into(_db.tablaAlertasGestionHistorial).insert(
      TablaAlertasGestionHistorialCompanion.insert(
        clave: clave,
        accion: accion,
        estadoAnterior: Value(estadoAnterior),
        estadoNuevo: estadoNuevo,
        derivadaA: Value(derivadaA),
        comentario: Value(comentario),
        creadoEn: Value(creadoEn),
      ),
    );
  }

  String _claveAlerta(ContextoInstitucional contexto, String base) {
    return [
      contexto.rol.name,
      contexto.nivel.name,
      contexto.dependencia.name,
      base,
    ].join(':');
  }

  List<AlertaGestion> _construirAlertasProductividad({
    required ContextoInstitucional contexto,
    required ProductividadGestion productividad,
  }) {
    final alertas = <AlertaGestion>[];
    for (final tendencia in productividad.tendencias) {
      if (tendencia.estado != 'Alerta') continue;
      final tipo = _tipoAlertaProductividad(
        claveTendencia: tendencia.clave,
        periodo: productividad.periodo,
      );
      alertas.add(
        AlertaGestion(
          clave: _claveAlerta(contexto, tipo),
          titulo: _tituloAlertaProductividad(tendencia.titulo),
          descripcion: _descripcionAlertaProductividad(
            tendencia: tendencia,
            periodo: productividad.periodo,
          ),
          severidad: _severidadAlertaProductividad(tendencia.clave),
          icono: _iconoAlertaProductividad(tendencia.clave),
        ),
      );
    }
    return alertas;
  }

  List<AlertaGestion> _construirAlertasCalidadCierre({
    required ContextoInstitucional contexto,
    required ProductividadGestion productividad,
  }) {
    final alertas = <AlertaGestion>[];
    final totalCierres = productividad.cierresEjecutivos;
    if (totalCierres <= 0) return alertas;

    final cierresGenerales = productividad.cierresPatrones
        .where((item) => item.plantilla == 'Plantilla general')
        .fold<int>(0, (total, item) => total + item.cantidad);
    final cierresCriticos = productividad.cierresPatrones
        .where((item) => item.impacto == 'Critico')
        .toList(growable: false);

    if (totalCierres >= 3 && cierresGenerales * 2 >= totalCierres) {
      alertas.add(
        AlertaGestion(
          clave: _claveAlerta(
            contexto,
            _tipoAlertaCalidadCierre(
              base: 'general',
              periodo: productividad.periodo,
            ),
          ),
          titulo: 'Predominio de cierres generales',
          descripcion:
              '$cierresGenerales de $totalCierres cierres ejecutivos usan plantilla general durante ${productividad.periodo.etiqueta}.',
          severidad: 'Media',
          icono: Icons.content_paste_search_outlined,
          accionSugerida: _accionCorrectivaCalidadCierre('general'),
        ),
      );
    }

    final totalCriticos = cierresCriticos.fold<int>(
      0,
      (total, item) => total + item.cantidad,
    );
    if (totalCriticos >= 3 && cierresCriticos.isNotEmpty) {
      final principal = [...cierresCriticos]
        ..sort((a, b) => b.cantidad.compareTo(a.cantidad));
      final dominante = principal.first;
      if (dominante.cantidad * 100 >= totalCriticos * 70) {
        alertas.add(
          AlertaGestion(
            clave: _claveAlerta(
              contexto,
              _tipoAlertaCalidadCierre(
                base: 'critico_concentrado',
                periodo: productividad.periodo,
              ),
            ),
            titulo: 'Cierres criticos concentrados',
          descripcion:
              '${dominante.cantidad} de $totalCriticos cierres criticos se concentran en ${dominante.tipoCaso.toLowerCase()} durante ${productividad.periodo.etiqueta}.',
          severidad: 'Alta',
          icono: Icons.center_focus_strong_outlined,
          accionSugerida: _accionCorrectivaCalidadCierre(
            'critico_concentrado',
          ),
        ),
      );
      }
    }

    return alertas;
  }

  List<AlertaGestion> _construirAlertasEfectividadCorrectiva({
    required ContextoInstitucional contexto,
    required ProductividadGestion productividad,
  }) {
    if (productividad.comparativaPlanesCorrectivos.estado != 'Atencion') {
      return const [];
    }

    return [
      AlertaGestion(
        clave: _claveAlerta(
          contexto,
          _tipoAlertaEfectividadCorrectiva(productividad.periodo),
        ),
        titulo: 'Planes correctivos con efectividad en riesgo',
        descripcion: productividad.comparativaPlanesCorrectivos.lecturaEjecutiva,
        severidad: 'Alta',
        icono: Icons.rule_folder_outlined,
        accionSugerida: _accionCorrectivaEfectividadCorrectiva(),
      ),
    ];
  }

  List<AlertaGestion> _construirAlertasRevisionCorrectiva({
    required ContextoInstitucional contexto,
    required ProductividadGestion productividad,
  }) {
    if (!_hayBloqueoCorrectivoRecurrente(
      productividad.resumenRevisionesCorrectivas,
    )) {
      return const [];
    }

    final principal =
        productividad.resumenRevisionesCorrectivas.bloqueosFrecuentes.first;
    return [
      AlertaGestion(
        clave: _claveAlerta(
          contexto,
          _tipoAlertaRevisionCorrectiva(productividad.periodo),
        ),
        titulo: 'Bloqueos correctivos recurrentes',
        descripcion:
            '"${principal.etiqueta}" aparece ${principal.cantidad} veces en las revisiones correctivas de ${productividad.periodo.etiqueta}.',
        severidad: principal.cantidad >= 3 ? 'Alta' : 'Media',
        icono: Icons.find_in_page_outlined,
        accionSugerida: _accionCorrectivaRevisionCorrectiva(),
      ),
    ];
  }

  List<AlertaGestion> _construirAlertasCumplimientoPlanMejora({
    required ContextoInstitucional contexto,
    required List<SeguimientoGestion> seguimientos,
  }) {
    final vencidos = seguimientos.where((item) => item.planMejoraVencido).toList(
      growable: false,
    );
    final porVencer = seguimientos
        .where((item) => item.planMejoraPorVencer)
        .toList(growable: false);

    final alertas = <AlertaGestion>[];
    if (vencidos.isNotEmpty) {
      alertas.add(
        AlertaGestion(
          clave: _claveAlerta(contexto, 'planes_mejora_vencidos'),
          titulo: 'Planes de mejora vencidos',
          descripcion:
              '${vencidos.length} planes de mejora superaron su fecha objetivo y requieren replanificacion o cierre.',
          severidad: 'Alta',
          icono: Icons.event_busy_outlined,
          accionSugerida: _accionCorrectivaPlanesMejora('vencidos'),
        ),
      );
    }
    if (porVencer.isNotEmpty) {
      alertas.add(
        AlertaGestion(
          clave: _claveAlerta(contexto, 'planes_mejora_por_vencer'),
          titulo: 'Planes de mejora por vencer',
          descripcion:
              '${porVencer.length} planes de mejora llegan a su fecha objetivo en los proximos 3 dias.',
          severidad: 'Media',
          icono: Icons.event_available_outlined,
          accionSugerida: _accionCorrectivaPlanesMejora('por_vencer'),
        ),
      );
    }
    return alertas;
  }

  List<AlertaGestion> _construirAlertasCronificacionPlanMejora({
    required ContextoInstitucional contexto,
    required ProductividadGestion productividad,
  }) {
    final resumen = productividad.resumenCumplimientoPlanMejora;
    if (!_hayCronificacionPlanMejora(resumen)) {
      return const [];
    }

    final principal = resumen.planesCronificadosDetalle.isEmpty
        ? null
        : resumen.planesCronificadosDetalle.first;
    final descripcion = principal != null
        ? '${resumen.replanificacionesRegistradas} replanificaciones sobre ${productividad.periodo.etiqueta}. "${principal.etiqueta}" ya acumula ${principal.cantidad} reprogramaciones.'
        : resumen.lecturaEjecutiva;

    return [
      AlertaGestion(
        clave: _claveAlerta(
          contexto,
          _tipoAlertaCronificacionPlanMejora(productividad.periodo),
        ),
        titulo: 'Cronificacion de planes de mejora',
        descripcion: descripcion,
        severidad: resumen.planesCronificados > 0 ? 'Alta' : 'Media',
        icono: Icons.history_toggle_off_outlined,
        accionSugerida: _accionCorrectivaCronificacionPlanMejora(),
      ),
    ];
  }

  List<AlertaGestion> _construirAlertasPostReplanificacion({
    required ContextoInstitucional contexto,
    required ProductividadGestion productividad,
  }) {
    final resumen = productividad.resumenPostReplanificacion;
    if (resumen.estado != 'Atencion') {
      return const [];
    }

    return [
      AlertaGestion(
        clave: _claveAlerta(
          contexto,
          _tipoAlertaPostReplanificacion(productividad.periodo),
        ),
        titulo: 'Post-replanificacion en riesgo',
        descripcion: resumen.lecturaEjecutiva,
        severidad:
            (resumen.reabiertos + resumen.vencidosActivos) >= 2
                ? 'Alta'
                : 'Media',
        icono: Icons.restart_alt_outlined,
        accionSugerida: _accionCorrectivaPostReplanificacion(),
      ),
    ];
  }

  List<AlertaGestion> _construirAlertasFocoRiesgoReplanificacion({
    required ContextoInstitucional contexto,
    required ProductividadGestion productividad,
  }) {
    final comparativa = productividad.comparativaRiesgoReplanificacion;
    final foco = comparativa.foco;
    if (foco != 'Reprogramacion excesiva' &&
        foco != 'Reprogramacion inefectiva') {
      return const [];
    }

    final excesiva = foco == 'Reprogramacion excesiva';
    return [
      AlertaGestion(
        clave: _claveAlerta(
          contexto,
          _tipoAlertaFocoReplanificacion(
            productividad.periodo,
            excesiva: excesiva,
          ),
        ),
        titulo:
            excesiva
                ? 'Foco prioritario: reprogramacion excesiva'
                : 'Foco prioritario: reprogramacion inefectiva',
        descripcion: comparativa.lecturaEjecutiva,
        severidad: 'Alta',
        icono:
            excesiva
                ? Icons.history_toggle_off_outlined
                : Icons.restart_alt_outlined,
        accionSugerida: comparativa.accionSugerida,
      ),
    ];
  }

  List<AlertaGestion> _construirAlertasEstrategiaCorrectivaEnRiesgo({
    required ContextoInstitucional contexto,
    required ProductividadGestion productividad,
  }) {
    final riesgos = productividad.resumenEstrategiasCorrectivas.estrategias
        .where((item) => _puntajeRiesgoEstrategia(item) >= 3)
        .toList(growable: false);
    if (riesgos.isEmpty) return const [];

    return riesgos.take(2).map((item) {
      final slug = _slugEstrategiaCorrectiva(item.estrategia);
      return AlertaGestion(
        clave: _claveAlerta(
          contexto,
          _tipoAlertaEstrategiaCorrectiva(productividad.periodo, slug),
        ),
        titulo: 'Estrategia correctiva en riesgo',
        descripcion:
            '${item.estrategia} acumula ${item.reabiertasPeriodo} reaperturas, ${item.vencidasActivas} planes vencidos y ${item.activas} casos activos en ${productividad.periodo.etiqueta}.',
        severidad: _puntajeRiesgoEstrategia(item) >= 5 ? 'Alta' : 'Media',
        icono: Icons.rule_folder_outlined,
        accionSugerida: _accionCorrectivaEstrategia(item),
      );
    }).toList(growable: false);
  }

  List<AlertaGestion> _construirAlertasEstrategiaCorrectivaEnDeterioro({
    required ContextoInstitucional contexto,
    required ProductividadGestion productividad,
  }) {
    final deterioros = productividad.resumenEstrategiasCorrectivas.tendencias
        .where((item) => item.estado == 'Alerta')
        .toList(growable: false);
    if (deterioros.isEmpty) return const [];

    return deterioros.take(2).map((item) {
      final slug = _slugEstrategiaCorrectiva(item.estrategia);
      return AlertaGestion(
        clave: _claveAlerta(
          contexto,
          _tipoAlertaEstrategiaCorrectivaDeterioro(
            productividad.periodo,
            slug,
          ),
        ),
        titulo: 'Estrategia correctiva en deterioro',
        descripcion: item.lectura,
        severidad:
            item.reabiertasActual > item.reabiertasAnterior ? 'Alta' : 'Media',
        icono: Icons.trending_down_outlined,
        accionSugerida: _accionCorrectivaEstrategiaDeterioro(item),
      );
    }).toList(growable: false);
  }

  List<AlertaGestion> _construirAlertasRecomendacionEstrategicaInestable({
    required ContextoInstitucional contexto,
    required ProductividadGestion productividad,
  }) {
    final recomendacion = productividad.resumenEstrategiasCorrectivas.recomendacion;
    if (!recomendacion.esInestable) return const [];

    return [
      AlertaGestion(
        clave: _claveAlerta(
          contexto,
          _tipoAlertaRecomendacionEstrategica(productividad.periodo),
        ),
        titulo: 'Recomendacion estrategica inestable',
        descripcion: recomendacion.lecturaEjecutiva,
        severidad: recomendacion.estado == 'Revisar' ? 'Alta' : 'Media',
        icono: Icons.insights_outlined,
        accionSugerida: recomendacion.accionSugerida,
      ),
    ];
  }

  SemaforoGestion _construirSemaforoProductividad(
    ProductividadGestion productividad,
  ) {
    var alertas = productividad.tendencias
        .where((item) => item.estado == 'Alerta')
        .length;
    var mejoras = productividad.tendencias
        .where((item) => item.estado == 'Mejora')
        .length;

    if (productividad.comparativaPlanesCorrectivos.estado == 'Atencion') {
      alertas++;
    } else if (productividad.comparativaPlanesCorrectivos.estado == 'Favorable') {
      mejoras++;
    }
    if (_hayBloqueoCorrectivoRecurrente(productividad.resumenRevisionesCorrectivas)) {
      alertas++;
    }
    if (
        _hayCronificacionPlanMejora(
          productividad.resumenCumplimientoPlanMejora,
        )) {
      alertas++;
    }
    if (productividad.resumenPostReplanificacion.estado == 'Atencion') {
      alertas++;
    } else if (productividad.resumenPostReplanificacion.estado == 'Favorable') {
      mejoras++;
    }
    if (_hayEstrategiaCorrectivaEnRiesgo(productividad.resumenEstrategiasCorrectivas)) {
      alertas++;
    }
    if (_hayEstrategiaCorrectivaEnDeterioro(productividad.resumenEstrategiasCorrectivas)) {
      alertas++;
    }
    if (productividad.resumenEstrategiasCorrectivas.recomendacion.esInestable) {
      alertas++;
    }

    if (alertas >= 2) {
      return SemaforoGestion(
        titulo: 'Productividad',
        valor: '$alertas alertas',
        descripcion:
            'Deterioro relevante en ${productividad.periodo.etiqueta}; conviene intervencion ejecutiva.',
        estado: 'Rojo',
        icono: Icons.monitor_heart_outlined,
      );
    }
    if (alertas == 1) {
      return SemaforoGestion(
        titulo: 'Productividad',
        valor: '1 alerta',
        descripcion:
            'Hay un desvio de productividad durante ${productividad.periodo.etiqueta}.',
        estado: 'Amarillo',
        icono: Icons.monitor_heart_outlined,
      );
    }
    if (mejoras > 0) {
      return SemaforoGestion(
        titulo: 'Productividad',
        valor: '$mejoras mejoras',
        descripcion:
            'Sin deterioro relevante; el periodo de ${productividad.periodo.etiqueta} muestra mejora operativa.',
        estado: 'Verde',
        icono: Icons.monitor_heart_outlined,
      );
    }
    return SemaforoGestion(
      titulo: 'Productividad',
      valor: 'Estable',
      descripcion:
          'Sin alertas de productividad en ${productividad.periodo.etiqueta}.',
      estado: 'Verde',
      icono: Icons.monitor_heart_outlined,
    );
  }

  String? _nullSiVacio(String? value) {
    final text = (value ?? '').trim();
    return text.isEmpty ? null : text;
  }

  Future<int> _contarInstitucionesActivas() async {
    final countExp = _db.tablaInstituciones.id.count();
    final row =
        await (_db.selectOnly(_db.tablaInstituciones)
              ..addColumns([countExp])
              ..where(_db.tablaInstituciones.activo.equals(true)))
            .getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<int> _contarCarrerasActivas() async {
    final countExp = _db.tablaCarreras.id.count();
    final row =
        await (_db.selectOnly(_db.tablaCarreras)
              ..addColumns([countExp])
              ..where(_db.tablaCarreras.activo.equals(true)))
            .getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<int> _contarCursosActivos() async {
    final countExp = _db.tablaCursos.id.count();
    final row =
        await (_db.selectOnly(_db.tablaCursos)
              ..addColumns([countExp])
              ..where(_db.tablaCursos.activo.equals(true)))
            .getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<int> _contarAlumnosActivos() async {
    final countExp = _db.tablaAlumnos.id.count();
    final row =
        await (_db.selectOnly(_db.tablaAlumnos)
              ..addColumns([countExp])
              ..where(_db.tablaAlumnos.activo.equals(true)))
            .getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<int> _legajosCriticos(ContextoInstitucional contexto) async {
    final countExp = _db.tablaLegajosDocumentales.id.count();
    final row =
        await (_db.selectOnly(_db.tablaLegajosDocumentales)
              ..addColumns([countExp])
              ..where(
                _db.tablaLegajosDocumentales.activo.equals(true) &
                    _db.tablaLegajosDocumentales.rolDestino.equals(
                      contexto.rol.name,
                    ) &
                    _db.tablaLegajosDocumentales.nivelDestino.equals(
                      contexto.nivel.name,
                    ) &
                    _db.tablaLegajosDocumentales.dependenciaDestino.equals(
                      contexto.dependencia.name,
                    ) &
                    (_db.tablaLegajosDocumentales.severidad.equals('Alta') |
                        _db.tablaLegajosDocumentales.estado.equals('Critico')),
              ))
            .getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<int> _alumnosSinDocumento() async {
    final countExp = _db.tablaAlumnos.id.count();
    final row =
        await (_db.selectOnly(_db.tablaAlumnos)
              ..addColumns([countExp])
              ..where(
                _db.tablaAlumnos.activo.equals(true) &
                    (_db.tablaAlumnos.documento.isNull() |
                        _db.tablaAlumnos.documento.equals('')),
              ))
            .getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<int> _cursosSinClaseReciente() async {
    final recientes = DateTime.now().subtract(const Duration(days: 14));
    final rows = await _db.customSelect(
      '''
      SELECT COUNT(*) AS total
      FROM tabla_cursos c
      WHERE c.activo = 1
        AND NOT EXISTS (
          SELECT 1
          FROM tabla_clases cl
          WHERE cl.curso_id = c.id
            AND cl.fecha >= ?
        )
      ''',
      variables: [Variable<DateTime>(recientes)],
    ).getSingle();
    return rows.read<int>('total');
  }

  Future<DetalleAlertaGestion> _detalleLegajosCriticos(
    ContextoInstitucional contexto,
  ) async {
    final rows =
        await (_db.select(_db.tablaLegajosDocumentales)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.rolDestino.equals(contexto.rol.name) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name) &
                    (t.severidad.equals('Alta') | t.estado.equals('Critico')),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.estado),
                (t) => OrderingTerm.desc(t.actualizadoEn),
              ]))
            .get();

    return DetalleAlertaGestion(
      titulo: 'Legajos criticos activos',
      descripcion:
          'Registros documentales con criticidad alta o estado critico para el perfil activo.',
      filas: rows
          .map(
            (row) => DetalleAlertaGestionFila(
              titulo: '${row.codigo} | ${row.titulo}',
              subtitulo: row.responsable,
              valor: row.estado,
            ),
          )
          .toList(growable: false),
    );
  }

  Future<DetalleAlertaGestion> _detalleCursosSinClase() async {
    final recientes = DateTime.now().subtract(const Duration(days: 14));
    final rows = await _db.customSelect(
      '''
      SELECT
        c.id AS id,
        COALESCE(NULLIF(TRIM(i.nombre), ''), 'Sin institucion') AS institucion,
        COALESCE(NULLIF(TRIM(ca.nombre), ''), 'Sin carrera') AS carrera,
        COALESCE(NULLIF(TRIM(m.nombre), ''), NULLIF(TRIM(c.materia), ''), 'Sin materia') AS materia,
        COALESCE(NULLIF(TRIM(c.division), ''), 'Sin division') AS division
      FROM tabla_cursos c
      LEFT JOIN tabla_instituciones i ON i.id = c.institucion_id
      LEFT JOIN tabla_carreras ca ON ca.id = c.carrera_id
      LEFT JOIN tabla_materias m ON m.id = c.materia_id
      WHERE c.activo = 1
        AND NOT EXISTS (
          SELECT 1
          FROM tabla_clases cl
          WHERE cl.curso_id = c.id
            AND cl.fecha >= ?
        )
      ORDER BY institucion ASC, carrera ASC, materia ASC
      ''',
      variables: [Variable<DateTime>(recientes)],
    ).get();

    return DetalleAlertaGestion(
      titulo: 'Cursos sin clase reciente',
      descripcion:
          'Cursos activos sin actividad registrada en los ultimos 14 dias.',
      filas: rows
          .map(
            (row) => DetalleAlertaGestionFila(
              titulo: row.read<String>('materia'),
              subtitulo:
                  '${row.read<String>('institucion')} | ${row.read<String>('carrera')}',
              valor: row.read<String>('division'),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<DetalleAlertaGestion> _detalleAlumnosSinDocumento() async {
    final rows =
        await (_db.select(_db.tablaAlumnos).join([
              leftOuterJoin(
                _db.tablaInstituciones,
                _db.tablaInstituciones.id.equalsExp(_db.tablaAlumnos.institucionId),
              ),
              leftOuterJoin(
                _db.tablaCarreras,
                _db.tablaCarreras.id.equalsExp(_db.tablaAlumnos.carreraId),
              ),
            ])
              ..where(
                _db.tablaAlumnos.activo.equals(true) &
                    (_db.tablaAlumnos.documento.isNull() |
                        _db.tablaAlumnos.documento.equals('')),
              ))
            .get();

    return DetalleAlertaGestion(
      titulo: 'Alumnos sin documento cargado',
      descripcion:
          'Legajos estudiantiles incompletos que requieren normalizacion documental.',
      filas: rows
          .map((row) {
            final alumno = row.readTable(_db.tablaAlumnos);
            final institucion = row.readTableOrNull(_db.tablaInstituciones);
            final carrera = row.readTableOrNull(_db.tablaCarreras);
            return DetalleAlertaGestionFila(
              titulo: '${alumno.apellido}, ${alumno.nombre}',
              subtitulo:
                  '${institucion?.nombre ?? 'Sin institucion'} | ${carrera?.nombre ?? 'Sin carrera'}',
              valor: 'Sin DNI',
            );
          })
          .toList(growable: false),
    );
  }

  Future<DetalleAlertaGestion> _detalleAsistenciaEnRiesgo() async {
    final desde30 = DateTime.now().subtract(const Duration(days: 30));
    final rows = await _db.customSelect(
      '''
      SELECT
        c.id AS curso_id,
        COALESCE(NULLIF(TRIM(i.nombre), ''), 'Sin institucion') AS institucion,
        COALESCE(NULLIF(TRIM(ca.nombre), ''), 'Sin carrera') AS carrera,
        COALESCE(NULLIF(TRIM(m.nombre), ''), NULLIF(TRIM(c.materia), ''), 'Sin materia') AS materia,
        SUM(CASE WHEN lower(trim(a.estado)) IN ('presente', 'tarde', 'justificada') THEN 1 ELSE 0 END) AS computables,
        COUNT(a.id) AS total
      FROM tabla_cursos c
      LEFT JOIN tabla_instituciones i ON i.id = c.institucion_id
      LEFT JOIN tabla_carreras ca ON ca.id = c.carrera_id
      LEFT JOIN tabla_materias m ON m.id = c.materia_id
      LEFT JOIN tabla_clases cl ON cl.curso_id = c.id AND cl.fecha >= ?
      LEFT JOIN tabla_asistencias a ON a.clase_id = cl.id
      WHERE c.activo = 1
      GROUP BY c.id, institucion, carrera, materia
      HAVING total > 0 AND (CAST(computables AS REAL) / total) * 100 < 75
      ORDER BY ((CAST(computables AS REAL) / total) * 100) ASC
      ''',
      variables: [Variable<DateTime>(desde30)],
    ).get();

    return DetalleAlertaGestion(
      titulo: 'Asistencia institucional en riesgo',
      descripcion:
          'Cursos con porcentaje de asistencia computable inferior al 75% en los ultimos 30 dias.',
      filas: rows.map((row) {
        final total = row.read<int>('total');
        final computables = row.read<int>('computables');
        final porcentaje = total == 0 ? 0 : (computables / total) * 100;
        return DetalleAlertaGestionFila(
          titulo: row.read<String>('materia'),
          subtitulo:
              '${row.read<String>('institucion')} | ${row.read<String>('carrera')}',
          valor: '${porcentaje.toStringAsFixed(1)}%',
        );
      }).toList(growable: false),
    );
  }

  Future<DetalleAlertaGestion> _detalleSinEstructura() async {
    final instituciones = await _contarInstitucionesActivas();
    final carreras = await _contarCarrerasActivas();
    final cursos = await _contarCursosActivos();

    return DetalleAlertaGestion(
      titulo: 'Estructura institucional incompleta',
      descripcion:
          'El tablero directivo necesita estructura base para ampliar la lectura operativa.',
      filas: [
        DetalleAlertaGestionFila(
          titulo: 'Instituciones',
          subtitulo: 'Sedes o unidades registradas',
          valor: '$instituciones',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Carreras',
          subtitulo: 'Oferta academica configurada',
          valor: '$carreras',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Cursos',
          subtitulo: 'Cursos o comisiones activas',
          valor: '$cursos',
        ),
      ],
    );
  }

  Future<DetalleAlertaGestion> _detalleSeguimientosVencidos(
    ContextoInstitucional contexto,
  ) async {
    final items = await _listarSeguimientos(contexto);
    final filtrados = items
        .where((item) => item.estado != 'resuelta' && item.estaVencido)
        .toList(growable: false);

    return DetalleAlertaGestion(
      titulo: 'Seguimientos vencidos',
      descripcion:
          'Casos que superaron la ventana operativa esperada y requieren intervencion ejecutiva.',
      filas: filtrados
          .map(
            (item) => DetalleAlertaGestionFila(
              titulo: item.titulo,
              subtitulo: item.responsable,
              valor: 'Vencida',
            ),
          )
          .toList(growable: false),
    );
  }

  Future<DetalleAlertaGestion> _detalleSeguimientosReabiertos(
    ContextoInstitucional contexto,
  ) async {
    final items = await _listarSeguimientos(contexto);
    final filtrados = items
        .where((item) => item.estado == 'reabierta')
        .toList(growable: false);

    return DetalleAlertaGestion(
      titulo: 'Seguimientos reabiertos',
      descripcion:
          'Casos que necesitaron reabrirse y conviene revisar con direccion o rectorado.',
      filas: filtrados
          .map(
            (item) => DetalleAlertaGestionFila(
              titulo: item.titulo,
              subtitulo: item.responsable,
              valor: item.urgencia,
            ),
          )
          .toList(growable: false),
    );
  }

  Future<List<SeguimientoGestion>> _listarSeguimientos(
    ContextoInstitucional contexto,
  ) async {
    final prefijo = [
      contexto.rol.name,
      contexto.nivel.name,
      contexto.dependencia.name,
    ].join(':');

    final rows = await _db.customSelect(
      '''
      SELECT
        clave,
        estado,
        COALESCE(derivada_a, '') AS derivada_a,
        COALESCE(comentario, '') AS comentario,
        actualizado_en
      FROM tabla_alertas_gestion_estado
      WHERE clave LIKE ?
        AND estado IN ('derivada', 'resuelta', 'reabierta')
      ORDER BY actualizado_en DESC
      ''',
      variables: [Variable<String>('$prefijo:%')],
    ).get();

    final items = rows.map((row) {
      final clave = row.read<String>('clave');
      final tipo = clave.split(':').last;
      final actualizadoEn = row.read<DateTime>('actualizado_en');
      final estado = row.read<String>('estado');
      final venceEn = _calcularVencimientoSeguimiento(
        tipo: tipo,
        estado: estado,
        actualizadoEn: actualizadoEn,
      );
      return SeguimientoGestion(
        clave: clave,
        titulo: _tituloAlertaDesdeTipo(tipo),
        responsable: row.read<String>('derivada_a'),
        estado: estado,
        comentario: row.read<String>('comentario'),
        estrategiaCorrectiva: _estrategiaCorrectivaPlan(
          row.read<String>('comentario'),
        ),
        decisionEstrategica: _decisionEstrategicaPlan(
          row.read<String>('comentario'),
        ),
        actualizadoEn: actualizadoEn,
        venceEn: venceEn,
        urgencia: _urgenciaSeguimiento(
          estado: estado,
          venceEn: venceEn,
        ),
        impactoProductividad: _impactoProductividadPorTipo(tipo),
        esPlanCorrectivo: _esComentarioPlanCorrectivo(
          row.read<String>('comentario'),
        ),
        tienePlanMejoraCorrectiva: _esComentarioPlanMejoraCorrectiva(
          row.read<String>('comentario'),
        ),
        fechaObjetivoPlan: _fechaObjetivoPlanMejora(
          row.read<String>('comentario'),
        ),
      );
    }).toList(growable: false);

    items.sort((a, b) {
      final porPlanVencido =
          (b.planMejoraVencido ? 1 : 0) - (a.planMejoraVencido ? 1 : 0);
      if (porPlanVencido != 0) return porPlanVencido;

      final porEstado = _pesoEstadoSeguimiento(
        a.estado,
      ).compareTo(_pesoEstadoSeguimiento(b.estado));
      if (porEstado != 0) return porEstado;

      final porImpacto = _pesoImpactoProductividad(
        a.impactoProductividad,
      ).compareTo(_pesoImpactoProductividad(b.impactoProductividad));
      if (porImpacto != 0) return porImpacto;

      final porUrgencia = _pesoUrgenciaSeguimiento(
        a.urgencia,
      ).compareTo(_pesoUrgenciaSeguimiento(b.urgencia));
      if (porUrgencia != 0) return porUrgencia;

      final porVencimiento = a.venceEn.compareTo(b.venceEn);
      if (porVencimiento != 0) return porVencimiento;

      return b.actualizadoEn.compareTo(a.actualizadoEn);
    });

    return items;
  }

  DateTime _calcularVencimientoSeguimiento({
    required String tipo,
    required String estado,
    required DateTime actualizadoEn,
  }) {
    if (estado == 'resuelta') {
      return actualizadoEn.add(const Duration(days: 30));
    }

    return actualizadoEn.add(
      switch (tipo) {
        'legajos_criticos' => const Duration(hours: 24),
        'cursos_sin_clase' => const Duration(hours: 48),
        'asistencia_en_riesgo' => const Duration(hours: 72),
        'alumnos_sin_documento' => const Duration(days: 5),
        'sin_estructura' => const Duration(days: 7),
        _ => const Duration(days: 3),
      },
    );
  }

  String _urgenciaSeguimiento({
    required String estado,
    required DateTime venceEn,
  }) {
    if (estado == 'resuelta') return 'Resuelta';
    if (venceEn.isBefore(DateTime.now())) return 'Vencida';

    final restante = venceEn.difference(DateTime.now());
    if (restante <= const Duration(hours: 12)) return 'Alta';
    if (restante <= const Duration(days: 2)) return 'Media';
    return 'Planificada';
  }

  int _pesoEstadoSeguimiento(String estado) {
    switch (estado) {
      case 'reabierta':
        return 0;
      case 'derivada':
        return 1;
      case 'resuelta':
        return 3;
      default:
        return 2;
    }
  }

  int _pesoUrgenciaSeguimiento(String urgencia) {
    switch (urgencia) {
      case 'Vencida':
        return 0;
      case 'Alta':
        return 1;
      case 'Media':
        return 2;
      case 'Planificada':
        return 3;
      case 'Resuelta':
        return 4;
      default:
        return 5;
    }
  }

  int _pesoImpactoProductividad(String impacto) {
    switch (impacto) {
      case 'Critico':
        return 0;
      case 'Alto':
        return 1;
      case 'Medio':
        return 2;
      case 'Bajo':
        return 3;
      default:
        return 4;
    }
  }

  Future<ProductividadGestion> _construirProductividad({
    required ContextoInstitucional contexto,
    required PeriodoProductividadGestion periodo,
    required List<SeguimientoGestion> seguimientos,
  }) async {
    final prefijo = [
      contexto.rol.name,
      contexto.nivel.name,
      contexto.dependencia.name,
    ].join(':');
    final ahora = DateTime.now();
    final desdeActual = ahora.subtract(Duration(days: periodo.dias));
    final desdeAnterior = ahora.subtract(Duration(days: periodo.dias * 2));

    final rows = await _db.customSelect(
      '''
      SELECT
        clave,
        accion,
        COALESCE(derivada_a, '') AS derivada_a,
        COALESCE(comentario, '') AS comentario,
        creado_en
      FROM tabla_alertas_gestion_historial
      WHERE clave LIKE ?
        AND creado_en >= ?
      ORDER BY clave ASC, creado_en ASC, id ASC
      ''',
      variables: [
        Variable<String>('$prefijo:%'),
        Variable<DateTime>(desdeAnterior),
      ],
    ).get();

    final actual = _ProductividadAcumulada();
    final anterior = _ProductividadAcumulada();

    final activosPorResponsable = <String, int>{};
    for (final item in seguimientos) {
      final responsable = item.responsable.trim();
      if (responsable.isEmpty || item.estado == 'resuelta') continue;
      activosPorResponsable[responsable] =
          (activosPorResponsable[responsable] ?? 0) + 1;
    }

    final resueltosPorResponsable = <String, int>{};
    final reabiertosPorResponsable = <String, int>{};
    final ultimaAperturaPorClave = <String, DateTime>{};
    final planCorrectivoPorClave = <String, bool>{};

    final planesCorrectivosActivos = seguimientos
        .where((item) => item.esPlanCorrectivo && item.estado != 'resuelta')
        .length;

    for (final row in rows) {
      final clave = row.read<String>('clave');
      final accion = row.read<String>('accion');
      final derivadaA = row.read<String>('derivada_a').trim();
      final comentario = row.read<String>('comentario');
      final creadoEn = row.read<DateTime>('creado_en');
      final bucket = creadoEn.isBefore(desdeActual) ? anterior : actual;

      if (_esComentarioPlanCorrectivo(comentario)) {
        planCorrectivoPorClave[clave] = true;
      }

      if (accion == 'derivada' ||
          accion == 'reabierta' ||
          accion == 'reasignada') {
        ultimaAperturaPorClave[clave] = creadoEn;
      }

      if (accion == 'reabierta') {
        bucket.reaberturas++;
        if (planCorrectivoPorClave[clave] ?? false) {
          bucket.planesCorrectivosReabiertos++;
        }
        if (derivadaA.isNotEmpty) {
          reabiertosPorResponsable[derivadaA] =
              (reabiertosPorResponsable[derivadaA] ?? 0) + 1;
        }
      }

      if (accion == 'resuelta' || accion == 'cierre_ejecutivo') {
        bucket.resoluciones++;
        if (planCorrectivoPorClave[clave] ?? false) {
          bucket.planesCorrectivosResueltos++;
        }
        if (accion == 'cierre_ejecutivo') {
          bucket.cierresEjecutivos++;
        }
        if (derivadaA.isNotEmpty) {
          resueltosPorResponsable[derivadaA] =
              (resueltosPorResponsable[derivadaA] ?? 0) + 1;
        }
        final inicio = ultimaAperturaPorClave[clave];
        if (inicio != null && !creadoEn.isBefore(inicio)) {
          bucket.sumaHorasResolucion +=
              creadoEn.difference(inicio).inMinutes / 60.0;
          bucket.totalResolucionesConTiempo++;
        }
      }
    }

    final responsables = <ProductividadResponsable>[];
    final nombres = {
      ...activosPorResponsable.keys,
      ...resueltosPorResponsable.keys,
      ...reabiertosPorResponsable.keys,
    }.toList()
      ..sort();

    for (final nombre in nombres) {
      responsables.add(
        ProductividadResponsable(
          responsable: nombre,
          activos: activosPorResponsable[nombre] ?? 0,
          resueltosPeriodo: resueltosPorResponsable[nombre] ?? 0,
          reabiertosPeriodo: reabiertosPorResponsable[nombre] ?? 0,
        ),
      );
    }

    responsables.sort((a, b) {
      final porActivos = b.activos.compareTo(a.activos);
      if (porActivos != 0) return porActivos;

      final porResueltos = b.resueltosPeriodo.compareTo(a.resueltosPeriodo);
      if (porResueltos != 0) return porResueltos;

      return a.reabiertosPeriodo.compareTo(b.reabiertosPeriodo);
    });

    final cierresPatrones = _agruparPatronesCierreEjecutivo(
      rows,
      desdeActual: desdeActual,
    );
    final comparativaPlanesCorrectivos = _construirComparativaPlanesCorrectivos(
      rows,
      desdeActual: desdeActual,
    );
    final resumenRevisionesCorrectivas = await _construirResumenRevisionesCorrectivas(
      contexto: contexto,
      rows: rows,
      desdeActual: desdeActual,
    );
    final resumenCumplimientoPlanMejora = _construirResumenCumplimientoPlanMejora(
      rows: rows,
      seguimientos: seguimientos,
      desdeActual: desdeActual,
    );
    final resumenPostReplanificacion = _construirResumenPostReplanificacion(
      rows: rows,
      seguimientos: seguimientos,
      desdeActual: desdeActual,
    );
    final comparativaRiesgoReplanificacion =
        _construirComparativaRiesgoReplanificacion(
          resumenCumplimiento: resumenCumplimientoPlanMejora,
          resumenPost: resumenPostReplanificacion,
        );
    final resumenEstrategiasCorrectivas = _construirResumenEstrategiasCorrectivas(
      rows: rows,
      seguimientos: seguimientos,
      desdeActual: desdeActual,
      desdeAnterior: desdeAnterior,
    );
    final resumenDecisionesEstrategicas = _construirResumenDecisionesEstrategicas(
      rows: rows,
      seguimientos: seguimientos,
      desdeActual: desdeActual,
    );

    return ProductividadGestion(
      periodo: periodo,
      cierresEjecutivos: actual.cierresEjecutivos,
      resoluciones: actual.resoluciones,
      reaberturas: actual.reaberturas,
      planesCorrectivosActivos: planesCorrectivosActivos,
      planesCorrectivosResueltos: actual.planesCorrectivosResueltos,
      planesCorrectivosReabiertos: actual.planesCorrectivosReabiertos,
      promedioHorasResolucion: actual.totalResolucionesConTiempo == 0
          ? 0
          : actual.sumaHorasResolucion / actual.totalResolucionesConTiempo,
      comparativaPlanesCorrectivos: comparativaPlanesCorrectivos,
      resumenRevisionesCorrectivas: resumenRevisionesCorrectivas,
      resumenCumplimientoPlanMejora: resumenCumplimientoPlanMejora,
      resumenPostReplanificacion: resumenPostReplanificacion,
      comparativaRiesgoReplanificacion: comparativaRiesgoReplanificacion,
      resumenEstrategiasCorrectivas: resumenEstrategiasCorrectivas,
      resumenDecisionesEstrategicas: resumenDecisionesEstrategicas,
      tendencias: [
        _armarTendenciaEntera(
          clave: 'cierres_ejecutivos',
          titulo: 'Cierres ejecutivos',
          actual: actual.cierresEjecutivos,
          anterior: anterior.cierresEjecutivos,
          descripcion: 'Comparado con los ${periodo.comparacionEtiqueta}.',
          mejorCuandoSube: true,
        ),
        _armarTendenciaEntera(
          clave: 'resoluciones',
          titulo: 'Resoluciones',
          actual: actual.resoluciones,
          anterior: anterior.resoluciones,
          descripcion:
              'Capacidad de cierre del circuito institucional en ${periodo.etiqueta}.',
          mejorCuandoSube: true,
        ),
        _armarTendenciaEntera(
          clave: 'reaperturas',
          titulo: 'Reaperturas',
          actual: actual.reaberturas,
          anterior: anterior.reaberturas,
          descripcion:
              'Menos reaperturas en ${periodo.etiqueta} indica mayor consistencia de cierre.',
          mejorCuandoSube: false,
        ),
        _armarTendenciaDecimal(
          clave: 'tiempo_resolucion',
          titulo: 'Tiempo medio de resolucion',
          actual: actual.promedioHorasResolucion,
          anterior: anterior.promedioHorasResolucion,
          descripcion:
              'Horas promedio entre apertura operativa y resolucion en ${periodo.etiqueta}.',
          mejorCuandoSube: false,
          sufijo: ' h',
        ),
      ],
      responsables: responsables.take(6).toList(growable: false),
      cierresPatrones: cierresPatrones.take(6).toList(growable: false),
    );
  }

  ResumenEstrategiasCorrectivas _construirResumenEstrategiasCorrectivas({
    required List<QueryRow> rows,
    required List<SeguimientoGestion> seguimientos,
    required DateTime desdeActual,
    required DateTime desdeAnterior,
  }) {
    final estrategiaPorClave = <String, String>{};
    final resueltasPorEstrategia = <String, int>{};
    final reabiertasPorEstrategia = <String, int>{};
    final resueltasPreviasPorEstrategia = <String, int>{};
    final reabiertasPreviasPorEstrategia = <String, int>{};

    for (final row in rows) {
      final clave = row.read<String>('clave');
      final comentario = row.read<String>('comentario');
      final estrategia = _estrategiaCorrectivaPlan(comentario);
      if (estrategia != null) {
        estrategiaPorClave[clave] = estrategia;
      }
    }

    for (final row in rows) {
      final creadoEn = row.read<DateTime>('creado_en');
      final clave = row.read<String>('clave');
      final estrategia = estrategiaPorClave[clave];
      if (estrategia == null) continue;
      final accion = row.read<String>('accion');
      final esActual = !creadoEn.isBefore(desdeActual);
      final esAnteriorComparable =
          creadoEn.isBefore(desdeActual) && !creadoEn.isBefore(desdeAnterior);
      if (!esActual && !esAnteriorComparable) continue;
      if (accion == 'resuelta' || accion == 'cierre_ejecutivo') {
        final target = esActual
            ? resueltasPorEstrategia
            : resueltasPreviasPorEstrategia;
        target[estrategia] = (target[estrategia] ?? 0) + 1;
      } else if (accion == 'reabierta') {
        final target = esActual
            ? reabiertasPorEstrategia
            : reabiertasPreviasPorEstrategia;
        target[estrategia] = (target[estrategia] ?? 0) + 1;
      }
    }

    final activasPorEstrategia = <String, int>{};
    final vencidasPorEstrategia = <String, int>{};
    for (final item in seguimientos) {
      final estrategia = item.estrategiaCorrectiva;
      if (estrategia == null) continue;
      if (item.estado != 'resuelta') {
        activasPorEstrategia[estrategia] =
            (activasPorEstrategia[estrategia] ?? 0) + 1;
      }
      if (item.planMejoraVencido) {
        vencidasPorEstrategia[estrategia] =
            (vencidasPorEstrategia[estrategia] ?? 0) + 1;
      }
    }

    final estrategias = {
      ...estrategiaPorClave.values,
      ...activasPorEstrategia.keys,
      ...resueltasPorEstrategia.keys,
      ...reabiertasPorEstrategia.keys,
      ...resueltasPreviasPorEstrategia.keys,
      ...reabiertasPreviasPorEstrategia.keys,
      ...vencidasPorEstrategia.keys,
    }.toList()
      ..sort();

    final items = estrategias
        .map(
          (estrategia) => EstrategiaCorrectivaItem(
            estrategia: estrategia,
            activas: activasPorEstrategia[estrategia] ?? 0,
            resueltasPeriodo: resueltasPorEstrategia[estrategia] ?? 0,
            reabiertasPeriodo: reabiertasPorEstrategia[estrategia] ?? 0,
            vencidasActivas: vencidasPorEstrategia[estrategia] ?? 0,
          ),
        )
        .where(
          (item) =>
              item.activas > 0 ||
              item.resueltasPeriodo > 0 ||
              item.reabiertasPeriodo > 0 ||
              item.vencidasActivas > 0,
        )
        .toList(growable: false)
      ..sort((a, b) {
        final riesgoA = (a.reabiertasPeriodo * 2) + a.vencidasActivas + a.activas;
        final riesgoB = (b.reabiertasPeriodo * 2) + b.vencidasActivas + b.activas;
        final porRiesgo = riesgoB.compareTo(riesgoA);
        if (porRiesgo != 0) return porRiesgo;
        final porResueltas = b.resueltasPeriodo.compareTo(a.resueltasPeriodo);
        if (porResueltas != 0) return porResueltas;
        return a.estrategia.compareTo(b.estrategia);
      });

    final tendencias = estrategias
        .map(
          (estrategia) => _construirTendenciaEstrategia(
            estrategia: estrategia,
            resueltasActual: resueltasPorEstrategia[estrategia] ?? 0,
            resueltasAnterior: resueltasPreviasPorEstrategia[estrategia] ?? 0,
            reabiertasActual: reabiertasPorEstrategia[estrategia] ?? 0,
            reabiertasAnterior: reabiertasPreviasPorEstrategia[estrategia] ?? 0,
          ),
        )
        .where(
          (item) =>
              item.resueltasActual > 0 ||
              item.resueltasAnterior > 0 ||
              item.reabiertasActual > 0 ||
              item.reabiertasAnterior > 0,
        )
        .toList(growable: false)
      ..sort((a, b) {
        final pesoA = _pesoEstadoTendenciaEstrategia(a.estado);
        final pesoB = _pesoEstadoTendenciaEstrategia(b.estado);
        final porEstado = pesoA.compareTo(pesoB);
        if (porEstado != 0) return porEstado;
        return a.estrategia.compareTo(b.estrategia);
      });

    final recomendacion = _construirRecomendacionEstrategiaCorrectiva(
      items,
      tendencias,
      resueltasPreviasPorEstrategia,
      reabiertasPreviasPorEstrategia,
    );

    return ResumenEstrategiasCorrectivas(
      lecturaEjecutiva: _lecturaResumenEstrategiasCorrectivas(
        items,
        tendencias,
      ),
      recomendacion: recomendacion,
      estrategias: items.take(4).toList(growable: false),
      tendencias: tendencias.take(4).toList(growable: false),
    );
  }

  ResumenDecisionesEstrategicas _construirResumenDecisionesEstrategicas({
    required List<QueryRow> rows,
    required List<SeguimientoGestion> seguimientos,
    required DateTime desdeActual,
  }) {
    final decisionPorClave = <String, String>{};
    for (final row in rows) {
      final decision = _decisionEstrategicaPlan(row.read<String>('comentario'));
      if (decision != null) {
        decisionPorClave[row.read<String>('clave')] = decision;
      }
    }

    final activas = <String, int>{};
    final resueltas = <String, int>{};
    final reabiertas = <String, int>{};

    for (final item in seguimientos) {
      final decision = item.decisionEstrategica;
      if (decision == null) continue;
      if (item.estado != 'resuelta') {
        activas[decision] = (activas[decision] ?? 0) + 1;
      }
    }

    for (final row in rows) {
      final creadoEn = row.read<DateTime>('creado_en');
      if (creadoEn.isBefore(desdeActual)) continue;
      final decision = decisionPorClave[row.read<String>('clave')];
      if (decision == null) continue;
      final accion = row.read<String>('accion');
      if (accion == 'resuelta' || accion == 'cierre_ejecutivo') {
        resueltas[decision] = (resueltas[decision] ?? 0) + 1;
      } else if (accion == 'reabierta') {
        reabiertas[decision] = (reabiertas[decision] ?? 0) + 1;
      }
    }

    final decisiones = {
      ...decisionPorClave.values,
      ...activas.keys,
      ...resueltas.keys,
      ...reabiertas.keys,
    }.toList()
      ..sort();

    final items = decisiones
        .map(
          (decision) => DecisionEstrategicaItem(
            decision: decision,
            activas: activas[decision] ?? 0,
            resueltasPeriodo: resueltas[decision] ?? 0,
            reabiertasPeriodo: reabiertas[decision] ?? 0,
          ),
        )
        .where(
          (item) =>
              item.activas > 0 ||
              item.resueltasPeriodo > 0 ||
              item.reabiertasPeriodo > 0,
        )
        .toList(growable: false)
      ..sort((a, b) {
        final scoreA =
            (a.resueltasPeriodo * 2) - (a.reabiertasPeriodo * 2) - a.activas;
        final scoreB =
            (b.resueltasPeriodo * 2) - (b.reabiertasPeriodo * 2) - b.activas;
        final porScore = scoreB.compareTo(scoreA);
        if (porScore != 0) return porScore;
        return a.decision.compareTo(b.decision);
      });

    return ResumenDecisionesEstrategicas(
      lecturaEjecutiva: _lecturaResumenDecisionesEstrategicas(items),
      decisiones: items.take(4).toList(growable: false),
    );
  }

  String _lecturaResumenDecisionesEstrategicas(
    List<DecisionEstrategicaItem> decisiones,
  ) {
    if (decisiones.isEmpty) {
      return 'Todavia no hay decisiones estrategicas formalizadas en el periodo activo.';
    }

    final principal = decisiones.first;
    final balanceResuelto =
        principal.resueltasPeriodo - principal.reabiertasPeriodo;
    final cierre = switch (balanceResuelto) {
      > 0 =>
        'Muestra una senal favorable de ejecucion frente a sus reaperturas.',
      < 0 =>
        'Arrastra mas reaperturas que resoluciones y conviene auditar su implementacion.',
      _ =>
        'Mantiene un balance neutro entre resoluciones y reaperturas.',
    };

    return 'La decision dominante es "${principal.decision.toLowerCase()}" con ${principal.activas} activas y ${principal.resueltasPeriodo} resoluciones en el periodo. $cierre';
  }

  ComparativaRiesgoReplanificacion _construirComparativaRiesgoReplanificacion({
    required ResumenCumplimientoPlanMejora resumenCumplimiento,
    required ResumenPostReplanificacion resumenPost,
  }) {
    final presionCronificacion =
        resumenCumplimiento.planesCronificados * 2 +
        resumenCumplimiento.planesVencidosActivos +
        (resumenCumplimiento.replanificacionesRegistradas -
                resumenCumplimiento.planesReplanificados)
            .clamp(0, 9999);
    final riesgoPostAjuste =
        resumenPost.reabiertos * 2 +
        resumenPost.vencidosActivos +
        (resumenPost.enSeguimiento > resumenPost.estabilizados ? 1 : 0);

    final diferencia = presionCronificacion - riesgoPostAjuste;
    final foco = switch ((presionCronificacion, riesgoPostAjuste)) {
      (0, 0) => 'Estable',
      _ when diferencia >= 2 => 'Reprogramacion excesiva',
      _ when diferencia <= -2 => 'Reprogramacion inefectiva',
      _ => 'Riesgo mixto',
    };

    final lecturaEjecutiva = switch (foco) {
      'Estable' =>
        'No aparece una brecha fuerte entre cronificacion y resultado posterior; la replanificacion se mantiene bajo control en el periodo.',
      'Reprogramacion excesiva' =>
        'El principal problema esta antes del ajuste: se reprograma demasiado o se acumulan planes cronificados, asi que conviene intervenir capacidad, alcance y fechas objetivo.',
      'Reprogramacion inefectiva' =>
        'El mayor desvio aparece despues del ajuste: aunque se reprograma, los planes vuelven a reabrirse o seguir vencidos, por lo que conviene revisar la calidad del rediseño y del control posterior.',
      _ =>
        'La presion por cronificacion y el riesgo posterior al ajuste aparecen equilibrados; conviene intervenir ambas capas en paralelo con supervision ejecutiva corta.',
    };

    final accionSugerida = switch (foco) {
      'Estable' =>
        'Sostener monitoreo, priorizar planes con vencimiento cercano y evitar sumar reprogramaciones innecesarias.',
      'Reprogramacion excesiva' =>
        'Reducir replanificaciones, redefinir compromisos sobredimensionados y concentrar supervision sobre planes ya cronificados.',
      'Reprogramacion inefectiva' =>
        'Auditar las ultimas replanificaciones, revisar responsables/hitos y cortar rapido los planes que no muestran mejora real despues del ajuste.',
      _ =>
        'Separar una mesa de saneamiento para planes cronificados y otra de auditoria para planes reprogramados que siguen en riesgo.',
    };

    return ComparativaRiesgoReplanificacion(
      presionCronificacion: presionCronificacion,
      riesgoPostAjuste: riesgoPostAjuste,
      foco: foco,
      lecturaEjecutiva: lecturaEjecutiva,
      accionSugerida: accionSugerida,
    );
  }

  ResumenCumplimientoPlanMejora _construirResumenCumplimientoPlanMejora({
    required List<QueryRow> rows,
    required List<SeguimientoGestion> seguimientos,
    required DateTime desdeActual,
  }) {
    final replanificacionesPorResponsable = <String, int>{};
    final replanificacionesPorClave = <String, int>{};
    final tituloSeguimientoPorClave = {
      for (final item in seguimientos) item.clave: item.titulo,
    };

    var replanificacionesRegistradas = 0;

    for (final row in rows) {
      final creadoEn = row.read<DateTime>('creado_en');
      if (creadoEn.isBefore(desdeActual)) continue;
      if (row.read<String>('accion') != 'replanificacion_mejora') continue;

      replanificacionesRegistradas++;
      final clave = row.read<String>('clave');
      replanificacionesPorClave[clave] = (replanificacionesPorClave[clave] ?? 0) + 1;

      final responsable = _responsableHistorico(row.read<String>('derivada_a'));
      replanificacionesPorResponsable[responsable] =
          (replanificacionesPorResponsable[responsable] ?? 0) + 1;
    }

    final planesVencidosActivos = seguimientos
        .where(
          (item) =>
              item.tienePlanMejoraCorrectiva &&
              item.estado != 'resuelta' &&
              item.planMejoraVencido,
        )
        .length;
    final planesReplanificados = replanificacionesPorClave.length;
    final cronificados = replanificacionesPorClave.entries
        .where((entry) => entry.value >= 2)
        .toList()
      ..sort((a, b) {
        final porCantidad = b.value.compareTo(a.value);
        if (porCantidad != 0) return porCantidad;
        return a.key.compareTo(b.key);
      });

    final responsablesOrdenados = replanificacionesPorResponsable.entries.toList()
      ..sort((a, b) {
        final porCantidad = b.value.compareTo(a.value);
        if (porCantidad != 0) return porCantidad;
        return a.key.compareTo(b.key);
      });

    return ResumenCumplimientoPlanMejora(
      replanificacionesRegistradas: replanificacionesRegistradas,
      planesReplanificados: planesReplanificados,
      planesVencidosActivos: planesVencidosActivos,
      planesCronificados: cronificados.length,
      lecturaEjecutiva: _lecturaResumenCumplimientoPlanMejora(
        replanificacionesRegistradas: replanificacionesRegistradas,
        planesReplanificados: planesReplanificados,
        planesVencidosActivos: planesVencidosActivos,
        principalResponsable:
            responsablesOrdenados.isEmpty ? null : responsablesOrdenados.first,
        principalPlanCronificado:
            cronificados.isEmpty ? null : cronificados.first,
      ),
      responsablesReprogramados: responsablesOrdenados
          .take(4)
          .map(
            (entry) => PatronCumplimientoPlanMejora(
              etiqueta: entry.key,
              cantidad: entry.value,
              subtitulo: 'Replanificaciones registradas en el periodo activo',
            ),
          )
          .toList(growable: false),
      planesCronificadosDetalle: cronificados
          .take(4)
          .map(
            (entry) => PatronCumplimientoPlanMejora(
              etiqueta: tituloSeguimientoPorClave[entry.key] ??
                  _tituloAlertaDesdeTipo(_tipoHistorico(entry.key)),
              cantidad: entry.value,
              subtitulo: 'Reprogramaciones acumuladas sobre el mismo plan',
            ),
          )
          .toList(growable: false),
    );
  }

  ResumenPostReplanificacion _construirResumenPostReplanificacion({
    required List<QueryRow> rows,
    required List<SeguimientoGestion> seguimientos,
    required DateTime desdeActual,
  }) {
    final ultimaReplanificacionPorClave = <String, DateTime>{};
    final seguimientoPorClave = {
      for (final item in seguimientos) item.clave: item,
    };

    for (final row in rows) {
      final creadoEn = row.read<DateTime>('creado_en');
      if (creadoEn.isBefore(desdeActual)) continue;
      if (row.read<String>('accion') != 'replanificacion_mejora') continue;
      ultimaReplanificacionPorClave[row.read<String>('clave')] = creadoEn;
    }

    if (ultimaReplanificacionPorClave.isEmpty) {
      return const ResumenPostReplanificacion(
        planesObservados: 0,
        estabilizados: 0,
        reabiertos: 0,
        vencidosActivos: 0,
        enSeguimiento: 0,
        estado: 'Neutro',
        lecturaEjecutiva:
            'Todavia no hay replanificaciones en el periodo activo para medir su efecto posterior.',
        responsablesEnRiesgo: [],
      );
    }

    final reabiertosPost = <String>{};
    final resueltosPost = <String>{};

    for (final row in rows) {
      final clave = row.read<String>('clave');
      final ultimaReplanificacion = ultimaReplanificacionPorClave[clave];
      if (ultimaReplanificacion == null) continue;
      final creadoEn = row.read<DateTime>('creado_en');
      if (!creadoEn.isAfter(ultimaReplanificacion)) continue;
      final accion = row.read<String>('accion');
      if (accion == 'reabierta') {
        reabiertosPost.add(clave);
      } else if (accion == 'resuelta' || accion == 'cierre_ejecutivo') {
        resueltosPost.add(clave);
      }
    }

    final riesgoPorResponsable = <String, int>{};
    var estabilizados = 0;
    var reabiertos = 0;
    var vencidosActivos = 0;
    var enSeguimiento = 0;

    for (final entry in ultimaReplanificacionPorClave.entries) {
      final clave = entry.key;
      final seguimiento = seguimientoPorClave[clave];

      if (reabiertosPost.contains(clave)) {
        reabiertos++;
        final responsable = _responsableHistorico(
          seguimiento?.responsable ?? 'Sin asignar',
        );
        riesgoPorResponsable[responsable] =
            (riesgoPorResponsable[responsable] ?? 0) + 1;
        continue;
      }

      if (seguimiento != null &&
          seguimiento.estado != 'resuelta' &&
          seguimiento.planMejoraVencido) {
        vencidosActivos++;
        final responsable = _responsableHistorico(seguimiento.responsable);
        riesgoPorResponsable[responsable] =
            (riesgoPorResponsable[responsable] ?? 0) + 1;
        continue;
      }

      if ((seguimiento?.estado == 'resuelta') || resueltosPost.contains(clave)) {
        estabilizados++;
      } else {
        enSeguimiento++;
      }
    }

    final responsablesEnRiesgo = riesgoPorResponsable.entries.toList()
      ..sort((a, b) {
        final porCantidad = b.value.compareTo(a.value);
        if (porCantidad != 0) return porCantidad;
        return a.key.compareTo(b.key);
      });

    final estado = _estadoPostReplanificacion(
      planesObservados: ultimaReplanificacionPorClave.length,
      estabilizados: estabilizados,
      reabiertos: reabiertos,
      vencidosActivos: vencidosActivos,
    );

    return ResumenPostReplanificacion(
      planesObservados: ultimaReplanificacionPorClave.length,
      estabilizados: estabilizados,
      reabiertos: reabiertos,
      vencidosActivos: vencidosActivos,
      enSeguimiento: enSeguimiento,
      estado: estado,
      lecturaEjecutiva: _lecturaResumenPostReplanificacion(
        planesObservados: ultimaReplanificacionPorClave.length,
        estabilizados: estabilizados,
        reabiertos: reabiertos,
        vencidosActivos: vencidosActivos,
        enSeguimiento: enSeguimiento,
        principalResponsable:
            responsablesEnRiesgo.isEmpty ? null : responsablesEnRiesgo.first,
      ),
      responsablesEnRiesgo: responsablesEnRiesgo
          .take(4)
          .map(
            (entry) => PatronCumplimientoPlanMejora(
              etiqueta: entry.key,
              cantidad: entry.value,
              subtitulo:
                  'Planes replanificados que siguen en riesgo despues del ajuste',
            ),
          )
          .toList(growable: false),
    );
  }

  Future<ResumenRevisionCorrectiva> _construirResumenRevisionesCorrectivas({
    required ContextoInstitucional contexto,
    required List<QueryRow> rows,
    required DateTime desdeActual,
  }) async {
    final areasPorResponsable = await _areasPorResponsableContexto(contexto);
    final bloqueos = <String, int>{};
    final areas = <String, int>{};
    final planesAuditados = <String>{};
    var revisionesRegistradas = 0;

    for (final row in rows) {
      final creadoEn = row.read<DateTime>('creado_en');
      if (creadoEn.isBefore(desdeActual)) continue;
      if (row.read<String>('accion') != 'revision_correctiva') continue;

      revisionesRegistradas++;
      final clave = row.read<String>('clave');
      planesAuditados.add(clave);

      final comentario = row.read<String>('comentario');
      final bloqueo = _extraerCampoRevisionCorrectiva(
        comentario,
        etiqueta: 'Bloqueo:',
      );
      if (bloqueo.isNotEmpty) {
        bloqueos[bloqueo] = (bloqueos[bloqueo] ?? 0) + 1;
      }

      final responsable = row.read<String>('derivada_a').trim();
      final area = areasPorResponsable[responsable] ??
          (responsable.isEmpty ? 'Sin area asignada' : responsable);
      areas[area] = (areas[area] ?? 0) + 1;
    }

    final bloqueosFrecuentes = bloqueos.entries.toList()
      ..sort((a, b) {
        final porCantidad = b.value.compareTo(a.value);
        if (porCantidad != 0) return porCantidad;
        return a.key.compareTo(b.key);
      });
    final areasComprometidas = areas.entries.toList()
      ..sort((a, b) {
        final porCantidad = b.value.compareTo(a.value);
        if (porCantidad != 0) return porCantidad;
        return a.key.compareTo(b.key);
      });

    return ResumenRevisionCorrectiva(
      revisionesRegistradas: revisionesRegistradas,
      planesAuditados: planesAuditados.length,
      lecturaEjecutiva: _lecturaResumenRevisionCorrectiva(
        revisionesRegistradas: revisionesRegistradas,
        planesAuditados: planesAuditados.length,
        principalBloqueo: bloqueosFrecuentes.isEmpty ? null : bloqueosFrecuentes.first,
        principalArea: areasComprometidas.isEmpty ? null : areasComprometidas.first,
      ),
      bloqueosFrecuentes: bloqueosFrecuentes
          .take(4)
          .map(
            (entry) => PatronRevisionCorrectiva(
              etiqueta: entry.key,
              cantidad: entry.value,
              subtitulo: 'Bloqueo detectado en revisiones correctivas',
            ),
          )
          .toList(growable: false),
      areasComprometidas: areasComprometidas
          .take(4)
          .map(
            (entry) => PatronRevisionCorrectiva(
              etiqueta: entry.key,
              cantidad: entry.value,
              subtitulo: 'Area/responsable con revisiones correctivas registradas',
            ),
          )
          .toList(growable: false),
    );
  }

  Future<Map<String, String>> _areasPorResponsableContexto(
    ContextoInstitucional contexto,
  ) async {
    final rows = await (_db.select(_db.tablaResponsablesGestion)
          ..where(
            (t) =>
                t.rolDestino.equals(contexto.rol.name) &
                t.nivelDestino.equals(contexto.nivel.name) &
                t.dependenciaDestino.equals(contexto.dependencia.name),
          ))
        .get();

    return {
      for (final row in rows) row.nombre.trim(): row.area.trim(),
    };
  }

  String _extraerCampoRevisionCorrectiva(
    String comentario, {
    required String etiqueta,
  }) {
    final lineas = comentario.split('\n');
    for (final linea in lineas) {
      final texto = linea.trim();
      if (!texto.startsWith(etiqueta)) continue;
      return texto.substring(etiqueta.length).trim();
    }
    return '';
  }

  String _lecturaResumenRevisionCorrectiva({
    required int revisionesRegistradas,
    required int planesAuditados,
    required MapEntry<String, int>? principalBloqueo,
    required MapEntry<String, int>? principalArea,
  }) {
    if (revisionesRegistradas == 0) {
      return 'Todavia no hay revisiones correctivas registradas en el periodo activo.';
    }

    final partes = <String>[
      '$revisionesRegistradas revisiones correctivas sobre $planesAuditados planes auditados.',
    ];

    if (principalBloqueo != null) {
      partes.add(
        'El bloqueo mas repetido fue "${principalBloqueo.key.toLowerCase()}" (${principalBloqueo.value}).',
      );
    }

    if (principalArea != null) {
      partes.add(
        'La mayor concentracion aparece en ${principalArea.key} (${principalArea.value}).',
      );
    }

    return partes.join(' ');
  }

  String _lecturaResumenCumplimientoPlanMejora({
    required int replanificacionesRegistradas,
    required int planesReplanificados,
    required int planesVencidosActivos,
    required MapEntry<String, int>? principalResponsable,
    required MapEntry<String, int>? principalPlanCronificado,
  }) {
    if (replanificacionesRegistradas == 0 && planesVencidosActivos == 0) {
      return 'Los planes de mejora vienen sosteniendo su fecha objetivo sin reprogramaciones ni vencimientos activos en el periodo.';
    }

    final partes = <String>[
      '$replanificacionesRegistradas replanificaciones sobre $planesReplanificados planes de mejora en el periodo activo.',
    ];

    if (planesVencidosActivos > 0) {
      partes.add(
        '$planesVencidosActivos planes siguen vencidos y necesitan redefinir compromiso o capacidad operativa.',
      );
    }

    if (principalResponsable != null) {
      partes.add(
        '${principalResponsable.key} concentra ${principalResponsable.value} reprogramaciones.',
      );
    }

    if (principalPlanCronificado != null) {
      partes.add(
        'Ya hay al menos un plan cronificado con ${principalPlanCronificado.value} reprogramaciones.',
      );
    }

    return partes.join(' ');
  }

  String _estadoPostReplanificacion({
    required int planesObservados,
    required int estabilizados,
    required int reabiertos,
    required int vencidosActivos,
  }) {
    if (planesObservados == 0) return 'Neutro';
    final enRiesgo = reabiertos + vencidosActivos;
    if (enRiesgo >= estabilizados && enRiesgo > 0) {
      return 'Atencion';
    }
    if (estabilizados > enRiesgo) {
      return 'Favorable';
    }
    return 'Neutro';
  }

  String _lecturaResumenPostReplanificacion({
    required int planesObservados,
    required int estabilizados,
    required int reabiertos,
    required int vencidosActivos,
    required int enSeguimiento,
    required MapEntry<String, int>? principalResponsable,
  }) {
    if (planesObservados == 0) {
      return 'Todavia no hay replanificaciones en el periodo activo para medir su efecto posterior.';
    }

    final partes = <String>[
      '$estabilizados de $planesObservados planes replanificados ya muestran estabilizacion posterior.',
    ];

    if (reabiertos > 0) {
      partes.add('$reabiertos volvieron a reabrirse despues de la reprogramacion.');
    }
    if (vencidosActivos > 0) {
      partes.add('$vencidosActivos siguen activos y vencidos aun despues del ajuste.');
    }
    if (enSeguimiento > 0) {
      partes.add('$enSeguimiento siguen abiertos dentro de su nueva ventana de seguimiento.');
    }
    if (principalResponsable != null) {
      partes.add(
        '${principalResponsable.key} concentra ${principalResponsable.value} casos post-replanificacion en riesgo.',
      );
    }

    return partes.join(' ');
  }

  String _lecturaResumenEstrategiasCorrectivas(
    List<EstrategiaCorrectivaItem> estrategias,
    List<TendenciaEstrategiaCorrectiva> tendencias,
  ) {
    if (estrategias.isEmpty) {
      return 'Todavia no hay estrategias correctivas diferenciadas suficientes para comparar su desempeno.';
    }

    final principal = estrategias.first;
    final riesgo =
        (principal.reabiertasPeriodo * 2) +
        principal.vencidasActivas +
        principal.activas;
    final tendenciaPrincipal = tendencias.isEmpty ? null : tendencias.first;

    if (principal.resueltasPeriodo > riesgo) {
      if (tendenciaPrincipal != null && tendenciaPrincipal.estado == 'Mejora') {
        return '${principal.estrategia} viene resolviendo mejor que el resto y ademas mejora frente al periodo anterior, asi que puede consolidarse como patron institucional.';
      }
      return '${principal.estrategia} viene resolviendo mejor que el resto en el periodo activo y puede servir como referencia de cierre.';
    }

    if (tendenciaPrincipal != null && tendenciaPrincipal.estado == 'Alerta') {
      return '${principal.estrategia} concentra hoy la mayor carga o riesgo correctivo y ademas empeora frente al periodo anterior, asi que conviene revisar si debe reforzarse o reemplazarse.';
    }
    return '${principal.estrategia} concentra hoy la mayor carga o riesgo correctivo, asi que conviene auditar su ejecucion y contrastarla con las otras estrategias.';
  }

  TendenciaEstrategiaCorrectiva _construirTendenciaEstrategia({
    required String estrategia,
    required int resueltasActual,
    required int resueltasAnterior,
    required int reabiertasActual,
    required int reabiertasAnterior,
  }) {
    final puntajeActual = resueltasActual - (reabiertasActual * 2);
    final puntajeAnterior = resueltasAnterior - (reabiertasAnterior * 2);
    final estado = switch (puntajeActual.compareTo(puntajeAnterior)) {
      > 0 => 'Mejora',
      < 0 => 'Alerta',
      _ => 'Estable',
    };

    final lectura = switch (estado) {
      'Mejora' =>
        '$estrategia mejora frente al periodo anterior: $resueltasActual resueltas y $reabiertasActual reabiertas en la ventana activa.',
      'Alerta' =>
        '$estrategia empeora frente al periodo anterior: suben reaperturas o baja la capacidad de resolucion en la ventana activa.',
      _ =>
        '$estrategia mantiene un desempeno parejo entre el periodo actual y el anterior.',
    };

    return TendenciaEstrategiaCorrectiva(
      estrategia: estrategia,
      resueltasActual: resueltasActual,
      resueltasAnterior: resueltasAnterior,
      reabiertasActual: reabiertasActual,
      reabiertasAnterior: reabiertasAnterior,
      estado: estado,
      lectura: lectura,
    );
  }

  int _pesoEstadoTendenciaEstrategia(String estado) {
    switch (estado) {
      case 'Alerta':
        return 0;
      case 'Mejora':
        return 1;
      default:
        return 2;
    }
  }

  RecomendacionEstrategiaCorrectiva _construirRecomendacionEstrategiaCorrectiva(
    List<EstrategiaCorrectivaItem> estrategias,
    List<TendenciaEstrategiaCorrectiva> tendencias,
    Map<String, int> resueltasPreviasPorEstrategia,
    Map<String, int> reabiertasPreviasPorEstrategia,
  ) {
    if (estrategias.isEmpty) {
      return const RecomendacionEstrategiaCorrectiva(
        estrategia: '',
        estrategiaAnterior: '',
        estado: 'Sin datos',
        esInestable: false,
        lecturaEjecutiva:
            'Todavia no hay suficiente recorrido para recomendar una estrategia correctiva dominante.',
        accionSugerida:
            'Sostener registro de estrategias en nuevos planes para construir una recomendacion comparativa.',
      );
    }

    final tendenciaPorEstrategia = {
      for (final item in tendencias) item.estrategia: item,
    };
    final candidatas = List<EstrategiaCorrectivaItem>.from(estrategias)
      ..sort((a, b) {
        final scoreA = _puntajeDominanciaEstrategia(
          a,
          tendenciaPorEstrategia[a.estrategia],
        );
        final scoreB = _puntajeDominanciaEstrategia(
          b,
          tendenciaPorEstrategia[b.estrategia],
        );
        final porScore = scoreB.compareTo(scoreA);
        if (porScore != 0) return porScore;
        return a.estrategia.compareTo(b.estrategia);
      });

    final dominante = candidatas.first;
    final tendencia = tendenciaPorEstrategia[dominante.estrategia];
    final score = _puntajeDominanciaEstrategia(dominante, tendencia);
    final estrategiaAnterior = _estrategiaDominantePeriodoAnterior(
      resueltasPreviasPorEstrategia,
      reabiertasPreviasPorEstrategia,
    );
    final cambioDominante = estrategiaAnterior.isNotEmpty &&
        estrategiaAnterior != dominante.estrategia;
    final estado = switch (tendencia?.estado) {
      'Mejora' when score > 0 => 'Promover',
      'Alerta' => 'Revisar',
      _ when score > 0 => 'Sostener',
      _ => 'Revisar',
    };
    final esInestable = estado == 'Revisar' || cambioDominante;

    final lecturaEjecutiva = switch (estado) {
      'Promover' =>
        cambioDominante
            ? '${dominante.estrategia} desplaza a $estrategiaAnterior como estrategia dominante del periodo, con mejores cierres y tendencia positiva.'
            : '${dominante.estrategia} combina mejores cierres con tendencia positiva frente al periodo anterior, asi que conviene consolidarla como patron institucional.',
      'Sostener' =>
        cambioDominante
            ? '${dominante.estrategia} pasa a liderar sobre $estrategiaAnterior, aunque todavia conviene confirmar que el cambio se sostenga antes de institucionalizarlo.'
            : '${dominante.estrategia} muestra hoy el balance mas sano entre cierres, reaperturas y carga activa, por lo que conviene sostenerla como referencia operativa.',
      _ =>
        cambioDominante
            ? '${dominante.estrategia} reemplaza a $estrategiaAnterior como recomendacion, pero el cambio todavia es inestable y necesita revision antes de promoverlo.'
            : '${dominante.estrategia} aparece arriba del comparativo, pero todavia necesita revision antes de promoverla como patron institucional.',
    };

    final accionSugerida = switch (estado) {
      'Promover' =>
        'Documentar esta estrategia, usarla como base en nuevos planes comparables y monitorear que sostenga su mejora en el proximo periodo.',
      'Sostener' =>
        'Mantener esta estrategia en casos afines y seguir contrastandola con las alternativas que hoy muestran mas riesgo o deterioro.',
      _ =>
        cambioDominante
            ? 'Auditar por que cambia la estrategia recomendada frente al periodo anterior y validar si el nuevo liderazgo es consistente o solo una variacion coyuntural.'
            : 'Auditar la estrategia antes de expandirla, revisar sus ultimos casos y definir ajustes concretos para el siguiente corte comparativo.',
    };

    return RecomendacionEstrategiaCorrectiva(
      estrategia: dominante.estrategia,
      estrategiaAnterior: estrategiaAnterior,
      estado: estado,
      esInestable: esInestable,
      lecturaEjecutiva: lecturaEjecutiva,
      accionSugerida: accionSugerida,
    );
  }

  String _estrategiaDominantePeriodoAnterior(
    Map<String, int> resueltasPreviasPorEstrategia,
    Map<String, int> reabiertasPreviasPorEstrategia,
  ) {
    final estrategias = {
      ...resueltasPreviasPorEstrategia.keys,
      ...reabiertasPreviasPorEstrategia.keys,
    }.toList();
    if (estrategias.isEmpty) return '';
    estrategias.sort((a, b) {
      final scoreA =
          (resueltasPreviasPorEstrategia[a] ?? 0) -
          ((reabiertasPreviasPorEstrategia[a] ?? 0) * 2);
      final scoreB =
          (resueltasPreviasPorEstrategia[b] ?? 0) -
          ((reabiertasPreviasPorEstrategia[b] ?? 0) * 2);
      final porScore = scoreB.compareTo(scoreA);
      if (porScore != 0) return porScore;
      return a.compareTo(b);
    });
    return estrategias.first;
  }

  int _puntajeDominanciaEstrategia(
    EstrategiaCorrectivaItem item,
    TendenciaEstrategiaCorrectiva? tendencia,
  ) {
    var puntaje =
        (item.resueltasPeriodo * 3) -
        (item.reabiertasPeriodo * 3) -
        (item.vencidasActivas * 2) -
        item.activas;
    switch (tendencia?.estado) {
      case 'Mejora':
        puntaje += 3;
      case 'Alerta':
        puntaje -= 3;
    }
    return puntaje;
  }

  bool _hayEstrategiaCorrectivaEnRiesgo(ResumenEstrategiasCorrectivas resumen) {
    for (final item in resumen.estrategias) {
      if (_puntajeRiesgoEstrategia(item) >= 3) return true;
    }
    return false;
  }

  bool _hayEstrategiaCorrectivaEnDeterioro(
    ResumenEstrategiasCorrectivas resumen,
  ) {
    for (final item in resumen.tendencias) {
      if (item.estado == 'Alerta') return true;
    }
    return false;
  }

  int _puntajeRiesgoEstrategia(EstrategiaCorrectivaItem item) {
    return (item.reabiertasPeriodo * 2) + item.vencidasActivas + (item.activas > 0 ? 1 : 0);
  }

  bool _hayBloqueoCorrectivoRecurrente(ResumenRevisionCorrectiva resumen) {
    if (resumen.revisionesRegistradas < 3) return false;
    if (resumen.bloqueosFrecuentes.isEmpty) return false;
    return resumen.bloqueosFrecuentes.first.cantidad >= 2;
  }

  bool _hayCronificacionPlanMejora(ResumenCumplimientoPlanMejora resumen) {
    if (resumen.planesCronificados > 0) return true;
    return resumen.replanificacionesRegistradas >= 3 &&
        resumen.planesVencidosActivos > 0;
  }

  ComparativaPlanCorrectivo _construirComparativaPlanesCorrectivos(
    List<QueryRow> rows, {
    required DateTime desdeActual,
  }) {
    final casos = <String, _CasoComparativaPlanCorrectivo>{};

    for (final row in rows) {
      final clave = row.read<String>('clave');
      final accion = row.read<String>('accion');
      final comentario = row.read<String>('comentario');
      final creadoEn = row.read<DateTime>('creado_en');
      final caso = casos.putIfAbsent(clave, _CasoComparativaPlanCorrectivo.new);

      if (_esComentarioPlanCorrectivo(comentario)) {
        caso.esPlanCorrectivo = true;
      }

      if (accion == 'derivada' ||
          accion == 'reabierta' ||
          accion == 'reasignada') {
        caso.ultimaApertura = creadoEn;
      }

      if (creadoEn.isBefore(desdeActual)) {
        continue;
      }

      if (accion == 'reabierta') {
        caso.reaperturas++;
      }

      if (accion == 'resuelta' || accion == 'cierre_ejecutivo') {
        caso.resoluciones++;
        final inicio = caso.ultimaApertura;
        if (inicio != null && !creadoEn.isBefore(inicio)) {
          caso.sumaHorasResolucion += creadoEn.difference(inicio).inMinutes / 60.0;
          caso.totalResolucionesConTiempo++;
        }
      }
    }

    final conPlan = _ComparativaPlanCorrectivoAcumulada();
    final sinPlan = _ComparativaPlanCorrectivoAcumulada();

    for (final caso in casos.values) {
      final bucket = caso.esPlanCorrectivo ? conPlan : sinPlan;
      bucket.resoluciones += caso.resoluciones;
      bucket.reaperturas += caso.reaperturas;
      bucket.sumaHorasResolucion += caso.sumaHorasResolucion;
      bucket.totalResolucionesConTiempo += caso.totalResolucionesConTiempo;
    }

    final segmentoConPlan = SegmentoEfectividadPlanCorrectivo(
      etiqueta: 'Con plan correctivo',
      casosResueltos: conPlan.resoluciones,
      reaperturas: conPlan.reaperturas,
      tasaReapertura: conPlan.tasaReapertura,
      promedioHorasResolucion: conPlan.promedioHorasResolucion,
      descripcion:
          'Casos que nacieron desde una alerta de calidad y siguieron el circuito correctivo.',
    );
    final segmentoSinPlan = SegmentoEfectividadPlanCorrectivo(
      etiqueta: 'Sin plan correctivo',
      casosResueltos: sinPlan.resoluciones,
      reaperturas: sinPlan.reaperturas,
      tasaReapertura: sinPlan.tasaReapertura,
      promedioHorasResolucion: sinPlan.promedioHorasResolucion,
      descripcion:
          'Casos institucionales resueltos sin un plan correctivo derivado desde alertas de calidad.',
    );

    return ComparativaPlanCorrectivo(
      conPlanCorrectivo: segmentoConPlan,
      sinPlanCorrectivo: segmentoSinPlan,
      estado: _estadoComparativaPlanes(conPlan, sinPlan),
      lecturaEjecutiva: _lecturaComparativaPlanes(conPlan, sinPlan),
    );
  }

  String _estadoComparativaPlanes(
    _ComparativaPlanCorrectivoAcumulada conPlan,
    _ComparativaPlanCorrectivoAcumulada sinPlan,
  ) {
    if (conPlan.resoluciones == 0 || sinPlan.resoluciones == 0) {
      return 'Neutro';
    }

    final mejoraReaperturas = sinPlan.tasaReapertura - conPlan.tasaReapertura;
    final mejoraTiempo =
        sinPlan.promedioHorasResolucion - conPlan.promedioHorasResolucion;

    if (mejoraReaperturas >= 8 && mejoraTiempo >= -2) {
      return 'Favorable';
    }
    if (mejoraReaperturas < -5 || mejoraTiempo < -8) {
      return 'Atencion';
    }
    return 'Neutro';
  }

  String _lecturaComparativaPlanes(
    _ComparativaPlanCorrectivoAcumulada conPlan,
    _ComparativaPlanCorrectivoAcumulada sinPlan,
  ) {
    if (conPlan.resoluciones == 0 && sinPlan.resoluciones == 0) {
      return 'Todavia no hay cierres suficientes en el periodo para comparar la efectividad del circuito correctivo.';
    }
    if (conPlan.resoluciones == 0) {
      return 'Aun no se resolvieron planes correctivos en el periodo activo, asi que la comparativa sigue abierta.';
    }
    if (sinPlan.resoluciones == 0) {
      return 'En este periodo casi todos los cierres pasaron por planes correctivos, por eso la comparacion con casos generales es acotada.';
    }

    final mejoraReaperturas = sinPlan.tasaReapertura - conPlan.tasaReapertura;
    final mejoraTiempo =
        sinPlan.promedioHorasResolucion - conPlan.promedioHorasResolucion;

    if (mejoraReaperturas >= 8 && mejoraTiempo >= 0) {
      return 'Los planes correctivos estan resolviendo con menos reaperturas y en menos tiempo que los casos generales del mismo periodo.';
    }
    if (mejoraReaperturas >= 8) {
      return 'Los planes correctivos estan cerrando con menos reaperturas, aunque todavia demandan mas tiempo operativo que los casos generales.';
    }
    if (mejoraReaperturas < -5 && mejoraTiempo < 0) {
      return 'Los planes correctivos estan tardando mas y reabriendo mas que los casos generales; conviene revisar la calidad de la derivacion y del cierre.';
    }
    if (mejoraReaperturas < -5) {
      return 'Los planes correctivos estan reabriendo mas que los casos generales; conviene revisar seguimiento, responsables y consistencia del cierre.';
    }
    if (mejoraTiempo < -8) {
      return 'Los planes correctivos estan demorando mas de lo esperable frente a los casos generales; conviene revisar capacidad operativa y hitos intermedios.';
    }
    return 'La comparativa muestra desempeno parejo entre planes correctivos y casos generales, sin una brecha operativa fuerte en este periodo.';
  }

  TendenciaProductividad _armarTendenciaEntera({
    required String clave,
    required String titulo,
    required int actual,
    required int anterior,
    required String descripcion,
    required bool mejorCuandoSube,
  }) {
    final delta = actual - anterior;
    return TendenciaProductividad(
      clave: clave,
      titulo: titulo,
      valorActual: '$actual',
      valorAnterior: '$anterior',
      variacion: _textoVariacionEntera(delta),
      estado: _estadoTendencia(
        delta: delta.toDouble(),
        mejorCuandoSube: mejorCuandoSube,
      ),
      descripcion: descripcion,
    );
  }

  TendenciaProductividad _armarTendenciaDecimal({
    required String clave,
    required String titulo,
    required double actual,
    required double anterior,
    required String descripcion,
    required bool mejorCuandoSube,
    required String sufijo,
  }) {
    final delta = actual - anterior;
    return TendenciaProductividad(
      clave: clave,
      titulo: titulo,
      valorActual: '${actual.toStringAsFixed(1)}$sufijo',
      valorAnterior: '${anterior.toStringAsFixed(1)}$sufijo',
      variacion: _textoVariacionDecimal(delta, sufijo: sufijo),
      estado: _estadoTendencia(
        delta: delta,
        mejorCuandoSube: mejorCuandoSube,
      ),
      descripcion: descripcion,
    );
  }

  String _textoVariacionEntera(int delta) {
    if (delta == 0) return 'Sin cambio';
    final prefijo = delta > 0 ? '+' : '';
    return '$prefijo$delta vs periodo anterior';
  }

  String _textoVariacionDecimal(double delta, {required String sufijo}) {
    if (delta.abs() < 0.05) return 'Sin cambio';
    final prefijo = delta > 0 ? '+' : '';
    return '$prefijo${delta.toStringAsFixed(1)}$sufijo vs periodo anterior';
  }

  String _estadoTendencia({
    required double delta,
    required bool mejorCuandoSube,
  }) {
    if (delta.abs() < 0.05) return 'Estable';
    final mejora = mejorCuandoSube ? delta > 0 : delta < 0;
    return mejora ? 'Mejora' : 'Alerta';
  }

  List<DetalleAlertaGestionFila> _detalleTendenciaConteo({
    required List<QueryRow> rows,
    required PeriodoProductividadGestion periodo,
    required bool Function(String accion) accionValida,
    required String unidad,
  }) {
    final ahora = DateTime.now();
    final desdeActual = ahora.subtract(Duration(days: periodo.dias));
    final actualResponsables = <String, int>{};
    final anteriorResponsables = <String, int>{};
    final actualTipos = <String, int>{};
    final anteriorTipos = <String, int>{};
    var actual = 0;
    var anterior = 0;

    for (final row in rows) {
      final accion = row.read<String>('accion');
      if (!accionValida(accion)) continue;
      final creadoEn = row.read<DateTime>('creado_en');
      final esActual = !creadoEn.isBefore(desdeActual);
      final responsable = _responsableHistorico(row.read<String>('derivada_a'));
      final tipo = _tipoHistorico(row.read<String>('clave'));
      if (esActual) {
        actual++;
        actualResponsables[responsable] =
            (actualResponsables[responsable] ?? 0) + 1;
        actualTipos[tipo] = (actualTipos[tipo] ?? 0) + 1;
      } else {
        anterior++;
        anteriorResponsables[responsable] =
            (anteriorResponsables[responsable] ?? 0) + 1;
        anteriorTipos[tipo] = (anteriorTipos[tipo] ?? 0) + 1;
      }
    }

    return _armarFilasCausalesConteo(
      periodo: periodo,
      metricaActual: actual,
      metricaAnterior: anterior,
      responsablesActual: actualResponsables,
      responsablesAnterior: anteriorResponsables,
      tiposActual: actualTipos,
      tiposAnterior: anteriorTipos,
      unidad: unidad,
    );
  }

  List<DetalleAlertaGestionFila> _detalleTendenciaTiempo({
    required List<QueryRow> rows,
    required PeriodoProductividadGestion periodo,
  }) {
    final ahora = DateTime.now();
    final desdeActual = ahora.subtract(Duration(days: periodo.dias));
    final ultimaAperturaPorClave = <String, DateTime>{};
    final actualResponsables = <String, _PromedioAcumulado>{};
    final anteriorResponsables = <String, _PromedioAcumulado>{};
    final actualTipos = <String, _PromedioAcumulado>{};
    final anteriorTipos = <String, _PromedioAcumulado>{};
    final actual = _PromedioAcumulado();
    final anterior = _PromedioAcumulado();

    for (final row in rows) {
      final accion = row.read<String>('accion');
      final claveHistorica = row.read<String>('clave');
      final creadoEn = row.read<DateTime>('creado_en');
      if (accion == 'derivada' ||
          accion == 'reabierta' ||
          accion == 'reasignada') {
        ultimaAperturaPorClave[claveHistorica] = creadoEn;
        continue;
      }
      if (accion != 'resuelta' && accion != 'cierre_ejecutivo') continue;
      final inicio = ultimaAperturaPorClave[claveHistorica];
      if (inicio == null || creadoEn.isBefore(inicio)) continue;

      final horas = creadoEn.difference(inicio).inMinutes / 60.0;
      final esActual = !creadoEn.isBefore(desdeActual);
      final responsable = _responsableHistorico(row.read<String>('derivada_a'));
      final tipo = _tipoHistorico(claveHistorica);
      final bucketResponsables =
          esActual ? actualResponsables : anteriorResponsables;
      final bucketTipos = esActual ? actualTipos : anteriorTipos;
      final bucket = esActual ? actual : anterior;
      bucket.agregar(horas);
      (bucketResponsables[responsable] ??= _PromedioAcumulado()).agregar(horas);
      (bucketTipos[tipo] ??= _PromedioAcumulado()).agregar(horas);
    }

    return _armarFilasCausalesPromedio(
      periodo: periodo,
      promedioActual: actual.promedio,
      promedioAnterior: anterior.promedio,
      responsablesActual: actualResponsables,
      responsablesAnterior: anteriorResponsables,
      tiposActual: actualTipos,
      tiposAnterior: anteriorTipos,
    );
  }

  List<DetalleAlertaGestionFila> _armarFilasCausalesConteo({
    required PeriodoProductividadGestion periodo,
    required int metricaActual,
    required int metricaAnterior,
    required Map<String, int> responsablesActual,
    required Map<String, int> responsablesAnterior,
    required Map<String, int> tiposActual,
    required Map<String, int> tiposAnterior,
    required String unidad,
  }) {
    final filas = <DetalleAlertaGestionFila>[
      DetalleAlertaGestionFila(
        titulo: 'Periodo actual',
        subtitulo: 'Ventana activa de ${periodo.etiqueta}',
        valor: '$metricaActual $unidad',
      ),
      DetalleAlertaGestionFila(
        titulo: 'Periodo anterior',
        subtitulo: 'Comparacion contra ${periodo.comparacionEtiqueta}',
        valor: '$metricaAnterior $unidad',
      ),
    ];
    filas.addAll(
      _topEnteros(
        datos: responsablesActual,
        subtitulo: 'Responsables | periodo actual',
        unidad: unidad,
      ),
    );
    filas.addAll(
      _topEnteros(
        datos: tiposActual,
        subtitulo: 'Tipos de caso | periodo actual',
        unidad: unidad,
      ),
    );
    filas.addAll(
      _topEnteros(
        datos: responsablesAnterior,
        subtitulo: 'Responsables | periodo anterior',
        unidad: unidad,
        maximo: 2,
      ),
    );
    filas.addAll(
      _topEnteros(
        datos: tiposAnterior,
        subtitulo: 'Tipos de caso | periodo anterior',
        unidad: unidad,
        maximo: 2,
      ),
    );
    return filas;
  }

  List<DetalleAlertaGestionFila> _armarFilasCausalesPromedio({
    required PeriodoProductividadGestion periodo,
    required double promedioActual,
    required double promedioAnterior,
    required Map<String, _PromedioAcumulado> responsablesActual,
    required Map<String, _PromedioAcumulado> responsablesAnterior,
    required Map<String, _PromedioAcumulado> tiposActual,
    required Map<String, _PromedioAcumulado> tiposAnterior,
  }) {
    final filas = <DetalleAlertaGestionFila>[
      DetalleAlertaGestionFila(
        titulo: 'Periodo actual',
        subtitulo: 'Ventana activa de ${periodo.etiqueta}',
        valor: '${promedioActual.toStringAsFixed(1)} h',
      ),
      DetalleAlertaGestionFila(
        titulo: 'Periodo anterior',
        subtitulo: 'Comparacion contra ${periodo.comparacionEtiqueta}',
        valor: '${promedioAnterior.toStringAsFixed(1)} h',
      ),
    ];
    filas.addAll(
      _topPromedios(
        datos: responsablesActual,
        subtitulo: 'Responsables | periodo actual',
      ),
    );
    filas.addAll(
      _topPromedios(
        datos: tiposActual,
        subtitulo: 'Tipos de caso | periodo actual',
      ),
    );
    filas.addAll(
      _topPromedios(
        datos: responsablesAnterior,
        subtitulo: 'Responsables | periodo anterior',
        maximo: 2,
      ),
    );
    filas.addAll(
      _topPromedios(
        datos: tiposAnterior,
        subtitulo: 'Tipos de caso | periodo anterior',
        maximo: 2,
      ),
    );
    return filas;
  }

  List<DetalleAlertaGestionFila> _topEnteros({
    required Map<String, int> datos,
    required String subtitulo,
    required String unidad,
    int maximo = 3,
  }) {
    final entries = datos.entries.toList()
      ..sort((a, b) {
        final porValor = b.value.compareTo(a.value);
        if (porValor != 0) return porValor;
        return a.key.compareTo(b.key);
      });
    return entries
        .take(maximo)
        .map(
          (entry) => DetalleAlertaGestionFila(
            titulo: entry.key,
            subtitulo: subtitulo,
            valor: '${entry.value} $unidad',
          ),
        )
        .toList(growable: false);
  }

  List<DetalleAlertaGestionFila> _topPromedios({
    required Map<String, _PromedioAcumulado> datos,
    required String subtitulo,
    int maximo = 3,
  }) {
    final entries = datos.entries.where((entry) => entry.value.cantidad > 0).toList()
      ..sort((a, b) {
        final porValor = b.value.promedio.compareTo(a.value.promedio);
        if (porValor != 0) return porValor;
        return a.key.compareTo(b.key);
      });
    return entries
        .take(maximo)
        .map(
          (entry) => DetalleAlertaGestionFila(
            titulo: entry.key,
            subtitulo: '$subtitulo | ${entry.value.cantidad} casos',
            valor: '${entry.value.promedio.toStringAsFixed(1)} h',
          ),
        )
        .toList(growable: false);
  }

  String _responsableHistorico(String responsable) {
    final limpio = responsable.trim();
    return limpio.isEmpty ? 'Sin asignar' : limpio;
  }

  String _tipoHistorico(String clave) {
    final tipo = clave.split(':').last;
    return _tituloAlertaDesdeTipo(tipo);
  }

  String _impactoProductividadPorTipo(String tipo) {
    switch (tipo) {
      case 'planes_mejora_vencidos':
        return 'Critico';
      case 'planes_mejora_por_vencer':
        return 'Alto';
    }
    if (_periodoDesdeTipoRecomendacionEstrategica(tipo) != null) {
      return 'Critico';
    }
    if (_periodoDesdeTipoEstrategiaCorrectivaDeterioro(tipo) != null) {
      return 'Critico';
    }
    if (_periodoDesdeTipoEstrategiaCorrectiva(tipo) != null) {
      return 'Critico';
    }
    if (_periodoDesdeTipoFocoReplanificacion(tipo) != null) {
      return 'Critico';
    }
    if (_periodoDesdeTipoPostReplanificacion(tipo) != null) {
      return 'Critico';
    }
    if (_periodoDesdeTipoCronificacionPlanMejora(tipo) != null) {
      return 'Critico';
    }
    if (_periodoDesdeTipoRevisionCorrectiva(tipo) != null) {
      return 'Critico';
    }
    if (_periodoDesdeTipoEfectividadCorrectiva(tipo) != null) {
      return 'Critico';
    }
    if (tipo.startsWith('calidad_cierre_critico_concentrado_')) {
      return 'Critico';
    }
    if (tipo.startsWith('calidad_cierre_general_')) {
      return 'Alto';
    }
    if (_tendenciaDesdeTipoAlerta(tipo) != null) {
      final tendencia = _tendenciaDesdeTipoAlerta(tipo)!;
      switch (tendencia) {
        case 'reaperturas':
        case 'tiempo_resolucion':
          return 'Critico';
        case 'resoluciones':
        case 'cierres_ejecutivos':
          return 'Alto';
        default:
          return 'Medio';
      }
    }

    switch (tipo) {
      case 'seguimientos_vencidos':
      case 'seguimientos_reabiertos':
        return 'Alto';
      case 'cursos_sin_clase':
      case 'asistencia_en_riesgo':
      case 'legajos_criticos':
        return 'Medio';
      case 'alumnos_sin_documento':
      case 'sin_estructura':
        return 'Bajo';
      default:
        return 'Bajo';
    }
  }

  String _etiquetaPlantillaCierre(String tipo) {
    if (tipo.startsWith('productividad_')) return 'Plantilla de productividad';
    if (tipo == 'planes_mejora_vencidos' || tipo == 'planes_mejora_por_vencer') {
      return 'Plantilla correctiva';
    }
    if (_periodoDesdeTipoRecomendacionEstrategica(tipo) != null) {
      return 'Plantilla correctiva';
    }
    if (_periodoDesdeTipoEstrategiaCorrectivaDeterioro(tipo) != null) {
      return 'Plantilla correctiva';
    }
    if (_periodoDesdeTipoEstrategiaCorrectiva(tipo) != null) {
      return 'Plantilla correctiva';
    }
    if (_periodoDesdeTipoFocoReplanificacion(tipo) != null) {
      return 'Plantilla correctiva';
    }
    if (_periodoDesdeTipoPostReplanificacion(tipo) != null) {
      return 'Plantilla correctiva';
    }
    if (_periodoDesdeTipoCronificacionPlanMejora(tipo) != null) {
      return 'Plantilla correctiva';
    }
    if (_periodoDesdeTipoRevisionCorrectiva(tipo) != null) {
      return 'Plantilla correctiva';
    }
    if (_periodoDesdeTipoEfectividadCorrectiva(tipo) != null) {
      return 'Plantilla correctiva';
    }
    switch (tipo) {
      case 'legajos_criticos':
      case 'alumnos_sin_documento':
        return 'Plantilla documental';
      case 'cursos_sin_clase':
      case 'asistencia_en_riesgo':
        return 'Plantilla academica';
      case 'seguimientos_vencidos':
      case 'seguimientos_reabiertos':
        return 'Plantilla ejecutiva';
      case 'sin_estructura':
        return 'Plantilla institucional';
      default:
        return 'Plantilla general';
    }
  }

  List<CierreEjecutivoPatron> _agruparPatronesCierreEjecutivo(
    Iterable<QueryRow> rows, {
    required DateTime desdeActual,
  }) {
    final cierresPorPatron = <String, int>{};
    for (final row in rows) {
      if (row.read<String>('accion') != 'cierre_ejecutivo') continue;
      final creadoEn = row.read<DateTime>('creado_en');
      if (creadoEn.isBefore(desdeActual)) continue;
      final tipo = row.read<String>('clave').split(':').last;
      final plantilla = _etiquetaPlantillaCierre(tipo);
      final tipoCaso = _tituloAlertaDesdeTipo(tipo);
      final impacto = _impactoProductividadPorTipo(tipo);
      final clavePatron = '$plantilla|$tipoCaso|$impacto';
      cierresPorPatron[clavePatron] = (cierresPorPatron[clavePatron] ?? 0) + 1;
    }

    return cierresPorPatron.entries.map((entry) {
      final partes = entry.key.split('|');
      return CierreEjecutivoPatron(
        plantilla: partes[0],
        tipoCaso: partes[1],
        impacto: partes[2],
        cantidad: entry.value,
      );
    }).toList(growable: false)
      ..sort((a, b) {
        final porCantidad = b.cantidad.compareTo(a.cantidad);
        if (porCantidad != 0) return porCantidad;
        final porImpacto = _pesoImpactoProductividad(
          a.impacto,
        ).compareTo(_pesoImpactoProductividad(b.impacto));
        if (porImpacto != 0) return porImpacto;
        final porPlantilla = a.plantilla.compareTo(b.plantilla);
        if (porPlantilla != 0) return porPlantilla;
        return a.tipoCaso.compareTo(b.tipoCaso);
      });
  }

  String _tituloDetalleTendencia(String clave) {
    switch (clave) {
      case 'cierres_ejecutivos':
        return 'Detalle causal | Cierres ejecutivos';
      case 'resoluciones':
        return 'Detalle causal | Resoluciones';
      case 'reaperturas':
        return 'Detalle causal | Reaperturas';
      case 'tiempo_resolucion':
        return 'Detalle causal | Tiempo medio de resolucion';
      default:
        return 'Detalle causal';
    }
  }

  String _tituloAlertaDesdeTipo(String tipo) {
    switch (tipo) {
      case 'planes_mejora_vencidos':
        return 'Planes de mejora vencidos';
      case 'planes_mejora_por_vencer':
        return 'Planes de mejora por vencer';
    }
    if (_periodoDesdeTipoRecomendacionEstrategica(tipo) != null) {
      return 'Recomendacion estrategica inestable';
    }
    if (_periodoDesdeTipoEstrategiaCorrectivaDeterioro(tipo) != null) {
      return 'Estrategia correctiva en deterioro';
    }
    if (_periodoDesdeTipoEstrategiaCorrectiva(tipo) != null) {
      return 'Estrategia correctiva en riesgo';
    }
    final focoReplanificacion = _focoDesdeTipoFocoReplanificacion(tipo);
    if (focoReplanificacion != null) {
      return focoReplanificacion == 'excesiva'
          ? 'Foco prioritario: reprogramacion excesiva'
          : 'Foco prioritario: reprogramacion inefectiva';
    }
    if (_periodoDesdeTipoPostReplanificacion(tipo) != null) {
      return 'Post-replanificacion en riesgo';
    }
    if (_periodoDesdeTipoCronificacionPlanMejora(tipo) != null) {
      return 'Cronificacion de planes de mejora';
    }
    if (_periodoDesdeTipoRevisionCorrectiva(tipo) != null) {
      return 'Bloqueos correctivos recurrentes';
    }
    if (_periodoDesdeTipoEfectividadCorrectiva(tipo) != null) {
      return 'Planes correctivos con efectividad en riesgo';
    }
    if (tipo.startsWith('calidad_cierre_general_')) {
      return 'Predominio de cierres generales';
    }
    if (tipo.startsWith('calidad_cierre_critico_concentrado_')) {
      return 'Cierres criticos concentrados';
    }
    final tendenciaProductividad = _tendenciaDesdeTipoAlerta(tipo);
    if (tendenciaProductividad != null) {
      return _tituloAlertaProductividad(
        _tituloDetalleTendenciaBase(tendenciaProductividad),
      );
    }
    switch (tipo) {
      case 'legajos_criticos':
        return 'Legajos criticos activos';
      case 'cursos_sin_clase':
        return 'Cursos sin clase reciente';
      case 'alumnos_sin_documento':
        return 'Alumnos sin documento cargado';
      case 'asistencia_en_riesgo':
        return 'Asistencia institucional en riesgo';
      case 'sin_estructura':
        return 'Sin estructura institucional cargada';
      case 'seguimientos_vencidos':
        return 'Seguimientos vencidos';
      case 'seguimientos_reabiertos':
        return 'Seguimientos reabiertos';
      default:
        return 'Seguimiento institucional';
    }
  }

  String _tipoAlertaProductividad({
    required String claveTendencia,
    required PeriodoProductividadGestion periodo,
  }) {
    return 'productividad_${claveTendencia}_${periodo.name}';
  }

  PeriodoProductividadGestion? _periodoDesdeTipoAlerta(String tipo) {
    if (!tipo.startsWith('productividad_')) return null;
    for (final periodo in PeriodoProductividadGestion.values) {
      if (tipo.endsWith('_${periodo.name}')) {
        return periodo;
      }
    }
    return null;
  }

  String? _tendenciaDesdeTipoAlerta(String tipo) {
    final periodo = _periodoDesdeTipoAlerta(tipo);
    if (periodo == null) return null;
    final sufijo = '_${periodo.name}';
    final base = tipo.substring(0, tipo.length - sufijo.length);
    if (!base.startsWith('productividad_')) return null;
    return base.substring('productividad_'.length);
  }

  String _tituloDetalleTendenciaBase(String clave) {
    switch (clave) {
      case 'cierres_ejecutivos':
        return 'Cierres ejecutivos';
      case 'resoluciones':
        return 'Resoluciones';
      case 'reaperturas':
        return 'Reaperturas';
      case 'tiempo_resolucion':
        return 'Tiempo medio de resolucion';
      default:
        return 'Productividad institucional';
    }
  }

  String _tipoAlertaCalidadCierre({
    required String base,
    required PeriodoProductividadGestion periodo,
  }) {
    return 'calidad_cierre_${base}_${periodo.name}';
  }

  String _tipoAlertaEfectividadCorrectiva(PeriodoProductividadGestion periodo) {
    return 'efectividad_correctiva_${periodo.name}';
  }

  String _tipoAlertaRevisionCorrectiva(PeriodoProductividadGestion periodo) {
    return 'revision_correctiva_${periodo.name}';
  }

  String _tipoAlertaCronificacionPlanMejora(
    PeriodoProductividadGestion periodo,
  ) {
    return 'cronificacion_plan_mejora_${periodo.name}';
  }

  String _tipoAlertaPostReplanificacion(
    PeriodoProductividadGestion periodo,
  ) {
    return 'post_replanificacion_${periodo.name}';
  }

  String _tipoAlertaFocoReplanificacion(
    PeriodoProductividadGestion periodo, {
    required bool excesiva,
  }) {
    return excesiva
        ? 'foco_replanificacion_excesiva_${periodo.name}'
        : 'foco_replanificacion_inefectiva_${periodo.name}';
  }

  String _tipoAlertaEstrategiaCorrectiva(
    PeriodoProductividadGestion periodo,
    String estrategiaSlug,
  ) {
    return 'estrategia_correctiva_${periodo.name}_$estrategiaSlug';
  }

  String _tipoAlertaEstrategiaCorrectivaDeterioro(
    PeriodoProductividadGestion periodo,
    String estrategiaSlug,
  ) {
    return 'estrategia_deterioro_${periodo.name}_$estrategiaSlug';
  }

  String _tipoAlertaRecomendacionEstrategica(
    PeriodoProductividadGestion periodo,
  ) {
    return 'recomendacion_estrategica_${periodo.name}';
  }

  PeriodoProductividadGestion? _periodoDesdeTipoCalidadCierre(String tipo) {
    if (!tipo.startsWith('calidad_cierre_')) return null;
    for (final periodo in PeriodoProductividadGestion.values) {
      if (tipo.endsWith('_${periodo.name}')) {
        return periodo;
      }
    }
    return null;
  }

  PeriodoProductividadGestion? _periodoDesdeTipoEfectividadCorrectiva(
    String tipo,
  ) {
    if (!tipo.startsWith('efectividad_correctiva_')) return null;
    for (final periodo in PeriodoProductividadGestion.values) {
      if (tipo.endsWith('_${periodo.name}')) {
        return periodo;
      }
    }
    return null;
  }

  PeriodoProductividadGestion? _periodoDesdeTipoRevisionCorrectiva(
    String tipo,
  ) {
    if (!tipo.startsWith('revision_correctiva_')) return null;
    for (final periodo in PeriodoProductividadGestion.values) {
      if (tipo.endsWith('_${periodo.name}')) {
        return periodo;
      }
    }
    return null;
  }

  PeriodoProductividadGestion? _periodoDesdeTipoCronificacionPlanMejora(
    String tipo,
  ) {
    if (!tipo.startsWith('cronificacion_plan_mejora_')) return null;
    for (final periodo in PeriodoProductividadGestion.values) {
      if (tipo.endsWith('_${periodo.name}')) {
        return periodo;
      }
    }
    return null;
  }

  PeriodoProductividadGestion? _periodoDesdeTipoPostReplanificacion(
    String tipo,
  ) {
    if (!tipo.startsWith('post_replanificacion_')) return null;
    for (final periodo in PeriodoProductividadGestion.values) {
      if (tipo.endsWith('_${periodo.name}')) {
        return periodo;
      }
    }
    return null;
  }

  PeriodoProductividadGestion? _periodoDesdeTipoFocoReplanificacion(
    String tipo,
  ) {
    if (!tipo.startsWith('foco_replanificacion_')) return null;
    for (final periodo in PeriodoProductividadGestion.values) {
      if (tipo.endsWith('_${periodo.name}')) {
        return periodo;
      }
    }
    return null;
  }

  String? _focoDesdeTipoFocoReplanificacion(String tipo) {
    if (tipo.startsWith('foco_replanificacion_excesiva_')) {
      return 'excesiva';
    }
    if (tipo.startsWith('foco_replanificacion_inefectiva_')) {
      return 'inefectiva';
    }
    return null;
  }

  PeriodoProductividadGestion? _periodoDesdeTipoEstrategiaCorrectiva(
    String tipo,
  ) {
    if (!tipo.startsWith('estrategia_correctiva_')) return null;
    for (final periodo in PeriodoProductividadGestion.values) {
      if (tipo.startsWith('estrategia_correctiva_${periodo.name}_')) {
        return periodo;
      }
    }
    return null;
  }

  PeriodoProductividadGestion? _periodoDesdeTipoEstrategiaCorrectivaDeterioro(
    String tipo,
  ) {
    if (!tipo.startsWith('estrategia_deterioro_')) return null;
    for (final periodo in PeriodoProductividadGestion.values) {
      if (tipo.startsWith('estrategia_deterioro_${periodo.name}_')) {
        return periodo;
      }
    }
    return null;
  }

  PeriodoProductividadGestion? _periodoDesdeTipoRecomendacionEstrategica(
    String tipo,
  ) {
    if (!tipo.startsWith('recomendacion_estrategica_')) return null;
    for (final periodo in PeriodoProductividadGestion.values) {
      if (tipo == 'recomendacion_estrategica_${periodo.name}') {
        return periodo;
      }
    }
    return null;
  }

  String? _slugDesdeTipoEstrategiaCorrectiva(String tipo) {
    final periodo = _periodoDesdeTipoEstrategiaCorrectiva(tipo);
    if (periodo == null) return null;
    final prefijo = 'estrategia_correctiva_${periodo.name}_';
    if (!tipo.startsWith(prefijo)) return null;
    final slug = tipo.substring(prefijo.length).trim();
    return slug.isEmpty ? null : slug;
  }

  String? _slugDesdeTipoEstrategiaCorrectivaDeterioro(String tipo) {
    final periodo = _periodoDesdeTipoEstrategiaCorrectivaDeterioro(tipo);
    if (periodo == null) return null;
    final prefijo = 'estrategia_deterioro_${periodo.name}_';
    if (!tipo.startsWith(prefijo)) return null;
    final slug = tipo.substring(prefijo.length).trim();
    return slug.isEmpty ? null : slug;
  }

  Future<List<QueryRow>> _cargarHistorialGestion({
    required ContextoInstitucional contexto,
    required DateTime desde,
  }) {
    final prefijo = [
      contexto.rol.name,
      contexto.nivel.name,
      contexto.dependencia.name,
    ].join(':');
    return _db.customSelect(
      '''
      SELECT
        clave,
        accion,
        COALESCE(derivada_a, '') AS derivada_a,
        creado_en
      FROM tabla_alertas_gestion_historial
      WHERE clave LIKE ?
        AND creado_en >= ?
      ORDER BY clave ASC, creado_en ASC, id ASC
      ''',
      variables: [
        Variable<String>('$prefijo:%'),
        Variable<DateTime>(desde),
      ],
    ).get();
  }

  Future<DetalleAlertaGestion> _detalleCalidadCierreGeneral(
    ContextoInstitucional contexto,
    PeriodoProductividadGestion periodo,
  ) async {
    final desdeActual = DateTime.now().subtract(Duration(days: periodo.dias));
    final rows = await _cargarHistorialGestion(
      contexto: contexto,
      desde: desdeActual,
    );
    final patrones = _agruparPatronesCierreEjecutivo(rows, desdeActual: desdeActual);
    final total = patrones.fold<int>(0, (acum, item) => acum + item.cantidad);
    final generales = patrones
        .where((item) => item.plantilla == 'Plantilla general')
        .toList(growable: false);
    final cantidadGeneral = generales.fold<int>(
      0,
      (acum, item) => acum + item.cantidad,
    );

    return DetalleAlertaGestion(
      titulo: 'Predominio de cierres generales',
      descripcion:
          'Detalle de cierres ejecutivos del periodo ${periodo.etiqueta} para revisar especificidad del cierre institucional.',
      filas: [
        DetalleAlertaGestionFila(
          titulo: 'Cierres generales',
          subtitulo: 'Plantilla general sobre el total del periodo',
          valor: '$cantidadGeneral / $total',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Accion correctiva sugerida',
          subtitulo: 'Recomendacion institucional inmediata',
          valor: _accionCorrectivaCalidadCierre('general'),
        ),
        ...generales.map(
          (item) => DetalleAlertaGestionFila(
            titulo: item.tipoCaso,
            subtitulo: item.plantilla,
            valor: '${item.cantidad} cierres',
          ),
        ),
      ],
    );
  }

  Future<DetalleAlertaGestion> _detalleCalidadCierreCritico(
    ContextoInstitucional contexto,
    PeriodoProductividadGestion periodo,
  ) async {
    final desdeActual = DateTime.now().subtract(Duration(days: periodo.dias));
    final rows = await _cargarHistorialGestion(
      contexto: contexto,
      desde: desdeActual,
    );
    final patrones = _agruparPatronesCierreEjecutivo(rows, desdeActual: desdeActual)
        .where((item) => item.impacto == 'Critico')
        .toList(growable: false);
    final total = patrones.fold<int>(0, (acum, item) => acum + item.cantidad);

    return DetalleAlertaGestion(
      titulo: 'Cierres criticos concentrados',
      descripcion:
          'Distribucion de cierres ejecutivos criticos durante ${periodo.etiqueta} para detectar concentraciones persistentes.',
      filas: [
        DetalleAlertaGestionFila(
          titulo: 'Cierres criticos',
          subtitulo: 'Total de cierres ejecutivos criticos en el periodo',
          valor: '$total',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Accion correctiva sugerida',
          subtitulo: 'Recomendacion institucional inmediata',
          valor: _accionCorrectivaCalidadCierre('critico_concentrado'),
        ),
        ...patrones.map(
          (item) => DetalleAlertaGestionFila(
            titulo: item.tipoCaso,
            subtitulo: item.plantilla,
            valor: '${item.cantidad} cierres',
          ),
        ),
      ],
    );
  }

  Future<DetalleAlertaGestion> _detalleEfectividadCorrectiva(
    ContextoInstitucional contexto,
    PeriodoProductividadGestion periodo,
  ) async {
    final seguimientos = await _listarSeguimientos(contexto);
    final productividad = await _construirProductividad(
      contexto: contexto,
      periodo: periodo,
      seguimientos: seguimientos,
    );
    final comparativa = productividad.comparativaPlanesCorrectivos;
    final conPlan = comparativa.conPlanCorrectivo;
    final sinPlan = comparativa.sinPlanCorrectivo;

    return DetalleAlertaGestion(
      titulo: 'Planes correctivos con efectividad en riesgo',
      descripcion:
          'Comparativa ejecutiva del periodo ${periodo.etiqueta} para revisar si el circuito correctivo sostiene mejores cierres que los casos generales.',
      filas: [
        DetalleAlertaGestionFila(
          titulo: conPlan.etiqueta,
          subtitulo: 'Reaperturas y tiempo medio de resolucion',
          valor:
              '${conPlan.tasaReapertura.toStringAsFixed(1)}% | ${conPlan.promedioHorasResolucion.toStringAsFixed(1)} h',
        ),
        DetalleAlertaGestionFila(
          titulo: sinPlan.etiqueta,
          subtitulo: 'Reaperturas y tiempo medio de resolucion',
          valor:
              '${sinPlan.tasaReapertura.toStringAsFixed(1)}% | ${sinPlan.promedioHorasResolucion.toStringAsFixed(1)} h',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Lectura ejecutiva',
          subtitulo: comparativa.estado,
          valor: comparativa.lecturaEjecutiva,
        ),
        DetalleAlertaGestionFila(
          titulo: 'Accion correctiva sugerida',
          subtitulo: 'Intervencion institucional prioritaria',
          valor: _accionCorrectivaEfectividadCorrectiva(),
        ),
        DetalleAlertaGestionFila(
          titulo: 'Cierres con plan correctivo',
          subtitulo: 'Casos observados en el periodo',
          valor: '${conPlan.casosResueltos}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Cierres sin plan correctivo',
          subtitulo: 'Casos observados en el periodo',
          valor: '${sinPlan.casosResueltos}',
        ),
      ],
    );
  }

  Future<DetalleAlertaGestion> _detalleBloqueosCorrectivosRecurrentes(
    ContextoInstitucional contexto,
    PeriodoProductividadGestion periodo,
  ) async {
    final seguimientos = await _listarSeguimientos(contexto);
    final productividad = await _construirProductividad(
      contexto: contexto,
      periodo: periodo,
      seguimientos: seguimientos,
    );
    final resumen = productividad.resumenRevisionesCorrectivas;
    final principal = resumen.bloqueosFrecuentes.isEmpty
        ? null
        : resumen.bloqueosFrecuentes.first;

    return DetalleAlertaGestion(
      titulo: 'Bloqueos correctivos recurrentes',
      descripcion:
          'Resumen de revisiones correctivas del periodo ${periodo.etiqueta} para detectar causas que se repiten dentro del circuito correctivo.',
      filas: [
        DetalleAlertaGestionFila(
          titulo: 'Revisiones registradas',
          subtitulo: 'Volumen total del periodo',
          valor: '${resumen.revisionesRegistradas}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Planes auditados',
          subtitulo: 'Planes correctivos con al menos una revision',
          valor: '${resumen.planesAuditados}',
        ),
        if (principal != null)
          DetalleAlertaGestionFila(
            titulo: 'Bloqueo principal',
            subtitulo: principal.subtitulo,
            valor: '${principal.etiqueta} | ${principal.cantidad}',
          ),
        DetalleAlertaGestionFila(
          titulo: 'Accion correctiva sugerida',
          subtitulo: 'Intervencion institucional prioritaria',
          valor: _accionCorrectivaRevisionCorrectiva(),
        ),
        ...resumen.areasComprometidas.map(
          (item) => DetalleAlertaGestionFila(
            titulo: item.etiqueta,
            subtitulo: item.subtitulo,
            valor: '${item.cantidad} revisiones',
          ),
        ),
      ],
    );
  }

  Future<DetalleAlertaGestion> _detallePlanesMejora(
    ContextoInstitucional contexto, {
    required bool soloVencidos,
  }) async {
    final items = await _listarSeguimientos(contexto);
    final filtrados = items
        .where(
          (item) => soloVencidos
              ? item.planMejoraVencido
              : item.planMejoraPorVencer,
        )
        .toList(growable: false);

    return DetalleAlertaGestion(
      titulo: soloVencidos
          ? 'Planes de mejora vencidos'
          : 'Planes de mejora por vencer',
      descripcion: soloVencidos
          ? 'Planes correctivos con compromiso formal cuya fecha objetivo ya fue superada.'
          : 'Planes correctivos que llegan a su fecha objetivo dentro de los proximos 3 dias.',
      filas: filtrados
          .map(
            (item) => DetalleAlertaGestionFila(
              titulo: item.titulo,
              subtitulo: item.responsable,
              valor: item.fechaObjetivoPlan == null
                  ? 'Sin fecha'
                  : _fechaObjetivoLegible(item.fechaObjetivoPlan!),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<DetalleAlertaGestion> _detalleCronificacionPlanMejora(
    ContextoInstitucional contexto,
    PeriodoProductividadGestion periodo,
  ) async {
    final seguimientos = await _listarSeguimientos(contexto);
    final productividad = await _construirProductividad(
      contexto: contexto,
      periodo: periodo,
      seguimientos: seguimientos,
    );
    final resumen = productividad.resumenCumplimientoPlanMejora;

    return DetalleAlertaGestion(
      titulo: 'Cronificacion de planes de mejora',
      descripcion:
          'Lectura ejecutiva de ${periodo.etiqueta} para detectar compromisos que se reprograman demasiado, siguen vencidos o necesitan rediseño institucional.',
      filas: [
        DetalleAlertaGestionFila(
          titulo: 'Replanificaciones registradas',
          subtitulo: 'Volumen acumulado del periodo',
          valor: '${resumen.replanificacionesRegistradas}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Planes reprogramados',
          subtitulo: 'Planes con al menos una replanificacion',
          valor: '${resumen.planesReplanificados}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Planes vencidos activos',
          subtitulo: 'Compromisos abiertos fuera de termino',
          valor: '${resumen.planesVencidosActivos}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Planes cronificados',
          subtitulo: 'Planes con dos o mas reprogramaciones',
          valor: '${resumen.planesCronificados}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Accion correctiva sugerida',
          subtitulo: 'Intervencion institucional prioritaria',
          valor: _accionCorrectivaCronificacionPlanMejora(),
        ),
        ...resumen.responsablesReprogramados.map(
          (item) => DetalleAlertaGestionFila(
            titulo: item.etiqueta,
            subtitulo: item.subtitulo,
            valor: '${item.cantidad} replanificaciones',
          ),
        ),
        ...resumen.planesCronificadosDetalle.map(
          (item) => DetalleAlertaGestionFila(
            titulo: item.etiqueta,
            subtitulo: item.subtitulo,
            valor: '${item.cantidad} reprogramaciones',
          ),
        ),
      ],
    );
  }

  Future<DetalleAlertaGestion> _detallePostReplanificacion(
    ContextoInstitucional contexto,
    PeriodoProductividadGestion periodo,
  ) async {
    final seguimientos = await _listarSeguimientos(contexto);
    final productividad = await _construirProductividad(
      contexto: contexto,
      periodo: periodo,
      seguimientos: seguimientos,
    );
    final resumen = productividad.resumenPostReplanificacion;

    return DetalleAlertaGestion(
      titulo: 'Post-replanificacion en riesgo',
      descripcion:
          'Lectura del periodo ${periodo.etiqueta} para verificar si los planes reprogramados se estabilizan o vuelven a reabrirse, vencerse o concentrar riesgo operativo.',
      filas: [
        DetalleAlertaGestionFila(
          titulo: 'Planes observados',
          subtitulo: 'Planes con al menos una replanificacion',
          valor: '${resumen.planesObservados}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Estabilizados',
          subtitulo: 'Sin reapertura ni vencimiento posterior',
          valor: '${resumen.estabilizados}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Reabiertos post-ajuste',
          subtitulo: 'Planes que volvieron a reabrirse',
          valor: '${resumen.reabiertos}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Vencidos post-ajuste',
          subtitulo: 'Planes que siguen activos y fuera de termino',
          valor: '${resumen.vencidosActivos}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'En seguimiento',
          subtitulo: 'Planes abiertos dentro de la nueva ventana',
          valor: '${resumen.enSeguimiento}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Accion correctiva sugerida',
          subtitulo: 'Intervencion institucional prioritaria',
          valor: _accionCorrectivaPostReplanificacion(),
        ),
        ...resumen.responsablesEnRiesgo.map(
          (item) => DetalleAlertaGestionFila(
            titulo: item.etiqueta,
            subtitulo: item.subtitulo,
            valor: '${item.cantidad} casos en riesgo',
          ),
        ),
      ],
    );
  }

  Future<DetalleAlertaGestion> _detalleFocoRiesgoReplanificacion(
    ContextoInstitucional contexto,
    PeriodoProductividadGestion periodo,
  ) async {
    final seguimientos = await _listarSeguimientos(contexto);
    final productividad = await _construirProductividad(
      contexto: contexto,
      periodo: periodo,
      seguimientos: seguimientos,
    );
    final comparativa = productividad.comparativaRiesgoReplanificacion;

    return DetalleAlertaGestion(
      titulo: 'Foco prioritario de replanificacion',
      descripcion:
          'Comparativa ejecutiva del periodo ${periodo.etiqueta} para distinguir si el principal desvio esta en la cantidad de reprogramaciones o en la baja efectividad posterior al ajuste.',
      filas: [
        DetalleAlertaGestionFila(
          titulo: 'Foco actual',
          subtitulo: 'Diagnostico ejecutivo dominante',
          valor: comparativa.foco,
        ),
        DetalleAlertaGestionFila(
          titulo: 'Presion de cronificacion',
          subtitulo: 'Peso de reprogramaciones repetidas y planes cronificados',
          valor: '${comparativa.presionCronificacion}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Riesgo post-ajuste',
          subtitulo: 'Peso de reaperturas y vencimientos posteriores al ajuste',
          valor: '${comparativa.riesgoPostAjuste}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Lectura ejecutiva',
          subtitulo: 'Interpretacion institucional',
          valor: comparativa.lecturaEjecutiva,
        ),
        DetalleAlertaGestionFila(
          titulo: 'Accion correctiva sugerida',
          subtitulo: 'Intervencion prioritaria',
          valor: comparativa.accionSugerida,
        ),
      ],
    );
  }

  Future<DetalleAlertaGestion> _detalleEstrategiaCorrectivaEnRiesgo(
    ContextoInstitucional contexto,
    PeriodoProductividadGestion periodo,
    String tipo,
  ) async {
    final seguimientos = await _listarSeguimientos(contexto);
    final productividad = await _construirProductividad(
      contexto: contexto,
      periodo: periodo,
      seguimientos: seguimientos,
    );
    final slug = _slugDesdeTipoEstrategiaCorrectiva(tipo);
    EstrategiaCorrectivaItem? estrategia;
    if (slug != null) {
      for (final item in productividad.resumenEstrategiasCorrectivas.estrategias) {
        if (_slugEstrategiaCorrectiva(item.estrategia) == slug) {
          estrategia = item;
          break;
        }
      }
    }

    if (estrategia == null) {
      return const DetalleAlertaGestion(
        titulo: 'Estrategia correctiva en riesgo',
        descripcion:
            'No se encontro una estrategia asociada para mostrar el detalle.',
        filas: [],
      );
    }

    return DetalleAlertaGestion(
      titulo: 'Estrategia correctiva en riesgo',
      descripcion:
          'Lectura de ${periodo.etiqueta} para revisar si una estrategia correctiva concreta esta acumulando reaperturas, vencimientos o sobrecarga activa.',
      filas: [
        DetalleAlertaGestionFila(
          titulo: 'Estrategia',
          subtitulo: 'Estrategia bajo observacion',
          valor: estrategia.estrategia,
        ),
        DetalleAlertaGestionFila(
          titulo: 'Activas',
          subtitulo: 'Planes abiertos bajo esta estrategia',
          valor: '${estrategia.activas}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Resueltas',
          subtitulo: 'Cierres del periodo activo',
          valor: '${estrategia.resueltasPeriodo}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Reabiertas',
          subtitulo: 'Casos que volvieron a abrirse',
          valor: '${estrategia.reabiertasPeriodo}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Vencidas',
          subtitulo: 'Planes activos fuera de termino',
          valor: '${estrategia.vencidasActivas}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Accion correctiva sugerida',
          subtitulo: 'Intervencion ejecutiva prioritaria',
          valor: _accionCorrectivaEstrategia(estrategia),
        ),
      ],
    );
  }

  Future<DetalleAlertaGestion> _detalleEstrategiaCorrectivaEnDeterioro(
    ContextoInstitucional contexto,
    PeriodoProductividadGestion periodo,
    String tipo,
  ) async {
    final seguimientos = await _listarSeguimientos(contexto);
    final productividad = await _construirProductividad(
      contexto: contexto,
      periodo: periodo,
      seguimientos: seguimientos,
    );
    final slug = _slugDesdeTipoEstrategiaCorrectivaDeterioro(tipo);
    TendenciaEstrategiaCorrectiva? tendencia;
    if (slug != null) {
      for (final item in productividad.resumenEstrategiasCorrectivas.tendencias) {
        if (_slugEstrategiaCorrectiva(item.estrategia) == slug) {
          tendencia = item;
          break;
        }
      }
    }

    if (tendencia == null) {
      return const DetalleAlertaGestion(
        titulo: 'Estrategia correctiva en deterioro',
        descripcion:
            'No se encontro una tendencia historica asociada para mostrar el detalle.',
        filas: [],
      );
    }

    return DetalleAlertaGestion(
      titulo: 'Estrategia correctiva en deterioro',
      descripcion:
          'Comparativa entre el periodo activo y el anterior para revisar una estrategia que viene empeorando en su relacion entre cierres y reaperturas.',
      filas: [
        DetalleAlertaGestionFila(
          titulo: 'Estrategia',
          subtitulo: 'Estrategia bajo revision historica',
          valor: tendencia.estrategia,
        ),
        DetalleAlertaGestionFila(
          titulo: 'Estado',
          subtitulo: 'Lectura comparativa',
          valor: tendencia.estado,
        ),
        DetalleAlertaGestionFila(
          titulo: 'Resueltas',
          subtitulo: 'Actual vs periodo anterior',
          valor: '${tendencia.resueltasActual} / ${tendencia.resueltasAnterior}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Reabiertas',
          subtitulo: 'Actual vs periodo anterior',
          valor:
              '${tendencia.reabiertasActual} / ${tendencia.reabiertasAnterior}',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Lectura ejecutiva',
          subtitulo: 'Interpretacion del deterioro',
          valor: tendencia.lectura,
        ),
        DetalleAlertaGestionFila(
          titulo: 'Accion correctiva sugerida',
          subtitulo: 'Intervencion prioritaria',
          valor: _accionCorrectivaEstrategiaDeterioro(tendencia),
        ),
      ],
    );
  }

  Future<DetalleAlertaGestion> _detalleRecomendacionEstrategicaInestable(
    ContextoInstitucional contexto,
    PeriodoProductividadGestion periodo,
  ) async {
    final seguimientos = await _listarSeguimientos(contexto);
    final productividad = await _construirProductividad(
      contexto: contexto,
      periodo: periodo,
      seguimientos: seguimientos,
    );
    final recomendacion = productividad.resumenEstrategiasCorrectivas.recomendacion;

    return DetalleAlertaGestion(
      titulo: 'Recomendacion estrategica inestable',
      descripcion:
          'Lectura ejecutiva para revisar si la estrategia recomendada sigue siendo confiable o si cambia demasiado frente al periodo anterior.',
      filas: [
        DetalleAlertaGestionFila(
          titulo: 'Estrategia actual',
          subtitulo: 'Recomendacion dominante del periodo',
          valor: recomendacion.estrategia.isEmpty
              ? 'Sin recomendacion'
              : recomendacion.estrategia,
        ),
        DetalleAlertaGestionFila(
          titulo: 'Referencia anterior',
          subtitulo: 'Mejor estrategia detectada en el periodo previo',
          valor: recomendacion.estrategiaAnterior.isEmpty
              ? 'Sin referencia'
              : recomendacion.estrategiaAnterior,
        ),
        DetalleAlertaGestionFila(
          titulo: 'Estado',
          subtitulo: 'Lectura de estabilidad',
          valor: recomendacion.estado,
        ),
        DetalleAlertaGestionFila(
          titulo: 'Inestabilidad',
          subtitulo: 'Cambio de referencia o necesidad de revision',
          valor: recomendacion.esInestable ? 'Si' : 'No',
        ),
        DetalleAlertaGestionFila(
          titulo: 'Lectura ejecutiva',
          subtitulo: 'Interpretacion institucional',
          valor: recomendacion.lecturaEjecutiva,
        ),
        DetalleAlertaGestionFila(
          titulo: 'Accion correctiva sugerida',
          subtitulo: 'Intervencion prioritaria',
          valor: recomendacion.accionSugerida,
        ),
      ],
    );
  }

  String _tituloAlertaProductividad(String base) => '$base en alerta';

  String _accionCorrectivaCalidadCierre(String tipo) {
    switch (tipo) {
      case 'general':
        return 'Priorizar plantillas especificas y exigir conclusion/decision alineadas al tipo de caso antes de cerrar.';
      case 'critico_concentrado':
        return 'Abrir revision focalizada del tipo de caso dominante y definir una respuesta correctiva comun para futuros cierres.';
      default:
        return 'Revisar calidad del cierre y reforzar criterio institucional.';
    }
  }

  String _accionCorrectivaEfectividadCorrectiva() {
    return 'Revisar responsables, hitos intermedios y criterios de cierre de los planes correctivos antes de seguir derivando nuevos casos por el mismo circuito.';
  }

  String _accionCorrectivaRevisionCorrectiva() {
    return 'Abrir una revision focalizada del bloqueo recurrente, ajustar responsables/hitos y dejar una decision comun para nuevos planes correctivos afectados.';
  }

  String _accionCorrectivaPlanesMejora(String tipo) {
    switch (tipo) {
      case 'vencidos':
        return 'Revisar el compromiso, decidir cierre o replanificacion y dejar nueva fecha objetivo con responsable confirmado.';
      case 'por_vencer':
        return 'Confirmar avance, validar cumplimiento del compromiso y anticipar replanificacion si no llega a la fecha objetivo.';
      default:
        return 'Ordenar seguimiento del plan de mejora correctiva.';
    }
  }

  String _accionCorrectivaCronificacionPlanMejora() {
    return 'Redefinir alcance y capacidad del compromiso, intervenir los planes con reprogramaciones repetidas y pasar los casos cronificados a una supervision ejecutiva mas corta y controlada.';
  }

  String _accionCorrectivaPostReplanificacion() {
    return 'Revisar si la replanificacion realmente cambio el curso del caso, intervenir responsables con riesgo recurrente y cortar rapido los planes que siguen reabriendo o vencidos despues del ajuste.';
  }

  String _accionCorrectivaEstrategia(EstrategiaCorrectivaItem item) {
    if (item.reabiertasPeriodo > item.vencidasActivas) {
      return 'Auditar la ejecucion de ${item.estrategia.toLowerCase()}, revisar hitos y criterios de cierre, y redefinir control posterior para evitar nuevas reaperturas.';
    }
    if (item.vencidasActivas > 0) {
      return 'Revisar capacidad y alcance de ${item.estrategia.toLowerCase()}, acortar plazos y priorizar cierre o saneamiento de planes vencidos.';
    }
    return 'Monitorear ${item.estrategia.toLowerCase()} y contrastarla con otras estrategias activas para decidir si conviene reforzarla o reemplazarla.';
  }

  String _accionCorrectivaEstrategiaDeterioro(
    TendenciaEstrategiaCorrectiva item,
  ) {
    return 'Revisar por que ${item.estrategia.toLowerCase()} empeora frente al periodo anterior, comparar su ejecucion con las estrategias mas estables y decidir si conviene reforzarla, acotarla o reemplazarla.';
  }

  String _fechaObjetivoLegible(DateTime fecha) {
    final dd = fecha.day.toString().padLeft(2, '0');
    final mm = fecha.month.toString().padLeft(2, '0');
    final yyyy = fecha.year.toString();
    return '$dd/$mm/$yyyy';
  }

  bool _esComentarioPlanCorrectivo(String comentario) {
    return comentario.toLowerCase().contains('plan correctivo:');
  }

  bool _esComentarioPlanMejoraCorrectiva(String comentario) {
    return comentario.toLowerCase().contains('plan de mejora correctiva:');
  }

  String? _estrategiaCorrectivaPlan(String comentario) {
    final texto = _extraerCampoRevisionCorrectiva(
      comentario,
      etiqueta: 'Estrategia correctiva:',
    );
    return texto.isEmpty ? null : texto;
  }

  String? _decisionEstrategicaPlan(String comentario) {
    final texto = _extraerCampoRevisionCorrectiva(
      comentario,
      etiqueta: 'Decision estrategica:',
    );
    return texto.isEmpty ? null : texto;
  }

  String _slugEstrategiaCorrectiva(String estrategia) {
    final buffer = StringBuffer();
    for (final rune in estrategia.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      if (RegExp(r'[a-z0-9]').hasMatch(char)) {
        buffer.write(char);
      } else if (buffer.isNotEmpty && !buffer.toString().endsWith('_')) {
        buffer.write('_');
      }
    }
    return buffer
        .toString()
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  DateTime? _fechaObjetivoPlanMejora(String comentario) {
    final texto = _extraerCampoRevisionCorrectiva(
      comentario,
      etiqueta: 'Fecha objetivo:',
    );
    if (texto.isEmpty) return null;
    final partes = texto.split('/');
    if (partes.length != 3) return null;
    final dia = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final anio = int.tryParse(partes[2]);
    if (dia == null || mes == null || anio == null) return null;
    return DateTime(anio, mes, dia, 23, 59);
  }

  String _descripcionAlertaProductividad({
    required TendenciaProductividad tendencia,
    required PeriodoProductividadGestion periodo,
  }) {
    return '${tendencia.variacion} durante ${periodo.etiqueta}. ${tendencia.descripcion}';
  }

  String _severidadAlertaProductividad(String claveTendencia) {
    switch (claveTendencia) {
      case 'reaperturas':
      case 'tiempo_resolucion':
        return 'Alta';
      default:
        return 'Media';
    }
  }

  IconData _iconoAlertaProductividad(String claveTendencia) {
    switch (claveTendencia) {
      case 'cierres_ejecutivos':
        return Icons.assignment_turned_in_outlined;
      case 'resoluciones':
        return Icons.task_alt_outlined;
      case 'reaperturas':
        return Icons.restart_alt_outlined;
      case 'tiempo_resolucion':
        return Icons.timelapse_outlined;
      default:
        return Icons.insights_outlined;
    }
  }

  String _armarCierreEjecutivo({
    required String conclusion,
    required String decision,
    String? proximoPaso,
  }) {
    final partes = <String>[
      'Cierre ejecutivo: ${conclusion.trim()}',
      'Decision institucional: ${decision.trim()}',
    ];
    final siguiente = (proximoPaso ?? '').trim();
    if (siguiente.isNotEmpty) {
      partes.add('Proximo paso: $siguiente');
    }
    return partes.join('\n');
  }
}

class _ProductividadAcumulada {
  int cierresEjecutivos = 0;
  int resoluciones = 0;
  int reaberturas = 0;
  int planesCorrectivosResueltos = 0;
  int planesCorrectivosReabiertos = 0;
  int totalResolucionesConTiempo = 0;
  double sumaHorasResolucion = 0;

  double get promedioHorasResolucion => totalResolucionesConTiempo == 0
      ? 0
      : sumaHorasResolucion / totalResolucionesConTiempo;
}

class _CasoComparativaPlanCorrectivo {
  bool esPlanCorrectivo = false;
  int resoluciones = 0;
  int reaperturas = 0;
  int totalResolucionesConTiempo = 0;
  double sumaHorasResolucion = 0;
  DateTime? ultimaApertura;
}

class _ComparativaPlanCorrectivoAcumulada {
  int resoluciones = 0;
  int reaperturas = 0;
  int totalResolucionesConTiempo = 0;
  double sumaHorasResolucion = 0;

  double get promedioHorasResolucion => totalResolucionesConTiempo == 0
      ? 0
      : sumaHorasResolucion / totalResolucionesConTiempo;

  double get tasaReapertura => resoluciones == 0
      ? 0
      : (reaperturas / resoluciones) * 100;
}

class _PromedioAcumulado {
  int cantidad = 0;
  double suma = 0;

  void agregar(double valor) {
    cantidad++;
    suma += valor;
  }

  double get promedio => cantidad == 0 ? 0 : suma / cantidad;
}
