import 'package:drift/drift.dart';

import '/infraestructura/base_de_datos/base_de_datos.dart';

import '../modelos/resumen_asistencia.dart';

class ReportesAsistenciaRepositorio {
  final BaseDeDatos _db;

  ReportesAsistenciaRepositorio(this._db);

  Future<List<ResumenAsistenciaAlumno>> porcentajePorAlumno({
    required int cursoId,
    required int meses,
  }) async {
    final desde = _inicioRangoMeses(meses);

    final inscripcionesJoin = _db.select(_db.tablaAlumnos).join([
      innerJoin(
        _db.tablaInscripciones,
        _db.tablaInscripciones.alumnoId.equalsExp(_db.tablaAlumnos.id) &
            _db.tablaInscripciones.cursoId.equals(cursoId) &
            _db.tablaInscripciones.activo.equals(true),
      ),
    ]);

    final alumnosRows = await inscripcionesJoin.get();
    final alumnos = <int, ({String apellido, String nombre})>{};

    for (final row in alumnosRows) {
      final a = row.readTable(_db.tablaAlumnos);
      alumnos[a.id] = (apellido: a.apellido, nombre: a.nombre);
    }

    if (alumnos.isEmpty) return const [];

    final clases =
        await (_db.select(_db.tablaClases)..where(
              (t) =>
                  t.cursoId.equals(cursoId) &
                  t.fecha.isBiggerOrEqualValue(desde),
            ))
            .get();

    if (clases.isEmpty) {
      return alumnos.entries
          .map(
            (e) => ResumenAsistenciaAlumno(
              alumnoId: e.key,
              apellido: e.value.apellido,
              nombre: e.value.nombre,
              presentes: 0,
              ausentes: 0,
              tardes: 0,
              justificadas: 0,
            ),
          )
          .toList()
        ..sort(_compararAlumno);
    }

    final claseIds = clases.map((c) => c.id).toSet().toList();
    final asistencias = await (_db.select(
      _db.tablaAsistencias,
    )..where((a) => a.claseId.isIn(claseIds))).get();

    final presentesPorAlumno = <int, int>{};
    final ausentesPorAlumno = <int, int>{};
    final tardesPorAlumno = <int, int>{};
    final justifPorAlumno = <int, int>{};

    for (final a in asistencias) {
      if (!alumnos.containsKey(a.alumnoId)) continue;

      final estado = a.estado.trim().toLowerCase();
      if (estado == 'ausente') {
        ausentesPorAlumno[a.alumnoId] =
            (ausentesPorAlumno[a.alumnoId] ?? 0) + 1;
      } else if (estado == 'tarde') {
        tardesPorAlumno[a.alumnoId] = (tardesPorAlumno[a.alumnoId] ?? 0) + 1;
      } else if (estado == 'justificada') {
        justifPorAlumno[a.alumnoId] = (justifPorAlumno[a.alumnoId] ?? 0) + 1;
      } else if (estado == 'presente') {
        presentesPorAlumno[a.alumnoId] =
            (presentesPorAlumno[a.alumnoId] ?? 0) + 1;
      }
    }

    final out = <ResumenAsistenciaAlumno>[];
    for (final e in alumnos.entries) {
      final alumnoId = e.key;
      out.add(
        ResumenAsistenciaAlumno(
          alumnoId: alumnoId,
          apellido: e.value.apellido,
          nombre: e.value.nombre,
          presentes: presentesPorAlumno[alumnoId] ?? 0,
          ausentes: ausentesPorAlumno[alumnoId] ?? 0,
          tardes: tardesPorAlumno[alumnoId] ?? 0,
          justificadas: justifPorAlumno[alumnoId] ?? 0,
        ),
      );
    }

    out.sort(_compararAlumno);
    return out;
  }

  Future<List<ResumenAsistenciaMensual>> resumenMensual({
    required int cursoId,
    required int meses,
  }) async {
    final mesesSeguros = meses.clamp(1, 36).toInt();
    final ahora = DateTime.now();
    final inicioMesActual = DateTime(ahora.year, ahora.month);
    final desde = _sumarMeses(inicioMesActual, -(mesesSeguros - 1));

    final clases =
        await (_db.select(_db.tablaClases)..where(
              (t) =>
                  t.cursoId.equals(cursoId) &
                  t.fecha.isBiggerOrEqualValue(desde),
            ))
            .get();

    final clasesPorPeriodo = <String, int>{};
    final periodoPorClaseId = <int, String>{};

    for (final c in clases) {
      final key = _periodoKey(c.fecha);
      clasesPorPeriodo[key] = (clasesPorPeriodo[key] ?? 0) + 1;
      periodoPorClaseId[c.id] = key;
    }

    final presentesPorPeriodo = <String, int>{};
    final ausentesPorPeriodo = <String, int>{};
    final tardesPorPeriodo = <String, int>{};
    final justifPorPeriodo = <String, int>{};

    if (periodoPorClaseId.isNotEmpty) {
      final asistencias = await (_db.select(
        _db.tablaAsistencias,
      )..where((a) => a.claseId.isIn(periodoPorClaseId.keys.toList()))).get();

      for (final a in asistencias) {
        final periodo = periodoPorClaseId[a.claseId];
        if (periodo == null) continue;

        final estado = a.estado.trim().toLowerCase();
        if (estado == 'ausente') {
          ausentesPorPeriodo[periodo] = (ausentesPorPeriodo[periodo] ?? 0) + 1;
        } else if (estado == 'tarde') {
          tardesPorPeriodo[periodo] = (tardesPorPeriodo[periodo] ?? 0) + 1;
        } else if (estado == 'justificada') {
          justifPorPeriodo[periodo] = (justifPorPeriodo[periodo] ?? 0) + 1;
        } else if (estado == 'presente') {
          presentesPorPeriodo[periodo] =
              (presentesPorPeriodo[periodo] ?? 0) + 1;
        }
      }
    }

    final out = <ResumenAsistenciaMensual>[];
    for (int i = 0; i < mesesSeguros; i++) {
      final mes = _sumarMeses(desde, i);
      final key = _periodoKey(mes);
      out.add(
        ResumenAsistenciaMensual(
          mes: mes,
          clases: clasesPorPeriodo[key] ?? 0,
          presentes: presentesPorPeriodo[key] ?? 0,
          ausentes: ausentesPorPeriodo[key] ?? 0,
          tardes: tardesPorPeriodo[key] ?? 0,
          justificadas: justifPorPeriodo[key] ?? 0,
        ),
      );
    }

    return out;
  }

  DateTime _inicioRangoMeses(int meses) {
    final mesesSeguros = meses.clamp(1, 36).toInt();
    final ahora = DateTime.now();
    final inicioMesActual = DateTime(ahora.year, ahora.month);
    return _sumarMeses(inicioMesActual, -(mesesSeguros - 1));
  }

  DateTime _sumarMeses(DateTime base, int delta) {
    final totalMeses = base.year * 12 + (base.month - 1) + delta;
    final year = totalMeses ~/ 12;
    final month = (totalMeses % 12) + 1;
    return DateTime(year, month);
  }

  String _periodoKey(DateTime fecha) {
    final mm = fecha.month.toString().padLeft(2, '0');
    return '${fecha.year}-$mm';
  }

  int _compararAlumno(ResumenAsistenciaAlumno a, ResumenAsistenciaAlumno b) {
    final por = b.porcentajeAsistencia.compareTo(a.porcentajeAsistencia);
    if (por != 0) return por;

    final ap = a.apellido.toLowerCase().compareTo(b.apellido.toLowerCase());
    if (ap != 0) return ap;

    return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
  }
}
