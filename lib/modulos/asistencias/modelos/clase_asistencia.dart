class ClaseAsistencia {
  final int id;
  final int cursoId;
  final DateTime fecha;
  final String? tema;
  final String? observacion;
  final String? actividadDia;
  final String? estadoContenido;
  final String? resultadoActividad;

  const ClaseAsistencia({
    required this.id,
    required this.cursoId,
    required this.fecha,
    required this.tema,
    required this.observacion,
    required this.actividadDia,
    required this.estadoContenido,
    required this.resultadoActividad,
  });
}
