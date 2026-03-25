import 'package:drift/drift.dart';

import 'package:gestion_de_asistencias/infraestructura/base_de_datos/base_de_datos.dart';
import 'package:gestion_de_asistencias/modulos/panel_institucional/modelos/perfil_institucional.dart';
import 'package:gestion_de_asistencias/modulos/secretaria/modelos/tramite_secretaria.dart';

class TramitesSecretariaRepositorio {
  final BaseDeDatos _db;

  TramitesSecretariaRepositorio(this._db);

  Future<DashboardSecretaria> cargarDashboard({
    required ContextoInstitucional contexto,
    required String categoria,
  }) async {
    await _asegurarDatosIniciales();

    final pendientes =
        await (_db.select(_db.tablaTramitesSecretaria)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.categoria.equals(categoria) &
                    t.rolDestino.equals(contexto.rol.name) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name) &
                    t.tipoTramite.isNotIn(const ['emision', 'salida']),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.prioridad),
                (t) => OrderingTerm.asc(t.fechaLimite),
                (t) => OrderingTerm.desc(t.actualizadoEn),
              ]))
            .get();

    final emisiones =
        await (_db.select(_db.tablaTramitesSecretaria)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.rolDestino.equals(contexto.rol.name) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name) &
                    t.tipoTramite.isIn(const ['emision', 'salida']),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.estado),
                (t) => OrderingTerm.asc(t.fechaLimite),
                (t) => OrderingTerm.desc(t.actualizadoEn),
              ]))
            .get();

    final vinculados = await _codigosVinculadosALegajos(
      contexto: contexto,
      codigos: [
        ...pendientes.map((item) => item.codigo),
        ...emisiones.map((item) => item.codigo),
      ],
    );
    final tramitesDerivados = [
      ...pendientes,
      ...emisiones,
    ].where((item) {
      final codigoLegajo = 'SEC-${item.codigo}';
      return vinculados.contains(codigoLegajo) || item.observaciones.contains('Actualizado desde Legajos:');
    }).toList(growable: false);

    return DashboardSecretaria(
      resumen: await _calcularResumen(
        contexto,
        tramitesDerivados: tramitesDerivados,
      ),
      tramitesPendientes: pendientes.map(_mapear).toList(growable: false),
      emisiones: emisiones.map(_mapear).toList(growable: false),
      tramitesDerivados: tramitesDerivados.map(_mapear).toList(growable: false),
    );
  }

  Future<int> guardarTramite(TramiteSecretariaBorrador borrador) async {
    await _asegurarDatosIniciales();

    final companion = TablaTramitesSecretariaCompanion(
      tipoTramite: Value(borrador.tipoTramite),
      categoria: Value(borrador.categoria),
      codigo: Value(borrador.codigo.trim()),
      asunto: Value(borrador.asunto.trim()),
      solicitante: Value(borrador.solicitante.trim()),
      cursoReferencia: Value(_nullSiVacio(borrador.cursoReferencia)),
      estado: Value(borrador.estado.trim()),
      prioridad: Value(borrador.prioridad.trim()),
      responsable: Value(borrador.responsable.trim()),
      observaciones: Value(borrador.observaciones.trim()),
      fechaLimite: Value(borrador.fechaLimite),
      rolDestino: Value(borrador.rolDestino),
      nivelDestino: Value(borrador.nivelDestino),
      dependenciaDestino: Value(borrador.dependenciaDestino),
      actualizadoEn: Value(DateTime.now()),
    );

    if (borrador.id == null) {
      return _db.into(_db.tablaTramitesSecretaria).insert(
        companion.copyWith(creadoEn: Value(DateTime.now())),
      );
    }

    await (_db.update(_db.tablaTramitesSecretaria)
          ..where((t) => t.id.equals(borrador.id!)))
        .write(companion);
    return borrador.id!;
  }

  Future<void> archivarTramite(int id) async {
    await (_db.update(_db.tablaTramitesSecretaria)
          ..where((t) => t.id.equals(id)))
        .write(
          TablaTramitesSecretariaCompanion(
            activo: const Value(false),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
  }

  Future<bool> recibirDeLegajos({
    required String codigoTramite,
    required String estadoLegajo,
    required String detalleLegajo,
    required bool urgente,
  }) async {
    await _asegurarDatosIniciales();

    final row =
        await (_db.select(_db.tablaTramitesSecretaria)
              ..where(
                (t) => t.activo.equals(true) & t.codigo.equals(codigoTramite),
              )
              ..limit(1))
            .getSingleOrNull();

    if (row == null) return false;

    final observacionesActualizadas = [
      row.observaciones.trim(),
      'Actualizado desde Legajos: $estadoLegajo.',
      if (detalleLegajo.trim().isNotEmpty) detalleLegajo.trim(),
    ].where((item) => item.isNotEmpty).join('\n');

    await (_db.update(_db.tablaTramitesSecretaria)
          ..where((t) => t.id.equals(row.id)))
        .write(
          TablaTramitesSecretariaCompanion(
            estado: Value(urgente ? 'Urgente' : 'En verificacion'),
            prioridad: Value(urgente ? 'Alta' : row.prioridad),
            observaciones: Value(observacionesActualizadas),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
    return true;
  }

  Future<ResumenSecretaria> _calcularResumen(
    ContextoInstitucional contexto, {
    required List<TablaTramitesSecretariaData> tramitesDerivados,
  }
  ) async {
    final rows =
        await (_db.select(_db.tablaTramitesSecretaria)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.rolDestino.equals(contexto.rol.name) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name),
              ))
            .get();

    final urgentes = rows.where(
      (item) => item.prioridad == 'Alta' || item.estado == 'Urgente',
    );
    final porVencer = rows.where((item) {
      final fecha = item.fechaLimite;
      if (fecha == null || fecha.isBefore(DateTime.now())) return false;
      return fecha.difference(DateTime.now()) <= const Duration(days: 3);
    });
    final listos = rows.where(
      (item) =>
          item.estado == 'Listo para emitir' || item.estado == 'Listo para firma',
    );

    return ResumenSecretaria(
      tramitesActivos: rows.length,
      urgentes: urgentes.length,
      porVencer: porVencer.length,
      listosParaEmitir: listos.length,
      vinculadosALegajos: tramitesDerivados.length,
      devueltosDesdeLegajos: tramitesDerivados
          .where((item) => item.observaciones.contains('Actualizado desde Legajos:'))
          .length,
    );
  }

  Future<Set<String>> _codigosVinculadosALegajos({
    required ContextoInstitucional contexto,
    required List<String> codigos,
  }) async {
    if (codigos.isEmpty) return <String>{};
    final objetivos = codigos.map((codigo) => 'SEC-$codigo').toSet();
    final rows =
        await (_db.select(_db.tablaLegajosDocumentales)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.rolDestino.equals(contexto.rol.name) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name) &
                    t.codigo.like('SEC-%'),
              ))
            .get();
    return rows
        .map((item) => item.codigo)
        .where(objetivos.contains)
        .toSet();
  }

  Future<void> _asegurarDatosIniciales() async {
    final total = await _db.tablaTramitesSecretaria.count().getSingle();
    if (total > 0) return;

    await _db.batch((batch) {
      batch.insertAll(_db.tablaTramitesSecretaria, _semillasIniciales());
    });
  }

  List<TablaTramitesSecretariaCompanion> _semillasIniciales() {
    return [
      _registro(
        tipoTramite: 'constancia',
        categoria: 'alumnos',
        codigo: 'SEC-2026-018',
        asunto: 'Constancia de alumno regular',
        solicitante: 'Familia Gomez',
        cursoReferencia: '4to B',
        estado: 'Listo para emitir',
        prioridad: 'Media',
        responsable: 'Secretaria academica',
        observaciones: 'Verificar firma directiva y numero de salida.',
        fechaLimite: DateTime.now().add(const Duration(days: 1)),
        rolDestino: RolInstitucional.secretario,
        nivelDestino: NivelInstitucional.secundario,
        dependenciaDestino: DependenciaInstitucional.publica,
      ),
      _registro(
        tipoTramite: 'pase',
        categoria: 'alumnos',
        codigo: 'SEC-2026-021',
        asunto: 'Pase a otra institucion con analitico parcial',
        solicitante: 'Alumno Torres',
        cursoReferencia: '5to A',
        estado: 'En verificacion',
        prioridad: 'Alta',
        responsable: 'Secretaria academica',
        observaciones: 'Falta control de equivalencias y libre deuda.',
        fechaLimite: DateTime.now().add(const Duration(days: 2)),
        rolDestino: RolInstitucional.secretario,
        nivelDestino: NivelInstitucional.secundario,
        dependenciaDestino: DependenciaInstitucional.publica,
      ),
      _registro(
        tipoTramite: 'salida',
        categoria: 'institucional',
        codigo: 'SEC-2026-024',
        asunto: 'Salida de resolucion interna a supervison',
        solicitante: 'Direccion',
        cursoReferencia: null,
        estado: 'Pendiente de firma',
        prioridad: 'Alta',
        responsable: 'Mesa de entradas',
        observaciones: 'Se necesita firma y foliado antes de remitir.',
        fechaLimite: DateTime.now().add(const Duration(days: 1)),
        rolDestino: RolInstitucional.secretario,
        nivelDestino: NivelInstitucional.secundario,
        dependenciaDestino: DependenciaInstitucional.publica,
      ),
      _registro(
        tipoTramite: 'certificacion',
        categoria: 'personal',
        codigo: 'SEC-2026-032',
        asunto: 'Certificacion de servicios docente',
        solicitante: 'Docente Sanchez',
        cursoReferencia: null,
        estado: 'En preparacion',
        prioridad: 'Media',
        responsable: 'Secretaria superior',
        observaciones: 'Cruzar antiguedad con legajo de personal.',
        fechaLimite: DateTime.now().add(const Duration(days: 4)),
        rolDestino: RolInstitucional.rector,
        nivelDestino: NivelInstitucional.terciario,
        dependenciaDestino: DependenciaInstitucional.privada,
      ),
      _registro(
        tipoTramite: 'equivalencia',
        categoria: 'alumnos',
        codigo: 'SEC-2026-037',
        asunto: 'Analisis de equivalencias de ingreso',
        solicitante: 'Coordinacion de carrera',
        cursoReferencia: '1er ano',
        estado: 'Urgente',
        prioridad: 'Alta',
        responsable: 'Secretaria superior',
        observaciones: 'Resolver antes del cierre de inscripciones.',
        fechaLimite: DateTime.now().add(const Duration(hours: 18)),
        rolDestino: RolInstitucional.rector,
        nivelDestino: NivelInstitucional.terciario,
        dependenciaDestino: DependenciaInstitucional.privada,
      ),
      _registro(
        tipoTramite: 'emision',
        categoria: 'institucional',
        codigo: 'SEC-2026-041',
        asunto: 'Emision de analiticos finales',
        solicitante: 'Rectorado',
        cursoReferencia: null,
        estado: 'Listo para firma',
        prioridad: 'Media',
        responsable: 'Secretaria superior',
        observaciones: 'Pendiente de control final y sello institucional.',
        fechaLimite: DateTime.now().add(const Duration(days: 2)),
        rolDestino: RolInstitucional.rector,
        nivelDestino: NivelInstitucional.terciario,
        dependenciaDestino: DependenciaInstitucional.privada,
      ),
    ];
  }

  TablaTramitesSecretariaCompanion _registro({
    required String tipoTramite,
    required String categoria,
    required String codigo,
    required String asunto,
    required String solicitante,
    required String? cursoReferencia,
    required String estado,
    required String prioridad,
    required String responsable,
    required String observaciones,
    required DateTime? fechaLimite,
    required RolInstitucional rolDestino,
    required NivelInstitucional nivelDestino,
    required DependenciaInstitucional dependenciaDestino,
  }) {
    return TablaTramitesSecretariaCompanion.insert(
      tipoTramite: tipoTramite,
      categoria: categoria,
      codigo: codigo,
      asunto: asunto,
      solicitante: solicitante,
      cursoReferencia: Value(cursoReferencia),
      estado: estado,
      prioridad: prioridad,
      responsable: responsable,
      observaciones: observaciones,
      fechaLimite: Value(fechaLimite),
      rolDestino: rolDestino.name,
      nivelDestino: nivelDestino.name,
      dependenciaDestino: dependenciaDestino.name,
    );
  }

  TramiteSecretaria _mapear(TablaTramitesSecretariaData row) {
    return TramiteSecretaria(
      id: row.id,
      tipoTramite: row.tipoTramite,
      categoria: row.categoria,
      codigo: row.codigo,
      asunto: row.asunto,
      solicitante: row.solicitante,
      cursoReferencia: row.cursoReferencia,
      estado: row.estado,
      prioridad: row.prioridad,
      responsable: row.responsable,
      observaciones: row.observaciones,
      fechaLimite: row.fechaLimite,
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
