import 'package:drift/drift.dart';

import '/infraestructura/base_de_datos/base_de_datos.dart';
import '../modelos/curso.dart';

class CursosRepositorio {
  final BaseDeDatos _db;

  CursosRepositorio(this._db);

  Future<List<Curso>> listar({bool incluirInactivos = false}) async {
    final q = _db.select(_db.tablaCursos).join([
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
    ]);

    if (!incluirInactivos) {
      q.where(
        _db.tablaCursos.activo.equals(true) &
            _db.tablaInstituciones.id.isNotNull() &
            _db.tablaInstituciones.activo.equals(true) &
            _db.tablaCarreras.id.isNotNull() &
            _db.tablaCarreras.activo.equals(true) &
            _db.tablaMaterias.id.isNotNull() &
            _db.tablaMaterias.activo.equals(true),
      );
    }

    q.orderBy([
      OrderingTerm.asc(_db.tablaCursos.turno),
      OrderingTerm.asc(_db.tablaCursos.materia),
      OrderingTerm.asc(_db.tablaCursos.nombre),
      OrderingTerm.asc(_db.tablaCursos.division),
      OrderingTerm.asc(_db.tablaCursos.anio),
    ]);

    final rows = await q.get();
    return rows.map(_mapFromJoin).toList(growable: false);
  }

  Future<int> crear({
    required int institucionId,
    required int carreraId,
    required int materiaId,
    required String division,
    required int anioLectivo,
  }) async {
    final institucion = await (_db.select(
      _db.tablaInstituciones,
    )..where((t) => t.id.equals(institucionId))).getSingle();
    final carrera = await (_db.select(
      _db.tablaCarreras,
    )..where((t) => t.id.equals(carreraId))).getSingle();
    final materia = await (_db.select(
      _db.tablaMaterias,
    )..where((t) => t.id.equals(materiaId))).getSingle();

    if (carrera.institucionId != institucionId) {
      throw StateError(
        'La carrera seleccionada no pertenece a la institucion seleccionada',
      );
    }
    if (materia.carreraId != carreraId) {
      throw StateError(
        'La materia seleccionada no pertenece a la carrera seleccionada',
      );
    }

    final divisionSanitizada = division.trim().toUpperCase();
    if (divisionSanitizada.isEmpty) {
      throw ArgumentError.value(
        division,
        'division',
        'La division es requerida',
      );
    }

    final existente = await _db
        .customSelect(
          '''
      SELECT id
      FROM tabla_cursos
      WHERE institucion_id = ?
        AND carrera_id = ?
        AND materia_id = ?
        AND anio = ?
        AND upper(trim(coalesce(division, ''))) = ?
      LIMIT 1
      ''',
          variables: <Variable<Object>>[
            Variable<int>(institucionId),
            Variable<int>(carreraId),
            Variable<int>(materiaId),
            Variable<int>(anioLectivo),
            Variable<String>(divisionSanitizada),
          ],
        )
        .getSingleOrNull();
    if (existente != null) {
      final id = existente.read<int>('id');
      await (_db.update(_db.tablaCursos)..where((t) => t.id.equals(id))).write(
        TablaCursosCompanion(
          nombre: Value(materia.anioCursada.toString()),
          division: Value(divisionSanitizada),
          materia: Value(materia.nombre),
          turno: Value(institucion.nombre),
          anio: Value(anioLectivo),
          institucionId: Value(institucionId),
          carreraId: Value(carreraId),
          materiaId: Value(materiaId),
          activo: const Value(true),
        ),
      );
      return id;
    }

    return _db
        .into(_db.tablaCursos)
        .insert(
          TablaCursosCompanion.insert(
            nombre: materia.anioCursada.toString(),
            division: Value(divisionSanitizada),
            materia: Value(materia.nombre),
            turno: Value(institucion.nombre),
            anio: Value(anioLectivo),
            institucionId: Value(institucionId),
            carreraId: Value(carreraId),
            materiaId: Value(materiaId),
          ),
        );
  }

  Future<void> actualizarActivo({required int cursoId, required bool activo}) {
    return (_db.update(_db.tablaCursos)..where((t) => t.id.equals(cursoId)))
        .write(TablaCursosCompanion(activo: Value(activo)));
  }

  Future<void> inscribirAlumno({
    required int cursoId,
    required int alumnoId,
  }) async {
    await _db
        .into(_db.tablaInscripciones)
        .insert(
          TablaInscripcionesCompanion.insert(
            cursoId: cursoId,
            alumnoId: alumnoId,
            activo: const Value(true),
          ),
          onConflict: DoUpdate(
            (old) => const TablaInscripcionesCompanion(activo: Value(true)),
            target: [
              _db.tablaInscripciones.alumnoId,
              _db.tablaInscripciones.cursoId,
            ],
          ),
        );
  }

  Future<Set<int>> listarIdsAlumnosInscritosActivos(int cursoId) async {
    final rows = await (_db.select(
      _db.tablaInscripciones,
    )..where((t) => t.cursoId.equals(cursoId) & t.activo.equals(true))).get();
    return rows.map((r) => r.alumnoId).toSet();
  }

  Future<int> contarInscritosActivos(int cursoId) async {
    final countExp = _db.tablaInscripciones.id.count();
    final row =
        await (_db.selectOnly(_db.tablaInscripciones)
              ..addColumns([countExp])
              ..where(
                _db.tablaInscripciones.cursoId.equals(cursoId) &
                    _db.tablaInscripciones.activo.equals(true),
              ))
            .getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<void> sincronizarInscripciones({
    required int cursoId,
    required Set<int> alumnoIdsActivos,
  }) async {
    final nuevos = alumnoIdsActivos.where((id) => id > 0).toSet();

    await _db.transaction(() async {
      final actuales = await (_db.select(
        _db.tablaInscripciones,
      )..where((t) => t.cursoId.equals(cursoId))).get();

      final porAlumno = {for (final a in actuales) a.alumnoId: a};

      for (final alumnoId in nuevos) {
        final existente = porAlumno[alumnoId];
        if (existente == null) {
          await _db
              .into(_db.tablaInscripciones)
              .insert(
                TablaInscripcionesCompanion.insert(
                  cursoId: cursoId,
                  alumnoId: alumnoId,
                  activo: const Value(true),
                ),
              );
        } else if (!existente.activo) {
          await (_db.update(_db.tablaInscripciones)
                ..where((t) => t.id.equals(existente.id)))
              .write(const TablaInscripcionesCompanion(activo: Value(true)));
        }
      }

      for (final existente in actuales) {
        if (!nuevos.contains(existente.alumnoId) && existente.activo) {
          await (_db.update(_db.tablaInscripciones)
                ..where((t) => t.id.equals(existente.id)))
              .write(const TablaInscripcionesCompanion(activo: Value(false)));
        }
      }
    });
  }

  Curso _mapFromJoin(TypedResult row) {
    final c = row.readTable(_db.tablaCursos);
    final institucion = row.readTableOrNull(_db.tablaInstituciones);
    final carrera = row.readTableOrNull(_db.tablaCarreras);
    final materia = row.readTableOrNull(_db.tablaMaterias);

    final division = (c.division ?? '').trim();
    final cursoTxt = division.trim();
    final anioCursada =
        materia?.anioCursada ?? int.tryParse((c.nombre).trim()) ?? 1;
    final cursoNormalizado = cursoTxt.isEmpty ? 'A' : cursoTxt;

    return Curso(
      id: c.id,
      institucionId: c.institucionId,
      carreraId: c.carreraId,
      materiaId: c.materiaId,
      institucion: (institucion?.nombre ?? c.turno ?? '').trim(),
      carrera: (carrera?.nombre ?? '').trim(),
      nombre: c.nombre,
      division: cursoNormalizado,
      materia: (materia?.nombre ?? c.materia ?? '').trim(),
      anio: c.anio ?? DateTime.now().year,
      anioCursada: anioCursada,
      curso: cursoNormalizado,
      activo: c.activo,
    );
  }
}
