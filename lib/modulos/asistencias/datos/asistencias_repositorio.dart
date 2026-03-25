import 'package:drift/drift.dart';

import '/infraestructura/base_de_datos/base_de_datos.dart';
import '/modulos/alumnos/modelos/alumno.dart';
import '/modulos/agenda/modelos/horario_curso.dart';

import '../modelos/clase_asistencia.dart';
import '../modelos/estado_asistencia.dart';
import '../modelos/registro_asistencia_alumno.dart';

class AsistenciasRepositorio {
  final BaseDeDatos _db;

  AsistenciasRepositorio(this._db);

  Future<int> crearClase({
    required int cursoId,
    DateTime? fecha,
    String? tema,
    String? observacion,
    String? actividadDia,
    String? estadoContenido,
    String? resultadoActividad,
    HorarioCurso? horario,
  }) async {
    final horaInicio = _normalizarHora(horario?.horaInicio);
    final horaFin = _normalizarHora(horario?.horaFin);
    final aula = _nullSiVacio(horario?.aula);
    final id = await _db
        .into(_db.tablaClases)
        .insert(
          TablaClasesCompanion.insert(
            cursoId: cursoId,
            fecha: fecha == null ? const Value.absent() : Value(fecha),
            tema: Value(_nullSiVacio(tema)),
            observacion: Value(_nullSiVacio(observacion)),
            actividadDia: Value(_nullSiVacio(actividadDia)),
          ),
        );
    await _db.customStatement(
      '''
      UPDATE tabla_clases
      SET
        estado_contenido = ?,
        resultado_actividad = ?,
        hora_inicio = ?,
        hora_fin = ?,
        aula = ?
      WHERE id = ?
      ''',
      [
        _nullSiVacio(estadoContenido),
        _nullSiVacio(resultadoActividad),
        horaInicio,
        horaFin,
        aula,
        id,
      ],
    );
    return id;
  }

  Future<void> actualizarDetalleClase({
    required int claseId,
    String? tema,
    String? descripcionTema,
    String? actividadDia,
    String? estadoContenido,
    String? resultadoActividad,
  }) {
    return _db.customStatement(
      '''
      UPDATE tabla_clases
      SET
        tema = ?,
        observacion = ?,
        actividad_dia = ?,
        estado_contenido = ?,
        resultado_actividad = ?
      WHERE id = ?
      ''',
      [
        _nullSiVacio(tema),
        _nullSiVacio(descripcionTema),
        _nullSiVacio(actividadDia),
        _nullSiVacio(estadoContenido),
        _nullSiVacio(resultadoActividad),
        claseId,
      ],
    );
  }

  Future<List<ClaseAsistencia>> listarClasesDeCurso(
    int cursoId, {
    int limite = 30,
  }) async {
    final rows = await _db
        .customSelect(
          '''
      SELECT
        id,
        curso_id,
        fecha,
        tema,
        observacion,
        actividad_dia,
        estado_contenido,
        resultado_actividad,
        hora_inicio,
        hora_fin,
        aula
      FROM tabla_clases
      WHERE curso_id = ?
      ORDER BY
        fecha DESC,
        CASE
          WHEN hora_inicio IS NULL OR TRIM(hora_inicio) = '' THEN 1
          ELSE 0
        END ASC,
        hora_inicio ASC,
        id DESC
      LIMIT ?
      ''',
          variables: [Variable<int>(cursoId), Variable<int>(limite)],
        )
        .get();
    return rows
        .map(
          (r) => ClaseAsistencia(
            id: r.read<int>('id'),
            cursoId: r.read<int>('curso_id'),
            fecha: _fechaDesdeEpoch(r.read<int>('fecha')),
            tema: r.read<String?>('tema'),
            observacion: r.read<String?>('observacion'),
            actividadDia: r.read<String?>('actividad_dia'),
            estadoContenido: r.read<String?>('estado_contenido'),
            resultadoActividad: r.read<String?>('resultado_actividad'),
            horaInicio: r.read<String?>('hora_inicio'),
            horaFin: r.read<String?>('hora_fin'),
            aula: r.read<String?>('aula'),
          ),
        )
        .toList();
  }

  Future<List<HorarioCurso>> listarHorariosCursoParaFecha({
    required int cursoId,
    required DateTime fecha,
  }) async {
    final rows = await _db
        .customSelect(
          '''
      SELECT id, curso_id, dia_semana, hora_inicio, hora_fin, aula
      FROM tabla_horarios_curso
      WHERE curso_id = ? AND activo = 1 AND dia_semana = ?
      ORDER BY hora_inicio ASC, id ASC
      ''',
          variables: [Variable<int>(cursoId), Variable<int>(fecha.weekday)],
        )
        .get();

    return rows
        .map(
          (row) => HorarioCurso(
            id: row.read<int>('id'),
            cursoId: row.read<int>('curso_id'),
            diaSemana: row.read<int>('dia_semana'),
            horaInicio: row.read<String>('hora_inicio'),
            horaFin: row.read<String?>('hora_fin'),
            aula: row.read<String?>('aula'),
          ),
        )
        .toList(growable: false);
  }

  Future<List<Alumno>> listarAlumnosDeCurso(int cursoId) async {
    final q = _db.select(_db.tablaAlumnos).join([
      innerJoin(
        _db.tablaInscripciones,
        _db.tablaInscripciones.alumnoId.equalsExp(_db.tablaAlumnos.id) &
            _db.tablaInscripciones.cursoId.equals(cursoId) &
            _db.tablaInscripciones.activo.equals(true) &
            _db.tablaAlumnos.activo.equals(true),
      ),
      leftOuterJoin(
        _db.tablaInstituciones,
        _db.tablaInstituciones.id.equalsExp(_db.tablaAlumnos.institucionId),
      ),
      leftOuterJoin(
        _db.tablaCarreras,
        _db.tablaCarreras.id.equalsExp(_db.tablaAlumnos.carreraId),
      ),
    ]);

    final rows = await q.get();
    return rows.map((row) {
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
    }).toList()..sort((a, b) => a.nombreCompleto.compareTo(b.nombreCompleto));
  }

  Future<List<RegistroAsistenciaAlumno>> cargarPlanillaClase({
    required int cursoId,
    required int claseId,
  }) async {
    final alumnos = await listarAlumnosDeCurso(cursoId);

    final asistencias = await (_db.select(
      _db.tablaAsistencias,
    )..where((t) => t.claseId.equals(claseId))).get();
    final porAlumnoId = {for (final a in asistencias) a.alumnoId: a};

    return alumnos.map((alumno) {
      final row = porAlumnoId[alumno.id];
      return RegistroAsistenciaAlumno(
        alumno: alumno,
        estado: EstadoAsistenciaX.fromCode(row?.estado),
        observacion: row?.observacion,
        justificada: row?.justificada ?? false,
        detalleJustificacion: row?.detalleJustificacion,
        actividadEntregada: row?.actividadEntregada ?? false,
        notaActividad: row?.notaActividad,
        detalleActividad: row?.detalleActividad,
      );
    }).toList();
  }

  Future<void> registrarAsistencia({
    required int claseId,
    required int alumnoId,
    required String estado,
    String? observacion,
  }) {
    final estadoNormalizado = estado.trim().isEmpty
        ? 'pendiente'
        : estado.trim();
    return _db
        .into(_db.tablaAsistencias)
        .insert(
          TablaAsistenciasCompanion.insert(
            claseId: claseId,
            alumnoId: alumnoId,
            estado: Value(estadoNormalizado),
            observacion: Value(_nullSiVacio(observacion)),
          ),
          onConflict: DoUpdate(
            (old) => TablaAsistenciasCompanion(
              estado: Value(estadoNormalizado),
              observacion: Value(_nullSiVacio(observacion)),
              registradoEn: Value(DateTime.now()),
            ),
            target: [
              _db.tablaAsistencias.claseId,
              _db.tablaAsistencias.alumnoId,
            ],
          ),
        );
  }

  Future<void> registrarEstadoAsistencia({
    required int claseId,
    required int alumnoId,
    required EstadoAsistencia estado,
    String? observacion,
  }) {
    return registrarAsistencia(
      claseId: claseId,
      alumnoId: alumnoId,
      estado: estado.code,
      observacion: observacion,
    );
  }

  Future<void> guardarDetalleAlumnoClase({
    required int claseId,
    required int alumnoId,
    required EstadoAsistencia estadoActual,
    required bool justificada,
    String? detalleJustificacion,
    required bool actividadEntregada,
    String? notaActividad,
    String? detalleActividad,
  }) {
    return _db
        .into(_db.tablaAsistencias)
        .insert(
          TablaAsistenciasCompanion.insert(
            claseId: claseId,
            alumnoId: alumnoId,
            estado: Value(estadoActual.code),
            justificada: Value(justificada),
            detalleJustificacion: Value(_nullSiVacio(detalleJustificacion)),
            actividadEntregada: Value(actividadEntregada),
            notaActividad: Value(_nullSiVacio(notaActividad)),
            detalleActividad: Value(_nullSiVacio(detalleActividad)),
          ),
          onConflict: DoUpdate(
            (old) => TablaAsistenciasCompanion(
              justificada: Value(justificada),
              detalleJustificacion: Value(_nullSiVacio(detalleJustificacion)),
              actividadEntregada: Value(actividadEntregada),
              notaActividad: Value(_nullSiVacio(notaActividad)),
              detalleActividad: Value(_nullSiVacio(detalleActividad)),
              registradoEn: Value(DateTime.now()),
            ),
            target: [
              _db.tablaAsistencias.claseId,
              _db.tablaAsistencias.alumnoId,
            ],
          ),
        );
  }

  Future<void> marcarEstadoParaTodos({
    required int claseId,
    required int cursoId,
    required EstadoAsistencia estado,
  }) async {
    final alumnos = await listarAlumnosDeCurso(cursoId);
    await _db.transaction(() async {
      for (final alumno in alumnos) {
        await registrarEstadoAsistencia(
          claseId: claseId,
          alumnoId: alumno.id,
          estado: estado,
        );
      }
    });
  }

  Future<void> marcarTodosPresentes({
    required int claseId,
    required int cursoId,
  }) {
    return marcarEstadoParaTodos(
      claseId: claseId,
      cursoId: cursoId,
      estado: EstadoAsistencia.presente,
    );
  }

  Future<void> eliminarClase(int claseId) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.tablaAsistencias,
      )..where((t) => t.claseId.equals(claseId))).go();
      await (_db.delete(
        _db.tablaClases,
      )..where((t) => t.id.equals(claseId))).go();
    });
  }

  String? _nullSiVacio(String? value) {
    final t = (value ?? '').trim();
    return t.isEmpty ? null : t;
  }

  String? _normalizarHora(String? value) {
    final t = (value ?? '').trim();
    if (t.isEmpty) return null;
    final regex = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$');
    if (!regex.hasMatch(t)) return null;
    return t;
  }

  DateTime _fechaDesdeEpoch(int epochSegundos) {
    return DateTime.fromMillisecondsSinceEpoch(epochSegundos * 1000);
  }
}
