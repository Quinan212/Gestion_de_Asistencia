import 'package:drift/drift.dart';

import '/infraestructura/base_de_datos/base_de_datos.dart';
import '../modelos/alumno.dart';
import '../modelos/alumno_organizado.dart';

class AlumnosRepositorio {
  final BaseDeDatos _db;

  AlumnosRepositorio(this._db);

  Future<List<Alumno>> listar({
    bool incluirInactivos = false,
    int? institucionId,
    int? carreraId,
  }) async {
    final q = _db.select(_db.tablaAlumnos).join([
      leftOuterJoin(
        _db.tablaInstituciones,
        _db.tablaInstituciones.id.equalsExp(_db.tablaAlumnos.institucionId),
      ),
      leftOuterJoin(
        _db.tablaCarreras,
        _db.tablaCarreras.id.equalsExp(_db.tablaAlumnos.carreraId),
      ),
    ]);

    final filtros = <Expression<bool>>[];
    if (!incluirInactivos) {
      filtros.add(_db.tablaAlumnos.activo.equals(true));
    }
    if (institucionId != null) {
      filtros.add(_db.tablaAlumnos.institucionId.equals(institucionId));
    }
    if (carreraId != null) {
      filtros.add(_db.tablaAlumnos.carreraId.equals(carreraId));
    }
    if (filtros.isNotEmpty) {
      Expression<bool> cond = filtros.first;
      for (int i = 1; i < filtros.length; i++) {
        cond = cond & filtros[i];
      }
      q.where(cond);
    }

    q.orderBy([
      OrderingTerm.asc(_db.tablaAlumnos.apellido),
      OrderingTerm.asc(_db.tablaAlumnos.nombre),
    ]);

    final rows = await q.get();
    return rows.map(_mapFromJoin).toList(growable: false);
  }

  Future<List<Alumno>> listarDisponiblesParaCurso({
    required int institucionId,
    required int carreraId,
  }) async {
    final rows =
        await (_db.select(_db.tablaAlumnos).join([
              leftOuterJoin(
                _db.tablaInstituciones,
                _db.tablaInstituciones.id.equalsExp(
                  _db.tablaAlumnos.institucionId,
                ),
              ),
              leftOuterJoin(
                _db.tablaCarreras,
                _db.tablaCarreras.id.equalsExp(_db.tablaAlumnos.carreraId),
              ),
            ])..where(
              _db.tablaAlumnos.activo.equals(true) &
                  (_db.tablaAlumnos.institucionId.equals(institucionId) &
                          _db.tablaAlumnos.carreraId.equals(carreraId) |
                      _db.tablaAlumnos.institucionId.isNull() |
                      _db.tablaAlumnos.carreraId.isNull()),
            ))
            .get();

    final alumnos = rows.map(_mapFromJoin).toList(growable: false);
    alumnos.sort((a, b) {
      final aMismaCarrera =
          a.institucionId == institucionId && a.carreraId == carreraId;
      final bMismaCarrera =
          b.institucionId == institucionId && b.carreraId == carreraId;
      if (aMismaCarrera != bMismaCarrera) {
        return aMismaCarrera ? -1 : 1;
      }
      final cmpApellido = a.apellido.toLowerCase().compareTo(
        b.apellido.toLowerCase(),
      );
      if (cmpApellido != 0) return cmpApellido;
      return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
    });
    return alumnos;
  }

  Future<int> crear({
    required String apellido,
    required String nombre,
    required int institucionId,
    required int carreraId,
    int? edad,
    String? documento,
    String? email,
    String? telefono,
  }) {
    return _db
        .into(_db.tablaAlumnos)
        .insert(
          TablaAlumnosCompanion.insert(
            apellido: apellido.trim(),
            nombre: nombre.trim(),
            edad: Value(edad),
            documento: Value(_nullSiVacio(documento)),
            email: Value(_nullSiVacio(email)),
            telefono: Value(_nullSiVacio(telefono)),
            institucionId: Value(institucionId),
            carreraId: Value(carreraId),
          ),
        );
  }

  Future<void> actualizarActivo({required int alumnoId, required bool activo}) {
    return (_db.update(_db.tablaAlumnos)..where((t) => t.id.equals(alumnoId)))
        .write(TablaAlumnosCompanion(activo: Value(activo)));
  }

  Future<void> actualizarFoto({
    required int alumnoId,
    required String? fotoPath,
  }) {
    return (_db.update(_db.tablaAlumnos)..where((t) => t.id.equals(alumnoId)))
        .write(TablaAlumnosCompanion(fotoPath: Value(_nullSiVacio(fotoPath))));
  }

  Future<void> eliminar({required int alumnoId}) {
    return (_db.delete(
      _db.tablaAlumnos,
    )..where((t) => t.id.equals(alumnoId))).go();
  }

  String? _nullSiVacio(String? value) {
    final t = (value ?? '').trim();
    return t.isEmpty ? null : t;
  }

  Alumno _mapFromJoin(TypedResult row) {
    final a = row.readTable(_db.tablaAlumnos);
    final i = row.readTableOrNull(_db.tablaInstituciones);
    final c = row.readTableOrNull(_db.tablaCarreras);
    return Alumno(
      id: a.id,
      apellido: a.apellido,
      nombre: a.nombre,
      edad: a.edad,
      documento: a.documento,
      email: a.email,
      telefono: a.telefono,
      fotoPath: a.fotoPath,
      institucionId: a.institucionId,
      carreraId: a.carreraId,
      institucionNombre: i?.nombre,
      carreraNombre: c?.nombre,
      activo: a.activo,
      creadoEn: a.creadoEn,
    );
  }

  Future<List<AlumnoOrganizado>> listarParaOrganizar() async {
    final rows = await _db.customSelect('''
      SELECT
        a.id AS alumno_id,
        c.id AS curso_id,
        a.apellido AS apellido,
        a.nombre AS nombre,
        a.edad AS edad,
        COALESCE(nm.nota, '') AS nota_manual,
        COALESCE(NULLIF(TRIM(i.nombre), ''), 'Sin institucion') AS institucion,
        COALESCE(NULLIF(TRIM(ca.nombre), ''), 'Sin carrera') AS carrera,
        COALESCE(
          NULLIF(TRIM(m.nombre), ''),
          NULLIF(TRIM(c.materia), ''),
          'Sin materia'
        ) AS materia,
        COALESCE(
          m.anio_cursada,
          CAST(NULLIF(TRIM(c.nombre), '') AS INTEGER),
          0
        ) AS anio_cursada,
        COALESCE(
          NULLIF(TRIM(c.division), ''),
          'Sin curso'
        ) AS curso,
        COALESCE(c.anio, 0) AS anio_lectivo,
        a.id AS orden_ingreso
      FROM tabla_alumnos a
      LEFT JOIN tabla_instituciones i
        ON i.id = a.institucion_id
      LEFT JOIN tabla_carreras ca
        ON ca.id = a.carrera_id
      LEFT JOIN tabla_inscripciones ins
        ON ins.alumno_id = a.id AND ins.activo = 1
      LEFT JOIN tabla_cursos c
        ON c.id = ins.curso_id
      LEFT JOIN tabla_materias m
        ON m.id = c.materia_id
      LEFT JOIN tabla_notas_manuales nm
        ON nm.alumno_id = a.id
       AND nm.clave_contexto = CASE
         WHEN c.id IS NULL THEN 'suelto'
         ELSE 'curso:' || CAST(c.id AS TEXT)
       END
      WHERE a.activo = 1
      ORDER BY
        institucion ASC,
        carrera ASC,
        materia ASC,
        anio_cursada ASC,
        curso ASC,
        anio_lectivo ASC,
        apellido ASC,
        nombre ASC
      ''').get();

    return rows
        .map((row) {
          return AlumnoOrganizado(
            alumnoId: row.read<int>('alumno_id'),
            cursoId: row.read<int?>('curso_id'),
            apellido: row.read<String>('apellido'),
            nombre: row.read<String>('nombre'),
            edad: row.read<int?>('edad'),
            notaManual: row.read<String>('nota_manual'),
            institucion: row.read<String>('institucion'),
            carrera: row.read<String>('carrera'),
            materia: row.read<String>('materia'),
            anioCursada: row.read<int>('anio_cursada'),
            curso: row.read<String>('curso'),
            anioLectivo: row.read<int>('anio_lectivo'),
            ordenIngreso: row.read<int>('orden_ingreso'),
          );
        })
        .toList(growable: false);
  }

  Future<void> guardarNotaManual({
    required int alumnoId,
    required int? cursoId,
    required String nota,
  }) async {
    final notaLimpia = nota.trim();
    final claveContexto = _claveContextoNota(cursoId);
    final ahora = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _db.customStatement(
      '''
      INSERT INTO tabla_notas_manuales (
        alumno_id,
        curso_id,
        clave_contexto,
        nota,
        actualizado_en
      ) VALUES (?, ?, ?, ?, ?)
      ON CONFLICT(alumno_id, clave_contexto)
      DO UPDATE SET
        curso_id = excluded.curso_id,
        nota = excluded.nota,
        actualizado_en = excluded.actualizado_en
      ''',
      [alumnoId, cursoId, claveContexto, notaLimpia, ahora],
    );
  }

  String _claveContextoNota(int? cursoId) {
    if (cursoId == null) return 'suelto';
    return 'curso:$cursoId';
  }
}
