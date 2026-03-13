import 'package:drift/drift.dart';

import '/infraestructura/base_de_datos/base_de_datos.dart';
import '../modelos/institucion.dart';
import '../modelos/carrera.dart';
import '../modelos/materia_institucion.dart';

class InstitucionesRepositorio {
  final BaseDeDatos _db;

  InstitucionesRepositorio(this._db);

  Future<List<Institucion>> listar({bool incluirInactivas = false}) async {
    final q = _db.select(_db.tablaInstituciones);
    if (!incluirInactivas) {
      q.where((t) => t.activo.equals(true));
    }
    q.orderBy([(t) => OrderingTerm.asc(t.nombre)]);
    final rows = await q.get();
    return rows
        .map((r) => Institucion(id: r.id, nombre: r.nombre, activo: r.activo))
        .toList(growable: false);
  }

  Future<int> crearInstitucion(String nombre) {
    return _db
        .into(_db.tablaInstituciones)
        .insert(
          TablaInstitucionesCompanion.insert(nombre: nombre.trim()),
          onConflict: DoUpdate(
            (old) => const TablaInstitucionesCompanion(activo: Value(true)),
            target: [_db.tablaInstituciones.nombre],
          ),
        );
  }

  Future<List<Carrera>> listarCarrerasDeInstitucion(
    int institucionId, {
    bool incluirInactivas = false,
  }) async {
    final q = _db.select(_db.tablaCarreras)
      ..where((t) => t.institucionId.equals(institucionId));
    if (!incluirInactivas) {
      q.where((t) => t.activo.equals(true));
    }
    q.orderBy([(t) => OrderingTerm.asc(t.nombre)]);

    final rows = await q.get();
    return rows
        .map(
          (r) => Carrera(
            id: r.id,
            institucionId: r.institucionId,
            nombre: r.nombre,
            activo: r.activo,
          ),
        )
        .toList(growable: false);
  }

  Future<Map<int, List<Carrera>>> listarCarrerasAgrupadas({
    bool incluirInactivas = false,
  }) async {
    final q = _db.select(_db.tablaCarreras);
    if (!incluirInactivas) {
      q.where((t) => t.activo.equals(true));
    }
    q.orderBy([
      (t) => OrderingTerm.asc(t.institucionId),
      (t) => OrderingTerm.asc(t.nombre),
    ]);

    final rows = await q.get();
    final out = <int, List<Carrera>>{};
    for (final r in rows) {
      final item = Carrera(
        id: r.id,
        institucionId: r.institucionId,
        nombre: r.nombre,
        activo: r.activo,
      );
      out.putIfAbsent(r.institucionId, () => []).add(item);
    }
    return out;
  }

  Future<int> crearCarrera({
    required int institucionId,
    required String nombre,
  }) {
    return _db
        .into(_db.tablaCarreras)
        .insert(
          TablaCarrerasCompanion.insert(
            institucionId: institucionId,
            nombre: nombre.trim(),
          ),
          onConflict: DoUpdate(
            (old) => const TablaCarrerasCompanion(activo: Value(true)),
            target: [_db.tablaCarreras.institucionId, _db.tablaCarreras.nombre],
          ),
        );
  }

  Future<List<MateriaInstitucion>> listarMateriasDeCarrera(
    int carreraId, {
    bool incluirInactivas = false,
  }) async {
    final q = _db.select(_db.tablaMaterias)
      ..where((t) => t.carreraId.equals(carreraId));
    if (!incluirInactivas) {
      q.where((t) => t.activo.equals(true));
    }
    q.orderBy([
      (t) => OrderingTerm.asc(t.anioCursada),
      (t) => OrderingTerm.asc(t.curso),
      (t) => OrderingTerm.asc(t.nombre),
    ]);
    final rows = await q.get();
    return rows
        .map(
          (r) => MateriaInstitucion(
            id: r.id,
            carreraId: r.carreraId,
            nombre: r.nombre,
            anioCursada: r.anioCursada,
            curso: r.curso,
            activo: r.activo,
          ),
        )
        .toList(growable: false);
  }

  Future<Map<int, List<MateriaInstitucion>>> listarMateriasAgrupadas({
    bool incluirInactivas = false,
  }) async {
    final q = _db.select(_db.tablaMaterias);
    if (!incluirInactivas) {
      q.where((t) => t.activo.equals(true));
    }
    q.orderBy([
      (t) => OrderingTerm.asc(t.carreraId),
      (t) => OrderingTerm.asc(t.anioCursada),
      (t) => OrderingTerm.asc(t.curso),
      (t) => OrderingTerm.asc(t.nombre),
    ]);

    final rows = await q.get();
    final out = <int, List<MateriaInstitucion>>{};
    for (final r in rows) {
      final item = MateriaInstitucion(
        id: r.id,
        carreraId: r.carreraId,
        nombre: r.nombre,
        anioCursada: r.anioCursada,
        curso: r.curso,
        activo: r.activo,
      );
      out.putIfAbsent(r.carreraId, () => []).add(item);
    }
    return out;
  }

  Future<int> crearMateria({
    required int carreraId,
    required String nombre,
    required int anioCursada,
    String curso = 'BASE',
  }) async {
    final cursoSanitizado = curso.trim().isEmpty
        ? 'BASE'
        : curso.trim().toUpperCase();
    final nombreSanitizado = nombre.trim();
    final usaEsquemaViejo = await _existeColumnaEnTablaMaterias(
      'institucion_id',
    );

    if (usaEsquemaViejo) {
      final carrera = await (_db.select(
        _db.tablaCarreras,
      )..where((t) => t.id.equals(carreraId))).getSingle();

      await _db.customStatement(
        '''
        INSERT INTO tabla_materias (
          institucion_id,
          carrera_id,
          nombre,
          anio_cursada,
          curso,
          activo,
          creado_en
        )
        VALUES (?, ?, ?, ?, ?, 1, CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
        ON CONFLICT(institucion_id, nombre)
        DO UPDATE SET
          carrera_id = excluded.carrera_id,
          anio_cursada = excluded.anio_cursada,
          curso = excluded.curso,
          activo = 1
        ''',
        <Variable<Object>>[
          Variable<int>(carrera.institucionId),
          Variable<int>(carreraId),
          Variable<String>(nombreSanitizado),
          Variable<int>(anioCursada),
          Variable<String>(cursoSanitizado),
        ],
      );

      final row = await _db
          .customSelect(
            '''
        SELECT id
        FROM tabla_materias
        WHERE institucion_id = ?
          AND lower(trim(nombre)) = lower(trim(?))
        ORDER BY id
        LIMIT 1
        ''',
            variables: <Variable<Object>>[
              Variable<int>(carrera.institucionId),
              Variable<String>(nombreSanitizado),
            ],
          )
          .getSingle();
      return row.read<int>('id');
    }

    await _db
        .into(_db.tablaMaterias)
        .insert(
          TablaMateriasCompanion.insert(
            carreraId: carreraId,
            nombre: nombreSanitizado,
            anioCursada: anioCursada,
            curso: cursoSanitizado,
          ),
          onConflict: DoUpdate(
            (old) => const TablaMateriasCompanion(activo: Value(true)),
            target: [
              _db.tablaMaterias.carreraId,
              _db.tablaMaterias.nombre,
              _db.tablaMaterias.anioCursada,
              _db.tablaMaterias.curso,
            ],
          ),
        );

    final row = await _db
        .customSelect(
          '''
      SELECT id
      FROM tabla_materias
      WHERE carrera_id = ?
        AND lower(trim(nombre)) = lower(trim(?))
        AND anio_cursada = ?
        AND curso = ?
      ORDER BY id
      LIMIT 1
      ''',
          variables: <Variable<Object>>[
            Variable<int>(carreraId),
            Variable<String>(nombreSanitizado),
            Variable<int>(anioCursada),
            Variable<String>(cursoSanitizado),
          ],
        )
        .getSingle();
    return row.read<int>('id');
  }

  Future<bool> _existeColumnaEnTablaMaterias(String columna) async {
    final rows = await _db
        .customSelect('PRAGMA table_info(tabla_materias)')
        .get();
    for (final row in rows) {
      if (row.read<String>('name') == columna) return true;
    }
    return false;
  }
}
