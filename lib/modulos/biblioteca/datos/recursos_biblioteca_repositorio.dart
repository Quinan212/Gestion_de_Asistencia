import 'package:drift/drift.dart';

import 'package:gestion_de_asistencias/infraestructura/base_de_datos/base_de_datos.dart';
import 'package:gestion_de_asistencias/modulos/biblioteca/modelos/recurso_biblioteca.dart';
import 'package:gestion_de_asistencias/modulos/panel_institucional/modelos/perfil_institucional.dart';

class RecursosBibliotecaRepositorio {
  final BaseDeDatos _db;

  RecursosBibliotecaRepositorio(this._db);

  Future<DashboardBiblioteca> cargarDashboard({
    required ContextoInstitucional contexto,
    required String categoria,
  }) async {
    await _asegurarDatosIniciales();

    final prestamos =
        await (_db.select(_db.tablaRecursosBiblioteca)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.rolDestino.equals(contexto.rol.name) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name) &
                    t.estado.isIn(const ['Prestado', 'Reservado']),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.fechaVencimiento),
                (t) => OrderingTerm.desc(t.actualizadoEn),
              ]))
            .get();

    final catalogo =
        await (_db.select(_db.tablaRecursosBiblioteca)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.categoria.equals(categoria) &
                    t.rolDestino.equals(contexto.rol.name) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.estado),
                (t) => OrderingTerm.asc(t.titulo),
              ]))
            .get();

    final recursosDerivados = await _recursosDerivadosALegajos(
      contexto: contexto,
      rows: [...prestamos, ...catalogo],
    );

    return DashboardBiblioteca(
      resumen: await _calcularResumen(
        contexto,
        recursosDerivados: recursosDerivados,
      ),
      prestamos: prestamos.map(_mapear).toList(growable: false),
      catalogo: catalogo.map(_mapear).toList(growable: false),
      recursosDerivados: recursosDerivados.map(_mapear).toList(growable: false),
    );
  }

  Future<int> guardarRecurso(RecursoBibliotecaBorrador borrador) async {
    await _asegurarDatosIniciales();

    final companion = TablaRecursosBibliotecaCompanion(
      tipoRecurso: Value(borrador.tipoRecurso),
      categoria: Value(borrador.categoria),
      codigo: Value(borrador.codigo.trim()),
      titulo: Value(borrador.titulo.trim()),
      autorReferencia: Value(_nullSiVacio(borrador.autorReferencia)),
      estado: Value(borrador.estado.trim()),
      responsable: Value(borrador.responsable.trim()),
      destinatario: Value(_nullSiVacio(borrador.destinatario)),
      cursoReferencia: Value(_nullSiVacio(borrador.cursoReferencia)),
      cantidadTotal: Value(borrador.cantidadTotal),
      cantidadDisponible: Value(borrador.cantidadDisponible),
      fechaVencimiento: Value(borrador.fechaVencimiento),
      observaciones: Value(borrador.observaciones.trim()),
      rolDestino: Value(borrador.rolDestino),
      nivelDestino: Value(borrador.nivelDestino),
      dependenciaDestino: Value(borrador.dependenciaDestino),
      actualizadoEn: Value(DateTime.now()),
    );

    if (borrador.id == null) {
      return _db.into(_db.tablaRecursosBiblioteca).insert(
        companion.copyWith(creadoEn: Value(DateTime.now())),
      );
    }

    await (_db.update(_db.tablaRecursosBiblioteca)
          ..where((t) => t.id.equals(borrador.id!)))
        .write(companion);
    return borrador.id!;
  }

  Future<void> archivarRecurso(int id) async {
    await (_db.update(_db.tablaRecursosBiblioteca)
          ..where((t) => t.id.equals(id)))
        .write(
          TablaRecursosBibliotecaCompanion(
            activo: const Value(false),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
  }

  Future<bool> recibirDeLegajos({
    required String codigoRecurso,
    required String estadoLegajo,
    required String detalleLegajo,
    required bool urgente,
  }) async {
    await _asegurarDatosIniciales();

    final row =
        await (_db.select(_db.tablaRecursosBiblioteca)
              ..where(
                (t) => t.activo.equals(true) & t.codigo.equals(codigoRecurso),
              )
              ..limit(1))
            .getSingleOrNull();

    if (row == null) return false;

    final observacionesActualizadas = [
      row.observaciones.trim(),
      'Actualizado desde Legajos: $estadoLegajo.',
      if (detalleLegajo.trim().isNotEmpty) detalleLegajo.trim(),
    ].where((item) => item.isNotEmpty).join('\n');

    await (_db.update(_db.tablaRecursosBiblioteca)
          ..where((t) => t.id.equals(row.id)))
        .write(
          TablaRecursosBibliotecaCompanion(
            estado: Value(urgente ? 'Prestado' : 'Reservado'),
            observaciones: Value(observacionesActualizadas),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
    return true;
  }

  Future<ResumenBiblioteca> _calcularResumen(
    ContextoInstitucional contexto, {
    required List<TablaRecursosBibliotecaData> recursosDerivados,
  }
  ) async {
    final rows =
        await (_db.select(_db.tablaRecursosBiblioteca)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.rolDestino.equals(contexto.rol.name) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name),
              ))
            .get();

    final prestamosActivos = rows.where(
      (item) => item.estado == 'Prestado' || item.estado == 'Reservado',
    );
    final vencidos = rows.where((item) {
      if (item.estado != 'Prestado' && item.estado != 'Reservado') return false;
      final fecha = item.fechaVencimiento;
      return fecha != null && fecha.isBefore(DateTime.now());
    });
    final disponibles = rows.fold<int>(
      0,
      (acc, item) => acc + item.cantidadDisponible,
    );

    return ResumenBiblioteca(
      recursosActivos: rows.length,
      prestamosActivos: prestamosActivos.length,
      vencidos: vencidos.length,
      disponibles: disponibles,
      vinculadosALegajos: recursosDerivados.length,
      devueltosDesdeLegajos: recursosDerivados
          .where((item) => item.observaciones.contains('Actualizado desde Legajos:'))
          .length,
    );
  }

  Future<List<TablaRecursosBibliotecaData>> _recursosDerivadosALegajos({
    required ContextoInstitucional contexto,
    required List<TablaRecursosBibliotecaData> rows,
  }) async {
    if (rows.isEmpty) return const [];
    final codigosEsperados = rows.map((item) => 'BIB-${item.codigo}').toSet();
    final legajos =
        await (_db.select(_db.tablaLegajosDocumentales)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name) &
                    t.codigo.like('BIB-%'),
              ))
            .get();
    final codigosVinculados = legajos
        .map((item) => item.codigo)
        .where(codigosEsperados.contains)
        .toSet();

    return rows.where((item) {
      return codigosVinculados.contains('BIB-${item.codigo}') ||
          item.observaciones.contains('Actualizado desde Legajos:');
    }).toList(growable: false);
  }

  Future<void> _asegurarDatosIniciales() async {
    final total = await _db.tablaRecursosBiblioteca.count().getSingle();
    if (total > 0) return;

    await _db.batch((batch) {
      batch.insertAll(_db.tablaRecursosBiblioteca, _semillasIniciales());
    });
  }

  List<TablaRecursosBibliotecaCompanion> _semillasIniciales() {
    return [
      _registro(
        tipoRecurso: 'libro',
        categoria: 'literatura',
        codigo: 'BIB-2026-011',
        titulo: 'Martin Fierro',
        autorReferencia: 'Jose Hernandez',
        estado: 'Disponible',
        responsable: 'Biblioteca central',
        destinatario: null,
        cursoReferencia: null,
        cantidadTotal: 4,
        cantidadDisponible: 3,
        fechaVencimiento: null,
        observaciones: 'Edicion escolar en buen estado.',
        rolDestino: RolInstitucional.bibliotecario,
        nivelDestino: NivelInstitucional.secundario,
        dependenciaDestino: DependenciaInstitucional.publica,
      ),
      _registro(
        tipoRecurso: 'manual',
        categoria: 'academico',
        codigo: 'BIB-2026-018',
        titulo: 'Manual de laboratorio',
        autorReferencia: 'Area de ciencias',
        estado: 'Prestado',
        responsable: 'Biblioteca central',
        destinatario: 'Curso 3ro Naturales',
        cursoReferencia: '3ro Naturales',
        cantidadTotal: 6,
        cantidadDisponible: 0,
        fechaVencimiento: DateTime.now().add(const Duration(days: 2)),
        observaciones: 'Prestamo colectivo para practicas.',
        rolDestino: RolInstitucional.bibliotecario,
        nivelDestino: NivelInstitucional.secundario,
        dependenciaDestino: DependenciaInstitucional.publica,
      ),
      _registro(
        tipoRecurso: 'equipo',
        categoria: 'multimedia',
        codigo: 'BIB-2026-026',
        titulo: 'Proyector movil',
        autorReferencia: null,
        estado: 'Reservado',
        responsable: 'Biblioteca central',
        destinatario: 'Prof. Sosa',
        cursoReferencia: '5to A',
        cantidadTotal: 1,
        cantidadDisponible: 0,
        fechaVencimiento: DateTime.now().add(const Duration(days: 1)),
        observaciones: 'Reserva para muestra institucional.',
        rolDestino: RolInstitucional.bibliotecario,
        nivelDestino: NivelInstitucional.secundario,
        dependenciaDestino: DependenciaInstitucional.publica,
      ),
      _registro(
        tipoRecurso: 'libro',
        categoria: 'academico',
        codigo: 'BIB-2026-034',
        titulo: 'Didactica de nivel superior',
        autorReferencia: 'Varios autores',
        estado: 'Disponible',
        responsable: 'Biblioteca superior',
        destinatario: null,
        cursoReferencia: null,
        cantidadTotal: 5,
        cantidadDisponible: 5,
        fechaVencimiento: null,
        observaciones: 'Disponible para consulta docente.',
        rolDestino: RolInstitucional.bibliotecario,
        nivelDestino: NivelInstitucional.terciario,
        dependenciaDestino: DependenciaInstitucional.privada,
      ),
      _registro(
        tipoRecurso: 'revista',
        categoria: 'hemeroteca',
        codigo: 'BIB-2026-041',
        titulo: 'Revista pedagogica trimestral',
        autorReferencia: 'Instituto superior',
        estado: 'Prestado',
        responsable: 'Biblioteca superior',
        destinatario: 'Coord. pedagogica',
        cursoReferencia: null,
        cantidadTotal: 3,
        cantidadDisponible: 1,
        fechaVencimiento: DateTime.now().subtract(const Duration(days: 1)),
        observaciones: 'Prestamo vencido, conviene reclamar devolucion.',
        rolDestino: RolInstitucional.bibliotecario,
        nivelDestino: NivelInstitucional.terciario,
        dependenciaDestino: DependenciaInstitucional.privada,
      ),
    ];
  }

  TablaRecursosBibliotecaCompanion _registro({
    required String tipoRecurso,
    required String categoria,
    required String codigo,
    required String titulo,
    required String? autorReferencia,
    required String estado,
    required String responsable,
    required String? destinatario,
    required String? cursoReferencia,
    required int cantidadTotal,
    required int cantidadDisponible,
    required DateTime? fechaVencimiento,
    required String observaciones,
    required RolInstitucional rolDestino,
    required NivelInstitucional nivelDestino,
    required DependenciaInstitucional dependenciaDestino,
  }) {
    return TablaRecursosBibliotecaCompanion.insert(
      tipoRecurso: tipoRecurso,
      categoria: categoria,
      codigo: codigo,
      titulo: titulo,
      autorReferencia: Value(autorReferencia),
      estado: estado,
      responsable: responsable,
      destinatario: Value(destinatario),
      cursoReferencia: Value(cursoReferencia),
      cantidadTotal: Value(cantidadTotal),
      cantidadDisponible: Value(cantidadDisponible),
      fechaVencimiento: Value(fechaVencimiento),
      observaciones: observaciones,
      rolDestino: rolDestino.name,
      nivelDestino: nivelDestino.name,
      dependenciaDestino: dependenciaDestino.name,
    );
  }

  RecursoBiblioteca _mapear(TablaRecursosBibliotecaData row) {
    return RecursoBiblioteca(
      id: row.id,
      tipoRecurso: row.tipoRecurso,
      categoria: row.categoria,
      codigo: row.codigo,
      titulo: row.titulo,
      autorReferencia: row.autorReferencia,
      estado: row.estado,
      responsable: row.responsable,
      destinatario: row.destinatario,
      cursoReferencia: row.cursoReferencia,
      cantidadTotal: row.cantidadTotal,
      cantidadDisponible: row.cantidadDisponible,
      fechaVencimiento: row.fechaVencimiento,
      observaciones: row.observaciones,
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
