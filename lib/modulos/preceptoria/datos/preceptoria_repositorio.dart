import 'package:drift/drift.dart';

import 'package:gestion_de_asistencias/infraestructura/base_de_datos/base_de_datos.dart';
import 'package:gestion_de_asistencias/modulos/panel_institucional/modelos/perfil_institucional.dart';
import 'package:gestion_de_asistencias/modulos/preceptoria/modelos/novedad_preceptoria.dart';

class PreceptoriaRepositorio {
  final BaseDeDatos _db;

  PreceptoriaRepositorio(this._db);

  Future<DashboardPreceptoria> cargarDashboard({
    required ContextoInstitucional contexto,
    required String categoria,
  }) async {
    await _asegurarDatosIniciales();

    final novedades =
        await (_db.select(_db.tablaNovedadesPreceptoria)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.categoria.equals(categoria) &
                    t.rolDestino.equals(contexto.rol.name) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.prioridad),
                (t) => OrderingTerm.asc(t.fechaSeguimiento),
                (t) => OrderingTerm.desc(t.actualizadoEn),
              ]))
            .get();

    final alumnosSinDocumento = await _contarAlumnosSinDocumento();
    final inasistenciasRiesgo = await _contarAlumnosEnRiesgoAsistencia();
    final novedadesDerivadas = await _novedadesDerivadasALegajos(
      contexto: contexto,
      rows: novedades,
    );

    return DashboardPreceptoria(
      resumen: ResumenPreceptoria(
        novedadesActivas: novedades.length,
        urgentes: novedades
            .where((item) => item.prioridad == 'Alta' || item.estado == 'Urgente')
            .length,
        alumnosSinDocumento: alumnosSinDocumento,
        alumnosConInasistenciasRiesgo: inasistenciasRiesgo,
        vinculadasALegajos: novedadesDerivadas.length,
        devueltasDesdeLegajos: novedadesDerivadas
            .where((item) => item.observaciones.contains('Actualizado desde Legajos:'))
            .length,
      ),
      novedades: novedades.map(_mapearNovedad).toList(growable: false),
      alertas: [
        AlertaPreceptoria(
          titulo: 'Alumnos sin documento',
          descripcion:
              'Legajos estudiantiles sin DNI cargado, utiles para seguimiento con familias.',
          valor: '$alumnosSinDocumento',
        ),
        AlertaPreceptoria(
          titulo: 'Inasistencias en riesgo',
          descripcion:
              'Alumnos con 3 o mas ausencias computadas en los ultimos 14 dias.',
          valor: '$inasistenciasRiesgo',
        ),
      ],
      novedadesDerivadas: novedadesDerivadas
          .map(_mapearNovedad)
          .toList(growable: false),
    );
  }

  Future<int> guardarNovedad(NovedadPreceptoriaBorrador borrador) async {
    await _asegurarDatosIniciales();

    final companion = TablaNovedadesPreceptoriaCompanion(
      tipoNovedad: Value(borrador.tipoNovedad),
      categoria: Value(borrador.categoria),
      cursoReferencia: Value(_nullSiVacio(borrador.cursoReferencia)),
      alumnoReferencia: Value(_nullSiVacio(borrador.alumnoReferencia)),
      estado: Value(borrador.estado.trim()),
      prioridad: Value(borrador.prioridad.trim()),
      responsable: Value(borrador.responsable.trim()),
      observaciones: Value(borrador.observaciones.trim()),
      fechaSeguimiento: Value(borrador.fechaSeguimiento),
      rolDestino: Value(borrador.rolDestino),
      nivelDestino: Value(borrador.nivelDestino),
      dependenciaDestino: Value(borrador.dependenciaDestino),
      actualizadoEn: Value(DateTime.now()),
    );

    if (borrador.id == null) {
      return _db.into(_db.tablaNovedadesPreceptoria).insert(
        companion.copyWith(creadoEn: Value(DateTime.now())),
      );
    }

    await (_db.update(_db.tablaNovedadesPreceptoria)
          ..where((t) => t.id.equals(borrador.id!)))
        .write(companion);
    return borrador.id!;
  }

  Future<void> archivarNovedad(int id) async {
    await (_db.update(_db.tablaNovedadesPreceptoria)
          ..where((t) => t.id.equals(id)))
        .write(
          TablaNovedadesPreceptoriaCompanion(
            activo: const Value(false),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
  }

  Future<bool> recibirDeLegajos({
    required int novedadId,
    required String estadoLegajo,
    required String detalleLegajo,
    required bool urgente,
  }) async {
    await _asegurarDatosIniciales();

    final row =
        await (_db.select(_db.tablaNovedadesPreceptoria)
              ..where((t) => t.activo.equals(true) & t.id.equals(novedadId))
              ..limit(1))
            .getSingleOrNull();

    if (row == null) return false;

    final observacionesActualizadas = [
      row.observaciones.trim(),
      'Actualizado desde Legajos: $estadoLegajo.',
      if (detalleLegajo.trim().isNotEmpty) detalleLegajo.trim(),
    ].where((item) => item.isNotEmpty).join('\n');

    await (_db.update(_db.tablaNovedadesPreceptoria)
          ..where((t) => t.id.equals(row.id)))
        .write(
          TablaNovedadesPreceptoriaCompanion(
            estado: Value(urgente ? 'Urgente' : 'En seguimiento'),
            prioridad: Value(urgente ? 'Alta' : row.prioridad),
            observaciones: Value(observacionesActualizadas),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
    return true;
  }

  Future<int> _contarAlumnosSinDocumento() async {
    final row = await _db.customSelect(
      '''
      SELECT COUNT(*) AS total
      FROM tabla_alumnos
      WHERE activo = 1
        AND (documento IS NULL OR TRIM(documento) = '')
      ''',
    ).getSingle();
    return row.read<int>('total');
  }

  Future<int> _contarAlumnosEnRiesgoAsistencia() async {
    final desde = DateTime.now().subtract(const Duration(days: 14));
    final rows = await _db.customSelect(
      '''
      SELECT a.alumno_id, COUNT(*) AS faltas
      FROM tabla_asistencias a
      INNER JOIN tabla_clases c ON c.id = a.clase_id
      WHERE c.fecha >= ?
        AND lower(trim(COALESCE(a.estado, ''))) IN ('ausente', 'falta')
      GROUP BY a.alumno_id
      HAVING COUNT(*) >= 3
      ''',
      variables: [Variable<DateTime>(desde)],
    ).get();
    return rows.length;
  }

  Future<void> _asegurarDatosIniciales() async {
    final total = await _db.tablaNovedadesPreceptoria.count().getSingle();
    if (total > 0) return;

    await _db.batch((batch) {
      batch.insertAll(_db.tablaNovedadesPreceptoria, _semillasIniciales());
    });
  }

  Future<List<TablaNovedadesPreceptoriaData>> _novedadesDerivadasALegajos({
    required ContextoInstitucional contexto,
    required List<TablaNovedadesPreceptoriaData> rows,
  }) async {
    if (rows.isEmpty) return const [];
    final idsEsperados = rows.map((item) => item.id).toSet();
    final legajos =
        await (_db.select(_db.tablaLegajosDocumentales)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name) &
                    t.codigo.like('PRE-%'),
              ))
            .get();
    final idsVinculados = legajos
        .map((item) => RegExp(r'^PRE-(\d+)').firstMatch(item.codigo)?.group(1))
        .map((value) => int.tryParse(value ?? ''))
        .whereType<int>()
        .where(idsEsperados.contains)
        .toSet();

    return rows.where((item) {
      return idsVinculados.contains(item.id) ||
          item.observaciones.contains('Actualizado desde Legajos:');
    }).toList(growable: false);
  }

  List<TablaNovedadesPreceptoriaCompanion> _semillasIniciales() {
    return [
      _registro(
        tipoNovedad: 'justificativo',
        categoria: 'asistencia',
        cursoReferencia: '2do A',
        alumnoReferencia: 'Lucia Benitez',
        estado: 'Pendiente de control',
        prioridad: 'Media',
        responsable: 'Preceptoria turno manana',
        observaciones: 'Se espera constancia medica por dos inasistencias consecutivas.',
        fechaSeguimiento: DateTime.now().add(const Duration(days: 1)),
        rolDestino: RolInstitucional.preceptor,
        nivelDestino: NivelInstitucional.secundario,
        dependenciaDestino: DependenciaInstitucional.publica,
      ),
      _registro(
        tipoNovedad: 'seguimiento',
        categoria: 'trayectoria',
        cursoReferencia: '4to B',
        alumnoReferencia: 'Nicolas Gomez',
        estado: 'Urgente',
        prioridad: 'Alta',
        responsable: 'Preceptoria turno tarde',
        observaciones: 'Acumula ausencias y se recomienda contacto con familia.',
        fechaSeguimiento: DateTime.now().add(const Duration(hours: 20)),
        rolDestino: RolInstitucional.preceptor,
        nivelDestino: NivelInstitucional.secundario,
        dependenciaDestino: DependenciaInstitucional.publica,
      ),
      _registro(
        tipoNovedad: 'convivencia',
        categoria: 'convivencia',
        cursoReferencia: '1ro C',
        alumnoReferencia: 'Curso completo',
        estado: 'En seguimiento',
        prioridad: 'Media',
        responsable: 'Preceptoria superior',
        observaciones: 'Registrar acuerdos y seguimiento grupal del turno.',
        fechaSeguimiento: DateTime.now().add(const Duration(days: 2)),
        rolDestino: RolInstitucional.rector,
        nivelDestino: NivelInstitucional.terciario,
        dependenciaDestino: DependenciaInstitucional.privada,
      ),
      _registro(
        tipoNovedad: 'documentacion',
        categoria: 'documental',
        cursoReferencia: '1er ano',
        alumnoReferencia: 'Camila Sosa',
        estado: 'Pendiente de control',
        prioridad: 'Alta',
        responsable: 'Preceptoria superior',
        observaciones: 'Falta recepcionar copia de DNI y ficha de salud.',
        fechaSeguimiento: DateTime.now().add(const Duration(days: 1)),
        rolDestino: RolInstitucional.rector,
        nivelDestino: NivelInstitucional.terciario,
        dependenciaDestino: DependenciaInstitucional.privada,
      ),
    ];
  }

  TablaNovedadesPreceptoriaCompanion _registro({
    required String tipoNovedad,
    required String categoria,
    required String? cursoReferencia,
    required String? alumnoReferencia,
    required String estado,
    required String prioridad,
    required String responsable,
    required String observaciones,
    required DateTime? fechaSeguimiento,
    required RolInstitucional rolDestino,
    required NivelInstitucional nivelDestino,
    required DependenciaInstitucional dependenciaDestino,
  }) {
    return TablaNovedadesPreceptoriaCompanion.insert(
      tipoNovedad: tipoNovedad,
      categoria: categoria,
      cursoReferencia: Value(cursoReferencia),
      alumnoReferencia: Value(alumnoReferencia),
      estado: estado,
      prioridad: prioridad,
      responsable: responsable,
      observaciones: observaciones,
      fechaSeguimiento: Value(fechaSeguimiento),
      rolDestino: rolDestino.name,
      nivelDestino: nivelDestino.name,
      dependenciaDestino: dependenciaDestino.name,
    );
  }

  NovedadPreceptoria _mapearNovedad(TablaNovedadesPreceptoriaData row) {
    return NovedadPreceptoria(
      id: row.id,
      tipoNovedad: row.tipoNovedad,
      categoria: row.categoria,
      cursoReferencia: row.cursoReferencia,
      alumnoReferencia: row.alumnoReferencia,
      estado: row.estado,
      prioridad: row.prioridad,
      responsable: row.responsable,
      observaciones: row.observaciones,
      fechaSeguimiento: row.fechaSeguimiento,
      rolDestino: row.rolDestino,
      nivelDestino: row.nivelDestino,
      dependenciaDestino: row.dependenciaDestino,
    );
  }

  String? _nullSiVacio(String? valor) {
    final texto = (valor ?? '').trim();
    return texto.isEmpty ? null : texto;
  }
}
