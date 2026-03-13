part of 'agenda_docente_repositorio.dart';

class _CursoAgendaBase {
  final int id;
  final String institucion;
  final String carrera;
  final String materia;
  final String etiquetaCurso;

  const _CursoAgendaBase({
    required this.id,
    required this.institucion,
    required this.carrera,
    required this.materia,
    required this.etiquetaCurso,
  });
}

class _PendientesClase {
  final int alumnosPendientes;
  final int actividadesSinEntregar;

  const _PendientesClase({
    required this.alumnosPendientes,
    required this.actividadesSinEntregar,
  });
}

class _AsistenciaComparada {
  int totalActual = 0;
  int presentesActual = 0;
  int totalAnterior = 0;
  int presentesAnterior = 0;
}

class _HistorialStats {
  final int alumnoId;
  final String alumnoNombre;

  int faltas = 0;
  int inasistenciasConsecutivas = 0;
  int actividadesSinEntregar = 0;
  int intervencionesAbiertas = 0;
  int intervencionesTotales = 0;
  int evaluacionesPendientes = 0;
  int evaluacionesEnProceso = 0;
  int evaluacionesAprobadas = 0;
  int evaluacionesRecuperacion = 0;
  bool mejoraReciente = false;

  _HistorialStats({required this.alumnoId, required this.alumnoNombre});
}
