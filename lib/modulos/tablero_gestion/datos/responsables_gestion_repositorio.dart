import 'package:drift/drift.dart';

import 'package:gestion_de_asistencias/infraestructura/base_de_datos/base_de_datos.dart';
import 'package:gestion_de_asistencias/modulos/panel_institucional/modelos/perfil_institucional.dart';
import 'package:gestion_de_asistencias/modulos/tablero_gestion/modelos/responsable_gestion.dart';
import 'package:gestion_de_asistencias/modulos/tablero_gestion/modelos/tablero_gestion_item.dart';

class ResponsablesGestionRepositorio {
  final BaseDeDatos _db;

  ResponsablesGestionRepositorio(this._db);

  Future<List<ResponsableGestion>> listarParaContexto(
    ContextoInstitucional contexto, {
    String? claveCaso,
    String? impactoProductividad,
    String? responsableActual,
  }) async {
    await _asegurarDatosIniciales();
    final cargasPorResponsable = await _cargasPorResponsable(contexto);

    final rows =
        await (_db.select(_db.tablaResponsablesGestion)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.rolDestino.equals(contexto.rol.name) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.area),
                (t) => OrderingTerm.asc(t.nombre),
              ]))
            .get();

    final items = rows
        .map((row) => _mapearFila(row, cargas: cargasPorResponsable[row.nombre]))
        .toList(growable: false);

    final caso = (claveCaso ?? '').trim();
    if (caso.isEmpty) return items;

    final impacto = (impactoProductividad ?? '').trim();
    final actual = (responsableActual ?? '').trim();
    items.sort((a, b) {
      final puntajeB = _puntajeResponsableParaCaso(
        b,
        claveCaso: caso,
        impactoProductividad: impacto,
        responsableActual: actual,
      );
      final puntajeA = _puntajeResponsableParaCaso(
        a,
        claveCaso: caso,
        impactoProductividad: impacto,
        responsableActual: actual,
      );
      final porPuntaje = puntajeB.compareTo(puntajeA);
      if (porPuntaje != 0) return porPuntaje;

      final porCarga = a.alertasActivas.compareTo(b.alertasActivas);
      if (porCarga != 0) return porCarga;

      final porResueltos =
          b.seguimientosResueltos.compareTo(a.seguimientosResueltos);
      if (porResueltos != 0) return porResueltos;

      return a.nombre.compareTo(b.nombre);
    });
    return items;
  }

  Future<List<ResponsableGestion>> listarAdministrables(
    ContextoInstitucional contexto,
  ) async {
    await _asegurarDatosIniciales();
    final cargasPorResponsable = await _cargasPorResponsable(contexto);

    final rows =
        await (_db.select(_db.tablaResponsablesGestion)
              ..where(
                (t) =>
                    t.rolDestino.equals(contexto.rol.name) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name),
              )
              ..orderBy([
                (t) => OrderingTerm.desc(t.activo),
                (t) => OrderingTerm.asc(t.area),
                (t) => OrderingTerm.asc(t.nombre),
              ]))
            .get();

    return rows
        .map((row) => _mapearFila(row, cargas: cargasPorResponsable[row.nombre]))
        .toList(growable: false);
  }

  Future<List<String>> listarAreasDisponibles(
    ContextoInstitucional contexto,
  ) async {
    await _asegurarDatosIniciales();
    final rows = await _db.customSelect(
      '''
      SELECT DISTINCT area
      FROM tabla_responsables_gestion
      WHERE rol_destino = ?
        AND nivel_destino = ?
        AND dependencia_destino = ?
      ORDER BY area ASC
      ''',
      variables: [
        Variable<String>(contexto.rol.name),
        Variable<String>(contexto.nivel.name),
        Variable<String>(contexto.dependencia.name),
      ],
    ).get();

    return rows
        .map((row) => row.read<String>('area').trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<SeguimientoGestion>> listarAgendaResponsable(
    ContextoInstitucional contexto,
    String responsable,
  ) async {
    final responsableNormalizado = responsable.trim();
    if (responsableNormalizado.isEmpty) return const [];

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
        AND TRIM(COALESCE(derivada_a, '')) = ?
        AND estado IN ('derivada', 'resuelta', 'reabierta')
      ORDER BY actualizado_en DESC
      ''',
      variables: [
        Variable<String>('$prefijo:%'),
        Variable<String>(responsableNormalizado),
      ],
    ).get();

    return rows.map((row) {
      final clave = row.read<String>('clave');
      final tipo = clave.split(':').last;
      final estado = row.read<String>('estado');
      final actualizadoEn = row.read<DateTime>('actualizado_en');
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
        urgencia: _urgenciaSeguimiento(estado: estado, venceEn: venceEn),
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
    }).toList(growable: false)
      ..sort((a, b) {
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
  }

  Future<void> guardarResponsable(ResponsableGestionBorrador borrador) async {
    final companion = TablaResponsablesGestionCompanion(
      nombre: Value(borrador.nombre.trim()),
      area: Value(borrador.area.trim()),
      rolDestino: Value(borrador.rol.name),
      nivelDestino: Value(borrador.nivel.name),
      dependenciaDestino: Value(borrador.dependencia.name),
      activo: Value(borrador.activo),
    );

    if (borrador.id == null) {
      await _db.into(_db.tablaResponsablesGestion).insert(
        companion.copyWith(creadoEn: Value(DateTime.now())),
      );
      return;
    }

    await (_db.update(_db.tablaResponsablesGestion)
          ..where((t) => t.id.equals(borrador.id!)))
        .write(companion);
  }

  Future<void> desactivarResponsable(int id) async {
    await (_db.update(_db.tablaResponsablesGestion)..where((t) => t.id.equals(id)))
        .write(
          const TablaResponsablesGestionCompanion(activo: Value(false)),
        );
  }

  Future<void> reactivarResponsable(int id) async {
    await (_db.update(_db.tablaResponsablesGestion)..where((t) => t.id.equals(id)))
        .write(
          const TablaResponsablesGestionCompanion(activo: Value(true)),
        );
  }

  Future<void> _asegurarDatosIniciales() async {
    final total = await _db.tablaResponsablesGestion.count().getSingle();
    if (total > 0) return;

    await _db.batch((batch) {
      batch.insertAll(_db.tablaResponsablesGestion, _semillas());
    });
  }

  List<TablaResponsablesGestionCompanion> _semillas() {
    return [
      _item(
        nombre: 'Secretaria academica',
        area: 'Documentacion y constancias',
        rol: RolInstitucional.director,
        nivel: NivelInstitucional.secundario,
        dependencia: DependenciaInstitucional.publica,
      ),
      _item(
        nombre: 'Preceptoria turno manana',
        area: 'Seguimiento diario',
        rol: RolInstitucional.director,
        nivel: NivelInstitucional.secundario,
        dependencia: DependenciaInstitucional.publica,
      ),
      _item(
        nombre: 'Coordinacion pedagogica',
        area: 'Trayectorias y asistencia',
        rol: RolInstitucional.director,
        nivel: NivelInstitucional.secundario,
        dependencia: DependenciaInstitucional.publica,
      ),
      _item(
        nombre: 'Secretaria superior',
        area: 'Actas y archivo',
        rol: RolInstitucional.rector,
        nivel: NivelInstitucional.terciario,
        dependencia: DependenciaInstitucional.privada,
      ),
      _item(
        nombre: 'Coordinacion de carrera',
        area: 'Seguimiento academico',
        rol: RolInstitucional.rector,
        nivel: NivelInstitucional.terciario,
        dependencia: DependenciaInstitucional.privada,
      ),
      _item(
        nombre: 'Area tecnica institucional',
        area: 'Infraestructura y soporte',
        rol: RolInstitucional.tecnico,
        nivel: NivelInstitucional.terciario,
        dependencia: DependenciaInstitucional.publica,
      ),
      _item(
        nombre: 'Secretaria academica',
        area: 'Movimientos administrativos',
        rol: RolInstitucional.secretario,
        nivel: NivelInstitucional.secundario,
        dependencia: DependenciaInstitucional.publica,
      ),
    ];
  }

  TablaResponsablesGestionCompanion _item({
    required String nombre,
    required String area,
    required RolInstitucional rol,
    required NivelInstitucional nivel,
    required DependenciaInstitucional dependencia,
  }) {
    return TablaResponsablesGestionCompanion.insert(
      nombre: nombre,
      area: area,
      rolDestino: rol.name,
      nivelDestino: nivel.name,
      dependenciaDestino: dependencia.name,
    );
  }

  Future<Map<String, _CargaResponsable>> _cargasPorResponsable(
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
        TRIM(derivada_a) AS derivada_a,
        SUM(CASE WHEN estado IN ('derivada', 'reabierta') THEN 1 ELSE 0 END) AS activas,
        SUM(CASE WHEN estado = 'resuelta' THEN 1 ELSE 0 END) AS resueltas
      FROM tabla_alertas_gestion_estado
      WHERE clave LIKE ?
        AND derivada_a IS NOT NULL
        AND TRIM(derivada_a) <> ''
      GROUP BY TRIM(derivada_a)
      ''',
      variables: [Variable<String>('$prefijo:%')],
    ).get();

    return {
      for (final row in rows)
        row.read<String>('derivada_a'): _CargaResponsable(
          activas: row.read<int>('activas'),
          resueltas: row.read<int>('resueltas'),
        ),
    };
  }

  ResponsableGestion _mapearFila(
    TablaResponsablesGestionData row, {
    _CargaResponsable? cargas,
  }) {
    return ResponsableGestion(
      id: row.id,
      nombre: row.nombre,
      area: row.area,
      rolDestino: row.rolDestino,
      nivelDestino: row.nivelDestino,
      dependenciaDestino: row.dependenciaDestino,
      activo: row.activo,
      alertasActivas: cargas?.activas ?? 0,
      seguimientosResueltos: cargas?.resueltas ?? 0,
    );
  }

  String _tituloAlertaDesdeTipo(String tipo) {
    switch (tipo) {
      case 'planes_mejora_vencidos':
        return 'Planes de mejora vencidos';
      case 'planes_mejora_por_vencer':
        return 'Planes de mejora por vencer';
    }
    if (tipo.startsWith('recomendacion_estrategica_')) {
      return 'Recomendacion estrategica inestable';
    }
    if (tipo.startsWith('estrategia_deterioro_')) {
      return 'Estrategia correctiva en deterioro';
    }
    if (tipo.startsWith('estrategia_correctiva_')) {
      return 'Estrategia correctiva en riesgo';
    }
    if (tipo.startsWith('foco_replanificacion_excesiva_')) {
      return 'Foco prioritario: reprogramacion excesiva';
    }
    if (tipo.startsWith('foco_replanificacion_inefectiva_')) {
      return 'Foco prioritario: reprogramacion inefectiva';
    }
    if (tipo.startsWith('post_replanificacion_')) {
      return 'Post-replanificacion en riesgo';
    }
    if (tipo.startsWith('cronificacion_plan_mejora_')) {
      return 'Cronificacion de planes de mejora';
    }
    if (tipo.startsWith('revision_correctiva_')) {
      return 'Bloqueos correctivos recurrentes';
    }
    if (tipo.startsWith('efectividad_correctiva_')) {
      return 'Planes correctivos con efectividad en riesgo';
    }
    if (tipo.startsWith('calidad_cierre_general_')) {
      return 'Predominio de cierres generales';
    }
    if (tipo.startsWith('calidad_cierre_critico_concentrado_')) {
      return 'Cierres criticos concentrados';
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
      default:
        return 'Seguimiento institucional';
    }
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

  String _impactoProductividadPorTipo(String tipo) {
    switch (tipo) {
      case 'planes_mejora_vencidos':
        return 'Critico';
      case 'planes_mejora_por_vencer':
        return 'Alto';
    }
    if (tipo.startsWith('recomendacion_estrategica_')) {
      return 'Critico';
    }
    if (tipo.startsWith('estrategia_deterioro_')) {
      return 'Critico';
    }
    if (tipo.startsWith('estrategia_correctiva_')) {
      return 'Critico';
    }
    if (tipo.startsWith('foco_replanificacion_')) {
      return 'Critico';
    }
    if (tipo.startsWith('post_replanificacion_')) {
      return 'Critico';
    }
    if (tipo.startsWith('cronificacion_plan_mejora_')) {
      return 'Critico';
    }
    if (tipo.startsWith('revision_correctiva_')) {
      return 'Critico';
    }
    if (tipo.startsWith('efectividad_correctiva_')) {
      return 'Critico';
    }
    if (tipo.startsWith('calidad_cierre_critico_concentrado_')) {
      return 'Critico';
    }
    if (tipo.startsWith('calidad_cierre_general_')) {
      return 'Alto';
    }
    if (tipo.startsWith('productividad_')) {
      if (tipo.contains('reaperturas') || tipo.contains('tiempo_resolucion')) {
        return 'Critico';
      }
      if (tipo.contains('resoluciones') ||
          tipo.contains('cierres_ejecutivos')) {
        return 'Alto';
      }
      return 'Medio';
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

  bool _esComentarioPlanCorrectivo(String comentario) {
    return comentario.toLowerCase().contains('plan correctivo:');
  }

  bool _esComentarioPlanMejoraCorrectiva(String comentario) {
    return comentario.toLowerCase().contains('plan de mejora correctiva:');
  }

  String? _estrategiaCorrectivaPlan(String comentario) {
    final lineas = comentario.split('\n');
    for (final linea in lineas) {
      final texto = linea.trim();
      if (!texto.startsWith('Estrategia correctiva:')) continue;
      final valor = texto.substring('Estrategia correctiva:'.length).trim();
      return valor.isEmpty ? null : valor;
    }
    return null;
  }

  String? _decisionEstrategicaPlan(String comentario) {
    final lineas = comentario.split('\n');
    for (final linea in lineas) {
      final texto = linea.trim();
      if (!texto.startsWith('Decision estrategica:')) continue;
      final valor = texto.substring('Decision estrategica:'.length).trim();
      return valor.isEmpty ? null : valor;
    }
    return null;
  }

  DateTime? _fechaObjetivoPlanMejora(String comentario) {
    final lineas = comentario.split('\n');
    for (final linea in lineas) {
      final texto = linea.trim();
      if (!texto.startsWith('Fecha objetivo:')) continue;
      final valor = texto.substring('Fecha objetivo:'.length).trim();
      final partes = valor.split('/');
      if (partes.length != 3) return null;
      final dia = int.tryParse(partes[0]);
      final mes = int.tryParse(partes[1]);
      final anio = int.tryParse(partes[2]);
      if (dia == null || mes == null || anio == null) return null;
      return DateTime(anio, mes, dia, 23, 59);
    }
    return null;
  }

  int _puntajeResponsableParaCaso(
    ResponsableGestion responsable, {
    required String claveCaso,
    required String impactoProductividad,
    required String responsableActual,
  }) {
    final tipo = claveCaso.split(':').last;
    final texto = '${responsable.nombre} ${responsable.area}'.toLowerCase();
    var puntaje = 0;

    if (responsableActual.isNotEmpty &&
        responsable.nombre.trim().toLowerCase() ==
            responsableActual.trim().toLowerCase()) {
      puntaje -= 12;
    }

    if (_contieneAlguno(
      texto,
      const ['secret', 'document', 'archivo', 'acta'],
    )) {
      if (tipo == 'legajos_criticos' || tipo == 'alumnos_sin_documento') {
        puntaje += 8;
      } else if (tipo == 'sin_estructura' ||
          tipo.startsWith('productividad_cierres_ejecutivos_')) {
        puntaje += 3;
      }
    }

    if (_contieneAlguno(
      texto,
      const ['precept', 'seguimiento', 'pedagog', 'coordin', 'academ'],
    )) {
      if (tipo == 'cursos_sin_clase' || tipo == 'asistencia_en_riesgo') {
        puntaje += 8;
      } else if (tipo == 'seguimientos_vencidos' ||
          tipo == 'seguimientos_reabiertos') {
        puntaje += 7;
      } else if (tipo.startsWith('productividad_resoluciones_')) {
        puntaje += 8;
      } else if (tipo.startsWith('productividad_reaperturas_') ||
          tipo.startsWith('productividad_tiempo_resolucion_')) {
        puntaje += 9;
      } else if (tipo.startsWith('productividad_cierres_ejecutivos_')) {
        puntaje += 6;
      }
    }

    if (_contieneAlguno(
      texto,
      const ['coordin', 'academ', 'pedagog', 'seguimiento'],
    )) {
      if (tipo.startsWith('recomendacion_estrategica_')) {
        puntaje += 15;
      } else if (tipo.startsWith('estrategia_deterioro_')) {
        puntaje += 14;
      } else if (tipo.startsWith('estrategia_correctiva_')) {
        puntaje += 13;
      } else if (tipo.startsWith('foco_replanificacion_inefectiva_')) {
        puntaje += 14;
      } else if (tipo.startsWith('foco_replanificacion_excesiva_')) {
        puntaje += 11;
      } else if (tipo.startsWith('post_replanificacion_')) {
        puntaje += 13;
      } else if (tipo.startsWith('cronificacion_plan_mejora_')) {
        puntaje += 12;
      } else if (tipo.startsWith('revision_correctiva_')) {
        puntaje += 11;
      } else if (tipo.startsWith('efectividad_correctiva_')) {
        puntaje += 10;
      } else if (tipo.startsWith('calidad_cierre_')) {
        puntaje += 8;
      }
    }

    if (_contieneAlguno(
      texto,
      const ['secret', 'document', 'archivo', 'acta'],
    )) {
      if (tipo.startsWith('recomendacion_estrategica_')) {
        puntaje += 7;
      } else if (tipo.startsWith('estrategia_deterioro_')) {
        puntaje += 8;
      } else if (tipo.startsWith('estrategia_correctiva_')) {
        puntaje += 9;
      } else if (tipo.startsWith('foco_replanificacion_excesiva_')) {
        puntaje += 12;
      } else if (tipo.startsWith('foco_replanificacion_inefectiva_')) {
        puntaje += 8;
      } else if (tipo.startsWith('post_replanificacion_')) {
        puntaje += 10;
      } else if (tipo.startsWith('cronificacion_plan_mejora_')) {
        puntaje += 9;
      } else if (tipo.startsWith('revision_correctiva_')) {
        puntaje += 8;
      } else if (tipo.startsWith('efectividad_correctiva_')) {
        puntaje += 7;
      } else if (tipo.startsWith('calidad_cierre_general_')) {
        puntaje += 9;
      } else if (tipo.startsWith('calidad_cierre_critico_concentrado_')) {
        puntaje += 6;
      }
    }

    if (_contieneAlguno(texto, const ['tecnic', 'infra', 'soporte'])) {
      if (tipo == 'sin_estructura') {
        puntaje += 4;
      }
    }

    if (impactoProductividad == 'Critico') {
      puntaje += responsable.seguimientosResueltos > 0 ? 3 : 1;
    } else if (impactoProductividad == 'Alto') {
      puntaje += responsable.seguimientosResueltos > 0 ? 2 : 1;
    }

    puntaje -= responsable.alertasActivas * 2;
    puntaje += responsable.seguimientosResueltos;
    return puntaje;
  }

  bool _contieneAlguno(String texto, List<String> terminos) {
    for (final termino in terminos) {
      if (texto.contains(termino)) return true;
    }
    return false;
  }
}

class _CargaResponsable {
  final int activas;
  final int resueltas;

  const _CargaResponsable({required this.activas, required this.resueltas});
}
