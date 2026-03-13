class HistorialAlumnoInteligente {
  final int alumnoId;
  final String alumnoNombre;
  final int faltas;
  final int inasistenciasConsecutivas;
  final int actividadesSinEntregar;
  final int intervencionesAbiertas;
  final int intervencionesTotales;
  final int evaluacionesPendientes;
  final int evaluacionesEnProceso;
  final int evaluacionesAprobadas;
  final int evaluacionesRecuperacion;
  final bool mejoraReciente;
  final String nivelRiesgo;
  final String resumen;

  const HistorialAlumnoInteligente({
    required this.alumnoId,
    required this.alumnoNombre,
    required this.faltas,
    required this.inasistenciasConsecutivas,
    required this.actividadesSinEntregar,
    required this.intervencionesAbiertas,
    required this.intervencionesTotales,
    required this.evaluacionesPendientes,
    required this.evaluacionesEnProceso,
    required this.evaluacionesAprobadas,
    required this.evaluacionesRecuperacion,
    required this.mejoraReciente,
    required this.nivelRiesgo,
    required this.resumen,
  });

  bool get requiereAcompanamiento => nivelRiesgo != 'bajo';
}
