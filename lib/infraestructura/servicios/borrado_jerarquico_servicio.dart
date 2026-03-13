import 'package:drift/drift.dart';

import '/infraestructura/base_de_datos/base_de_datos.dart';

class BorradoJerarquicoServicio {
  final BaseDeDatos _db;

  BorradoJerarquicoServicio(this._db);

  Future<String> eliminarInstitucion({
    required int institucionId,
    required bool eliminarAlumnosAsociados,
  }) async {
    await _db.transaction(() async {
      final carreraIds = await _idsCarrerasDeInstitucion(institucionId);
      final materiaIds = await _idsMateriasDeCarreras(carreraIds);
      final cursoIds = await _idsCursosRelacionados(
        institucionId: institucionId,
        carreraIds: carreraIds,
        materiaIds: materiaIds,
      );

      final alumnoIds = <int>{
        ...await _idsAlumnosPorInstitucion(institucionId),
        ...await _idsAlumnosPorCarreras(carreraIds),
        ...await _idsAlumnosInscriptosEnCursos(cursoIds),
      };

      if (eliminarAlumnosAsociados) {
        await _eliminarAlumnos(alumnoIds);
      } else {
        await _desasignarAlumnosDeInstitucion(
          institucionId: institucionId,
          carreraIds: carreraIds,
        );
      }

      await _eliminarCursosYDependencias(cursoIds);
      await _eliminarMaterias(materiaIds);
      await _eliminarCarreras(carreraIds);
      await (_db.delete(
        _db.tablaInstituciones,
      )..where((t) => t.id.equals(institucionId))).go();
    });

    return eliminarAlumnosAsociados
        ? 'Institucion eliminada con carreras, materias, cursos y alumnos asociados'
        : 'Institucion eliminada con carreras, materias y cursos. Alumnos conservados sin asignacion';
  }

  Future<String> eliminarCarrera({
    required int carreraId,
    required bool eliminarAlumnosAsociados,
  }) async {
    await _db.transaction(() async {
      final materiaIds = await _idsMateriasDeCarreras({carreraId});
      final cursoIds = await _idsCursosRelacionados(
        carreraIds: {carreraId},
        materiaIds: materiaIds,
      );

      final alumnoIds = <int>{
        ...await _idsAlumnosPorCarreras({carreraId}),
        ...await _idsAlumnosInscriptosEnCursos(cursoIds),
      };

      if (eliminarAlumnosAsociados) {
        await _eliminarAlumnos(alumnoIds);
      } else {
        await (_db.update(_db.tablaAlumnos)
              ..where((t) => t.carreraId.equals(carreraId)))
            .write(const TablaAlumnosCompanion(carreraId: Value(null)));
      }

      await _eliminarCursosYDependencias(cursoIds);
      await _eliminarMaterias(materiaIds);
      await (_db.delete(
        _db.tablaCarreras,
      )..where((t) => t.id.equals(carreraId))).go();
    });

    return eliminarAlumnosAsociados
        ? 'Carrera eliminada con materias, cursos y alumnos asociados'
        : 'Carrera eliminada con materias y cursos. Alumnos conservados sin carrera';
  }

  Future<String> eliminarMateria({
    required int materiaId,
    required bool eliminarAlumnosAsociados,
  }) async {
    await _db.transaction(() async {
      final cursoIds = await _idsCursosPorMateria(materiaId);
      final alumnoIds = await _idsAlumnosInscriptosEnCursos(cursoIds);

      if (eliminarAlumnosAsociados) {
        await _eliminarAlumnos(alumnoIds);
      }

      await _eliminarCursosYDependencias(cursoIds);
      await (_db.delete(
        _db.tablaMaterias,
      )..where((t) => t.id.equals(materiaId))).go();
    });

    return eliminarAlumnosAsociados
        ? 'Materia eliminada con cursos y alumnos asociados'
        : 'Materia eliminada con sus cursos. Alumnos conservados';
  }

  Future<String> eliminarCurso({
    required int cursoId,
    required bool eliminarAlumnosAsociados,
  }) async {
    await _db.transaction(() async {
      final cursoIds = <int>{cursoId};
      final alumnoIds = await _idsAlumnosInscriptosEnCursos(cursoIds);

      if (eliminarAlumnosAsociados) {
        await _eliminarAlumnos(alumnoIds);
      }

      await _eliminarCursosYDependencias(cursoIds);
    });

    return eliminarAlumnosAsociados
        ? 'Curso eliminado con alumnos asociados'
        : 'Curso eliminado. Alumnos conservados sin ese curso';
  }

  Future<Set<int>> _idsCarrerasDeInstitucion(int institucionId) async {
    final rows = await (_db.select(
      _db.tablaCarreras,
    )..where((t) => t.institucionId.equals(institucionId))).get();
    return rows.map((r) => r.id).toSet();
  }

  Future<Set<int>> _idsMateriasDeCarreras(Set<int> carreraIds) async {
    if (carreraIds.isEmpty) return <int>{};
    final rows =
        await (_db.select(_db.tablaMaterias)..where(
              (t) => t.carreraId.isIn(carreraIds.toList(growable: false)),
            ))
            .get();
    return rows.map((r) => r.id).toSet();
  }

  Future<Set<int>> _idsCursosRelacionados({
    int? institucionId,
    Set<int> carreraIds = const <int>{},
    Set<int> materiaIds = const <int>{},
  }) async {
    final out = <int>{};

    if (institucionId != null) {
      final porInstitucion = await (_db.select(
        _db.tablaCursos,
      )..where((t) => t.institucionId.equals(institucionId))).get();
      out.addAll(porInstitucion.map((r) => r.id));
    }

    if (carreraIds.isNotEmpty) {
      final porCarrera =
          await (_db.select(_db.tablaCursos)..where(
                (t) => t.carreraId.isIn(carreraIds.toList(growable: false)),
              ))
              .get();
      out.addAll(porCarrera.map((r) => r.id));
    }

    if (materiaIds.isNotEmpty) {
      final porMateria =
          await (_db.select(_db.tablaCursos)..where(
                (t) => t.materiaId.isIn(materiaIds.toList(growable: false)),
              ))
              .get();
      out.addAll(porMateria.map((r) => r.id));
    }

    return out;
  }

  Future<Set<int>> _idsCursosPorMateria(int materiaId) async {
    final rows = await (_db.select(
      _db.tablaCursos,
    )..where((t) => t.materiaId.equals(materiaId))).get();
    return rows.map((r) => r.id).toSet();
  }

  Future<Set<int>> _idsAlumnosPorInstitucion(int institucionId) async {
    final rows = await (_db.select(
      _db.tablaAlumnos,
    )..where((t) => t.institucionId.equals(institucionId))).get();
    return rows.map((r) => r.id).toSet();
  }

  Future<Set<int>> _idsAlumnosPorCarreras(Set<int> carreraIds) async {
    if (carreraIds.isEmpty) return <int>{};
    final rows =
        await (_db.select(_db.tablaAlumnos)..where(
              (t) => t.carreraId.isIn(carreraIds.toList(growable: false)),
            ))
            .get();
    return rows.map((r) => r.id).toSet();
  }

  Future<Set<int>> _idsAlumnosInscriptosEnCursos(Set<int> cursoIds) async {
    if (cursoIds.isEmpty) return <int>{};
    final rows = await (_db.select(
      _db.tablaInscripciones,
    )..where((t) => t.cursoId.isIn(cursoIds.toList(growable: false)))).get();
    return rows.map((r) => r.alumnoId).toSet();
  }

  Future<void> _eliminarAlumnos(Set<int> alumnoIds) async {
    if (alumnoIds.isEmpty) return;
    await (_db.delete(
      _db.tablaAlumnos,
    )..where((t) => t.id.isIn(alumnoIds.toList(growable: false)))).go();
  }

  Future<void> _desasignarAlumnosDeInstitucion({
    required int institucionId,
    required Set<int> carreraIds,
  }) async {
    await (_db.update(
      _db.tablaAlumnos,
    )..where((t) => t.institucionId.equals(institucionId))).write(
      const TablaAlumnosCompanion(
        institucionId: Value(null),
        carreraId: Value(null),
      ),
    );

    if (carreraIds.isEmpty) return;
    await (_db.update(_db.tablaAlumnos)
          ..where((t) => t.carreraId.isIn(carreraIds.toList(growable: false))))
        .write(const TablaAlumnosCompanion(carreraId: Value(null)));
  }

  Future<void> _eliminarCursosYDependencias(Set<int> cursoIds) async {
    if (cursoIds.isEmpty) return;
    final ids = cursoIds.toList(growable: false);

    final clases = await (_db.select(
      _db.tablaClases,
    )..where((t) => t.cursoId.isIn(ids))).get();
    final claseIds = clases.map((c) => c.id).toList(growable: false);

    if (claseIds.isNotEmpty) {
      await (_db.delete(
        _db.tablaAsistencias,
      )..where((t) => t.claseId.isIn(claseIds))).go();
    }

    for (final cursoId in ids) {
      await (_db.delete(_db.tablaNotasManuales)..where(
            (t) =>
                t.cursoId.equals(cursoId) |
                t.claveContexto.equals('curso:$cursoId'),
          ))
          .go();
    }

    await (_db.delete(
      _db.tablaInscripciones,
    )..where((t) => t.cursoId.isIn(ids))).go();
    await (_db.delete(_db.tablaClases)..where((t) => t.cursoId.isIn(ids))).go();
    await (_db.delete(_db.tablaCursos)..where((t) => t.id.isIn(ids))).go();
  }

  Future<void> _eliminarMaterias(Set<int> materiaIds) async {
    if (materiaIds.isEmpty) return;
    await (_db.delete(
      _db.tablaMaterias,
    )..where((t) => t.id.isIn(materiaIds.toList(growable: false)))).go();
  }

  Future<void> _eliminarCarreras(Set<int> carreraIds) async {
    if (carreraIds.isEmpty) return;
    await (_db.delete(
      _db.tablaCarreras,
    )..where((t) => t.id.isIn(carreraIds.toList(growable: false)))).go();
  }
}
