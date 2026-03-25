import 'package:drift/drift.dart';

import 'package:gestion_de_asistencias/infraestructura/base_de_datos/base_de_datos.dart';
import 'package:gestion_de_asistencias/modulos/legajos/modelos/legajo_documental.dart';
import 'package:gestion_de_asistencias/modulos/panel_institucional/modelos/perfil_institucional.dart';

class LegajosRepositorio {
  final BaseDeDatos _db;

  LegajosRepositorio(this._db);

  Future<DashboardLegajos> cargarDashboard({
    required ContextoInstitucional contexto,
    required String categoria,
  }) async {
    await _asegurarDatosIniciales();

    final expedientes =
        await (_db.select(_db.tablaLegajosDocumentales)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.tipoRegistro.equals('expediente') &
                    t.categoria.equals(categoria) &
                    t.rolDestino.equals(contexto.rol.name) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.severidad),
                (t) => OrderingTerm.desc(t.actualizadoEn),
              ]))
            .get();

    final documentos =
        await (_db.select(_db.tablaLegajosDocumentales)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.tipoRegistro.equals('documento') &
                    t.rolDestino.equals(contexto.rol.name) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.horasHastaVencimiento),
                (t) => OrderingTerm.desc(t.actualizadoEn),
              ]))
            .get();

    final resumen = await _calcularResumen(contexto: contexto);

    return DashboardLegajos(
      resumen: resumen,
      expedientes: expedientes.map(_mapear).toList(growable: false),
      documentosPendientes: documentos.map(_mapear).toList(growable: false),
    );
  }

  Future<int> guardarRegistro(LegajoDocumentalBorrador borrador) async {
    await _asegurarDatosIniciales();

    final companion = TablaLegajosDocumentalesCompanion(
      tipoRegistro: Value(borrador.tipoRegistro),
      categoria: Value(borrador.categoria),
      codigo: Value(borrador.codigo.trim()),
      titulo: Value(borrador.titulo.trim()),
      detalle: Value(borrador.detalle.trim()),
      responsable: Value(borrador.responsable.trim()),
      estado: Value(borrador.estado.trim()),
      severidad: Value(borrador.severidad.trim()),
      rolDestino: Value(borrador.rolDestino),
      nivelDestino: Value(borrador.nivelDestino),
      dependenciaDestino: Value(borrador.dependenciaDestino),
      horasHastaVencimiento: Value(borrador.horasHastaVencimiento),
      actualizadoEn: Value(DateTime.now()),
    );

    if (borrador.id == null) {
      return _db.into(_db.tablaLegajosDocumentales).insert(
        companion.copyWith(creadoEn: Value(DateTime.now())),
      );
    }

    await (_db.update(_db.tablaLegajosDocumentales)
          ..where((t) => t.id.equals(borrador.id!)))
        .write(companion);
    return borrador.id!;
  }

  Future<void> archivarRegistro(int id) async {
    await (_db.update(_db.tablaLegajosDocumentales)..where((t) => t.id.equals(id)))
        .write(
          TablaLegajosDocumentalesCompanion(
            activo: const Value(false),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
  }

  Future<EstadoCruceLegajo?> buscarVinculoPorCodigo(String codigo) async {
    await _asegurarDatosIniciales();

    final rows =
        await (_db.select(_db.tablaLegajosDocumentales)
              ..where((t) => t.codigo.equals(codigo.trim()))
              ..orderBy([
                (t) => OrderingTerm.desc(t.activo),
                (t) => OrderingTerm.desc(t.actualizadoEn),
              ]))
            .get();

    if (rows.isEmpty) return null;
    final principal = rows.first;
    return EstadoCruceLegajo(
      codigoLegajo: principal.codigo,
      tipoRegistro: principal.tipoRegistro,
      estado: principal.estado,
      severidad: principal.severidad,
      cantidadRegistros: rows.length,
      activo: principal.activo,
    );
  }

  Future<ResumenLegajos> _calcularResumen({
    required ContextoInstitucional contexto,
  }) async {
    final rows =
        await (_db.select(_db.tablaLegajosDocumentales)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.rolDestino.equals(contexto.rol.name) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name),
              ))
            .get();

    final pendientes = rows.where((item) => item.estado != 'Listo para emitir');
    final criticos = rows.where(
      (item) => item.severidad == 'Alta' || item.estado == 'Critico',
    );

    return ResumenLegajos(
      legajosActivos: rows.length,
      pendientes: pendientes.length,
      criticos: criticos.length,
    );
  }

  Future<void> _asegurarDatosIniciales() async {
    final total = await _db.tablaLegajosDocumentales.count().getSingle();
    if (total > 0) return;

    final semillas = _semillasIniciales();
    await _db.batch((batch) {
      batch.insertAll(_db.tablaLegajosDocumentales, semillas);
    });
  }

  List<TablaLegajosDocumentalesCompanion> _semillasIniciales() {
    return [
      _registro(
        tipoRegistro: 'expediente',
        categoria: 'alumnos',
        codigo: 'AL-2026-014',
        titulo: 'Pase de alumno con equivalencias pendientes',
        detalle:
            'Ingreso desde otra institucion con materias en analisis y constancia provisoria.',
        responsable: 'Secretaria academica',
        estado: 'Requiere revision',
        severidad: 'Alta',
        rolDestino: RolInstitucional.secretario,
        nivelDestino: NivelInstitucional.secundario,
        dependenciaDestino: DependenciaInstitucional.publica,
      ),
      _registro(
        tipoRegistro: 'expediente',
        categoria: 'alumnos',
        codigo: 'AL-2026-027',
        titulo: 'Regularidad observada por inasistencias',
        detalle:
            'Se espera documentacion respaldatoria y decision institucional.',
        responsable: 'Preceptoria',
        estado: 'En seguimiento',
        severidad: 'Media',
        rolDestino: RolInstitucional.director,
        nivelDestino: NivelInstitucional.secundario,
        dependenciaDestino: DependenciaInstitucional.publica,
      ),
      _registro(
        tipoRegistro: 'expediente',
        categoria: 'alumnos',
        codigo: 'AL-2026-031',
        titulo: 'Solicitud de constancia analitica parcial',
        detalle: 'Legajo completo, falta firma y numero de salida.',
        responsable: 'Mesa de entradas',
        estado: 'Listo para emitir',
        severidad: 'Media',
        rolDestino: RolInstitucional.secretario,
        nivelDestino: NivelInstitucional.secundario,
        dependenciaDestino: DependenciaInstitucional.publica,
      ),
      _registro(
        tipoRegistro: 'expediente',
        categoria: 'personal',
        codigo: 'PE-2026-008',
        titulo: 'Actualizacion de antecedentes del docente',
        detalle: 'Faltan certificados complementarios y validacion de firma.',
        responsable: 'Rectorado',
        estado: 'En revision',
        severidad: 'Media',
        rolDestino: RolInstitucional.rector,
        nivelDestino: NivelInstitucional.terciario,
        dependenciaDestino: DependenciaInstitucional.privada,
      ),
      _registro(
        tipoRegistro: 'expediente',
        categoria: 'personal',
        codigo: 'PE-2026-011',
        titulo: 'Licencia administrativa y reemplazo',
        detalle:
            'Se requiere resolucion urgente para sostener continuidad del curso.',
        responsable: 'Direccion',
        estado: 'Critico',
        severidad: 'Alta',
        rolDestino: RolInstitucional.director,
        nivelDestino: NivelInstitucional.secundario,
        dependenciaDestino: DependenciaInstitucional.publica,
      ),
      _registro(
        tipoRegistro: 'expediente',
        categoria: 'institucional',
        codigo: 'IN-2026-004',
        titulo: 'Renovacion de habilitacion de laboratorio',
        detalle: 'Documentacion incompleta para la proxima inspeccion interna.',
        responsable: 'Area tecnica',
        estado: 'Critico',
        severidad: 'Alta',
        rolDestino: RolInstitucional.tecnico,
        nivelDestino: NivelInstitucional.terciario,
        dependenciaDestino: DependenciaInstitucional.publica,
      ),
      _registro(
        tipoRegistro: 'expediente',
        categoria: 'institucional',
        codigo: 'IN-2026-009',
        titulo: 'Cierre de ciclo y archivo anual',
        detalle:
            'Se estan consolidando reportes, actas y respaldo documental.',
        responsable: 'Secretaria',
        estado: 'En curso',
        severidad: 'Media',
        rolDestino: RolInstitucional.secretario,
        nivelDestino: NivelInstitucional.secundario,
        dependenciaDestino: DependenciaInstitucional.publica,
      ),
      _registro(
        tipoRegistro: 'documento',
        categoria: 'institucional',
        codigo: 'DOC-001',
        titulo: 'Constancias provisorias sin cierre',
        detalle: 'Hay constancias emitidas que todavia no tienen cierre formal.',
        responsable: 'Secretaria academica',
        estado: 'Pendiente',
        severidad: 'Alta',
        rolDestino: RolInstitucional.secretario,
        nivelDestino: NivelInstitucional.secundario,
        dependenciaDestino: DependenciaInstitucional.publica,
        horasHastaVencimiento: 72,
      ),
      _registro(
        tipoRegistro: 'documento',
        categoria: 'institucional',
        codigo: 'DOC-002',
        titulo: 'Legajos con firmas pendientes',
        detalle: 'Faltan firmas institucionales en expedientes activos.',
        responsable: 'Direccion',
        estado: 'Pendiente',
        severidad: 'Alta',
        rolDestino: RolInstitucional.director,
        nivelDestino: NivelInstitucional.secundario,
        dependenciaDestino: DependenciaInstitucional.publica,
        horasHastaVencimiento: 48,
      ),
      _registro(
        tipoRegistro: 'documento',
        categoria: 'institucional',
        codigo: 'DOC-003',
        titulo: 'Documentacion anual para archivo',
        detalle: 'Preparar actas y respaldos para archivo institucional.',
        responsable: 'Rectorado',
        estado: 'Pendiente',
        severidad: 'Media',
        rolDestino: RolInstitucional.rector,
        nivelDestino: NivelInstitucional.terciario,
        dependenciaDestino: DependenciaInstitucional.privada,
        horasHastaVencimiento: 120,
      ),
      _registro(
        tipoRegistro: 'documento',
        categoria: 'institucional',
        codigo: 'DOC-004',
        titulo: 'Actualizacion de datos institucionales',
        detalle: 'Revisar domicilio, autoridades y datos de contacto.',
        responsable: 'Area tecnica',
        estado: 'Pendiente',
        severidad: 'Media',
        rolDestino: RolInstitucional.tecnico,
        nivelDestino: NivelInstitucional.terciario,
        dependenciaDestino: DependenciaInstitucional.publica,
        horasHastaVencimiento: 168,
      ),
    ];
  }

  TablaLegajosDocumentalesCompanion _registro({
    required String tipoRegistro,
    required String categoria,
    required String codigo,
    required String titulo,
    required String detalle,
    required String responsable,
    required String estado,
    required String severidad,
    required RolInstitucional rolDestino,
    required NivelInstitucional nivelDestino,
    required DependenciaInstitucional dependenciaDestino,
    int? horasHastaVencimiento,
  }) {
    return TablaLegajosDocumentalesCompanion.insert(
      tipoRegistro: tipoRegistro,
      categoria: categoria,
      codigo: codigo,
      titulo: titulo,
      detalle: detalle,
      responsable: responsable,
      estado: estado,
      severidad: severidad,
      rolDestino: rolDestino.name,
      nivelDestino: nivelDestino.name,
      dependenciaDestino: dependenciaDestino.name,
      horasHastaVencimiento: Value(horasHastaVencimiento),
    );
  }

  LegajoDocumental _mapear(TablaLegajosDocumentale row) {
    return LegajoDocumental(
      id: row.id,
      tipoRegistro: row.tipoRegistro,
      categoria: row.categoria,
      codigo: row.codigo,
      titulo: row.titulo,
      detalle: row.detalle,
      responsable: row.responsable,
      estado: row.estado,
      severidad: row.severidad,
      rolDestino: row.rolDestino,
      nivelDestino: row.nivelDestino,
      dependenciaDestino: row.dependenciaDestino,
      horasHastaVencimiento: row.horasHastaVencimiento,
    );
  }
}
