class PendienteAccionableDocente {
  final String tipo;
  final String prioridad;
  final DateTime fecha;
  final int? cursoId;
  final int? alumnoId;
  final String institucion;
  final String materia;
  final String etiquetaCurso;
  final String titulo;
  final String detalle;
  final String accionSugerida;

  const PendienteAccionableDocente({
    required this.tipo,
    required this.prioridad,
    required this.fecha,
    required this.cursoId,
    required this.alumnoId,
    required this.institucion,
    required this.materia,
    required this.etiquetaCurso,
    required this.titulo,
    required this.detalle,
    required this.accionSugerida,
  });
}

class PanelPendientesAccionables {
  final DateTime fechaReferencia;
  final int evaluacionesPorCerrar;
  final int entregasPorCorregir;
  final int alumnosEnRiesgo;
  final int clasesIncompletas;
  final int acuerdosAbiertos;
  final int alertasSinRevisar;
  final List<PendienteAccionableDocente> pendientes;

  const PanelPendientesAccionables({
    required this.fechaReferencia,
    required this.evaluacionesPorCerrar,
    required this.entregasPorCorregir,
    required this.alumnosEnRiesgo,
    required this.clasesIncompletas,
    required this.acuerdosAbiertos,
    required this.alertasSinRevisar,
    required this.pendientes,
  });

  int get total =>
      evaluacionesPorCerrar +
      entregasPorCorregir +
      alumnosEnRiesgo +
      clasesIncompletas +
      acuerdosAbiertos +
      alertasSinRevisar;
}
