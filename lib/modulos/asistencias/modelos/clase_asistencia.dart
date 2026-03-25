class ClaseAsistencia {
  final int id;
  final int cursoId;
  final DateTime fecha;
  final String? tema;
  final String? observacion;
  final String? actividadDia;
  final String? estadoContenido;
  final String? resultadoActividad;
  final String? horaInicio;
  final String? horaFin;
  final String? aula;

  const ClaseAsistencia({
    required this.id,
    required this.cursoId,
    required this.fecha,
    required this.tema,
    required this.observacion,
    required this.actividadDia,
    required this.estadoContenido,
    required this.resultadoActividad,
    required this.horaInicio,
    required this.horaFin,
    required this.aula,
  });

  String? get franjaHoraria {
    final inicio = (horaInicio ?? '').trim();
    if (inicio.isEmpty) return null;
    final fin = (horaFin ?? '').trim();
    if (fin.isEmpty) return inicio;
    return '$inicio-$fin';
  }
}
