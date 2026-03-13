class EvaluacionInstancia {
  final int id;
  final int evaluacionId;
  final String tipoInstancia;
  final int orden;
  final DateTime fecha;
  final String? observacion;
  final String estado;
  final int resultadosCargados;
  final int aprobados;
  final int noAprobados;
  final int pendientes;
  final int ausentes;

  const EvaluacionInstancia({
    required this.id,
    required this.evaluacionId,
    required this.tipoInstancia,
    required this.orden,
    required this.fecha,
    required this.observacion,
    required this.estado,
    required this.resultadosCargados,
    required this.aprobados,
    required this.noAprobados,
    required this.pendientes,
    required this.ausentes,
  });

  bool get esOriginal => orden == 0;

  bool get cerrada => estado.trim().toLowerCase() == 'cerrada';
}
