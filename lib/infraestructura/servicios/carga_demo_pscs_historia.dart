import 'package:drift/drift.dart';

import '/infraestructura/base_de_datos/base_de_datos.dart';
import '/infraestructura/dep_inyeccion/proveedores.dart';
import '/modulos/asistencias/modelos/estado_asistencia.dart';
import '/modulos/cursos/datos/cursos_repositorio.dart';

class CargaDemoPscsHistoria {
  CargaDemoPscsHistoria._();

  static const String _institucionNombre = 'PSCS';
  static const String _carreraNombre = 'Historia';
  static const String _materiaNombreDemo =
      'Procesos Sociales, Politicos, Economicos y Culturales de la Antiguedad [DEMO]';
  static const int _anioCursadaDemo = 2;
  static const String _cursoDemo = 'A';
  static const int _anioLectivoDemo = 2031;
  static const String _tagDemo = 'demo_pscs_historia_v1';
  static final DateTime _fechaInicio = DateTime(2026, 3, 11);

  static const List<({String apellido, String nombre, int edad})> _alumnosDemo =
      [
        (apellido: 'Bondaz', nombre: 'Pablo German', edad: 26),
        (apellido: 'Delmenico Zabala', nombre: 'Agustin Ramon', edad: 24),
        (apellido: 'Devoto Franco', nombre: 'Rocio', edad: 23),
        (apellido: 'Diaz Siro', nombre: 'Sebastian', edad: 25),
        (apellido: 'Gaitan Lopez', nombre: 'Roque Mario', edad: 30),
        (apellido: 'Galeano', nombre: 'Ludmila', edad: 24),
        (apellido: 'Krauel', nombre: 'Luciano', edad: 22),
        (apellido: 'Lucenti', nombre: 'Santiago Francisco', edad: 24),
        (apellido: 'Maciel', nombre: 'Ailen Maria', edad: 23),
        (apellido: 'Muller', nombre: 'Tobias Manuel', edad: 25),
        (apellido: 'Pereyra Ramirez', nombre: 'Juan Martin', edad: 24),
        (apellido: 'Perez', nombre: 'Mariel Silvana', edad: 29),
        (apellido: 'Romero', nombre: 'Nicolas', edad: 23),
        (apellido: 'Vilche Gomez', nombre: 'Rebeca', edad: 22),
        (apellido: 'Villalba', nombre: 'Luciano Emanuel', edad: 24),
        (apellido: 'Zampedri', nombre: 'Jennifer Candela', edad: 23),
      ];

  static Future<String> cargarDemo() async {
    await limpiarDemo();

    final institucionesRepo = Proveedores.institucionesRepositorio;
    final cursosRepo = Proveedores.cursosRepositorio;
    final alumnosRepo = Proveedores.alumnosRepositorio;
    final asistenciasRepo = Proveedores.asistenciasRepositorio;
    final db = Proveedores.baseDeDatos;

    await institucionesRepo.crearInstitucion(_institucionNombre);
    final institucionId = await _buscarInstitucionId(db, _institucionNombre);

    await institucionesRepo.crearCarrera(
      institucionId: institucionId,
      nombre: _carreraNombre,
    );
    final carreraId = await _buscarCarreraId(
      db: db,
      institucionId: institucionId,
      nombre: _carreraNombre,
    );

    final materiaId = await institucionesRepo.crearMateria(
      carreraId: carreraId,
      nombre: _materiaNombreDemo,
      anioCursada: _anioCursadaDemo,
    );

    final cursoId = await _buscarOCrearCursoDemo(
      db: db,
      cursosRepo: cursosRepo,
      institucionId: institucionId,
      carreraId: carreraId,
      materiaId: materiaId,
    );

    for (final a in _alumnosDemo) {
      final alumnoId = await alumnosRepo.crear(
        apellido: a.apellido,
        nombre: a.nombre,
        institucionId: institucionId,
        carreraId: carreraId,
        edad: a.edad,
        telefono: _tagDemo,
      );
      await cursosRepo.inscribirAlumno(cursoId: cursoId, alumnoId: alumnoId);
    }

    for (var i = 0; i < 10; i++) {
      final fecha = _fechaInicio.add(Duration(days: i * 7));
      final claseId = await asistenciasRepo.crearClase(
        cursoId: cursoId,
        fecha: fecha,
        tema: 'Clase programada ${i + 1}',
        observacion: _tagDemo,
      );
      await asistenciasRepo.marcarEstadoParaTodos(
        claseId: claseId,
        cursoId: cursoId,
        estado: EstadoAsistencia.pendiente,
      );
    }

    return 'Demo PSCS Historia cargado: 16 alumnos y 10 clases';
  }

  static Future<String> limpiarDemo() async {
    final db = Proveedores.baseDeDatos;

    await db.customStatement(
      'DELETE FROM tabla_notas_manuales WHERE alumno_id IN (SELECT id FROM tabla_alumnos WHERE telefono = ?)',
      [_tagDemo],
    );
    await db.customStatement('DELETE FROM tabla_alumnos WHERE telefono = ?', [
      _tagDemo,
    ]);

    final materias = await db
        .customSelect(
          '''
      SELECT id
      FROM tabla_materias
      WHERE lower(trim(nombre)) = lower(trim(?))
      ''',
          variables: [Variable<String>(_materiaNombreDemo)],
        )
        .get();

    if (materias.isNotEmpty) {
      final materiaIds = materias.map((r) => r.read<int>('id')).toList();
      final inMaterias = materiaIds.join(',');
      final cursosRows = await db.customSelect('''
        SELECT id
        FROM tabla_cursos
        WHERE materia_id IN ($inMaterias)
        ''').get();
      if (cursosRows.isNotEmpty) {
        final cursoIds = cursosRows.map((r) => r.read<int>('id')).join(',');
        await db.customStatement('''
          DELETE FROM tabla_asistencias
          WHERE clase_id IN (SELECT id FROM tabla_clases WHERE curso_id IN ($cursoIds))
        ''');
        await db.customStatement(
          'DELETE FROM tabla_clases WHERE curso_id IN ($cursoIds)',
        );
        await db.customStatement(
          'DELETE FROM tabla_inscripciones WHERE curso_id IN ($cursoIds)',
        );
        await db.customStatement(
          'DELETE FROM tabla_cursos WHERE id IN ($cursoIds)',
        );
      }

      await db.customStatement(
        'DELETE FROM tabla_materias WHERE id IN ($inMaterias)',
      );
    }

    return 'Demo PSCS Historia eliminado';
  }

  static Future<int> _buscarInstitucionId(BaseDeDatos db, String nombre) async {
    final row = await db
        .customSelect(
          '''
      SELECT id
      FROM tabla_instituciones
      WHERE lower(trim(nombre)) = lower(trim(?))
      ORDER BY id
      LIMIT 1
      ''',
          variables: [Variable<String>(nombre)],
        )
        .getSingle();
    return row.read<int>('id');
  }

  static Future<int> _buscarCarreraId({
    required BaseDeDatos db,
    required int institucionId,
    required String nombre,
  }) async {
    final row = await db
        .customSelect(
          '''
      SELECT id
      FROM tabla_carreras
      WHERE institucion_id = ?
        AND lower(trim(nombre)) = lower(trim(?))
      ORDER BY id
      LIMIT 1
      ''',
          variables: [Variable<int>(institucionId), Variable<String>(nombre)],
        )
        .getSingle();
    return row.read<int>('id');
  }

  static Future<int> _buscarOCrearCursoDemo({
    required BaseDeDatos db,
    required CursosRepositorio cursosRepo,
    required int institucionId,
    required int carreraId,
    required int materiaId,
  }) async {
    final existente = await db
        .customSelect(
          '''
      SELECT id
      FROM tabla_cursos
      WHERE institucion_id = ?
        AND carrera_id = ?
        AND materia_id = ?
        AND anio = ?
        AND upper(trim(coalesce(division, ''))) = ?
      ORDER BY id DESC
      LIMIT 1
      ''',
          variables: [
            Variable<int>(institucionId),
            Variable<int>(carreraId),
            Variable<int>(materiaId),
            Variable<int>(_anioLectivoDemo),
            Variable<String>(_cursoDemo),
          ],
        )
        .getSingleOrNull();

    if (existente != null) {
      return existente.read<int>('id');
    }

    return cursosRepo.crear(
      institucionId: institucionId,
      carreraId: carreraId,
      materiaId: materiaId,
      division: _cursoDemo,
      anioLectivo: _anioLectivoDemo,
    );
  }
}
