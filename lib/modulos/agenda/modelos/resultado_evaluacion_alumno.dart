class ResultadoEvaluacionAlumno {
  final int? id;
  final int evaluacionId;
  final int? evaluacionInstanciaId;
  final String instanciaTipo;
  final int instanciaOrden;
  final DateTime? instanciaFecha;
  final int alumnoId;
  final String alumnoNombre;
  final String estado;
  final String? calificacion;
  final bool entregaComplementaria;
  final bool ausenteJustificado;
  final String? observacion;
  final String condicionFinal;
  final String? calificacionVigente;
  final bool elegibleRecuperatorio;

  const ResultadoEvaluacionAlumno({
    required this.id,
    required this.evaluacionId,
    this.evaluacionInstanciaId,
    this.instanciaTipo = 'original',
    this.instanciaOrden = 0,
    this.instanciaFecha,
    required this.alumnoId,
    required this.alumnoNombre,
    required this.estado,
    required this.calificacion,
    required this.entregaComplementaria,
    this.ausenteJustificado = false,
    required this.observacion,
    this.condicionFinal = 'pendiente',
    this.calificacionVigente,
    this.elegibleRecuperatorio = true,
  });
}
